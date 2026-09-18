---
name: jax-style
description: Write JAX code matching the author's personal style. Use whenever writing or reviewing JAX code — pytrees, jit/vmap/scan, RNG keys, dataclasses, typing.
---

# JAX style

House rules for personal JAX code. Apply them even where a "more standard" alternative
exists. When reviewing, flag style deviations from these rules only, not generic JAX
style.

## Canonical shape

```python
class Agent[TState](Protocol):
    def step(self, key: Key, state: TState, obs: Array) -> tuple[TState, Array]: ...

@jax.tree_util.register_dataclass
@dataclass
class PPOState:
    params: PyTree
    opt_state: optax.OptState

@dataclass(frozen=True)
class PPO:
    env: Environment
    network: nn.Module
    learning_rate: float

    def step(self, key: Key, state: PPOState, obs: Array) -> tuple[PPOState, Array]: ...

    def rollout(
        self, key: Key, state: PPOState, env_state: EnvState, num_steps: int
    ) -> tuple[tuple[PPOState, EnvState], TimeStep]:
        def body(carry, key_step):
            state, env_state = carry
            key_act, key_env = jax.random.split(key_step)
            state, action = self.step(key_act, state, env_state.obs)
            env_state, timestep = self.env.step(key_env, env_state, action)
            return (state, env_state), timestep
        keys = jax.random.split(key, num_steps)
        return jax.lax.scan(body, (state, env_state), keys)

rollout = jax.jit(ppo.rollout, static_argnames="num_steps")  # bound once, outside the loop
```

## Pytrees and state

- Plain `@dataclass` + `@jax.tree_util.register_dataclass`. Never equinox, flax `struct`,
  `chex.dataclass`, or flax `nnx`. `NamedTuple` only for small scan carries.
- **Config lives on `self`, state is a separate pytree.** A class (`Agent`, `Dynamics`,
  `Environment`, `Solver`, `Buffer`) holds only what is fixed at construction: hyperparams,
  `cost_fn`, spaces, network modules. Anything reassigned between calls is state and is
  threaded explicitly: `state, out = obj.step(key, state, ...)`. An array fixed at
  construction (e.g. a stack of checkpoint params an ensemble is built from) may live on
  `self` — the line is reassignment, not array-ness.
- Config dataclasses are `frozen=True`; state dataclasses are not. Mutating a state's
  fields in place inside a jitted/scanned body (`state.params = ...`) is fine and pure at
  the trace boundary — don't refactor it into "always construct a new object". This holds
  only for objects received as an argument or scan carry; never mutate a closed-over
  object or `self`, which leaks tracers. Hazard: under `jit` the argument is a fresh
  unflattened object, but eagerly it is the caller's own object, so the old state is
  overwritten. Where a caller still needs the previous state (target networks, replay
  buffers, tests that diff states), use `dataclasses.replace` instead.
- Static fields are declared inline with `field(metadata=dict(static=True))`;
  `register_dataclass` infers the rest. Never pass `data_fields=`/`meta_fields=`.
- `jax.tree.*` for map/flatten/unflatten; `jax.tree_util` only for `register_dataclass`.

## Interfaces

- Shared contracts are `typing.Protocol`, never `ABC`. Implementations satisfy them
  structurally and do not inherit from them, so `@abstractmethod` has no effect and is
  not used. Parametrize over state types with PEP 695 generics:
  `class Agent[TState, TCarry](Protocol)`.
- Argument order: `key` first when the method consumes randomness, the object's own
  state next as bare `state`, foreign state qualified (`dynamics_state`).
- Return the object's own state first: `(state, output)`.

## Networks

- `flax.linen` modules for networks, `optax` for optimizers. Params and optimizer state
  are fields of the state pytree, never baked into the module. The module itself is
  static config on `self`.

## RNG keys

- `jax.random.key(seed)`, not the legacy `PRNGKey`.
- A key variable is `key`, or `key_<purpose>` when several are in scope (`key_actor`,
  `key_critic`). Never `<purpose>_key`, `rng`, `subkey`, `k1`. A batch of keys is `keys`.
- Split immediately before use and never reuse a split key. For a batch:
  `keys = jax.random.split(key, num_envs)` then `vmap`/`scan` over it. Across a pytree: split
  by leaf count and `jax.tree.unflatten` back.
- Split once per callee that consumes randomness and hand each its own key. Don't
  pre-split on behalf of a callee's internals — how many keys it needs is its business.

## Control flow

- Loops under `jit`, and any loop over timesteps, default to `jax.lax.scan`. A Python
  `for` over a small static range is fine when unrolling is the intent (layers, a handful
  of inner steps); `lax.while_loop` for dynamic termination. Host-side loops over jitted
  chunks, epochs, logging, and file I/O are fine.
- Reverse-time scans (e.g. GAE) use `reverse=True`, not array flips.
- `lax.cond` only saves work when the predicate is unbatched. Under `vmap` it lowers to
  a `select` and both branches run, so use `jnp.where` (or a `tree.map` of it) there and
  for cheap branches like env auto-reset. No Python `if` on a traced value.

## Logging

- Logging goes through `lox` (`import lox`), depended on as
  `"lox@git+https://github.com/huterguier/lox"`. The PyPI package named `lox` is unrelated.
  Log from inside jitted/scanned code with `lox.log({"name": value})`, never
  `jax.debug.print`/`jax.debug.callback` and never by threading metrics through return
  values or the scan carry. Per-step scan outputs are for data (`timestep`), not metrics.
  The library function stays unaware of where logs go; the caller picks them up:
  ```python
  lox.log(data: dict[str, Any], tags=()) -> None      # inside jit/scan/vmap
  y, logs = lox.spool(f)(*args)                       # collect; logs is a logdict
  y = lox.tap(f, callback=lambda logs: ...)(*args)    # stream live
  ```
  Inside `scan`, spooled logs come back stacked along the scan axis; under `vmap`, along
  the batch axis. `logdict` is a dict subclass, so `jax.tree.map(jnp.mean, logs)` works.

## Naming

- Integer counts take a `num_` prefix when they need one: `num_steps`, `num_envs`. Not
  `n`, `n_steps`, `steps`. Bare nouns that are unambiguous (`horizon`, `batch_size`) stay
  as they are.

## Types

- No jaxtyping, no shape-typed arrays. Every project has its own `typing.py` with the
  same aliases, and annotations use these rather than raw `jax.Array`/`jnp.ndarray`:
  ```python
  type Array = jax.Array
  type Key = jax.Array
  type PyTree = Any
  ```
- Shapes/dtypes go in docstrings or a trailing comment (`goal_pos: Array  # (2,)`).

## jit / static args

- Don't bake `@jax.jit` into library methods. Apply it at the call site on bound methods
  (`jax.jit(env.step)`) so callers control compilation boundaries. This works because
  `self` holds only static config; arrays on `self` are captured by value at trace time.
- Bind once, outside any loop: `step = jax.jit(env.step)`. Every `env.step` attribute
  access is a new bound-method object and would retrace.
- Non-array args like `num_steps` go in `static_argnames`.

## Validation and unused args

- Runtime checks on shapes and structure are plain `assert` with an f-string showing the
  actual value: `assert v.ndim == 1, f"expected shape (batch,), got {v.shape}"`. Shapes
  and dtypes are static, so these are fine inside `jit`. Never assert on the *value* of a
  traced array.
- Mark an intentionally unused but required arg with `del arg` right after the
  signature, not a leading underscore or `# noqa`.
- `__post_init__` validates narrowly — only what is load-bearing.

## Project conventions

- `requires-python >= 3.12`. Lint only: ruff, `target-version = "py312"`,
  `select = ["E", "F", "I", "W", "UP", "B"]`, `ignore = ["E501"]`. No `ruff format`,
  black, separate isort, or mypy.

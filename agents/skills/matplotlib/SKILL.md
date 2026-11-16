---
name: matplotlib
description: Make matplotlib figures matching the author's paper style. Use whenever creating or editing a matplotlib figure — sizes, fonts, colors, legends, multi-panel layouts, seeds.
---

# Matplotlib figures

Figures are made for papers: vector PDFs, sized to the page, included in LaTeX without
scaling.

## Style block

Each project has a `plotting.py` that sets the style once on import. Start from this
block; adjust it per project (font, `WIDTH`) rather than per figure.

```python
import matplotlib.pyplot as plt

WIDTH = 5.5  # inches, the venue's \textwidth (NeurIPS / ICLR)
plt.rc("font", family="serif", serif=["cmr10"], size=10)
plt.rc("mathtext", fontset="cm")
plt.rc(
    "axes",
    grid=True,
    axisbelow=True,
    titlesize=10,
    labelsize=10,
    linewidth=0.5,
    unicode_minus=False,
)
plt.rc("axes.formatter", use_mathtext=True)
plt.rc("axes.spines", top=False, right=False)
plt.rc("xtick", direction="in", labelsize=9)
plt.rc("ytick", direction="in", labelsize=9)
plt.rc("xtick.major", width=0.5, size=2.5)
plt.rc("ytick.major", width=0.5, size=2.5)
plt.rc("xtick.minor", width=0.4, size=1.5)
plt.rc("ytick.minor", width=0.4, size=1.5)
plt.rc("lines", linewidth=0.8)
plt.rc("figure.constrained_layout", use=True)
plt.rc("savefig", dpi=300)
plt.rc("grid", alpha=0.15, linewidth=0.4)
plt.rc("legend", fontsize=10, frameon=False)
```

- The font should match the document's body font: `cmr10` with `fontset="cm"` for
  Computer Modern templates; for Times-based venues use a Times serif with
  `fontset="stix"`.

## Size

- `WIDTH` is the target document's `\textwidth`. Without a venue, use 5.5 in
  (NeurIPS / ICLR).
- `WIDTH` is a maximum, not a default: `figsize=(w, h)` with `w <= WIDTH`, as wide as the
  content needs.
- The figure is included at natural size (`\includegraphics{fig.pdf}`, no
  `width=\linewidth`), so the font sizes are the printed sizes.
- Axis labels, titles, and legends are 10pt; tick labels 9pt. If panels do not fit,
  prefer fewer panels per row over smaller text.

## Layout

- Constrained layout handles spacing; avoid `tight_layout` and `subplots_adjust`.
- Panels showing the same quantity usually share axes (`sharex`, `sharey`), with the
  shared label only on the outer panels.
- Panels that show a 2-D space (parameters, latents, positions) use
  `ax.set_aspect("equal")`.

## Text

- Sentence case for labels, titles, and legend entries: "Learning rate", "Success rate".
- Math in mathtext with raw strings: `r"Latent dimension $K$"`, `r"$\eta = 10^{-5}$"`.
- Panel titles name the condition that differs between panels.

## Color

- Series use the default cycle by index, `color=f"C{i}"`, and a method keeps its color in
  every panel of a figure.
- Context (contours, meshes, guide lines) is thin and grey, e.g. `colors="0.7"`.
- Reference points and curves are black: start `"ko"`, optimum `"k*"`, oracle or baseline
  `"k:"`.
- Colormaps: sequential (`magma`, `viridis`) for magnitudes, diverging (`RdBu_r`) with
  symmetric limits for signed values, `gray` for pixel images.
- Comparable images share `vmin`/`vmax` and one colorbar: `fig.colorbar(im, ax=axes[:2])`.

## Legends

- Frameless (from the style block).
- A legend shared by all panels is one figure legend:
  `fig.legend(*axes[0].get_legend_handles_labels(), loc="outside upper center", ncols=n)`.
- A legend that would cover data goes outside the axes.

## Seeds

- Show the mean as a line plus the spread across seeds: faint per-seed points when there
  are few x values, a band for dense curves.
- Pick the band to fit the seed count (min–max for a handful, standard error or CI for
  many) and say in the caption what it is and how many seeds there are.

## Output

- Save as PDF; `dpi=300` only affects embedded rasters.

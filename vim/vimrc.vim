" Plugin-free vimrc mirroring the main settings/keybinds of huterguier/nvim.
" For machines where nvim isn't available (e.g. the cluster).

set nocompatible
syntax on
filetype plugin indent on

let mapleader = " "

set number
set relativenumber
set scrolloff=5

set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4

set backspace=indent,eol,start
set incsearch

if has('clipboard')
  set clipboard=unnamedplus
endif

augroup prose_wrap
  autocmd!
  autocmd FileType latex,tex,markdown,text setlocal wrap linebreak
  if exists('+breakindent')
    autocmd FileType latex,tex,markdown,text setlocal breakindent breakindentopt=shift:2,min:20
  endif
  autocmd FileType latex,tex,markdown,text nnoremap <buffer> <expr> j v:count == 0 ? 'gj' : 'j'
  autocmd FileType latex,tex,markdown,text nnoremap <buffer> <expr> k v:count == 0 ? 'gk' : 'k'
  autocmd FileType latex,tex,markdown,text vnoremap <buffer> <expr> j v:count == 0 ? 'gj' : 'j'
  autocmd FileType latex,tex,markdown,text vnoremap <buffer> <expr> k v:count == 0 ? 'gk' : 'k'
augroup END

nnoremap <leader>so :update<CR>:source $MYVIMRC<CR>
nnoremap <leader>w :write<CR>
nnoremap <leader>q :quit<CR>
nnoremap <leader>% :vs<CR>
nnoremap <leader>" :sp<CR>

inoremap jk <Esc>
inoremap kj <Esc>

" Split navigation (plain window commands; vim-tmux-navigator is nvim-only here)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

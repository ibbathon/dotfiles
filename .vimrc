" Handle Win/Lin config first
if has('win32') || has('win64')
  let $VIMHOME = $HOME."/vimfiles"
else
  let $VIMHOME = $HOME."/.vim"
endif


" Vundle config
set nocompatible
set encoding=utf-8
filetype off
set rtp+=$VIMHOME/bundle/Vundle.vim
call vundle#begin('$VIMHOME/bundle')
Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'
Plugin 'leafgarland/typescript-vim'
Plugin 'Glench/Vim-Jinja2-Syntax'
Plugin 'Valloric/YouCompleteMe'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'morhetz/gruvbox'
Plugin 'Konfekt/FastFold'
Plugin 'tmhedberg/SimpylFold'
Plugin 'rlue/vim-fold-rspec'
"Plugin 'nathanaelkane/vim-indent-guides'
"Plugin 'mkitt/tabline.vim'
call vundle#end()
filetype plugin indent on

" pathogen config
"execute pathogen#infect()

" airline config
let g:airline_section_y = ''
let g:airline_mode_map = {
      \ '__' : '--',
      \ 'n'  : 'N ',
      \ 'i'  : 'I ',
      \ 'R'  : 'R ',
      \ 'c'  : 'C ',
      \ 'v'  : 'Vc',
      \ 'V'  : 'Vl',
      \ '' : 'Vb',
      \ 's'  : 'Sc',
      \ 'S'  : 'Sl',
      \ '' : 'Sb',
      \ }
let g:airline_section_c = '%f'
let g:airline_symbols_ascii = 1
silent! call airline#extensions#whitespace#disable()

" My config
set hlsearch
set incsearch
set ignorecase
set wildignorecase

syntax on
if system('uname -s') == "Darwin\n"
  set clipboard=unnamed
else
  set clipboard=unnamedplus
endif
set backspace=indent,eol,start

set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2

set wrap
set linebreak
set nolist

filetype plugin indent on

"set path=.,**
set wildmode=longest:list

set noruler

set directory=$VIMHOME/swap/
set backupdir=$VIMHOME/backup/
set undodir=$VIMHOME/undo/
set undofile

set foldmethod=syntax
set foldlevelstart=30

set mouse=a
set ttymouse=sgr

set fileformats=unix,dos " Prefer unix line endings

" Netrw setup
let g:netrw_mousemaps=0 " Stupid Netrw
let g:netrw_sort_options='i' " Ignore case
let g:netrw_sort_by='name'
let g:netrw_sort_sequence='[\/]$' " Display directories first, then normal sorting
let g:netrw_browse_split=0

" Shortcut to write to a file that we need sudo access for
cmap w!! w !sudo tee > /dev/null %

" For some reason, C-PageUp and C-PageDown are not mapped correctly; remap them
map [5^ :tabp<CR>
map [6^ :tabn<CR>

" This only works if gruvbox Vundle is installed, but it's so much prettier
set background=dark
colorscheme gruvbox

" Keep docstring first line visible when folding Python
let g:SimpylFold_docstring_preview = 1

" Mark the 80th column, so I know when to break
set colorcolumn=80

" Disable ycm for commit message editing
autocmd BufNewFile,BufRead COMMIT_EDITMSG let g:ycm_auto_trigger = 0

" Autocomplete braces
inoremap {<CR> {<CR>}<Esc>ko
inoremap [<CR> [<CR>]<Esc>ko

" Only do the following in macvim or gvim
if has("gui_running")
  if has("win32") || has("win64")
    set guifont=Consolas:h9:cANSI:qDRAFT
    set lines=65
    set columns=80
  endif
  "set guifont=xos4\ Terminus\ 12
  "colorscheme slate
  "set transparency=15
  set guioptions=
else
  " Only do the following in a terminal

  " 1 or 0 -> blinking block
  " 2 -> solid block
  " 3 -> blinking underscore
  " 4 -> solid underscore
  " Recent versions of xterm (282 or above) also support
  " 5 -> blinking vertical bar
  " 6 -> solid vertical bar

  " Insert mode
  let &t_SI .= "\<Esc>[5 q"
  " Replace mode
  let &t_SR .= "\<Esc>[3 q"
  " Normal mode
  let &t_EI .= "\<Esc>[2 q"
endif

set showbreak=>>>\ 
set breakindent
set breakindentopt=min:40,shift:2,sbr

" Close scratch buffer when leaving insert mode, to clean up my panes
autocmd InsertLeave * if pumvisible() == 0 && bufname("%") != "[Command Line]"|pclose|endif

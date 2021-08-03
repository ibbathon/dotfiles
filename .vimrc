" Determine OS first
if has('win32') || has('win64')
  let os = "windows"
elseif has('win32unix')
  let os = "cygwin"
elseif has('macunix')
  let os = "mac"
else
  let os = "unix"
endif

" Handle Win/Lin config directory locations
if os == "windows" || os == "cygwin"
  let $VIMHOME = $HOME."/vimfiles"
else
  let $VIMHOME = $HOME."/.vim"
end

" Need to disable ALE's LSP before loading plugins, so it doesn't conflict
" with COC's LSP. Also need to edit CocConfig and add
" "diagnostic.displayByAle": true
let g:ale_disable_lsp = 1

"************************************
"***** Vundle and plugin config *****
"************************************
set nocompatible
set encoding=utf-8
filetype off
set rtp+=$VIMHOME/bundle/Vundle.vim
call vundle#begin('$VIMHOME/bundle')
" Necessary to prevent cleaning the main plugin
Plugin 'VundleVim/Vundle.vim'
" Languages
Plugin 'leafgarland/typescript-vim' " TypeScript syntax
Plugin 'peitalin/vim-jsx-typescript' " TypeScript-React syntax
Plugin 'quramy/tsuquyomi' " Typescript completion
Plugin 'omnisharp/omnisharp-vim' " C-Sharp syntax/completion/linting
Plugin 'adamclerk/vim-razor' " *.cshtml files
Plugin 'othree/xml.vim' " Better XML support (such as auto-folding)
Plugin 'JamshedVesuna/vim-markdown-preview' " Preview MD with Ctrl-P
Plugin 'davidhalter/jedi-vim' " Python auto-completion through Jedi
Plugin 'pappasam/coc-jedi' " Python LSP IDE support
" Appearance
Plugin 'vim-airline/vim-airline' " Status/Tabline
Plugin 'morhetz/gruvbox' " Color scheme
" Wrappers
Plugin 'tpope/vim-fugitive' " Adds git commands like Gstatus
Plugin 'tpope/vim-rbenv' " rbenv support for vim
Plugin 'dense-analysis/ale' " as-you-type linting
Plugin 'vim-test/vim-test' " run tests within vim
Plugin 'direnv/direnv.vim' " use direnv for env setup
Plugin 'neoclide/coc.nvim' " Add additional LSP support
" Folding
Plugin 'Konfekt/FastFold' " Folding performance gains
Plugin 'tmhedberg/SimpylFold' " Better folding for Python
Plugin 'rlue/vim-fold-rspec' " Folding for *_spec.rb files
" Other functionality
Plugin 'ctrlpvim/ctrlp.vim' " Quick file search
Plugin 'ajh17/vimcompletesme' " No-prereqs auto-completion
Plugin 'tyru/open-browser.vim' " Replace netrw's broken gx
Plugin 'AnsiEsc.vim' " Interpret color codes in log files (call `:AnsiEsc` to use)
Plugin 'gcmt/taboo.vim' " Rename tabs with TabooRename; reset with TabooReset
" Unsorted/Testing
" UNUSED/UNWANTED/REPLACED
"Plugin 'scrooloose/syntastic' " Auto syntax checking
"Plugin 'davidhalter/jedi-vim' " Advanced Python auto-complete (causes flicker)
"Plugin 'ervandew/supertab' " No-prereqs auto-completion
"Plugin 'nathanaelkane/vim-indent-guides'
"Plugin 'mkitt/tabline.vim'
"Plugin 'Glench/Vim-Jinja2-Syntax' " Jinja syntax (used at Vivial)
"Plugin 'Valloric/YouCompleteMe' " Powerful auto-completion (requires compile)
"Plugin 'nvie/vim-flake8' " Python linter Flake8 (not actually needed?)
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

" Keep docstring first line visible when folding Python
let g:SimpylFold_docstring_preview = 1

" Use Rubocop by default for Ruby files
let g:syntastic_ruby_checkers = ['rubocop']

" Disable ycm for commit message editing
autocmd BufNewFile,BufRead COMMIT_EDITMSG let g:ycm_auto_trigger = 0


"**********************
"***** var config *****
"**********************
set hlsearch
set incsearch
set ignorecase
set wildignorecase
set wrap
set linebreak
set nolist
set wildmode=longest:list
set noruler
set backspace=indent,eol,start
set foldmethod=syntax
set foldlevelstart=30
set mouse=a
set ttymouse=sgr
set showbreak=>>>\ 
set breakindent
set breakindentopt=min:40,shift:2,sbr

" Tab width and tabs-to-spaces
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2

" Visibly show tab characters, trailing whitespace
set list
set listchars=tab:>·,trail:·

" Split to the right/below, instead of left/above
set splitright
set splitbelow

" Syntax highlighting and other options
syntax on
filetype plugin indent on

" Use unnamedplus for Linux, unnamed for all other systems.
" This is because tmux copies into unnamedplus, but not unnamed.
if os == "unix"
  set clipboard=unnamedplus
else
  set clipboard=unnamed
end

" Put swap, undo, and backup files in ~/.vim
set directory=$VIMHOME/swap/
set backupdir=$VIMHOME/backup/
set undodir=$VIMHOME/undo/
set undofile " Allow undo in a file that was previously open

" Prefer unix line endings
set fileformats=unix,dos

" Mark the 80th column, so I know when to break
set colorcolumn=80,120

" Automatically reload files which have only had a timestamp change
set autoread

" This only works if gruvbox Vundle is installed, but it's so much prettier
if globpath(&runtimepath, 'colors/gruvbox.vim', 1) !=# ''
  set background=dark
  colorscheme gruvbox
end

" Netrw setup
let g:netrw_mousemaps=0 " Stupid Netrw
let g:netrw_sort_options='i' " Ignore case
let g:netrw_sort_by='name'
let g:netrw_sort_sequence='[\/]$' " Display directories first, then normal sorting
let g:netrw_browse_split=0
" Netrw's gx is broken: https://github.com/vim/vim/issues/4738
let g:netrw_nogx=1

" ALE setup
let g:ale_lint_on_text_changed = 'always' " check during both normal and insert, might want to disable on battery
" TODO: add check for battery, based on proc status, might want to attach to
" CursorHold

" OmniSharp setup
let g:OmniSharp_diagnostic_showid = 1 " show offending rule ID in linter messages


"*************************************
"***** Custom mappings and fixes *****
"*************************************

" Change C-p MD preview key to C-m (to avoid conflict with the ctrlp)
let vim_markdown_preview_hotkey='<C-m>'
let vim_markdown_preview_browser='Google Chrome'
let vim_markdown_preview_github=1

" Shortcut to write to a file that we need sudo access for
cmap w!! w !sudo tee > /dev/null %

" For some reason, C-PageUp and C-PageDown are not mapped correctly; remap them
map [5^ :tabp<CR>
map [6^ :tabn<CR>

" Autocomplete braces
" These are annoying, so I'm commenting them out for now
" inoremap {<CR> {<CR>}<Esc>ko
" inoremap [<CR> [<CR>]<Esc>ko

" Home moves to first non-whitespace on line
" If already on first non-whitespace, jumps to actual beginning of line
map <Home> :call LineHome()<CR>:echo<CR>
imap <Home> <C-R>=LineHome()<CR>
map ^[[1~ :call LineHome()<CR>:echo<CR>
imap ^[[1~ <C-R>=LineHome()<CR>
function! LineHome()
  let x = col('.')
  execute "normal ^"
  if x == col('.')
    execute "normal 0"
  endif
  return ""
endfunction

" Use open-browser to open https? links
nnoremap <silent> gx :<C-u> call openbrowser#_keymap_smart_search('n')<CR>
xnoremap <silent> gx :<C-u> call openbrowser#_keymap_smart_search('v')<CR>


"************************
"***** Autocommands *****
"************************

" Close scratch buffer when leaving insert mode, to clean up my panes
autocmd InsertLeave * if pumvisible() == 0 && bufname("%") != "[Command Line]"|pclose|endif

" Delete netrw's buffer, so I can actually quit
autocmd FileType netrw setl bufhidden=delete

" Use git's recommended line length for commits
autocmd FileType gitcommit let &colorcolumn=72

" JBuilder is a ruby filetype
autocmd BufRead,BufNewFile *.jbuilder set filetype=ruby


"***************************
"***** GUI vs terminal *****
"***************************

if has("gui_running")
  " Only do the following in macvim or gvim

  if has("win32") || has("win64")
    set guifont=Consolas:h9:cANSI:qDRAFT
  endif
  set lines=78
  set columns=242
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


"******************************
"***** Experimental stuff *****
"******************************
if os == "mac"
  function! CreateUsualBuffers()
    cd ~/gitwork/monorepo/server
    " First tab is notes
    :TabooRename NOTES
    :e ~/quicknotes
    :vs
    :e ~/standupnotes
    :vs
    :e ~/questions
    " Second tab is terminal stuff
    :tabnew
    :TabooRename TERMINAL
    :terminal ++curwin tmux
    :vs
    :terminal ++curwin tmux
    :vs
    :terminal ++curwin tmux
    " Finally, a normal tab
    :tabnew
    :vs
    :vs
  endfunction
  command! Usuals :call CreateUsualBuffers()

  " Go to fixture definition
  nmap <silent>gf :execute "lvimgrep /\\(def \\<" . expand("<cword>") . "\\>\\<Bar>\\<" . expand("<cword>") . "\\> = generate_mutation_fixture\\)/ tests/fixtures/**/*.py"<CR>
  " Use COC to jump to the definition
  nmap <silent>gd <Plug>(coc-definition)

  " Change linters based on project
  au BufNewFile,BufRead /Users/ibb/gitwork/monorepo/**/*.py let b:ale_linters = ["flake8", "mypy"]
endif

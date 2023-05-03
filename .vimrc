" requires .zshrc configuration for fzf https://learnvim.irian.to/basics/searching_files

" also from above - set :grep to use ripgrep
set grepprg=rg\ --vimgrep\ --smart-case\ --follow

" learnvim says to turn this on to avoid buffer save prompt
set hidden

" colorscheme from bundled themes
colorscheme iceberg

" Airline bar customization
" let g:airline_detect_spelllang=0
let g:airline_section_y = ''

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Enable language completion from https://lual.dev/blog/how-to-use-autocompletion-in-vim/
" Info at :h ins-completion
set omnifunc=syntaxcomplete#Complete

" Hide netrw directory banner
let g:netrw_banner = 0

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number

" Highlight cursor line underneath the cursor horizontally.
" set cursorline

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Ignore capital letters during search.
set ignorecase

" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
set smartcase

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Set the commands to save in history default number is 20.
set history=1000

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx


" PLUGINS ---------------------------------------------------------------- {{{

" Plugin code goes here.
" Don't forget to :PlugInstall after adding
call plug#begin('~/.vim/plugged')

	Plug 'tpope/vim-fugitive'
	Plug 'tpope/vim-commentary'
	Plug 'tpope/vim-surround'
	Plug 'junegunn/fzf.vim'
	Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'


call plug#end()

" }}}


" MAPPINGS --------------------------------------------------------------- {{{

" Mappings code goes here.
let mapleader = ","
inoremap jk <esc>
nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <Leader>f :Rg<CR>

" FZF buffers to <C-l> (for :ls)
nnoremap <silent> <C-l> :Buffers<CR>

" }}}


" VIMSCRIPT -------------------------------------------------------------- {{{

" More Vimscripts code goes here.
" If Vim version is equal to or greater than 7.3 enable undofile.
" This allows you to undo changes to a file even after saving it.
if version >= 703
    set undodir=~/.vim/backup
    set undofile
    set undoreload=10000
endif

" }}}


" STATUS LINE ------------------------------------------------------------ {{{

" Status bar code goes here.

" }}}

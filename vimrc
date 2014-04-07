"-------------------------------------- "
" 
" Basic vimrc configuration
" Author: Jakub Czarnowicz
" 
" -------------------------------------- " 


" Define modules here. Possible values:
" general - line numbers, tabs, vundle, stuff
" arrows
" programming
" look
" git
" ycm - ycm
" go - gocode, vim-golang
" python
let g:modules = ["general", "programming", "look", "git", "ycm", "go", "python"]

" GENERAL "
if count(g:modules, "general")
	set nocompatible              " be iMproved, required
	filetype off                  " required

	" PATH variable
	let $PATH.='/usr/lib64/mpi/gcc/openmpi/bin:/home/ciemny/bin:/usr/local/bin:/usr/bin:/bin:/usr/bin/X11:/usr/X11R6/bin:/usr/games:/opt/kde3/bin:/usr/lib/mit/bin:/usr/lib/mit/sbin:/home/ciemny/NetKit/bin:/home/ciemny/go_path/bin'
	" set the runtime path to include Vundle and initialize
	set rtp+=~/.vim/bundle/vundle/
	call vundle#rc()
	set shortmess+=filmnrxoOtT " Abbrev. of messages (avoids 'hit enter')
	set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
	set virtualedit=onemore " Allow for cursor beyond last character
	set history=1000 " Store a ton of history (default is 20)
	set spell " Spell checking on
	set hidden
	set backup
	set undofile
	set undolevels=1000
	set undoreload=10000
	Bundle "gmarik/vundle"
	Bundle 'jistr/vim-nerdtree-tabs'
	Bundle 'tpope/vim-surround'
	Bundle 'spf13/vim-autoclose'
	Bundle 'Lokaltog/vim-easymotion'
	Bundle 'Shougo/unite.vim'


	call unite#filters#matcher_default#use(['matcher_fuzzy'])
	" call unite#filters#sorter_default#use(['sorter_rank'])
	call unite#set_profile('files', 'smartcase', 1)
	call unite#custom#source('line,outline', 'matchers', 'matcher_fuzzy')
	call unite#custom#source('file', 'max_candidates', 0)

	let g:unite_data_directory = expand('~/.cache/unite')

	let g:unite_enable_start_insert        = 0
	let g:unite_source_history_yank_enable = 1

	let g:unite_prompt = '>>> '

	nnoremap <silent> <C-o>
				\ :<C-u>Unite
				\   -buffer-name=files
				\   -auto-resize
				\   -toggle
				\   file<CR>

	nnoremap <silent> <Leader><space>y
				\ :<C-u>Unite
				\   -buffer-name=yanks
				\   history/yank<CR>

	nnoremap <silent> <Leader><space>l
				\ :<C-u>Unite
				\   -buffer-name=lines
				\   -auto-resize
				\   line<CR>

	nnoremap <silent> <C-p>
				\ :<C-u>Unite
				\   -buffer-name=buffers
				\   -auto-resize
				\   buffer<CR>

	nnoremap <silent> <C-f>
				\ :<C-u>Unite
				\   -buffer-name=search
				\   -start-insert
				\   -no-quit
				\   grep:.<CR>

	nnoremap <silent> <Leader><space>m
				\ :<C-u>Unite
				\   -buffer-name=mappings
				\   -auto-resize
				\   mapping<CR>

	nnoremap <silent> <Leader><space>s
				\ :<C-u>Unite
				\   -quick-match
				\   buffer<CR>

	" key mapping "
	nnoremap <up> :bprev<CR>
	nnoremap <down> :bnext<CR>
	nnoremap <right> :tabnext<CR>
	nnoremap <left> :tabprev<CR>

	nmap <leader>rf :call Preserve("normal gg=G")<CR>
	nmap <leader>f$ :call StripTrailingWhitespace()<CR>
	vmap <leader>s :sort<cr>

	inoremap  <Up>     <NOP>
	inoremap  <Down>   <NOP>
	inoremap  <Left>   <NOP>
	inoremap  <Right>  <NOP>
	filetype plugin indent on

	nnoremap / /\v
	vnoremap / /\v
	nnoremap ? ?\v
	vnoremap ? ?\v
	nnoremap :s/ :s/\v

	" Paste from clipboard "
	inoremap <S-Insert> <ESC>"+p`]a

endif

" PROGRAMMING"
if count(g:modules, "programming")
	Bundle 'scrooloose/syntastic'
	" syntastic flags etc. "
	let g:syntastic_cpp_compiler = 'clang++'
	let g:syntastic_cpp_compiler_options = ' -std=c++11 -stdlib=libc++'
	Bundle 'tpope/vim-fugitive'
	Bundle 'mattn/webapi-vim'
	Bundle 'mattn/gist-vim'
	Bundle 'scrooloose/nerdcommenter'
	Bundle 'godlygeek/tabular'
	if executable('ctags')
		Bundle 'majutsushi/tagbar'
	endif
endif


" LOOK "
if count(g:modules, "look")
	Bundle 'Lokaltog/vim-powerline'
	Bundle 'spf13/vim-colors'
	Bundle 'altercation/vim-colors-solarized'
	Bundle 'mhinz/vim-startify'

	" stuff "
	set background=dark
	filetype plugin indent on
	syntax on
	set mouse=a
	set mousehide
	scriptencoding utf-8
	set backspace=indent,eol,start " Backspace for dummies
	set linespace=0 " No extra spaces between rows
	set nu " Line numbers on
	set relativenumber
	set showmatch " Show matching brackets/parenthesis
	set incsearch " Find as you type search
	set hlsearch " Highlight search terms
	set winminheight=0 " Windows can be 0 line high
	set ignorecase " Case insensitive search
	set smartcase " Case sensitive when uc present
	set wildmenu " Show list instead of just completing
	set wildmode=list:longest,full " Command <Tab> completion, list matches, then longest common part, then all.
	set whichwrap=b,s,h,l,<,>,[,] " Backspace and cursor keys wrap too
	set scrolljump=5 " Lines to scroll when cursor leaves screen
	set scrolloff=3 " Minimum lines to keep above and below cursor
	set foldenable " Auto fold code
	set shiftwidth=3
	set tabstop=3

	" margin "
	set colorcolumn=81

	" colors "
	let g:solarized_termcolors=256
	let g:solarized_termtrans=1
	let g:solarized_contrast="normal"
	let g:solarized_visibility="normal"

	set background=dark
	color molokai

	" status line "
	set laststatus=2
	set statusline=%<%f\ " Filename
	set statusline+=%w%h%m%r " Options
	set statusline+=%{fugitive#statusline()} " Git Hotness
	set statusline+=\ [%{&ff}/%Y] " Filetype
	set statusline+=\ [%{getcwd()}] " Current dir
	set statusline+=%=%-14.(%l,%c%V%)\ %p%% " Right aligned file nav info

	let mapleader = ','

	" shifting in visual mode"
	vnoremap < <gv
	vnoremap > >gv


endif


" GIT "
if count(g:modules, "git")
endif


" YouCompleteMe"
if (count(g:modules, "ycm"))
	Bundle 'Valloric/YouCompleteMe'
	Bundle 'SirVer/ultisnips'
	Bundle 'honza/vim-snippets'
	let g:ycm_confirm_extra_conf = 0
endif


" GOLANG "
if count(g:modules, "go")
	filetype off
	filetype plugin indent off
	set runtimepath+=$GOROOT/misc/vim
	filetype plugin indent on
	syntax on
	Bundle "jnwhiteh/vim-golang"
	Bundle "Blackrush/vim-gocode"
	Bundle "jstemmer/gotags"

	" tags "
	let g:tagbar_type_go = {
				\ 'ctagstype' : 'go',
				\ 'kinds'     : [
				\ 'p:package',
				\ 'i:imports:1',
				\ 'c:constants',
				\ 'v:variables',
				\ 't:types',
				\ 'n:interfaces',
				\ 'w:fields',
				\ 'e:embedded',
				\ 'm:methods',
				\ 'r:constructor',
				\ 'f:functions'
				\ ],
				\ 'sro' : '.',
				\ 'kind2scope' : {
				\ 't' : 'ctype',
				\ 'n' : 'ntype'
				\ },
				\ 'scope2kind' : {
				\ 'ctype' : 't',
				\ 'ntype' : 'n'
				\ },
				\ 'ctagsbin'  : 'gotags',
				\ 'ctagsargs' : '-sort -silent'
				\ }
endif


" PYTHON "
if count(g:modules, "python")
	Bundle 'klen/python-mode'
	Bundle 'python.vim'
	Bundle 'python_match.vim'
	Bundle 'pythoncomplete'
endif

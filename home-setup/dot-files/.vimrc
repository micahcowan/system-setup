" This vimrc file is based on the example vimrc provided with vim.
" My customizations are at the end.
"
" Info on the vimrc file it originally came from:
" Maintainer:   Bram Moolenaar <Bram@vim.org>
" Last change:  2002 Sep 19

" Deal with older Vims.
if v:version > 600

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup          " do not keep a backup file, use versions instead
else
  set backup            " keep a backup file
endif
set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set incsearch           " do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  " autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
      " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

else

  set autoindent                " always set autoindenting on

endif " has("autocmd")

"
" Micah's customizations follow.
"

set exrc
set number
set relativenumber
set softtabstop=4
set expandtab
set notimeout       -- Let me take as long as I want to type a binding
set shiftwidth=4
set textwidth=77
set backspace=indent,eol,start
set belloff=complete,error,esc
set cino=(0,W2s
set hidden
set autoindent
if !has("nvim")
    exe "set pastetoggle=\<C-\>"
endif
nmap <M-u> :nohls<C-M>
nmap <Esc>u :nohls<C-M>

set smartcase
set ignorecase

set nobackup
set noswapfile

let g:changelog_username="Micah Cowan  <micah@addictivecode.org>"

"autocmd BufEnter *  lcd %:p:h

"if has("gui_running")
"    set guifont=Monospace\ 8
"    set guioptions-=T
"    set guioptions-=m
"endif

" Quick access to cnext, cprev
nmap <Tab> :cnext<Return>
nmap <S-Tab> :cprev<Return>

" Cscope stuff
if has("cscope") && !has("nvim")
    set csto=0
    set cst
    set nocsverb
    " add any database in current directory
    if filereadable("cscope.out")
        cs add cscope.out
        " else add database pointed to by environment
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif
    set csverb

    nmap <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-_>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-_>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-_>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-_>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-_>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-_>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-_>d :cs find d <C-R>=expand("<cword>")<CR><CR>
endif

if &term =~ '^screen' && !has('nvim')
    set mouse=nic
    set ttymouse=xterm2
endif

if !has('nvim')
    set printoptions=header:0,paper:letter
endif

set bg=dark

if !has('nvim')
    set noesckeys
endif

set exrc
set secure

set listchars=eol:$,tab:>-

set modelines=3
set modeline

execute pathogen#infect()

autocmd BufRead,BufNewFile *.s set ft=asm_ca65

" Convenience searches to find over-indented lines
" (when indent is expected to be 2).
let @i="/^\\( *\\)[^ ].*\\n   \\1/"
let @j="/^+ \\( *\\)[^ ].*\\n+    \\1\\|^+   *$/"

if filereadable(expand('~/.vimrc-local'))
    source ~/.vimrc-local
endif

endif " v:version > 600

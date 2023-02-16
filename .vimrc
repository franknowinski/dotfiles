set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" Utils
Plugin 'AndrewRadev/splitjoin.vim'
Plugin 'benmills/vimux'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'christoomey/vim-tmux-runner'
Plugin 'craigemery/vim-autotag'
Plugin 'edkolev/tmuxline.vim'
Plugin 'elixir-editors/vim-elixir'
"Plugin 'epmatsw/ag.vim'
Plugin 'godlygeek/tabular'
Plugin 'janko-m/vim-test'
Plugin 'jiangmiao/auto-pairs'
Plugin 'junegunn/vim-easy-align'
Plugin 'leafgarland/typescript-vim'
Plugin 'majutsushi/tagbar'
Plugin 'mattn/emmet-vim'
Plugin 'mxw/vim-jsx'
Plugin 'neomake/neomake'
Plugin 'ngmy/vim-rubocop'
Plugin 'pangloss/vim-javascript'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'simeji/winresizer'
Plugin 'sonph/onehalf'
Plugin 'tasn/vim-tsx'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tmm1/ripper-tags'
Plugin 'tpope/vim-bundler'
Plugin 'tpope/vim-dispatch'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-projectionist'
Plugin 'tpope/vim-ragtag'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-rbenv'
Plugin 'tpope/vim-rhubarb'
Plugin 'tpope/vim-sleuth'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-ruby/vim-ruby'
Plugin 'vim-syntastic/syntastic'
Plugin 'vimwiki/vimwiki'
Plugin 'junegunn/fzf', { 'do': { -> fzf#install()  }  }
Plugin 'easymotion/vim-easymotion'
Plugin 'MaxMEllon/vim-jsx-pretty'
Plugin 'junegunn/fzf.vim'
Plugin 'haishanh/night-owl.vim'
"Plugin 'neoclide/coc.nvim', {'branch': 'release'}
"Plugin 'wincent/command-t'
Plugin 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

call vundle#end()
filetype plugin indent on

" Prettier
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md PrettierAsync

" Syntax
syntax on
set t_Co=256
set background=dark

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" Vim Easy Motion
map <leader>/ <Plug>(easymotion-bd-w)
nmap <Leader>/ <Plug>(easymotion-overwin-w)
nmap s <Plug>(easymotion-overwin-f2)
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)
map  n <Plug>(easymotion-next)
map  N <Plug>(easymotion-prev)

let g:EasyMotion_smartcase = 1

" Map Leader
let mapleader = ","

" Airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 0
let g:jsx_ext_required = 0

let g:airline_theme='luna'
"let g:airline_theme='wombat'
let &t_AB="\e[48;5;%dm"
let &t_AF="\e[38;5;%dm"
let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"

let g:CommandTTraverseSCM='pwd'

runtime macros/matchit.vim

set number
set backspace=indent,eol,start
set clipboard=unnamed
set incsearch
set hlsearch
set ignorecase
set tags=tags;/
set tags+=gems.tags
set noswapfile
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
set ttymouse=xterm2
set mouse=a
set nowrap
set hidden
set history=10000
set scrolloff=4
set noesckeys
set ttimeout
set ttimeoutlen=1
set relativenumber
set path=$PWD/**
set exrc

 " For night-owl color scheme
 "if (has("termguicolors"))
   "set termguicolors
 "endif
 if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

syntax enable
colorscheme night-owl

" Exclude included files with vim autocomplete
set complete-=i

" Key Mappings
nmap <leader>vr :tabe $MYVIMRC<cr>
nmap <leader>rv :source $MYVIMRC<cr>

cnoremap %% <C-R>=expand('%:h').'/'<cr>
nmap <space>e :edit %%
nmap <space>v :view %%

" Window
nnoremap <leader>1 <C-w>_<cr>
nnoremap <leader>2 <C-w>\|<cr>
nnoremap <leader>3 <C-w>=<cr>

" Bash
""nmap <space>z :!
""imap <space>z :!

" Find and replace in file
nmap <space>F :%s/<c-r><c-w>//g<left><left>

" Debuggers
imap cll console.log();<Esc>==f(a
nmap cll yiwocll
imap ppp binding.pry
nmap ppp yiwoppp
imap dgr debugger
nmap dgr yiwodgr
imap ppb <%= binding.pry %>
nmap ppb ywippb

" Deleting
nnoremap <leader>d "_d
xnoremap <leader>d "_d
xnoremap <leader>p "_dP

" Yank all
imap ya y$
nmap ya y$

" Search directory
nnoremap <leader>ta :ta<SPACE>
nnoremap <leader>tb :TagbarToggle<CR>
nnoremap <leader><space> :noh<CR>
nnoremap <leader>x :only<CR>
cnoremap <C-a> <C-b>
map \ :NERDTreeToggle<CR>
map \| :NERDTreeFind<CR>
map <leader>rt :!~/.vim/bin/update_ctags 2>/dev/null &<CR>
map <leader>g :Git blame<CR>
nmap <space>b <c-^>
nmap <space>w :w<cr>
nmap <space>q :q!<cr>
nmap <leader>q :wq<cr>
nmap <leader>w :set wrap!<cr>
map <space><tab> :Tabularize /
map <leader>p :pu<cr>
nmap 0 ^
nmap <space>f gg=G<cr>``<cr>
nmap <leader>fh :%s/:\(\w\+\)\s*=>\s*/\1: /g<CR>
nmap <leader>fs :%s/'/"/g<cr>
nmap <leader>fS :%s/"/'/g<cr>
map <leader>m :CommandTMRU<CR>

" FZF
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

set secure

let g:fzf_preview_highlighter = "highlight -o xterm256 --line-number --style rdark --force"
let g:fzf_preview_window = 'right:60%'

command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* Find
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(expand('<cword>')), 1,
  \   fzf#vim#with_preview(),
  \   <bang>0)

command! -bang -nargs=+ -complete=dir Rag call fzf#vim#ag_raw(<q-args>, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

" Move lines
nnoremap <leader>vv :m .+1<CR>==
nnoremap <leader>ff :m .-2<CR>==
inoremap <leader>vv <Esc>:m .+1<CR>==gi
inoremap <leader>ff <Esc>:m .-2<CR>==gi
vnoremap <leader>vv :m '>+1<CR>gv=gv
vnoremap <leader>ff :m '<-2<CR>gv=gv
nnoremap <leader>- :wincmd _<cr>:wincmd \|<cr>
nnoremap <leader>= :wincmd =<cr>

" Open bundler
nmap <leader>bs :Bsplit<cr>

" Open routes
nmap <leader>br :e config/routes.rb<cr>

" Open in GitHub
" nmap <leader>G :Gbrowse master:%<cr>
" Open PR in Github from Git Blame
" nmap <space>G :Gbrowse <c-r><c-w><cr>

nmap <space>G :Gbrowse <c-r><c-w><cr>
" Open PR on line
nmap <leader>G :.GBrowse <cr>

" Sort
vnoremap <leader>S :sort<cr>

" Split windows
map <leader>- :split<cr>
map <leader>\ :vsplit<cr>

" Prettier
map <leader>p :PrettierAsync<cr>

" Replace word under cursor with buffer
nmap <space>r viw"0p

" Copy word under cursor into buffer
nmap <space>c yiw

autocmd BufWritePre * :%s/\s\+$//e
autocmd VimResized * :wincmd =
au VimEnter * highlight clear SignColumn
imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")
let g:user_emmet_leader_key=","

" Rename Current File
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction
map <leader>n :call RenameFile()<cr>

" Promote Variable to Rspec Let
function! PromoteToLet()
  :normal! dd
  " :exec '?^\s*it\>'
  :normal! P
  :.s/\(\w\+\) = \(.*\)$/let(:\1) { \2 }/
  :normal ==
endfunction
:command! PromoteToLet :call PromoteToLet()
:map <leader>l :PromoteToLet<cr>

" Open up file to last cursor position
autocmd BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal g`\"" |
      \ endif

" Fix Multiple cursors lag in change mode
function! Multiple_cursors_before()
  if exists(':NeoCompleteLock')==2
    exe 'NeoCompleteLock'
  endif
endfunction

function! Multiple_cursors_after()
  if exists(':NeoCompleteUnlock')==2
    exe 'NeoCompleteUnlock'
  endif
endfunction

" Vim easy align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)"

let g:test#strategy = 'vimux'
"let test#project_root = '~/Projects/tc-www/app/javascript_apps/'
let g:test#javascript#jest#file_pattern = '.*\.spec\.js'

nmap <space>t :w<cr> :TestNearest<CR>
nmap <space>T :w<cr> :TestFile<CR>
nmap <space>l :w<cr> :TestLast<CR>
nmap <space>s :w<cr> :TestSuite<CR>

" Italics
hi htmlArg gui=italic
hi Comment gui=italic
hi Type    gui=italic
hi htmlArg cterm=italic
hi Comment cterm=italic
hi Type    cterm=italic

"'nearest': '--backtrace',
let test#ruby#rspec#options = {
  \ 'file':    '--format documentation',
  \ 'suite':   '--tag ~slow',
\}

set wildignore+=*/node_modules/*
set wildignore+=*/bower_components/*"

" Navigation
nnoremap <c-p> :Files<CR>

map <leader>jg :GFiles<CR>
map <leader>m :Buffers <CR>
map <leader>h :History <CR>

map <leader>ja :Files app<CR>
map <leader>jm :Files app/models<CR>
map <leader>jc :Files app/controllers<CR>
map <leader>jv :Files app/views<CR>
map <leader>jh :Files app/helpers<CR>
map <leader>js :Files app/services<CR>
map <leader>jw :Files app/workers<CR>
map <leader>jr :Files app/javascript_apps/<CR>
map <leader>je :Files app/services/distribution_system<CR>
map <leader>jl :Files lib<CR>
map <leader>ji :Files infra<CR>
map <leader>jp :Files public<CR>
map <leader>jt :Files spec<CR>
map <leader>jC :Files config<CR>
map <leader>jD :Files db<CR>
map <leader>jf :Files spec/support/factories<CR>
map <leader>jd :Files %%<CR>

map <leader>aa :Find <c-r>=expand("<cword>")<cr><cr>
map <leader>sa :Rag <c-r>=expand("<cword>")<cr> app/<cr>
map <leader>sm :Rag <c-r>=expand("<cword>")<cr> app/models<cr>
map <leader>sc :Rag <c-r>=expand("<cword>")<cr> app/controllers<cr>
map <leader>sv :Rag <c-r>=expand("<cword>")<cr> app/views<cr>
map <leader>sh :Rag <c-r>=expand("<cword>")<cr> app/helpers<cr>
map <leader>ss :Rag <c-r>=expand("<cword>")<cr> app/services<cr>
map <leader>sw :Rag <c-r>=expand("<cword>")<cr> app/workers<cr>
map <leader>sr :Rag <c-r>=expand("<cword>")<cr> app/javascript_apps/<cr>
map <leader>se :Rag <c-r>=expand("<cword>")<cr> app/services/distribution_system<cr>
map <leader>sl :Rag <c-r>=expand("<cword>")<cr> lib/<cr>
map <leader>si :Rag <c-r>=expand("<cword>")<cr> infra/<cr>
map <leader>sp :Rag <c-r>=expand("<cword>")<cr> public/<cr>
map <leader>st :Rag <c-r>=expand("<cword>")<cr> spec/<cr>
map <leader>sC :Rag <c-r>=expand("<cword>")<cr> config/<cr>
map <leader>sD :Rag <c-r>=expand("<cword>")<cr> db/<cr>
map <leader>sf :Rag <c-r>=expand("<cword>")<cr> spec/support/factories<cr>
map <leader>sd :Rag <c-r>=expand("<cword>")<cr> %%<cr>

map <space>aa :Rag -i<space>
map <space>sa :Rag -i <space>app/<C-Left><Left>
map <space>sm :Rag -i <space>app/models/<C-Left><Left>
map <space>sc :Rag -i <space>app/controllers/<C-Left><Left>
map <space>sv :Rag -i <space>app/views/<C-Left><Left>
map <space>sh :Rag -i <space>app/helpers/<C-Left><Left>
map <space>ss :Rag -i <space>app/services/<C-Left><Left>
map <space>sw :Rag -i <space>app/workers/<C-Left><Left>
map <space>sr :Rag -i <space>app/javascript_apps/<C-Left><Left>
map <space>se :Rag -i <space>app/services/distribution_system<C-Left><Left>
map <space>sl :Rag -i <space>lib/<C-Left><Left>
map <space>si :Rag -i <space>infra/<C-Left><Left>
map <space>sp :Rag -i <space>public/<C-Left><Left>
map <space>st :Rag -i <space>spec/<C-Left><Left>
map <space>sC :Rag -i <space>config/<C-Left><Left>
map <space>sD :Rag -i <space>db/<C-Left><Left>
map <space>sf :Rag -i <space>spec/support/factories/<C-Left><Left>
map <space>sd :Rag -i <space>%%<C-Left><Left>

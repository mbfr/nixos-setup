{ config, lib, pkgs, modulesPath, ... }:

{
  environment.systemPackages = with pkgs; [
    (python310.withPackages(ps: [
      ps.jedi
      ps.pynvim
      ps.yamllint
    ]))

    (neovim.override {
      configure = {
        packages.myPlugins = with pkgs.vimPlugins; {
          start = [
            (nvim-treesitter.withPlugins (
               plugins: pkgs.tree-sitter.allGrammars
            ))
          ];
        };
      };
    })

    (neovim.override {
      vimAlias = true;
      configure = {
        packages.myPlugins = with pkgs.vimPlugins; {
          start = [
            vim-lastplace
            vim-nix
            nvim-treesitter
            ctrlp-vim
            nvim-fzf
            neomake
            deoplete-tabnine
          ]; 
          opt = [];
        };
        customRC = ''
          scriptencoding utf-8 " utf-8 all the way
set encoding=utf-8
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1

let s:editor_root=expand("~/.config/nvim")


""""""""""""""""""""
" deoplete
let g:deoplete#enable_at_startup = 1
"call deoplete#custom#option('smart_case', v:true)
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

let g:neomake_yaml_enabled_makers = ['yamllint']
let g:neomake_python_enabled_makers = ['pyflakes']
" autocmd FileType python,pyopencl setlocal omnifunc=pythoncomplete#Complete
autocmd! BufRead,BufWritePost * Neomake
" call neomake#configure#automake('rw', 500)
" call neomake#configure#automake('rw', 1000)

" highlighting
hi link ALEError Error
hi Warning term=underline cterm=underline ctermfg=Yellow gui=undercurl guisp=Gold
hi link ALEWarning Warning
hi link ALEInfo SpellCap
""""""""""""""""""""

set autoindent
set showmatch

let g:UltiSnipsExpandTrigger = '<C-j>'
let g:UltiSnipsJumpForwardTrigger = '<C-j>'
let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

hi Folded ctermbg=8 ctermfg=blue
hi FoldColumn ctermbg=darkgrey ctermfg=white

hi Search ctermbg=yellow ctermfg=black

"popup menu
hi Pmenu ctermbg=white
hi Pmenusel ctermbg=yellow

" need tabs in makefile
autocmd bufnewfile,bufread,Filetype make set noexpandtab

" change leader key to , from \
let mapleader = ","

"ctrlp
let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:30'
"let g:ctrlp_working_path_mode = 'c'
let g:ctrlp_working_path_mode = 0
" stop stupid auto indenting with labels
let g:ctrlp_switch_buffer = 'et'
"map <leader>D  :call delete(expand('%')) \| bdelete! <CR>
let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:30'

let g:vim_tags_auto_generate = 1
let g:vim_tags_directories = ["."]

map <leader>c  :TagsGenerate!<CR>
map <leader>t  :CtrlP<CR>
map <leader>T  :CtrlPTag<CR>
map <leader>b  :CtrlPBuffer<CR>

"auto syntax on :Style
command Style %!astyle --style=ansi --align-pointer=middle --add-brackets --break-blocks

"autocmd BufWinEnter * normal zM
"autocmd BufWinEnter * normal zR

"spellcheck on ctrl-l
map <Esc>[s1z=

"autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" refresh diff
autocmd BufWritePost * if &diff == 1 | diffupdate | endif

if executable('rg')
  set grepprg=rg\ --color=never
  let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
  let g:ctrlp_use_caching = 0

  let g:ackprg = 'rg --vimgrep --smart-case'
elseif executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0

  let g:ackprg = 'ag --vimgrep --smart-case'
endif

cnoreabbrev Ack Ack!
nnoremap <Leader>a :Ack!<Space>
nnoremap <Leader>A :Ack!<Space><cword><CR>

let g:rainbow_conf = {
\	'guifgs': ['darkyellow', 'darkorange3', 'seagreen3', 'firebrick'],
\    }
let g:rainbow_active = 1

" format as json with =j
nmap =j :%!python -m json.tool<CR>

set termguicolors
"colorscheme srcery

" Note: Neovim ignores t_Co and other terminal codes.
" set t_Co=256

" always draw column for gitgutter
set signcolumn=yes

" interactive mouse
set mouse=a


function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

set laststatus=2
set backspace=2

" types
set wildignore+=*.lo
set wildignore+=*.pyc
set wildignore+=*.o
set wildignore+=*.a
set wildignore+=*.npz
set wildignore+=*.so
set wildignore+=*.pdf
set wildignore+=*.ps
set wildignore+=*.eps
set wildignore+=*.dvi
set wildignore+=*.gz
set wildignore+=*.bz2
set wildignore+=*.zip

" folders
set wildignore+=.git
set wildignore+=*.eggs/**
set wildignore+=*.egg-info/**
set wildignore+=**/node_modules/**
set wildignore+=**/build/lib.linux-x86_64-*
set wildignore+=**/node_modules
set wildignore+=**/.svn
set wildignore+=**/.idea
set wildignore+=**/__pycache__

set diffopt+=vertical

set foldmethod=marker
set foldlevel=1
set nofoldenable
set foldnestmax=10

set hlsearch

set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4
"set background=dark

"autocmd Filetype tex set tabstop=2 shiftwidth=2 softtabstop=2

"syntax on
set showtabline=2
set number
set ruler

set noswapfile
set ignorecase
set smartcase
set incsearch
let g:is_posix = 1

set backspace=indent
set backspace+=eol
set backspace+=start
set cinoptions+=L0

"map <F6> :e \| :! `pdflatex *.tex && bibtex *.aux && makeglossaries *.glo && pdflatex *.tex` <CR><CR>
"map <F7> :e \| :! latex *.tex && dvips -Ppdf *.dvi && ps2pdf *.ps <CR><CR>
"map <F3> :e \| :w !detex \| wc -w<CR>

"C++11
let c_no_curly_error=1

" turn off stupid auto indenting
set autoindent
set nocindent
set nosmartindent

filetype indent off
filetype plugin indent off

autocmd BufNewFile,BufRead requirements.txt set ft=cfg

autocmd BufNewFile,BufRead *.json set ft=javascript
"autocmd BufNewFile,BufRead *.tex set tw=130
autocmd BufNewFile,BufRead *.tex set spell spelllang=en_gb
autocmd BufNewFile,BufRead *.cl set ft=c
autocmd BufNewFile,BufRead *.cuknl set ft=cuda
autocmd BufNewFile,BufRead interfaces set ft=interfaces
autocmd BufNewFile,BufRead Rockerfile set ft=dockerfile
autocmd BufNewFile,BufRead *.Rockerfile set ft=dockerfile
autocmd BufNewFile,BufRead *.rockerfile set ft=dockerfile
autocmd BufNewFile,BufRead *.dockerfile set ft=dockerfile
autocmd BufNewFile,BufRead *.Dockerfile set ft=dockerfile
autocmd BufNewFile,BufRead Dockerfile.* set ft=dockerfile

autocmd BufNewFile,BufRead *.conf set ft=conf

autocmd BufNewFile,BufRead iptables.* set ft=iptables

autocmd BufNewFile,BufRead *.chpl set ft=chpl
autocmd BufNewFile,BufRead sw-description set ft=lua
"autocmd BufNewFile,BufRead *.py set ft=pyopencl

autocmd BufNewFile,BufRead iptables.* set ft=iptables

autocmd BufNewFile,BufRead *.its set ft=dts
autocmd BufNewFile,BufRead *.socket set ft=systemd

autocmd BufNewFile,BufRead .pylintrc set ft=cfg

map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

let g:go_highlight_structs = 1 
let g:go_highlight_methods = 1
let g:go_highlight_functions = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
EOF

          " ...
        '';
      };
    }
    )
  ];

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.viAlias = true;
  programs.neovim.withPython3 = true;
  # programs.neovim.withNodeJs = true;

}

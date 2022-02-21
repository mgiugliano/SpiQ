"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" This is my .vimrc configuration file
# February 21st 2022 - Michele Giugliano (mgiugliano@gmail.com)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Global comfort-related remappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ","
" remap leader from \ to,

nnoremap;:
" For: w, : q!, etc., pressing SHIFT becomes optional
"nnoremap:;

nnoremap < leader > w: w!< CR >
nnoremap < leader > z: wq!< CR >
nnoremap < leader > q: q!< CR >
vnoremap < leader > q < esc >: q!< CR >
" Remap frequent commands(write, quit, and wite & quit)

nnoremap < leader > v: vsplit < CR >
nnoremap < leader > h: split < CR >
" Remap vertical, horizontal splits

nnoremap < Up >: resize + 2 < CR >
nnoremap < Down >: resize - 2 < CR >
nnoremap < Left >: vertical resize + 2 < CR >
nnoremap < Right >: vertical resize - 2 < CR >
" Arrow keys now resize vertical/horizontal splits

nnoremap < leader > <Tab > za
nnoremap < leader > <S-Tab > : FoldToggle < CR >
" Fold and unfould Markdown sections

map < C-h > <C-w > h
map < C-j > <C-w > j
map < C-k > <C-w > k
map < C-l > <C-w > l
" Splits - navigation(simpler keystrokes)

nnoremap < Tab >: ls < CR > : b < Space >
nnoremap < S-Tab > : b  # <CR>
nnoremap < C-B > : bnext < CR >
" Buffers - navigation
nnoremap < leader > x: Bdelete < CR >
" Deletes the current buffer(thanks to vim-bbye plugin)

map < leader > o: setlocal spell < CR >
" Activate spell checking - orthography

" To add words to your own word list: zg


nnoremap < leader > s z =
" Spell checking - suggest replacement

inoremap < C-l > <c-g > u < Esc > [s1z=`]a < c-g > u
" Pressing CTRL+L in insert mode jumps to the previous mistake([s),
" then picks the first suggestion(1z=) and then jumps back `[a

nnoremap S: % s//g < Left > <Left >
" Replace all is aliased to S.

"inoremap [ @ [@<C-x > <C-o >
autocmd Filetype markdown, rmd, vimwiki inoremap, 2 < C-x > <C-o >
autocmd Filetype markdown, rmd, vimwiki inoremap < Up > <C-p >
autocmd Filetype markdown, rmd, vimwiki inoremap < Down > <C-n >


" nnoremap < C-P > : r !pbpaste < CR >
" Use Ctrl+P to paste from the clipboard(on macOs)

nnoremap tn: tabnew < Space >
nnoremap tk: tabnext < CR >
nnoremap tj: tabprev < CR >
nnoremap th: tabfirst < CR >
nnoremap tl: tablast < CR >
" Tabs - navigation


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Specific settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set termguicolors     " enable true colors support

set spelllang= en_us, it

"
" Editor Internals, Controls, and Appearances
"set nocompatible                  " Use Vim(default) rather than Vi settings.
set backup                        " Backups are nice ...
set backupdir = ~/.tmp               " Path to backup files
set directory = .                  " Path to swap files
set swapfile
"set noswapfile                    " Do not use swapfiles
set fileformats = unix, dos, mac
set ruler 						  " Show current line and column number in the status bar
set number relativenumber   	  " Hybdrid mode of line numbering: current line and relative nums to it
set cursorline                    " highlight current line
"set cursorcolumn 				   " highlight current column
set showcmd                       " show command in bottom bar
set cmdheight = 1                   " Number of screen lines to use for the command-line
set showmode                      " Display the current mode
set splitbelow splitright         " New splits open at the bottom and right, unlike vim defaults
set modeline
set modelines = 10
set title
set titleold = "Terminal"
set titlestring = %F
set wildmenu                      " visual autocomplete for command menu
set wildchar= <Tab > wildmenu wildmode = longest, list, full
set encoding = utf-8
set fileencoding = utf-8
set fileencodings = utf-8
set bomb
set binary
set ttyfast
set regexpengine = 1 				  " Use the old regex engine to improve performances
set autoread 					  " Automatically reload file, if content changed externally
set backspace = indent, eol, start    " Make backspace behave in a sane manner.
set hidden                        " Allow hidden buffers, don't limit to 1 file per window/split
set mouse = a"n                     " Enable the mouse but only in normal mode
set ttymouse = xterm2               " Improved xterm mouse handling
set shell = /bin/bash               " Command to start a shell
set path += ** " List of directories to search(tab completion)
set ttimeoutlen = 10				  " no delay when quitting visual mode with < Esc >
set updatetime = 1000               " decreased from 4s (default) to 1s, for git-gutter
filetype plugin on
filetype plugin indent on         " Enable file type detection and do language-dependent indenting.
"if $TMUX == ''
    set clipboard += unnamed 		  " Make the yank/paste working in vim within a TMUX session too
"endif 							  " the option 'unnamed' makes it working with OSX copy/paste

" Options for Find and Text Processing
"set noincsearch                     " no incremental search(search after characters are entered)
set incsearch                     " incremental search(search while characters are entered)
set nohlsearch                    " Does NOT highlight all matches
"set hlsearch                      " highlight ALL matches
set ignorecase smartcase          " case-sensitive only if they contain upper-case chars
set synmaxcol = 200 				  "Don't bother highlighting anything over 200 chars
syntax enable                         " Switch syntax highlighting on
set conceallevel = 0                " I don't like the rendering of Markdown by VIM
set showmatch                     " highlight matching[{()}]
set tabstop = 4                     " (max) width of an actual tab character
set softtabstop = 0                 " number of spaces in tab when editing
set noexpandtab                   " tabs (in insert mode) insert spaces not tab chars
set shiftwidth = 4 				  " size of an indent
set smarttab 					  " tab key (in insert mode) insert spaces or tabs to go to the next indent
"set smartindent
set autoindent                     " Indent at the same level of the previous line
filetype indent on      		   " load filetype-specific indent files
set wrap                		   " Always wrap long lines
set linebreak           		   " Prevents words to be split across lines
set list 						   " Turns on option to highlight specific chars below
":set list lcs=tab:\|\ " (here is a space)
set listchars = tab: ▸, trail: · 	   " was: set listchars = tab: ▸, eol: ¬
highlight LineNr term = bold cterm = NONE ctermfg = DarkGrey ctermbg = NONE gui = NONE guifg = DarkGrey guibg = NONE
highlight ColorColumn ctermbg = black         " Outline the character at column 81
call matchadd('ColorColumn', '\%81v', 100)  " with a different color(altering on col > 80)
autocmd FileType * setlocal formatoptions -= c formatoptions -= r formatoptions -= o " No auto commenting on newline

" Change cursor shape between insert and normal mode in iTerm2.app
if $TERM_PROGRAM= ~ "iTerm"
    let & t_SI= "\<Esc>]50;CursorShape=1\x7" " Vertical bar in insert mode
    let & t_EI= "\<Esc>]50;CursorShape=0\x7" " Block in normal mode
endif


autocmd BufWritePre * %s /\s\+$//e
" Automatically deletes all trailing whitespace on save.

autocmd BufNewFile, BufRead * .md  set filetype = markdown
"autocmd BufNewFile, BufRead * .txt set filetype = markdown
" Call function WP() if markdown file
autocmd Filetype markdown, mkd silent exec "!iterm_profile Editing2" | call WP()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Word Processing ad-hoc settings and remappings (function)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
	setlocal spell
	set thesaurus += ~/.vim/words.txt
	set complete += s

	noremap j gj
	noremap k gk
	noremap 0 g0
	noremap $ g$
	noremap A g$a
	noremap I g0i
	" move the cursor by line ** on screen ** (not on file)

	nnoremap < leader > s z =
	" Spell checking - suggest replacement

	nnoremap < leader > a: silent % s /\([aeiouAEIOU]\)'/\=tr(submatch(1), 'aeiouAEIOU', 'àèìòùÀÈÌÒÙ')/ge <Bar> %s/ pò/ po'/ge < Bar > %s / sè / sé/ge < Bar > s/chè/ché/ge < Bar > %s/trè/tré/ge < Bar > %s/nè/né/ge < Bar > %s/Nè/Né/ge < CR > <CR >
	"nnoremap < leader > a: % s /\([aeiouAEIOU]\)'/\=tr(submatch(1), 'aeiouAEIOU', 'àèìòùÀÈÌÒÙ')/g < CR >
	" Replace a', e', i', ... by proper Italian accented letters(handles exceptions) - ----
	" http://www.treccani.it/enciclopedia/acuto-o-grave-accento_ % 28La-grammatica-italiana % 29 /

	let b:delimitMate_autoclose=0


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"= > Mappings for Greek and Math (unicode) charatcters
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
inoremap < C-v > G Γ
inoremap < C-v > D Δ
inoremap < C-v > T Θ
inoremap < C-v > L Λ
inoremap < C-v > X Ξ
inoremap < C-v > P Π
inoremap < C-v > S Σ
inoremap < C-v > F Φ
inoremap < C-v > P Ψ
inoremap < C-v > O Ω

inoremap < C-v > a α
inoremap < C-v > b β
inoremap < C-v > g γ
inoremap < C-v > d δ
inoremap < C-v > e ε
inoremap < C-v > z ζ
inoremap < C-v > e η
inoremap < C-v > t θ
inoremap < C-v > i ι
inoremap < C-v > k κ
inoremap < C-v > l λ
inoremap < C-v > m μ
inoremap < C-v > x ξ
inoremap < C-v > p π
inoremap < C-v > r ρ
inoremap < C-v > s σ
inoremap < C-v > t τ
inoremap < C-v > p ψ
inoremap < C-v > o ω
inoremap < C-v > f ϕ
inoremap < C-v > n ν

inoremap < C-v > ll →
inoremap < C-v > hh ⇌
inoremap < C-v > kk ↑
inoremap < C-v > jj ↓
inoremap < C-v >= ∝
inoremap < C-v > ~ ≈
inoremap < C-v > != ≠
inoremap < C-v >>= ≥
inoremap < C-v > <= ≤
inoremap < C-v > 0  °
inoremap < C-v > *  •
inoremap < C-v > co ⌘

" =============================================================================
" Funkcje pomocnicze
" =============================================================================
" Interaktywna pomoc ze skrótami klawiszowymi (FZF)
function! FZFKeyMappings()
    let l:mappings = [
        \ '📁 NerdTree: Space+n → Otwórz/zamknij NerdTree',
        \ '📁 NerdTree: Space+f → Znajdź aktualny plik w NerdTree',
        \ '📁 NerdTree: Space+e → Przejdź do NerdTree (focus)',
        \ '',
        \ '🚀 Okna: Space+← → Przejdź do okna po lewej',
        \ '🚀 Okna: Space+→ → Przejdź do okna po prawej',
        \ '🚀 Okna: Space+↑ → Przejdź do okna wyżej',
        \ '🚀 Okna: Space+↓ → Przejdź do okna niżej',
        \ '🚀 Okna: Ctrl+h/j/k/l → Przejdź między oknami (vim style)',
        \ '',
        \ '📄 Bufory: Space+Shift+← → Poprzedni bufor',
        \ '📄 Bufory: Space+Shift+→ → Następny bufor',
        \ '📄 Bufory: Space+[ → Poprzedni bufor',
        \ '📄 Bufory: Space+] → Następny bufor',
        \ '📄 Bufory: Tab → Następny bufor',
        \ '📄 Bufory: Shift+Tab → Poprzedni bufor',
        \ '📄 Bufory: Space+bd → Zamknij aktualny bufor',
        \ '',
        \ '💾 Plik: Space+w → Zapisz plik',
        \ '💾 Plik: Space+q → Wyjdź z bufora/okna (nie całego Vima)',
        \ '💾 Plik: Space+x → Zapisz i zamknij bufor/okno',
        \ '',
        \ '🔍 FZF: Space+o → Szybkie otwieranie plików',
        \ '🔍 FZF: Space+b → Lista buforów',
        \ '🔍 FZF: Space+/ → Wyszukaj w plikach (Ripgrep)',
        \ '🔍 Wyszukiwanie: Space+Space → Wyczyść podświetlenie',
        \ '',
        \ '📋 Kopiuj: Space+ya → Kopiuj cały plik',
        \ '📋 Wklej: Space+p → Wklej bez nadpisywania rejestru (visual)',
        \ '',
        \ '⚙️ Konfiguracja: Space+ev → Edytuj .vimrc',
        \ '⚙️ Konfiguracja: Space+sv → Przeładuj .vimrc',
        \ '',
        \ '🎨 Kolory: Space+cc → Włącz/wyłącz podświetlanie kolorów HEX',
        \ '',
        \ '❓ Pomoc: Space+? → Pokaż pomoc (ta lista)',
        \ '',
        \ '📝 Vim: i → Tryb wstawiania',
        \ '📝 Vim: v → Tryb wizualny',
        \ '📝 Vim: : → Tryb komend',
        \ '📝 Vim: Esc → Powrót do trybu normalnego',
        \ '📝 Vim: u → Cofnij (undo)',
        \ '📝 Vim: Ctrl+r → Ponów (redo)',
        \ '📝 Vim: dd → Usuń linię',
        \ '📝 Vim: yy → Kopiuj linię',
        \ '📝 Vim: p → Wklej'
    \ ]
    call fzf#run(fzf#wrap({
        \ 'source': l:mappings,
        \ 'sink': function('s:execute_mapping'),
        \ 'options': [
        \   '--prompt', '🎯 Skróty klawiszowe > ',
        \   '--header', 'Wybierz skrót aby wykonać akcję lub ESC aby wyjść',
        \   '--preview-window', 'hidden',
        \   '--height', '60%'
        \ ]
    \ }))
endfunction
" Funkcja wykonująca akcje na podstawie wybranego skrótu
function! s:execute_mapping(mapping)
    let l:mapping = a:mapping

    " NerdTree
    if l:mapping =~ 'Space+n.*NerdTree'
        execute 'NERDTreeToggle'
    elseif l:mapping =~ 'Space+f.*Znajdź aktualny plik'
        execute 'NERDTreeFind'
    elseif l:mapping =~ 'Space+e.*focus'
        execute 'NERDTreeFocus'

    " Pliki
    "elseif l:mapping =~ 'Space+w.*Zapisz'
    "    execute 'write'
    "    echo 'Plik zapisany!'
    "elseif l:mapping =~ 'Space+q.*Wyjdź'
    "    execute 'quit'
    "elseif l:mapping =~ 'Space+x.*Zapisz i zamknij'
    "    execute 'wq'
    "    echo 'Plik zapisany i zamknięty!'

    " FZF
    elseif l:mapping =~ 'Space+o.*otwieranie plików'
        execute 'Files'
    elseif l:mapping =~ 'Space+b.*Lista buforów'
        execute 'Buffers'
    elseif l:mapping =~ 'Space+/.*Wyszukaj w plikach'
        execute 'Rg'
    elseif l:mapping =~ 'Space+Space.*Wyczyść'
        execute 'nohlsearch'
        echo 'Podświetlenie wyszukiwania wyczyszczone'

    " Bufory
    elseif l:mapping =~ 'Space+\[.*Poprzedni'
        execute 'bprevious'
    elseif l:mapping =~ 'Space+\].*Następny'
        execute 'bnext'
    elseif l:mapping =~ 'Tab.*Następny'
        execute 'bnext'
    elseif l:mapping =~ 'Shift+Tab.*Poprzedni'
        execute 'bprevious'
    elseif l:mapping =~ 'Space+bd.*Zamknij'
        execute 'bdelete'

    " Kopiowanie
    elseif l:mapping =~ 'Space+ya.*Kopiuj cały'
        execute 'normal! ggVGy'
        echo 'Cały plik skopiowany!'

    " Konfiguracja
    elseif l:mapping =~ 'Space+ev.*Edytuj .vimrc'
        execute 'e $MYVIMRC'
    elseif l:mapping =~ 'Space+sv.*Przeładuj .vimrc'
        execute 'source $MYVIMRC'
        echo '.vimrc przeładowany!'

    " Kolory
    elseif l:mapping =~ 'Space+cc.*kolory'
        execute 'call css_color#toggle()'

    " Pomoc
    elseif l:mapping =~ 'Space+?.*Pomoc'
        call FZFKeyMappings()

    " Tryby Vim
    elseif l:mapping =~ 'i.*wstawiania'
        execute 'startinsert'
    elseif l:mapping =~ 'v.*wizualny'
        execute 'normal! v'
    elseif l:mapping =~ ':.*komend'
        execute 'normal! :'

    " Podstawowe operacje
    elseif l:mapping =~ 'u.*Cofnij'
        execute 'normal! u'
        echo 'Cofnięto'
    elseif l:mapping =~ 'Ctrl+r.*Ponów'
        execute 'normal! \<C-r>'
        echo 'Powtórzono'
    elseif l:mapping =~ 'dd.*Usuń linię'
        execute 'normal! dd'
        echo 'Linia usunięta'
    elseif l:mapping =~ 'yy.*Kopiuj linię'
        execute 'normal! yy'
        echo 'Linia skopiowana'
    elseif l:mapping =~ 'p.*Wklej'
        execute 'normal! p'
        echo 'Wklejono'
    else
        echo 'Instrukcja: ' . l:mapping
    endif
endfunction
" =============================================================================
" Podstawowa konfiguracja Vim
" =============================================================================
" Wyłącz kompatybilność z vi
set nocompatible
" =============================================================================
" Plugin Manager (vim-plug) - Automatyczna instalacja
" =============================================================================
" Sprawdź czy vim-plug jest zainstalowany
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')
" NerdTree - eksplorator plików
Plug 'preservim/nerdtree'
" Catppuccin Mocha theme
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
" Lepsze podświetlanie dla popularnych języków (zamiast vim-polyglot)
Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'rust-lang/rust.vim'
Plug 'vim-python/python-syntax'
" Podświetlanie kolorów HEX/RGB w kodzie
Plug 'ap/vim-css-color'
" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Ikony dla NerdTree
Plug 'ryanoasis/vim-devicons'
" Automatyczne zamykanie nawiasów
Plug 'jiangmiao/auto-pairs'
" Zaawansowane wyszukiwanie
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()
" Automatycznie zainstaluj brakujące pluginy przy starcie Vim
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif
" =============================================================================
" Podstawowe ustawienia
" =============================================================================
" Włącz numerowanie linii
set number
set relativenumber
" Włącz obsługę myszy
set mouse=a
" Kodowanie
set encoding=utf-8
" Podświetlanie składni
syntax enable
" Ustawienia dla pluginów podświetlania składni
let g:python_highlight_all = 1
let g:rust_fold = 1
" Konfiguracja vim-css-color
" Włącz podświetlanie kolorów we wszystkich plikach (nie tylko CSS)
let g:css_color_enabled = 1
" Formatty kolorów do rozpoznania
let g:css_color_terms = ['#\w\{6}', '#\w\{3}', 'rgb(', 'rgba(', 'hsl(', 'hsla(']
" Kolorowy schemat
set termguicolors
colorscheme catppuccin_mocha
" Podświetl aktualną linię
set cursorline
" Pokaż dopasowania podczas wpisywania
set showmatch
" Podświetl wyszukiwane frazy
set hlsearch
set incsearch
" Ignoruj wielkość liter podczas wyszukiwania (chyba że użyjesz wielkich)
set ignorecase
set smartcase
" =============================================================================
" Wcięcia i tabulatory
" =============================================================================
" Użyj spacji zamiast tabulatorów
set expandtab
" Szerokość tabulatora
set tabstop=4
set shiftwidth=4
set softtabstop=4
" Automatyczne wcięcia
set autoindent
set smartindent
" =============================================================================
" Schowek systemowy
" =============================================================================
" Kopiowanie do schowka systemowego
set clipboard=unnamedplus
" Dla macOS (jeśli używasz)
" set clipboard=unnamed
" =============================================================================
" Ustawienia plików
" =============================================================================
" Automatyczne przeładowywanie plików zmienionych na zewnątrz
set autoread
" Nie twórz plików backup
set nobackup
set nowritebackup
set noswapfile
" Pokaż niewidoczne znaki
set list
set listchars=tab:▸\ ,eol:¬,trail:⋅,extends:❯,precedes:❮
" =============================================================================
" Interface
" =============================================================================
" Pokaż status line zawsze
set laststatus=2
" Pokaż pozycję kursora
set ruler
" Pokaż komendy
set showcmd
" Linie kontekstu przy scrollowaniu
set scrolloff=8
set sidescrolloff=8
" Podział okien
set splitbelow
set splitright
" Szerokość kolumny
set textwidth=80
set colorcolumn=81
" =============================================================================
" NerdTree konfiguracja
" =============================================================================
" Automatycznie otwórz NerdTree
autocmd VimEnter * NERDTree | wincmd p
" Zamknij Vim jeśli zostało tylko NerdTree
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" Pokaż ukryte pliki
let NERDTreeShowHidden=1
" Ignoruj określone pliki
let NERDTreeIgnore=['\~$', '\.pyc$', '\.swp$', '\.git$', '\.DS_Store$']
" Szerokość NerdTree
let NERDTreeWinSize=30
" =============================================================================
" Airline konfiguracja
" =============================================================================
" Motyw dla airline
let g:airline_theme='catppuccin_mocha'
" Włącz powerline fonts
let g:airline_powerline_fonts=1
" Pokaż bufory jako tabulatory
let g:airline#extensions#tabline#enabled=1
" =============================================================================
" Skróty klawiszowe
" =============================================================================
" Leader key
let mapleader=" "
" NerdTree toggle i fokus
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>
" Szybkie przejście do NerdTree i z powrotem
nnoremap <leader>e :NERDTreeFocus<CR>
" Szybkie zapisywanie i zamykanie
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :wq<CR>
" Nawigacja między buforami
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>
" Czyszczenie podświetlenia wyszukiwania
nnoremap <leader><space> :nohlsearch<CR>
" Szybkie kopiowanie całego pliku
nnoremap <leader>ya ggVGy
" Wklejanie bez nadpisywania rejestru
vnoremap <leader>p "_dP
" Szybka edycja .vimrc
nnoremap <leader>ev :e $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>
" FZF wyszukiwanie plików
nnoremap <leader>o :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>/ :Rg<CR>
" Przełączanie podświetlania kolorów
nnoremap <leader>cc :call css_color#toggle()<CR>
" Pomoc - pokaż wszystkie skróty klawiszowe (FZF)
nnoremap <leader>? :call FZFKeyMappings()<CR>
" Nawigacja okna (Ctrl + hjkl)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" Nawigacja okna (Space + strzałki)
nnoremap <leader><Left> <C-w>h
nnoremap <leader><Down> <C-w>j
nnoremap <leader><Up> <C-w>k
nnoremap <leader><Right> <C-w>l
" Nawigacja między buforami (Space + Shift + strzałki)
nnoremap <leader><S-Left> :bprevious<CR>
nnoremap <leader><S-Right> :bnext<CR>
" Alternatywne nawigacje buforów (Space + [ ] dla wygody)
nnoremap <leader>[ :bprevious<CR>
nnoremap <leader>] :bnext<CR>
" =============================================================================
" Automatyczne komendy
" =============================================================================
" Przywróć pozycję kursora przy otwieraniu pliku
augroup restore_cursor
    autocmd!
    autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif
augroup END
" Automatycznie usuń białe znaki na końcu linii przy zapisie
augroup remove_trailing_whitespace
    autocmd!
    autocmd BufWritePre * %s/\s\+$//e
augroup END
" Podświetl linię tylko w aktywnym oknie
augroup cursor_line
    autocmd!
    autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
augroup END

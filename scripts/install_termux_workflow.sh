#!/bin/bash -
#===============================================================================
#
#          FILE: install_termux_workflow.sh
#
#         USAGE: ./install_termux_workflow.sh
#
#   DESCRIPTION: TERMUX EMBEDDED & ROBOTICS WORKFLOW INSTALLER
#
#       OPTIONS: ---
#  REQUIREMENTS: Hardened, Native Tooling (No-AI/No-Glibc)
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Oleg Sokolov (Al`Sapsan), 
#  ORGANIZATION: al-sapsan@mail.ru
#       CREATED: 18.01.2026 17:40:58
#      REVISION:  1.3
#===============================================================================

set -e # Exit immediately if a command exits with a non-zero status

# Colors for logging
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[SETUP]${NC} $1"; }
success() { echo -e "${GREEN}[DONE]${NC} $1"; }
warn() { echo -e "${RED}[ATTENTION]${NC} $1"; }

log "Starting Termux Environment Setup..."

# ==============================================================================
# 1. SYSTEM & PACKAGE INSTALLATION
# ==============================================================================
log "Updating repositories..."
pkg update -y && pkg upgrade -y

log "Installing Core Packages..."
# Combined list from all 3 configs
PACKAGES=(
    zsh git wget curl unzip tar
    neovim vim
    build-essential clang lldb cmake ninja
    python nodejs
    ripgrep fd bat eza zoxide fzf
    termux-api
    silversearcher-ag universal-ctags lazygit shellcheck
)

pkg install -y "${PACKAGES[@]}"

log "Installing Python dependencies..."
pip install --upgrade pynvim black flake8

log "Installing Node.js dependencies (for Vim CoC)..."
npm install -g pyright bash-language-server

log "Installing Yazi (File Manager) via TUR..."
pkg install -y tur-repo
pkg update -y
pkg install -y yazi ffmpegthumbnailer

success "System dependencies installed."

# ==============================================================================
# 2. ZSH CONFIGURATION
# ==============================================================================
log "Configuring Zsh..."

# Install Oh My Zsh (Unattended)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

# Install Plugins
PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
[ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR/zsh-autosuggestions"
[ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR/zsh-syntax-highlighting"

# Write .zshrc
log "Writing ~/.zshrc..."
cat > "$HOME/.zshrc" <<'EOF'
# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH="$HOME/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
export EDITOR='nvim'
export VISUAL='nvim'
export CMAKE_EXPORT_COMPILE_COMMANDS=1
export BAT_THEME="ansi"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# P10k Config
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)
POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Aliases
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lh --icons --git'
    alias la='eza -lah --icons --git'
    alias tree='eza --tree --icons'
else
    alias ll='ls -lh'
    alias la='ls -lah'
fi

alias cl='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias nv='nvim'
alias nvdir='cd ~/.config/nvim/lua/'
alias v='vim'
alias zconf='v ~/.zshrc'
alias zreload='source ~/.zshrc'
alias gs='git status'
alias ga='git add'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias lg='lazygit'
alias gpp='clang++ -std=c++20 -Wall -Wextra -Wpedantic'
alias cmdbg='cmake -S . -B build/Debug -G Ninja -DCMAKE_BUILD_TYPE=Debug && cmake --build build/Debug'
alias cmrel='cmake -S . -B build/Release -G Ninja -DCMAKE_BUILD_TYPE=Release && cmake --build build/Release'
alias bcl='rm -rf build'

# Zoxide
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
    alias zi='z -i'
fi

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --bind 'ctrl-/:toggle-preview'"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Yazi Wrapper
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# FZF + Yazi Launcher
fy() {
    local dir
    dir=$(fd --type d --hidden --exclude .git | fzf +m --preview 'tree -C {} | head -20') && y "$dir"
}

# Python Venv Helper
pyenv() {
    if [[ "$1" == "create" ]]; then python -m venv venv; echo "Created venv."; fi
    if [[ -f "venv/bin/activate" ]]; then source venv/bin/activate; else echo "No venv found."; fi
}

bindkey -v
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then echo -ne "\e[5 q"; else echo -ne "\e[6 q"; fi
}
zle -N zle-keymap-select
echo -ne "\e[6 q"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

success "Zsh configured."

# ==============================================================================
# 3. VIM CONFIGURATION
# ==============================================================================
log "Configuring Vim..."

# Install Vim-Plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Write .vimrc
log "Writing ~/.vimrc..."
cat > "$HOME/.vimrc" <<'EOF'
filetype off
call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons' 
Plug 'morhetz/gruvbox' 
Plug 'kien/rainbow_parentheses.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'voldikss/vim-floaterm'
Plug 'preservim/tagbar'
Plug 'jeetsukumaran/vim-pythonsense' 
Plug 'psf/black' 
Plug 'vim-test/vim-test'
Plug 'dense-analysis/ale'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'WolfgangMehner/bash-support'
Plug 'koalaman/shellcheck'
call plug#end()

let mapleader = " "
let maplocalleader = " "
set encoding=utf8
set ffs=unix,dos
set expandtab smarttab tabstop=4 softtabstop=4 shiftwidth=4
set number relativenumber ruler signcolumn=yes
set updatetime=300 
set cmdwinheight=10
set laststatus=2
set scrolloff=5
set ignorecase smartcase hlsearch incsearch
set foldmethod=indent foldlevel=99

if (has("termguicolors"))
    set termguicolors
endif
let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox
set background=dark
let g:airline_theme = 'gruvbox'

noremap <C-q> :wq<CR>
inoremap <C-q> <Esc>:wq<CR>
nnoremap <leader>t :terminal<CR>
inoremap jk <Esc>
vnoremap jk <C-c>
tnoremap jk <C-\><C-n>
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>
vnoremap <C-s> <Esc>:w<CR>

" Termux Clipboard
nnoremap <silent> <C-z> :%w !termux-clipboard-set<CR><CR>
vnoremap <leader>y y:call system("termux-clipboard-set", @")<CR>
nnoremap <leader>p :let @"=system("termux-clipboard-get")<CR>p

let &t_SI = "\e[6 q"
let &t_SR = "\e[4 q"
let &t_EI = "\e[2 q"

autocmd VimEnter * NERDTree | wincmd p
autocmd FileType c,cpp,python,sh TagbarOpen
autocmd CursorHold * if winnr('$') == 1 && getbufvar('%', '&filetype') == 'nerdtree' | quit | endif

let g:AutoPairsShortcutToggle = '<M-p>'
augroup PythonAutoPairs
    autocmd!
    autocmd FileType python let b:AutoPairs = {'(':')', '[':']', '{':'}', "'":"'",'"':'"', '`':'`'}
augroup END

nmap <silent> <leader>rn :TestNearest<CR>
nmap <silent> <leader>rf :TestFile<CR>
nmap <silent> <leader>rs :TestSuite<CR>
nmap <silent> <leader>rl :TestLast<CR>
let g:test#strategy = 'vimterminal'

let g:gitgutter_enabled = 1
nnoremap <silent> <leader>gg :FloatermNew --height=0.9 --width=0.9 --name=lazygit lazygit<CR>
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gl :Git pull<CR>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gd :Gdiffsplit<CR>

let g:coc_global_extensions = ['coc-pyright', 'coc-sh', 'coc-snippets', 'coc-prettier', 'coc-json']
let g:ale_disable_lsp = 1
let g:ale_linters = {'python': ['flake8'], 'sh': ['shellcheck']}

inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#next(1) : CheckBackspace() ? "\<Tab>" : coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> K :call CocActionAsync('doHover')<CR>

nnoremap <leader>e :NERDTreeToggle<CR> 
nnoremap <leader>o :TagbarToggle<CR>
let g:fzf_vim = {}
let g:fzf_vim.buffers_jump = 1
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fg :Rg<CR>

let g:rbpt_max = 6
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]
autocmd VimEnter * RainbowParenthesesToggle
autocmd VimEnter * redraw!
EOF

success "Vim configured."

# ==============================================================================
# 4. NEOVIM CONFIGURATION
# ==============================================================================
log "Configuring Neovim..."

NVIM_DIR="$HOME/.config/nvim"
log "Cleaning old Neovim config..."
rm -rf "$NVIM_DIR"
mkdir -p "$NVIM_DIR/lua/core"
mkdir -p "$NVIM_DIR/lua/plugins"
mkdir -p "$NVIM_DIR/lua/config"

# init.lua
cat > "$NVIM_DIR/init.lua" <<'EOF'
require("core.options")
require("core.keymaps")
require("plugins.init")
EOF

# core/options.lua
cat > "$NVIM_DIR/lua/core/options.lua" <<'EOF'
local o = vim.opt
o.number = true
o.relativenumber = true
o.termguicolors = true
o.signcolumn = "yes"
o.cursorline = true
o.updatetime = 250
o.timeoutlen = 300
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true
EOF

# core/keymaps.lua
cat > "$NVIM_DIR/lua/core/keymaps.lua" <<'EOF'
vim.g.mapleader = " "
local map = vim.keymap.set

map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save File" })
map({ "n", "i", "v" }, "<C-q>", "<cmd>wq<CR>", { desc = "Save and Quit" })

map("i", "jk", "<Esc>", { silent = true })
map("n", "<Esc>", ":nohlsearch<CR>", { silent = true })

map("n", "<leader>h", "<C-w>h", { desc = "Window Left" })
map("n", "<leader>j", "<C-w>j", { desc = "Window Down" })
map("n", "<leader>k", "<C-w>k", { desc = "Window Up" })
map("n", "<leader>l", "<C-w>l", { desc = "Window Right" })

map("n", "<leader>cg", "<cmd>CMakeGenerate<CR>", { desc = "CMake Generate" })
map("n", "<leader>cb", "<cmd>CMakeBuild<CR>", { desc = "CMake Build" })
map("n", "<leader>ct", "<cmd>CMakeSelectBuildType<CR>", { desc = "Select Build Type" })
map("n", "<leader>cs", "<cmd>CMakeSelectBuildTarget<CR>", { desc = "Select Build Target" })
map("n", "<leader>cc", "<cmd>CMakeClean<CR>", { desc = "CMake Clean" })

map("n", "<leader>t", function() Snacks.terminal() end, { desc = "Toggle Float Term" })
map("n", "<leader>th", "<cmd>botright 15split | terminal<CR>", { desc = "Term Bottom" })
map("n", "<leader>tt", "<cmd>topleft 15split | terminal<CR>", { desc = "Term Top" })

map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
map("n", "<leader>o", "<cmd>AerialToggle!<CR>", { desc = "Toggle Outline" })
EOF

# plugins/init.lua
cat > "$NVIM_DIR/lua/plugins/init.lua" <<'EOF'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "nvim-lua/plenary.nvim" },
  { "folke/tokyonight.nvim", lazy = true },
  { 
    "rebelot/kanagawa.nvim", 
    priority = 1000,
    config = function() vim.cmd("colorscheme kanagawa") end
  },
  { 
    "nvim-tree/nvim-tree.lua", 
    config = true,
    keys = { { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Explorer" } }
  },
  { "nvim-lualine/lualine.nvim", config = true },
  { 
    "nvim-treesitter/nvim-treesitter", 
    build = ":TSUpdate",
    config = function() require("config.treesitter") end 
  },
  { "neovim/nvim-lspconfig" },
  { "p00f/clangd_extensions.nvim" }, 
  { 
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "L3MON4D3/LuaSnip" },
    config = function() require("config.cmp") end
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function() require("config.autopairs") end,
  },
  { "HiPhish/rainbow-delimiters.nvim", event = "BufReadPost" },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    config = function() require("config.formatting") end
  },
  {
    "stevearc/aerial.nvim",
    config = function()
        require("aerial").setup({
            layout = { max_width = { 40, 0.4 }, width = 35, min_width = 25, default_direction = "prefer_right" },
            show_guides = true, 
            filter_kind = { "Class", "Constructor", "Enum", "Function", "Interface", "Module", "Method", "Struct" },
        })
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  },
  {
    "Civitasv/cmake-tools.nvim",
    config = function() require("config.cmake") end
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
    config = function() require("config.dap") end
  },
  { "folke/snacks.nvim", version = ">=2.24.0" },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    event = "BufReadPost",
  },
  { 
    "nvim-telescope/telescope.nvim", 
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>" },
      { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Find TODOs" }, 
    }
  }
})
EOF

# config/lsp.lua
cat > "$NVIM_DIR/lua/config/lsp.lua" <<'EOF'
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.clangd.setup({
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
    "--query-driver=/data/data/com.termux/files/usr/bin/clang*,/data/data/com.termux/files/usr/bin/gcc*",
  },
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  end
})
EOF

# config/cmp.lua
cat > "$NVIM_DIR/lua/config/cmp.lua" <<'EOF'
local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
    mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "luasnip" }, { name = "buffer" }, { name = "path" } })
})
EOF

# config/autopairs.lua
cat > "$NVIM_DIR/lua/config/autopairs.lua" <<'EOF'
local status_ok, npairs = pcall(require, "nvim-autopairs")
if not status_ok then return end
npairs.setup({ check_ts = true })
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp_status_ok, cmp = pcall(require, "cmp")
if cmp_status_ok then cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done()) end
EOF

# config/formatting.lua
cat > "$NVIM_DIR/lua/config/formatting.lua" <<'EOF'
require("conform").setup({
  formatters_by_ft = {
    c = { "clang-format" },
    cpp = { "clang-format" },
    cmake = { "cmake_format" },
    lua = { "stylua" },
    python = { "black" },
  },
  format_on_save = { timeout_ms = 500, lsp_fallback = true },
})
EOF

# config/dap.lua
cat > "$NVIM_DIR/lua/config/dap.lua" <<'EOF'
local dap = require("dap")
local ui_ok, dapui = pcall(require, "dapui")
if not ui_ok then return end
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

dap.adapters.lldb = { type = 'executable', command = 'lldb-dap', name = 'lldb' }
dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file') end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
  },
}
dap.configurations.c = dap.configurations.cpp
EOF

# config/cmake.lua
cat > "$NVIM_DIR/lua/config/cmake.lua" <<'EOF'
require("cmake-tools").setup({
  cmake_command = "cmake",
  cmake_build_directory = "build/${variant:buildType}",
  cmake_generator = "Ninja", 
  cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
  cmake_executor = { name = "quickfix" },
})
EOF

# config/treesitter.lua
cat > "$NVIM_DIR/lua/config/treesitter.lua" <<'EOF'
local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then return end
local install_ok, install = pcall(require, "nvim-treesitter.install")
if install_ok then install.compilers = { "clang" } end
configs.setup({
  ensure_installed = { "c", "cpp", "lua", "bash", "python", "cmake", "make", "vim", "vimdoc" },
  sync_install = false, 
  auto_install = false, 
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  indent = { enable = true },
})
EOF

success "Neovim configured."

# ==============================================================================
# 5. FINALIZATION
# ==============================================================================
log "Changing default shell to Zsh..."
chsh -s zsh

echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}   SETUP COMPLETE! RESTART TERMUX NOW.            ${NC}"
echo -e "${GREEN}==================================================${NC}"
warn "1. Restart Termux."
warn "2. Open Vim and run :PlugInstall"
warn "3. Open Neovim - plugins will install automatically."
warn "4. Run 'p10k configure' to set up your prompt."

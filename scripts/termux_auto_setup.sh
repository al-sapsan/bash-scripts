#!/bin/bash -
#===============================================================================
#
#          FILE: termux_auto_setup.sh
#
#         USAGE: ./termux_auto_setup.sh
#
#   DESCRIPTION:TERMUX EMBEDDED & ROBOTICS WORKFLOW INSTALLER
#
#        Target: Termux (Android)
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Oleg Sokolov (Al`Sapsan), 
#  ORGANIZATION: al.sapsan@mail.ru
#       CREATED: 16.01.2026 19:34:53
#      REVISION:  0.1
#===============================================================================

set -e # Exit immediately if a command exits with a non-zero status

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[SETUP]${NC} $1"; }
success() { echo -e "${GREEN}[DONE]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

log "Starting Termux Hardening Process..."

# ==============================================================================
# 1. SYSTEM & PACKAGE INSTALLATION
# ==============================================================================
log "Updating repositories and installing core packages..."
pkg update -y && pkg upgrade -y

# Core Tools
PACKAGES=(
    zsh git wget curl unzip tar
    neovim vim
    build-essential clang lldb cmake ninja
    python
    ripgrep fd bat eza zoxide fzf
    termux-api
    gcompat # Required for Codeium AI
)

pkg install -y "${PACKAGES[@]}"

# Python Provider for Neovim
log "Installing Python provider for Neovim..."
pip install --upgrade pynvim

# Yazi (File Manager) via TUR
log "Installing Yazi..."
pkg install -y tur-repo
pkg update -y
pkg install -y yazi ffmpegthumbnailer

success "Packages installed."

# ==============================================================================
# 2. ZSH & POWERLEVEL10K SETUP
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
log "Writing .zshrc..."
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
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time time)
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Aliases
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lh --icons --git'
    alias la='eza -lah --icons --git'
else
    alias ll='ls -lh'
    alias la='ls -lah'
fi

alias ..='cd ..'
alias ~='cd ~'
alias nv='nvim'
alias v='vim'
alias zconf='v ~/.zshrc'
alias zreload='source ~/.zshrc'
alias gs='git status'
alias lg='lazygit'
alias gpp='clang++ -std=c++20 -Wall -Wextra'
alias cmdbg='cmake -S . -B build/Debug -G Ninja -DCMAKE_BUILD_TYPE=Debug && cmake --build build/Debug'
alias bcl='rm -rf build'

# Zoxide
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
    alias zi='z -i'
fi

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
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

# Python Venv Helper
pyenv() {
    if [[ "$1" == "create" ]]; then python -m venv venv; fi
    if [[ -f "venv/bin/activate" ]]; then source venv/bin/activate; else echo "No venv found."; fi
}

bindkey -v
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

success "Zsh configured."

# ==============================================================================
# 3. VIM SETUP (Python/Bash)
# ==============================================================================
log "Configuring Vim..."

# Install Vim-Plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Write .vimrc
cat > "$HOME/.vimrc" <<'EOF'
filetype off
call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons' 
Plug 'morhetz/gruvbox' 
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'Exafunction/codeium.vim', { 'branch': 'main' }
Plug 'tpope/vim-fugitive'
Plug 'voldikss/vim-floaterm'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
call plug#end()

let mapleader = "\\"
set encoding=utf8
set expandtab smarttab tabstop=4 shiftwidth=4
set number relativenumber
set termguicolors
colorscheme gruvbox
set background=dark

noremap <C-q> :wq<CR>
inoremap <C-q> <Esc>:wq<CR>
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>

" Termux Clipboard
nnoremap <silent> <C-z> :%w !termux-clipboard-set<CR><CR>
vnoremap <leader>y y:call system("termux-clipboard-set", @")<CR>
nnoremap <leader>p :let @"=system("termux-clipboard-get")<CR>p

" Mappings
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :Rg<CR>
nnoremap <silent> <leader>gg :FloatermNew --height=0.9 --width=0.9 --name=lazygit lazygit<CR>

" Codeium
let g:codeium_disable_bindings = 1
inoremap <script><silent><nowait><expr> <C-a> codeium#Accept()
inoremap <C-x> <Cmd>call codeium#Chat()<CR>

" CoC
inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
nmap <silent> gd <Plug>(coc-definition)
EOF

success "Vim configured."

# ==============================================================================
# 4. NEOVIM SETUP (C/C++)
# ==============================================================================
log "Configuring Neovim..."

NVIM_DIR="$HOME/.config/nvim"
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
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = false
o.signcolumn = "yes"
o.updatetime = 200
o.clipboard = "unnamedplus"
EOF

# core/keymaps.lua
cat > "$NVIM_DIR/lua/core/keymaps.lua" <<'EOF'
vim.g.mapleader = "\\"
local map = vim.keymap.set
map("n", "<C-s>", ":w<CR>", { silent = true })
map("i", "jk", "<Esc>", { silent = true })
map("n", "<leader>h", "<C-w>h")
map("n", "<leader>j", "<C-w>j")
map("n", "<leader>k", "<C-w>k")
map("n", "<leader>l", "<C-w>l")
map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
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
  { "folke/tokyonight.nvim" },
  { "rebelot/kanagawa.nvim" },
  { "nvim-tree/nvim-tree.lua", config = true },
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
    dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip" },
    config = function() require("config.cmp") end
  },
  {
    "monkoose/neocodeium",
    event = "InsertEnter",
    config = function() require("config.neocodeium") end
  },
  {
    "Civitasv/cmake-tools.nvim",
    config = function() require("config.cmake") end
  },
  {
    "mfussenegger/nvim-dap",
    config = function() require("config.dap") end
  },
  { "rcarriga/nvim-dap-ui", dependencies = {"nvim-neotest/nvim-nio"}, config = true },
  { "folke/snacks.nvim", version = ">=2.24.0" },
  { 
    "nvim-telescope/telescope.nvim", 
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>" },
    }
  }
})
EOF

# config/lsp.lua (NATIVE CLANGD)
cat > "$NVIM_DIR/lua/config/lsp.lua" <<'EOF'
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.clangd.setup({
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--query-driver=/data/data/com.termux/files/usr/bin/clang*,/data/data/com.termux/files/usr/bin/gcc*",
  },
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  end
})
EOF

# config/dap.lua (NATIVE LLDB)
cat > "$NVIM_DIR/lua/config/dap.lua" <<'EOF'
local dap = require("dap")
local dapui = require("dapui")
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end

dap.adapters.lldb = {
  type = 'executable',
  command = 'lldb-dap',
  name = 'lldb'
}
dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
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
})
EOF

# config/treesitter.lua
cat > "$NVIM_DIR/lua/config/treesitter.lua" <<'EOF'
require("nvim-treesitter.install").compilers = { "clang" }
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "cpp", "lua", "bash", "python", "cmake" },
  highlight = { enable = true },
})
EOF

# config/neocodeium.lua
cat > "$NVIM_DIR/lua/config/neocodeium.lua" <<'EOF'
local neocodeium = require("neocodeium")
neocodeium.setup({ manual = true, silent = true })
vim.keymap.set("i", "<C-a>", neocodeium.accept)
vim.keymap.set("i", "<C-s>", neocodeium.cycle_or_complete)
vim.keymap.set("n", "<leader>ai", "<cmd>NeoCodeium chat<CR>")
EOF

# config/cmp.lua
cat > "$NVIM_DIR/lua/config/cmp.lua" <<'EOF'
local cmp = require("cmp")
cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = { { name = "nvim_lsp" } }
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
echo -e "1. Restart Termux."
echo -e "2. Open Vim and run :PlugInstall"
echo -e "3. Open Neovim - plugins will install automatically."
echo -e "4. Run 'p10k configure' to set up your prompt."

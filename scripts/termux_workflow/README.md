## **Termux Workflow Installer**

### **📋 "Two Words" Description:**
**Mobile Development Environment**

### **🎯 Core Purpose:**
One-command setup for embedded/robotics development environment on Android Termux.

---

## **🚀 Quick Start**
```bash
# Download and run
curl -O https://your-repo/install_termux_workflow.sh
chmod +x install_termux_workflow.sh
./install_termux_workflow.sh
```

---

## **🔧 User Patterns**

### **Pattern 1: Fresh Termux Setup**
```
Open Termux → Run script → Wait 5-10 mins → Complete environment
```
**Result**: Full C/C++/Python toolchain with Neovim IDE and CLI tools.

### **Pattern 2: Embedded Development**
```bash
# After installation:
cd ~/projects
mkdir robot_firmware && cd robot_firmware
nvim main.cpp  # Full IDE with LSP, DAP, CMake
cmdbg         # CMake debug build
./build/Debug/app  # Run
```

### **Pattern 3: Mobile Code Review**
```bash
# Pull code and review on phone
git clone https://github.com/your/repo
cd repo
lg            # LazyGit for commits
nv            # Neovim for code review
./security-auditor.sh  # Audit libraries
```

---

## **🛠️ What Gets Installed**

### **Core Toolchain:**
```
┌───────────┬─────────────────────────────────────────┐
│ Category  │ Tools                                    │
├───────────┼─────────────────────────────────────────┤
│ Compilers │ clang, gcc, cmake, ninja                │
│ Editors   │ Neovim (LSP/DAP), Vim (CoC)             │
│ CLI       │ zsh+p10k, fzf, eza, bat, rg, fd, zoxide │
│ Git       │ lazygit, git                            │
│ File Mgr  │ Yazi with previews                      │
└───────────┴─────────────────────────────────────────┘
```

---

## **📁 Directory Structure After Install**
```
~/
├── .config/nvim/      # Lua Neovim config
├── .vim/              # Vim with CoC
├── .oh-my-zsh/        # Zsh + plugins
├── .local/share/nvim/ # Neovim plugins
└── projects/          # Your code here
```

---

## **🎮 Key Commands After Install**

### **Development:**
```bash
nv        # Neovim IDE
cmdbg     # CMake debug build
cmrel     # CMake release build
lg        # LazyGit GUI
y         # Yazi file manager
fy        # FZF → Yazi file picker
```

### **Navigation:**
```bash
z <dir>   # Smart directory jump
<leader>e # File explorer (Neovim)
<leader>ff# Fuzzy find files
<leader>gg# LazyGit float
<leader>t # Terminal float
```

### **Code Actions:**
```bash
gd        # Go to definition (LSP)
gr        # Find references
<leader>rn# Rename symbol
<leader>ca# Code actions
```

---

## **⚡ Pro Tips**

### **For Embedded:**
```bash
# Cross-compile setup
pkg install ndk-multilib
export CC=arm-linux-androideabi-clang
export CXX=arm-linux-androideabi-clang++
cmdbg
```

### **For Python:**
```bash
pyenv create  # Create virtual env
source venv/bin/activate
pip install -r requirements.txt
nv main.py    # Full Python LSP
```

### **For File Management:**
```bash
y             # Launch Yazi
Space         # Select files
t             # Toggle preview
/             # Search
q             # Quit and cd to selected
```

---

## **🔌 Neovim Plugin Highlights**

### **Essential:**
- **LSP**: clangd, pyright, bashls
- **DAP**: Native debugging with LLDB
- **CMake**: Integrated build system
- **Telescope**: Fuzzy finder
- **Treesitter**: Syntax highlighting

### **Workflow:**
```
1. Open file (nv file.cpp)
2. LSP loads automatically
3. <leader>cg → CMake configure
4. <leader>cb → Build
5. <leader>cs → Select target
6. F5 → Debug
```

---

## **🚨 Post-Install Steps**

```bash
# 1. Restart Termux (close and reopen)
# 2. Configure Powerlevel10k
p10k configure

# 3. Install Vim plugins
vim +PlugInstall +qall

# 4. Verify installation
clang --version
nvim --version
cmake --version
```

---

## **📊 Environment Features**

### **Development:**
- **Full C++20 support** with clang
- **CMake presets** for Debug/Release
- **LLDB debugging** with UI
- **Compile commands** for LSP
- **Clang-tidy integration**

### **Productivity:**
- **Instant prompt** (p10k)
- **Zoxide** (smart cd)
- **FZF** (unified search)
- **Bat** (syntax highlighting)
- **Eza** (modern ls)

---

## **🎯 Ideal Use Cases**

1. **Mobile Development**: Code anywhere on Android
2. **Embedded Prototyping**: C/C++ firmware development
3. **Code Reviews**: Pull and review code on-the-go
4. **Learning Environment**: Full toolchain for students
5. **Backup IDE**: When desktop isn't available

---

## **📚 Quick Reference Card**

```bash
# INSTALLATION
./install_termux_workflow.sh     # One command

# AFTER INSTALL
nv                              # Open Neovim
z projects                     # Jump to projects
cmdbg                          # Build debug
lg                             # Git GUI

# NEOVIM KEYS
<leader>e     # File explorer
<leader>ff    # Find files
<leader>gg    # LazyGit
<leader>t     # Terminal
gd           # Go to definition
F5           # Start debug

# ZSH ALIASES
gs, ga, gcm, gp   # Git shortcuts
cl                # Clear
.., ...          # Up directories
```

**Tagline**: *"Full IDE in your pocket"*

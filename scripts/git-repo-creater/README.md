
## **Git Repo Creator v2.0 – User Guide**

### **📋 "Two Words" Description:**

**Repo Bootstrap**

### **🎯 Core Purpose:**

Interactive Bash tool for creating, initializing, and optionally publishing Git repositories with standard project scaffolding on macOS and Linux.

---

## **🚀 Quick Start**

```bash
# 1. Make executable
chmod +x git-repo-creator.sh

# 2. Run interactive mode
./git-repo-creator.sh
```

---

## **🔧 User Patterns**

### **Pattern 1: Local Repository Only**

```bash
./git-repo-creator.sh
```

**Flow**:
Choose location → Enter repo name → Initialize Git → Optional README / .gitignore → Initial commit

**Use case**: Quick local project setup without GitHub.

---

### **Pattern 2: GitHub-Connected Repository**

```bash
./git-repo-creator.sh
```

**Flow**:
Select directory → Create repo folder → Initialize Git → Add remote (SSH/HTTPS) → Push to GitHub

**Use case**: Start a new project and publish it in one session.

---

### **Pattern 3: Project Scaffolding**

```bash
./git-repo-creator.sh
```

**Options**:

* Create `src/`, `tests/`, `docs/`
* Generate Python or Bash starter file
* Auto-stage generated files

**Use case**: Consistent project layout for scripts, tools, or libraries.

---

## **📂 Repository Location Logic**

### **Creation Modes**

* **Current directory** (`pwd`)
* **Custom path** (auto-created if missing)
* **Path-derived repo name** (optional)

### **Validation**

* Repository name must match:

```
[a-zA-Z0-9_.-]+
```

---

## **🧱 Generated Files (Optional)**

### **README.md**

* Project title
* Description
* Installation
* Usage placeholder
* License placeholder

### **.gitignore Templates**

* Python
* Node.js
* Java
* Go
* Rust
* Custom input

### **Starter Files**

* `src/main.py`
* `src/main.sh`

---

## **🔗 GitHub Integration**

### **Supported Protocols**

* **SSH**: `git@github.com:user/repo.git`
* **HTTPS**: `https://github.com/user/repo.git`

### **Workflow**

```
Local Init → Remote Add → Branch Rename → Push
```

* Default branch: `main`
* Detects existing `origin`
* Optional browser auto-open after push

---

## **📜 License Support**

```text
1) MIT
2) Apache 2.0
3) GPLv3
4) BSD 3-Clause
5) Custom
```

* Licenses fetched via `curl`
* Auto-staged for commit

---

## **🎮 Interactive Commands**

### **User Prompts**

* y / n confirmation
* Default values supported
* Safe exits on errors

### **Error Handling**

* `set -e` + `set -u`
* Line-number error reporting
* Command existence checks

---

## **⚡ Pro Tips**

### **Fast Local Project**

```bash
./git-repo-creator.sh
# Skip GitHub when prompted
```

### **SSH-First Workflow**

```bash
# Ensure SSH keys are configured
ssh -T git@github.com
```

### **Reusable for Scripts**

```bash
# Create multiple repos quickly
for p in tool1 tool2 tool3; do ./git-repo-creator.sh; done
```

---

## **🚨 Common Issues & Solutions**

| Issue             | Solution                         |
| ----------------- | -------------------------------- |
| Git not found     | Install git                      |
| Push fails        | Create repo on GitHub first      |
| Permission denied | Check SSH keys                   |
| Invalid repo name | Use only letters, numbers, `._-` |

---

## **📈 Ideal Use Cases**

1. Rapid project bootstrapping
2. Script & tooling repositories
3. Embedded / robotics utilities
4. Homelab & automation repos
5. Teaching Git fundamentals

---

## **📚 Quick Reference Card**

```bash
./git-repo-creator.sh   # Interactive mode

# Creates:
- Git repo
- Optional README.md
- Optional .gitignore
- Optional src/tests/docs
- Optional GitHub remote
```

**Tagline**: *“From zero to pushed in one run.”*

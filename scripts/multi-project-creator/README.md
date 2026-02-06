## **Multi-Project Creator v3.0 – User Guide**

### **📋 "Two Words" Description:**

**Project Scaffold**

### **🎯 Core Purpose:**

Interactive multi-language project generator that creates structured, production-ready repositories for Bash, C, C++, Python, Rust, or generic projects.

---

## **🚀 Quick Start**

```bash
# 1. Make executable
chmod +x multi-project-creator.sh

# 2. Run interactive mode
./multi-project-creator.sh
```

---

## **🔧 User Patterns**

### **Pattern 1: Script / Tool Project**

```bash
./multi-project-creator.sh
# Select: Bash or Python
```

**Flow**:
Select language → Choose location → Name project → Generate structure → Start coding

**Use case**: CLI tools, automation scripts, DevOps utilities.

---

### **Pattern 2: Systems / Embedded Project**

```bash
./multi-project-creator.sh
# Select: C or C++
```

**Flow**:
Language → Folder → Validated project name → Full build system → Tests

**Includes**:

* Makefile
* CMake
* Tests
* Modular source layout

---

### **Pattern 3: Modern Application Project**

```bash
./multi-project-creator.sh
# Select: Python or Rust
```

**Use case**: Libraries, services, research tools, robotics software.

**Includes**:

* Packaging config
* Linting & formatting
* Test framework
* Entry points

---

## **📁 Supported Project Types**

| Option | Language | Highlights                                |
| ------ | -------- | ----------------------------------------- |
| 1      | Bash     | Modular scripts, logging, build packaging |
| 2      | C        | Makefile + CMake, tests, clean API        |
| 3      | C++      | Modern CMake, GoogleTest, namespaces      |
| 4      | Python   | `pyproject.toml`, pytest, black, mypy     |
| 5      | Rust     | Cargo-style naming (planned extension)    |
| 6      | Generic  | Minimal reusable skeleton                 |

---

## **📂 Directory Layout Examples**

### **Bash**

```
src/
 ├─ bin/
 ├─ lib/
 └─ utils/
tests/
examples/
config/
build.sh
```

### **C / C++**

```
include/
src/
 ├─ core/
 ├─ utils/
tests/
examples/
build/
Makefile
CMakeLists.txt
```

### **Python**

```
src/project_name/
 ├─ core/
 ├─ utils/
 ├─ models/
 └─ api/
tests/
docs/
pyproject.toml
setup.cfg
```

---

## **🧠 Naming Rules**

* Project name:

```
lowercase + numbers + dashes
```

✔ Valid: `robot-control`, `net-utils`
✖ Invalid: `MyProject`, `test_app`

Rust crates automatically convert dashes → underscores.

---

## **🧱 Generated Components**

### **Always**

* Validated project structure
* Language-specific boilerplate
* Ready-to-build layout

### **Language-Specific**

* **Bash**: logging, helpers, build archive
* **C**: error codes, API headers, tests
* **C++**: RAII design, exceptions, GoogleTest
* **Python**: packaging, linting, coverage

---

## **🎮 Interactive Experience**

### **Menus**

```
1️⃣ Bash
2️⃣ C
3️⃣ C++
4️⃣ Python
5️⃣ Rust
6️⃣ Generic
```

### **Features**

* Safe exits
* Colored output
* Auto-formatted names
* Error-checked execution (`set -e`, `set -u`)

---

## **⚡ Pro Tips**

### **Rapid Prototyping**

```bash
./multi-project-creator.sh
# Choose Python → start coding immediately
```

### **Embedded / Robotics**

```bash
./multi-project-creator.sh
# Choose C or C++
# Use generated Makefile + CMake
```

### **Teaching & Templates**

```bash
# Reusable project boilerplates
cp -r template-project new-project
```

---

## **🚨 Common Issues & Solutions**

| Issue                | Solution                  |
| -------------------- | ------------------------- |
| Invalid project name | Use lowercase + dashes    |
| gcc / g++ missing    | Install build tools       |
| Tests won’t build    | Disable via CMake options |
| Python deps missing  | Use virtual environment   |

---

## **📈 Ideal Use Cases**

1. Embedded & robotics software
2. CLI tools & automation
3. Teaching project structure
4. Research codebases
5. Consistent multi-language repos

---

## **📚 Quick Reference Card**

```bash
./multi-project-creator.sh

# Generates:
✔ Language-specific structure
✔ Build system
✔ Tests
✔ Best-practice layout
```

**Tagline**: *“One script. Any language. Clean start.”*

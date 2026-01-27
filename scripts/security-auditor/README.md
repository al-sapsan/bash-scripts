## **Security Auditor v2.3 - User Guide**

### **📋 "Two Words" Description:**
**Library Hardening**

### **🎯 Core Purpose:**
Interactive security assessment tool for compiled C/C++ libraries in embedded/robotics projects.

---

## **🚀 Quick Start**
```bash
# 1. Make executable
chmod +x security-auditor.sh

# 2. Navigate to project directory
cd /path/to/your/project

# 3. Run interactive mode
./security-auditor.sh
```

---

## **🔧 User Patterns**

### **Pattern 1: Single Library Audit**
```bash
# From project root
./security-auditor.sh

# Or audit specific file
./security-auditor.sh ./build/libmatrixlib.dylib
```
**Flow**: Select library → View security report → Optionally save log

### **Pattern 2: Batch Audit**
```bash
# Audit multiple libraries at once
./security-auditor.sh
# Choose option 2, multi-select with Tab in fzf
```
**Use case**: CI/CD pipelines, regression testing, project-wide security sweep

### **Pattern 3: Neovim Integration**
```bash
# Add to Neovim config for quick access
nnoremap <leader>sa :!./security-auditor.sh<CR>
nnoremap <leader>sl :!./security-auditor.sh %:p:h<CR>
```
**Workflow**: Code → Build → Audit → Fix

---

## **📊 Security Metrics Explained**

### **Attack Surface (Exported Symbols)**
- **🟢 < 30 symbols**: Excellent (minimal exposure)
- **🟡 30-100 symbols**: Review recommended
- **🔴 > 100 symbols**: High risk (refactor needed)

### **Critical Checks:**
1. **Debug Symbols**: Should be stripped in production
2. **Dangerous Functions**: `strcpy`, `gets`, `system` calls
3. **C++ Symbols**: Leak internal implementation
4. **Permissions**: Proper ownership and access

---

## **💾 Logging Workflow**
```
Audit Complete → [Save? y/N] → Choose filename → View? y/N
```
- **Logs saved to**: `./security_audit_logs/`
- **Auto-timestamped**: `audit_libname_YYYYMMDD_HHMMSS.log`
- **Includes metadata**: Host, user, path, timestamp

---

## **🎮 Interactive Commands**

### **fzf Navigation:**
- **↑/↓**: Navigate library list
- **Tab**: Multi-select (batch mode)
- **/**: Search filter
- **Enter**: Confirm selection
- **Ctrl+C**: Exit

### **Menu Options:**
```
1️⃣ Single Audit    → Pick one library → Full report
2️⃣ Batch Audit     → Multi-select → All reports
3️⃣ Help            → Quick reference guide
4️⃣ Exit            → Close application
```

---

## **🔍 Embedded/Robotics Focus**

### **What It Catches:**
- **Memory safety**: Buffer overflows, dangerous functions
- **Information leakage**: Debug symbols, C++ internals
- **Attack surface**: Excessive exported symbols
- **Platform issues**: RPATH/RELRO configurations

### **Best Practices Enforced:**
- Minimal C API interfaces
- Hidden symbol visibility
- Stripped production binaries
- Clean separation layers

---

## **⚡ Pro Tips**

### **For CI/CD:**
```bash
# Run silently, save logs only
./security-auditor.sh --silent 2>/dev/null

# Check exit codes
if ./security-auditor.sh --check lib.dylib; then
    echo "Security passed"
else
    echo "Security failed"
fi
```

### **For Development:**
```bash
# Audit after every build
make && ./security-auditor.sh ./build/*.dylib

# Compare library versions
diff audit_v1.log audit_v2.log
```

### **For Security Reviews:**
```bash
# Generate comprehensive report
./security-auditor.sh > security_report.txt

# Archive with project
tar -czf security_audits.tar.gz security_audit_logs/
```

---

## **🚨 Common Issues & Solutions**

| Issue | Solution |
|-------|----------|
| "No libraries found" | Run from build directory |
| "Missing fzf/nm" | `brew install fzf binutils` (macOS) |
| Colors not displaying | Terminal supports ANSI colors |
| Log file permissions | Check `security_audit_logs/` directory |

---

## **📈 Output Interpretation**

### **Green (✓)**: Secure
- Minimal exported symbols
- No debug symbols
- Clean C API
- Proper permissions

### **Yellow (⚠)**: Warning
- Moderate symbol count
- C++ symbols present
- Needs review

### **Red (✗)**: Critical
- Large attack surface
- Dangerous functions
- Debug symbols in production

---

## **🎯 Ideal Use Cases**

1. **Pre-release validation**: Final security check before deployment
2. **Dependency auditing**: Third-party library security assessment
3. **Code review automation**: Integrate with pull request workflows
4. **Security regression**: Track attack surface over time
5. **Compliance checks**: Embedded safety standards (MISRA, AUTOSAR)

---

## **📚 Quick Reference Card**

```bash
# COMMAND LINE
./security-auditor.sh                    # Interactive mode
./security-auditor.sh lib.dylib          # Audit specific file
./security-auditor.sh 2>&1 | tee out.log # Save full output

# MENU KEYS
1 → Single audit
2 → Batch audit (Tab to multi-select)
3 → Help
4/q → Exit

# LOGGING
y → Save log
n → Skip logging
y → View after saving
```

**Tagline**: *"Find holes before hackers do"*

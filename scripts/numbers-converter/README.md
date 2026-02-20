Here's a README.md for your number base converter script following the template:

```markdown
# Base Converter v2.0 – User Guide

## 📋 "Two Words" Description:

Number Base Converter

## 🎯 Core Purpose:

Interactive Bash tool for converting numbers between decimal, binary, and hexadecimal formats with cross-platform support and intelligent fallback mechanisms on macOS, Linux, and Windows.

## 🚀 Quick Start

```bash
# 1. Make executable
chmod +x base-converter.sh

# 2. Run interactive mode
./base-converter.sh
```

## 🔧 User Patterns

### Pattern 1: Decimal Conversion

```bash
./base-converter.sh
# Select option 1
# Enter: 42
# Output: Binary: 101010, Hex: 2A
```

**Flow:** Choose decimal option → Enter number → Get binary and hex results

**Use case:** Converting everyday numbers to computer formats.

### Pattern 2: Binary Conversion

```bash
./base-converter.sh
# Select option 2
# Enter: 101010
# Output: Decimal: 42, Hex: 2A
```

**Flow:** Choose binary option → Enter binary string → Get decimal and hex results

**Use case:** Working with low-level data, network masks, or permissions.

### Pattern 3: Hexadecimal Conversion

```bash
./base-converter.sh
# Select option 3
# Enter: 2A or 2a
# Output: Decimal: 42, Binary: 101010
```

**Flow:** Choose hex option → Enter hex value → Get decimal and binary results

**Use case:** Debugging memory dumps, color codes, or assembly programming.

## 💻 System Compatibility

| OS | Status | Notes |
|----|--------|-------|
| Linux | ✅ Full | Native support |
| macOS | ✅ Full | Homebrew/MacPorts optional |
| Windows | ✅ Partial | WSL, Git Bash, or Cygwin |

## 📦 Dependency Management

### Automatic Fallback
The script includes a built-in binary converter that works **without bc**:
- Pure Bash implementation
- No external dependencies required
- Graceful degradation

### Optional: Install bc for advanced features

**Linux:**
```bash
# Debian/Ubuntu
sudo apt-get install bc

# RHEL/CentOS
sudo yum install bc

# Fedora
sudo dnf install bc

# Arch
sudo pacman -S bc
```

**macOS:**
```bash
# Homebrew
brew install bc

# MacPorts
sudo port install bc
```

**Windows:**
- WSL: Use Linux commands above
- Git Bash: Included in installation
- Cygwin: Select bc package during setup

## 🧮 Conversion Logic

### Input Validation

**Decimal:**
```regex
^[0-9]+$
```
- Only digits allowed
- No leading zeros required

**Binary:**
```regex
^[01]+$
```
- Only 0 and 1 allowed
- Any length supported

**Hexadecimal:**
```regex
^[0-9a-fA-F]+$
```
- Case-insensitive
- Standard 0-9, A-F format

### Conversion Methods

1. **Primary Method (with bc)**
   - Decimal → Binary: `obase=2; $dec | bc`
   - Binary → Decimal: Bash arithmetic `$((2#$bin))`
   - Hex → Decimal: Bash arithmetic `$((16#$hex))`

2. **Fallback Method (without bc)**
   - Manual division algorithm for binary conversion
   - Preserves functionality on minimal systems

## 🎨 Output Formatting

### Color-Coded Results

- 🔵 **Blue:** Menus and system info
- 🟢 **Green:** Binary results
- 🟡 **Yellow:** Hexadecimal results
- 🔴 **Red:** Error messages

### Example Output
```
=================================
Конвертер систем счисления
=================================
Выберите операцию:
1) Десятичное -> Двоичное и Шестнадцатеричное
2) Двоичное -> Десятичное и Шестнадцатеричное
3) Шестнадцатеричное -> Десятичное и Двоичное
4) Показать информацию о системе
5) Выход
=================================
Введите номер операции: 1
Введите десятичное число: 255
Двоичное: 11111111
Шестнадцатеричное: FF
```

## 📊 System Information

Option 4 provides:
- Operating system details
- Architecture (x86_64, arm64, etc.)
- bc installation status
- Homebrew detection (macOS)

## ⚡ Pro Tips

### Quick Conversion Chain
```bash
# Convert between all formats quickly
./base-converter.sh
# Option 1: 64 → 1000000, 40
# Option 2: 1000000 → 64, 40
# Option 3: 40 → 64, 1000000
```

### Batch Processing Idea
```bash
# Create wrapper for multiple conversions
for num in 1 10 100 1000; do
  echo "echo 'obase=2; $num' | bc" | bash
done
```

### Color Management
```bash
# Disable colors if needed (pipe to file)
./base-converter.sh | cat
```

## 🚨 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| ❌ "bc не установлен" warning | Install bc or ignore (fallback works) |
| ❌ Binary conversion fails | Check for non-binary characters |
| ❌ Hex conversion errors | Remove 0x prefix if present |
| ❌ Colors show as codes | Terminal doesn't support ANSI; remove color codes |
| ❌ Large number overflow | Use bc for big numbers > 64-bit |

## 📈 Ideal Use Cases

- **Programming:** Quick constant conversion
- **Networking:** Subnet mask calculations
- **Embedded Systems:** Register value conversion
- **Education:** Teaching number systems
- **Debugging:** Memory address analysis
- **CTF Challenges:** Quick encoding/decoding

## 📚 Quick Reference Card

```bash
./base-converter.sh          # Interactive mode
# Options:
# 1 - Decimal → Binary + Hex
# 2 - Binary → Decimal + Hex  
# 3 - Hex → Decimal + Binary
# 4 - System information
# 5 - Exit

# Example conversions:
# Decimal 255    → Binary 11111111, Hex FF
# Binary 1010    → Decimal 10, Hex A
# Hex FF        → Decimal 255, Binary 11111111
```

**Tagline:** “Convert any number, any base, anywhere.” 🚀
```


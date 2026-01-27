#!/usr/bin/env bash
# ==============================================================================
#
#         FILE: security-auditor.sh
#         USAGE: ./security-auditor.sh
#
#   DESCRIPTION: Interactive security audit for compiled dynamic libraries
#                using fzf for file selection with optional logging
#
#        AUTHOR: Oleg Sokolov (Al`Sapsan)
#  ORGANIZATION: al.sapsan@mail.ru
#       CREATED: 01/27/2026 18:39:47
#      REVISION:  2.3
# ==============================================================================

set -o nounset    # Treat unset variables as an error
set -o pipefail   # Fail on pipe errors

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
LIBRARY_PATH=""
AUDIT_PLAIN=""
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
declare -a OUTPUT_LINES

# Banner
print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           EMBEDDED LIBRARY SECURITY AUDITOR                  ║"
    echo "║           Interactive fzf-based selection                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Check required tools
check_dependencies() {
    local missing_tools=()
    
    for tool in nm file fzf; do
        if ! command -v "$tool" &>/dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo -e "${RED}✗ Missing required tools:${NC}"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        echo -e "\n${YELLOW}Install missing tools and try again.${NC}"
        exit 1
    fi
}

# Find library files recursively from current directory
find_libraries() {
    echo -e "${BLUE}🔍 Searching for dynamic libraries...${NC}"
    
    # Find common dynamic library extensions
    local -a library_extensions=(
        ".dylib"    # macOS
        ".so"       # Linux/Unix
        ".so.*"     # Versioned libraries
        ".dll"      # Windows (if using WSL)
        ".a"        # Static libraries
        ".la"       # Libtool archives
    )
    
    # Build find command
    local find_cmd="find . -type f"
    for ext in "${library_extensions[@]}"; do
        find_cmd+=" -o -name \"*${ext}\""
    done
    
    # Execute and filter out common build artifacts
    eval "$find_cmd" 2>/dev/null | \
        grep -v "\.git" | \
        grep -v "\.cmake" | \
        grep -v "/CMakeFiles/" | \
        sort | uniq
}

# Interactive library selection with fzf
select_library() {
    echo -e "\n${YELLOW}📁 Searching for libraries in: $(pwd)${NC}"
    
    local libraries
    libraries=$(find_libraries)
    
    if [[ -z "$libraries" ]]; then
        echo -e "${RED}✗ No library files found in current directory or subdirectories.${NC}"
        echo -e "${YELLOW}Try running from a different directory or building your project first.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Found $(echo "$libraries" | wc -l) library file(s).${NC}"
    echo -e "${CYAN}Use arrow keys, type to filter, press Enter to select, Ctrl+C to exit.${NC}"
    
    # Use fzf with preview
    local selected
    selected=$(echo "$libraries" | fzf \
        --height 40% \
        --border rounded \
        --prompt="🔎 Select library to audit: " \
        --header="Use ↑↓ to navigate, / to filter, Enter to select" \
        --preview="echo -e '${BLUE}File Info:${NC}\n'; file {}" \
        --preview-window=right:50%:wrap \
        --bind "?:toggle-preview" \
        --ansi)
    
    if [[ -z "$selected" ]]; then
        echo -e "${YELLOW}⚠ No library selected. Exiting.${NC}"
        exit 0
    fi
    
    echo -e "${GREEN}✓ Selected: ${CYAN}$selected${NC}"
    LIBRARY_PATH="$selected"
}

# Get library type for platform-specific analysis
get_library_type() {
    local lib="$1"
    local file_output
    
    file_output=$(file "$lib" 2>/dev/null)
    
    if echo "$file_output" | grep -qi "mach-o.*dynamically linked shared library"; then
        echo "macos_dylib"
    elif echo "$file_output" | grep -qi "elf.*shared object"; then
        echo "linux_so"
    elif echo "$file_output" | grep -qi "pe32.*dll"; then
        echo "windows_dll"
    elif echo "$file_output" | grep -qi "ar archive"; then
        echo "static_lib"
    else
        echo "unknown"
    fi
}

# Platform-specific symbol extraction
extract_symbols() {
    local lib="$1"
    local lib_type="$2"
    
    case "$lib_type" in
        "macos_dylib")
            nm -gU "$lib" 2>/dev/null
            ;;
        "linux_so")
            nm -D --defined-only "$lib" 2>/dev/null
            ;;
        "windows_dll")
            # For WSL/Cygwin, might need objdump
            objdump -p "$lib" 2>/dev/null | grep "Export" || \
            echo "Windows DLL analysis requires specific tools"
            ;;
        "static_lib")
            nm -g --defined-only "$lib" 2>/dev/null
            ;;
        *)
            nm -g "$lib" 2>/dev/null
            ;;
    esac
}

# Add line to output (both displayed and stored)
add_output() {
    local plain_text="$1"
    local colored_text="$2"
    
    # Display colored version
    if [[ -n "$colored_text" ]]; then
        echo -e "$colored_text"
    else
        echo "$plain_text"
    fi
    
    # Store plain text version
    OUTPUT_LINES+=("$plain_text")
}

# Perform security audit on selected library
audit_library() {
    local lib="$1"
    
    if [[ ! -f "$lib" ]]; then
        echo -e "${RED}✗ Library file not found: $lib${NC}"
        return 1
    fi
    
    local lib_type
    lib_type=$(get_library_type "$lib")
    
    # Reset output array
    OUTPUT_LINES=()
    
    # Header
    add_output "══════════════════════════════════════════════════════════════" \
               "${MAGENTA}══════════════════════════════════════════════════════════════${NC}"
    add_output "SECURITY AUDIT: $(basename "$lib")" \
               "${CYAN}🔐 SECURITY AUDIT: ${YELLOW}$(basename "$lib")${NC}"
    add_output "Path: $lib" \
               "${CYAN}📂 Path: ${YELLOW}$lib${NC}"
    add_output "Type: $lib_type" \
               "${CYAN}📋 Type: ${YELLOW}$lib_type${NC}"
    add_output "Time: $(date)" \
               "${CYAN}⏰ Time: ${YELLOW}$(date)${NC}"
    add_output "══════════════════════════════════════════════════════════════" \
               "${MAGENTA}══════════════════════════════════════════════════════════════${NC}"
    
    # 1. Check file permissions
    add_output "" ""
    add_output "1. File Permissions & Ownership:" \
               "${BLUE}1. File Permissions & Ownership:${NC}"
    local perms
    perms=$(stat -c "%A %U:%G %s bytes" "$lib" 2>/dev/null || \
            stat -f "%Sp %Su:%Sg %z bytes" "$lib" 2>/dev/null)
    add_output "   $perms" \
               "   ${YELLOW}$perms${NC}"
    
    # 2. Check for debug symbols
    add_output "" ""
    add_output "2. Debug Symbols Check:" \
               "${BLUE}2. Debug Symbols Check:${NC}"
    if file "$lib" | grep -q "not stripped"; then
        add_output "   Debug symbols present (security risk for production)" \
                   "   ${RED}✗ Debug symbols present (security risk for production)${NC}"
    else
        add_output "   Stripped - no debug symbols" \
                   "   ${GREEN}✓ Stripped - no debug symbols${NC}"
    fi
    
    # 3. Check exported symbols count
    add_output "" ""
    add_output "3. Attack Surface Analysis (Exported Symbols):" \
               "${BLUE}3. Attack Surface Analysis (Exported Symbols):${NC}"
    local symbols
    symbols=$(extract_symbols "$lib" "$lib_type")
    local symbol_count
    symbol_count=$(echo "$symbols" | wc -l)
    
    if [[ $symbol_count -gt 100 ]]; then
        add_output "   Large attack surface: $symbol_count symbols" \
                   "   ${RED}✗ Large attack surface: $symbol_count symbols${NC}"
    elif [[ $symbol_count -gt 30 ]]; then
        add_output "   Moderate attack surface: $symbol_count symbols" \
                   "   ${YELLOW}⚠ Moderate attack surface: $symbol_count symbols${NC}"
    else
        add_output "   Minimal attack surface: $symbol_count symbols" \
                   "   ${GREEN}✓ Minimal attack surface: $symbol_count symbols${NC}"
    fi
    
    # Show top 10 symbols if there are any
    if [[ $symbol_count -gt 0 ]]; then
        add_output "   Top 10 exported symbols:" \
                   "   ${CYAN}Top 10 exported symbols:${NC}"
        local counter=0
        while IFS= read -r symbol && [[ $counter -lt 10 ]]; do
            add_output "     $symbol" "     $symbol"
            ((counter++))
        done <<< "$symbols"
    fi
    
    # 4. Look for dangerous functions
    add_output "" ""
    add_output "4. Dangerous Function Patterns:" \
               "${BLUE}4. Dangerous Function Patterns:${NC}"
    local danger_found=false
    
    # Common dangerous patterns
    declare -a dangerous_patterns=(
        "gets\(" "strcpy\(" "strcat\(" "sprintf\("
        "system\(" "popen\(" "exec\(" "fork\("
        "malloc\(" "free\(" "realloc\("
        "memcpy\(" "memset\(" "memmove\("
    )
    
    for pattern in "${dangerous_patterns[@]}"; do
        if echo "$symbols" | grep -i "$pattern" >/dev/null; then
            add_output "   Dangerous pattern: $pattern" \
                       "   ${RED}✗ Dangerous pattern: $pattern${NC}"
            danger_found=true
        fi
    done
    
    if [[ "$danger_found" = false ]]; then
        add_output "   No dangerous function patterns detected" \
                   "   ${GREEN}✓ No dangerous function patterns detected${NC}"
    fi
    
    # 5. Check for C++ symbols (potential bloat/security issues)
    add_output "" ""
    add_output "5. C++ Symbol Analysis:" \
               "${BLUE}5. C++ Symbol Analysis:${NC}"
    local cpp_symbols
    cpp_symbols=$(echo "$symbols" | grep -E "_Z|_GLOBAL|\.eh_frame|__cxa")
    
    if [[ -n "$cpp_symbols" ]]; then
        local cpp_count
        cpp_count=$(echo "$cpp_symbols" | wc -l)
        add_output "   C++ symbols detected: $cpp_count symbols" \
                   "   ${YELLOW}⚠ C++ symbols detected: $cpp_count symbols${NC}"
        add_output "   Sample C++ symbols:" \
                   "   ${CYAN}Sample C++ symbols:${NC}"
        local counter=0
        while IFS= read -r symbol && [[ $counter -lt 5 ]]; do
            add_output "     $symbol" "     $symbol"
            ((counter++))
        done <<< "$cpp_symbols"
    else
        add_output "   Clean C API (no C++ symbols)" \
                   "   ${GREEN}✓ Clean C API (no C++ symbols)${NC}"
    fi
    
    # 6. Additional platform-specific checks
    add_output "" ""
    add_output "6. Platform-Specific Checks:" \
               "${BLUE}6. Platform-Specific Checks:${NC}"
    case "$lib_type" in
        "macos_dylib")
            add_output "   macOS-specific:" \
                       "   ${CYAN}macOS-specific:${NC}"
            # Check for @rpath
            if otool -l "$lib" 2>/dev/null | grep -q "@rpath"; then
                add_output "   Uses @rpath (good for relocation)" \
                           "   ${GREEN}✓ Uses @rpath (good for relocation)${NC}"
            fi
            ;;
        "linux_so")
            add_output "   Linux-specific:" \
                       "   ${CYAN}Linux-specific:${NC}"
            # Check for RELRO, NX, etc.
            if command -v checksec &>/dev/null; then
                local checksec_output
                checksec_output=$(checksec --file="$lib" 2>/dev/null | tail -1)
                add_output "   $checksec_output" \
                           "   ${YELLOW}$checksec_output${NC}"
            elif command -v readelf &>/dev/null; then
                add_output "   Run: readelf -d $lib | grep -E '(RELRO|BIND_NOW|DEBUG)'" \
                           "   ${YELLOW}Run: readelf -d $lib | grep -E '(RELRO|BIND_NOW|DEBUG)'${NC}"
            fi
            ;;
    esac
    
    # Footer
    add_output "" ""
    add_output "══════════════════════════════════════════════════════════════" \
               "${MAGENTA}══════════════════════════════════════════════════════════════${NC}"
    add_output "Audit Summary:" \
               "${CYAN}📊 Audit Summary:${NC}"
    add_output "   Library: $(basename "$lib")" \
               "${CYAN}   Library: ${YELLOW}$(basename "$lib")${NC}"
    add_output "   Symbols: $symbol_count exported" \
               "${CYAN}   Symbols: ${YELLOW}$symbol_count exported${NC}"
    add_output "   Status:  Audit complete" \
               "${CYAN}   Status:  ${GREEN}Audit complete${NC}"
    add_output "══════════════════════════════════════════════════════════════" \
               "${MAGENTA}══════════════════════════════════════════════════════════════${NC}"
    
    # Convert array to plain text for logging
    AUDIT_PLAIN=$(printf "%s\n" "${OUTPUT_LINES[@]}")
}

# Batch audit option
batch_audit() {
    echo -e "\n${BLUE}🔍 Select multiple libraries for batch audit:${NC}"
    
    local libraries
    libraries=$(find_libraries)
    
    local selected
    selected=$(echo "$libraries" | fzf \
        --height 40% \
        --border rounded \
        --multi \
        --prompt="🔎 Select libraries (Tab to multi-select): " \
        --header="Use Tab to select multiple, Enter to audit all selected" \
        --preview="echo -e '${BLUE}File Info:${NC}\n'; file {}" \
        --preview-window=right:50%:wrap)
    
    if [[ -z "$selected" ]]; then
        echo -e "${YELLOW}⚠ No libraries selected.${NC}"
        return
    fi
    
    local count
    count=$(echo "$selected" | wc -l)
    echo -e "${GREEN}✓ Selected $count libraries for audit.${NC}"
    
    # Clear previous audit output
    AUDIT_PLAIN=""
    OUTPUT_LINES=()
    
    local audit_counter=1
    local batch_output=""
    
    while IFS= read -r lib; do
        [[ -n "$lib" ]] || continue
        echo -e "\n${CYAN}══════════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}📦 Batch Audit $audit_counter of $count${NC}"
        echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
        
        # Run audit and capture output
        audit_library "$lib"
        batch_output+="$AUDIT_PLAIN"$'\n\n'
        
        ((audit_counter++))
        echo ""  # Add spacing between audits
    done <<< "$selected"
    
    echo -e "\n${GREEN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Batch Audit Complete${NC}"
    echo -e "${GREEN}   Total Libraries: $count${NC}"
    echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
    
    # Store batch output
    AUDIT_PLAIN="$batch_output"
}

# Ask to save log file
ask_to_save_log() {
    echo -e "\n${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}💾 Save Audit Results to Log File?${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    
    read -rp "$(echo -e "${CYAN}Save audit results to log file? (y/N): ${NC}")" save_choice
    
    if [[ "$save_choice" =~ ^[Yy]$ ]]; then
        # Create logs directory if it doesn't exist
        mkdir -p "./security_audit_logs"
        
        # Generate log filename
        local log_filename
        if [[ -n "$LIBRARY_PATH" ]]; then
            local lib_name=$(basename "$LIBRARY_PATH" | sed 's/[^a-zA-Z0-9._-]/_/g')
            log_filename="./security_audit_logs/audit_${lib_name}_${TIMESTAMP}.log"
        else
            log_filename="./security_audit_logs/audit_batch_${TIMESTAMP}.log"
        fi
        
        # Create log file with header
        {
            echo "=================================================================="
            echo "SECURITY AUDIT LOG"
            echo "Timestamp: $(date)"
            echo "Host: $(hostname)"
            echo "User: $(whoami)"
            echo "Working Directory: $(pwd)"
            echo "Log File: $log_filename"
            echo "=================================================================="
            echo ""
            echo "$AUDIT_PLAIN"
        } > "$log_filename"
        
        echo -e "${GREEN}✓ Audit log saved to: ${YELLOW}$log_filename${NC}"
        
        # Option to view the log file
        read -rp "$(echo -e "${CYAN}View the log file now? (y/N): ${NC}")" view_choice
        if [[ "$view_choice" =~ ^[Yy]$ ]]; then
            echo -e "\n${BLUE}📄 Log File Content:${NC}"
            echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
            cat "$log_filename"
            echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Audit results not saved.${NC}"
    fi
}

# Main menu
main_menu() {
    while true; do
        print_banner
        
        echo -e "${CYAN}Current directory: ${YELLOW}$(pwd)${NC}"
        echo -e "${CYAN}Available options:${NC}"
        echo -e "  ${GREEN}1${NC}) Select and audit single library"
        echo -e "  ${GREEN}2${NC}) Batch audit multiple libraries"
        echo -e "  ${GREEN}3${NC}) View quick help"
        echo -e "  ${GREEN}4${NC}) Exit"
        echo ""
        
        read -rp "$(echo -e "${CYAN}Select option [1-4]: ${NC}")" choice
        
        case "$choice" in
            1)
                select_library
                audit_library "$LIBRARY_PATH"
                ask_to_save_log
                pause
                ;;
            2)
                batch_audit
                ask_to_save_log
                pause
                ;;
            3)
                show_help
                pause
                ;;
            4|q|quit)
                echo -e "${GREEN}👋 Exiting. Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}✗ Invalid option. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Pause function
pause() {
    echo ""
    read -n 1 -s -rp "$(echo -e "${CYAN}Press any key to continue...${NC}")"
    echo ""
}

# Show help
show_help() {
    echo -e "\n${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}                    QUICK HELP GUIDE                        ${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}What this tool checks:${NC}"
    echo -e "  • Exported symbols count (attack surface)"
    echo -e "  • Dangerous function patterns"
    echo -e "  • Debug symbols presence"
    echo -e "  • File permissions"
    echo -e "  • C++ symbol leakage"
    echo -e ""
    echo -e "${GREEN}Logging Feature:${NC}"
    echo -e "  • After each audit, you can save results to a log file"
    echo -e "  • Logs are saved in ./security_audit_logs/"
    echo -e "  • Automatic timestamp and metadata included"
    echo -e ""
    echo -e "${GREEN}Security guidelines:${NC}"
    echo -e "  • ${RED}< 30 symbols${NC}: Excellent (minimal attack surface)"
    echo -e "  • ${YELLOW}30-100 symbols${NC}: Acceptable (review needed)"
    echo -e "  • ${RED}> 100 symbols${NC}: High risk (consider refactoring)"
    echo -e ""
    echo -e "${GREEN}How to reduce attack surface:${NC}"
    echo -e "  • Use -fvisibility=hidden in compiler flags"
    echo -e "  • Mark functions as static when possible"
    echo -e "  • Provide minimal C API for libraries"
    echo -e "  • Strip debug symbols in production"
    echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
}

# Main execution
main() {
    check_dependencies
    
    # If library path provided as argument
    if [[ $# -gt 0 ]]; then
        if [[ -f "$1" ]]; then
            audit_library "$1"
            ask_to_save_log
            exit 0
        else
            echo -e "${RED}✗ File not found: $1${NC}"
            exit 1
        fi
    fi
    
    # Interactive mode
    main_menu
}

# Run main function
main "$@"

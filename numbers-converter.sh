#!/bin/bash -
#===============================================================================
#
#   FILE: numbers-converter.sh
#   USAGE: ./numbers-converter.sh
#
#   DESCRIPTION: Interactive Bash tool for converting numbers between decimal, 
#   binary, and hexadecimal formats with cross-platform support and intelligent 
#   fallback mechanisms on macOS, Linux, and Windows.
#
#  REQUIREMENTS: bc (Basic Calculator)
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Oleg Sokolov (Al`Sapsan), al-sapsan@mail.ru
#       CREATED: 02/20/2026 22:14:58
#      REVISION: 2.1
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect operating system
detect_os() {
  case "$(uname -s)" in
    Linux*)     echo "linux";;
    Darwin*)    echo "macos";;
    CYGWIN*|MINGW*|MSYS*) echo "windows";;
    *)          echo "unknown";;
  esac
}

OS=$(detect_os)

# Check for bc dependency with OS-specific instructions
check_bc() {
  if ! command -v bc &> /dev/null; then
    echo -e "${RED}Ошибка:${NC} bc не установлен."
    
    case $OS in
      linux)
        echo "Установите bc одной из команд:"
        echo "  Ubuntu/Debian:  sudo apt-get install bc"
        echo "  CentOS/RHEL:    sudo yum install bc"
        echo "  Fedora:         sudo dnf install bc"
        echo "  Arch Linux:     sudo pacman -S bc"
        ;;
      macos)
        echo "Установите bc одной из команд:"
        echo "  С помощью Homebrew:     brew install bc"
        echo "  С помощью MacPorts:     sudo port install bc"
        echo ""
        echo "Homebrew можно установить с: https://brew.sh/"
        ;;
      windows)
        echo "Для Windows рекомендуется:"
        echo "  - Установить WSL (Windows Subsystem for Linux)"
        echo "  - Или использовать Git Bash с пакетом bc"
        echo "  - Или установить Cygwin с пакетом bc"
        ;;
      *)
        echo "Пожалуйста, установите bc для вашей операционной системы"
        ;;
    esac
    return 1
  fi
  return 0
}

# Alternative binary conversion without bc (for systems without bc)
decimal_to_binary_fallback() {
  local dec=$1
  local bin=""
  
  if [[ $dec -eq 0 ]]; then
    echo "0"
    return
  fi
  
  while [[ $dec -gt 0 ]]; do
    bin=$((dec % 2))$bin
    dec=$((dec / 2))
  done
  
  echo "$bin"
}

convert_decimal() {
  read -p "Введите десятичное число: " dec
  if [[ -z "$dec" ]] || ! [[ "$dec" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Ошибка:${NC} введите корректное десятичное число"
    return 1
  fi
  
  # Try using bc first, fall back to manual conversion if bc is not available
  if command -v bc &> /dev/null; then
    bin=$(echo "obase=2; $dec" | bc)
  else
    echo -e "${YELLOW}Предупреждение:${NC} bc не найден, использую встроенное преобразование"
    bin=$(decimal_to_binary_fallback "$dec")
  fi
  
  hex=$(printf "%X\n" "$dec")
  
  echo -e "${GREEN}Двоичное:${NC} $bin"
  echo -e "${YELLOW}Шестнадцатеричное:${NC} $hex"
}

convert_binary() {
  read -p "Введите двоичное число: " bin
  if [[ -z "$bin" ]] || ! [[ "$bin" =~ ^[01]+$ ]]; then
    echo -e "${RED}Ошибка:${NC} введите корректное двоичное число"
    return 1
  fi
  
  # Check for overflow on 32-bit systems
  if [[ ${#bin} -gt 31 ]] && [[ $(getconf LONG_BIT 2>/dev/null) -eq 32 ]]; then
    echo -e "${YELLOW}Предупреждение:${NC} число может быть слишком большим для 32-битной системы"
  fi
  
  dec=$((2#$bin))
  hex=$(printf "%X\n" "$dec")
  
  echo -e "${BLUE}Десятичное:${NC} $dec"
  echo -e "${YELLOW}Шестнадцатеричное:${NC} $hex"
}

convert_hex() {
  read -p "Введите шестнадцатеричное число: " hex
  # Convert to uppercase for validation
  hex_upper=$(echo "$hex" | tr '[:lower:]' '[:upper:]')
  if [[ -z "$hex" ]] || ! [[ "$hex_upper" =~ ^[0-9A-F]+$ ]]; then
    echo -e "${RED}Ошибка:${NC} введите корректное шестнадцатеричное число"
    return 1
  fi
  
  dec=$((16#$hex_upper))
  
  # Try using bc first, fall back to manual conversion if bc is not available
  if command -v bc &> /dev/null; then
    bin=$(echo "obase=2; $dec" | bc)
  else
    echo -e "${YELLOW}Предупреждение:${NC} bc не найден, использую встроенное преобразование"
    bin=$(decimal_to_binary_fallback "$dec")
  fi
  
  echo -e "${BLUE}Десятичное:${NC} $dec"
  echo -e "${GREEN}Двоичное:${NC} $bin"
}

show_system_info() {
  echo -e "${BLUE}Системная информация:${NC}"
  echo "  ОС: $(uname -s) $(uname -r)"
  echo "  Архитектура: $(uname -m)"
  
  if command -v bc &> /dev/null; then
    echo "  bc: установлен (версия $(bc --version | head -n1))"
  else
    echo -e "  bc: ${RED}не установлен${NC}"
  fi
  
  if command -v brew &> /dev/null; then
    echo "  Homebrew: установлен"
  fi
  echo ""
}

# Main menu
while true; do
  echo -e "${BLUE}=================================${NC}"
  echo "Конвертер систем счисления"
  echo -e "${BLUE}=================================${NC}"
  echo "Выберите операцию:"
  echo "1) Десятичное -> Двоичное и Шестнадцатеричное"
  echo "2) Двоичное -> Десятичное и Шестнадцатеричное"
  echo "3) Шестнадцатеричное -> Десятичное и Двоичное"
  echo "4) Показать информацию о системе"
  echo "5) Выход"
  echo -e "${BLUE}=================================${NC}"
  read -p "Введите номер операции: " choice

  case $choice in
    1) convert_decimal ;;
    2) convert_binary ;;
    3) convert_hex ;;
    4) show_system_info ;;
    5) echo -e "${GREEN}До свидания!${NC}"; break ;;
    *) echo -e "${RED}Неверный выбор, попробуйте снова.${NC}" ;;
  esac
  echo
done

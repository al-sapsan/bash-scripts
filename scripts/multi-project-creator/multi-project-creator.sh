#!/bin/bash -
#===============================================================================
#
#          FILE: multi-project-creator.sh
#
#         USAGE: ./multi-project-creator.sh
#
#   DESCRIPTION: Multi-language Project Repository Creator
#                Supports: Bash, C, C++, Python, Rust
#
#       OPTIONS: ---
#  REQUIREMENTS: git, (optional: cargo for Rust, gcc for C/C++)
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Oleg Sokolov (Al`Sapsan), 
#  ORGANIZATION: al-sapsan@mail.ru
#       CREATED: 02/06/2026 22:00:03
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
set -o errexit                              # Exit on error
trap 'echo "Error at line $LINENO. Exit code: $?"' ERR

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${PURPLE}$1${NC}"; }
print_language() { echo -e "${CYAN}[$1]${NC} $2"; }

# Check prerequisites
check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_warning "$1 is not installed. Some features may not work."
        return 1
    fi
    return 0
}

# ASCII Art Banner
echo "================================================"
cat << "EOF"
  __  __       _ _   _       _   _             
 |  \/  |_   _| | |_(_)_ __ | |_(_)_ __   __ _ 
 | |\/| | | | | | __| | '_ \| __| | '_ \ / _` |
 | |  | | |_| | | |_| | |_) | |_| | | | | (_| |
 |_|  |_|\__,_|_|\__|_| .__/ \__|_|_| |_|\__, |
                      |_|                |___/ 
EOF
echo "     Multi-Language Project Creator"
echo "================================================"

# --- Step 1: Choose project type ---
print_header "🎯 Select Project Type"
echo "1) Bash Script Project"
echo "2) C Project"
echo "3) C++ Project"
echo "4) Python Project"
echo "5) Rust Project"
echo "6) Custom/Generic"

while true; do
    read -p "Enter choice (1-6): " project_type
    case $project_type in
        1) language="bash"; break ;;
        2) language="c"; break ;;
        3) language="cpp"; break ;;
        4) language="python"; break ;;
        5) language="rust"; break ;;
        6) language="generic"; break ;;
        *) print_error "Invalid choice. Please enter 1-6";;
    esac
done

print_language "$language" "Selected project type"

# --- Step 2: Choose folder location ---
print_header "📁 Choose Project Location"
while true; do
    read -p "Create project in current directory? (y/n/help): " use_current
    
    case "$use_current" in
        [Yy]*)
            repo_path="$(pwd)"
            print_info "Using current directory: $repo_path"
            break
            ;;
        [Nn]*)
            read -p "Enter full path where the project should be created: " repo_path
            
            # Expand tilde to home directory
            repo_path="${repo_path/#\~/$HOME}"
            
            # Create directory if it doesn't exist
            if [ ! -d "$repo_path" ]; then
                print_info "Creating directory: $repo_path"
                mkdir -p "$repo_path"
                print_success "Directory created successfully"
            fi
            break
            ;;
        [Hh]elp)
            echo "y/Y - Use current directory"
            echo "n/N - Specify custom path"
            continue
            ;;
        *)
            print_error "Invalid choice. Please enter y/n or help"
            continue
            ;;
    esac
done

# --- Step 3: Ask for project name ---
print_header "🏷️  Project Name"
read -p "Enter project name (lowercase, dashes): " project_name

# Format project name
project_name=$(echo "$project_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr '_' '-')

# Validate project name
if [[ ! "$project_name" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]]; then
    print_error "Invalid project name. Use lowercase letters, numbers, and dashes only."
    exit 1
fi

# For Rust, convert dashes to underscores for crate name
if [[ "$language" == "rust" ]]; then
    crate_name=$(echo "$project_name" | tr '-' '_')
else
    crate_name="$project_name"
fi

full_path="$repo_path/$project_name"

# Check if folder exists
if [ -d "$full_path" ]; then
    print_warning "Folder '$full_path' already exists."
    read -p "Do you want to use it? (y/n): " use_existing
    
    if [[ ! "$use_existing" =~ ^[Yy]$ ]]; then
        print_info "Exiting..."
        exit 1
    fi
else
    # Create project folder
    mkdir -p "$full_path"
    print_success "Created project folder: $full_path"
fi

cd "$full_path" || {
    print_error "Failed to navigate to $full_path"
    exit 1
}

# --- Step 4: Create language-specific structure ---
print_header "📁 Creating Project Structure"

create_bash_structure() {
    print_language "bash" "Creating Bash project structure..."
    
    # Directory structure
    mkdir -p src/{bin,lib,utils} tests examples config
    
    # Main entry point
    cat << 'EOF' > src/bin/main.sh
#!/bin/bash
# Main script for PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
source "$PROJECT_ROOT/lib/common.sh"

# Main function
main() {
    log_info "Starting application..."
    
    # Your code here
    
    log_success "Application completed successfully"
    exit 0
}

# Error handling
trap 'log_error "Error at line $LINENO"; exit 1' ERR

# Run main function
main "$@"
EOF
    
    # Common library
    cat << 'EOF' > src/lib/common.sh
#!/bin/bash
# Common functions library

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate required commands
validate_commands() {
    local missing=()
    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required commands: ${missing[*]}"
        return 1
    fi
    return 0
}
EOF
    
    # Example utility
    cat << 'EOF' > src/utils/helpers.sh
#!/bin/bash
# Utility functions

# Function to check if string contains substring
contains() {
    [[ "$1" == *"$2"* ]] && return 0 || return 1
}

# Function to check if file exists and is readable
file_exists() {
    [[ -f "$1" && -r "$1" ]] && return 0 || return 1
}

# Function to get file extension
get_extension() {
    echo "${1##*.}"
}

# Function to get filename without extension
get_basename() {
    echo "${1%.*}"
}
EOF
    
    # Test script
    cat << 'EOF' > tests/test_basic.sh
#!/bin/bash
# Basic test script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
source "$PROJECT_ROOT/src/lib/common.sh"

test_logging() {
    log_info "This is an info message"
    log_success "This is a success message"
    log_warning "This is a warning message"
    log_error "This is an error message"
    return 0
}

# Run tests
echo "Running tests..."
test_logging
echo "Tests completed!"
EOF
    
    # Make scripts executable
    chmod +x src/bin/main.sh
    chmod +x src/lib/common.sh
    chmod +x src/utils/helpers.sh
    chmod +x tests/test_basic.sh
    
    # Build script
    cat << 'EOF' > build.sh
#!/bin/bash
# Build script for Bash project

set -e

PROJECT_NAME="PROJECT_NAME"
VERSION="1.0.0"
BUILD_DIR="build"
DIST_DIR="dist"

echo "Building $PROJECT_NAME v$VERSION"

# Create directories
mkdir -p "$BUILD_DIR" "$DIST_DIR"

# Copy source files
cp -r src "$BUILD_DIR/"
cp -r lib "$BUILD_DIR/" 2>/dev/null || true

# Create archive
tar -czf "$DIST_DIR/$PROJECT_NAME-$VERSION.tar.gz" -C "$BUILD_DIR" .

echo "Build complete: $DIST_DIR/$PROJECT_NAME-$VERSION.tar.gz"
EOF
    
    chmod +x build.sh
    
    print_success "Bash project structure created"
}

create_c_structure() {
    print_language "c" "Creating C project structure..."
    
    # Directory structure
    mkdir -p src/{core,utils,platform} include tests examples build
    
    # Main header
    cat << 'EOF' > include/project.h
/**
 * @file project.h
 * @brief Main header file for PROJECT_NAME
 * @version 1.0.0
 */

#ifndef PROJECT_NAME_H
#define PROJECT_NAME_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

// Project version
#define PROJECT_NAME_VERSION_MAJOR 1
#define PROJECT_NAME_VERSION_MINOR 0
#define PROJECT_NAME_VERSION_PATCH 0

// Error codes
typedef enum {
    PROJECT_SUCCESS = 0,
    PROJECT_ERROR_NULL_POINTER = -1,
    PROJECT_ERROR_INVALID_ARGUMENT = -2,
    PROJECT_ERROR_MEMORY = -3,
    PROJECT_ERROR_IO = -4,
    PROJECT_ERROR_UNKNOWN = -99
} project_error_t;

// Basic types
typedef struct {
    int x;
    int y;
} point_t;

// Core functions
project_error_t project_init(void);
project_error_t project_cleanup(void);
const char* project_get_version(void);

// Utility functions
char* project_string_duplicate(const char* str);
bool project_string_equals(const char* a, const char* b);

#ifdef __cplusplus
}
#endif

#endif // PROJECT_NAME_H
EOF
    
    # Main source
    cat << 'EOF' > src/core/main.c
/**
 * @file main.c
 * @brief Main entry point
 */

#include "project.h"
#include "utils.h"

int main(int argc, char** argv) {
    printf("Starting PROJECT_NAME v%s\n", project_get_version());
    
    // Initialize project
    project_error_t err = project_init();
    if (err != PROJECT_SUCCESS) {
        fprintf(stderr, "Failed to initialize project: %d\n", err);
        return EXIT_FAILURE;
    }
    
    // Your application logic here
    printf("Application running...\n");
    
    // Cleanup
    project_cleanup();
    printf("Application completed successfully\n");
    
    return EXIT_SUCCESS;
}
EOF
    
    # Implementation
    cat << 'EOF' > src/core/project.c
/**
 * @file project.c
 * @brief Core implementation
 */

#include "project.h"

// Static variables
static bool initialized = false;

project_error_t project_init(void) {
    if (initialized) {
        return PROJECT_SUCCESS;
    }
    
    printf("Initializing PROJECT_NAME...\n");
    initialized = true;
    
    return PROJECT_SUCCESS;
}

project_error_t project_cleanup(void) {
    if (!initialized) {
        return PROJECT_SUCCESS;
    }
    
    printf("Cleaning up PROJECT_NAME...\n");
    initialized = false;
    
    return PROJECT_SUCCESS;
}

const char* project_get_version(void) {
    return "1.0.0";
}
EOF
    
    # Utility functions
    cat << 'EOF' > src/utils/utils.c
/**
 * @file utils.c
 * @brief Utility functions
 */

#include "project.h"

char* project_string_duplicate(const char* str) {
    if (str == NULL) {
        return NULL;
    }
    
    size_t len = strlen(str) + 1;
    char* copy = (char*)malloc(len);
    
    if (copy != NULL) {
        strcpy(copy, str);
    }
    
    return copy;
}

bool project_string_equals(const char* a, const char* b) {
    if (a == NULL || b == NULL) {
        return a == b;
    }
    
    return strcmp(a, b) == 0;
}
EOF
    
    # Utils header
    cat << 'EOF' > include/utils.h
#ifndef UTILS_H
#define UTILS_H

#include "project.h"

// String utilities
char* string_trim(char* str);
char* string_to_lower(char* str);
char* string_to_upper(char* str);

// File utilities
bool file_exists(const char* path);
long file_size(const char* path);

// Memory utilities
void* safe_malloc(size_t size);
void* safe_calloc(size_t num, size_t size);
void safe_free(void** ptr);

#endif // UTILS_H
EOF
    
    # Test file
    cat << 'EOF' > tests/test_basic.c
#include <assert.h>
#include <string.h>
#include "project.h"

void test_version(void) {
    const char* version = project_get_version();
    assert(version != NULL);
    printf("Version: %s\n", version);
}

void test_string_duplicate(void) {
    char* original = "Hello, World!";
    char* copy = project_string_duplicate(original);
    
    assert(copy != NULL);
    assert(strcmp(original, copy) == 0);
    
    free(copy);
    printf("String duplicate test passed\n");
}

int main(void) {
    printf("Running C tests...\n");
    
    test_version();
    test_string_duplicate();
    
    printf("All tests passed!\n");
    return 0;
}
EOF
    
    # Makefile
    cat << 'EOF' > Makefile
# Makefile for C Project

CC = gcc
CFLAGS = -Wall -Wextra -Werror -std=c11 -I./include
DEBUG_CFLAGS = -g -O0 -DDEBUG
RELEASE_CFLAGS = -O2 -DNDEBUG

TARGET = project_name
SRC_DIR = src
BUILD_DIR = build
TEST_DIR = tests

# Find all source files
SRCS = $(shell find $(SRC_DIR) -name "*.c")
OBJS = $(SRCS:%.c=$(BUILD_DIR)/%.o)
TEST_SRCS = $(shell find $(TEST_DIR) -name "*.c")
TEST_OBJS = $(TEST_SRCS:%.c=$(BUILD_DIR)/%.o)

# Main targets
all: debug

debug: CFLAGS += $(DEBUG_CFLAGS)
debug: $(BUILD_DIR)/$(TARGET)

release: CFLAGS += $(RELEASE_CFLAGS)
release: $(BUILD_DIR)/$(TARGET)-release

$(BUILD_DIR)/$(TARGET): $(OBJS)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $^ -o $@
	@echo "Build complete: $@"

$(BUILD_DIR)/$(TARGET)-release: $(OBJS)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $^ -o $@
	@echo "Build complete: $@"

# Compile source files
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

# Tests
test: $(BUILD_DIR)/test_runner
	@echo "Running tests..."
	@./$(BUILD_DIR)/test_runner

$(BUILD_DIR)/test_runner: $(filter-out $(BUILD_DIR)/$(SRC_DIR)/core/main.o, $(OBJS)) $(TEST_OBJS)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $^ -o $@

# Clean
clean:
	rm -rf $(BUILD_DIR)
	@echo "Clean complete"

# Run
run: debug
	./$(BUILD_DIR)/$(TARGET)

.PHONY: all debug release test clean run
EOF
    
    # CMakeLists.txt for modern builds
    cat << 'EOF' > CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
project(PROJECT_NAME LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# Options
option(BUILD_TESTS "Build tests" ON)
option(BUILD_EXAMPLES "Build examples" ON)

# Include directories
include_directories(include)

# Main executable
file(GLOB_RECURSE SRC_FILES src/*.c)
add_executable(${PROJECT_NAME} ${SRC_FILES})

# Tests
if(BUILD_TESTS)
    enable_testing()
    file(GLOB_RECURSE TEST_FILES tests/*.c)
    add_executable(test_runner ${TEST_FILES} ${SRC_FILES})
    target_compile_definitions(test_runner PRIVATE UNIT_TESTS)
    add_test(NAME project_tests COMMAND test_runner)
endif()

# Examples
if(BUILD_EXAMPLES)
    file(GLOB_RECURSE EXAMPLE_FILES examples/*.c)
    foreach(example ${EXAMPLE_FILES})
        get_filename_component(example_name ${example} NAME_WE)
        add_executable(${example_name} ${example} ${SRC_FILES})
    endforeach()
endif()
EOF
    
    print_success "C project structure created"
}

create_cpp_structure() {
    print_language "cpp" "Creating C++ project structure..."
    
    # Directory structure
    mkdir -p src/{core,utils,math,graphics} include tests examples build
    
    # Main header
    cat << 'EOF' > include/project.hpp
/**
 * @file project.hpp
 * @brief Main header for PROJECT_NAME
 * @version 1.0.0
 */

#pragma once

#include <iostream>
#include <memory>
#include <vector>
#include <string>
#include <stdexcept>
#include <functional>

namespace project {

// Version information
struct Version {
    static constexpr int MAJOR = 1;
    static constexpr int MINOR = 0;
    static constexpr int PATCH = 0;
    
    static std::string string() {
        return std::to_string(MAJOR) + "." + 
               std::to_string(MINOR) + "." + 
               std::to_string(PATCH);
    }
};

// Custom exception
class ProjectException : public std::runtime_error {
public:
    explicit ProjectException(const std::string& message)
        : std::runtime_error(message) {}
};

// Core class
class Project {
public:
    Project();
    virtual ~Project();
    
    void initialize();
    void shutdown();
    
    std::string getName() const;
    void setName(const std::string& name);
    
    static std::string getVersion();
    
private:
    std::string name_;
    bool initialized_ = false;
};

// Utility functions
namespace utils {
    std::string toUpperCase(const std::string& str);
    std::string toLowerCase(const std::string& str);
    std::vector<std::string> split(const std::string& str, char delimiter);
    bool startsWith(const std::string& str, const std::string& prefix);
    bool endsWith(const std::string& str, const std::string& suffix);
}

} // namespace project
EOF
    
    # Main source
    cat << 'EOF' > src/core/main.cpp
/**
 * @file main.cpp
 * @brief Main entry point
 */

#include "project.hpp"
#include <iostream>

int main(int argc, char** argv) {
    try {
        std::cout << "Starting PROJECT_NAME v" 
                  << project::Project::getVersion() << std::endl;
        
        // Create project instance
        project::Project app;
        app.initialize();
        app.setName("PROJECT_NAME");
        
        std::cout << "Project: " << app.getName() << std::endl;
        
        // Your application logic here
        std::cout << "Application running..." << std::endl;
        
        // Cleanup
        app.shutdown();
        
        std::cout << "Application completed successfully" << std::endl;
        return EXIT_SUCCESS;
        
    } catch (const project::ProjectException& e) {
        std::cerr << "Project error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    } catch (const std::exception& e) {
        std::cerr << "Standard error: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
}
EOF
    
    # Project implementation
    cat << 'EOF' > src/core/project.cpp
#include "project.hpp"

namespace project {

Project::Project() : name_("Unnamed") {
    std::cout << "Project created" << std::endl;
}

Project::~Project() {
    if (initialized_) {
        shutdown();
    }
    std::cout << "Project destroyed" << std::endl;
}

void Project::initialize() {
    if (initialized_) {
        throw ProjectException("Already initialized");
    }
    
    std::cout << "Initializing project..." << std::endl;
    initialized_ = true;
}

void Project::shutdown() {
    if (!initialized_) {
        return;
    }
    
    std::cout << "Shutting down project..." << std::endl;
    initialized_ = false;
}

std::string Project::getName() const {
    return name_;
}

void Project::setName(const std::string& name) {
    if (name.empty()) {
        throw ProjectException("Name cannot be empty");
    }
    name_ = name;
}

std::string Project::getVersion() {
    return Version::string();
}

// Utility implementations
namespace utils {
    
std::string toUpperCase(const std::string& str) {
    std::string result = str;
    std::transform(result.begin(), result.end(), result.begin(), ::toupper);
    return result;
}

std::string toLowerCase(const std::string& str) {
    std::string result = str;
    std::transform(result.begin(), result.end(), result.begin(), ::tolower);
    return result;
}

std::vector<std::string> split(const std::string& str, char delimiter) {
    std::vector<std::string> tokens;
    std::stringstream ss(str);
    std::string token;
    
    while (std::getline(ss, token, delimiter)) {
        tokens.push_back(token);
    }
    
    return tokens;
}

bool startsWith(const std::string& str, const std::string& prefix) {
    if (str.length() < prefix.length()) return false;
    return str.compare(0, prefix.length(), prefix) == 0;
}

bool endsWith(const std::string& str, const std::string& suffix) {
    if (str.length() < suffix.length()) return false;
    return str.compare(str.length() - suffix.length(), suffix.length(), suffix) == 0;
}

} // namespace utils
} // namespace project
EOF
    
    # Test file with Google Test style
    cat << 'EOF' > tests/test_basic.cpp
#include <gtest/gtest.h>
#include "project.hpp"

TEST(ProjectTest, Version) {
    EXPECT_EQ(project::Project::getVersion(), "1.0.0");
}

TEST(ProjectTest, CreateAndDestroy) {
    project::Project app;
    EXPECT_NO_THROW(app.initialize());
    EXPECT_NO_THROW(app.shutdown());
}

TEST(ProjectTest, NameOperations) {
    project::Project app;
    
    // Default name
    EXPECT_EQ(app.getName(), "Unnamed");
    
    // Set name
    app.setName("TestProject");
    EXPECT_EQ(app.getName(), "TestProject");
    
    // Empty name should throw
    EXPECT_THROW(app.setName(""), project::ProjectException);
}

TEST(UtilsTest, StringOperations) {
    using namespace project::utils;
    
    EXPECT_EQ(toUpperCase("hello"), "HELLO");
    EXPECT_EQ(toLowerCase("WORLD"), "world");
    
    auto parts = split("a,b,c", ',');
    ASSERT_EQ(parts.size(), 3);
    EXPECT_EQ(parts[0], "a");
    EXPECT_EQ(parts[1], "b");
    EXPECT_EQ(parts[2], "c");
    
    EXPECT_TRUE(startsWith("hello world", "hello"));
    EXPECT_FALSE(startsWith("hello world", "world"));
    
    EXPECT_TRUE(endsWith("hello world", "world"));
    EXPECT_FALSE(endsWith("hello world", "hello"));
}

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
EOF
    
    # Modern CMakeLists.txt
    cat << 'EOF' > CMakeLists.txt
cmake_minimum_required(VERSION 3.14)
project(PROJECT_NAME LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Project options
option(BUILD_TESTS "Build tests" ON)
option(BUILD_EXAMPLES "Build examples" ON)
option(USE_SYSTEM_GTEST "Use system Google Test" OFF)

# Compiler warnings
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Werror -pedantic)
endif()

# Include directories
include_directories(include)

# Main executable
add_executable(${PROJECT_NAME}
    src/core/main.cpp
    src/core/project.cpp
)

# Tests with Google Test
if(BUILD_TESTS)
    enable_testing()
    
    if(USE_SYSTEM_GTEST)
        find_package(GTest REQUIRED)
    else()
        # Download and build Google Test
        include(FetchContent)
        FetchContent_Declare(
            googletest
            URL https://github.com/google/googletest/archive/refs/tags/v1.13.0.tar.gz
        )
        FetchContent_MakeAvailable(googletest)
    endif()
    
    add_executable(test_runner tests/test_basic.cpp src/core/project.cpp)
    target_link_libraries(test_runner GTest::gtest GTest::gtest_main)
    target_include_directories(test_runner PRIVATE include)
    add_test(NAME ${PROJECT_NAME}_tests COMMAND test_runner)
endif()

# Install target
install(TARGETS ${PROJECT_NAME} DESTINATION bin)
install(DIRECTORY include/ DESTINATION include)
EOF
    
    # Simple Makefile alternative
    cat << 'EOF' > Makefile
# Makefile for C++ Project

CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -Werror -I./include
LDFLAGS = 
DEBUG_CXXFLAGS = -g -O0 -DDEBUG
RELEASE_CXXFLAGS = -O3 -DNDEBUG

TARGET = project_name
SRC_DIR = src
BUILD_DIR = build

# Find source files
SRCS = $(shell find $(SRC_DIR) -name "*.cpp")
OBJS = $(SRCS:%.cpp=$(BUILD_DIR)/%.o)

all: debug

debug: CXXFLAGS += $(DEBUG_CXXFLAGS)
debug: $(BUILD_DIR)/$(TARGET)

release: CXXFLAGS += $(RELEASE_CXXFLAGS)
release: $(BUILD_DIR)/$(TARGET)-release

$(BUILD_DIR)/$(TARGET): $(OBJS)
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "Build complete: $@"

$(BUILD_DIR)/$(TARGET)-release: $(OBJS)
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)
	@echo "Build complete: $@"

$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

run: debug
	./$(BUILD_DIR)/$(TARGET)

.PHONY: all debug release clean run
EOF
    
    print_success "C++ project structure created"
}

create_python_structure() {
    print_language "python" "Creating Python project structure..."
    
    # Directory structure
    mkdir -p src/$crate_name/{core,utils,models,api} tests examples docs
    
    # Setup.cfg (modern Python packaging)
    cat << EOF > setup.cfg
[metadata]
name = $project_name
version = 1.0.0
author = Your Name
author_email = your.email@example.com
description = A Python project
long_description = file: README.md
long_description_content_type = text/markdown
url = https://github.com/username/$project_name
classifiers =
    Programming Language :: Python :: 3
    Programming Language :: Python :: 3.8
    Programming Language :: Python :: 3.9
    Programming Language :: Python :: 3.10
    Programming Language :: Python :: 3.11
    License :: OSI Approved :: MIT License
    Operating System :: OS Independent

[options]
package_dir = 
    = src
packages = find:
python_requires = >=3.8
install_requires =
    # Add your dependencies here
    # requests>=2.25.0
    # numpy>=1.19.0

[options.packages.find]
where = src

[options.extras_require]
dev =
    pytest>=6.0
    pytest-cov>=2.0
    black>=21.0
    flake8>=3.9
    mypy>=0.900
    pre-commit>=2.0
    # Add other dev dependencies

test =
    pytest>=6.0
    pytest-cov>=2.0

[options.entry_points]
console_scripts =
    $crate_name = $crate_name.cli:main

[flake8]
max-line-length = 88
extend-ignore = E203, W503

[mypy]
python_version = 3.8
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
EOF
    
    # Setup.py (minimal, for backward compatibility)
    cat << 'EOF' > setup.py
#!/usr/bin/env python3
"""Setup script for the package."""

from setuptools import setup

if __name__ == "__main__":
    setup()
EOF
    
    # Pyproject.toml (for modern tools)
    cat << EOF > pyproject.toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[tool.black]
line-length = 88
target-version = ['py38']
include = '\.pyi?$'
extend-exclude = '''
/(
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | build
  | dist
)/
'''

[tool.isort]
profile = "black"
multi_line_output = 3
line_length = 88

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "-v --cov=src/$crate_name --cov-report=term-missing"

[tool.coverage.run]
source = ["src/$crate_name"]
omit = ["*/test_*.py", "*/__pycache__/*"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
    "if TYPE_CHECKING:",
]
EOF
    
    # Main __init__.py
    cat << EOF > src/$crate_name/__init__.py
"""
$project_name - A Python project
"""

__version__ = "1.0.0"
__author__ = "Your Name"
__email__ = "your.email@example.com"

from $crate_name.core.main import Project
from $crate_name.utils.helpers import setup_logging

__all__ = ["Project", "setup_logging", "__version__"]
EOF
    
    # Core module
    cat << 'EOF' > src/$crate_name/core/main.py
"""Core module for the project."""

import logging
from typing import Optional, Any
from dataclasses import dataclass
from enum import Enum

logger = logging.getLogger(__name__)


class Status(Enum):
    """Project status."""
    INITIALIZED = "initialized"
    RUNNING = "running"
    STOPPED = "stopped"
    ERROR = "error"


@dataclass
class Config:
    """Project configuration."""
    name: str
    debug: bool = False
    log_level: str = "INFO"
    max_workers: int = 4


class Project:
    """Main project class."""
    
    def __init__(self, config: Optional[Config] = None):
        """Initialize project.
        
        Args:
            config: Project configuration. If None, uses defaults.
        """
        self.config = config or Config(name="Project")
        self.status = Status.INITIALIZED
        self.logger = logging.getLogger(self.__class__.__name__)
        
        self.logger.info(f"Initializing {self.config.name}")
        
    def start(self) -> None:
        """Start the project."""
        if self.status == Status.RUNNING:
            self.logger.warning("Project is already running")
            return
            
        self.status = Status.RUNNING
        self.logger.info(f"Starting {self.config.name}")
        
        # Your startup logic here
        
    def stop(self) -> None:
        """Stop the project."""
        if self.status != Status.RUNNING:
            self.logger.warning("Project is not running")
            return
            
        self.status = Status.STOPPED
        self.logger.info(f"Stopping {self.config.name}")
        
        # Your cleanup logic here

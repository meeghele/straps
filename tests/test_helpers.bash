#!/usr/bin/env bash
# Copyright (c) 2025 Michele Tavella <meeghele@proton.me>
# Licensed under the MIT License. See LICENSE file for details.

# Test helper functions for straps test suite
# This file provides common utilities and data generators for testing

# Set default test domain
TEST_DOMAIN="${TEST_DOMAIN:-example.com}"

# Generate test data
generate_random_string() {
  local length=${1:-10}
  tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
}

generate_random_number() {
  local max=${1:-1000}
  echo $((RANDOM % max))
}

generate_valid_ip() {
  echo "$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"
}

generate_invalid_ip() {
  local type=${1:-"high"}
  case $type in
    "high")
      echo "$((RANDOM % 100 + 256)).$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"
      ;;
    "format")
      echo "$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255))"
      ;;
    "alpha")
      echo "$((RANDOM % 255)).$((RANDOM % 255)).$((RANDOM % 255)).abc"
      ;;
  esac
}

# Test data arrays
setup_test_data() {
  # Valid integers
  export VALID_INTEGERS=("0" "1" "123" "-456" "999999" "-999999")
  
  # Valid unsigned integers
  export VALID_UINTS=("0" "1" "123" "999999" "18446744073709551615")
  
  # Valid floats
  export VALID_FLOATS=("3.14" "-2.718" "0.0" "123.456" "1.23e10" "-4.56e-3")
  
  # Valid strings (non-numeric)
  export VALID_STRINGS=("hello" "world123" "abc def" "test@example.com" "path/to/file")
  
  # Valid IP addresses
  export VALID_IPS=("0.0.0.0" "127.0.0.1" "192.168.1.1" "255.255.255.255" "8.8.8.8")
  
  # Invalid IP addresses
  export INVALID_IPS=("256.1.1.1" "192.168.1" "192.168.1.1.1" "192.168.1.a" "not.an.ip.address")
  
  # Test file extensions
  export FILE_EXTENSIONS=(".txt" ".sh" ".conf" ".log" ".md" ".json" ".xml")
  
  # Common hostnames for testing
  export TEST_HOSTNAMES=("localhost" "$TEST_DOMAIN" "example.com" "1.1.1.1" "8.8.8.8")
  
  # Common ports for testing
  export TEST_PORTS=("22" "53" "80" "443" "8080")
  
  # Invalid ports
  export INVALID_PORTS=("-1" "0" "65536" "99999" "abc" "")
}

# Assertion helpers
assert_function_exists() {
  local func_name="$1"
  if ! declare -f "$func_name" > /dev/null; then
    echo "Function $func_name does not exist"
    return 1
  fi
}

assert_all_functions_exist() {
  local functions=("is_ip" "can_connect_to" "is_numeric" "is_string" "string_starts_with" 
                   "string_ends_with" "string_contains" "folder_exists" "file_exists" 
                   "is_uint" "is_float")
  
  for func in "${functions[@]}"; do
    assert_function_exists "$func" || return 1
  done
}

# Performance measurement helpers
measure_execution_time() {
  local command="$1"
  local iterations="${2:-1}"
  
  local start_time=$(date +%s%N)
  
  for ((i=1; i<=iterations; i++)); do
    eval "$command" >/dev/null 2>&1
  done
  
  local end_time=$(date +%s%N)
  local duration=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
  
  echo "$duration"
}

benchmark_function() {
  local func_name="$1"
  local test_value="$2"
  local iterations="${3:-100}"
  
  local duration
  duration=$(measure_execution_time "$func_name \"$test_value\"" "$iterations")
  
  echo "Function: $func_name, Value: $test_value, Iterations: $iterations, Time: ${duration}ms"
}

# Test environment setup helpers
create_test_environment() {
  local test_dir="${1:-$(mktemp -d)}"
  
  # Create various test files
  echo "test content" > "$test_dir/test.txt"
  echo "#!/bin/bash" > "$test_dir/script.sh"
  chmod +x "$test_dir/script.sh"
  
  # Create empty file
  touch "$test_dir/empty.txt"
  
  # Create hidden file
  echo "hidden content" > "$test_dir/.hidden"
  
  # Create file with spaces
  echo "spaces content" > "$test_dir/file with spaces.txt"
  
  # Create various directories
  mkdir -p "$test_dir/subdir"
  mkdir -p "$test_dir/deep/nested/directory"
  mkdir -p "$test_dir/.hidden_dir"
  
  # Create symlinks
  ln -s "test.txt" "$test_dir/test_link.txt"
  ln -s "subdir" "$test_dir/dir_link"
  ln -s "nonexistent" "$test_dir/broken_link"
  
  echo "$test_dir"
}

cleanup_test_environment() {
  local test_dir="$1"
  if [[ -n "$test_dir" && -d "$test_dir" ]]; then
    rm -rf "$test_dir"
  fi
}

# Data validation helpers
is_valid_test_result() {
  local status="$1"
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

# Network testing helpers
is_network_available() {
  # Check if we can reach a reliable DNS server
  if command -v ping >/dev/null 2>&1; then
    ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1
  else
    # Fallback using our own can_connect_to if ping is not available
    can_connect_to "1.1.1.1" 53 udp 2>/dev/null
  fi
}

skip_if_no_network() {
  if ! is_network_available; then
    skip "Network not available"
  fi
}

# GitHub CI detection
is_running_in_ci() {
  [[ -n "${GITHUB_ACTIONS:-}" ]]
}

skip_if_ci() {
  if is_running_in_ci; then
    skip "Skipping in GitHub CI"
  fi
}

skip_if_ci_with_reason() {
  local reason="$1"
  if is_running_in_ci; then
    skip "Skipping in GitHub CI: $reason"
  fi
}

# Test pattern generators
generate_test_patterns() {
  local type="$1"
  
  case "$type" in
    "numbers")
      echo "0 1 -1 123 -456 999999 -999999"
      ;;
    "floats")
      echo "0.0 3.14 -2.718 1.23e10 -4.56e-3"
      ;;
    "strings")
      echo "hello world test123 abc_def test@example.com"
      ;;
    "ips")
      echo "127.0.0.1 192.168.1.1 0.0.0.0 255.255.255.255 8.8.8.8"
      ;;
    "invalid_ips")
      echo "256.1.1.1 192.168.1 192.168.1.1.1 192.168.1.a"
      ;;
    *)
      echo "Unknown pattern type: $type" >&2
      return 1
      ;;
  esac
}

# Batch testing helpers
run_batch_test() {
  local function_name="$1"
  local test_values="$2"
  local expected_status="$3"
  
  local failures=0
  local total=0
  
  for value in $test_values; do
    ((total++))
    if ! $function_name "$value" >/dev/null 2>&1; then
      local actual_status=$?
    else
      local actual_status=0
    fi
    
    if [[ "$actual_status" -ne "$expected_status" ]]; then
      echo "FAIL: $function_name '$value' returned $actual_status, expected $expected_status"
      ((failures++))
    fi
  done
  
  echo "Batch test: $function_name - $((total - failures))/$total passed"
  return $failures
}

# Stress testing helpers
stress_test_function() {
  local function_name="$1"
  local test_value="$2"
  local iterations="${3:-1000}"
  
  local failures=0
  
  for ((i=1; i<=iterations; i++)); do
    if ! $function_name "$test_value" >/dev/null 2>&1; then
      ((failures++))
    fi
  done
  
  if [[ $failures -gt 0 ]]; then
    echo "Stress test FAILED: $function_name failed $failures/$iterations times"
    return 1
  else
    echo "Stress test PASSED: $function_name succeeded $iterations/$iterations times"
    return 0
  fi
}

# Memory usage monitoring (basic)
monitor_memory_usage() {
  local command="$1"
  local iterations="${2:-100}"
  
  # Get initial memory usage
  local initial_mem
  if command -v ps >/dev/null 2>&1; then
    initial_mem=$(ps -o rss= -p $$)
  else
    initial_mem=0
  fi
  
  # Run the command multiple times
  for ((i=1; i<=iterations; i++)); do
    eval "$command" >/dev/null 2>&1
  done
  
  # Get final memory usage
  local final_mem
  if command -v ps >/dev/null 2>&1; then
    final_mem=$(ps -o rss= -p $$)
  else
    final_mem=0
  fi
  
  local mem_diff=$((final_mem - initial_mem))
  echo "Memory usage change: ${mem_diff}KB after $iterations iterations"
  
  # Return non-zero if memory usage increased significantly (>1MB)
  [[ $mem_diff -lt 1024 ]]
}

# Integration test helpers
test_function_integration() {
  local test_case="$1"
  
  case "$test_case" in
    "url_validation")
      # Test URL components
      local url="https://www.$TEST_DOMAIN:443/software/bash"
      string_contains "$url" "://" && \
      string_starts_with "$url" "https" && \
      string_ends_with "$url" "bash" && \
      string_contains "$url" "$TEST_DOMAIN"
      ;;
    "file_processing")
      # Test file path validation
      local filepath="/usr/local/bin/script.sh"
      string_starts_with "$filepath" "/" && \
      string_ends_with "$filepath" ".sh" && \
      string_contains "$filepath" "/bin/"
      ;;
    "network_config")
      # Test network configuration values
      local ip="192.168.1.100"
      local port="8080"
      is_ip "$ip" && \
      is_uint "$port" && \
      string_starts_with "$ip" "192.168"
      ;;
    *)
      echo "Unknown integration test case: $test_case" >&2
      return 1
      ;;
  esac
}

# Initialize test helpers
init_test_helpers() {
  setup_test_data
  assert_all_functions_exist
}

# Export all helper functions
export -f generate_random_string generate_random_number generate_valid_ip generate_invalid_ip
export -f setup_test_data assert_function_exists assert_all_functions_exist
export -f measure_execution_time benchmark_function
export -f create_test_environment cleanup_test_environment
export -f is_valid_test_result is_network_available skip_if_no_network
export -f is_running_in_ci skip_if_ci skip_if_ci_with_reason
export -f generate_test_patterns run_batch_test stress_test_function
export -f monitor_memory_usage test_function_integration init_test_helpers
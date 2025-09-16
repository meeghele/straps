#!/usr/bin/env bats
# Copyright (c) 2025 Michele Tavella <meeghele@proton.me>
# Licensed under the MIT License. See LICENSE file for details.

load ../harness

setup() {
  # Create test data for performance tests
  TEST_DIR=$(mktemp -d)
  export TEST_DIR
  
  # Generate large test strings
  export LARGE_STRING=$(printf 'a%.0s' {1..10000})
  export VERY_LARGE_STRING=$(printf 'x%.0s' {1..100000})
  
  # Create many test files
  for i in {1..100}; do
    touch "$TEST_DIR/testfile_$i.txt"
  done
  
  # Create many test directories
  for i in {1..50}; do
    mkdir "$TEST_DIR/testdir_$i"
  done
}

teardown() {
  rm -rf "$TEST_DIR"
}

# Performance tests for string functions
@test "string_starts_with performance with large strings" {
  # Test with large string and small pattern
  run string_starts_with "$LARGE_STRING" "aa"
  [ "$status" -eq 0 ]
  
  # Test with very large string
  run string_starts_with "$VERY_LARGE_STRING" "xx"
  [ "$status" -eq 0 ]
  
  # Test with large pattern
  large_pattern=$(printf 'a%.0s' {1..1000})
  run string_starts_with "$LARGE_STRING" "$large_pattern"
  [ "$status" -eq 0 ]
}

@test "string_ends_with performance with large strings" {
  # Test with large string and small pattern
  run string_ends_with "$LARGE_STRING" "aa"
  [ "$status" -eq 0 ]
  
  # Test with very large string
  run string_ends_with "$VERY_LARGE_STRING" "xx"
  [ "$status" -eq 0 ]
  
  # Test with large pattern at end
  large_pattern=$(printf 'a%.0s' {1..1000})
  run string_ends_with "$LARGE_STRING" "$large_pattern"
  [ "$status" -eq 0 ]
}

@test "string_contains performance with large strings" {
  # Test pattern at beginning
  run string_contains "$LARGE_STRING" "aa"
  [ "$status" -eq 0 ]
  
  # Test pattern in middle (worst case for some algorithms)
  middle_pattern="a"
  run string_contains "$LARGE_STRING" "$middle_pattern"
  [ "$status" -eq 0 ]
  
  # Test pattern not found (full scan)
  run string_contains "$LARGE_STRING" "z"
  [ "$status" -eq 1 ]
  
  # Test with very large string
  run string_contains "$VERY_LARGE_STRING" "x"
  [ "$status" -eq 0 ]
}

@test "string functions stress test with repeated calls" {
  # Simulate repeated function calls in a loop-like scenario
  for i in {1..20}; do
    run string_starts_with "test_string_$i" "test"
    [ "$status" -eq 0 ]
    
    run string_ends_with "string_test_$i" "$i"
    [ "$status" -eq 0 ]
    
    run string_contains "test_$i_string" "_$i_"
    [ "$status" -eq 0 ]
  done
}

# Performance tests for numeric functions
@test "numeric functions performance with many calls" {
  # Test is_numeric with various patterns
  for i in {1..100}; do
    run is_numeric "$i"
    [ "$status" -eq 0 ]
  done
  
  # Test with large numbers
  for i in {1..100}; do
    large_num="${i}23456789012345"
    run is_numeric "$large_num"
    [ "$status" -eq 0 ]
  done
}

@test "is_uint performance with large numbers" {
  # Test with progressively larger numbers
  num="1"
  for i in {1..20}; do
    run is_uint "$num"
    [ "$status" -eq 0 ]
    num="${num}0"  # Make number 10x larger each iteration
  done
}

@test "is_float performance with complex patterns" {
  # Test scientific notation performance
  for i in {1..100}; do
    run is_float "1.23e$i"
    [ "$status" -eq 0 ]
    
    run is_float "1.${i}e-10"
    [ "$status" -eq 0 ]
  done
  
  # Test with very long decimal precision
  long_decimal="3.$(printf '1%.0s' {1..1000})"
  run is_float "$long_decimal"
  [ "$status" -eq 0 ]
}

# Performance tests for IP validation
@test "is_ip performance with many IP addresses" {
  # Test with valid IP ranges
  for a in {1..10}; do
    for b in {1..10}; do
      run is_ip "$a.$b.1.1"
      [ "$status" -eq 0 ]
    done
  done
}

@test "is_ip performance with invalid patterns" {
  # Test performance with patterns that require full validation
  for i in {1..100}; do
    # Invalid IPs that might take longer to validate
    run is_ip "256.256.256.$i"
    [ "$status" -eq 1 ]
    
    run is_ip "192.168.1.abc$i"
    [ "$status" -eq 1 ]
  done
}

# Performance tests for filesystem functions
@test "file_exists performance with many files" {
  # Test with existing files
  for i in {1..100}; do
    run file_exists "$TEST_DIR/testfile_$i.txt"
    [ "$status" -eq 0 ]
  done
  
  # Test with non-existing files
  for i in {101..200}; do
    run file_exists "$TEST_DIR/nonexistent_$i.txt"
    [ "$status" -eq 1 ]
  done
}

@test "folder_exists performance with many directories" {
  # Test with existing directories
  for i in {1..50}; do
    run folder_exists "$TEST_DIR/testdir_$i"
    [ "$status" -eq 0 ]
  done
  
  # Test with non-existing directories
  for i in {51..100}; do
    run folder_exists "$TEST_DIR/nonexistent_dir_$i"
    [ "$status" -eq 1 ]
  done
}

@test "filesystem functions with deep directory structures" {
  # Create deep directory structure
  deep_path="$TEST_DIR"
  for i in {1..20}; do
    deep_path="$deep_path/level_$i"
    mkdir -p "$deep_path"
    
    # Test folder_exists at each level
    run folder_exists "$deep_path"
    [ "$status" -eq 0 ]
    
    # Create and test file at each level
    touch "$deep_path/file_$i.txt"
    run file_exists "$deep_path/file_$i.txt"
    [ "$status" -eq 0 ]
  done
}

# Network performance tests (with caution)
@test "can_connect_to performance with multiple connections" {
  # Test multiple rapid connections to known good endpoints
  # Note: Be respectful and don't hammer servers
  
  for i in {1..5}; do
    run can_connect_to "1.1.1.1" 53 udp
    [ "$status" -eq 0 ]
    
    # Small delay to be respectful
    sleep 0.1
  done
}

@test "can_connect_to performance with timeout scenarios" {
  # Test connection attempts to unreachable addresses
  # These should timeout quickly due to /dev/tcp mechanism
  
  for i in {1..10}; do
    run can_connect_to "192.0.2.$i" 12345 tcp  # RFC5737 test network
    [ "$status" -eq 1 ]
  done
}

# Memory usage tests (indirect)
@test "memory efficiency with large data sets" {
  # Test functions don't leak memory or create excessive temporary data
  
  # Create array of large strings
  declare -a large_strings
  for i in {1..5}; do
    large_strings[$i]=$(printf "data_${i}_%.0s" {1..500})
  done
  
  # Test string functions with all large strings
  local i=1
  for str in "${large_strings[@]}"; do
    run string_contains "$str" "data_"
    [ "$status" -eq 0 ]
    
    run string_starts_with "$str" "data_"
    [ "$status" -eq 0 ]
    
    # Test ending - check for the repeating pattern
    run string_contains "$str" "data_${i}_"
    [ "$status" -eq 0 ]
    
    ((i++))
  done
}

# Concurrent-like testing (bash doesn't have true concurrency but we can simulate rapid calls)
@test "rapid sequential function calls" {
  # Simulate rapid successive calls that might happen in scripts
  start_time=$(date +%s%N)
  
  for i in {1..200}; do
    is_numeric "$i" >/dev/null 2>&1
    is_string "test$i" >/dev/null 2>&1
  done
  
  end_time=$(date +%s%N)
  duration=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
  
  # Test should complete in reasonable time (less than 10 seconds = 10000ms)
  # This is a generous timeout to account for system load variations
  [ "$duration" -lt 10000 ]
}

# Performance tests for resource and limit functions
@test "cpu_count returns valid count" {
  run cpu_count
  [ "$status" -eq 0 ]
  [ "$output" -gt 0 ]
  # CPU count should be a positive integer
  [[ "$output" =~ ^[0-9]+$ ]]
}

@test "cpu_count with wrong argument count" {
  run cpu_count "extra"
  [ "$status" -eq 1 ]
}

@test "memory_available_mb returns valid memory" {
  run memory_available_mb
  [ "$status" -eq 0 ]
  [ "$output" -gt 0 ]
  # Memory should be a positive integer (in MB)
  [[ "$output" =~ ^[0-9]+$ ]]
}

@test "memory_available_mb with wrong argument count" {
  run memory_available_mb "extra"
  [ "$status" -eq 1 ]
}

@test "disk_usage_percentage with valid path" {
  run disk_usage_percentage "/"
  [ "$status" -eq 0 ]
  # Usage should be 0-100
  [ "$output" -ge 0 ]
  [ "$output" -le 100 ]
  [[ "$output" =~ ^[0-9]+$ ]]
}

@test "disk_usage_percentage with test directory" {
  run disk_usage_percentage "$TEST_DIR"
  [ "$status" -eq 0 ]
  [ "$output" -ge 0 ]
  [ "$output" -le 100 ]
}

@test "disk_usage_percentage with invalid path" {
  run disk_usage_percentage "/nonexistent/path"
  [ "$status" -eq 1 ]
}

@test "disk_usage_percentage with wrong argument count" {
  run disk_usage_percentage
  [ "$status" -eq 1 ]
  
  run disk_usage_percentage "/" "extra"
  [ "$status" -eq 1 ]
}

@test "load_average_exceeds with valid thresholds" {
  # Test with very high threshold (should return 1)
  run load_average_exceeds "1000.0"
  [ "$status" -eq 1 ]
  
  # Test with very low threshold (likely to return 0)
  run load_average_exceeds "0.01"
  # Don't assert the result since load can vary
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
  
  # Test integer threshold
  run load_average_exceeds "10"
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "load_average_exceeds with invalid thresholds" {
  run load_average_exceeds "invalid"
  [ "$status" -eq 1 ]
  
  run load_average_exceeds "-1.0"
  [ "$status" -eq 1 ]
  
  run load_average_exceeds "abc"
  [ "$status" -eq 1 ]
}

@test "load_average_exceeds with wrong argument count" {
  run load_average_exceeds
  [ "$status" -eq 1 ]
  
  run load_average_exceeds "1.0" "extra"
  [ "$status" -eq 1 ]
}

@test "file_descriptor_limit returns valid limit" {
  run file_descriptor_limit
  [ "$status" -eq 0 ]
  
  # Handle both numeric limits and "unlimited"
  if [[ "$output" == "unlimited" ]]; then
    # "unlimited" is a valid response in some systems (like CI)
    echo "File descriptor limit is unlimited - this is valid"
  else
    # Should be a positive integer
    [ "$output" -gt 0 ]
    [[ "$output" =~ ^[0-9]+$ ]]
  fi
}

@test "file_descriptor_limit with wrong argument count" {
  run file_descriptor_limit "extra"
  [ "$status" -eq 1 ]
}

@test "process_limit returns valid limit" {
  run process_limit
  [ "$status" -eq 0 ]
  
  # Handle both numeric limits and "unlimited"
  if [[ "$output" == "unlimited" ]]; then
    # "unlimited" is a valid response in some systems (like CI)
    echo "Process limit is unlimited - this is valid"
  else
    # Should be a positive integer
    [ "$output" -gt 0 ]
    [[ "$output" =~ ^[0-9]+$ ]]
  fi
}

@test "process_limit with wrong argument count" {
  run process_limit "extra"
  [ "$status" -eq 1 ]
}

@test "resource functions performance test" {
  # Test multiple calls don't degrade performance significantly
  for i in {1..10}; do
    run cpu_count
    [ "$status" -eq 0 ]
    
    run memory_available_mb
    [ "$status" -eq 0 ]
    
    run file_descriptor_limit
    [ "$status" -eq 0 ]
    
    run process_limit
    [ "$status" -eq 0 ]
    
    run disk_usage_percentage "/"
    [ "$status" -eq 0 ]
  done
}

@test "stress test all functions together" {
  # Combined stress test using all functions
  for i in {1..20}; do
    # Numeric tests
    is_numeric "$i" >/dev/null 2>&1
    is_uint "$i" >/dev/null 2>&1
    is_float "$i.5" >/dev/null 2>&1
    is_string "test$i" >/dev/null 2>&1
    
    # String tests
    string_contains "test_string_$i" "string" >/dev/null 2>&1
    string_starts_with "prefix_$i" "prefix" >/dev/null 2>&1
    string_ends_with "suffix_$i" "$i" >/dev/null 2>&1
    
    # IP tests (with valid IPs)
    local ip="192.168.1.$((i % 255 + 1))"
    is_ip "$ip" >/dev/null 2>&1
    
    # Filesystem tests
    file_exists "$TEST_DIR/testfile_$((i % 100 + 1)).txt" >/dev/null 2>&1
    folder_exists "$TEST_DIR/testdir_$((i % 50 + 1))" >/dev/null 2>&1
  done
}
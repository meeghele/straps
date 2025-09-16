#!/usr/bin/env bats
# Copyright (c) 2025 Michele Tavella <meeghele@proton.me>
# Licensed under the MIT License. See LICENSE file for details.

load ../harness

# Set default test domain
TEST_DOMAIN="${TEST_DOMAIN:-example.com}"

# Test functions with wrong number of arguments
@test "functions with no arguments should fail" {
  run is_ip
  [ "$status" -eq 1 ]
  
  run is_numeric
  [ "$status" -eq 1 ]
  
  run is_string
  [ "$status" -eq 1 ]
  
  run is_uint
  [ "$status" -eq 1 ]
  
  run is_float
  [ "$status" -eq 1 ]
  
  run file_exists
  [ "$status" -eq 1 ]
  
  run folder_exists
  [ "$status" -eq 1 ]
}

@test "functions with too many arguments should fail" {
  run is_ip "1.1.1.1" "extra"
  [ "$status" -eq 1 ]
  
  run is_numeric "123" "extra"
  [ "$status" -eq 1 ]
  
  run is_string "hello" "extra"
  [ "$status" -eq 1 ]
  
  run is_uint "123" "extra"
  [ "$status" -eq 1 ]
  
  run is_float "3.14" "extra"
  [ "$status" -eq 1 ]
  
  run file_exists "README.md" "extra"
  [ "$status" -eq 1 ]
  
  run folder_exists "." "extra"
  [ "$status" -eq 1 ]
}

@test "string functions with wrong argument count" {
  run string_starts_with "hello"
  [ "$status" -eq 1 ]
  
  run string_ends_with "hello"
  [ "$status" -eq 1 ]
  
  run string_contains "hello"
  [ "$status" -eq 1 ]
  
  run string_starts_with "hello" "h" "extra"
  [ "$status" -eq 1 ]
  
  run string_ends_with "hello" "o" "extra"
  [ "$status" -eq 1 ]
  
  run string_contains "hello" "ll" "extra"
  [ "$status" -eq 1 ]
}

@test "can_connect_to with wrong argument count" {
  run can_connect_to "$TEST_DOMAIN"
  [ "$status" -eq 1 ]
  
  run can_connect_to "$TEST_DOMAIN" "80"
  [ "$status" -eq 1 ]
  
  run can_connect_to "$TEST_DOMAIN" "80" "tcp" "extra"
  [ "$status" -eq 1 ]
}

# IP address edge cases
@test "is_ip with edge case IP addresses" {
  # Valid edge cases
  run is_ip "0.0.0.0"
  [ "$status" -eq 0 ]
  
  run is_ip "255.255.255.255"
  [ "$status" -eq 0 ]
  
  run is_ip "127.0.0.1"
  [ "$status" -eq 0 ]
  
  # Invalid - too many octets
  run is_ip "192.168.1.1.1"
  [ "$status" -eq 1 ]
  
  # Invalid - too few octets
  run is_ip "192.168.1"
  [ "$status" -eq 1 ]
  
  # Invalid - empty string
  run is_ip ""
  [ "$status" -eq 1 ]
  
  # Leading zeros (accepted by current implementation)
  run is_ip "192.168.001.001"
  [ "$status" -eq 0 ]
  
  # Invalid - non-numeric
  run is_ip "192.168.1.a"
  [ "$status" -eq 1 ]
  
  # Invalid - spaces
  run is_ip "192.168.1.1 "
  [ "$status" -eq 1 ]
  
  run is_ip " 192.168.1.1"
  [ "$status" -eq 1 ]
  
  # Invalid - IPv6 (should fail for IPv4 validator)
  run is_ip "2001:db8::1"
  [ "$status" -eq 1 ]
}

# String operations with edge cases
@test "string operations with empty strings" {
  run string_starts_with "" ""
  [ "$status" -eq 0 ]
  
  run string_ends_with "" ""
  [ "$status" -eq 0 ]
  
  run string_contains "" ""
  [ "$status" -eq 0 ]
  
  run string_starts_with "hello" ""
  [ "$status" -eq 0 ]
  
  run string_ends_with "hello" ""
  [ "$status" -eq 0 ]
  
  run string_contains "hello" ""
  [ "$status" -eq 0 ]
  
  run string_starts_with "" "h"
  [ "$status" -eq 1 ]
  
  run string_ends_with "" "o"
  [ "$status" -eq 1 ]
  
  run string_contains "" "l"
  [ "$status" -eq 1 ]
}

@test "string operations with special characters" {
  # Test with spaces
  run string_starts_with "hello world" "hello "
  [ "$status" -eq 0 ]
  
  run string_ends_with "hello world" " world"
  [ "$status" -eq 0 ]
  
  run string_contains "hello world" "o w"
  [ "$status" -eq 0 ]
  
  # Test with tabs and newlines
  run string_contains "hello	world" "	"
  [ "$status" -eq 0 ]
  
  # Test with special bash characters
  run string_contains "hello\$world" "\$"
  [ "$status" -eq 0 ]
  
  run string_contains "hello*world" "*"
  [ "$status" -eq 0 ]
}

# Numeric validation edge cases
@test "is_numeric with extreme values" {
  # Very large numbers
  run is_numeric "9223372036854775807"  # Maximum 64-bit signed integer
  [ "$status" -eq 0 ]
  
  run is_numeric "-9223372036854775808"  # Minimum 64-bit signed integer
  [ "$status" -eq 0 ]
  
  # Just zero
  run is_numeric "0"
  [ "$status" -eq 0 ]
  
  run is_numeric "-0"
  [ "$status" -eq 0 ]
  
  # Numbers with spaces (should fail)
  run is_numeric " 123"
  [ "$status" -eq 1 ]
  
  run is_numeric "123 "
  [ "$status" -eq 1 ]
  
  run is_numeric "1 23"
  [ "$status" -eq 1 ]
}

@test "is_uint with edge cases" {
  # Zero should be valid uint
  run is_uint "0"
  [ "$status" -eq 0 ]
  
  # Very large positive number
  run is_uint "18446744073709551615"  # Maximum 64-bit unsigned
  [ "$status" -eq 0 ]
  
  # Leading zeros (should be valid)
  run is_uint "0123"
  [ "$status" -eq 0 ]
  
  # Empty string
  run is_uint ""
  [ "$status" -eq 1 ]
  
  # Just plus sign
  run is_uint "+"
  [ "$status" -eq 1 ]
  
  # Decimal point
  run is_uint "123."
  [ "$status" -eq 1 ]
}

@test "is_float with edge cases" {
  # Very small numbers
  run is_float "0.0000000001"
  [ "$status" -eq 0 ]
  
  # Very large exponents
  run is_float "1.23e308"
  [ "$status" -eq 0 ]
  
  run is_float "-1.23e-308"
  [ "$status" -eq 0 ]
  
  # Edge case: just a dot
  run is_float "."
  [ "$status" -eq 1 ]
  
  # Multiple dots
  run is_float "1.2.3"
  [ "$status" -eq 1 ]
  
  # Invalid scientific notation
  run is_float "1.23ee5"
  [ "$status" -eq 1 ]
  
  run is_float "1.23e"
  [ "$status" -eq 1 ]
  
  run is_float "e5"
  [ "$status" -eq 1 ]
}
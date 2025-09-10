#!/usr/bin/env bats
# Copyright (c) 2025 Michele Tavella <meeghele@proton.me>
# Licensed under the MIT License. See LICENSE file for details.

load ../harness

# is_numeric comprehensive tests
@test "is_numeric with positive integers" {
  run is_numeric "0"
  [ "$status" -eq 0 ]
  
  run is_numeric "1"
  [ "$status" -eq 0 ]
  
  run is_numeric "123"
  [ "$status" -eq 0 ]
  
  run is_numeric "999999"
  [ "$status" -eq 0 ]
  
  # Very large numbers
  run is_numeric "9223372036854775807"  # Max 64-bit signed
  [ "$status" -eq 0 ]
}

@test "is_numeric with negative integers" {
  run is_numeric "-1"
  [ "$status" -eq 0 ]
  
  run is_numeric "-123"
  [ "$status" -eq 0 ]
  
  run is_numeric "-999999"
  [ "$status" -eq 0 ]
  
  # Very large negative numbers
  run is_numeric "-9223372036854775808"  # Min 64-bit signed
  [ "$status" -eq 0 ]
}

@test "is_numeric with leading zeros" {
  run is_numeric "0123"
  [ "$status" -eq 0 ]
  
  run is_numeric "00001"
  [ "$status" -eq 0 ]
  
  run is_numeric "-0123"
  [ "$status" -eq 0 ]
  
  run is_numeric "000"
  [ "$status" -eq 0 ]
}

@test "is_numeric with invalid formats" {
  # Floating point numbers (should fail for is_numeric)
  run is_numeric "3.14"
  [ "$status" -eq 1 ]
  
  run is_numeric "1.0"
  [ "$status" -eq 1 ]
  
  run is_numeric "-2.5"
  [ "$status" -eq 1 ]
  
  # Scientific notation (should fail for is_numeric)
  run is_numeric "1e10"
  [ "$status" -eq 1 ]
  
  run is_numeric "2.5e-3"
  [ "$status" -eq 1 ]
  
  # Hexadecimal
  run is_numeric "0x1A"
  [ "$status" -eq 1 ]
  
  run is_numeric "0xFF"
  [ "$status" -eq 1 ]
  
  # Octal
  run is_numeric "0755"
  [ "$status" -eq 0 ]  # This should be valid as it's just digits
}

@test "is_numeric with non-numeric strings" {
  run is_numeric "abc"
  [ "$status" -eq 1 ]
  
  run is_numeric "hello123"
  [ "$status" -eq 1 ]
  
  run is_numeric "123abc"
  [ "$status" -eq 1 ]
  
  run is_numeric "12a34"
  [ "$status" -eq 1 ]
  
  # Special characters
  run is_numeric "+"
  [ "$status" -eq 1 ]
  
  run is_numeric "-"
  [ "$status" -eq 1 ]
  
  run is_numeric "."
  [ "$status" -eq 1 ]
  
  run is_numeric ""
  [ "$status" -eq 1 ]
  
  run is_numeric " "
  [ "$status" -eq 1 ]
}

@test "is_numeric with whitespace" {
  # Leading/trailing spaces should fail
  run is_numeric " 123"
  [ "$status" -eq 1 ]
  
  run is_numeric "123 "
  [ "$status" -eq 1 ]
  
  run is_numeric " 123 "
  [ "$status" -eq 1 ]
  
  # Spaces in middle
  run is_numeric "1 23"
  [ "$status" -eq 1 ]
  
  # Tabs and newlines
  run is_numeric "123\t"
  [ "$status" -eq 1 ]
  
  run is_numeric "\n123"
  [ "$status" -eq 1 ]
}

# is_uint comprehensive tests
@test "is_uint with valid unsigned integers" {
  run is_uint "0"
  [ "$status" -eq 0 ]
  
  run is_uint "1"
  [ "$status" -eq 0 ]
  
  run is_uint "123"
  [ "$status" -eq 0 ]
  
  run is_uint "999999"
  [ "$status" -eq 0 ]
  
  # Very large positive numbers
  run is_uint "18446744073709551615"  # Max 64-bit unsigned
  [ "$status" -eq 0 ]
}

@test "is_uint with leading zeros" {
  run is_uint "0123"
  [ "$status" -eq 0 ]
  
  run is_uint "00001"
  [ "$status" -eq 0 ]
  
  run is_uint "000"
  [ "$status" -eq 0 ]
}

@test "is_uint with invalid values" {
  # Negative numbers
  run is_uint "-1"
  [ "$status" -eq 1 ]
  
  run is_uint "-123"
  [ "$status" -eq 1 ]
  
  run is_uint "-0"
  [ "$status" -eq 1 ]
  
  # Floating point
  run is_uint "3.14"
  [ "$status" -eq 1 ]
  
  run is_uint "1.0"
  [ "$status" -eq 1 ]
  
  # Non-numeric
  run is_uint "abc"
  [ "$status" -eq 1 ]
  
  run is_uint "123abc"
  [ "$status" -eq 1 ]
  
  run is_uint ""
  [ "$status" -eq 1 ]
  
  # Special characters
  run is_uint "+"
  [ "$status" -eq 1 ]
  
  run is_uint "+123"
  [ "$status" -eq 1 ]  # Plus sign should not be allowed
}

# is_float comprehensive tests
@test "is_float with valid basic floats" {
  run is_float "3.14"
  [ "$status" -eq 0 ]
  
  run is_float "-2.718"
  [ "$status" -eq 0 ]
  
  run is_float "0.0"
  [ "$status" -eq 0 ]
  
  run is_float "-0.0"
  [ "$status" -eq 0 ]
  
  run is_float "123.456"
  [ "$status" -eq 0 ]
}

@test "is_float with edge case decimal formats" {
  # Leading decimal point
  run is_float ".123"
  [ "$status" -eq 0 ]
  
  run is_float "-.456"
  [ "$status" -eq 0 ]
  
  # Trailing decimal point
  run is_float "123."
  [ "$status" -eq 1 ]  # Based on current regex, this should fail
  
  run is_float "-123."
  [ "$status" -eq 1 ]
  
  # Just decimal point
  run is_float "."
  [ "$status" -eq 1 ]
  
  run is_float "-."
  [ "$status" -eq 1 ]
}

@test "is_float with scientific notation" {
  # Basic scientific notation
  run is_float "1.23e10"
  [ "$status" -eq 0 ]
  
  run is_float "1.23E10"
  [ "$status" -eq 0 ]
  
  run is_float "-1.23e10"
  [ "$status" -eq 0 ]
  
  run is_float "-1.23E10"
  [ "$status" -eq 0 ]
  
  # With explicit + in exponent
  run is_float "1.23e+10"
  [ "$status" -eq 0 ]
  
  run is_float "1.23E+10"
  [ "$status" -eq 0 ]
  
  # With - in exponent
  run is_float "1.23e-10"
  [ "$status" -eq 0 ]
  
  run is_float "1.23E-10"
  [ "$status" -eq 0 ]
  
  # Integer with scientific notation
  run is_float "123e10"
  [ "$status" -eq 0 ]
  
  run is_float "123E-5"
  [ "$status" -eq 0 ]
}

@test "is_float with invalid scientific notation" {
  # Missing exponent
  run is_float "1.23e"
  [ "$status" -eq 1 ]
  
  run is_float "1.23E"
  [ "$status" -eq 1 ]
  
  # Missing mantissa
  run is_float "e10"
  [ "$status" -eq 1 ]
  
  run is_float "E10"
  [ "$status" -eq 1 ]
  
  # Invalid exponent
  run is_float "1.23e+"
  [ "$status" -eq 1 ]
  
  run is_float "1.23e-"
  [ "$status" -eq 1 ]
  
  run is_float "1.23eabc"
  [ "$status" -eq 1 ]
  
  # Double e
  run is_float "1.23ee10"
  [ "$status" -eq 1 ]
}

@test "is_float with integers (should fail)" {
  run is_float "123"
  [ "$status" -eq 1 ]
  
  run is_float "-456"
  [ "$status" -eq 1 ]
  
  run is_float "0"
  [ "$status" -eq 1 ]
}

@test "is_float with invalid formats" {
  # Multiple decimal points
  run is_float "1.2.3"
  [ "$status" -eq 1 ]
  
  run is_float "1..23"
  [ "$status" -eq 1 ]
  
  # Non-numeric
  run is_float "abc"
  [ "$status" -eq 1 ]
  
  run is_float "1.2abc"
  [ "$status" -eq 1 ]
  
  run is_float "abc1.2"
  [ "$status" -eq 1 ]
  
  # Empty
  run is_float ""
  [ "$status" -eq 1 ]
  
  # Special values (not supported)
  run is_float "inf"
  [ "$status" -eq 1 ]
  
  run is_float "nan"
  [ "$status" -eq 1 ]
  
  run is_float "infinity"
  [ "$status" -eq 1 ]
}

@test "is_float with very large and small numbers" {
  # Very large
  run is_float "1.23e308"
  [ "$status" -eq 0 ]
  
  # Very small
  run is_float "1.23e-308"
  [ "$status" -eq 0 ]
  
  # Extreme precision
  run is_float "3.141592653589793238462643383279"
  [ "$status" -eq 0 ]
}

# is_string tests (inverse of is_numeric)
@test "is_string with non-numeric strings" {
  run is_string "hello"
  [ "$status" -eq 0 ]
  
  run is_string "world123"
  [ "$status" -eq 0 ]
  
  run is_string "123abc"
  [ "$status" -eq 0 ]
  
  run is_string "abc"
  [ "$status" -eq 0 ]
  
  run is_string "3.14"
  [ "$status" -eq 0 ]  # Float is not numeric integer
  
  run is_string ""
  [ "$status" -eq 0 ]  # Empty string is not numeric
  
  run is_string " "
  [ "$status" -eq 0 ]  # Space is not numeric
}

@test "is_string with numeric values (should fail)" {
  run is_string "123"
  [ "$status" -eq 1 ]
  
  run is_string "-456"
  [ "$status" -eq 1 ]
  
  run is_string "0"
  [ "$status" -eq 1 ]
  
  run is_string "0123"
  [ "$status" -eq 1 ]
}

# Cross-function validation tests
@test "numeric function consistency" {
  # Test that functions are mutually exclusive where expected
  
  # Pure integers should pass is_numeric and is_uint (if positive)
  run is_numeric "123"
  [ "$status" -eq 0 ]
  run is_uint "123"
  [ "$status" -eq 0 ]
  run is_float "123"
  [ "$status" -eq 1 ]
  run is_string "123"
  [ "$status" -eq 1 ]
  
  # Negative integers should pass is_numeric but fail is_uint
  run is_numeric "-123"
  [ "$status" -eq 0 ]
  run is_uint "-123"
  [ "$status" -eq 1 ]
  run is_float "-123"
  [ "$status" -eq 1 ]
  run is_string "-123"
  [ "$status" -eq 1 ]
  
  # Floats should pass is_float and is_string but fail others
  run is_numeric "3.14"
  [ "$status" -eq 1 ]
  run is_uint "3.14"
  [ "$status" -eq 1 ]
  run is_float "3.14"
  [ "$status" -eq 0 ]
  run is_string "3.14"
  [ "$status" -eq 0 ]
  
  # Pure strings should only pass is_string
  run is_numeric "hello"
  [ "$status" -eq 1 ]
  run is_uint "hello"
  [ "$status" -eq 1 ]
  run is_float "hello"
  [ "$status" -eq 1 ]
  run is_string "hello"
  [ "$status" -eq 0 ]
}

# Kubernetes resource format tests
@test "is_valid_cpu_request with valid CPU formats" {
  # Millicores
  run is_valid_cpu_request "100m"
  [ "$status" -eq 0 ]
  
  run is_valid_cpu_request "500m"
  [ "$status" -eq 0 ]
  
  run is_valid_cpu_request "1000m"
  [ "$status" -eq 0 ]
  
  # Whole cores
  run is_valid_cpu_request "1"
  [ "$status" -eq 0 ]
  
  run is_valid_cpu_request "2"
  [ "$status" -eq 0 ]
  
  run is_valid_cpu_request "10"
  [ "$status" -eq 0 ]
  
  # Fractional cores
  run is_valid_cpu_request "0.1"
  [ "$status" -eq 0 ]
  
  run is_valid_cpu_request "0.5"
  [ "$status" -eq 0 ]
  
  run is_valid_cpu_request "1.5"
  [ "$status" -eq 0 ]
  
  run is_valid_cpu_request "2.25"
  [ "$status" -eq 0 ]
}

@test "is_valid_cpu_request with invalid CPU formats" {
  # Invalid units
  run is_valid_cpu_request "100c"
  [ "$status" -eq 1 ]
  
  run is_valid_cpu_request "1000u"
  [ "$status" -eq 1 ]
  
  run is_valid_cpu_request "500cores"
  [ "$status" -eq 1 ]
  
  # Negative values
  run is_valid_cpu_request "-100m"
  [ "$status" -eq 1 ]
  
  run is_valid_cpu_request "-1"
  [ "$status" -eq 1 ]
  
  # Non-numeric
  run is_valid_cpu_request "abc"
  [ "$status" -eq 1 ]
  
  run is_valid_cpu_request "m"
  [ "$status" -eq 1 ]
  
  run is_valid_cpu_request "abcm"
  [ "$status" -eq 1 ]
  
  # Empty string
  run is_valid_cpu_request ""
  [ "$status" -eq 1 ]
  
  # Spaces
  run is_valid_cpu_request "100 m"
  [ "$status" -eq 1 ]
  
  run is_valid_cpu_request " 100m"
  [ "$status" -eq 1 ]
}

@test "is_valid_memory_request with valid memory formats" {
  # Bytes (no unit)
  run is_valid_memory_request "1024"
  [ "$status" -eq 0 ]
  
  run is_valid_memory_request "2048"
  [ "$status" -eq 0 ]
  
  # Kibibytes
  run is_valid_memory_request "512Ki"
  [ "$status" -eq 0 ]
  
  run is_valid_memory_request "1024Ki"
  [ "$status" -eq 0 ]
  
  # Mebibytes
  run is_valid_memory_request "128Mi"
  [ "$status" -eq 0 ]
  
  run is_valid_memory_request "512Mi"
  [ "$status" -eq 0 ]
  
  run is_valid_memory_request "1Gi"
  [ "$status" -eq 0 ]
  
  # Gibibytes
  run is_valid_memory_request "2Gi"
  [ "$status" -eq 0 ]
  
  run is_valid_memory_request "4Gi"
  [ "$status" -eq 0 ]
  
  # Tebibytes
  run is_valid_memory_request "1Ti"
  [ "$status" -eq 0 ]
  
  # Decimal units (SI)
  run is_valid_memory_request "1000K"
  [ "$status" -eq 0 ]
  
  run is_valid_memory_request "500M"
  [ "$status" -eq 0 ]
  
  run is_valid_memory_request "2G"
  [ "$status" -eq 0 ]
  
  run is_valid_memory_request "1T"
  [ "$status" -eq 0 ]
}

@test "is_valid_memory_request with invalid memory formats" {
  # Invalid units
  run is_valid_memory_request "128Mb"
  [ "$status" -eq 1 ]
  
  run is_valid_memory_request "512GB"
  [ "$status" -eq 1 ]
  
  run is_valid_memory_request "1000bytes"
  [ "$status" -eq 1 ]
  
  run is_valid_memory_request "512kb"
  [ "$status" -eq 1 ]  # lowercase not allowed
  
  # Negative values
  run is_valid_memory_request "-128Mi"
  [ "$status" -eq 1 ]
  
  run is_valid_memory_request "-1Gi"
  [ "$status" -eq 1 ]
  
  # Non-numeric
  run is_valid_memory_request "abc"
  [ "$status" -eq 1 ]
  
  run is_valid_memory_request "Mi"
  [ "$status" -eq 1 ]
  
  run is_valid_memory_request "abcMi"
  [ "$status" -eq 1 ]
  
  # Empty string
  run is_valid_memory_request ""
  [ "$status" -eq 1 ]
  
  # Spaces
  run is_valid_memory_request "128 Mi"
  [ "$status" -eq 1 ]
  
  run is_valid_memory_request " 128Mi"
  [ "$status" -eq 1 ]
  
  # Decimal with binary units (technically invalid but we might accept)
  run is_valid_memory_request "1.5Mi"
  [ "$status" -eq 1 ]
}

@test "is_valid_image_pull_policy with valid policies" {
  run is_valid_image_pull_policy "Always"
  [ "$status" -eq 0 ]
  
  run is_valid_image_pull_policy "Never"
  [ "$status" -eq 0 ]
  
  run is_valid_image_pull_policy "IfNotPresent"
  [ "$status" -eq 0 ]
}

@test "is_valid_image_pull_policy with invalid policies" {
  # Wrong case
  run is_valid_image_pull_policy "always"
  [ "$status" -eq 1 ]
  
  run is_valid_image_pull_policy "never"
  [ "$status" -eq 1 ]
  
  run is_valid_image_pull_policy "ifnotpresent"
  [ "$status" -eq 1 ]
  
  # Invalid values
  run is_valid_image_pull_policy "Sometimes"
  [ "$status" -eq 1 ]
  
  run is_valid_image_pull_policy "Default"
  [ "$status" -eq 1 ]
  
  run is_valid_image_pull_policy "Auto"
  [ "$status" -eq 1 ]
  
  # Empty string
  run is_valid_image_pull_policy ""
  [ "$status" -eq 1 ]
  
  # Spaces
  run is_valid_image_pull_policy " Always"
  [ "$status" -eq 1 ]
  
  run is_valid_image_pull_policy "Always "
  [ "$status" -eq 1 ]
}
#!/usr/bin/env bats
# Copyright (c) 2025 Michele Tavella <meeghele@proton.me>
# Licensed under the MIT License. See LICENSE file for details.

load ../harness
load test_helpers

@test "check 10 is uint" {
  run is_uint 10
  [ "$status" -eq 0 ]
}

@test "check -10 is not uint" {
  run is_uint -10
  [ "$status" -eq 1 ]
}

@test "check 3.14 is not uint" {
  run is_uint 3.14
  [ "$status" -eq 1 ]
}

@test "check Pi is string" {
  run is_string "Pi"
  [ "$status" -eq 0 ]
}

@test "check 2h is not uint" {
  run is_uint 2h
  [ "$status" -eq 1 ]
}

@test "check domain URL" {
  run is_string           "admin.google.com"
  [ "$status" -eq 0 ]

  run is_numeric          10
  [ "$status" -eq 0 ]

  run string_starts_with  "admin.google.com" "admin"
  [ "$status" -eq 0 ]

  run string_contains     "admin.google.com" "google"
  [ "$status" -eq 0 ]

  run string_ends_with    "admin.google.com" ".com"
  [ "$status" -eq 0 ]
}

@test "check domain IP" {
  run is_string           "192.168.0.1"
  [ "$status" -eq 0 ]

  run string_starts_with  "192.168.0.1" "192."
  [ "$status" -eq 0 ]

  run string_contains     "192.168.0.1" ".168.0"
  [ "$status" -eq 0 ]

  run is_ip               "192.168.1.1"
  [ "$status" -eq 0 ]

  run is_ip               "192.168.0.256"
  [ "$status" -eq 1 ]
}

@test "connect to remote HTTPS" {
  run can_connect_to 204.79.197.200 443 tcp
  [ "$status" -eq 0 ]
}

@test "connect to local SSH" {
  skip_if_ci_with_reason "SSH service not available in CI containers"
  run can_connect_to 127.0.0.1 22 tcp
  [ "$status" -eq 0 ]
}

@test "connect to remote DNS" {
  run can_connect_to 1.1.1.1 53 udp
  [ "$status" -eq 0 ]
}

@test "test filesystem" {
  run file_exists README.md
  [ "$status" -eq 0 ]

  run folder_exists ../straps
  [ "$status" -eq 0 ]
}

@test "TERM is set" {
  run : ${TERM?}
  [ "$status" -eq 0 ]
}

@test "is_numeric with valid integers" {
  run is_numeric 0
  [ "$status" -eq 0 ]

  run is_numeric 123
  [ "$status" -eq 0 ]

  run is_numeric -456
  [ "$status" -eq 0 ]

  run is_numeric 1000
  [ "$status" -eq 0 ]
}

@test "is_numeric with invalid values" {
  run is_numeric 1.23
  [ "$status" -eq 1 ]

  run is_numeric abc
  [ "$status" -eq 1 ]

  run is_numeric " "
  [ "$status" -eq 1 ]

  run is_numeric ""
  [ "$status" -eq 1 ]
}

@test "is_numeric with leading zeros" {
  run is_numeric 0123  # Should still be valid as a number
  [ "$status" -eq 0 ]
}

@test "is_numeric with non-numeric characters" {
  run is_numeric "123abc"
  [ "$status" -eq 1 ]

  run is_numeric "abc123"
  [ "$status" -eq 1 ]
}

@test "is_numeric with special characters" {
  run is_numeric "$((2**31))"  # A large valid number
  [ "$status" -eq 0 ]
}

@test "is_float with valid floats" {
  run is_float 0.1
  [ "$status" -eq 0 ]

  run is_float -3.14
  [ "$status" -eq 0 ]

  run is_float .567
  [ "$status" -eq 0 ]

  run is_float 123.0
  [ "$status" -eq 0 ]

  run is_float -0.999
  [ "$status" -eq 0 ]

  run is_float 2.5e3
  [ "$status" -eq 0 ]

  run is_float -4.2E-2
  [ "$status" -eq 0 ]
}

@test "is_float with invalid values" {
  run is_float 42
  [ "$status" -eq 1 ]

  run is_float -123
  [ "$status" -eq 1 ]

  run is_float "hello"
  [ "$status" -eq 1 ]

  run is_float "12.34.56"
  [ "$status" -eq 1 ]

  run is_float ""
  [ "$status" -eq 1 ]
}

@test "is_float with edge cases" {
  run is_float .0
  [ "$status" -eq 0 ]

  run is_float -0.
  [ "$status" -eq 1 ]

  run is_float 1e10
  [ "$status" -eq 0 ]

  run is_float -2E+5
  [ "$status" -eq 0 ]

  run is_float 3.14E
  [ "$status" -eq 1 ]

  run is_float "3.14e-"
  [ "$status" -eq 1 ]

  run is_float "1.2.3"
  [ "$status" -eq 1 ]
}

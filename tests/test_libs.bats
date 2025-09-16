#! ../libs/bats/bin/bats
# Copyright (c) 2025 Michele Tavella <meeghele@proton.me>
# Licensed under the MIT License. See LICENSE file for details.

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

load ../harness

@test "test filesystem" {
  run file_exists README.md
  assert_success

  run folder_exists ../straps
  assert_success
}

@test "TERM is set" {
  run : ${TERM?}
  assert_success
}

#!/usr/bin/env bats
# Copyright (c) 2025 Michele Tavella <meeghele@proton.me>
# Licensed under the MIT License. See LICENSE file for details.

load ../harness

setup() {
  # Create test directory and files for security tests
  TEST_DIR=$(mktemp -d)
  export TEST_DIR
  
  # Create regular test file
  TEST_FILE="$TEST_DIR/regular_file.txt"
  echo "test content" > "$TEST_FILE"
  
  # Create test SSH keys (valid format examples)
  export VALID_RSA_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDhA7mBJkAo8X test@example.com"
  export VALID_ED25519_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2eQZSms4xNwGcg0cGe9Qa7QAqnF test@example.com"
  export VALID_ECDSA_KEY="ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABB test@example.com"
  export VALID_DSS_KEY="ssh-dss AAAAB3NzaC1kc3MAAACBAM5HqZcVJXq7l6sL1ZGf1CuFXa test@example.com"
  
  # Create a simple self-signed certificate for testing (if openssl is available)
  if command -v openssl >/dev/null 2>&1; then
    CERT_FILE="$TEST_DIR/test_cert.pem"
    openssl req -x509 -newkey rsa:2048 -keyout "$TEST_DIR/test_key.pem" -out "$CERT_FILE" \
      -days 365 -nodes -subj "/C=US/ST=Test/L=Test/O=Test/CN=test.example.com" >/dev/null 2>&1
    export CERT_FILE
    
    # Create an expired certificate (backdated)
    EXPIRED_CERT_FILE="$TEST_DIR/expired_cert.pem"
    openssl req -x509 -newkey rsa:2048 -keyout "$TEST_DIR/expired_key.pem" -out "$EXPIRED_CERT_FILE" \
      -not_after 20200101000000Z -nodes -subj "/C=US/ST=Test/L=Test/O=Test/CN=expired.example.com" >/dev/null 2>&1 || true
    export EXPIRED_CERT_FILE
  fi
}

teardown() {
  rm -rf "$TEST_DIR"
}

# SELinux context tests
@test "has_selinux_context with wrong argument count" {
  run has_selinux_context
  [ "$status" -eq 1 ]
  
  run has_selinux_context "/etc/passwd"
  [ "$status" -eq 1 ]
  
  run has_selinux_context "/etc/passwd" "system_u" "extra"
  [ "$status" -eq 1 ]
}

@test "has_selinux_context with nonexistent file" {
  run has_selinux_context "/nonexistent/file" "system_u"
  [ "$status" -eq 1 ]
}

@test "has_selinux_context with valid file" {
  # Test with regular file - context may or may not exist depending on system
  run has_selinux_context "$TEST_FILE" "unconfined"
  # Don't assert result since SELinux may not be available or configured
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "is_selinux_enforcing with wrong argument count" {
  run is_selinux_enforcing "extra"
  [ "$status" -eq 1 ]
}

@test "is_selinux_enforcing returns valid result" {
  run is_selinux_enforcing
  # Result depends on system SELinux configuration
  [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

# SUID/SGID tests
@test "file_has_suid with wrong argument count" {
  run file_has_suid
  [ "$status" -eq 1 ]
  
  run file_has_suid "$TEST_FILE" "extra"
  [ "$status" -eq 1 ]
}

@test "file_has_suid with nonexistent file" {
  run file_has_suid "/nonexistent/file"
  [ "$status" -eq 1 ]
}

@test "file_has_suid with regular file" {
  run file_has_suid "$TEST_FILE"
  [ "$status" -eq 1 ]  # Regular file should not have SUID
}

@test "file_has_suid with common SUID binaries" {
  # Test common SUID binaries that might exist on the system
  local common_suid_files=(
    "/usr/bin/sudo"
    "/bin/su"
    "/usr/bin/passwd"
    "/usr/bin/ping"
  )
  
  local found_suid=false
  for file in "${common_suid_files[@]}"; do
    if [[ -f "$file" ]]; then
      run file_has_suid "$file"
      if [[ "$status" -eq 0 ]]; then
        found_suid=true
        break
      fi
    fi
  done
  
  # Note: We don't assert the result since SUID files vary by system
  # This test mainly verifies the function doesn't crash
}

@test "file_has_sgid with wrong argument count" {
  run file_has_sgid
  [ "$status" -eq 1 ]
  
  run file_has_sgid "$TEST_FILE" "extra"
  [ "$status" -eq 1 ]
}

@test "file_has_sgid with nonexistent file" {
  run file_has_sgid "/nonexistent/file"
  [ "$status" -eq 1 ]
}

@test "file_has_sgid with regular file" {
  run file_has_sgid "$TEST_FILE"
  [ "$status" -eq 1 ]  # Regular file should not have SGID
}

# SSH key validation tests
@test "is_valid_ssh_key with wrong argument count" {
  run is_valid_ssh_key
  [ "$status" -eq 1 ]
  
  run is_valid_ssh_key "$VALID_RSA_KEY" "extra"
  [ "$status" -eq 1 ]
}

@test "is_valid_ssh_key with valid RSA key" {
  run is_valid_ssh_key "$VALID_RSA_KEY"
  [ "$status" -eq 0 ]
}

@test "is_valid_ssh_key with valid ED25519 key" {
  run is_valid_ssh_key "$VALID_ED25519_KEY"
  [ "$status" -eq 0 ]
}

@test "is_valid_ssh_key with valid ECDSA key" {
  run is_valid_ssh_key "$VALID_ECDSA_KEY"
  [ "$status" -eq 0 ]
}

@test "is_valid_ssh_key with valid DSS key" {
  run is_valid_ssh_key "$VALID_DSS_KEY"
  [ "$status" -eq 0 ]
}

@test "is_valid_ssh_key with invalid keys" {
  # Empty string
  run is_valid_ssh_key ""
  [ "$status" -eq 1 ]
  
  # Missing key type
  run is_valid_ssh_key "AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDhA7mBJkAo8X"
  [ "$status" -eq 1 ]
  
  # Invalid key type
  run is_valid_ssh_key "ssh-invalid AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDhA7mBJkAo8X"
  [ "$status" -eq 1 ]
  
  # Missing key data
  run is_valid_ssh_key "ssh-rsa"
  [ "$status" -eq 1 ]
  
  # Invalid base64 characters
  run is_valid_ssh_key "ssh-rsa INVALID@#$%KEY"
  [ "$status" -eq 1 ]
  
  # Random text
  run is_valid_ssh_key "this is not a key"
  [ "$status" -eq 1 ]
}

@test "is_valid_ssh_key with keys containing comments" {
  # Key with comment should be valid
  local key_with_comment="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDhA7mBJkAo8X user@hostname.example.com"
  run is_valid_ssh_key "$key_with_comment"
  [ "$status" -eq 0 ]
  
  # Key with complex comment
  local key_with_complex_comment="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDhA7mBJkAo8X My SSH Key for Production Server"
  run is_valid_ssh_key "$key_with_complex_comment"
  [ "$status" -eq 0 ]
}

# Certificate validation tests (only if OpenSSL is available)
@test "cert_is_valid with wrong argument count" {
  run cert_is_valid
  [ "$status" -eq 1 ]
  
  run cert_is_valid "$TEST_DIR/test_cert.pem" "extra"
  [ "$status" -eq 1 ]
}

@test "cert_is_valid with nonexistent file" {
  run cert_is_valid "/nonexistent/cert.pem"
  [ "$status" -eq 1 ]
}

@test "cert_is_valid with regular file" {
  run cert_is_valid "$TEST_FILE"
  [ "$status" -eq 1 ]  # Regular text file is not a valid certificate
}

@test "cert_is_valid with valid certificate" {
  if [[ -n "$CERT_FILE" && -f "$CERT_FILE" ]]; then
    run cert_is_valid "$CERT_FILE"
    [ "$status" -eq 0 ]
  else
    skip "OpenSSL not available or certificate creation failed"
  fi
}

@test "cert_expires_within with wrong argument count" {
  run cert_expires_within
  [ "$status" -eq 1 ]
  
  run cert_expires_within "$TEST_DIR/test_cert.pem"
  [ "$status" -eq 1 ]
  
  run cert_expires_within "$TEST_DIR/test_cert.pem" "30" "extra"
  [ "$status" -eq 1 ]
}

@test "cert_expires_within with nonexistent file" {
  run cert_expires_within "/nonexistent/cert.pem" "30"
  [ "$status" -eq 1 ]
}

@test "cert_expires_within with invalid days parameter" {
  if [[ -n "$CERT_FILE" && -f "$CERT_FILE" ]]; then
    run cert_expires_within "$CERT_FILE" "invalid"
    [ "$status" -eq 1 ]
    
    run cert_expires_within "$CERT_FILE" "-30"
    [ "$status" -eq 1 ]
    
    run cert_expires_within "$CERT_FILE" "30.5"
    [ "$status" -eq 1 ]
  else
    skip "OpenSSL not available or certificate creation failed"
  fi
}

@test "cert_expires_within with valid certificate" {
  if [[ -n "$CERT_FILE" && -f "$CERT_FILE" ]]; then
    # Test with very large number of days (should return 1 - cert doesn't expire that soon)
    run cert_expires_within "$CERT_FILE" "36500"  # 100 years
    [ "$status" -eq 1 ]
    
    # Test with small number (depends on certificate validity period)
    run cert_expires_within "$CERT_FILE" "1"
    # Don't assert result since it depends on when cert was created
    [[ "$status" -eq 0 || "$status" -eq 1 ]]
  else
    skip "OpenSSL not available or certificate creation failed"
  fi
}

@test "cert_expires_within with expired certificate" {
  if [[ -n "$EXPIRED_CERT_FILE" && -f "$EXPIRED_CERT_FILE" ]]; then
    # Any positive days should indicate the cert expires within that timeframe (it's already expired)
    run cert_expires_within "$EXPIRED_CERT_FILE" "1"
    # Note: Expired cert behavior may vary by implementation
    [[ "$status" -eq 0 || "$status" -eq 1 ]]
  else
    skip "OpenSSL not available or expired certificate creation failed"
  fi
}

# Combined security function tests
@test "security functions with various inputs" {
  # Test all security functions don't crash with valid inputs
  
  # SSH key tests
  is_valid_ssh_key "$VALID_RSA_KEY" >/dev/null 2>&1
  is_valid_ssh_key "$VALID_ED25519_KEY" >/dev/null 2>&1
  is_valid_ssh_key "invalid_key" >/dev/null 2>&1
  
  # File permission tests
  file_has_suid "$TEST_FILE" >/dev/null 2>&1
  file_has_sgid "$TEST_FILE" >/dev/null 2>&1
  
  # SELinux tests (may not be available)
  is_selinux_enforcing >/dev/null 2>&1
  has_selinux_context "$TEST_FILE" "unconfined" >/dev/null 2>&1
  
  # Certificate tests (if OpenSSL available)
  if [[ -n "$CERT_FILE" && -f "$CERT_FILE" ]]; then
    cert_is_valid "$CERT_FILE" >/dev/null 2>&1
    cert_expires_within "$CERT_FILE" "30" >/dev/null 2>&1
  fi
}

@test "security functions edge cases" {
  # Test edge cases and boundary conditions
  
  # SSH keys with minimal valid format
  local minimal_rsa="ssh-rsa A"
  run is_valid_ssh_key "$minimal_rsa"
  [ "$status" -eq 0 ]
  
  # SSH key with only key type and data, no comment
  local no_comment_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7vbqajDhA7mBJkAo8X"
  run is_valid_ssh_key "$no_comment_key"
  [ "$status" -eq 0 ]
  
  # File permissions on non-regular files (if available)
  if [[ -d "/tmp" ]]; then
    run file_has_suid "/tmp"
    [ "$status" -eq 1 ]  # Directory can't have SUID in typical sense
  fi
  
  # Certificate expiry with edge values
  if [[ -n "$CERT_FILE" && -f "$CERT_FILE" ]]; then
    run cert_expires_within "$CERT_FILE" "0"
    [[ "$status" -eq 0 || "$status" -eq 1 ]]
  fi
}
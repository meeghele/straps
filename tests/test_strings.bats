#!/usr/bin/env bats
# Copyright (c) 2025 Michele Tavella <meeghele@proton.me>
# Licensed under the MIT License. See LICENSE file for details.

load ../harness

# Set default test domain
TEST_DOMAIN="${TEST_DOMAIN:-example.com}"

# string_starts_with tests
@test "string_starts_with with basic patterns" {
  run string_starts_with "hello world" "hello"
  [ "$status" -eq 0 ]
  
  run string_starts_with "hello world" "world"
  [ "$status" -eq 1 ]
  
  run string_starts_with "hello world" "Hello"  # Case sensitive
  [ "$status" -eq 1 ]
  
  # Exact match
  run string_starts_with "hello" "hello"
  [ "$status" -eq 0 ]
  
  # Longer prefix than string
  run string_starts_with "hi" "hello"
  [ "$status" -eq 1 ]
}

@test "string_starts_with with edge cases" {
  # Empty prefix (should always match)
  run string_starts_with "hello" ""
  [ "$status" -eq 0 ]
  
  # Empty string with empty prefix
  run string_starts_with "" ""
  [ "$status" -eq 0 ]
  
  # Empty string with non-empty prefix
  run string_starts_with "" "hello"
  [ "$status" -eq 1 ]
  
  # Single character tests
  run string_starts_with "hello" "h"
  [ "$status" -eq 0 ]
  
  run string_starts_with "hello" "e"
  [ "$status" -eq 1 ]
}

@test "string_starts_with with special characters" {
  # Spaces
  run string_starts_with " hello" " "
  [ "$status" -eq 0 ]
  
  run string_starts_with "hello world" "hello "
  [ "$status" -eq 0 ]
  
  # Special bash characters
  run string_starts_with "\$PATH" "\$"
  [ "$status" -eq 0 ]
  
  run string_starts_with "file*.txt" "file*"
  [ "$status" -eq 0 ]
  
  # Tabs (using literal string)
  run string_starts_with "hello	world" "hello	"
  [ "$status" -eq 0 ]
  
  # Backslashes (simplified)
  run string_starts_with "path/to/file" "path"
  [ "$status" -eq 0 ]
}

# string_ends_with tests
@test "string_ends_with with basic patterns" {
  run string_ends_with "hello world" "world"
  [ "$status" -eq 0 ]
  
  run string_ends_with "hello world" "hello"
  [ "$status" -eq 1 ]
  
  run string_ends_with "hello world" "World"  # Case sensitive
  [ "$status" -eq 1 ]
  
  # Exact match
  run string_ends_with "world" "world"
  [ "$status" -eq 0 ]
  
  # Longer suffix than string
  run string_ends_with "hi" "world"
  [ "$status" -eq 1 ]
}

@test "string_ends_with with edge cases" {
  # Empty suffix (should always match)
  run string_ends_with "hello" ""
  [ "$status" -eq 0 ]
  
  # Empty string with empty suffix
  run string_ends_with "" ""
  [ "$status" -eq 0 ]
  
  # Empty string with non-empty suffix
  run string_ends_with "" "world"
  [ "$status" -eq 1 ]
  
  # Single character tests
  run string_ends_with "hello" "o"
  [ "$status" -eq 0 ]
  
  run string_ends_with "hello" "e"
  [ "$status" -eq 1 ]
}

@test "string_ends_with with special characters" {
  # File extensions
  run string_ends_with "document.pdf" ".pdf"
  [ "$status" -eq 0 ]
  
  run string_ends_with "script.sh" ".sh"
  [ "$status" -eq 0 ]
  
  run string_ends_with "image.jpg" ".png"
  [ "$status" -eq 1 ]
  
  # Trailing spaces
  run string_ends_with "hello " " "
  [ "$status" -eq 0 ]
  
  # Special characters
  run string_ends_with "query?" "?"
  [ "$status" -eq 0 ]
  
  run string_ends_with "list[]" "[]"
  [ "$status" -eq 0 ]
}

# string_contains tests
@test "string_contains with basic patterns" {
  run string_contains "hello world" "hello"
  [ "$status" -eq 0 ]
  
  run string_contains "hello world" "world"
  [ "$status" -eq 0 ]
  
  run string_contains "hello world" "lo wo"
  [ "$status" -eq 0 ]
  
  run string_contains "hello world" "xyz"
  [ "$status" -eq 1 ]
  
  run string_contains "hello world" "Hello"  # Case sensitive
  [ "$status" -eq 1 ]
}

@test "string_contains with edge cases" {
  # Empty substring (should always match)
  run string_contains "hello" ""
  [ "$status" -eq 0 ]
  
  # Empty string with empty substring
  run string_contains "" ""
  [ "$status" -eq 0 ]
  
  # Empty string with non-empty substring
  run string_contains "" "hello"
  [ "$status" -eq 1 ]
  
  # Exact match
  run string_contains "hello" "hello"
  [ "$status" -eq 0 ]
  
  # Longer substring than string
  run string_contains "hi" "hello"
  [ "$status" -eq 1 ]
  
  # Single character
  run string_contains "hello" "e"
  [ "$status" -eq 0 ]
  
  run string_contains "hello" "x"
  [ "$status" -eq 1 ]
}

@test "string_contains with overlapping patterns" {
  # Repeated patterns
  run string_contains "abababab" "abab"
  [ "$status" -eq 0 ]
  
  run string_contains "aaaa" "aa"
  [ "$status" -eq 0 ]
  
  run string_contains "abcabc" "ca"
  [ "$status" -eq 0 ]
  
  # Partial overlaps
  run string_contains "banana" "ana"
  [ "$status" -eq 0 ]
  
  run string_contains "banana" "anan"
  [ "$status" -eq 0 ]
}

@test "string_contains with special characters and patterns" {
  # URLs
  run string_contains "https://www.$TEST_DOMAIN/software" "$TEST_DOMAIN"
  [ "$status" -eq 0 ]
  
  run string_contains "https://www.$TEST_DOMAIN/software" "://"
  [ "$status" -eq 0 ]
  
  # Paths
  run string_contains "/usr/local/bin" "/bin"
  [ "$status" -eq 0 ]
  
  run string_contains "/usr/local/bin" "local"
  [ "$status" -eq 0 ]
  
  # Email-like patterns
  run string_contains "user@domain.com" "@"
  [ "$status" -eq 0 ]
  
  run string_contains "user@domain.com" ".com"
  [ "$status" -eq 0 ]
  
  # Special bash characters
  run string_contains "var=\$HOME/bin" "\$HOME"
  [ "$status" -eq 0 ]
  
  run string_contains "*.txt files" "*.txt"
  [ "$status" -eq 0 ]
  
  # Quotes and escapes
  run string_contains 'echo "hello world"' '"'
  [ "$status" -eq 0 ]
  
  run string_contains "path/to/file" "/"
  [ "$status" -eq 0 ]
}

# Test all string functions with long strings
@test "string functions with long strings" {
  # Create a long string (1000 characters)
  long_string=$(printf 'a%.0s' {1..1000})
  
  run string_starts_with "$long_string" "aaa"
  [ "$status" -eq 0 ]
  
  run string_ends_with "$long_string" "aaa"
  [ "$status" -eq 0 ]
  
  run string_contains "$long_string" "aaa"
  [ "$status" -eq 0 ]
  
  # Test with pattern in middle
  middle_string="$(printf 'a%.0s' {1..500})xyz$(printf 'a%.0s' {1..500})"
  
  run string_contains "$middle_string" "xyz"
  [ "$status" -eq 0 ]
  
  run string_starts_with "$middle_string" "xyz"
  [ "$status" -eq 1 ]
  
  run string_ends_with "$middle_string" "xyz"
  [ "$status" -eq 1 ]
}

# Test unicode and international characters (if supported)
@test "string functions with international characters" {
  # UTF-8 characters
  run string_contains "café" "é"
  [ "$status" -eq 0 ]
  
  run string_starts_with "naïve" "na"
  [ "$status" -eq 0 ]
  
  run string_ends_with "résumé" "é"
  [ "$status" -eq 0 ]
  
  # Additional non-ASCII characters
  run string_contains "Hello ñ World" "ñ"
  [ "$status" -eq 0 ]
}

# Docker tag validation tests
@test "is_valid_docker_tag with valid tags" {
  run is_valid_docker_tag "latest"
  [ "$status" -eq 0 ]
  
  run is_valid_docker_tag "v1.0.0"
  [ "$status" -eq 0 ]
  
  run is_valid_docker_tag "1.2.3"
  [ "$status" -eq 0 ]
  
  run is_valid_docker_tag "stable"
  [ "$status" -eq 0 ]
  
  run is_valid_docker_tag "ubuntu_18.04"
  [ "$status" -eq 0 ]
  
  run is_valid_docker_tag "my-app-v2"
  [ "$status" -eq 0 ]
}

@test "is_valid_docker_tag with invalid tags" {
  # Cannot start with period
  run is_valid_docker_tag ".invalid"
  [ "$status" -eq 1 ]
  
  # Cannot start with dash
  run is_valid_docker_tag "-invalid"
  [ "$status" -eq 1 ]
  
  # Uppercase letters not allowed
  run is_valid_docker_tag "Invalid"
  [ "$status" -eq 1 ]
  
  run is_valid_docker_tag "UPPERCASE"
  [ "$status" -eq 1 ]
  
  # Special characters not allowed
  run is_valid_docker_tag "tag@special"
  [ "$status" -eq 1 ]
  
  run is_valid_docker_tag "tag#hash"
  [ "$status" -eq 1 ]
  
  run is_valid_docker_tag "tag with spaces"
  [ "$status" -eq 1 ]
  
  # Empty tag
  run is_valid_docker_tag ""
  [ "$status" -eq 1 ]
  
  # Too long (>128 chars)
  long_tag=$(printf 'a%.0s' {1..129})
  run is_valid_docker_tag "$long_tag"
  [ "$status" -eq 1 ]
}

# Kubernetes name validation tests
@test "is_valid_k8s_name with valid names" {
  run is_valid_k8s_name "my-app"
  [ "$status" -eq 0 ]
  
  run is_valid_k8s_name "web-server-123"
  [ "$status" -eq 0 ]
  
  run is_valid_k8s_name "nginx"
  [ "$status" -eq 0 ]
  
  run is_valid_k8s_name "a"
  [ "$status" -eq 0 ]
  
  run is_valid_k8s_name "my-service-v2"
  [ "$status" -eq 0 ]
  
  run is_valid_k8s_name "frontend-deployment"
  [ "$status" -eq 0 ]
}

@test "is_valid_k8s_name with invalid names" {
  # Cannot start with hyphen
  run is_valid_k8s_name "-invalid"
  [ "$status" -eq 1 ]
  
  # Cannot end with hyphen
  run is_valid_k8s_name "invalid-"
  [ "$status" -eq 1 ]
  
  # Uppercase not allowed
  run is_valid_k8s_name "Invalid"
  [ "$status" -eq 1 ]
  
  run is_valid_k8s_name "MY-APP"
  [ "$status" -eq 1 ]
  
  # Special characters not allowed
  run is_valid_k8s_name "my_app"
  [ "$status" -eq 1 ]
  
  run is_valid_k8s_name "my.app"
  [ "$status" -eq 1 ]
  
  run is_valid_k8s_name "my@app"
  [ "$status" -eq 1 ]
  
  # Empty name
  run is_valid_k8s_name ""
  [ "$status" -eq 1 ]
  
  # Too long (>253 chars)
  long_name=$(printf 'a%.0s' {1..254})
  run is_valid_k8s_name "$long_name"
  [ "$status" -eq 1 ]
}

# Kubernetes label validation tests
@test "is_valid_label with valid labels" {
  run is_valid_label "app=nginx"
  [ "$status" -eq 0 ]
  
  run is_valid_label "version=1.2.3"
  [ "$status" -eq 0 ]
  
  run is_valid_label "environment=production"
  [ "$status" -eq 0 ]
  
  run is_valid_label "tier=frontend"
  [ "$status" -eq 0 ]
  
  # Key-only labels
  run is_valid_label "debug"
  [ "$status" -eq 0 ]
  
  run is_valid_label "test"
  [ "$status" -eq 0 ]
  
  # Labels with prefixes
  run is_valid_label "example.com/app=myapp"
  [ "$status" -eq 0 ]
  
  run is_valid_label "k8s.io/component=controller"
  [ "$status" -eq 0 ]
}

@test "is_valid_label allows empty values" {
  run is_valid_label "app="
  [ "$status" -eq 0 ]

  run is_valid_label "example.com/component="
  [ "$status" -eq 0 ]
}

@test "is_valid_label with invalid labels" {
  # Value too long
  long_value=$(printf 'a%.0s' {1..64})
  run is_valid_label "app=$long_value"
  [ "$status" -eq 1 ]
  
  # Key too long  
  long_key=$(printf 'a%.0s' {1..64})
  run is_valid_label "${long_key}=value"
  [ "$status" -eq 1 ]
  
  # Invalid characters in key
  run is_valid_label "app@key=value"
  [ "$status" -eq 1 ]
  
  # Invalid characters in value
  run is_valid_label "app=value@invalid"
  [ "$status" -eq 1 ]
  
  # Cannot start with non-alphanumeric
  run is_valid_label "-app=value"
  [ "$status" -eq 1 ]
  
  run is_valid_label ".app=value"
  [ "$status" -eq 1 ]
  
  # Cannot end with non-alphanumeric
  run is_valid_label "app-=value"
  [ "$status" -eq 1 ]
  
  # Empty label
  run is_valid_label ""
  [ "$status" -eq 1 ]
}

@test "is_valid_annotation accepts empty values" {
  run is_valid_annotation "example.com/config="
  [ "$status" -eq 0 ]

  run is_valid_annotation "simple="
  [ "$status" -eq 0 ]
}

# Environment variable name validation tests  
@test "is_valid_env_var_name with valid names" {
  run is_valid_env_var_name "PATH"
  [ "$status" -eq 0 ]
  
  run is_valid_env_var_name "HOME"
  [ "$status" -eq 0 ]
  
  run is_valid_env_var_name "MY_VAR"
  [ "$status" -eq 0 ]
  
  run is_valid_env_var_name "_PRIVATE_VAR"
  [ "$status" -eq 0 ]
  
  run is_valid_env_var_name "APP_VERSION_123"
  [ "$status" -eq 0 ]
  
  run is_valid_env_var_name "a"
  [ "$status" -eq 0 ]
  
  run is_valid_env_var_name "_"
  [ "$status" -eq 0 ]
}

@test "is_valid_env_var_name with invalid names" {
  # Cannot start with digit
  run is_valid_env_var_name "123_VAR"
  [ "$status" -eq 1 ]
  
  # Cannot contain special characters
  run is_valid_env_var_name "MY-VAR"
  [ "$status" -eq 1 ]
  
  run is_valid_env_var_name "MY.VAR"
  [ "$status" -eq 1 ]
  
  run is_valid_env_var_name "MY@VAR"
  [ "$status" -eq 1 ]
  
  run is_valid_env_var_name "MY VAR"
  [ "$status" -eq 1 ]
  
  run is_valid_env_var_name "MY+VAR"
  [ "$status" -eq 1 ]
  
  # Empty name
  run is_valid_env_var_name ""
  [ "$status" -eq 1 ]
  
  # Lowercase (typically env vars are uppercase, but technically valid)
  run is_valid_env_var_name "my_var"
  [ "$status" -eq 0 ]  # This should actually pass
}

# Base64 validation tests
@test "is_base64 with valid base64 strings" {
  # Basic valid base64 strings
  run is_base64 "SGVsbG8gV29ybGQ="
  [ "$status" -eq 0 ]
  
  run is_base64 "dGVzdA=="
  [ "$status" -eq 0 ]
  
  # Base64 without padding
  run is_base64 "SGVsbG8"
  [ "$status" -eq 0 ]
  
  # Empty string (valid)
  run is_base64 ""
  [ "$status" -eq 0 ]
  
  # Long base64 string
  run is_base64 "VGhpcyBpcyBhIGxvbmcgc3RyaW5nIHRvIHRlc3QgYmFzZTY0IGVuY29kaW5nIHdpdGggbXVsdGlwbGUgY2hhcmFjdGVycw=="
  [ "$status" -eq 0 ]
  
  # Base64 with URL-safe characters
  run is_base64 "VGVzdF9zdHJpbmctd2l0aC1zcGVjaWFsLWNoYXJz"
  [ "$status" -eq 0 ]
}

@test "is_base64 with invalid base64 strings" {
  # Invalid characters
  run is_base64 "SGVsbG8@V29ybGQ="
  [ "$status" -eq 1 ]
  
  # Spaces (not allowed)
  run is_base64 "SGVs bG8="
  [ "$status" -eq 1 ]
  
  # Invalid padding (3 or more equals)
  run is_base64 "SGVsbG8==="
  [ "$status" -eq 1 ]
  
  # Padding in middle
  run is_base64 "SGVs=bG8="
  [ "$status" -eq 1 ]
  
  # Invalid characters mixed with valid
  run is_base64 "SGVsbG8#V29ybGQ="
  [ "$status" -eq 1 ]
  
  # Just invalid characters
  run is_base64 "!@#$%^&*()"
  [ "$status" -eq 1 ]
}

# Base32 validation tests
@test "is_base32 with valid base32 strings" {
  # Basic valid base32 strings
  run is_base32 "JBSWY3DPEBLW64TMMQQQ===="
  [ "$status" -eq 0 ]
  
  # Base32 without padding
  run is_base32 "MFRGG43FMZRW63LB"
  [ "$status" -eq 0 ]
  
  # Empty string (valid)
  run is_base32 ""
  [ "$status" -eq 0 ]
  
  # All valid characters
  run is_base32 "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
  [ "$status" -eq 0 ]
  
  # With various padding amounts
  run is_base32 "MFRGG43F========"
  [ "$status" -eq 0 ]
  
  run is_base32 "MFRGG==="
  [ "$status" -eq 0 ]
}

@test "is_base32 with invalid base32 strings" {
  # Invalid characters (lowercase)
  run is_base32 "jbswy3dpeblw64tmmqqq===="
  [ "$status" -eq 1 ]
  
  # Invalid characters (0, 1, 8, 9)
  run is_base32 "JBSWY3DPEBLW64TMMQQ0===="
  [ "$status" -eq 1 ]
  
  run is_base32 "JBSWY3DPEBLW64TMMQQ1===="
  [ "$status" -eq 1 ]
  
  run is_base32 "JBSWY3DPEBLW64TMMQQ8===="
  [ "$status" -eq 1 ]
  
  run is_base32 "JBSWY3DPEBLW64TMMQQ9===="
  [ "$status" -eq 1 ]
  
  # Spaces (not allowed)
  run is_base32 "JBSWY3DP EBLW64TM"
  [ "$status" -eq 1 ]
  
  # Wrong length (not multiple of 8)
  run is_base32 "JBSWY3DPEBLW64T"
  [ "$status" -eq 1 ]
  
  # Too much padding (more than 6)
  run is_base32 "J======="
  [ "$status" -eq 1 ]
  
  # Padding in wrong place
  run is_base32 "JBSWY=DPEBLW64TM"
  [ "$status" -eq 1 ]
  
  # Invalid special characters
  run is_base32 "JBSWY3DP@EBLW64T"
  [ "$status" -eq 1 ]
}

# URL validation tests
@test "is_valid_url with valid URLs" {
  run is_valid_url "https://example.com"
  [ "$status" -eq 0 ]
  
  run is_valid_url "http://example.com"
  [ "$status" -eq 0 ]
  
  run is_valid_url "https://www.example.com"
  [ "$status" -eq 0 ]
  
  run is_valid_url "https://api.example.com/v1/users"
  [ "$status" -eq 0 ]
  
  run is_valid_url "https://example.com:8080/path"
  [ "$status" -eq 0 ]
  
  run is_valid_url "https://subdomain.example.com/path/to/resource"
  [ "$status" -eq 0 ]
  
  run is_valid_url "ftp://files.example.com"
  [ "$status" -eq 0 ]
  
  run is_valid_url "https://example.com/path?query=value"
  [ "$status" -eq 0 ]
}

@test "is_valid_url with invalid URLs" {
  # Missing protocol
  run is_valid_url "example.com"
  [ "$status" -eq 1 ]
  
  run is_valid_url "www.example.com"
  [ "$status" -eq 1 ]
  
  # Invalid protocols
  run is_valid_url "file://example.com"
  [ "$status" -eq 1 ]
  
  run is_valid_url "mailto:user@example.com"
  [ "$status" -eq 1 ]
  
  run is_valid_url "ssh://user@example.com"
  [ "$status" -eq 1 ]
  
  # Missing domain
  run is_valid_url "https://"
  [ "$status" -eq 1 ]
  
  run is_valid_url "http://"
  [ "$status" -eq 1 ]
  
  # Invalid domain characters
  run is_valid_url "https://invalid@domain.com"
  [ "$status" -eq 1 ]
  
  # Empty string
  run is_valid_url ""
  [ "$status" -eq 1 ]
  
  # Just protocol
  run is_valid_url "https"
  [ "$status" -eq 1 ]
}

# API endpoint validation tests
@test "is_valid_api_endpoint with valid endpoints" {
  run is_valid_api_endpoint "https://api.example.com/v1"
  [ "$status" -eq 0 ]
  
  run is_valid_api_endpoint "https://api.example.com/v1/users"
  [ "$status" -eq 0 ]
  
  run is_valid_api_endpoint "http://localhost:8080/api"
  [ "$status" -eq 0 ]
  
  run is_valid_api_endpoint "https://example.com/graphql"
  [ "$status" -eq 0 ]
  
  run is_valid_api_endpoint "https://api.service.com/v2/data/items"
  [ "$status" -eq 0 ]
}

@test "is_valid_api_endpoint with invalid endpoints" {
  # Missing path (API endpoints should have a path)
  run is_valid_api_endpoint "https://api.example.com"
  [ "$status" -eq 1 ]
  
  run is_valid_api_endpoint "http://example.com"
  [ "$status" -eq 1 ]
  
  # Missing protocol
  run is_valid_api_endpoint "api.example.com/v1"
  [ "$status" -eq 1 ]
  
  # Invalid protocols
  run is_valid_api_endpoint "ftp://api.example.com/v1"
  [ "$status" -eq 1 ]
  
  # Empty string
  run is_valid_api_endpoint ""
  [ "$status" -eq 1 ]
}

# Webhook URL validation tests
@test "is_valid_webhook_url with valid webhook URLs" {
  run is_valid_webhook_url "https://hooks.example.com/webhook"
  [ "$status" -eq 0 ]
  
  run is_valid_webhook_url "https://api.service.com/webhooks/123"
  [ "$status" -eq 0 ]
  
  run is_valid_webhook_url "https://example.com/api/webhook/callback"
  [ "$status" -eq 0 ]
  
  run is_valid_webhook_url "https://secure.hooks.com/v1/notify"
  [ "$status" -eq 0 ]
}

@test "is_valid_webhook_url with invalid webhook URLs" {
  # HTTP not allowed (security requirement)
  run is_valid_webhook_url "http://hooks.example.com/webhook"
  [ "$status" -eq 1 ]
  
  # Missing path
  run is_valid_webhook_url "https://hooks.example.com"
  [ "$status" -eq 1 ]
  
  # Missing protocol  
  run is_valid_webhook_url "hooks.example.com/webhook"
  [ "$status" -eq 1 ]
  
  # Invalid protocol
  run is_valid_webhook_url "ftp://hooks.example.com/webhook"
  [ "$status" -eq 1 ]
  
  # Empty string
  run is_valid_webhook_url ""
  [ "$status" -eq 1 ]
}

@test "hash functions handle empty strings" {
  run hash_md5 ""
  [ "$status" -eq 0 ]
  [ "$output" = "d41d8cd98f00b204e9800998ecf8427e" ]

  run hash_sha1 ""
  [ "$status" -eq 0 ]
  [ "$output" = "da39a3ee5e6b4b0d3255bfef95601890afd80709" ]
}

#!/usr/bin/env bats
# Copyright (c) 2025 Michele Tavella <meeghele@proton.me>
# Licensed under the MIT License. See LICENSE file for details.

load ../harness

setup() {
  # Create temporary directory for tests
  TEST_DIR=$(mktemp -d)
  export TEST_DIR
}

teardown() {
  # Clean up temporary directory
  rm -rf "$TEST_DIR"
}

# file_exists tests
@test "file_exists with existing files" {
  # Test with files that should exist
  run file_exists "README.md"
  [ "$status" -eq 0 ]
  
  run file_exists "harness.bash"
  [ "$status" -eq 0 ]
  
  run file_exists "LICENSE"
  [ "$status" -eq 0 ]
  
  run file_exists "Makefile"
  [ "$status" -eq 0 ]
}

@test "file_exists with non-existent files" {
  run file_exists "nonexistent.txt"
  [ "$status" -eq 1 ]
  
  run file_exists "missing_file"
  [ "$status" -eq 1 ]
  
  run file_exists "does_not_exist.conf"
  [ "$status" -eq 1 ]
}

@test "file_exists with directories (should fail)" {
  # Directories should fail file_exists test
  run file_exists "tests"
  [ "$status" -eq 1 ]
  
  run file_exists "."
  [ "$status" -eq 1 ]
  
  run file_exists ".."
  [ "$status" -eq 1 ]
  
  run file_exists "/tmp"
  [ "$status" -eq 1 ]
}

@test "file_exists with temporary test files" {
  # Create temporary files for testing
  echo "test content" > "$TEST_DIR/testfile.txt"
  touch "$TEST_DIR/empty_file"
  
  run file_exists "$TEST_DIR/testfile.txt"
  [ "$status" -eq 0 ]
  
  run file_exists "$TEST_DIR/empty_file"
  [ "$status" -eq 0 ]
  
  # Remove file and test again
  rm "$TEST_DIR/testfile.txt"
  run file_exists "$TEST_DIR/testfile.txt"
  [ "$status" -eq 1 ]
}

@test "file_exists with special file types" {
  # Test with device files (should fail as they're not regular files)
  run file_exists "/dev/null"
  [ "$status" -eq 1 ]
  
  run file_exists "/dev/zero"
  [ "$status" -eq 1 ]
  
  # Test with symlinks
  echo "test" > "$TEST_DIR/target_file.txt"
  ln -s "$TEST_DIR/target_file.txt" "$TEST_DIR/readme_link"
  run file_exists "$TEST_DIR/readme_link"
  [ "$status" -eq 0 ]
  
  # Test with broken symlink
  ln -s "nonexistent_target" "$TEST_DIR/broken_link"
  run file_exists "$TEST_DIR/broken_link"
  [ "$status" -eq 1 ]  # Broken symlink should fail since target doesn't exist
}

@test "file_exists with paths containing spaces" {
  # Create file with spaces in name
  touch "$TEST_DIR/file with spaces.txt"
  
  run file_exists "$TEST_DIR/file with spaces.txt"
  [ "$status" -eq 0 ]
  
  # Test with quoted paths
  run file_exists "$TEST_DIR/file with spaces.txt"
  [ "$status" -eq 0 ]
}

@test "file_exists with relative and absolute paths" {
  # Test with relative paths
  echo "test" > "$TEST_DIR/relative_test.txt"
  cd "$TEST_DIR"
  
  run file_exists "relative_test.txt"
  [ "$status" -eq 0 ]
  
  run file_exists "./relative_test.txt"
  [ "$status" -eq 0 ]
  
  # Test with absolute path
  run file_exists "$TEST_DIR/relative_test.txt"
  [ "$status" -eq 0 ]
  
  cd - > /dev/null
}

@test "file_exists with hidden files" {
  # Create hidden file
  touch "$TEST_DIR/.hidden_file"
  
  run file_exists "$TEST_DIR/.hidden_file"
  [ "$status" -eq 0 ]
  
  # Test with system hidden files
  run file_exists ".gitignore"
  [ "$status" -eq 0 ]
}

# folder_exists tests
@test "folder_exists with existing directories" {
  run folder_exists "tests"
  [ "$status" -eq 0 ]
  
  run folder_exists "."
  [ "$status" -eq 0 ]
  
  run folder_exists ".."
  [ "$status" -eq 0 ]
  
  run folder_exists "/tmp"
  [ "$status" -eq 0 ]
  
  run folder_exists "/usr"
  [ "$status" -eq 0 ]
}

@test "folder_exists with non-existent directories" {
  run folder_exists "nonexistent_dir"
  [ "$status" -eq 1 ]
  
  run folder_exists "/path/does/not/exist"
  [ "$status" -eq 1 ]
  
  run folder_exists "missing_directory"
  [ "$status" -eq 1 ]
}

@test "folder_exists with files (should fail)" {
  # Files should fail folder_exists test
  run folder_exists "README.md"
  [ "$status" -eq 1 ]
  
  run folder_exists "harness.bash"
  [ "$status" -eq 1 ]
  
  run folder_exists "LICENSE"
  [ "$status" -eq 1 ]
}

@test "folder_exists with temporary test directories" {
  # Create temporary directories
  mkdir -p "$TEST_DIR/test_subdir"
  mkdir -p "$TEST_DIR/nested/deep/directory"
  
  run folder_exists "$TEST_DIR/test_subdir"
  [ "$status" -eq 0 ]
  
  run folder_exists "$TEST_DIR/nested"
  [ "$status" -eq 0 ]
  
  run folder_exists "$TEST_DIR/nested/deep"
  [ "$status" -eq 0 ]
  
  run folder_exists "$TEST_DIR/nested/deep/directory"
  [ "$status" -eq 0 ]
  
  # Remove directory and test again
  rmdir "$TEST_DIR/test_subdir"
  run folder_exists "$TEST_DIR/test_subdir"
  [ "$status" -eq 1 ]
}

@test "folder_exists with symlinked directories" {
  # Create directory and symlink to it
  mkdir "$TEST_DIR/real_dir"
  ln -s "$TEST_DIR/real_dir" "$TEST_DIR/linked_dir"
  
  run folder_exists "$TEST_DIR/real_dir"
  [ "$status" -eq 0 ]
  
  run folder_exists "$TEST_DIR/linked_dir"
  [ "$status" -eq 0 ]
  
  # Test with broken directory symlink
  rmdir "$TEST_DIR/real_dir"
  run folder_exists "$TEST_DIR/linked_dir"
  [ "$status" -eq 1 ]  # Broken symlink should fail
}

@test "folder_exists with directories containing spaces" {
  # Create directory with spaces
  mkdir "$TEST_DIR/dir with spaces"
  
  run folder_exists "$TEST_DIR/dir with spaces"
  [ "$status" -eq 0 ]
}

@test "folder_exists with hidden directories" {
  # Create hidden directory
  mkdir "$TEST_DIR/.hidden_dir"
  
  run folder_exists "$TEST_DIR/.hidden_dir"
  [ "$status" -eq 0 ]
  
  # Test with system hidden directories (skip if not available)
  if [[ -d ".git" ]]; then
    run folder_exists ".git"
    [ "$status" -eq 0 ]
  else
    skip ".git directory not available in CI environment"
  fi
}

@test "folder_exists with permission scenarios" {
  # Create directory and test permissions
  mkdir "$TEST_DIR/perm_test"
  
  run folder_exists "$TEST_DIR/perm_test"
  [ "$status" -eq 0 ]
  
  # Remove read permission and test (should still exist)
  chmod 000 "$TEST_DIR/perm_test"
  run folder_exists "$TEST_DIR/perm_test"
  [ "$status" -eq 0 ]  # Directory exists even without permissions
  
  # Restore permissions for cleanup
  chmod 755 "$TEST_DIR/perm_test"
}

# Edge cases for both functions
@test "filesystem functions with empty strings" {
  run file_exists ""
  [ "$status" -eq 1 ]
  
  run folder_exists ""
  [ "$status" -eq 1 ]
}

@test "filesystem functions with whitespace paths" {
  run file_exists " "
  [ "$status" -eq 1 ]
  
  run folder_exists " "
  [ "$status" -eq 1 ]
  
  run file_exists "	"  # Tab character
  [ "$status" -eq 1 ]
  
  run folder_exists "	"  # Tab character
  [ "$status" -eq 1 ]
}

@test "filesystem functions with special characters in paths" {
  # Create files/dirs with special characters
  touch "$TEST_DIR/file@#\$%^.txt"
  mkdir "$TEST_DIR/dir@#\$%^"
  
  run file_exists "$TEST_DIR/file@#\$%^.txt"
  [ "$status" -eq 0 ]
  
  run folder_exists "$TEST_DIR/dir@#\$%^"
  [ "$status" -eq 0 ]
  
  # Test with parentheses
  touch "$TEST_DIR/file(with)parens.txt"
  mkdir "$TEST_DIR/dir(with)parens"
  
  run file_exists "$TEST_DIR/file(with)parens.txt"
  [ "$status" -eq 0 ]
  
  run folder_exists "$TEST_DIR/dir(with)parens"
  [ "$status" -eq 0 ]
}

@test "filesystem functions with very long paths" {
  # Create a deep directory structure
  long_path="$TEST_DIR"
  for i in {1..10}; do
    long_path="$long_path/very_long_directory_name_$i"
  done
  
  mkdir -p "$long_path"
  touch "$long_path/deep_file.txt"
  
  run folder_exists "$long_path"
  [ "$status" -eq 0 ]
  
  run file_exists "$long_path/deep_file.txt"
  [ "$status" -eq 0 ]
}

@test "filesystem functions with unicode filenames" {
  # Test with unicode characters (if supported)
  touch "$TEST_DIR/café.txt"
  mkdir "$TEST_DIR/naïve_dir"
  
  run file_exists "$TEST_DIR/café.txt"
  [ "$status" -eq 0 ]
  
  run folder_exists "$TEST_DIR/naïve_dir"
  [ "$status" -eq 0 ]
}

# Extended filesystem function tests
@test "file_is_executable with executable files" {
  # Create executable file
  touch "$TEST_DIR/executable_file.sh"
  chmod +x "$TEST_DIR/executable_file.sh"
  
  run file_is_executable "$TEST_DIR/executable_file.sh"
  [ "$status" -eq 0 ]
  
  # Test system executable
  run file_is_executable "/bin/bash"
  [ "$status" -eq 0 ]
  
  run file_is_executable "/bin/ls"
  [ "$status" -eq 0 ]
}

@test "file_is_executable with non-executable files" {
  # Create non-executable file
  touch "$TEST_DIR/non_executable.txt"
  chmod -x "$TEST_DIR/non_executable.txt"
  
  run file_is_executable "$TEST_DIR/non_executable.txt"
  [ "$status" -eq 1 ]
  
  # Test with directory (should fail)
  run file_is_executable "$TEST_DIR"
  [ "$status" -eq 1 ]
  
  # Non-existent file
  run file_is_executable "$TEST_DIR/nonexistent"
  [ "$status" -eq 1 ]
}

@test "file_is_readable with readable files" {
  # Create readable file
  touch "$TEST_DIR/readable_file.txt"
  chmod +r "$TEST_DIR/readable_file.txt"
  
  run file_is_readable "$TEST_DIR/readable_file.txt"
  [ "$status" -eq 0 ]
  
  # System files
  run file_is_readable "/etc/passwd"
  [ "$status" -eq 0 ]
}

@test "file_is_readable with non-readable files" {
  # Create non-readable file
  touch "$TEST_DIR/non_readable.txt"
  chmod 000 "$TEST_DIR/non_readable.txt"
  
  # Skip if running as root (permissions don't apply)
  if [[ $EUID -eq 0 ]]; then
    skip "Running as root - file permissions don't restrict access"
  fi
  
  run file_is_readable "$TEST_DIR/non_readable.txt"
  [ "$status" -eq 1 ]
  
  # Directory should fail
  run file_is_readable "$TEST_DIR"
  [ "$status" -eq 1 ]
  
  # Non-existent file
  run file_is_readable "$TEST_DIR/nonexistent"
  [ "$status" -eq 1 ]
}

@test "file_is_writable with writable files" {
  # Create writable file
  touch "$TEST_DIR/writable_file.txt"
  chmod +w "$TEST_DIR/writable_file.txt"
  
  run file_is_writable "$TEST_DIR/writable_file.txt"
  [ "$status" -eq 0 ]
  
  # Test with new file in writable directory
  run file_is_writable "$TEST_DIR/new_file.txt"
  [ "$status" -eq 0 ]
}

@test "file_is_writable with non-writable files" {
  # Create non-writable file
  touch "$TEST_DIR/readonly_file.txt"
  chmod 444 "$TEST_DIR/readonly_file.txt"
  
  # Skip if running as root (permissions don't apply)
  if [[ $EUID -eq 0 ]]; then
    skip "Running as root - file permissions don't restrict access"
  fi
  
  run file_is_writable "$TEST_DIR/readonly_file.txt"
  [ "$status" -eq 1 ]
  
  # Test in non-writable directory (only if not root)
  if [[ $EUID -ne 0 ]]; then
    mkdir "$TEST_DIR/readonly_dir"
    chmod 555 "$TEST_DIR/readonly_dir"
    
    run file_is_writable "$TEST_DIR/readonly_dir/new_file.txt"
    [ "$status" -eq 1 ]
  fi
  
  # Clean up (only if directory was created)
  if [[ -d "$TEST_DIR/readonly_dir" ]]; then
    chmod +w "$TEST_DIR/readonly_dir"
  fi
}

@test "file_is_symlink with symbolic links" {
  # Create file and symlink
  touch "$TEST_DIR/original_file.txt"
  ln -s "$TEST_DIR/original_file.txt" "$TEST_DIR/symlink_file.txt"
  
  run file_is_symlink "$TEST_DIR/symlink_file.txt"
  [ "$status" -eq 0 ]
  
  # Directory symlink
  mkdir "$TEST_DIR/original_dir"
  ln -s "$TEST_DIR/original_dir" "$TEST_DIR/symlink_dir"
  
  run file_is_symlink "$TEST_DIR/symlink_dir"
  [ "$status" -eq 0 ]
  
  # Broken symlink
  ln -s "$TEST_DIR/nonexistent_file" "$TEST_DIR/broken_link"
  
  run file_is_symlink "$TEST_DIR/broken_link"
  [ "$status" -eq 0 ]
}

@test "file_is_symlink with regular files" {
  # Regular file should not be symlink
  touch "$TEST_DIR/regular_file.txt"
  
  run file_is_symlink "$TEST_DIR/regular_file.txt"
  [ "$status" -eq 1 ]
  
  # Directory should not be symlink
  run file_is_symlink "$TEST_DIR"
  [ "$status" -eq 1 ]
  
  # Non-existent file
  run file_is_symlink "$TEST_DIR/nonexistent"
  [ "$status" -eq 1 ]
}

@test "dir_is_empty with empty directories" {
  # Create empty directory
  mkdir "$TEST_DIR/empty_dir"
  
  run dir_is_empty "$TEST_DIR/empty_dir"
  [ "$status" -eq 0 ]
}

@test "dir_is_empty with non-empty directories" {
  # Create directory with file
  mkdir "$TEST_DIR/non_empty_dir"
  touch "$TEST_DIR/non_empty_dir/file.txt"
  
  run dir_is_empty "$TEST_DIR/non_empty_dir"
  [ "$status" -eq 1 ]
  
  # Directory with subdirectory
  mkdir "$TEST_DIR/non_empty_dir2"
  mkdir "$TEST_DIR/non_empty_dir2/subdir"
  
  run dir_is_empty "$TEST_DIR/non_empty_dir2"
  [ "$status" -eq 1 ]
  
  # Directory with hidden files
  mkdir "$TEST_DIR/non_empty_dir3"
  touch "$TEST_DIR/non_empty_dir3/.hidden_file"
  
  run dir_is_empty "$TEST_DIR/non_empty_dir3"
  [ "$status" -eq 1 ]
  
  # Test with file (should fail)
  touch "$TEST_DIR/not_a_dir.txt"
  run dir_is_empty "$TEST_DIR/not_a_dir.txt"
  [ "$status" -eq 1 ]
}

@test "path_is_absolute with absolute paths" {
  run path_is_absolute "/home/user"
  [ "$status" -eq 0 ]
  
  run path_is_absolute "/usr/local/bin"
  [ "$status" -eq 0 ]
  
  run path_is_absolute "/"
  [ "$status" -eq 0 ]
  
  run path_is_absolute "/tmp"
  [ "$status" -eq 0 ]
  
  run path_is_absolute "$TEST_DIR"
  [ "$status" -eq 0 ]
}

@test "path_is_absolute with relative paths" {
  run path_is_absolute "home/user"
  [ "$status" -eq 1 ]
  
  run path_is_absolute "usr/local/bin"
  [ "$status" -eq 1 ]
  
  run path_is_absolute "."
  [ "$status" -eq 1 ]
  
  run path_is_absolute ".."
  [ "$status" -eq 1 ]
  
  run path_is_absolute "./file.txt"
  [ "$status" -eq 1 ]
  
  run path_is_absolute "../parent/file.txt"
  [ "$status" -eq 1 ]
  
  run path_is_absolute "~"
  [ "$status" -eq 1 ]
  
  run path_is_absolute "~/documents"
  [ "$status" -eq 1 ]
  
  # Empty string
  run path_is_absolute ""
  [ "$status" -eq 1 ]
}

@test "path_is_relative with relative paths" {
  run path_is_relative "home/user"
  [ "$status" -eq 0 ]
  
  run path_is_relative "usr/local/bin"
  [ "$status" -eq 0 ]
  
  run path_is_relative "."
  [ "$status" -eq 0 ]
  
  run path_is_relative ".."
  [ "$status" -eq 0 ]
  
  run path_is_relative "./file.txt"
  [ "$status" -eq 0 ]
  
  run path_is_relative "../parent/file.txt"
  [ "$status" -eq 0 ]
  
  run path_is_relative "~"
  [ "$status" -eq 0 ]
  
  run path_is_relative "~/documents"
  [ "$status" -eq 0 ]
  
  # Empty string
  run path_is_relative ""
  [ "$status" -eq 0 ]
}

@test "path_is_relative with absolute paths" {
  run path_is_relative "/home/user"
  [ "$status" -eq 1 ]
  
  run path_is_relative "/usr/local/bin"
  [ "$status" -eq 1 ]
  
  run path_is_relative "/"
  [ "$status" -eq 1 ]
  
  run path_is_relative "/tmp"
  [ "$status" -eq 1 ]
  
  run path_is_relative "$TEST_DIR"
  [ "$status" -eq 1 ]
}

@test "file_size_exceeds with files of various sizes" {
  # Create small file (10 bytes)
  echo -n "1234567890" > "$TEST_DIR/small_file.txt"
  
  run file_size_exceeds "$TEST_DIR/small_file.txt" 5
  [ "$status" -eq 0 ]
  
  run file_size_exceeds "$TEST_DIR/small_file.txt" 15
  [ "$status" -eq 1 ]
  
  run file_size_exceeds "$TEST_DIR/small_file.txt" 10
  [ "$status" -eq 1 ]  # Equal to threshold, should not exceed
  
  # Create larger file (1KB)
  dd if=/dev/zero of="$TEST_DIR/large_file.txt" bs=1024 count=1 2>/dev/null
  
  run file_size_exceeds "$TEST_DIR/large_file.txt" 512
  [ "$status" -eq 0 ]
  
  run file_size_exceeds "$TEST_DIR/large_file.txt" 2048
  [ "$status" -eq 1 ]
  
  # Empty file
  touch "$TEST_DIR/empty_file.txt"
  
  run file_size_exceeds "$TEST_DIR/empty_file.txt" 0
  [ "$status" -eq 1 ]
  
  run file_size_exceeds "$TEST_DIR/empty_file.txt" 1
  [ "$status" -eq 1 ]
}

@test "file_size_exceeds with invalid inputs" {
  touch "$TEST_DIR/test_file.txt"
  
  # Non-existent file
  run file_size_exceeds "$TEST_DIR/nonexistent.txt" 100
  [ "$status" -eq 1 ]
  
  # Invalid threshold
  run file_size_exceeds "$TEST_DIR/test_file.txt" "abc"
  [ "$status" -eq 1 ]
  
  run file_size_exceeds "$TEST_DIR/test_file.txt" "-1"
  [ "$status" -eq 1 ]
  
  run file_size_exceeds "$TEST_DIR/test_file.txt" ""
  [ "$status" -eq 1 ]
  
  # Directory instead of file
  run file_size_exceeds "$TEST_DIR" 100
  [ "$status" -eq 1 ]
}

@test "has_file_extension with various extensions" {
  # Test with dot prefix
  run has_file_extension "document.pdf" ".pdf"
  [ "$status" -eq 0 ]
  
  run has_file_extension "script.sh" ".sh"
  [ "$status" -eq 0 ]
  
  run has_file_extension "image.jpeg" ".jpeg"
  [ "$status" -eq 0 ]
  
  # Test without dot prefix
  run has_file_extension "document.pdf" "pdf"
  [ "$status" -eq 0 ]
  
  run has_file_extension "script.sh" "sh"
  [ "$status" -eq 0 ]
  
  run has_file_extension "image.jpeg" "jpeg"
  [ "$status" -eq 0 ]
  
  # Multiple extensions
  run has_file_extension "archive.tar.gz" ".gz"
  [ "$status" -eq 0 ]
  
  run has_file_extension "archive.tar.gz" "gz"
  [ "$status" -eq 0 ]
  
  # Case sensitivity
  run has_file_extension "IMAGE.JPG" ".JPG"
  [ "$status" -eq 0 ]
  
  run has_file_extension "IMAGE.JPG" ".jpg"
  [ "$status" -eq 1 ]
}

@test "has_file_extension with invalid cases" {
  # Wrong extension
  run has_file_extension "document.pdf" ".txt"
  [ "$status" -eq 1 ]
  
  run has_file_extension "script.sh" "py"
  [ "$status" -eq 1 ]
  
  # No extension
  run has_file_extension "filename" ".txt"
  [ "$status" -eq 1 ]
  
  run has_file_extension "filename" "txt"
  [ "$status" -eq 1 ]
  
  # Empty filename
  run has_file_extension "" ".txt"
  [ "$status" -eq 1 ]
  
  # Empty extension
  run has_file_extension "file.txt" ""
  [ "$status" -eq 0 ]  # Empty extension should match (end of string)
  
  # Just dot
  run has_file_extension "file." "."
  [ "$status" -eq 0 ]
  
  # Partial match
  run has_file_extension "document.pdf" ".pd"
  [ "$status" -eq 1 ]
}

@test "config_key_exists handles literal characters" {
  local config_file="$TEST_DIR/config-with-special-keys.conf"
  cat > "$config_file" <<'EOF'
db.url: postgres://localhost
pattern[key] value
plain_key = something
EOF

  run config_key_exists "$config_file" "db.url"
  [ "$status" -eq 0 ]

  run config_key_exists "$config_file" "pattern[key]"
  [ "$status" -eq 0 ]

  run config_key_exists "$config_file" "missing.key"
  [ "$status" -eq 1 ]
}

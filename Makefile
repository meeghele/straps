# Copyright (c) 2025 Michele Tavella <meeghele@proton.me>
# Licensed under the MIT License. See LICENSE file for details.

default: validate test
all: test_all

# Main targets
.PHONY: test test_straps test_libs test_extended test_extended_fast test_all help install validate clean
.PHONY: test_edge_cases test_network test_strings test_numbers test_filesystem test_performance

test: test_straps test_libs

test_straps: libs
	./libs/bats/libexec/bats tests/$@.bats

test_libs: libs
	./libs/bats/libexec/bats tests/$@.bats

# Extended test suite
test_extended: libs test_edge_cases test_network test_strings test_numbers test_filesystem test_performance

# Extended test suite (fast - without performance tests)
test_extended_fast: libs test_edge_cases test_network test_strings test_numbers test_filesystem

test_edge_cases: libs
	./libs/bats/libexec/bats tests/$@.bats

test_network: libs
	./libs/bats/libexec/bats tests/$@.bats

test_strings: libs
	./libs/bats/libexec/bats tests/$@.bats

test_numbers: libs
	./libs/bats/libexec/bats tests/$@.bats

test_filesystem: libs
	./libs/bats/libexec/bats tests/$@.bats

test_performance: libs
	./libs/bats/libexec/bats tests/$@.bats

# Run all tests (original + extended)
test_all: test test_extended

# Dependencies
.PHONY: libs
libs: libs/bats libs/bats-assert libs/bats-support

libs/bats:
	git clone https://github.com/sstephenson/bats libs/bats

libs/bats-assert:
	git clone https://github.com/ztombol/bats-assert libs/bats-assert

libs/bats-support:
	git clone https://github.com/ztombol/bats-support libs/bats-support

# Installation
install: harness.bash
	@echo "Installing straps harness to /usr/local/bin/straps-harness"
	@sudo cp harness.bash /usr/local/bin/straps-harness
	@sudo chmod +x /usr/local/bin/straps-harness
	@echo "Installation completed. You can now source it with: source /usr/local/bin/straps-harness"

# Validation
validate: harness.bash
	@echo "Validating bash syntax..."
	@bash -n harness.bash && echo "OK: Syntax validation passed"
	@echo "Checking for common issues..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "Running shellcheck analysis..."; \
		shellcheck harness.bash; \
		if [ $$? -eq 0 ]; then \
			echo "OK: No shellcheck issues found"; \
		else \
			echo "WARNING: Shellcheck found issues above"; \
		fi; \
	else \
		echo "WARNING: shellcheck not available, skipping advanced checks"; \
	fi

# Cleanup
clean:
	rm -Rvf libs

# Help
help:
	@echo "Straps - Bash Testing Harness"
	@echo ""
	@echo "Available targets:"
	@echo "  test            - Run basic tests (default)"
	@echo "  test_straps     - Run straps harness tests"
	@echo "  test_libs       - Run library tests"
	@echo "  test_extended   - Run extended test suite"
	@echo "  test_extended_fast - Run extended tests (without performance)"
	@echo "  test_all        - Run all tests (basic + extended)"
	@echo ""
	@echo "Extended test targets:"
	@echo "  test_edge_cases - Run edge case and boundary tests"
	@echo "  test_network    - Run network function tests"
	@echo "  test_strings    - Run string operation tests"
	@echo "  test_numbers    - Run numeric validation tests"
	@echo "  test_filesystem - Run file/folder tests"
	@echo "  test_performance- Run performance tests"
	@echo ""
	@echo "Other targets:"
	@echo "  libs            - Install BATS testing dependencies"
	@echo "  install         - Install harness system-wide"
	@echo "  validate        - Validate bash syntax and check for issues"
	@echo "  clean           - Remove downloaded dependencies"
	@echo "  help            - Show this help message"

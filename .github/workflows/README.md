# GitHub Actions Workflows

This directory contains the CI/CD workflows for the Straps project.

## Workflows

### 1. `ci.yml` - Main CI Pipeline
**Triggers:** Push and PR to main/develop/feat/chore/fix branches, manual dispatch

**What it does:**
- ✅ Runs `make all` - Executes all 187+ test cases
- ✅ Runs `make validate` - Performs syntax and ShellCheck validation  
- 🔄 Tests across multiple Ubuntu and Fedora distributions (ubuntu:latest, ubuntu:rolling, fedora:latest)
- 📊 Provides comprehensive test reporting

**Test Categories Covered:**
- Numbers & validation functions
- Network connectivity tests
- String manipulation functions  
- Filesystem operations
- Performance benchmarks
- Edge cases and error handling

### 2. `pr-checks.yml` - Pull Request Quality Gates
**Triggers:** PRs to main/develop branches

**What it does:**
- 🧪 Quality assurance checks
- 🔒 Security scanning with ShellCheck
- 🕵️ Hardcoded secrets detection
- 📋 Generates detailed test reports

## Local Testing

Before pushing, ensure your changes pass locally:

```bash
# Run all tests (187+ test cases)
make all

# Run validation checks
make validate

# Individual test suites
make test_strings
make test_network
make test_filesystem
# etc.
```

## CI Status

The CI pipeline ensures:
- All bash functions work correctly
- No syntax errors in shell scripts
- Code follows shellcheck best practices
- No security vulnerabilities detected
- Compatible across different Ubuntu versions

## Badge

Add this to your README.md:
```markdown
[![CI](https://github.com/username/straps/workflows/straps-ci/badge.svg)](https://github.com/username/straps/actions)
```
[![CI](https://github.com/meeghele/straps/actions/workflows/ci.yml/badge.svg)](https://github.com/meeghele/straps/actions)
[![Bash 4.0+](https://img.shields.io/badge/bash-4.0+-green.svg)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

# Straps

A comprehensive Bash testing harness providing 80+ utility functions for cloud-native development, Docker containers, Kubernetes, system administration, security validation, and DevOps automation.

<div align="center">
  <img src="images/straps_512.png" alt="Straps Logo" width="200"/>
</div>

## Warning 

This test suite has been accumulated over many years and was released on GitHub in September 2025. Further testing might be necessary for your specific use cases.

## Features

### Core Functionality
- **Data Type Validation**: Integers, floats, strings, unsigned integers
- **String Operations**: Pattern matching (starts with, ends with, contains)
- **Network Testing**: Connectivity checks with TCP/UDP protocols and 3-second timeout
- **File System Operations**: File/directory existence, permissions, and properties

### Cloud-Native & DevOps
- **Docker & Containers**: Container status, image validation, port exposure, volumes, networks
- **Kubernetes**: Resource naming, labels, annotations, namespaces, resource requests
- **Service Discovery**: Port monitoring, DNS resolution, health checks, FQDN validation
- **Process & System Management**: Process monitoring, user/group validation, systemd integration

### Security & Configuration
- **Environment & Config**: Environment variables, base64/base32 encoding validation
- **Security Features**: SSL/TLS certificates, SSH keys, file permissions, SELinux contexts
- **Network Security**: IPv6, CIDR notation, MAC addresses, private/loopback IP detection
- **Resource Monitoring**: CPU/memory usage, disk space, system load, process limits

### Integration & APIs
- **URL & API Testing**: URL validation, HTTP response codes, webhook endpoints
- **BATS Integration**: Seamless integration with Bash Automated Testing System
- **Cross-Platform**: Multiple tool fallbacks for maximum compatibility

## Functions

Straps provides **83 functions** organized into 10 categories for comprehensive system testing and validation.

### Core Data Type Validation
- `is_numeric(value)` - Check if value is a signed integer
- `is_uint(value)` - Check if value is an unsigned integer (positive)
- `is_float(value)` - Check if value is a floating point number
- `is_string(value)` - Check if value is a string (non-numeric)

### String Operations
- `string_starts_with(string, prefix)` - Check if string starts with prefix
- `string_ends_with(string, suffix)` - Check if string ends with suffix
- `string_contains(string, substring)` - Check if string contains substring

### Core Network & File System
- `can_connect_to(host, port, protocol)` - Test network connectivity (TCP/UDP, UDP requires `nc`)
- `is_ip(address)` - Validate IPv4 address format
- `file_exists(path)` - Check if file exists
- `folder_exists(path)` - Check if directory exists

### Docker & Container Functions
- `is_docker_running()` - Check if Docker daemon is running
- `container_exists(name)` - Check if container exists
- `container_is_running(name)` - Check if container is running
- `image_exists(image:tag)` - Check if Docker image exists locally
- `is_valid_docker_tag(tag)` - Validate Docker tag format
- `port_is_exposed(container, port)` - Check if port is exposed
- `volume_exists(volume_name)` - Check if Docker volume exists
- `network_exists(network_name)` - Check if Docker network exists

### Kubernetes & Cloud-Native Functions
- `is_valid_k8s_name(name)` - Validate Kubernetes resource naming
- `is_valid_label(label)` - Validate Kubernetes label format
- `is_valid_annotation(annotation)` - Validate annotation format
- `namespace_exists(namespace)` - Check if K8s namespace exists
- `is_valid_cpu_request(value)` - Validate CPU resource format
- `is_valid_memory_request(value)` - Validate memory format
- `is_valid_image_pull_policy(policy)` - Validate pull policy values

### Port & Service Discovery Functions
- `port_is_listening(port, [host])` - Check if port is listening
- `port_in_range(port)` - Validate port is in valid range (1-65535)
- `is_privileged_port(port)` - Check if port < 1024
- `service_is_healthy(url)` - Basic HTTP health check
- `dns_resolves(hostname)` - Check DNS resolution
- `is_valid_fqdn(fqdn)` - Validate fully qualified domain name

### Environment & Configuration Functions
- `env_var_exists(var_name)` - Check if environment variable is set
- `env_var_not_empty(var_name)` - Check env var exists and not empty
- `is_valid_env_var_name(name)` - Validate environment variable naming
- `is_base64(string)` - Check if string is valid base64 encoding
- `is_base32(string)` - Check if string is valid base32 encoding
- `hash_md5(string|[-f file])` - Compute MD5 hash of string or file
- `hash_sha1(string|[-f file])` - Compute SHA1 hash of string or file
- `config_key_exists(file, key)` - Check if key exists in config file

### Process & System Functions
- `process_exists(name)` - Check if process is running
- `pid_exists(pid)` - Check if PID exists
- `user_exists(username)` - Check if user exists
- `group_exists(groupname)` - Check if group exists
- `command_exists(command)` - Check if command is available
- `is_root()` - Check if running as root
- `has_capability(cap)` - Check for Linux capabilities
- `systemd_unit_exists(unit)` - Check systemd unit exists
- `systemd_unit_active(unit)` - Check if systemd unit is active

### File System Extended Functions
- `file_is_executable(file)` - Check if file is executable
- `file_is_readable(file)` - Check if file is readable
- `file_is_writable(file)` - Check if file is writable
- `file_is_symlink(file)` - Check if file is symlink
- `dir_is_empty(dir)` - Check if directory is empty
- `path_is_absolute(path)` - Check if path is absolute
- `path_is_relative(path)` - Check if path is relative
- `file_size_exceeds(file, size)` - Check file size threshold
- `has_file_extension(file, ext)` - Check file extension

### Network Extended Functions
- `is_ipv6(address)` - Validate IPv6 address
- `is_cidr(notation)` - Validate CIDR notation
- `is_mac_address(mac)` - Validate MAC address format
- `is_valid_hostname(hostname)` - Validate hostname format
- `subnet_contains_ip(subnet, ip)` - Check if IP is in subnet
- `is_private_ip(ip)` - Check if IP is in private range
- `is_loopback_ip(ip)` - Check if IP is loopback

### Resource & System Monitoring Functions
- `cpu_count()` - Get CPU core count
- `memory_available_mb()` - Get available memory in MB
- `disk_usage_percentage(path)` - Get disk usage percentage
- `load_average_exceeds(threshold)` - Check system load
- `file_descriptor_limit()` - Get file descriptor limit
- `process_limit()` - Get process limit

### Security & Permissions Functions
- `has_selinux_context(file, context)` - Check SELinux context
- `is_selinux_enforcing()` - Check SELinux mode
- `file_has_suid(file)` - Check SUID bit
- `file_has_sgid(file)` - Check SGID bit
- `is_valid_ssh_key(key)` - Validate SSH key format
- `cert_is_valid(cert_file)` - Basic certificate validation
- `cert_expires_within(cert_file, days)` - Check certificate expiry

### URL & API Functions
- `is_valid_url(url)` - Validate URL format
- `url_is_reachable(url)` - Check URL accessibility
- `is_valid_api_endpoint(url)` - Validate API endpoint format
- `response_code_is(url, code)` - Check HTTP response code
- `is_valid_webhook_url(url)` - Validate webhook URL format

## Installation

Clone the repository:
```bash
git clone https://github.com/meeghele/straps.git
cd straps
```

Install dependencies:
```bash
make libs
```

## Usage

### As a Library

Source the harness in your bash scripts:
```bash
#!/usr/bin/env bash
source path/to/straps/harness.bash

# Basic validation examples
if is_ip "1.1.1.1"; then
    echo "Valid IP address"
fi

if can_connect_to "example.com" 80 tcp; then
    echo "Can reach example.com"
fi

if is_numeric "123"; then
    echo "It's a number"
fi
```

### Cloud-Native & DevOps Usage

```bash
#!/usr/bin/env bash
source path/to/straps/harness.bash

# Docker container health check
if is_docker_running && container_is_running "web-server"; then
    echo "Web server container is running"

    if port_is_exposed "web-server" 80; then
        echo "Port 80 is exposed"
    fi
fi

# Kubernetes resource validation
if is_valid_k8s_name "$APP_NAME" && is_valid_label "app=$APP_NAME"; then
    echo "Valid Kubernetes configuration"
fi

# System resource monitoring
if load_average_exceeds 2.0; then
    echo "High system load detected"
fi

# Security checks
if cert_expires_within "/etc/ssl/cert.pem" 30; then
    echo "Certificate expires within 30 days - renewal needed"
fi
```

### With BATS Testing

```bash
#!/usr/bin/env bats

load path/to/straps/harness

@test "validate IP address" {
    run is_ip "1.1.1.1"
    [ "$status" -eq 0 ]
}

@test "check string operations" {
    run string_starts_with "hello world" "hello"
    [ "$status" -eq 0 ]

    run string_contains "hello world" "world"
    [ "$status" -eq 0 ]
}
```

## Testing

Straps includes a comprehensive test suite with 80+ test cases covering all functions and edge cases.

### Quick Testing

Run the basic test suite:
```bash
make test
```

Or simply:
```bash
make
```

### Comprehensive Testing

Run all tests including extended test suite:
```bash
make test_all
```

Run extended tests only (faster - excludes network/performance):
```bash
make test_extended_fast
```

### Individual Test Categories

Run specific test categories:
```bash
make test_straps           # Original harness tests
make test_libs             # Library functionality tests
make test_edge_cases       # Boundary and edge case tests
make test_network          # Network connectivity tests
make test_strings          # String operation tests
make test_numbers          # Numeric validation tests
make test_filesystem       # File/folder operation tests
make test_performance      # Performance and stress tests
```

#### Network-Dependent Checks

Tests that reach the public internet are disabled by default to keep the suite hermetic. Enable them explicitly when needed:

```bash
STRAPS_RUN_NETWORK_TESTS=1 make test_network
STRAPS_RUN_NETWORK_TESTS=1 make test_all
```

### Test Organization & Structure

Straps uses a modular test architecture organized into specialized test suites:

#### Test Categories

- **Basic Tests** (`test_straps`, `test_libs`) - 22 tests
  - Core functionality validation for original harness functions
  - Library integration and dependency verification
  - Basic smoke tests for essential operations

- **Extended Test Suite** - 60+ additional tests covering new functionality
  - **Edge Cases** (`test_edge_cases`) - 10 tests: Boundary conditions, error handling, malformed input
  - **Network Tests** (`test_network`) - 11 tests: IP validation, connectivity testing, DNS resolution
  - **String Tests** (`test_strings`) - 12 tests: Pattern matching, format validation, encoding checks
  - **Numeric Tests** (`test_numbers`) - 19 tests: Data type validation, range checking, format parsing
  - **Filesystem Tests** (`test_filesystem`) - 21 tests: File operations, permissions, path validation
  - **Performance Tests** (`test_performance`) - 10+ tests: Stress testing, load validation, resource limits

#### Test File Organization

```
tests/
├── test_straps.bats       # Original harness functionality tests
├── test_libs.bats         # Library and dependency tests
├── test_edge_cases.bats   # Boundary condition and error tests
├── test_network.bats      # Network connectivity and validation tests
├── test_strings.bats      # String operation and format tests
├── test_numbers.bats      # Numeric validation and type tests
├── test_filesystem.bats   # File/directory operation tests
├── test_performance.bats  # Performance and resource tests
└── test_helpers.bash      # Shared test utilities and data generators
```

#### Test Categories by Function Type

- **Core Functions**: Tested in `test_straps.bats` and `test_libs.bats`
- **Docker/Container**: Argument validation covered in `test_edge_cases.bats` (no live Docker dependency required)
- **Kubernetes/Cloud**: Format validation tests in `test_strings.bats` and `test_numbers.bats`
- **Security Functions**: Permission and format tests across multiple suites
- **System Resources**: Resource limit tests in `test_performance.bats`
- **Network Extended**: Protocol validation in `test_network.bats` (live checks optional)

### Test Dependencies

Tests require BATS (Bash Automated Testing System):
```bash
make libs          # Install BATS and testing dependencies
```

### Test Configuration

The test suite uses environment variables for configuration:

- **TEST_DOMAIN**: Domain used for network connectivity tests (default: `example.com`)

#### Recommended Test Domains

For ethical testing practices, use IANA-reserved example domains:
- `example.com` (default)
- `example.net`
- `example.org`

These domains are specifically reserved by RFC 2606 for testing and documentation purposes, ensuring you don't inadvertently test against someone else's production systems.

Examples:
```bash
TEST_DOMAIN=example.net make test_network     # Test with example.net
TEST_DOMAIN=example.org make test_all         # Test all with example.org
```

### Viewing Available Test Targets

See all available testing options:
```bash
make help          # Shows all available targets and descriptions
```

## Examples

### Basic Data Type Validation
```bash
is_numeric "123"     # Returns 0 (true)
is_numeric "-456"    # Returns 0 (true)
is_numeric "abc"     # Returns 1 (false)

is_uint "123"        # Returns 0 (true)
is_uint "-456"       # Returns 1 (false)

is_float "3.14"      # Returns 0 (true)
is_float "1.2e-3"    # Returns 0 (true)

is_string "hello"    # Returns 0 (true)
is_string "123"      # Returns 1 (false)
```

### Network & Connectivity
```bash
can_connect_to "example.com" 80 tcp  # Test HTTP connectivity
can_connect_to "1.1.1.1" 53 udp      # Test DNS connectivity

is_ip "1.1.1.1"          # Returns 0 (valid IPv4)
is_ipv6 "2001:db8::1"    # Returns 0 (valid IPv6)
is_cidr "192.168.1.0/24" # Returns 0 (valid CIDR)

port_is_listening 80     # Check if port 80 is listening
dns_resolves "example.com"  # Check DNS resolution
```

### Docker & Container Operations
```bash
is_docker_running           # Returns 0 if Docker daemon is running
container_exists "nginx"    # Returns 0 if container exists
container_is_running "web"  # Returns 0 if container is running
image_exists "nginx:latest" # Returns 0 if image exists locally
is_valid_docker_tag "v1.2.3"  # Returns 0 if valid tag format
```

### Kubernetes & Cloud-Native
```bash
is_valid_k8s_name "my-app-123"        # Returns 0 (valid K8s name)
is_valid_label "app=nginx"            # Returns 0 (valid label)
is_valid_cpu_request "100m"           # Returns 0 (valid CPU format)
is_valid_memory_request "512Mi"       # Returns 0 (valid memory format)
namespace_exists "kube-system"        # Returns 0 if namespace exists
```

### System & Process Management
```bash
process_exists "nginx"      # Returns 0 if process is running
user_exists "root"          # Returns 0 if user exists
command_exists "docker"     # Returns 0 if command is available
is_root                     # Returns 0 if running as root
systemd_unit_active "nginx" # Returns 0 if service is active
```

### Security & Configuration
```bash
env_var_exists "PATH"                    # Returns 0 if env var exists
is_base64 "SGVsbG8gV29ybGQ="            # Returns 0 if valid base64
is_base32 "JBSWY3DPEBLW64TMMQQQ====" # Returns 0 if valid base32
cert_is_valid "/etc/ssl/cert.pem"       # Returns 0 if cert is valid
file_has_suid "/usr/bin/sudo"           # Returns 0 if SUID bit set
```

### URL & API Testing
```bash
is_valid_url "https://api.example.com/v1"     # Returns 0 if valid URL
url_is_reachable "https://example.com"        # Returns 0 if reachable
response_code_is "https://example.com" 200    # Returns 0 if status matches
service_is_healthy "http://localhost:8080/health"  # Returns 0 if healthy
```

### Resource Monitoring
```bash
cpu_count                    # Prints number of CPU cores
memory_available_mb          # Prints available memory in MB
disk_usage_percentage "/"    # Prints disk usage percentage
load_average_exceeds 2.0     # Returns 0 if load > 2.0
```

## Requirements

- Bash 4.0 or higher
- BATS testing framework (installed via `make libs`)
- Optional: `nc`/netcat (used for UDP connectivity checks)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome, please follow the semantic versioning branch naming convention:

- **main**: Production-ready code
- **develop**: Integration branch for features
- **feat/**: New features (`feat/user-authentication`)
- **fix/**: Bug fixes (`fix/connection-timeout`)
- **chore/**: Maintenance (`chore/update-dependencies`)

## Author

**Michele Tavella** - [meeghele@proton.me](mailto:meeghele@proton.me)

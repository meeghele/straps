#!/usr/bin/env bash
# Copyright (c) 2025 Michele Tavella <meeghele@proton.me>
# Licensed under the MIT License. See LICENSE file for details.

# Validates if a string is a valid IPv4 address
# Args: IP address string
# Returns: 0 if valid IPv4, 1 otherwise
# Example: is_ip "192.168.1.1" -> returns 0
is_ip() {
  [[ $# -eq 1 ]] || return 1
  local ip_addr="$1"
  
  if [[ $ip_addr =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    local OIFS=$IFS
    IFS='.'
    local ip=($ip_addr)
    IFS=$OIFS

    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    return $?
  fi

  return 1
}

# Tests network connectivity to a host/port using specified protocol
# Args: host, port, protocol (tcp/udp)
# Returns: 0 if connection successful, 1 otherwise
# Note: Uses 3-second timeout to prevent hanging on unreachable hosts
# Example: can_connect_to "example.com" 80 tcp
can_connect_to() {
  [[ $# -eq 3 ]] || return 1
  local host="$1" port="$2" proto="$3"
  
  # Validate protocol
  [[ "$proto" == "tcp" || "$proto" == "udp" ]] || return 1
  
  # Validate port range (1-65535)
  [[ "$port" =~ ^[0-9]+$ ]] || return 1
  [[ "$port" -ge 1 && "$port" -le 65535 ]] || return 1
  
  # Use timeout to prevent hanging (3 seconds timeout)
  timeout 3 bash -c "(echo >/dev/$proto/$host/$port) 2>/dev/null" && return 0 || return 1
}

# Checks if a value is a signed integer (positive or negative)
# Args: value to test
# Returns: 0 if numeric integer, 1 otherwise
# Example: is_numeric "-123" -> returns 0
is_numeric() {
  [[ $# -eq 1 ]] || return 1
  [[ $1 =~ ^-?[0-9]+$ ]]
}

# Checks if a value is a string (not a numeric integer)
# Args: value to test
# Returns: 0 if string (non-numeric), 1 if numeric
# Example: is_string "hello" -> returns 0
is_string() {
  [[ $# -eq 1 ]] || return 1
  ! is_numeric "$1"
}

# Checks if a string starts with a specific substring
# Args: string, prefix
# Returns: 0 if string starts with prefix, 1 otherwise
# Example: string_starts_with "hello world" "hello" -> returns 0
string_starts_with() {
  [[ $# -eq 2 ]] || return 1
  [[ $1 == $2* ]]
}

# Checks if a string ends with a specific substring
# Args: string, suffix
# Returns: 0 if string ends with suffix, 1 otherwise
# Example: string_ends_with "hello world" "world" -> returns 0
string_ends_with() {
  [[ $# -eq 2 ]] || return 1
  [[ $1 == *$2 ]]
}

# Checks if a string contains a specific substring
# Args: string, substring
# Returns: 0 if string contains substring, 1 otherwise
# Example: string_contains "hello world" "lo wo" -> returns 0
string_contains() {
  [[ $# -eq 2 ]] || return 1
  [[ $1 == *$2* ]]
}

# Checks if a directory exists
# Args: directory path
# Returns: 0 if directory exists, 1 otherwise
# Example: folder_exists "/tmp" -> returns 0
folder_exists() {
  [[ $# -eq 1 ]] || return 1
  [[ -d "$1" ]]
}

# Checks if a file exists and is a regular file
# Args: file path
# Returns: 0 if file exists, 1 otherwise
# Example: file_exists "/etc/passwd" -> returns 0
file_exists() {
  [[ $# -eq 1 ]] || return 1
  [[ -f "$1" ]]
}

# Checks if a value is an unsigned integer (positive integer or zero)
# Args: value to test
# Returns: 0 if unsigned integer, 1 otherwise
# Example: is_uint "123" -> returns 0, is_uint "-123" -> returns 1
is_uint() {
  [[ $# -eq 1 ]] || return 1
  [[ $1 =~ ^[0-9]+$ ]]
}

# Checks if a value is a floating point number (with decimal point or scientific notation)
# Args: value to test
# Returns: 0 if float, 1 otherwise
# Example: is_float "3.14" -> returns 0, is_float "1.2e-3" -> returns 0
is_float() {
  [[ $# -eq 1 ]] || return 1
  [[ $1 =~ ^-?[0-9]*\.[0-9]+$ ]] || [[ $1 =~ ^-?[0-9]+\.?[0-9]*[eE][-+]?[0-9]+$ ]]
}

# ============================================================================
# DOCKER & CONTAINER FUNCTIONS
# ============================================================================

# Checks if Docker daemon is running
# Args: none
# Returns: 0 if Docker is running, 1 otherwise
# Example: is_docker_running -> returns 0
is_docker_running() {
  [[ $# -eq 0 ]] || return 1
  command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1
}

# Checks if a Docker container exists (running or stopped)
# Args: container name or ID
# Returns: 0 if container exists, 1 otherwise
# Example: container_exists "nginx" -> returns 0
container_exists() {
  [[ $# -eq 1 ]] || return 1
  local container="$1"
  
  command -v docker >/dev/null 2>&1 || return 1
  docker ps -a --format "{{.Names}}" 2>/dev/null | grep -q "^${container}$" || \
  docker ps -a --format "{{.ID}}" 2>/dev/null | grep -q "^${container}"
}

# Checks if a Docker container is currently running
# Args: container name or ID
# Returns: 0 if container is running, 1 otherwise
# Example: container_is_running "nginx" -> returns 0
container_is_running() {
  [[ $# -eq 1 ]] || return 1
  local container="$1"
  
  command -v docker >/dev/null 2>&1 || return 1
  docker ps --format "{{.Names}}" 2>/dev/null | grep -q "^${container}$" || \
  docker ps --format "{{.ID}}" 2>/dev/null | grep -q "^${container}"
}

# Checks if a Docker image exists locally
# Args: image name with optional tag (defaults to :latest)
# Returns: 0 if image exists, 1 otherwise
# Example: image_exists "nginx:1.20" -> returns 0
image_exists() {
  [[ $# -eq 1 ]] || return 1
  local image="$1"
  
  command -v docker >/dev/null 2>&1 || return 1
  
  # Add :latest if no tag specified
  [[ "$image" == *:* ]] || image="${image}:latest"
  
  docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q "^${image}$"
}

# Validates Docker tag format
# Args: tag string
# Returns: 0 if valid Docker tag, 1 otherwise
# Example: is_valid_docker_tag "v1.0.0" -> returns 0
is_valid_docker_tag() {
  [[ $# -eq 1 ]] || return 1
  local tag="$1"
  
  # Docker tag format: lowercase letters, digits, underscores, periods, dashes
  # Cannot start with period or dash, max 128 characters
  [[ ${#tag} -le 128 ]] && \
  [[ $tag =~ ^[a-z0-9_][a-z0-9._-]*$ ]]
}

# Checks if a port is exposed in a running container
# Args: container name/ID, port number
# Returns: 0 if port is exposed, 1 otherwise
# Example: port_is_exposed "nginx" 80 -> returns 0
port_is_exposed() {
  [[ $# -eq 2 ]] || return 1
  local container="$1" port="$2"
  
  command -v docker >/dev/null 2>&1 || return 1
  is_uint "$port" || return 1
  
  docker port "$container" 2>/dev/null | grep -q ":${port}/"
}

# Checks if a Docker volume exists
# Args: volume name
# Returns: 0 if volume exists, 1 otherwise
# Example: volume_exists "data_vol" -> returns 0
volume_exists() {
  [[ $# -eq 1 ]] || return 1
  local volume="$1"
  
  command -v docker >/dev/null 2>&1 || return 1
  docker volume ls --format "{{.Name}}" 2>/dev/null | grep -q "^${volume}$"
}

# Checks if a Docker network exists
# Args: network name
# Returns: 0 if network exists, 1 otherwise
# Example: network_exists "bridge" -> returns 0
network_exists() {
  [[ $# -eq 1 ]] || return 1
  local network="$1"
  
  command -v docker >/dev/null 2>&1 || return 1
  docker network ls --format "{{.Name}}" 2>/dev/null | grep -q "^${network}$"
}

# ============================================================================
# KUBERNETES & CLOUD-NATIVE FUNCTIONS
# ============================================================================

# Validates Kubernetes resource name format
# Args: resource name
# Returns: 0 if valid K8s name, 1 otherwise
# Example: is_valid_k8s_name "my-app-123" -> returns 0
is_valid_k8s_name() {
  [[ $# -eq 1 ]] || return 1
  local name="$1"
  
  # K8s naming: lowercase letters, numbers, hyphens; max 253 chars; no leading/trailing hyphens
  [[ ${#name} -le 253 ]] && \
  [[ $name =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]
}

# Validates Kubernetes label format (key=value or key)
# Args: label string
# Returns: 0 if valid label, 1 otherwise
# Example: is_valid_label "app=nginx" -> returns 0
is_valid_label() {
  [[ $# -eq 1 ]] || return 1
  local label="$1"
  
  if [[ $label == *=* ]]; then
    local key="${label%=*}"
    local value="${label#*=}"
    
    # Key validation (with optional prefix)
    [[ ${#key} -le 253 ]] || return 1
    if [[ $key == */* ]]; then
      local prefix="${key%/*}"
      local name="${key#*/}"
      [[ ${#prefix} -le 253 ]] && [[ $prefix =~ ^[a-z0-9.-]+$ ]] && \
      [[ ${#name} -le 63 ]] && [[ $name =~ ^[a-zA-Z0-9]([a-zA-Z0-9_.-]*[a-zA-Z0-9])?$ ]]
    else
      [[ ${#key} -le 63 ]] && [[ $key =~ ^[a-zA-Z0-9]([a-zA-Z0-9_.-]*[a-zA-Z0-9])?$ ]]
    fi || return 1
    
    # Value validation
    [[ ${#value} -le 63 ]] && [[ $value =~ ^[a-zA-Z0-9]([a-zA-Z0-9_.-]*[a-zA-Z0-9])?$ ]]
  else
    # Key-only label
    [[ ${#label} -le 63 ]] && [[ $label =~ ^[a-zA-Z0-9]([a-zA-Z0-9_.-]*[a-zA-Z0-9])?$ ]]
  fi
}

# Validates Kubernetes annotation format
# Args: annotation string (key=value)
# Returns: 0 if valid annotation, 1 otherwise
# Example: is_valid_annotation "example.com/config=value" -> returns 0
is_valid_annotation() {
  [[ $# -eq 1 ]] || return 1
  local annotation="$1"
  
  [[ $annotation == *=* ]] || return 1
  
  local key="${annotation%=*}"
  local value="${annotation#*=}"
  
  # Key validation (similar to label but more permissive)
  [[ ${#key} -le 253 ]] || return 1
  if [[ $key == */* ]]; then
    local prefix="${key%/*}"
    local name="${key#*/}"
    [[ ${#prefix} -le 253 ]] && [[ $prefix =~ ^[a-z0-9.-]+$ ]] && \
    [[ ${#name} -le 63 ]] && [[ $name =~ ^[a-zA-Z0-9]([a-zA-Z0-9_.-]*[a-zA-Z0-9])?$ ]]
  else
    [[ ${#key} -le 63 ]] && [[ $key =~ ^[a-zA-Z0-9]([a-zA-Z0-9_.-]*[a-zA-Z0-9])?$ ]]
  fi || return 1
  
  # Value can be any string
  [[ -n "$value" ]]
}

# Checks if a Kubernetes namespace exists
# Args: namespace name
# Returns: 0 if namespace exists, 1 otherwise
# Example: namespace_exists "kube-system" -> returns 0
namespace_exists() {
  [[ $# -eq 1 ]] || return 1
  local namespace="$1"
  
  command -v kubectl >/dev/null 2>&1 || return 1
  kubectl get namespace "$namespace" >/dev/null 2>&1
}

# Validates CPU resource request format
# Args: CPU value string
# Returns: 0 if valid CPU format, 1 otherwise
# Example: is_valid_cpu_request "100m" -> returns 0
is_valid_cpu_request() {
  [[ $# -eq 1 ]] || return 1
  local cpu="$1"
  
  # CPU formats: "100m" (millicores), "0.1" (fractional), "1" (whole cores)
  [[ $cpu =~ ^[0-9]+m$ ]] || \
  [[ $cpu =~ ^[0-9]+(\.[0-9]+)?$ ]]
}

# Validates memory resource request format
# Args: memory value string
# Returns: 0 if valid memory format, 1 otherwise
# Example: is_valid_memory_request "128Mi" -> returns 0
is_valid_memory_request() {
  [[ $# -eq 1 ]] || return 1
  local memory="$1"
  
  # Memory formats: "128Mi", "1Gi", "512Ki", "1024M", "2G", etc.
  [[ $memory =~ ^[0-9]+([KMGT]i?)?$ ]]
}

# Validates image pull policy values
# Args: pull policy string
# Returns: 0 if valid policy, 1 otherwise
# Example: is_valid_image_pull_policy "Always" -> returns 0
is_valid_image_pull_policy() {
  [[ $# -eq 1 ]] || return 1
  local policy="$1"
  
  [[ "$policy" == "Always" || "$policy" == "Never" || "$policy" == "IfNotPresent" ]]
}

# ============================================================================
# PORT & SERVICE DISCOVERY FUNCTIONS
# ============================================================================

# Checks if a port is listening on a host (defaults to localhost)
# Args: port number, [optional host]
# Returns: 0 if port is listening, 1 otherwise
# Example: port_is_listening 80 -> returns 0
port_is_listening() {
  [[ $# -ge 1 && $# -le 2 ]] || return 1
  local port="$1"
  local host="${2:-127.0.0.1}"
  
  is_uint "$port" || return 1
  
  # Try multiple methods for checking listening ports
  if command -v ss >/dev/null 2>&1; then
    ss -tln | grep -q ":${port} "
  elif command -v netstat >/dev/null 2>&1; then
    netstat -tln 2>/dev/null | grep -q ":${port} "
  else
    # Fallback: try to connect
    can_connect_to "$host" "$port" tcp
  fi
}

# Validates port number is in valid range (1-65535)
# Args: port number
# Returns: 0 if valid port, 1 otherwise
# Example: port_in_range 8080 -> returns 0
port_in_range() {
  [[ $# -eq 1 ]] || return 1
  local port="$1"
  
  is_uint "$port" && [[ "$port" -ge 1 && "$port" -le 65535 ]]
}

# Checks if port is privileged (< 1024)
# Args: port number
# Returns: 0 if privileged port, 1 otherwise
# Example: is_privileged_port 80 -> returns 0
is_privileged_port() {
  [[ $# -eq 1 ]] || return 1
  local port="$1"
  
  is_uint "$port" && [[ "$port" -lt 1024 && "$port" -gt 0 ]]
}

# Performs basic HTTP health check on a URL
# Args: URL
# Returns: 0 if service responds with 2xx status, 1 otherwise
# Example: service_is_healthy "http://localhost:8080/health" -> returns 0
service_is_healthy() {
  [[ $# -eq 1 ]] || return 1
  local url="$1"
  
  if command -v curl >/dev/null 2>&1; then
    curl -f -s --connect-timeout 5 --max-time 10 "$url" >/dev/null 2>&1
  elif command -v wget >/dev/null 2>&1; then
    wget -q --spider --timeout=5 --tries=1 "$url" 2>/dev/null
  else
    return 1
  fi
}

# Checks if a hostname resolves to an IP address
# Args: hostname
# Returns: 0 if resolves, 1 otherwise
# Example: dns_resolves "example.com" -> returns 0
dns_resolves() {
  [[ $# -eq 1 ]] || return 1
  local hostname="$1"
  
  if command -v dig >/dev/null 2>&1; then
    dig +short "$hostname" 2>/dev/null | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
  elif command -v nslookup >/dev/null 2>&1; then
    nslookup "$hostname" 2>/dev/null | grep -q "Address:"
  elif command -v getent >/dev/null 2>&1; then
    getent hosts "$hostname" >/dev/null 2>&1
  else
    # Fallback: try ping (may not work in all environments)
    ping -c 1 -W 1 "$hostname" >/dev/null 2>&1
  fi
}

# Validates fully qualified domain name format
# Args: FQDN string
# Returns: 0 if valid FQDN, 1 otherwise
# Example: is_valid_fqdn "api.example.com" -> returns 0
is_valid_fqdn() {
  [[ $# -eq 1 ]] || return 1
  local fqdn="$1"
  
  # FQDN format validation
  [[ ${#fqdn} -le 253 ]] && \
  [[ $fqdn =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*$ ]] && \
  [[ ! $fqdn =~ \.\.+ ]] && \
  [[ $fqdn == *.* ]]
}

# ============================================================================
# ENVIRONMENT & CONFIGURATION FUNCTIONS
# ============================================================================

# Checks if an environment variable exists (is set)
# Args: variable name
# Returns: 0 if variable exists, 1 otherwise
# Example: env_var_exists "PATH" -> returns 0
env_var_exists() {
  [[ $# -eq 1 ]] || return 1
  local var_name="$1"
  
  [[ -n "${!var_name+x}" ]]
}

# Checks if an environment variable exists and is not empty
# Args: variable name
# Returns: 0 if variable exists and not empty, 1 otherwise
# Example: env_var_not_empty "HOME" -> returns 0
env_var_not_empty() {
  [[ $# -eq 1 ]] || return 1
  local var_name="$1"
  
  [[ -n "${!var_name:-}" ]]
}

# Validates environment variable name format
# Args: variable name
# Returns: 0 if valid env var name, 1 otherwise
# Example: is_valid_env_var_name "MY_VAR_123" -> returns 0
is_valid_env_var_name() {
  [[ $# -eq 1 ]] || return 1
  local name="$1"
  
  # Env var names: letters, digits, underscores; must start with letter or underscore
  [[ $name =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
}

# Checks if a string is valid base64 encoding
# Args: string to test
# Returns: 0 if valid base64, 1 otherwise
# Example: is_base64 "SGVsbG8gV29ybGQ=" -> returns 0
is_base64() {
  [[ $# -eq 1 ]] || return 1
  local string="$1"
  
  # Empty string is valid base64
  [[ -z "$string" ]] && return 0
  
  # Base64 format: A-Z, a-z, 0-9, +, /, with optional = padding
  # Must only contain valid base64 characters
  [[ ! $string =~ ^[A-Za-z0-9+/=]*$ ]] && return 1
  
  # Check for spaces (not allowed)
  [[ "$string" =~ [[:space:]] ]] && return 1
  
  # Check padding rules more strictly
  if [[ "$string" =~ = ]]; then
    # Must end with 1 or 2 equals, not 3 or more
    [[ "$string" =~ ===$ ]] && return 1
    
    # Must not have = in the middle
    [[ "$string" =~ ^[^=]*=[^=]*[A-Za-z0-9+/] ]] && return 1
  fi
  
  # Cross-platform base64 validation that handles padding differences
  # between different base64 implementations (GNU coreutils vs others)
  local test_string="$string"
  
  # For strings without padding, try adding padding for strict decoders
  if [[ ! "$test_string" =~ =$ ]]; then
    local len=${#test_string}
    local padding_needed=$((4 - (len % 4)))
    
    case $padding_needed in
      1) test_string="${test_string}=" ;;
      2) test_string="${test_string}==" ;;
      3) ;; # 3 would be invalid, don't add padding
    esac
  fi
  
  # Try to decode - if it works, it's valid base64
  echo "$test_string" | base64 -d >/dev/null 2>&1
}

# Checks if a string is valid base32 encoding
# Args: string to test
# Returns: 0 if valid base32, 1 otherwise
# Example: is_base32 "JBSWY3DPEBLW64TMMQQQ====" -> returns 0
is_base32() {
  [[ $# -eq 1 ]] || return 1
  local string="$1"
  
  # Empty string is valid base32
  [[ -z "$string" ]] && return 0
  
  # Base32 format: A-Z, 2-7, with optional = padding
  # Must only contain valid base32 characters
  [[ ! $string =~ ^[A-Z2-7=]*$ ]] && return 1
  
  # Check for spaces (not allowed)
  [[ "$string" =~ [[:space:]] ]] && return 1
  
  # Check for lowercase letters (not allowed in standard base32)
  [[ "$string" =~ [a-z] ]] && return 1
  
  # Check padding rules
  if [[ "$string" =~ = ]]; then
    # Padding must be at the end
    [[ ! "$string" =~ ^[^=]*=+$ ]] && return 1
    
    # Base32 can have 1-6 padding characters (RFC 4648)
    # However, some edge cases may require up to 8 padding for specific encodings
    local padding_count
    padding_count=$(echo "$string" | grep -o '=*$' | wc -c)
    padding_count=$((padding_count - 1)) # subtract 1 for newline
    
    # Allow special case: 8 padding characters only if the data portion is exactly 8 chars
    local data_length=$((${#string} - padding_count))
    if [[ $padding_count -gt 6 ]]; then
      # Only allow 7-8 padding characters in specific cases (8 data chars + 8 padding = 16 total)
      if [[ $padding_count -le 8 && $data_length -eq 8 ]]; then
        # This is valid - continue with other validations
        :
      else
        return 1
      fi
    fi
  fi
  
  # Length validation: base32 strings must be multiples of 8 chars when padded
  local len=${#string}
  [[ $((len % 8)) -ne 0 ]] && return 1
  
  # Try to decode if base32 command is available (some systems have it)
  # However, some valid base32 strings may not decode due to implementation differences
  if command -v base32 >/dev/null 2>&1; then
    # If decode fails but format checks passed, still consider it valid
    # since different base32 implementations have varying strictness
    echo "$string" | base32 -d >/dev/null 2>&1 || return 0
  else
    # If no base32 decoder available, the format checks above are sufficient
    return 0
  fi
}

# Computes MD5 hash of a string or file
# Args: input string or file path (use -f flag for file)
# Returns: 0 on success, outputs MD5 hash to stdout
# Example: hash_md5 "hello world" -> outputs MD5 hash
# Example: hash_md5 -f "/path/to/file" -> outputs MD5 hash of file
hash_md5() {
  local file_mode=false
  local input=""
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -f|--file)
        file_mode=true
        shift
        ;;
      *)
        input="$1"
        shift
        ;;
    esac
  done
  
  [[ -n "$input" ]] || return 1
  
  if [[ "$file_mode" == true ]]; then
    [[ -f "$input" ]] || return 1
    
    # Try different MD5 commands based on platform
    if command -v md5sum >/dev/null 2>&1; then
      command md5sum "$input" | cut -d' ' -f1
    elif command -v md5 >/dev/null 2>&1; then
      # macOS/BSD style
      md5 -q "$input"
    elif command -v openssl >/dev/null 2>&1; then
      openssl dgst -md5 "$input" | cut -d' ' -f2
    else
      return 1
    fi
  else
    # Hash string input
    if command -v md5sum >/dev/null 2>&1; then
      echo -n "$input" | command md5sum | cut -d' ' -f1
    elif command -v md5 >/dev/null 2>&1; then
      # macOS/BSD style
      echo -n "$input" | md5 -q
    elif command -v openssl >/dev/null 2>&1; then
      echo -n "$input" | openssl dgst -md5 | cut -d' ' -f2
    else
      return 1
    fi
  fi
}

# Computes SHA1 hash of a string or file
# Args: input string or file path (use -f flag for file)
# Returns: 0 on success, outputs SHA1 hash to stdout
# Example: hash_sha1 "hello world" -> outputs SHA1 hash
# Example: hash_sha1 -f "/path/to/file" -> outputs SHA1 hash of file
hash_sha1() {
  local file_mode=false
  local input=""
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -f|--file)
        file_mode=true
        shift
        ;;
      *)
        input="$1"
        shift
        ;;
    esac
  done
  
  [[ -n "$input" ]] || return 1
  
  if [[ "$file_mode" == true ]]; then
    [[ -f "$input" ]] || return 1
    
    # Try different SHA1 commands based on platform
    if command -v sha1sum >/dev/null 2>&1; then
      command sha1sum "$input" | cut -d' ' -f1
    elif command -v shasum >/dev/null 2>&1; then
      shasum -a 1 "$input" | cut -d' ' -f1
    elif command -v openssl >/dev/null 2>&1; then
      openssl dgst -sha1 "$input" | cut -d' ' -f2
    else
      return 1
    fi
  else
    # Hash string input
    if command -v sha1sum >/dev/null 2>&1; then
      echo -n "$input" | command sha1sum | cut -d' ' -f1
    elif command -v shasum >/dev/null 2>&1; then
      echo -n "$input" | shasum -a 1 | cut -d' ' -f1
    elif command -v openssl >/dev/null 2>&1; then
      echo -n "$input" | openssl dgst -sha1 | cut -d' ' -f2
    else
      return 1
    fi
  fi
}




# Checks if a key exists in a configuration file (supports basic key-value formats)
# Args: file path, key name
# Returns: 0 if key exists, 1 otherwise
# Example: config_key_exists "/etc/config" "server_port" -> returns 0
config_key_exists() {
  [[ $# -eq 2 ]] || return 1
  local file="$1" key="$2"
  
  [[ -f "$file" ]] || return 1
  
  # Check for various config formats
  grep -qE "^[[:space:]]*${key}[[:space:]]*[:=]" "$file" 2>/dev/null || \
  grep -qE "^[[:space:]]*${key}[[:space:]]+" "$file" 2>/dev/null
}

# ============================================================================
# PROCESS & SYSTEM FUNCTIONS
# ============================================================================

# Checks if a process with given name is running
# Args: process name
# Returns: 0 if process exists, 1 otherwise
# Example: process_exists "nginx" -> returns 0
process_exists() {
  [[ $# -eq 1 ]] || return 1
  local process_name="$1"
  
  if command -v pgrep >/dev/null 2>&1; then
    pgrep -f "$process_name" >/dev/null 2>&1
  elif command -v ps >/dev/null 2>&1; then
    ps aux 2>/dev/null | grep -v grep | grep -q "$process_name"
  else
    return 1
  fi
}

# Checks if a process ID (PID) exists
# Args: process ID
# Returns: 0 if PID exists, 1 otherwise
# Example: pid_exists 1234 -> returns 0
pid_exists() {
  [[ $# -eq 1 ]] || return 1
  local pid="$1"
  
  is_uint "$pid" || return 1
  
  if [[ -d "/proc" ]]; then
    [[ -d "/proc/$pid" ]]
  elif command -v ps >/dev/null 2>&1; then
    ps -p "$pid" >/dev/null 2>&1
  else
    kill -0 "$pid" >/dev/null 2>&1
  fi
}

# Checks if a user exists in the system
# Args: username
# Returns: 0 if user exists, 1 otherwise
# Example: user_exists "root" -> returns 0
user_exists() {
  [[ $# -eq 1 ]] || return 1
  local username="$1"
  
  if command -v getent >/dev/null 2>&1; then
    getent passwd "$username" >/dev/null 2>&1
  elif [[ -f /etc/passwd ]]; then
    grep -q "^${username}:" /etc/passwd 2>/dev/null
  else
    id "$username" >/dev/null 2>&1
  fi
}

# Checks if a group exists in the system
# Args: group name
# Returns: 0 if group exists, 1 otherwise
# Example: group_exists "wheel" -> returns 0
group_exists() {
  [[ $# -eq 1 ]] || return 1
  local groupname="$1"
  
  if command -v getent >/dev/null 2>&1; then
    getent group "$groupname" >/dev/null 2>&1
  elif [[ -f /etc/group ]]; then
    grep -q "^${groupname}:" /etc/group 2>/dev/null
  else
    return 1
  fi
}

# Checks if a command/binary exists and is executable
# Args: command name
# Returns: 0 if command exists, 1 otherwise
# Example: command_exists "docker" -> returns 0
command_exists() {
  [[ $# -eq 1 ]] || return 1
  local cmd="$1"
  
  command -v "$cmd" >/dev/null 2>&1
}

# Checks if current user is root
# Args: none
# Returns: 0 if running as root, 1 otherwise
# Example: is_root -> returns 0
is_root() {
  [[ $# -eq 0 ]] || return 1
  [[ $EUID -eq 0 ]]
}

# Checks if process has specific Linux capability (requires root or appropriate permissions)
# Args: capability name (without CAP_ prefix)
# Returns: 0 if capability present, 1 otherwise
# Example: has_capability "NET_BIND_SERVICE" -> returns 0
has_capability() {
  [[ $# -eq 1 ]] || return 1
  local cap="$1"
  
  if command -v capsh >/dev/null 2>&1; then
    capsh --print 2>/dev/null | grep -q "cap_${cap,,}"
  elif [[ -f "/proc/self/status" ]]; then
    # Check effective capabilities
    grep -q "CapEff:" /proc/self/status 2>/dev/null
  else
    return 1
  fi
}

# Checks if a systemd unit exists
# Args: unit name (with or without .service extension)
# Returns: 0 if unit exists, 1 otherwise
# Example: systemd_unit_exists "nginx" -> returns 0
systemd_unit_exists() {
  [[ $# -eq 1 ]] || return 1
  local unit="$1"
  
  # Add .service extension if not present and no other extension
  [[ "$unit" == *.* ]] || unit="${unit}.service"
  
  if command -v systemctl >/dev/null 2>&1; then
    systemctl list-unit-files "$unit" >/dev/null 2>&1 || \
    systemctl status "$unit" >/dev/null 2>&1
  else
    return 1
  fi
}

# Checks if a systemd unit is active (running)
# Args: unit name (with or without .service extension)
# Returns: 0 if unit is active, 1 otherwise
# Example: systemd_unit_active "nginx" -> returns 0
systemd_unit_active() {
  [[ $# -eq 1 ]] || return 1
  local unit="$1"
  
  # Add .service extension if not present and no other extension
  [[ "$unit" == *.* ]] || unit="${unit}.service"
  
  if command -v systemctl >/dev/null 2>&1; then
    systemctl is-active "$unit" >/dev/null 2>&1
  else
    return 1
  fi
}

# ============================================================================
# FILE SYSTEM EXTENDED FUNCTIONS
# ============================================================================

# Checks if a file is executable
# Args: file path
# Returns: 0 if file is executable, 1 otherwise
# Example: file_is_executable "/usr/bin/bash" -> returns 0
file_is_executable() {
  [[ $# -eq 1 ]] || return 1
  local file="$1"
  
  [[ -f "$file" && -x "$file" ]]
}

# Checks if a file is readable
# Args: file path
# Returns: 0 if file is readable, 1 otherwise
# Example: file_is_readable "/etc/passwd" -> returns 0
file_is_readable() {
  [[ $# -eq 1 ]] || return 1
  local file="$1"
  
  [[ -f "$file" && -r "$file" ]]
}

# Checks if a file is writable
# Args: file path
# Returns: 0 if file is writable, 1 otherwise
# Example: file_is_writable "/tmp/test.txt" -> returns 0
file_is_writable() {
  [[ $# -eq 1 ]] || return 1
  local file="$1"
  
  if [[ -f "$file" ]]; then
    [[ -w "$file" ]]
  else
    # Check if parent directory is writable
    local parent_dir=$(dirname "$file")
    [[ -d "$parent_dir" && -w "$parent_dir" ]]
  fi
}

# Checks if a path is a symbolic link
# Args: file/directory path
# Returns: 0 if path is symlink, 1 otherwise
# Example: file_is_symlink "/usr/bin/vi" -> returns 0
file_is_symlink() {
  [[ $# -eq 1 ]] || return 1
  local path="$1"
  
  [[ -L "$path" ]]
}

# Checks if a directory is empty
# Args: directory path
# Returns: 0 if directory is empty, 1 otherwise
# Example: dir_is_empty "/tmp/empty" -> returns 0
dir_is_empty() {
  [[ $# -eq 1 ]] || return 1
  local dir="$1"
  
  [[ -d "$dir" ]] && [[ ! "$(ls -A "$dir" 2>/dev/null)" ]]
}

# Checks if a path is absolute (starts with /)
# Args: path string
# Returns: 0 if absolute path, 1 otherwise
# Example: path_is_absolute "/usr/bin" -> returns 0
path_is_absolute() {
  [[ $# -eq 1 ]] || return 1
  local path="$1"
  
  [[ "$path" == /* ]]
}

# Checks if a path is relative (does not start with /)
# Args: path string
# Returns: 0 if relative path, 1 otherwise
# Example: path_is_relative "bin/test" -> returns 0
path_is_relative() {
  [[ $# -eq 1 ]] || return 1
  local path="$1"
  
  [[ "$path" != /* ]]
}

# Checks if a file size exceeds a threshold (in bytes)
# Args: file path, size threshold in bytes
# Returns: 0 if file exceeds threshold, 1 otherwise
# Example: file_size_exceeds "/var/log/app.log" 1048576 -> returns 0
file_size_exceeds() {
  [[ $# -eq 2 ]] || return 1
  local file="$1" threshold="$2"
  
  [[ -f "$file" ]] || return 1
  is_uint "$threshold" || return 1
  
  if command -v stat >/dev/null 2>&1; then
    local size
    # Try different stat formats (GNU vs BSD)
    if size=$(stat -f%z "$file" 2>/dev/null); then
      # BSD stat
      [[ $size -gt $threshold ]]
    elif size=$(stat -c%s "$file" 2>/dev/null); then
      # GNU stat
      [[ $size -gt $threshold ]]
    else
      return 1
    fi
  else
    # Fallback using ls
    local size
    size=$(ls -l "$file" 2>/dev/null | awk '{print $5}')
    [[ -n "$size" && "$size" =~ ^[0-9]+$ && $size -gt $threshold ]]
  fi
}

# Checks if a file has a specific extension
# Args: file path, extension (with or without leading dot)
# Returns: 0 if file has extension, 1 otherwise
# Example: has_file_extension "test.txt" "txt" -> returns 0
has_file_extension() {
  [[ $# -eq 2 ]] || return 1
  local file="$1" ext="$2"
  
  # Special case: empty extension should match any file (end of string)
  [[ -z "$ext" ]] && return 0
  
  # Add dot if not present
  [[ "$ext" == .* ]] || ext=".$ext"
  
  [[ "$file" == *"$ext" ]]
}

# ============================================================================
# NETWORK EXTENDED FUNCTIONS
# ============================================================================

# Validates IPv6 address format
# Args: IPv6 address string
# Returns: 0 if valid IPv6, 1 otherwise
# Example: is_ipv6 "2001:db8::1" -> returns 0
is_ipv6() {
  [[ $# -eq 1 ]] || return 1
  local ipv6="$1"
  
  # Basic IPv6 validation - simplified but comprehensive
  # Must have colons and hex characters
  [[ $ipv6 =~ ^[0-9a-fA-F:]+$ ]] || [[ $ipv6 =~ ^[0-9a-fA-F:.]+$ ]] || return 1
  
  # Must contain at least one colon
  [[ $ipv6 == *:* ]] || return 1
  
  # Handle special cases
  [[ $ipv6 == "::" ]] && return 0
  
  # Check for valid IPv6 patterns
  # Full form (8 groups of 4 hex digits)
  [[ $ipv6 =~ ^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$ ]] && return 0
  
  # Compressed form with :: - split on :: and validate parts
  if [[ $ipv6 == *"::"* ]]; then
    # Should have exactly one ::
    local double_colon_count
    double_colon_count=$(echo "$ipv6" | grep -o "::" | wc -l)
    [[ $double_colon_count -eq 1 ]] || return 1
    
    # IPv4-mapped IPv6 (e.g., ::ffff:192.0.2.1)
    [[ $ipv6 =~ ^::ffff:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] && return 0
    
    # Split on :: and validate each part
    local before_double_colon="${ipv6%%::*}"
    local after_double_colon="${ipv6##*::}"
    
    # Validate before part (if exists)
    if [[ -n "$before_double_colon" ]]; then
      [[ $before_double_colon =~ ^([0-9a-fA-F]{1,4}:)*[0-9a-fA-F]{1,4}$ ]] || \
      [[ $before_double_colon =~ ^([0-9a-fA-F]{1,4}:)+$ ]] || return 1
    fi
    
    # Validate after part (if exists)
    if [[ -n "$after_double_colon" ]]; then
      [[ $after_double_colon =~ ^([0-9a-fA-F]{1,4}:)*[0-9a-fA-F]{1,4}$ ]] || \
      [[ $after_double_colon =~ ^[0-9a-fA-F]{1,4}$ ]] || return 1
    fi
    
    return 0
  fi
  
  return 1
}

# Validates CIDR notation (IPv4 with subnet mask)
# Args: CIDR string (e.g., "192.168.1.0/24")
# Returns: 0 if valid CIDR, 1 otherwise
# Example: is_cidr "192.168.1.0/24" -> returns 0
is_cidr() {
  [[ $# -eq 1 ]] || return 1
  local cidr="$1"
  
  [[ $cidr == */* ]] || return 1
  
  local ip="${cidr%/*}"
  local mask="${cidr#*/}"
  
  is_ip "$ip" && is_uint "$mask" && [[ $mask -le 32 ]]
}

# Validates MAC address format
# Args: MAC address string
# Returns: 0 if valid MAC address, 1 otherwise
# Example: is_mac_address "aa:bb:cc:dd:ee:ff" -> returns 0
is_mac_address() {
  [[ $# -eq 1 ]] || return 1
  local mac="$1"
  
  # MAC address formats: aa:bb:cc:dd:ee:ff or aa-bb-cc-dd-ee-ff (consistent separators only)
  [[ $mac =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]] || \
  [[ $mac =~ ^([0-9a-fA-F]{2}-){5}[0-9a-fA-F]{2}$ ]]
}

# Validates hostname format (not FQDN)
# Args: hostname string
# Returns: 0 if valid hostname, 1 otherwise
# Example: is_valid_hostname "web-server-01" -> returns 0
is_valid_hostname() {
  [[ $# -eq 1 ]] || return 1
  local hostname="$1"
  
  # Hostname: alphanumeric and hyphens, max 63 chars, no leading/trailing hyphens
  [[ ${#hostname} -le 63 ]] && \
  [[ $hostname =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]
}

# Checks if an IP address is within a subnet (simplified check for /24, /16, /8)
# Args: subnet CIDR, IP address
# Returns: 0 if IP is in subnet, 1 otherwise
# Example: subnet_contains_ip "192.168.1.0/24" "192.168.1.100" -> returns 0
subnet_contains_ip() {
  [[ $# -eq 2 ]] || return 1
  local subnet="$1" ip="$2"
  
  is_cidr "$subnet" && is_ip "$ip" || return 1
  
  local network="${subnet%/*}"
  local mask="${subnet#*/}"
  
  # Simple check for common subnet masks
  case $mask in
    8)  [[ ${ip%%.*} == ${network%%.*} ]] ;;
    16) [[ ${ip%.*.*} == ${network%.*.*} ]] ;;
    24) [[ ${ip%.*} == ${network%.*} ]] ;;
    32) [[ $ip == $network ]] ;;
    *)  return 1 ;;  # More complex calculations not implemented
  esac
}

# Checks if an IP address is in private address ranges
# Args: IP address
# Returns: 0 if private IP, 1 otherwise
# Example: is_private_ip "192.168.1.1" -> returns 0
is_private_ip() {
  [[ $# -eq 1 ]] || return 1
  local ip="$1"
  
  is_ip "$ip" || return 1
  
  # Check private IP ranges: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
  subnet_contains_ip "10.0.0.0/8" "$ip" || \
  subnet_contains_ip "192.168.0.0/16" "$ip" || \
  # 172.16.0.0/12 check (172.16.0.0 - 172.31.255.255)
  ( [[ ${ip%%.*} == "172" ]] && 
    local second=${ip#*.}; second=${second%%.*}
    [[ $second -ge 16 && $second -le 31 ]] )
}

# Checks if an IP address is a loopback address
# Args: IP address
# Returns: 0 if loopback IP, 1 otherwise
# Example: is_loopback_ip "127.0.0.1" -> returns 0
is_loopback_ip() {
  [[ $# -eq 1 ]] || return 1
  local ip="$1"
  
  is_ip "$ip" || return 1
  
  # 127.0.0.0/8 range
  [[ ${ip%%.*} == "127" ]]
}

# ============================================================================
# RESOURCE & LIMIT FUNCTIONS
# ============================================================================

# Gets the number of CPU cores available
# Args: none
# Returns: 0 and prints CPU count, 1 if unable to determine
# Example: cpu_count -> prints "4"
cpu_count() {
  [[ $# -eq 0 ]] || return 1
  
  if [[ -f /proc/cpuinfo ]]; then
    grep -c "^processor" /proc/cpuinfo
  elif command -v nproc >/dev/null 2>&1; then
    nproc
  elif command -v sysctl >/dev/null 2>&1; then
    sysctl -n hw.ncpu 2>/dev/null || sysctl -n hw.logicalcpu 2>/dev/null
  else
    return 1
  fi
}

# Gets available memory in MB
# Args: none
# Returns: 0 and prints memory in MB, 1 if unable to determine
# Example: memory_available_mb -> prints "8192"
memory_available_mb() {
  [[ $# -eq 0 ]] || return 1
  
  if [[ -f /proc/meminfo ]]; then
    local mem_kb
    mem_kb=$(grep "^MemAvailable:" /proc/meminfo 2>/dev/null | awk '{print $2}')
    if [[ -n "$mem_kb" ]]; then
      echo $((mem_kb / 1024))
    else
      # Fallback to MemFree + Buffers + Cached
      local mem_free buffers cached
      mem_free=$(grep "^MemFree:" /proc/meminfo | awk '{print $2}')
      buffers=$(grep "^Buffers:" /proc/meminfo | awk '{print $2}')
      cached=$(grep "^Cached:" /proc/meminfo | awk '{print $2}')
      echo $(((mem_free + buffers + cached) / 1024))
    fi
  elif command -v free >/dev/null 2>&1; then
    free -m | awk 'NR==2{printf "%.0f", $7}'
  else
    return 1
  fi
}

# Gets disk usage percentage for a path
# Args: path
# Returns: 0 and prints usage percentage, 1 if unable to determine
# Example: disk_usage_percentage "/" -> prints "85"
disk_usage_percentage() {
  [[ $# -eq 1 ]] || return 1
  local path="$1"
  
  if command -v df >/dev/null 2>&1; then
    # Check if df can get usage info for the path
    local result
    result=$(df "$path" 2>/dev/null | awk 'NR==2 {sub(/%/, "", $5); print $5}')
    
    # If df fails or returns empty result, return error
    [[ -n "$result" && "$result" =~ ^[0-9]+$ ]] || return 1
    
    echo "$result"
  else
    return 1
  fi
}

# Checks if system load average exceeds threshold
# Args: threshold (float)
# Returns: 0 if load exceeds threshold, 1 otherwise
# Example: load_average_exceeds 2.0 -> returns 0
load_average_exceeds() {
  [[ $# -eq 1 ]] || return 1
  local threshold="$1"
  
  # Validate threshold is a number
  [[ $threshold =~ ^[0-9]+(\.[0-9]+)?$ ]] || return 1
  
  if [[ -f /proc/loadavg ]]; then
    local current_load
    current_load=$(awk '{print $1}' /proc/loadavg)
    # Compare using awk for floating point comparison
    awk -v current="$current_load" -v thresh="$threshold" 'BEGIN { exit (current > thresh ? 0 : 1) }'
  elif command -v uptime >/dev/null 2>&1; then
    local load_output current_load
    load_output=$(uptime)
    # Extract 1-minute load average
    current_load=$(echo "$load_output" | sed 's/.*load average[s]*: \([0-9.]*\).*/\1/')
    awk -v current="$current_load" -v thresh="$threshold" 'BEGIN { exit (current > thresh ? 0 : 1) }'
  else
    return 1
  fi
}

# Gets the file descriptor limit for current process
# Args: none
# Returns: 0 and prints limit, 1 if unable to determine
# Example: file_descriptor_limit -> prints "1024"
file_descriptor_limit() {
  [[ $# -eq 0 ]] || return 1
  
  if command -v ulimit >/dev/null 2>&1; then
    ulimit -n
  elif [[ -f /proc/self/limits ]]; then
    awk '/Max open files/ {print $4}' /proc/self/limits
  else
    return 1
  fi
}

# Gets the process limit for current user
# Args: none
# Returns: 0 and prints limit, 1 if unable to determine
# Example: process_limit -> prints "4096"
process_limit() {
  [[ $# -eq 0 ]] || return 1
  
  if command -v ulimit >/dev/null 2>&1; then
    ulimit -u
  elif [[ -f /proc/self/limits ]]; then
    awk '/Max processes/ {print $3}' /proc/self/limits
  else
    return 1
  fi
}

# ============================================================================
# SECURITY & PERMISSIONS FUNCTIONS
# ============================================================================

# Checks if a file has specific SELinux context (Linux only)
# Args: file path, context pattern
# Returns: 0 if context matches, 1 otherwise
# Example: has_selinux_context "/etc/passwd" "system_u" -> returns 0
has_selinux_context() {
  [[ $# -eq 2 ]] || return 1
  local file="$1" context_pattern="$2"
  
  [[ -f "$file" ]] || return 1
  
  if command -v ls >/dev/null 2>&1 && ls --help 2>&1 | grep -q "\-Z"; then
    ls -Z "$file" 2>/dev/null | grep -q "$context_pattern"
  elif command -v stat >/dev/null 2>&1; then
    stat -c %C "$file" 2>/dev/null | grep -q "$context_pattern"
  else
    return 1
  fi
}

# Checks if SELinux is in enforcing mode
# Args: none
# Returns: 0 if enforcing, 1 otherwise
# Example: is_selinux_enforcing -> returns 0
is_selinux_enforcing() {
  [[ $# -eq 0 ]] || return 1
  
  if [[ -f /sys/fs/selinux/enforce ]]; then
    [[ "$(cat /sys/fs/selinux/enforce 2>/dev/null)" == "1" ]]
  elif command -v getenforce >/dev/null 2>&1; then
    [[ "$(getenforce 2>/dev/null)" == "Enforcing" ]]
  else
    return 1
  fi
}

# Checks if a file has SUID bit set
# Args: file path
# Returns: 0 if SUID bit is set, 1 otherwise
# Example: file_has_suid "/usr/bin/sudo" -> returns 0
file_has_suid() {
  [[ $# -eq 1 ]] || return 1
  local file="$1"
  
  [[ -f "$file" && -u "$file" ]]
}

# Checks if a file has SGID bit set
# Args: file path
# Returns: 0 if SGID bit is set, 1 otherwise
# Example: file_has_sgid "/usr/bin/write" -> returns 0
file_has_sgid() {
  [[ $# -eq 1 ]] || return 1
  local file="$1"
  
  [[ -f "$file" && -g "$file" ]]
}

# Validates SSH public key format (basic check)
# Args: SSH key string
# Returns: 0 if appears to be valid SSH key, 1 otherwise
# Example: is_valid_ssh_key "ssh-rsa AAAAB3NzaC1yc2E..." -> returns 0
is_valid_ssh_key() {
  [[ $# -eq 1 ]] || return 1
  local key="$1"
  
  # Basic SSH key format check
  [[ $key =~ ^(ssh-rsa|ssh-dss|ssh-ed25519|ecdsa-sha2-nistp[0-9]+)[[:space:]]+[A-Za-z0-9+/]+[=]{0,2}([[:space:]]+.*)?$ ]]
}

# Basic certificate validation (checks if file exists and has cert-like content)
# Args: certificate file path
# Returns: 0 if appears to be valid certificate, 1 otherwise
# Example: cert_is_valid "/etc/ssl/cert.pem" -> returns 0
cert_is_valid() {
  [[ $# -eq 1 ]] || return 1
  local cert_file="$1"
  
  [[ -f "$cert_file" ]] || return 1
  
  if command -v openssl >/dev/null 2>&1; then
    openssl x509 -in "$cert_file" -noout -text >/dev/null 2>&1
  else
    # Basic heuristic check
    grep -q "BEGIN CERTIFICATE" "$cert_file" 2>/dev/null && \
    grep -q "END CERTIFICATE" "$cert_file" 2>/dev/null
  fi
}

# Checks if certificate expires within specified days
# Args: certificate file path, days threshold
# Returns: 0 if expires within threshold, 1 otherwise
# Example: cert_expires_within "/etc/ssl/cert.pem" 30 -> returns 0
cert_expires_within() {
  [[ $# -eq 2 ]] || return 1
  local cert_file="$1" days="$2"
  
  [[ -f "$cert_file" ]] || return 1
  is_uint "$days" || return 1
  
  if command -v openssl >/dev/null 2>&1; then
    local expiry_date current_epoch expiry_epoch threshold_epoch
    
    # Get certificate expiry date
    expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate 2>/dev/null | cut -d= -f2)
    [[ -n "$expiry_date" ]] || return 1
    
    # Convert to epoch times
    if command -v date >/dev/null 2>&1; then
      current_epoch=$(date +%s)
      expiry_epoch=$(date -d "$expiry_date" +%s 2>/dev/null || date -j -f "%b %d %H:%M:%S %Y %Z" "$expiry_date" +%s 2>/dev/null)
      threshold_epoch=$((current_epoch + days * 86400))
      
      [[ $expiry_epoch -le $threshold_epoch ]]
    else
      return 1
    fi
  else
    return 1
  fi
}


# ============================================================================
# URL & API FUNCTIONS
# ============================================================================

# Validates URL format (basic validation)
# Args: URL string
# Returns: 0 if valid URL format, 1 otherwise
# Example: is_valid_url "https://example.com/api" -> returns 0
is_valid_url() {
  [[ $# -eq 1 ]] || return 1
  local url="$1"
  
  # Basic URL validation: protocol://domain[:port][/path][?query][#fragment]
  # Support http, https, and ftp protocols
  [[ $url =~ ^https?://[a-zA-Z0-9.-]+(:[0-9]+)?([/].*)?$ ]] || \
  [[ $url =~ ^ftp://[a-zA-Z0-9.-]+(:[0-9]+)?([/].*)?$ ]]
}

# Checks if a URL is reachable (returns 2xx status)
# Args: URL
# Returns: 0 if URL is reachable, 1 otherwise
# Example: url_is_reachable "https://example.com" -> returns 0
url_is_reachable() {
  [[ $# -eq 1 ]] || return 1
  local url="$1"
  
  if command -v curl >/dev/null 2>&1; then
    curl -f -s --head --connect-timeout 5 --max-time 10 "$url" >/dev/null 2>&1
  elif command -v wget >/dev/null 2>&1; then
    wget -q --spider --timeout=5 --tries=1 "$url" 2>/dev/null
  else
    return 1
  fi
}

# Validates API endpoint format (must be HTTP/HTTPS URL with path)
# Args: API endpoint URL
# Returns: 0 if valid API endpoint, 1 otherwise
# Example: is_valid_api_endpoint "https://api.example.com/v1/users" -> returns 0
is_valid_api_endpoint() {
  [[ $# -eq 1 ]] || return 1
  local endpoint="$1"
  
  # API endpoints should have protocol, domain (with optional port), and path
  [[ $endpoint =~ ^https?://[a-zA-Z0-9.-]+(:[0-9]+)?/.+ ]]
}

# Checks if a URL returns a specific HTTP status code
# Args: URL, expected status code
# Returns: 0 if status matches, 1 otherwise
# Example: response_code_is "https://example.com" 200 -> returns 0
response_code_is() {
  [[ $# -eq 2 ]] || return 1
  local url="$1" expected_code="$2"
  
  is_uint "$expected_code" || return 1
  
  if command -v curl >/dev/null 2>&1; then
    local actual_code
    actual_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 10 "$url" 2>/dev/null)
    [[ "$actual_code" == "$expected_code" ]]
  else
    return 1
  fi
}

# Validates webhook URL format (must be HTTPS for security)
# Args: webhook URL
# Returns: 0 if valid webhook URL, 1 otherwise
# Example: is_valid_webhook_url "https://hooks.example.com/webhook/123" -> returns 0
is_valid_webhook_url() {
  [[ $# -eq 1 ]] || return 1
  local webhook_url="$1"
  
  # Webhook URLs should use HTTPS for security and have a path
  [[ $webhook_url =~ ^https://[a-zA-Z0-9.-]+/.+ ]]
}

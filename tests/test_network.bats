#!/usr/bin/env bats
# Copyright (c) 2025 Michele Tavella <meeghele@proton.me>
# Licensed under the MIT License. See LICENSE file for details.

load ../harness
load test_helpers

# Set default test domain
TEST_DOMAIN="${TEST_DOMAIN:-example.com}"

# Basic connectivity tests
@test "can_connect_to with valid TCP connections" {
  # Test HTTPS (port 443)
  run can_connect_to "$TEST_DOMAIN" 443 tcp
  [ "$status" -eq 0 ]
  
  # Test HTTP (port 80)  
  run can_connect_to "$TEST_DOMAIN" 80 tcp
  [ "$status" -eq 0 ]
}

@test "can_connect_to with local SSH" {
  skip_if_ci_with_reason "SSH service not available in CI containers"
  # Test local loopback SSH
  run can_connect_to "127.0.0.1" 22 tcp
  [ "$status" -eq 0 ]
}

@test "can_connect_to with valid UDP connections" {
  # Test DNS (port 53)
  run can_connect_to "1.1.1.1" 53 udp
  [ "$status" -eq 0 ]
  
  run can_connect_to "8.8.8.8" 53 udp
  [ "$status" -eq 0 ]
}

@test "can_connect_to with invalid protocols" {
  run can_connect_to "$TEST_DOMAIN" 80 "invalid"
  [ "$status" -eq 1 ]
  
  run can_connect_to "$TEST_DOMAIN" 80 "TCP"  # Case sensitive
  [ "$status" -eq 1 ]
  
  run can_connect_to "$TEST_DOMAIN" 80 "UDP"  # Case sensitive
  [ "$status" -eq 1 ]
  
  run can_connect_to "$TEST_DOMAIN" 80 "http"
  [ "$status" -eq 1 ]
  
  run can_connect_to "$TEST_DOMAIN" 80 ""
  [ "$status" -eq 1 ]
}

@test "can_connect_to with invalid port numbers" {
  # Negative port
  run can_connect_to "$TEST_DOMAIN" -1 tcp
  [ "$status" -eq 1 ]
  
  # Port 0 (reserved)
  run can_connect_to "$TEST_DOMAIN" 0 tcp
  [ "$status" -eq 1 ]
  
  # Port > 65535
  run can_connect_to "$TEST_DOMAIN" 65536 tcp
  [ "$status" -eq 1 ]
  
  run can_connect_to "$TEST_DOMAIN" 99999 tcp
  [ "$status" -eq 1 ]
  
  # Non-numeric port
  run can_connect_to "$TEST_DOMAIN" "abc" tcp
  [ "$status" -eq 1 ]
  
  # Empty port
  run can_connect_to "$TEST_DOMAIN" "" tcp
  [ "$status" -eq 1 ]
  
  # Port with spaces
  run can_connect_to "$TEST_DOMAIN" " 80" tcp
  [ "$status" -eq 1 ]
  
  run can_connect_to "$TEST_DOMAIN" "80 " tcp
  [ "$status" -eq 1 ]
}

@test "can_connect_to with invalid hostnames" {
  # Non-existent domain
  run can_connect_to "this-domain-should-never-exist-12345.com" 80 tcp
  [ "$status" -eq 1 ]
  
  # Empty hostname
  run can_connect_to "" 80 tcp
  [ "$status" -eq 1 ]
  
  # Invalid IP format
  run can_connect_to "256.256.256.256" 80 tcp
  [ "$status" -eq 1 ]
  
  # Hostname with spaces
  run can_connect_to " $TEST_DOMAIN" 80 tcp
  [ "$status" -eq 1 ]
  
  run can_connect_to "$TEST_DOMAIN " 80 tcp
  [ "$status" -eq 1 ]
}

@test "can_connect_to with unreachable ports" {
  # Typically closed port on loopback
  run can_connect_to "127.0.0.1" 12345 tcp
  [ "$status" -eq 1 ]
  
  # Very high port number (but valid range)
  run can_connect_to "127.0.0.1" 65534 tcp
  [ "$status" -eq 1 ]
}

@test "can_connect_to stress test with multiple rapid connections" {
  # Test multiple rapid connections to ensure function handles concurrency
  for i in {1..5}; do
    run can_connect_to "1.1.1.1" 53 udp
    [ "$status" -eq 0 ]
  done
}

# IP validation comprehensive tests
@test "is_ip with all valid IP ranges" {
  # Class A
  run is_ip "10.0.0.1"
  [ "$status" -eq 0 ]
  
  # Class B
  run is_ip "172.16.0.1"
  [ "$status" -eq 0 ]
  
  # Class C
  run is_ip "192.168.1.1"
  [ "$status" -eq 0 ]
  
  # Public IPs
  run is_ip "8.8.8.8"
  [ "$status" -eq 0 ]
  
  run is_ip "1.1.1.1"
  [ "$status" -eq 0 ]
  
  # Loopback
  run is_ip "127.0.0.1"
  [ "$status" -eq 0 ]
  
  # Broadcast
  run is_ip "255.255.255.255"
  [ "$status" -eq 0 ]
  
  # Network address
  run is_ip "0.0.0.0"
  [ "$status" -eq 0 ]
}

@test "is_ip with boundary values for each octet" {
  # Test each octet at boundary values
  run is_ip "0.0.0.0"
  [ "$status" -eq 0 ]
  
  run is_ip "255.0.0.0"
  [ "$status" -eq 0 ]
  
  run is_ip "0.255.0.0"
  [ "$status" -eq 0 ]
  
  run is_ip "0.0.255.0"
  [ "$status" -eq 0 ]
  
  run is_ip "0.0.0.255"
  [ "$status" -eq 0 ]
  
  run is_ip "255.255.255.255"
  [ "$status" -eq 0 ]
}

@test "is_ip with invalid octet values" {
  # Values > 255
  run is_ip "256.0.0.0"
  [ "$status" -eq 1 ]
  
  run is_ip "0.256.0.0"
  [ "$status" -eq 1 ]
  
  run is_ip "0.0.256.0"
  [ "$status" -eq 1 ]
  
  run is_ip "0.0.0.256"
  [ "$status" -eq 1 ]
  
  run is_ip "999.999.999.999"
  [ "$status" -eq 1 ]
  
  # Negative values
  run is_ip "-1.0.0.0"
  [ "$status" -eq 1 ]
  
  # Non-numeric octets
  run is_ip "a.b.c.d"
  [ "$status" -eq 1 ]
  
  run is_ip "192.168.1.a"
  [ "$status" -eq 1 ]
}

@test "is_ip with malformed IP addresses" {
  # Too many octets
  run is_ip "192.168.1.1.1"
  [ "$status" -eq 1 ]
  
  # Too few octets
  run is_ip "192.168.1"
  [ "$status" -eq 1 ]
  
  run is_ip "192.168"
  [ "$status" -eq 1 ]
  
  run is_ip "192"
  [ "$status" -eq 1 ]
  
  # Empty octets
  run is_ip "192..1.1"
  [ "$status" -eq 1 ]
  
  run is_ip ".168.1.1"
  [ "$status" -eq 1 ]
  
  run is_ip "192.168.1."
  [ "$status" -eq 1 ]
  
  # Leading/trailing dots
  run is_ip ".192.168.1.1"
  [ "$status" -eq 1 ]
  
  run is_ip "192.168.1.1."
  [ "$status" -eq 1 ]
  
  # Spaces
  run is_ip "192.168.1.1 "
  [ "$status" -eq 1 ]
  
  run is_ip " 192.168.1.1"
  [ "$status" -eq 1 ]
  
  run is_ip "192.168. 1.1"
  [ "$status" -eq 1 ]
}

# Port validation tests
@test "port_in_range with valid ports" {
  run port_in_range 1
  [ "$status" -eq 0 ]
  
  run port_in_range 80
  [ "$status" -eq 0 ]
  
  run port_in_range 443
  [ "$status" -eq 0 ]
  
  run port_in_range 8080
  [ "$status" -eq 0 ]
  
  run port_in_range 65535
  [ "$status" -eq 0 ]
  
  run port_in_range 22
  [ "$status" -eq 0 ]
  
  run port_in_range 3306
  [ "$status" -eq 0 ]
}

@test "port_in_range with invalid ports" {
  run port_in_range 0
  [ "$status" -eq 1 ]
  
  run port_in_range -1
  [ "$status" -eq 1 ]
  
  run port_in_range 65536
  [ "$status" -eq 1 ]
  
  run port_in_range 99999
  [ "$status" -eq 1 ]
  
  run port_in_range "abc"
  [ "$status" -eq 1 ]
  
  run port_in_range ""
  [ "$status" -eq 1 ]
  
  run port_in_range "3.14"
  [ "$status" -eq 1 ]
}

@test "is_privileged_port tests" {
  # Privileged ports (1-1023)
  run is_privileged_port 1
  [ "$status" -eq 0 ]
  
  run is_privileged_port 22
  [ "$status" -eq 0 ]
  
  run is_privileged_port 80
  [ "$status" -eq 0 ]
  
  run is_privileged_port 443
  [ "$status" -eq 0 ]
  
  run is_privileged_port 1023
  [ "$status" -eq 0 ]
  
  # Non-privileged ports
  run is_privileged_port 1024
  [ "$status" -eq 1 ]
  
  run is_privileged_port 8080
  [ "$status" -eq 1 ]
  
  run is_privileged_port 65535
  [ "$status" -eq 1 ]
  
  # Invalid ports
  run is_privileged_port 0
  [ "$status" -eq 1 ]
  
  run is_privileged_port -1
  [ "$status" -eq 1 ]
}

# IPv6 validation tests
@test "is_ipv6 with valid IPv6 addresses" {
  run is_ipv6 "2001:db8::1"
  [ "$status" -eq 0 ]
  
  run is_ipv6 "::1"
  [ "$status" -eq 0 ]
  
  run is_ipv6 "::"
  [ "$status" -eq 0 ]
  
  run is_ipv6 "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
  [ "$status" -eq 0 ]
  
  run is_ipv6 "fe80::1"
  [ "$status" -eq 0 ]
  
  run is_ipv6 "::ffff:192.0.2.1"
  [ "$status" -eq 0 ]
}

@test "is_ipv6 with invalid IPv6 addresses" {
  run is_ipv6 "192.168.1.1"
  [ "$status" -eq 1 ]
  
  run is_ipv6 "invalid"
  [ "$status" -eq 1 ]
  
  run is_ipv6 "2001:db8::1::2"
  [ "$status" -eq 1 ]
  
  run is_ipv6 ""
  [ "$status" -eq 1 ]
  
  run is_ipv6 "2001:db8:85a3::8a2e::7334"
  [ "$status" -eq 1 ]
}

# CIDR validation tests
@test "is_cidr with valid CIDR notation" {
  run is_cidr "192.168.1.0/24"
  [ "$status" -eq 0 ]
  
  run is_cidr "10.0.0.0/8"
  [ "$status" -eq 0 ]
  
  run is_cidr "172.16.0.0/16"
  [ "$status" -eq 0 ]
  
  run is_cidr "192.168.1.1/32"
  [ "$status" -eq 0 ]
  
  run is_cidr "0.0.0.0/0"
  [ "$status" -eq 0 ]
  
  run is_cidr "255.255.255.255/32"
  [ "$status" -eq 0 ]
}

@test "is_cidr with invalid CIDR notation" {
  # Invalid IP addresses
  run is_cidr "256.1.1.1/24"
  [ "$status" -eq 1 ]
  
  run is_cidr "192.168.1/24"
  [ "$status" -eq 1 ]
  
  # Invalid subnet masks
  run is_cidr "192.168.1.0/33"
  [ "$status" -eq 1 ]
  
  run is_cidr "192.168.1.0/-1"
  [ "$status" -eq 1 ]
  
  run is_cidr "192.168.1.0/abc"
  [ "$status" -eq 1 ]
  
  # Missing slash
  run is_cidr "192.168.1.0"
  [ "$status" -eq 1 ]
  
  # Empty string
  run is_cidr ""
  [ "$status" -eq 1 ]
  
  # Missing parts
  run is_cidr "/24"
  [ "$status" -eq 1 ]
  
  run is_cidr "192.168.1.0/"
  [ "$status" -eq 1 ]
}

# MAC address validation tests
@test "is_mac_address with valid MAC addresses" {
  run is_mac_address "aa:bb:cc:dd:ee:ff"
  [ "$status" -eq 0 ]
  
  run is_mac_address "00:11:22:33:44:55"
  [ "$status" -eq 0 ]
  
  run is_mac_address "AA:BB:CC:DD:EE:FF"
  [ "$status" -eq 0 ]
  
  run is_mac_address "01:23:45:67:89:ab"
  [ "$status" -eq 0 ]
  
  # Dash format
  run is_mac_address "aa-bb-cc-dd-ee-ff"
  [ "$status" -eq 0 ]
  
  run is_mac_address "00-11-22-33-44-55"
  [ "$status" -eq 0 ]
}

@test "is_mac_address with invalid MAC addresses" {
  # Wrong length
  run is_mac_address "aa:bb:cc:dd:ee"
  [ "$status" -eq 1 ]
  
  run is_mac_address "aa:bb:cc:dd:ee:ff:gg"
  [ "$status" -eq 1 ]
  
  # Invalid characters
  run is_mac_address "aa:bb:cc:dd:ee:zz"
  [ "$status" -eq 1 ]
  
  run is_mac_address "aa:bb:cc:dd:ee:g0"
  [ "$status" -eq 1 ]
  
  # Wrong separators
  run is_mac_address "aa.bb.cc.dd.ee.ff"
  [ "$status" -eq 1 ]
  
  run is_mac_address "aa bb cc dd ee ff"
  [ "$status" -eq 1 ]
  
  # Mixed separators
  run is_mac_address "aa:bb-cc:dd:ee:ff"
  [ "$status" -eq 1 ]
  
  # No separators
  run is_mac_address "aabbccddeeff"
  [ "$status" -eq 1 ]
  
  # Empty string
  run is_mac_address ""
  [ "$status" -eq 1 ]
}

# Hostname validation tests
@test "is_valid_hostname with valid hostnames" {
  run is_valid_hostname "localhost"
  [ "$status" -eq 0 ]
  
  run is_valid_hostname "web-server"
  [ "$status" -eq 0 ]
  
  run is_valid_hostname "db01"
  [ "$status" -eq 0 ]
  
  run is_valid_hostname "app-server-123"
  [ "$status" -eq 0 ]
  
  run is_valid_hostname "host"
  [ "$status" -eq 0 ]
  
  run is_valid_hostname "a"
  [ "$status" -eq 0 ]
  
  # Max length (63 chars)
  long_hostname=$(printf 'a%.0s' {1..63})
  run is_valid_hostname "$long_hostname"
  [ "$status" -eq 0 ]
}

@test "is_valid_hostname with invalid hostnames" {
  # Cannot start with hyphen
  run is_valid_hostname "-invalid"
  [ "$status" -eq 1 ]
  
  # Cannot end with hyphen
  run is_valid_hostname "invalid-"
  [ "$status" -eq 1 ]
  
  # Cannot contain dots (use is_valid_fqdn for FQDNs)
  run is_valid_hostname "host.domain.com"
  [ "$status" -eq 1 ]
  
  # Cannot contain special characters
  run is_valid_hostname "host@domain"
  [ "$status" -eq 1 ]
  
  run is_valid_hostname "host_name"
  [ "$status" -eq 1 ]
  
  run is_valid_hostname "host.name"
  [ "$status" -eq 1 ]
  
  # Cannot be empty
  run is_valid_hostname ""
  [ "$status" -eq 1 ]
  
  # Too long (>63 chars)
  too_long_hostname=$(printf 'a%.0s' {1..64})
  run is_valid_hostname "$too_long_hostname"
  [ "$status" -eq 1 ]
}

# FQDN validation tests
@test "is_valid_fqdn with valid FQDNs" {
  run is_valid_fqdn "$TEST_DOMAIN"
  [ "$status" -eq 0 ]
  
  run is_valid_fqdn "www.$TEST_DOMAIN"
  [ "$status" -eq 0 ]
  
  run is_valid_fqdn "api.v1.$TEST_DOMAIN"
  [ "$status" -eq 0 ]
  
  run is_valid_fqdn "mail.google.com"
  [ "$status" -eq 0 ]
  
  run is_valid_fqdn "long-subdomain.example.org"
  [ "$status" -eq 0 ]
}

@test "is_valid_fqdn with invalid FQDNs" {
  # Single hostname (no dots)
  run is_valid_fqdn "localhost"
  [ "$status" -eq 1 ]
  
  # Consecutive dots
  run is_valid_fqdn "host..domain.com"
  [ "$status" -eq 1 ]
  
  # Starting with dot
  run is_valid_fqdn ".example.com"
  [ "$status" -eq 1 ]
  
  # Ending with dot (technically valid but we reject)
  run is_valid_fqdn "example.com."
  [ "$status" -eq 1 ]
  
  # Empty parts
  run is_valid_fqdn "host..com"
  [ "$status" -eq 1 ]
  
  # Invalid characters
  run is_valid_fqdn "host@domain.com"
  [ "$status" -eq 1 ]
  
  # Empty string
  run is_valid_fqdn ""
  [ "$status" -eq 1 ]
}

# Private IP tests
@test "is_private_ip with private IP addresses" {
  # 10.0.0.0/8
  run is_private_ip "10.0.0.1"
  [ "$status" -eq 0 ]
  
  run is_private_ip "10.255.255.255"
  [ "$status" -eq 0 ]
  
  # 192.168.0.0/16  
  run is_private_ip "192.168.1.1"
  [ "$status" -eq 0 ]
  
  run is_private_ip "192.168.255.255"
  [ "$status" -eq 0 ]
  
  # 172.16.0.0/12
  run is_private_ip "172.16.0.1"
  [ "$status" -eq 0 ]
  
  run is_private_ip "172.31.255.255"
  [ "$status" -eq 0 ]
}

@test "is_private_ip with public IP addresses" {
  run is_private_ip "8.8.8.8"
  [ "$status" -eq 1 ]
  
  run is_private_ip "1.1.1.1"
  [ "$status" -eq 1 ]
  
  run is_private_ip "208.67.222.222"
  [ "$status" -eq 1 ]
  
  # Edge cases
  run is_private_ip "9.255.255.255"
  [ "$status" -eq 1 ]
  
  run is_private_ip "11.0.0.1"
  [ "$status" -eq 1 ]
  
  run is_private_ip "172.15.255.255"
  [ "$status" -eq 1 ]
  
  run is_private_ip "172.32.0.1"
  [ "$status" -eq 1 ]
  
  run is_private_ip "192.167.255.255"
  [ "$status" -eq 1 ]
  
  run is_private_ip "192.169.0.1"
  [ "$status" -eq 1 ]
}

# Loopback IP tests  
@test "is_loopback_ip with loopback addresses" {
  run is_loopback_ip "127.0.0.1"
  [ "$status" -eq 0 ]
  
  run is_loopback_ip "127.0.0.2"
  [ "$status" -eq 0 ]
  
  run is_loopback_ip "127.255.255.255"
  [ "$status" -eq 0 ]
  
  run is_loopback_ip "127.1.1.1"
  [ "$status" -eq 0 ]
}

@test "is_loopback_ip with non-loopback addresses" {
  run is_loopback_ip "192.168.1.1"
  [ "$status" -eq 1 ]
  
  run is_loopback_ip "10.0.0.1"
  [ "$status" -eq 1 ]
  
  run is_loopback_ip "8.8.8.8"
  [ "$status" -eq 1 ]
  
  run is_loopback_ip "126.255.255.255"
  [ "$status" -eq 1 ]
  
  run is_loopback_ip "128.0.0.1"
  [ "$status" -eq 1 ]
}
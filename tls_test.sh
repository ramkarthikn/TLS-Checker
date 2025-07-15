#!/bin/bash

# Configuration
DOMAIN=""
IP=""
PORT=""

echo "Checking TLS versions for $DOMAIN:$PORT (connecting to $IP)..."
echo "----------------------------------------------------"

# List of TLS protocols to test
# Note: -tls1_3 is for TLS 1.3, -tls1_2 for TLS 1.2, etc.
# Some older OpenSSL versions might not support all options or use different flags.
TLS_VERSIONS=(
    "TLSv1.3"
    "TLSv1.2"
    "TLSv1.1"
    "TLSv1.0"
)

# Corresponding OpenSSL flags for minimum and maximum protocol versions
# Modern OpenSSL defaults to negotiating the highest common version if not restricted.
# We'll use s_client's specific version flags.
TLS_FLAGS=(
    "-tls1_3"
    "-tls1_2"
    "-tls1_1"
    "-tls1"
)

for i in "${!TLS_VERSIONS[@]}"; do
    VERSION="${TLS_VERSIONS[$i]}"
    FLAG="${TLS_FLAGS[$i]}"

    echo -n "  Testing $VERSION... "

    # Use openssl s_client to attempt a connection
    # -connect: specifies host and port
    # $FLAG: forces the specific TLS version (e.g., -tls1_3)
    # -servername: important for SNI (Server Name Indication)
    # -quiet: suppresses some output
    # -noout: prevents certificate output
    # -debug: (optional) can provide more verbose output if connection fails
    # 2>&1: redirects stderr to stdout
    # grep -q "Cipher is" or "TLSv" (more robust) to check for successful handshake
    # timeout 5s: ensures the command doesn't hang indefinitely

    # Using -starttls smtp, -starttls ftp etc. can be used for services that upgrade to TLS
    # but for HTTPS (port 443), direct connection is sufficient.

    # We connect directly to the IP to ensure we're testing the specified server,
    # but still pass the domain with -servername for SNI.
    if openssl s_client -connect "${IP}:${PORT}" "${FLAG}" -servername "${DOMAIN}" \
        </dev/null 2>&1 | grep -q "Protocol  : ${VERSION}" || \
       openssl s_client -connect "${IP}:${PORT}" "${FLAG}" -servername "${DOMAIN}" \
        </dev/null 2>&1 | grep -q "Cipher is" ; then
        echo "SUPPORTED"
    else
        echo "NOT SUPPORTED (or connection error)"
        # For more detailed error, remove /dev/null and grep, and inspect full output
        # Example to debug:
        # openssl s_client -connect "${IP}:${PORT}" "${FLAG}" -servername "${DOMAIN}" -debug </dev/null
    fi
done

echo "----------------------------------------------------"
echo "Note: 'NOT SUPPORTED' can also mean connection refused/timeout or other network issues."
echo "      The 'Protocol' line is the most reliable indicator of handshake success."
echo "      For some older OpenSSL versions or specific server configs, 'Cipher is' might be the only success indicator."
echo "      Ensure 'openssl' command is available in your PATH."
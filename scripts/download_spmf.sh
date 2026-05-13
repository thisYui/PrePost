#!/bin/bash
# cmd/download_spmf.sh

set -e

echo "========================================"
echo " Download SPMF jar"
echo "========================================"

# Paths
SPMF_DIR="spmf"
JAR_PATH="$SPMF_DIR/spmf.jar"

mkdir -p "$SPMF_DIR"

# Check Java
echo ""
echo "[1/2] Checking Java..."

if command -v java &> /dev/null; then
    java -version
else
    echo "[WARN] Java is not installed or not available in PATH."
    echo "SPMF jar can still be downloaded, but experiments need Java to run."
fi

# Download SPMF jar
echo ""
echo "[2/2] Checking SPMF jar..."

if [ ! -f "$JAR_PATH" ]; then
    echo "spmf.jar not found. Downloading..."

    if command -v wget &> /dev/null; then
        wget -O "$JAR_PATH" "https://www.philippe-fournier-viger.com/spmf/spmf.jar"
    elif command -v curl &> /dev/null; then
        curl -o "$JAR_PATH" "https://www.philippe-fournier-viger.com/spmf/spmf.jar"
    else
        echo "[ERROR] Neither wget nor curl found. Please install one to download SPMF jar."
        exit 1
    fi

    echo "[OK] Downloaded: $JAR_PATH"
else
    echo "[OK] Found existing: $JAR_PATH"
fi

echo ""
echo "========================================"
echo " SPMF download DONE"
echo "========================================"
echo "Jar path:"
echo "  $JAR_PATH"


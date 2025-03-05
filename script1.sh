#!/bin/bash
set -e  # Exit if any command fails

echo "🔍 Checking if 'recovery.img.lz4' exists..."
if [ -f recovery.img.lz4 ]; then
    echo "📦 Decompressing 'recovery.img.lz4'..."
    lz4 -B6 --content-size -f recovery.img.lz4 recovery.img || { echo "❌ ERROR: Failed to decompress recovery.img.lz4"; exit 1; }
    echo "✅ Decompression completed."
else
    echo "ℹ️ No 'recovery.img.lz4' found, skipping decompression."
fi

echo "🔍 Checking if 'recovery.img' exists..."
if [ ! -f recovery.img ]; then
    echo "❌ ERROR: recovery.img not found! Exiting."
    exit 1
fi

echo "📂 Copying 'recovery.img' to 'r.img'..."
cp recovery.img r.img
echo "✅ Copy complete."

echo "🔍 Checking for 'phh.pem' key..."
if [ ! -f phh.pem ]; then
    echo "🔑 Generating new RSA key (phh.pem)..."
    openssl genrsa -f4 -out phh.pem 4096 || { echo "❌ ERROR: Failed to generate RSA key"; exit 1; }
    chmod 600 phh.pem  # Secure the key
    echo "✅ RSA key generated successfully."
else
    echo "✅ 'phh.pem' already exists, skipping key generation."
fi

echo "✅ Script completed successfully!"

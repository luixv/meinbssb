#!/bin/bash

# Test script for token-service
# This script tests the token service endpoints locally

echo "Testing Token Service..."
echo ""

# Check if the service is running
echo "1. Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:3002/health)
echo "Health response: $HEALTH_RESPONSE"
echo ""

# Test token retrieval
echo "2. Testing token retrieval..."
TOKEN_RESPONSE=$(curl -s -X POST http://localhost:3002/get-token)
echo "Token response: $TOKEN_RESPONSE"
echo ""

# Check if token was received
if echo "$TOKEN_RESPONSE" | grep -q "Token"; then
    echo "✓ Token service is working correctly!"
    exit 0
else
    echo "✗ Token service failed to return a token"
    exit 1
fi

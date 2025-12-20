#!/bin/bash

# Usage: ./test-api.sh [YOUR_API_KEY]

API_KEY=$1

if [ -z "$API_KEY" ]; then
    read -p "Enter your Zeabur API Key: " API_KEY
fi

if [ -z "$API_KEY" ]; then
    echo "Error: API Key is required."
    exit 1
fi

echo "Testing API Key..."
echo ""

curl --request POST \
  --url https://api.zeabur.com/graphql \
  --header "Authorization: Bearer $API_KEY" \
  --header "Content-Type: application/json" \
  --data '{"query":"query { me { _id username name } }"}' | json_pp

echo ""

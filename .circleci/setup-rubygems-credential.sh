#!/usr/bin/env bash

CREDENTIAL_DIR="$HOME/.gem"
CREDENTIAL_FILE="$CREDENTIAL_DIR/credentials"

mkdir $CREDENTIAL_DIR
echo -e "---\n:rubygems_api_key: $RUBYGEMS_API_KEY" > $CREDENTIAL_FILE
chmod 0600 $CREDENTIAL_FILE
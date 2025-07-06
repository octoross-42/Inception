#!/usr/bin/env bash
set -e

if [ -f ./srcs/.env ]; then
  . ./srcs/.env
fi

if [ -z "$DOMAIN_NAME" ]; then
  echo "❌ Start: Pls define DOMAIN_NAME in env file" >&2
  exit 1
fi

DOMAIN_NAME="$DOMAIN_NAME" ./srcs/tools/redirect-localhost.sh

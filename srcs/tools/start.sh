#!/usr/bin/env bash
set -e

if [ -f ./srcs/.env ]; then
  . ./srcs/.env
fi

if [ -z "$DOMAIN_NAME" ]; then
  echo "❌ Start: Pls define DOMAIN_NAME in env file" >&2
  exit 1
fi

./tools/redirect-localhost.sh

#!/usr/bin/env bash

REPO_ROOT=$(git rev-parse --show-toplevel)

if [ $? -ne 0 ]; then
  echo "Not inside a Git repository"
  exit 1
fi

if [[ ! -f $REPO_ROOT/temp/jwt ]]
then
  mkdir -p $REPO_ROOT/temp
  openssl rand -hex 32 | tr -d "\n" | tee > $REPO_ROOT/temp/jwt
else
  echo "$REPO_ROOT/temp/jwt already exists!"
fi

kubectl create secret generic jwt-secret --from-file=$REPO_ROOT/temp/jwt

# Clean up temp file
rm -r $REPO_ROOT/temp

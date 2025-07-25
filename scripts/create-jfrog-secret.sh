#!/bin/bash
# Usage: ./create-jfrog-secret.sh <username> <apikey>

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <username> <apikey>"
  exit 1
fi

USERNAME=$1
APIKEY=$2

kubectl create secret generic jfrog-auth \
  --from-literal=username=$USERNAME \
  --from-literal=apikey=$APIKEY \
  -n dev --dry-run=client -o yaml | kubectl apply --validate=false -f -

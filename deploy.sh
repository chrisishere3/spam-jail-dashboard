#!/bin/bash
# Deploy spamjail.chris-as-is.com to Cloudflare Pages.
# Usage: ./deploy.sh
set -euo pipefail
cd "$(dirname "$0")"

export CLOUDFLARE_API_TOKEN=$(grep '^CLOUDFLARE_API_TOKEN=' ~/.env | cut -d= -f2)
export CLOUDFLARE_ACCOUNT_ID=$(grep '^CLOUDFLARE_ACCOUNT_ID=' ~/.env | cut -d= -f2)

# Publish only the page itself.
rm -rf .cf-dist
mkdir .cf-dist
cp index.html .cf-dist/

npx wrangler pages deploy .cf-dist --project-name spam-jail-dashboard --branch main --commit-dirty=true
rm -rf .cf-dist

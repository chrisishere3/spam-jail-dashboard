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

# Hosted copy gets Cloudflare Web Analytics (cookieless visit counting).
# The repo's index.html stays clean so self-hosters get zero tracking.
BEACON="<!-- Cloudflare Web Analytics --><script type='module' src='https://static.cloudflareinsights.com/beacon.min.js' data-cf-beacon='{\"token\": \"dde6d1b372cf4c58a8cee734500099c8\"}'></script><!-- End Cloudflare Web Analytics -->"
python3 - "$BEACON" <<'PYEOF'
import sys
beacon = sys.argv[1]
p = '.cf-dist/index.html'
h = open(p).read()
assert h.count('</body>') == 1
open(p, 'w').write(h.replace('</body>', beacon + '\n</body>'))
print('beacon injected into hosted copy')
PYEOF

npx wrangler pages deploy .cf-dist --project-name spam-jail-dashboard --branch main --commit-dirty=true
rm -rf .cf-dist

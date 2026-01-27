#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Please enter version like: ./release.sh v1.2.3'
    echo 'Check existing with: git tag'
    exit 0
fi

VERSION=$1

git tag -a $VERSION -m "$VERSION"
git push origin $VERSION
docker login

DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1429742263109419081/E_LZB4dV9yO1F3E-SaLFn2okYcbgRTKB7YrGWKqnpLaCVgKSgYSG_M2ODbeXbo9mz0Al
GIT_URL=https://github.com/swissinnovationlab/dorian/releases/tag/$VERSION

echo -n "Update release notes $GIT_URL: "
read

VERSION="$1"
MESSAGE="🧪 RELEASE – Dorian $VERSION
Date: $(date)
GIT: $GIT_URL

jq -n --arg username "release_bot" --arg content "$MESSAGE" '{username:$username, content:$content}' | curl -sS -H "Content-Type: application/json" -d @- "$DISCORD_WEBHOOK_URL"

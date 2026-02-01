#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Please enter version like: ./release.sh v1.2.3'
    echo 'Check existing with: git tag'
    exit 0
fi

VERSION=$1

git tag -a $VERSION -m "$VERSION"
git push origin $VERSION

DISCORD_WEBHOOK_URL=""
GIT_URL=https://github.com/swissinnovationlab/dorian/releases/tag/$VERSION

echo -n "Update release notes $GIT_URL: "
read

VERSION="$1"
MESSAGE="🧪 RELEASE – Dorian $VERSION
Date: $(date)
GIT: $GIT_URL"

jq -n --arg username "release_bot" --arg content "$MESSAGE" '{username:$username, content:$content}' | curl -sS -H "Content-Type: application/json" -d @- "$DISCORD_WEBHOOK_URL"

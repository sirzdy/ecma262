#!/bin/bash

declare -r PRIVATE_KEY_FILE_NAME='deploy_key'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

REPO=`git config remote.docschina.url`
SSH_REPO=${REPO}
git config --global user.name "Travis CI"
git config --global user.email "ci@travis-ci.org"
git remote set-url origin "${SSH_REPO}"

# Decrypt the file containing the private key

openssl aes-256-cbc \
    -K  $encrypted_1e2182e20f4c_key \
    -iv $encrypted_1e2182e20f4c_iv \
    -in "$(dirname "$BASH_SOURCE")/${PRIVATE_KEY_FILE_NAME}.enc" \
    -out ~/.ssh/$PRIVATE_KEY_FILE_NAME -d

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Enable SSH authentication

chmod 600 ~/.ssh/$PRIVATE_KEY_FILE_NAME
echo "Host github.com" >> ~/.ssh/config
echo "  IdentityFile ~/.ssh/$PRIVATE_KEY_FILE_NAME" >> ~/.ssh/config

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Update the content from the `gh-pages` branch

$(npm bin)/update-branch --commands "npm run build" \
                         --commit-message "Update gh-pages [skip ci]" \
                         --directory "out" \
                         --distribution-branch "gh-pages" \
                         --source-branch "master"

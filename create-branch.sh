#! /bin/bash
echo "New branch name?"
read branch
git checkout main && git pull origin main && git checkout -b $branch
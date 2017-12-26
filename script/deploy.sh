#!/bin/bash
# Credits to: https://github.com/merakipost/merakipost

set -e # Exit with nonzero exit code if anything fails

echo "Setting the source and destination branches"
SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages-wip"

echo "Defining the function to build the site"
function doCompile {
    echo "Building the site"
    bundle exec jekyll build -d out/
}

echo "Defining the function to minify the site"
function doMinify {
    echo "Minifying the site"
    python3.5 css-html-js-minify/css-html-js-minify.py ${$PWD}/out/ --overwrite
}

# Pull requests and commits to other branches shouldn't try to deploy, just build to verify
if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Skipping deploy; just doing a build."
    doCompile
    exit 0
fi

# Save some useful information
REPO="https://${GH_TOKEN}@github.com/SimCMinMax/herodamage.git"
SHA=`git rev-parse --verify HEAD`

# Clone the existing gh-pages for this repo into out/
# Create a new empty branch if gh-pages doesn't exist yet (should only happen on first deploy)
echo "Cloning the repository to out"
git clone ${REPO} out
echo "Navigating to out"
cd out
echo "Checking out the target branch"
git checkout ${TARGET_BRANCH} || git checkout --orphan ${TARGET_BRANCH}
echo "Going back to root"
cd ..

# Clean out existing contents
echo "Cleaning up contents from out"
rm -rf out/**/* || exit 0

# Run our compile script
doCompile

# Run our minify script
doMinify

# Now let's go have some fun with the cloned repo
echo "Navigating to out"
cd out
echo "Setting Git username and email"
git config user.name ${GH_USERNAME}
git config user.email ${GH_EMAIL}

# If there are no changes to the compiled out (e.g. this is a README update) then just bail.
if [ -z `git diff --exit-code` ]; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi

# Commit the "changes", i.e. the new version.
# The delta will show diffs between new and old versions.
echo "Adding all changes and committing"
git add --all .
git commit -m "Deploy: ${SHA}"

# Now that we're all set up, we can push.
echo "Pushing changes to the target branch on repo"
git push ${REPO} ${TARGET_BRANCH}

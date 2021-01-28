#!/bin/bash
set -x

################################################################################
# Credits: https://tech.michaelaltfield.net/2020/07/18/sphinx-rtd-github-pages-1/
################################################################################

################
# INFO MESSAGE #
###############

echo "### BUILDING DOCUMENTATION FOR ${GITHUB_REPOSITORY} ###"
echo "Initiated by ${GITHUB_ACTOR}"
echo "Event: ${GITHUB_EVENT_NAME}"

################
# DEPENDENCIES #
################

apt-get update && apt-get install -y git python3-sphinx python3-sphinx-rtd-theme rsync

#####################
# DECLARE VARIABLES #
#####################

export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)

##############
# BUILD DOCS #
##############

make -C docs clean
make -C docs html

#######################
# Update GitHub Pages #
#######################

git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"

docroot=`mktemp -d`
rsync -av "docs/_build/html/" "${docroot}/"

pushd "${docroot}"

# don't bother maintaining history; just generate fresh
git init
git remote add deploy "https://token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git checkout -b gh-pages

# add .nojekyll to the root so that github won't 404 on content added to dirs
# that start with an underscore (_), such as our "_content" dir..
touch .nojekyll

touch README.md
echo "This is not the branch you are looking for. Check the other branches for the actual repository content." > README.md

# copy the resulting html pages built from sphinx above to our new git repo
git add .

# commit all the new files
msg="Updating Docs for commit ${GITHUB_SHA} made on `date -d"@${SOURCE_DATE_EPOCH}" --iso-8601=seconds` from ${GITHUB_REF} by ${GITHUB_ACTOR}"
git commit -am "${msg}"

# overwrite the contents of the gh-pages branch on our github.com repo
git push deploy gh-pages --force

popd # return to main repo sandbox root

# exit cleanly
exit 0

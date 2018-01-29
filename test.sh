#!/usr/bin/env bash
# Licensed under the MIT license. See LICENSE file on the project webpage for details.

# Determine the appropriate github branch to clone using environment variables

BRANCH=${TRAVIS_PULL_REQUEST_BRANCH:-$TRAVIS_BRANCH}
REPO=$TRAVIS_REPO_SLUG
FOLDER=$(basename $REPO)
echo "BRANCH=$BRANCH, REPO=$REPO, FOLDER=$FOLDER"

# Connect to container
docker exec -i stepdo0 /bin/bash -s <<EOF

# test systemd
if systemctl > /dev/null ; then
    echo "success: has systemd"
else
    echo "FAILURE: no systemd"
    exit 1
fi

env
exit 0
#todo: below

# test networking
apt update
if apt-get clean; apt-get -d --reinstall install apt | grep "Download complete" ; then
    echo "success: has networking"
else
    echo "FAILURE: no networking"
    exit 1
fi

# install git
if apt install -y git ; then
    echo "success: apt install git"
else
    echo "FAILURE: can't apt install git"
    exit 1
fi

# clone repo
if pushd /var/tmp && git clone --depth=50 --branch=$BRANCH https://github.com/${REPO} ; then
    echo "success: clone repo inside of container"
else
    echo "FAILURE: can't clone repo inside of container"
    exit 1
fi

# run custom tests
if pushd $FOLDER && bash your-tests-go-here.sh ; then
    echo "success: your-tests-go-here.sh passed"
else
    echo "FAILURE: your-tests-go-here.sh failed"
    exit 1
fi

EOF

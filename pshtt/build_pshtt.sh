#!/bin/bash

###
# Set up the Python virtual environment
###
VENV_DIR=/venv
python -m venv $VENV_DIR
source $VENV_DIR/bin/activate

##
# Force pip to install sslyze from GitHub, so it depends on
# cryptography 2.x and not 1.9. Also force pip to install the latest
# pshtt from GitHub.
##
source $VENV_DIR/bin/activate
pip install --upgrade \
    git+https://github.com/nabla-c0d3/sslyze.git@master \
    git+https://github.com/dhs-ncats/pshtt.git@develop

###
# Install domain-scan
###
git clone https://github.com/18F/domain-scan
pip install -r domain-scan/requirements.txt

###
# Leave the Python virtual environment
###
deactivate

###
# Set up the build directory
###
BUILD_DIR=/build
mkdir -p $BUILD_DIR/bin

###
# Copy all packages, including any hidden dotfiles.  Also copy the
# pshtt executable.
###
cp -rT $VENV_DIR/lib/python3.6/site-packages/ $BUILD_DIR
cp -rT $VENV_DIR/lib64/python3.6/site-packages/ $BUILD_DIR
cp $VENV_DIR/bin/pshtt $BUILD_DIR/bin

###
# Copy in a snapshot of the public suffix list in text form
###
wget -O $BUILD_DIR/public-suffix-list.txt \
     https://publicsuffix.org/list/public_suffix_list.dat

# Lambda workaround for SQLite.
# RUN wget https://github.com/Miserlou/lambda-packages/raw/master/lambda_packages/sqlite3/python3.6-sqlite3-3.6.0.tar.gz | tar xz --directory=$BUILD_DIR

# Lambda workaround for cryptography (Lambda doesn't have openssl 1.0.2)
# RUN rm -rf $BUILD_DIR/cryptography \
#     && rm -rf $BUILD_DIR/cryptography-1.9-py3.6.egg-info
# RUN wget https://github.com/Miserlou/lambda-packages/raw/master/lambda_packages/cryptography/python3.6-cryptography-1.9.tar.gz | tar xz --directory=$BUILD_DIR

###
# Zip it all up
###
OUTPUT_DIR=/output
if [ ! -d $OUTPUT_DIR ]
then
    mkdir $OUTPUT_DIR
fi

if [ -e $OUTPUT_DIR/pshtt.zip ]
then
    rm $OUTPUT_DIR/pshtt.zip
fi
cd $BUILD_DIR
zip -rq9 $OUTPUT_DIR/pshtt.zip .
#!/usr/bin/env bash
# Files downloaded by this script are under the LICENSE of respective repositories and distributors.
# We are not responsible by any of these files

# All credits for the OpenVPN binaries goes for OpenVPN community:
# - https://openvpn.net/
# - https://github.com/OpenVPN/

# All credits for the patch files goes for 'samm-git'
# - https://smallhacks.wordpress.com/
# - https://github.com/samm-git/aws-vpn-client

set -e

OPENVPN_VERSION="2.6.19"
CURRENT_DIRNAME=${PWD##*/}

if [ "$CURRENT_DIRNAME" != "scripts" ]; then
    if ! [[ -d "scripts" ]]
    then
        echo "Could not find 'scripts' directory. Please run this script from the root directory of the repository."
        exit 255
    fi

    cd "scripts"
fi

ROOT_DIR="$(pwd)"
mkdir -p "$ROOT_DIR/../share/openvpn"

rm -rf tmp
mkdir tmp
cd tmp

# Download OpenVPN
echo "Downloading OpenVPN..."
curl -fL https://raw.githubusercontent.com/OpenVPN/openvpn/master/COPYING --output "$ROOT_DIR/../share/openvpn/COPYING"
curl -fL https://raw.githubusercontent.com/OpenVPN/openvpn/master/COPYRIGHT.GPL --output "$ROOT_DIR/../share/openvpn/COPYRIGHT.GPL"
curl -fL https://swupdate.openvpn.org/community/releases/openvpn-$OPENVPN_VERSION.tar.gz --output openvpn-$OPENVPN_VERSION.tar.gz
echo "18e466dcc8edb5417a452599a85f6767eb48c2e61a05d46ed1d1565fcf75296d0b33962ba332becb1da248718e96cf5a965054c7c7493f919606bf653f56b50b  openvpn-$OPENVPN_VERSION.tar.gz" | sha512sum -c -
echo "Decompressing OpenVPN..."
tar -xf openvpn-$OPENVPN_VERSION.tar.gz
rm -rf openvpn-$OPENVPN_VERSION.tar.gz
cd openvpn-$OPENVPN_VERSION || exit 1

# Apply OpenVPN patch by 'samm-git'
echo "Downloading OpenVPN Patch by 'samm-git'..."
curl -fL https://raw.githubusercontent.com/samm-git/aws-vpn-client/master/LICENSE --output "$ROOT_DIR/../share/openvpn/PATCH-LICENSE"
curl -fL https://raw.githubusercontent.com/samm-git/aws-vpn-client/master/openvpn-v2.6.12-aws.patch --output openvpn-v2.6.12-aws.patch
echo "d3d6831dd250af27c0e4fe1f9e820e157a0230d86b0c60ec21dae53266884bbf9dbc46ce2ba29c0f37efd640d2ccb614e81feaa1a66e238f2e259ff33472b2dc  openvpn-v2.6.12-aws.patch" | sha512sum -c -
echo "Applying OpenVPN Patch by 'samm-git'..."
patch -p1 <openvpn-v2.6.12-aws.patch

# Configure and build OpenVPN
echo "Building OpenVPN..."
./configure
make

echo "Copying OpenVPN..."
mkdir -p "$ROOT_DIR/../share/openvpn/bin"
cp src/openvpn/openvpn "$ROOT_DIR/../share/openvpn/bin/openvpn"

echo "Custom OpenVPN binary created."
cd "$ROOT_DIR"
rm -rf tmp

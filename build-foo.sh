#!/bin/bash

cd /build

echo "::info:: Creating foo package"
dpkg-deb --root-owner-group --build ./foo-1.2.3-4_amd64 ./foo-1.2.3-4_amd64.deb
echo "::info:: Created foo package"

GPG_TTY=$(tty)
export GPG_TTY

# Generate the key

echo "::info:: Generating GPG key"

gpg --batch --generate-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Name-Real: Test
Name-Comment: test key
Name-Email: info@example.com
Expire-Date: 0
%commit
EOF

echo "::info:: Generated GPG key"

#obtain the GPG key ID
KEYID=$(gpg --list-keys info@example.com | sed -n '2p' | cut -c31-)
echo "::info:: GPG key ID: $KEYID"

# Sign the package
echo "::info:: Signing the package"
debsigs --sign origin -k $KEYID foo-1.2.3-4_amd64.deb
echo "::info:: Signed the package"

echo ":::::::::: NOTE THE ABOVE WARNING BY debsigs command ::::::::::"


# Add the key
KEY_DIR=/usr/share/debsig/keyrings/${KEYID}
mkdir "${KEY_DIR}"
gpg --export "$KEYID" | tee "${KEY_DIR}/debsig.gpg" > /dev/null

# create policy file
POL_DIR="/etc/debsig/policies/${KEYID}"
mkdir "${POL_DIR}"
cat << EOT | tee "${POL_DIR}/test.pol" > /dev/null
<?xml version="1.0"?>
<!DOCTYPE Policy SYSTEM "http://www.debian.org/debsig/1.0/policy.dtd">
<Policy xmlns="http://www.debian.org/debsig/1.0/">
  <Origin Name="Test" id="${KEYID}" Description="Test &lt;info@example.com&gt;"/>
  <Selection>
    <Required Type="origin" File="debsig.gpg" id="${KEYID}"/>
  </Selection>
  <Verification MinOptional="0">
    <Required Type="origin" File="debsig.gpg" id="${KEYID}"/>
  </Verification>
</Policy>
EOT

# Verify the package
debsig-verify --debug --verbose "./foo-1.2.3-4_amd64.deb"

echo ":::::::::: NOTE the above "No applicable policy found"  by debsig-verify command ::::::::::"
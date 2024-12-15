# Debian Build Repo

## About

I posted a [question on stackoverflow](https://stackoverflow.com/questions/79281660/debsig-no-applicable-policy-found-when-running-debsig-verify) about a problem I am having signing a Debian package. This repo reproduces the problem I am having to make it easy to get help. I run everything in a docker container (which is deleted upon exit) so that testing doesn't affect the user's system.


## Background
I am building a Debian package (foo is the name for the purpose of the question). I want to sign the package with GPG. In this example below, I changed the names, version number, email, etc. with fictional ones.

## Folder Structure
My package folder structure looks like this:


    foo-1.2.3-4_amd64
      DEBIAN
        control
        postinst
        prerm
      lib
        systemd
          system
            foo.service
      opt
        my-company
          foo
            bin
              foo-binary
            conf
              foo-config.yml

## Building the package
I am using the following command to build the package                

```bash
dpkg-deb --root-owner-group --build ./foo-1.2.3-4_amd64 ./foo-1.2.3-4_amd64.deb
```

The OS I am using is Ubuntu 24.04.1 LTS (Running on WSL on Windows 11). The dpkg-deb version I use is: Debian 'dpkg-deb' package archive backend version 1.22.6 (amd64). The above command runs fine, **and when I test the installing and uninstall the package, everything runs as expected**.

## Signing the package
Now I want to sign the package using a GPG key. So I run the following script

```bash
#obtain the GPG key ID
KEYID=$(gpg --list-keys info@example.com | sed -n '2p' | cut -c31-)

# Sign the package
debsigs --sign=origin -k "${KEYID}" foo-1.2.3-4_amd64.deb
```

This is where I get the first problem. I get the following output

```
 *** Processing file foo-1.2.3-4_amd64.deb
Use of uninitialized value $args[4] in exec at /usr/share/perl5/Debian/debsigs/forktools.pm line 64.
Use of uninitialized value $args[5] in exec at /usr/share/perl5/Debian/debsigs/forktools.pm line 64.
RUNNING: gpg --openpgp --detach-sign --default-key XXXXXXXXXXXXXXXX at /usr/bin/debsigs line 117.
no entry  in archive
no entry  in archive
gpg: using "XXXXXXXXXXXXXXXX" as default secret key for signing
```

So the above "no entry  in archine" and "Use of uninitialized value" seem to be warnings, so I am thinking may be I can ignore them???

debsigs version is: 0.01.19


## Verifying the package

Anyway, after I sign the package (and getting the warnings shown above), I try to verify the package.


```bash
# Add the key
KEY_DIR=/usr/share/debsig/keyrings/${KEYID}
sudo mkdir "${KEY_DIR}"
gpg --export "$KEYID" | sudo tee "${KEY_DIR}/debsig.gpg" > /dev/null

# create policy file
POL_DIR="/etc/debsig/policies/${KEYID}"
sudo mkdir "${POL_DIR}"
cat << EOT | sudo tee "${POL_DIR}/test.pol" > /dev/null
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
debsig-verify --debug --verbose "foo-1.2.3-4_amd64.deb"
```

`debsig-verify` command results in the following output:

```
debsig: Starting verification for: foo-1.2.3-4_amd64.deb
debsig: Using policy directory: /etc/debsig/policies/XXXXXXXXXXXXXXXX
debsig:   Parsing policy file: /etc/debsig/policies/XXXXXXXXXXXXXXXX/test.pol
debsig: No applicable policy found.
```

When running `debsig-verify --version` I get

```
Debsig Program Version - 0.29
  Signature Version - 1.0
  Signature Namespace - https://www.debian.org/debsig/1.0/
  Policies Directory - /etc/debsig/policies
  Keyrings Directory - /usr/share/debsig/keyrings
```

## Summary

So I have two problems: 
First the warning I get when signing the package. I don't know how to fix, or whether I can ignore it or not.

Second, the package verification fails with No applicable policy found.

I appreciate any help in fixing those problems and thanks a lot in advance for reading and help.


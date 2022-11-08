#!/bin/bash

echo "Enter the path containing the secrets (Kubeconfig and the Automation Config) : "
read file

echo "Enter the password for the encrypted archive : "
read -s pass

echo "Archiving"
tar -czf secrets -C $file . >> /dev/null &&

echo "Encrypting"
echo $pass | gpg --symmetric --passphrase-fd 0 --batch --yes --cipher-algo AES256 secrets >> /dev/null &&

echo "Removing Unencrypted Archive"
rm secrets
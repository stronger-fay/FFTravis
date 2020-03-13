#!/usr/bin/env bash

SHELL_DIR=$(cd"$(dirname "$0")"; pwd)
echo "*** $SHELL_DIR"

pushd ${SHELL_DIR}

KEYCHAIN_PASSWORD=123456
ENCRYPTION_SECRET=foo

# TRAVIS_BRANCH是Travis的常量，用于获取当前所在的git分支。
echo "*** $TRAVIS_BRANCH"

# ENCRYPTION_SECRET 是travis.yml中已经添加的两个环境变量
openssl aes-256-cbc -k $ENCRYPTION_SECRET -in certs/dist.cer.enc -d -a -out certs/dist.cer

openssl aes-256-cbc -k $ENCRYPTION_SECRET -in certs/dist.p12.enc -d -a -out certs/dist.p12

security -v create-keychain -p ${KEYCHAIN_PASSWORD} ios-build.keychain

security -v default-keychain -s ios-build.keychain

security -v unlock-keychain -p ${KEYCHAIN_PASSWORD} ios-build.keychain

security -v set-keychain-settings -t 864000 -lu ~/Library/Keychains/ios-build.keychain

security -v import certs/dist.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign

security -v import certs/dist.p12 -k ~/Library/Keychains/ios-build.keychain -P "${KEYCHAIN_PASSWORD}" -T /usr/bin/codesign

security -v set-key-partition-list -S apple-tool:,apple:,codesign: -s -k ${KEYCHAIN_PASSWORD} ios-build.keychain

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

for file in profile/*.mobileprovision.enc; do
  echo "file: $file"
  provision_file=${file%.enc}
  echo "provision_file: $provision_file"
  openssl aes-256-cbc -k $ENCRYPTION_SECRET -in $file -d -a -out ${provision_file}
  final_file=`grep UUID -A1 -a "$provision_file" | grep -io "[-A-F0-9]\{36\}"`
  echo "final_file: $final_file.mobileprovision"
  mv -f $provision_file ~/Library/MobileDevice/Provisioning\ Profiles/${final_file}.mobileprovision
done

security -v find-identity -p codesigning ~/Library/Keychains/ios-build.keychain

security -v list-keychains

popd

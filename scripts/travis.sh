#!/usr/bin/env bash

SHELL_DIR=$(cd"$(dirname "$0")"; pwd)   

# 编译路径
BUILD_PATH=${SHELL_DIR}/../build/

echo "*** $TRAVIS_BRANCH"


# -workspace ${}名字.xcworkspace
SANDBOX=SANDBOX

# -scheme ${SCHEME_SANDBOX}
SCHEME_SANDBOX=HOLLA-dev

# Release 包
SCHEME_RELEASE=HOLLA-dev

# APPNAME 是travis.yml中的环境变量
SANDBOX_IPA_ARCHIVE_PATH=${BUILD_PATH}/${APPNAME}${SANDBOX}

RELEASE_IPA_ARCHIVE_PATH=${BUILD_PATH}/${APPNAME}${SCHEME_RELEASE}

xcodebuild archive -workspace  ${SHELL_DIR}/../${APPNAME}.xcworkspace -scheme ${SCHEME_SANDBOX} -configuration Debug -derivedDataPath ${BUILD_PATH} -archivePath ${SANDBOX_IPA_ARCHIVE_PATH}.xcarchive -quiet

xcodebuild -exportArchive -archivePath ${SANDBOX_IPA_ARCHIVE_PATH}.xcarchive -exportPath ${SANDBOX_IPA_ARCHIVE_PATH} -exportOptionsPlist ${SHELL_DIR}/exportOptions-developer.plist -quiet

xcodebuild archive -workspace  ${SHELL_DIR}/../${APPNAME}.xcworkspace -scheme ${SCHEME_RELEASE} -configuration Release -derivedDataPath ${BUILD_PATH} -archivePath ${RELEASE_IPA_ARCHIVE_PATH}.xcarchive -quiet

xcodebuild -exportArchive -archivePath ${RELEASE_IPA_ARCHIVE_PATH}.xcarchive -exportPath ${RELEASE_IPA_ARCHIVE_PATH} -exportOptionsPlist ${SHELL_DIR}/exportOptions-developer.plist -quiet

echo "*** end exportArchive"
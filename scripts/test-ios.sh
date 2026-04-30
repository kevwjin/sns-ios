#!/bin/sh
set -eu

xcodebuild -project sns.xcodeproj \
  -scheme sns \
  -destination 'platform=iOS Simulator,id=E125EE27-91F8-49DF-A7D2-B63E5A9AFCAE' \
  -derivedDataPath /tmp/sns-derived-data \
  -parallel-testing-enabled NO \
  test

# Project Instructions

## Testing

For full iOS test runs, disable parallel UI testing. Xcode 26.4 can hang or fail while launching cloned `snsUITests.xctrunner` simulators.

Use:

```sh
./scripts/test-ios.sh
```

The script runs:

```sh
xcodebuild -project sns.xcodeproj \
  -scheme sns \
  -destination 'platform=iOS Simulator,id=E125EE27-91F8-49DF-A7D2-B63E5A9AFCAE' \
  -derivedDataPath /tmp/sns-derived-data \
  -parallel-testing-enabled NO \
  test
```

If the simulator id changes, use an available `iPhone 17` simulator and keep `-parallel-testing-enabled NO`.

# Project Instructions

## Testing

For full iOS test runs, disable parallel UI testing. Xcode 26.4 can hang or fail while launching cloned `snsUITests.xctrunner` simulators.

When running from Codex or another sandboxed agent, run the test command outside the sandbox / with escalated permissions. Sandboxed runs can lose access to `CoreSimulatorService` and fail with errors like:

- `CoreSimulatorService connection became invalid`
- `Unable to find a device matching the provided destination specifier`
- `no available devices matched the request`

If a sandboxed test run hits one of those errors, stop it and rerun the same script with CoreSimulator access instead of changing the test command.

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

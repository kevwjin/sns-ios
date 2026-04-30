# sns

## Testing

Use the smallest test loop that gives confidence for the change you are making.

```sh
./scripts/test-ios-fast.sh
```

Runs only `snsTests`. This is the default day-to-day development loop and should cover most model, router, search, and other pure app behavior.

```sh
./scripts/test-ios-ui-smoke.sh
```

Runs a small serial UI smoke suite. Use this after UI or navigation changes to confirm the app launches, root tabs render, quick search can navigate, and a representative settings route hides/restores the tab bar.

```sh
./scripts/test-ios.sh
```

Runs the full iOS test suite. Use this before merge, before broad validation, or after high-risk UI/navigation changes.

Full UI testing intentionally disables parallel UI testing. Xcode 26.4 can hang or fail while launching cloned `snsUITests.xctrunner` simulators, so UI scripts should keep `-parallel-testing-enabled NO`.

If a UI run fails before executing test bodies because `snsUITests.xctrunner` is busy or cannot bootstrap, retry after the simulator settles or restart the target simulator. Use `./scripts/test-ios-fast.sh` for normal development while that CoreSimulator issue is isolated.

The scripts currently target simulator id `E125EE27-91F8-49DF-A7D2-B63E5A9AFCAE`. If that simulator is unavailable, use an available `iPhone 17` simulator and keep UI parallelism disabled.

Prefer adding unit coverage for behavior first. Reserve XCUI tests for end-to-end confidence across app launch, navigation, and critical user workflows.

fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### build_runner

```sh
[bundle exec] fastlane build_runner
```

Flutter build runner

### pub_get

```sh
[bundle exec] fastlane pub_get
```

Flutter pub get

### watch

```sh
[bundle exec] fastlane watch
```

Watch changes for rerunning the build_runner

### clean

```sh
[bundle exec] fastlane clean
```

Flutter clean

### check

```sh
[bundle exec] fastlane check
```

Sanity checks

### publish

```sh
[bundle exec] fastlane publish
```

Build and publish (i.e fastlane publish platform:ios build:release)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

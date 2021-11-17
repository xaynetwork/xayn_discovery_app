fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### build_runner
```
fastlane build_runner
```
Flutter build runner
### pub_get
```
fastlane pub_get
```
Flutter pub get
### watch
```
fastlane watch
```
Watch changes for rerunning the build_runner
### clean
```
fastlane clean
```
Flutter clean
### check
```
fastlane check
```
Sanity checks
### publish
```
fastlane publish
```
Build and publish (i.e fastlane publish platform:ios build:release)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### create_appstore_api_key

```sh
[bundle exec] fastlane create_appstore_api_key
```

Create an app store connect api key 

### update_strings

```sh
[bundle exec] fastlane update_strings
```

Update strings

### build_runner

```sh
[bundle exec] fastlane build_runner
```

Flutter build runner

### check_config_files

```sh
[bundle exec] fastlane check_config_files
```

Checks alle the config (env, properties, etc) if they are correctly set

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

Sanity checks (options: coverage:[true/FALSE])
Available options:
   - coverage

### publish

```sh
[bundle exec] fastlane publish
```

Build and publish 
Available options:
   - android_output
   - clean
   - coverage
   - download_profile
   - flavor
   - platform
   - release_build
   - update_assets
   - upload_to_appcenter
   - keyFile
   - keyId
   - issuerId


### update_assets

```sh
[bundle exec] fastlane update_assets
```

Update the assets folder based on the Assets Manifest from xayn_discovery_engine

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

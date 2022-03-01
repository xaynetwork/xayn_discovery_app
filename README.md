## Development

For all targets the `.env.debug` Environment file needs to be added. 
An example can be found in `env.example`.

The build system supports to automatically fill those files, just run:

```shell
$ fastlane build_runner
```

after checking out the project. Then answer the wizard questions in the command line.

`fastlane build_runner` can be called whenever you want during development to ensure all dependencies
are created, and property files are correctly set-up.

To run the app during development on simulators/emulators and the android devices simply run

```shell
$ flutter run
```

### iOS device development

In order to run and debug the app on a real iOS device a provisioning profile and a developer certificate is necessary.
A default development  profile for development is part of this repository, to install it run:

```shell 
$ open ios/profiles/Xayn_Discovery_Internal_Develop_Profile.mobileprovision
```

Or open the profile in the finder.
Then install the development certificate found under `ios/profiles/Certificates-internal.p12`
the encryption key can be found in 1password.

If you want to use another profile follow this steps:

- Create a development certificate in XCode (Settings -> Accounts -> Xayn AG Team -> Manage Certificates -> "+" Button  -> Apple Development)
- Create a "iOS App Development" provisioning profile under [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/profiles/list)
- Be sure that it matches the default team id and app id found in `ios/fastlane/Appfile` and that it contains your created certificate in step 1
- Edit the `ios/Flutter/UserDefaults.xcconfig` to contain
```properties
USER_PROVISIONING_PROFILE=YOUR PROFILE NAME
USER_CERTIFICATE=YOUR CERTIFICATE NAME 
```
- Now plugin your iOS device (be sure it is accepted as a development device XCode -> Window -> Devices )
- Run `flutter run`

NOTE: The `ios/Flutter/Dartdefines.xcconfig` can contain overrides for `USER_PROVISIONING_PROFILE/ CERTIFICATE` (when running fastlane publish) so be sure that this is not the case!!!

## Release

### Check secrets with gitleaks

[Gitleaks](https://github.com/zricethezav/gitleaks) is a tool for detecting and preventing hardcoded secrets in git repos.
The tool scans the repo using a set of regex rules. 
We have our custom set of rules implemented in the `.gitleaks.toml` file, located at the root folder of the project.

Steps to follow for scanning the repo:
- [Get started](https://github.com/zricethezav/gitleaks#getting-started) with gitleaks
- Navigate to the `root folder` of the project.
- Run the command `gitleaks detect -l debug --verbose`. For more information about the usage, please check the [documentation](https://github.com/zricethezav/gitleaks#usage). Please note: in order to use our custom set of rules, the location where the command is run must be the same of where the `.gitleaks.toml` is located. 
- Check the output and look for any hardcoded secrets, if any

[top :arrow_heading_up:](#project_name)

----------



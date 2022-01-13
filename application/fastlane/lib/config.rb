module Config

  #release, debug
  BUILD = "debug"

  # env defaults that will be used when no ENV variables are provided
  ENV_DEFAULTS = { "SEARCH_API_URL_DEBUG" => "api-gw.xaynet.dev",
                   "SEARCH_API_URL_PRODUCTION" => "api-gw.xayn.com",
                   "IMAGE_FETCHER_URL_DEBUG" => "https://img-fetcher.xaynet.dev",
                   "IMAGE_FETCHER_URL_PRODUCTION" => "https://img-fetcher.xayn.com" }

  #ios, android, web
  PLATFORM = "android"

  #apk, appbundle
  ANDROID_OUTPUT = "apk"

  #internal, beta, production
  FLAVOR = "internal"

  FLAVOR_MATRIX = {
    "internal" => {
      "ios" => {
        "id" => "com.xayn.discovery.internal",
        "name" => "Discovery App Internal",
        "appcenter_target" => "Discovery-App-internal",
        "appcenter_token" => "APPCENTER_IOS_INTERNAL_TOKEN",
        "appcenter_buildfile" => "build/discovery-app.ipa",
      },
      "android" => {
        "id" => "com.xayn.discovery.internal",
        "name" => "Discovery App Internal",
        "appcenter_target" => "Discovery-App-Android-internal",
        "appcenter_token" => "APPCENTER_ANDROID_INTERNAL_TOKEN",
        "appcenter_buildfile" => "build/app/outputs/flutter-apk/app-release.apk",
      },
    },
    "beta" => {
      "ios" => {
        "id" => "com.xayn.discovery",
        "name" => "Discovery App Beta",
        "appcenter_target" => "Discoveru-App-iOS-beta",
        "appcenter_token" => "APPCENTER_IOS_BETA_TOKEN",
        "appcenter_buildfile" => "build/discovery-app.ipa",
      },
      "android" => {
        "id" => "com.xayn.search",
        "name" => "Discovery App Beta",
      },
    },
    "production" => {
      "ios" => {
        "id" => "com.xayn.search",
        "name" => "Discovery App",
      },
      "android" => {
        "id" => "com.xayn.search",
        "name" => "Discovery App",
      },
    },
  }

  IOS_BUILD_CONFIG = {
    "internal" => {
      "provisioning_profile_path" => "profiles/Xayn_Discovery_Internal_Adhoc_Profile.mobileprovision",
      "provisioning_profile_name" => "Xayn Discovery Internal Adhoc Profile",
      "provisioning_profiles" => {
        "com.xayn.discovery.internal" => "Xayn Discovery Internal Adhoc Profile",
      },
      "adhoc" => true,
    },
    "beta" => {
      "provisioning_profile_path" => "profiles/Xayn_Discovery_AppStore_Profile.mobileprovision",
      "provisioning_profile_name" => "Xayn Discovery AppStore Profile",
      "provisioning_profiles" => {
        "com.xayn.discovery" => "Xayn Discovery AppStore Profile",
      },
      "adhoc" => false,
    },
  }
end

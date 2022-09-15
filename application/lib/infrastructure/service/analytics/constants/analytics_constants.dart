class AnalyticsConstants {
  AnalyticsConstants._();

  /// You can find it in the appsflyer dashboard
  static const String appInviteOneLinkID = 'gvbN';
  static const String deepLinkNameForSharingDocument = 'cardDetails';

  /// The name of this parameter is the one used by default for getting the deep link name
  /// when onDeepLink has been called. Found it by debugging the object DeepLinkResult
  static const String deepLinkNameParamName = 'deep_link_value';
  static const String articleLinkParamName = 'article';

  /// Default parameters names provided by appsFlyer used for redirecting the user
  /// to a certain endpoint in case the app is not installed
  static const String afWebDp = "af_web_dp";
  static const String afDp = "af_dp";

  static const String webArticleViewerEndpoint =
      "https://xayn.webflow.io/article";
}

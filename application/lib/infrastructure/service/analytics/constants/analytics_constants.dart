class AnalyticsConstants {
  AnalyticsConstants._();

  /// You can find it in the appsflyer dashboard
  static const String appInviteOneLinkID = 'gvbN';
  static const String deepLinkNameForSharingDocument = 'cardDetails';

  /// The name of this parameter is the one used by default for getting the deep link name
  /// when onDeepLink has been called. Found it by debugging the object DeepLinkResult
  static const String deepLinkNameParamName = 'deep_link_value';
  static const String articleLinkParamName = 'article';
}

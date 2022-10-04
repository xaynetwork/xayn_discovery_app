import 'dart:io';

const String _kIOSUserInviteFieldName = 'userInviteURL';
const String _kAndroidUserInviteFieldName = 'userInviteUrl';

abstract class GenerateInviteLinkResult {}

class GenerateInviteLinkError extends GenerateInviteLinkResult {
  final String? message;

  GenerateInviteLinkError({this.message});
}

class GenerateInviteLinkSuccess extends GenerateInviteLinkResult {
  final String userInviteUrl;

  GenerateInviteLinkSuccess(this.userInviteUrl);

  GenerateInviteLinkSuccess.fromMap(Map map)
      : userInviteUrl = Platform.isIOS
            ? map['payload'][_kIOSUserInviteFieldName]
            : map['payload'][_kAndroidUserInviteFieldName];
}

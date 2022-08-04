// ignore_for_file: avoid_print
/// NOTE: Does not support any flutter dependencies thus can not load flutter code,
/// so be careful when importing packages.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:equatable/equatable.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

/// Creates a database snapshot in the given directory
void main(List<String> args) async {
  EquatableConfig.stringify = true;

  if (args.length != 2) {
    print('dart download_remote_config.dart <APPID> <FLAVOR>');
    exit(1);
  }

  final appID = args[0];
  final flavor = args[1];

  const bucketName = 'remote_configs_repo';
  final factory = defaultS3Factory(
      secretKey: Env.rconfigSecretKey,
      accessKey: Env.rconfigAccessKey,
      endpointUrl: Env.rconfigEndpointUrl,
      s3Region: Env.rconfigRegion);

  final nameBuilder = defaultNameBuilder(
    appId: appID,
    flavor: flavor,
  );

  final s3 = factory();
  final listBucketsOutput = await s3.getObject(
    bucket: bucketName,
    key: nameBuilder(),
  );

  final content = utf8.decode(Uint8List.fromList(listBucketsOutput.body ?? []));
  print(content);
  exit(0);
}

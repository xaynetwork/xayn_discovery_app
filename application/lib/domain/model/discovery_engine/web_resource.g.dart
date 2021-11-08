// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_WebResource _$$_WebResourceFromJson(Map<String, dynamic> json) =>
    _$_WebResource(
      displayUrl: Uri.parse(json['displayUrl'] as String),
      snippet: json['snippet'] as String,
      title: json['title'] as String,
      url: Uri.parse(json['url'] as String),
    );

Map<String, dynamic> _$$_WebResourceToJson(_$_WebResource instance) =>
    <String, dynamic>{
      'displayUrl': instance.displayUrl.toString(),
      'snippet': instance.snippet,
      'title': instance.title,
      'url': instance.url.toString(),
    };

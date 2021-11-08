// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Document _$$_DocumentFromJson(Map<String, dynamic> json) => _$_Document(
      documentId:
          DocumentId.fromJson(json['documentId'] as Map<String, dynamic>),
      webResource:
          WebResource.fromJson(json['webResource'] as Map<String, dynamic>),
      nonPersonalizedRank: json['nonPersonalizedRank'] as int,
      personalizedRank: json['personalizedRank'] as int,
    );

Map<String, dynamic> _$$_DocumentToJson(_$_Document instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'webResource': instance.webResource,
      'nonPersonalizedRank': instance.nonPersonalizedRank,
      'personalizedRank': instance.personalizedRank,
    };

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Document _$DocumentFromJson(Map<String, dynamic> json) {
  return _Document.fromJson(json);
}

/// @nodoc
class _$DocumentTearOff {
  const _$DocumentTearOff();

  _Document call(
      {required DocumentId documentId,
      required WebResource webResource,
      required int nonPersonalizedRank,
      required int personalizedRank}) {
    return _Document(
      documentId: documentId,
      webResource: webResource,
      nonPersonalizedRank: nonPersonalizedRank,
      personalizedRank: personalizedRank,
    );
  }

  Document fromJson(Map<String, Object?> json) {
    return Document.fromJson(json);
  }
}

/// @nodoc
const $Document = _$DocumentTearOff();

/// @nodoc
mixin _$Document {
  DocumentId get documentId => throw _privateConstructorUsedError;
  WebResource get webResource => throw _privateConstructorUsedError;
  int get nonPersonalizedRank => throw _privateConstructorUsedError;
  int get personalizedRank => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentCopyWith<Document> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentCopyWith<$Res> {
  factory $DocumentCopyWith(Document value, $Res Function(Document) then) =
      _$DocumentCopyWithImpl<$Res>;
  $Res call(
      {DocumentId documentId,
      WebResource webResource,
      int nonPersonalizedRank,
      int personalizedRank});

  $DocumentIdCopyWith<$Res> get documentId;
  $WebResourceCopyWith<$Res> get webResource;
}

/// @nodoc
class _$DocumentCopyWithImpl<$Res> implements $DocumentCopyWith<$Res> {
  _$DocumentCopyWithImpl(this._value, this._then);

  final Document _value;
  // ignore: unused_field
  final $Res Function(Document) _then;

  @override
  $Res call({
    Object? documentId = freezed,
    Object? webResource = freezed,
    Object? nonPersonalizedRank = freezed,
    Object? personalizedRank = freezed,
  }) {
    return _then(_value.copyWith(
      documentId: documentId == freezed
          ? _value.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as DocumentId,
      webResource: webResource == freezed
          ? _value.webResource
          : webResource // ignore: cast_nullable_to_non_nullable
              as WebResource,
      nonPersonalizedRank: nonPersonalizedRank == freezed
          ? _value.nonPersonalizedRank
          : nonPersonalizedRank // ignore: cast_nullable_to_non_nullable
              as int,
      personalizedRank: personalizedRank == freezed
          ? _value.personalizedRank
          : personalizedRank // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  @override
  $DocumentIdCopyWith<$Res> get documentId {
    return $DocumentIdCopyWith<$Res>(_value.documentId, (value) {
      return _then(_value.copyWith(documentId: value));
    });
  }

  @override
  $WebResourceCopyWith<$Res> get webResource {
    return $WebResourceCopyWith<$Res>(_value.webResource, (value) {
      return _then(_value.copyWith(webResource: value));
    });
  }
}

/// @nodoc
abstract class _$DocumentCopyWith<$Res> implements $DocumentCopyWith<$Res> {
  factory _$DocumentCopyWith(_Document value, $Res Function(_Document) then) =
      __$DocumentCopyWithImpl<$Res>;
  @override
  $Res call(
      {DocumentId documentId,
      WebResource webResource,
      int nonPersonalizedRank,
      int personalizedRank});

  @override
  $DocumentIdCopyWith<$Res> get documentId;
  @override
  $WebResourceCopyWith<$Res> get webResource;
}

/// @nodoc
class __$DocumentCopyWithImpl<$Res> extends _$DocumentCopyWithImpl<$Res>
    implements _$DocumentCopyWith<$Res> {
  __$DocumentCopyWithImpl(_Document _value, $Res Function(_Document) _then)
      : super(_value, (v) => _then(v as _Document));

  @override
  _Document get _value => super._value as _Document;

  @override
  $Res call({
    Object? documentId = freezed,
    Object? webResource = freezed,
    Object? nonPersonalizedRank = freezed,
    Object? personalizedRank = freezed,
  }) {
    return _then(_Document(
      documentId: documentId == freezed
          ? _value.documentId
          : documentId // ignore: cast_nullable_to_non_nullable
              as DocumentId,
      webResource: webResource == freezed
          ? _value.webResource
          : webResource // ignore: cast_nullable_to_non_nullable
              as WebResource,
      nonPersonalizedRank: nonPersonalizedRank == freezed
          ? _value.nonPersonalizedRank
          : nonPersonalizedRank // ignore: cast_nullable_to_non_nullable
              as int,
      personalizedRank: personalizedRank == freezed
          ? _value.personalizedRank
          : personalizedRank // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Document extends _Document {
  const _$_Document(
      {required this.documentId,
      required this.webResource,
      required this.nonPersonalizedRank,
      required this.personalizedRank})
      : super._();

  factory _$_Document.fromJson(Map<String, dynamic> json) =>
      _$$_DocumentFromJson(json);

  @override
  final DocumentId documentId;
  @override
  final WebResource webResource;
  @override
  final int nonPersonalizedRank;
  @override
  final int personalizedRank;

  @override
  String toString() {
    return 'Document(documentId: $documentId, webResource: $webResource, nonPersonalizedRank: $nonPersonalizedRank, personalizedRank: $personalizedRank)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Document &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId) &&
            (identical(other.webResource, webResource) ||
                other.webResource == webResource) &&
            (identical(other.nonPersonalizedRank, nonPersonalizedRank) ||
                other.nonPersonalizedRank == nonPersonalizedRank) &&
            (identical(other.personalizedRank, personalizedRank) ||
                other.personalizedRank == personalizedRank));
  }

  @override
  int get hashCode => Object.hash(runtimeType, documentId, webResource,
      nonPersonalizedRank, personalizedRank);

  @JsonKey(ignore: true)
  @override
  _$DocumentCopyWith<_Document> get copyWith =>
      __$DocumentCopyWithImpl<_Document>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DocumentToJson(this);
  }
}

abstract class _Document extends Document {
  const factory _Document(
      {required DocumentId documentId,
      required WebResource webResource,
      required int nonPersonalizedRank,
      required int personalizedRank}) = _$_Document;
  const _Document._() : super._();

  factory _Document.fromJson(Map<String, dynamic> json) = _$_Document.fromJson;

  @override
  DocumentId get documentId;
  @override
  WebResource get webResource;
  @override
  int get nonPersonalizedRank;
  @override
  int get personalizedRank;
  @override
  @JsonKey(ignore: true)
  _$DocumentCopyWith<_Document> get copyWith =>
      throw _privateConstructorUsedError;
}

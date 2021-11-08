// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'web_resource.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

WebResource _$WebResourceFromJson(Map<String, dynamic> json) {
  return _WebResource.fromJson(json);
}

/// @nodoc
class _$WebResourceTearOff {
  const _$WebResourceTearOff();

  _WebResource call(
      {required Uri displayUrl,
      required String snippet,
      required String title,
      required Uri url}) {
    return _WebResource(
      displayUrl: displayUrl,
      snippet: snippet,
      title: title,
      url: url,
    );
  }

  WebResource fromJson(Map<String, Object?> json) {
    return WebResource.fromJson(json);
  }
}

/// @nodoc
const $WebResource = _$WebResourceTearOff();

/// @nodoc
mixin _$WebResource {
  Uri get displayUrl => throw _privateConstructorUsedError;
  String get snippet => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  Uri get url => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WebResourceCopyWith<WebResource> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebResourceCopyWith<$Res> {
  factory $WebResourceCopyWith(
          WebResource value, $Res Function(WebResource) then) =
      _$WebResourceCopyWithImpl<$Res>;
  $Res call({Uri displayUrl, String snippet, String title, Uri url});
}

/// @nodoc
class _$WebResourceCopyWithImpl<$Res> implements $WebResourceCopyWith<$Res> {
  _$WebResourceCopyWithImpl(this._value, this._then);

  final WebResource _value;
  // ignore: unused_field
  final $Res Function(WebResource) _then;

  @override
  $Res call({
    Object? displayUrl = freezed,
    Object? snippet = freezed,
    Object? title = freezed,
    Object? url = freezed,
  }) {
    return _then(_value.copyWith(
      displayUrl: displayUrl == freezed
          ? _value.displayUrl
          : displayUrl // ignore: cast_nullable_to_non_nullable
              as Uri,
      snippet: snippet == freezed
          ? _value.snippet
          : snippet // ignore: cast_nullable_to_non_nullable
              as String,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      url: url == freezed
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as Uri,
    ));
  }
}

/// @nodoc
abstract class _$WebResourceCopyWith<$Res>
    implements $WebResourceCopyWith<$Res> {
  factory _$WebResourceCopyWith(
          _WebResource value, $Res Function(_WebResource) then) =
      __$WebResourceCopyWithImpl<$Res>;
  @override
  $Res call({Uri displayUrl, String snippet, String title, Uri url});
}

/// @nodoc
class __$WebResourceCopyWithImpl<$Res> extends _$WebResourceCopyWithImpl<$Res>
    implements _$WebResourceCopyWith<$Res> {
  __$WebResourceCopyWithImpl(
      _WebResource _value, $Res Function(_WebResource) _then)
      : super(_value, (v) => _then(v as _WebResource));

  @override
  _WebResource get _value => super._value as _WebResource;

  @override
  $Res call({
    Object? displayUrl = freezed,
    Object? snippet = freezed,
    Object? title = freezed,
    Object? url = freezed,
  }) {
    return _then(_WebResource(
      displayUrl: displayUrl == freezed
          ? _value.displayUrl
          : displayUrl // ignore: cast_nullable_to_non_nullable
              as Uri,
      snippet: snippet == freezed
          ? _value.snippet
          : snippet // ignore: cast_nullable_to_non_nullable
              as String,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      url: url == freezed
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as Uri,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_WebResource extends _WebResource {
  const _$_WebResource(
      {required this.displayUrl,
      required this.snippet,
      required this.title,
      required this.url})
      : super._();

  factory _$_WebResource.fromJson(Map<String, dynamic> json) =>
      _$$_WebResourceFromJson(json);

  @override
  final Uri displayUrl;
  @override
  final String snippet;
  @override
  final String title;
  @override
  final Uri url;

  @override
  String toString() {
    return 'WebResource(displayUrl: $displayUrl, snippet: $snippet, title: $title, url: $url)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WebResource &&
            (identical(other.displayUrl, displayUrl) ||
                other.displayUrl == displayUrl) &&
            (identical(other.snippet, snippet) || other.snippet == snippet) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.url, url) || other.url == url));
  }

  @override
  int get hashCode => Object.hash(runtimeType, displayUrl, snippet, title, url);

  @JsonKey(ignore: true)
  @override
  _$WebResourceCopyWith<_WebResource> get copyWith =>
      __$WebResourceCopyWithImpl<_WebResource>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_WebResourceToJson(this);
  }
}

abstract class _WebResource extends WebResource {
  const factory _WebResource(
      {required Uri displayUrl,
      required String snippet,
      required String title,
      required Uri url}) = _$_WebResource;
  const _WebResource._() : super._();

  factory _WebResource.fromJson(Map<String, dynamic> json) =
      _$_WebResource.fromJson;

  @override
  Uri get displayUrl;
  @override
  String get snippet;
  @override
  String get title;
  @override
  Uri get url;
  @override
  @JsonKey(ignore: true)
  _$WebResourceCopyWith<_WebResource> get copyWith =>
      throw _privateConstructorUsedError;
}

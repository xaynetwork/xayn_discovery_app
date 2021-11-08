// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'document_id.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DocumentId _$DocumentIdFromJson(Map<String, dynamic> json) {
  return _DocumentId.fromJson(json);
}

/// @nodoc
class _$DocumentIdTearOff {
  const _$DocumentIdTearOff();

  _DocumentId call({required String key}) {
    return _DocumentId(
      key: key,
    );
  }

  DocumentId fromJson(Map<String, Object?> json) {
    return DocumentId.fromJson(json);
  }
}

/// @nodoc
const $DocumentId = _$DocumentIdTearOff();

/// @nodoc
mixin _$DocumentId {
  String get key => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentIdCopyWith<DocumentId> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentIdCopyWith<$Res> {
  factory $DocumentIdCopyWith(
          DocumentId value, $Res Function(DocumentId) then) =
      _$DocumentIdCopyWithImpl<$Res>;
  $Res call({String key});
}

/// @nodoc
class _$DocumentIdCopyWithImpl<$Res> implements $DocumentIdCopyWith<$Res> {
  _$DocumentIdCopyWithImpl(this._value, this._then);

  final DocumentId _value;
  // ignore: unused_field
  final $Res Function(DocumentId) _then;

  @override
  $Res call({
    Object? key = freezed,
  }) {
    return _then(_value.copyWith(
      key: key == freezed
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$DocumentIdCopyWith<$Res> implements $DocumentIdCopyWith<$Res> {
  factory _$DocumentIdCopyWith(
          _DocumentId value, $Res Function(_DocumentId) then) =
      __$DocumentIdCopyWithImpl<$Res>;
  @override
  $Res call({String key});
}

/// @nodoc
class __$DocumentIdCopyWithImpl<$Res> extends _$DocumentIdCopyWithImpl<$Res>
    implements _$DocumentIdCopyWith<$Res> {
  __$DocumentIdCopyWithImpl(
      _DocumentId _value, $Res Function(_DocumentId) _then)
      : super(_value, (v) => _then(v as _DocumentId));

  @override
  _DocumentId get _value => super._value as _DocumentId;

  @override
  $Res call({
    Object? key = freezed,
  }) {
    return _then(_DocumentId(
      key: key == freezed
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DocumentId extends _DocumentId {
  const _$_DocumentId({required this.key}) : super._();

  factory _$_DocumentId.fromJson(Map<String, dynamic> json) =>
      _$$_DocumentIdFromJson(json);

  @override
  final String key;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DocumentId &&
            (identical(other.key, key) || other.key == key));
  }

  @override
  int get hashCode => Object.hash(runtimeType, key);

  @JsonKey(ignore: true)
  @override
  _$DocumentIdCopyWith<_DocumentId> get copyWith =>
      __$DocumentIdCopyWithImpl<_DocumentId>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DocumentIdToJson(this);
  }
}

abstract class _DocumentId extends DocumentId {
  const factory _DocumentId({required String key}) = _$_DocumentId;
  const _DocumentId._() : super._();

  factory _DocumentId.fromJson(Map<String, dynamic> json) =
      _$_DocumentId.fromJson;

  @override
  String get key;
  @override
  @JsonKey(ignore: true)
  _$DocumentIdCopyWith<_DocumentId> get copyWith =>
      throw _privateConstructorUsedError;
}

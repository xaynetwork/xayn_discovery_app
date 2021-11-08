// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'discovery_card_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$DiscoveryCardStateTearOff {
  const _$DiscoveryCardStateTearOff();

  _DiscoveryCardState call(
      {bool isComplete = false,
      ProcessHtmlResult? result,
      List<String> paragraphs = const [],
      List<String> images = const [],
      PaletteGenerator? paletteGenerator}) {
    return _DiscoveryCardState(
      isComplete: isComplete,
      result: result,
      paragraphs: paragraphs,
      images: images,
      paletteGenerator: paletteGenerator,
    );
  }
}

/// @nodoc
const $DiscoveryCardState = _$DiscoveryCardStateTearOff();

/// @nodoc
mixin _$DiscoveryCardState {
  bool get isComplete => throw _privateConstructorUsedError;
  ProcessHtmlResult? get result => throw _privateConstructorUsedError;
  List<String> get paragraphs => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  PaletteGenerator? get paletteGenerator => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DiscoveryCardStateCopyWith<DiscoveryCardState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscoveryCardStateCopyWith<$Res> {
  factory $DiscoveryCardStateCopyWith(
          DiscoveryCardState value, $Res Function(DiscoveryCardState) then) =
      _$DiscoveryCardStateCopyWithImpl<$Res>;
  $Res call(
      {bool isComplete,
      ProcessHtmlResult? result,
      List<String> paragraphs,
      List<String> images,
      PaletteGenerator? paletteGenerator});
}

/// @nodoc
class _$DiscoveryCardStateCopyWithImpl<$Res>
    implements $DiscoveryCardStateCopyWith<$Res> {
  _$DiscoveryCardStateCopyWithImpl(this._value, this._then);

  final DiscoveryCardState _value;
  // ignore: unused_field
  final $Res Function(DiscoveryCardState) _then;

  @override
  $Res call({
    Object? isComplete = freezed,
    Object? result = freezed,
    Object? paragraphs = freezed,
    Object? images = freezed,
    Object? paletteGenerator = freezed,
  }) {
    return _then(_value.copyWith(
      isComplete: isComplete == freezed
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      result: result == freezed
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ProcessHtmlResult?,
      paragraphs: paragraphs == freezed
          ? _value.paragraphs
          : paragraphs // ignore: cast_nullable_to_non_nullable
              as List<String>,
      images: images == freezed
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      paletteGenerator: paletteGenerator == freezed
          ? _value.paletteGenerator
          : paletteGenerator // ignore: cast_nullable_to_non_nullable
              as PaletteGenerator?,
    ));
  }
}

/// @nodoc
abstract class _$DiscoveryCardStateCopyWith<$Res>
    implements $DiscoveryCardStateCopyWith<$Res> {
  factory _$DiscoveryCardStateCopyWith(
          _DiscoveryCardState value, $Res Function(_DiscoveryCardState) then) =
      __$DiscoveryCardStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {bool isComplete,
      ProcessHtmlResult? result,
      List<String> paragraphs,
      List<String> images,
      PaletteGenerator? paletteGenerator});
}

/// @nodoc
class __$DiscoveryCardStateCopyWithImpl<$Res>
    extends _$DiscoveryCardStateCopyWithImpl<$Res>
    implements _$DiscoveryCardStateCopyWith<$Res> {
  __$DiscoveryCardStateCopyWithImpl(
      _DiscoveryCardState _value, $Res Function(_DiscoveryCardState) _then)
      : super(_value, (v) => _then(v as _DiscoveryCardState));

  @override
  _DiscoveryCardState get _value => super._value as _DiscoveryCardState;

  @override
  $Res call({
    Object? isComplete = freezed,
    Object? result = freezed,
    Object? paragraphs = freezed,
    Object? images = freezed,
    Object? paletteGenerator = freezed,
  }) {
    return _then(_DiscoveryCardState(
      isComplete: isComplete == freezed
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      result: result == freezed
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ProcessHtmlResult?,
      paragraphs: paragraphs == freezed
          ? _value.paragraphs
          : paragraphs // ignore: cast_nullable_to_non_nullable
              as List<String>,
      images: images == freezed
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      paletteGenerator: paletteGenerator == freezed
          ? _value.paletteGenerator
          : paletteGenerator // ignore: cast_nullable_to_non_nullable
              as PaletteGenerator?,
    ));
  }
}

/// @nodoc

class _$_DiscoveryCardState extends _DiscoveryCardState {
  const _$_DiscoveryCardState(
      {this.isComplete = false,
      this.result,
      this.paragraphs = const [],
      this.images = const [],
      this.paletteGenerator})
      : super._();

  @JsonKey(defaultValue: false)
  @override
  final bool isComplete;
  @override
  final ProcessHtmlResult? result;
  @JsonKey(defaultValue: const [])
  @override
  final List<String> paragraphs;
  @JsonKey(defaultValue: const [])
  @override
  final List<String> images;
  @override
  final PaletteGenerator? paletteGenerator;

  @override
  String toString() {
    return 'DiscoveryCardState(isComplete: $isComplete, result: $result, paragraphs: $paragraphs, images: $images, paletteGenerator: $paletteGenerator)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DiscoveryCardState &&
            (identical(other.isComplete, isComplete) ||
                other.isComplete == isComplete) &&
            (identical(other.result, result) || other.result == result) &&
            const DeepCollectionEquality()
                .equals(other.paragraphs, paragraphs) &&
            const DeepCollectionEquality().equals(other.images, images) &&
            (identical(other.paletteGenerator, paletteGenerator) ||
                other.paletteGenerator == paletteGenerator));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isComplete,
      result,
      const DeepCollectionEquality().hash(paragraphs),
      const DeepCollectionEquality().hash(images),
      paletteGenerator);

  @JsonKey(ignore: true)
  @override
  _$DiscoveryCardStateCopyWith<_DiscoveryCardState> get copyWith =>
      __$DiscoveryCardStateCopyWithImpl<_DiscoveryCardState>(this, _$identity);
}

abstract class _DiscoveryCardState extends DiscoveryCardState {
  const factory _DiscoveryCardState(
      {bool isComplete,
      ProcessHtmlResult? result,
      List<String> paragraphs,
      List<String> images,
      PaletteGenerator? paletteGenerator}) = _$_DiscoveryCardState;
  const _DiscoveryCardState._() : super._();

  @override
  bool get isComplete;
  @override
  ProcessHtmlResult? get result;
  @override
  List<String> get paragraphs;
  @override
  List<String> get images;
  @override
  PaletteGenerator? get paletteGenerator;
  @override
  @JsonKey(ignore: true)
  _$DiscoveryCardStateCopyWith<_DiscoveryCardState> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'discovery_feed_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$DiscoveryFeedStateTearOff {
  const _$DiscoveryFeedStateTearOff();

  _DiscoveryFeedState call(
      {List<Document>? results,
      required int resultIndex,
      required bool isComplete,
      required bool isInErrorState}) {
    return _DiscoveryFeedState(
      results: results,
      resultIndex: resultIndex,
      isComplete: isComplete,
      isInErrorState: isInErrorState,
    );
  }
}

/// @nodoc
const $DiscoveryFeedState = _$DiscoveryFeedStateTearOff();

/// @nodoc
mixin _$DiscoveryFeedState {
  List<Document>? get results => throw _privateConstructorUsedError;
  int get resultIndex => throw _privateConstructorUsedError;
  bool get isComplete => throw _privateConstructorUsedError;
  bool get isInErrorState => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DiscoveryFeedStateCopyWith<DiscoveryFeedState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscoveryFeedStateCopyWith<$Res> {
  factory $DiscoveryFeedStateCopyWith(
          DiscoveryFeedState value, $Res Function(DiscoveryFeedState) then) =
      _$DiscoveryFeedStateCopyWithImpl<$Res>;
  $Res call(
      {List<Document>? results,
      int resultIndex,
      bool isComplete,
      bool isInErrorState});
}

/// @nodoc
class _$DiscoveryFeedStateCopyWithImpl<$Res>
    implements $DiscoveryFeedStateCopyWith<$Res> {
  _$DiscoveryFeedStateCopyWithImpl(this._value, this._then);

  final DiscoveryFeedState _value;
  // ignore: unused_field
  final $Res Function(DiscoveryFeedState) _then;

  @override
  $Res call({
    Object? results = freezed,
    Object? resultIndex = freezed,
    Object? isComplete = freezed,
    Object? isInErrorState = freezed,
  }) {
    return _then(_value.copyWith(
      results: results == freezed
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<Document>?,
      resultIndex: resultIndex == freezed
          ? _value.resultIndex
          : resultIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isComplete: isComplete == freezed
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      isInErrorState: isInErrorState == freezed
          ? _value.isInErrorState
          : isInErrorState // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
abstract class _$DiscoveryFeedStateCopyWith<$Res>
    implements $DiscoveryFeedStateCopyWith<$Res> {
  factory _$DiscoveryFeedStateCopyWith(
          _DiscoveryFeedState value, $Res Function(_DiscoveryFeedState) then) =
      __$DiscoveryFeedStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {List<Document>? results,
      int resultIndex,
      bool isComplete,
      bool isInErrorState});
}

/// @nodoc
class __$DiscoveryFeedStateCopyWithImpl<$Res>
    extends _$DiscoveryFeedStateCopyWithImpl<$Res>
    implements _$DiscoveryFeedStateCopyWith<$Res> {
  __$DiscoveryFeedStateCopyWithImpl(
      _DiscoveryFeedState _value, $Res Function(_DiscoveryFeedState) _then)
      : super(_value, (v) => _then(v as _DiscoveryFeedState));

  @override
  _DiscoveryFeedState get _value => super._value as _DiscoveryFeedState;

  @override
  $Res call({
    Object? results = freezed,
    Object? resultIndex = freezed,
    Object? isComplete = freezed,
    Object? isInErrorState = freezed,
  }) {
    return _then(_DiscoveryFeedState(
      results: results == freezed
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<Document>?,
      resultIndex: resultIndex == freezed
          ? _value.resultIndex
          : resultIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isComplete: isComplete == freezed
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      isInErrorState: isInErrorState == freezed
          ? _value.isInErrorState
          : isInErrorState // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_DiscoveryFeedState extends _DiscoveryFeedState {
  const _$_DiscoveryFeedState(
      {this.results,
      required this.resultIndex,
      required this.isComplete,
      required this.isInErrorState})
      : super._();

  @override
  final List<Document>? results;
  @override
  final int resultIndex;
  @override
  final bool isComplete;
  @override
  final bool isInErrorState;

  @override
  String toString() {
    return 'DiscoveryFeedState(results: $results, resultIndex: $resultIndex, isComplete: $isComplete, isInErrorState: $isInErrorState)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DiscoveryFeedState &&
            const DeepCollectionEquality().equals(other.results, results) &&
            (identical(other.resultIndex, resultIndex) ||
                other.resultIndex == resultIndex) &&
            (identical(other.isComplete, isComplete) ||
                other.isComplete == isComplete) &&
            (identical(other.isInErrorState, isInErrorState) ||
                other.isInErrorState == isInErrorState));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(results),
      resultIndex,
      isComplete,
      isInErrorState);

  @JsonKey(ignore: true)
  @override
  _$DiscoveryFeedStateCopyWith<_DiscoveryFeedState> get copyWith =>
      __$DiscoveryFeedStateCopyWithImpl<_DiscoveryFeedState>(this, _$identity);
}

abstract class _DiscoveryFeedState extends DiscoveryFeedState {
  const factory _DiscoveryFeedState(
      {List<Document>? results,
      required int resultIndex,
      required bool isComplete,
      required bool isInErrorState}) = _$_DiscoveryFeedState;
  const _DiscoveryFeedState._() : super._();

  @override
  List<Document>? get results;
  @override
  int get resultIndex;
  @override
  bool get isComplete;
  @override
  bool get isInErrorState;
  @override
  @JsonKey(ignore: true)
  _$DiscoveryFeedStateCopyWith<_DiscoveryFeedState> get copyWith =>
      throw _privateConstructorUsedError;
}

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispatch_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkflowDispatchRequest {

/// The git reference for the workflow (branch or tag name).
 String get ref;/// Input keys and values configured in the workflow file.
 Map<String, String>? get inputs;
/// Create a copy of WorkflowDispatchRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkflowDispatchRequestCopyWith<WorkflowDispatchRequest> get copyWith => _$WorkflowDispatchRequestCopyWithImpl<WorkflowDispatchRequest>(this as WorkflowDispatchRequest, _$identity);

  /// Serializes this WorkflowDispatchRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkflowDispatchRequest&&(identical(other.ref, ref) || other.ref == ref)&&const DeepCollectionEquality().equals(other.inputs, inputs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ref,const DeepCollectionEquality().hash(inputs));

@override
String toString() {
  return 'WorkflowDispatchRequest(ref: $ref, inputs: $inputs)';
}


}

/// @nodoc
abstract mixin class $WorkflowDispatchRequestCopyWith<$Res>  {
  factory $WorkflowDispatchRequestCopyWith(WorkflowDispatchRequest value, $Res Function(WorkflowDispatchRequest) _then) = _$WorkflowDispatchRequestCopyWithImpl;
@useResult
$Res call({
 String ref, Map<String, String>? inputs
});




}
/// @nodoc
class _$WorkflowDispatchRequestCopyWithImpl<$Res>
    implements $WorkflowDispatchRequestCopyWith<$Res> {
  _$WorkflowDispatchRequestCopyWithImpl(this._self, this._then);

  final WorkflowDispatchRequest _self;
  final $Res Function(WorkflowDispatchRequest) _then;

/// Create a copy of WorkflowDispatchRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ref = null,Object? inputs = freezed,}) {
  return _then(_self.copyWith(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,inputs: freezed == inputs ? _self.inputs : inputs // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkflowDispatchRequest].
extension WorkflowDispatchRequestPatterns on WorkflowDispatchRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkflowDispatchRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkflowDispatchRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkflowDispatchRequest value)  $default,){
final _that = this;
switch (_that) {
case _WorkflowDispatchRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkflowDispatchRequest value)?  $default,){
final _that = this;
switch (_that) {
case _WorkflowDispatchRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ref,  Map<String, String>? inputs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkflowDispatchRequest() when $default != null:
return $default(_that.ref,_that.inputs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ref,  Map<String, String>? inputs)  $default,) {final _that = this;
switch (_that) {
case _WorkflowDispatchRequest():
return $default(_that.ref,_that.inputs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ref,  Map<String, String>? inputs)?  $default,) {final _that = this;
switch (_that) {
case _WorkflowDispatchRequest() when $default != null:
return $default(_that.ref,_that.inputs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkflowDispatchRequest implements WorkflowDispatchRequest {
  const _WorkflowDispatchRequest({required this.ref, final  Map<String, String>? inputs}): _inputs = inputs;
  factory _WorkflowDispatchRequest.fromJson(Map<String, dynamic> json) => _$WorkflowDispatchRequestFromJson(json);

/// The git reference for the workflow (branch or tag name).
@override final  String ref;
/// Input keys and values configured in the workflow file.
 final  Map<String, String>? _inputs;
/// Input keys and values configured in the workflow file.
@override Map<String, String>? get inputs {
  final value = _inputs;
  if (value == null) return null;
  if (_inputs is EqualUnmodifiableMapView) return _inputs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of WorkflowDispatchRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkflowDispatchRequestCopyWith<_WorkflowDispatchRequest> get copyWith => __$WorkflowDispatchRequestCopyWithImpl<_WorkflowDispatchRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkflowDispatchRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkflowDispatchRequest&&(identical(other.ref, ref) || other.ref == ref)&&const DeepCollectionEquality().equals(other._inputs, _inputs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ref,const DeepCollectionEquality().hash(_inputs));

@override
String toString() {
  return 'WorkflowDispatchRequest(ref: $ref, inputs: $inputs)';
}


}

/// @nodoc
abstract mixin class _$WorkflowDispatchRequestCopyWith<$Res> implements $WorkflowDispatchRequestCopyWith<$Res> {
  factory _$WorkflowDispatchRequestCopyWith(_WorkflowDispatchRequest value, $Res Function(_WorkflowDispatchRequest) _then) = __$WorkflowDispatchRequestCopyWithImpl;
@override @useResult
$Res call({
 String ref, Map<String, String>? inputs
});




}
/// @nodoc
class __$WorkflowDispatchRequestCopyWithImpl<$Res>
    implements _$WorkflowDispatchRequestCopyWith<$Res> {
  __$WorkflowDispatchRequestCopyWithImpl(this._self, this._then);

  final _WorkflowDispatchRequest _self;
  final $Res Function(_WorkflowDispatchRequest) _then;

/// Create a copy of WorkflowDispatchRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ref = null,Object? inputs = freezed,}) {
  return _then(_WorkflowDispatchRequest(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,inputs: freezed == inputs ? _self._inputs : inputs // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}

// dart format on

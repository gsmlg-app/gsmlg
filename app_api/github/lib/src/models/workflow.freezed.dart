// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workflow.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkflowResponse {

 int get id;@JsonKey(name: 'node_id') String? get nodeId; String get name; String get path; String get state;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt; String? get url;@JsonKey(name: 'html_url') String? get htmlUrl;@JsonKey(name: 'badge_url') String? get badgeUrl;
/// Create a copy of WorkflowResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkflowResponseCopyWith<WorkflowResponse> get copyWith => _$WorkflowResponseCopyWithImpl<WorkflowResponse>(this as WorkflowResponse, _$identity);

  /// Serializes this WorkflowResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkflowResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.state, state) || other.state == state)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.url, url) || other.url == url)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&(identical(other.badgeUrl, badgeUrl) || other.badgeUrl == badgeUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nodeId,name,path,state,createdAt,updatedAt,url,htmlUrl,badgeUrl);

@override
String toString() {
  return 'WorkflowResponse(id: $id, nodeId: $nodeId, name: $name, path: $path, state: $state, createdAt: $createdAt, updatedAt: $updatedAt, url: $url, htmlUrl: $htmlUrl, badgeUrl: $badgeUrl)';
}


}

/// @nodoc
abstract mixin class $WorkflowResponseCopyWith<$Res>  {
  factory $WorkflowResponseCopyWith(WorkflowResponse value, $Res Function(WorkflowResponse) _then) = _$WorkflowResponseCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'node_id') String? nodeId, String name, String path, String state,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt, String? url,@JsonKey(name: 'html_url') String? htmlUrl,@JsonKey(name: 'badge_url') String? badgeUrl
});




}
/// @nodoc
class _$WorkflowResponseCopyWithImpl<$Res>
    implements $WorkflowResponseCopyWith<$Res> {
  _$WorkflowResponseCopyWithImpl(this._self, this._then);

  final WorkflowResponse _self;
  final $Res Function(WorkflowResponse) _then;

/// Create a copy of WorkflowResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nodeId = freezed,Object? name = null,Object? path = null,Object? state = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? url = freezed,Object? htmlUrl = freezed,Object? badgeUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nodeId: freezed == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,htmlUrl: freezed == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String?,badgeUrl: freezed == badgeUrl ? _self.badgeUrl : badgeUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkflowResponse].
extension WorkflowResponsePatterns on WorkflowResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkflowResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkflowResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkflowResponse value)  $default,){
final _that = this;
switch (_that) {
case _WorkflowResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkflowResponse value)?  $default,){
final _that = this;
switch (_that) {
case _WorkflowResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'node_id')  String? nodeId,  String name,  String path,  String state, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  String? url, @JsonKey(name: 'html_url')  String? htmlUrl, @JsonKey(name: 'badge_url')  String? badgeUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkflowResponse() when $default != null:
return $default(_that.id,_that.nodeId,_that.name,_that.path,_that.state,_that.createdAt,_that.updatedAt,_that.url,_that.htmlUrl,_that.badgeUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'node_id')  String? nodeId,  String name,  String path,  String state, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  String? url, @JsonKey(name: 'html_url')  String? htmlUrl, @JsonKey(name: 'badge_url')  String? badgeUrl)  $default,) {final _that = this;
switch (_that) {
case _WorkflowResponse():
return $default(_that.id,_that.nodeId,_that.name,_that.path,_that.state,_that.createdAt,_that.updatedAt,_that.url,_that.htmlUrl,_that.badgeUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'node_id')  String? nodeId,  String name,  String path,  String state, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt,  String? url, @JsonKey(name: 'html_url')  String? htmlUrl, @JsonKey(name: 'badge_url')  String? badgeUrl)?  $default,) {final _that = this;
switch (_that) {
case _WorkflowResponse() when $default != null:
return $default(_that.id,_that.nodeId,_that.name,_that.path,_that.state,_that.createdAt,_that.updatedAt,_that.url,_that.htmlUrl,_that.badgeUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkflowResponse implements WorkflowResponse {
  const _WorkflowResponse({required this.id, @JsonKey(name: 'node_id') this.nodeId, required this.name, required this.path, required this.state, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, this.url, @JsonKey(name: 'html_url') this.htmlUrl, @JsonKey(name: 'badge_url') this.badgeUrl});
  factory _WorkflowResponse.fromJson(Map<String, dynamic> json) => _$WorkflowResponseFromJson(json);

@override final  int id;
@override@JsonKey(name: 'node_id') final  String? nodeId;
@override final  String name;
@override final  String path;
@override final  String state;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override final  String? url;
@override@JsonKey(name: 'html_url') final  String? htmlUrl;
@override@JsonKey(name: 'badge_url') final  String? badgeUrl;

/// Create a copy of WorkflowResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkflowResponseCopyWith<_WorkflowResponse> get copyWith => __$WorkflowResponseCopyWithImpl<_WorkflowResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkflowResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkflowResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.state, state) || other.state == state)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.url, url) || other.url == url)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&(identical(other.badgeUrl, badgeUrl) || other.badgeUrl == badgeUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nodeId,name,path,state,createdAt,updatedAt,url,htmlUrl,badgeUrl);

@override
String toString() {
  return 'WorkflowResponse(id: $id, nodeId: $nodeId, name: $name, path: $path, state: $state, createdAt: $createdAt, updatedAt: $updatedAt, url: $url, htmlUrl: $htmlUrl, badgeUrl: $badgeUrl)';
}


}

/// @nodoc
abstract mixin class _$WorkflowResponseCopyWith<$Res> implements $WorkflowResponseCopyWith<$Res> {
  factory _$WorkflowResponseCopyWith(_WorkflowResponse value, $Res Function(_WorkflowResponse) _then) = __$WorkflowResponseCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'node_id') String? nodeId, String name, String path, String state,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt, String? url,@JsonKey(name: 'html_url') String? htmlUrl,@JsonKey(name: 'badge_url') String? badgeUrl
});




}
/// @nodoc
class __$WorkflowResponseCopyWithImpl<$Res>
    implements _$WorkflowResponseCopyWith<$Res> {
  __$WorkflowResponseCopyWithImpl(this._self, this._then);

  final _WorkflowResponse _self;
  final $Res Function(_WorkflowResponse) _then;

/// Create a copy of WorkflowResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nodeId = freezed,Object? name = null,Object? path = null,Object? state = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? url = freezed,Object? htmlUrl = freezed,Object? badgeUrl = freezed,}) {
  return _then(_WorkflowResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nodeId: freezed == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,htmlUrl: freezed == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String?,badgeUrl: freezed == badgeUrl ? _self.badgeUrl : badgeUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ListWorkflowsResponse {

@JsonKey(name: 'total_count') int get totalCount; List<WorkflowResponse> get workflows;
/// Create a copy of ListWorkflowsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListWorkflowsResponseCopyWith<ListWorkflowsResponse> get copyWith => _$ListWorkflowsResponseCopyWithImpl<ListWorkflowsResponse>(this as ListWorkflowsResponse, _$identity);

  /// Serializes this ListWorkflowsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListWorkflowsResponse&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other.workflows, workflows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCount,const DeepCollectionEquality().hash(workflows));

@override
String toString() {
  return 'ListWorkflowsResponse(totalCount: $totalCount, workflows: $workflows)';
}


}

/// @nodoc
abstract mixin class $ListWorkflowsResponseCopyWith<$Res>  {
  factory $ListWorkflowsResponseCopyWith(ListWorkflowsResponse value, $Res Function(ListWorkflowsResponse) _then) = _$ListWorkflowsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_count') int totalCount, List<WorkflowResponse> workflows
});




}
/// @nodoc
class _$ListWorkflowsResponseCopyWithImpl<$Res>
    implements $ListWorkflowsResponseCopyWith<$Res> {
  _$ListWorkflowsResponseCopyWithImpl(this._self, this._then);

  final ListWorkflowsResponse _self;
  final $Res Function(ListWorkflowsResponse) _then;

/// Create a copy of ListWorkflowsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCount = null,Object? workflows = null,}) {
  return _then(_self.copyWith(
totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,workflows: null == workflows ? _self.workflows : workflows // ignore: cast_nullable_to_non_nullable
as List<WorkflowResponse>,
  ));
}

}


/// Adds pattern-matching-related methods to [ListWorkflowsResponse].
extension ListWorkflowsResponsePatterns on ListWorkflowsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListWorkflowsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListWorkflowsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListWorkflowsResponse value)  $default,){
final _that = this;
switch (_that) {
case _ListWorkflowsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListWorkflowsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ListWorkflowsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_count')  int totalCount,  List<WorkflowResponse> workflows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListWorkflowsResponse() when $default != null:
return $default(_that.totalCount,_that.workflows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_count')  int totalCount,  List<WorkflowResponse> workflows)  $default,) {final _that = this;
switch (_that) {
case _ListWorkflowsResponse():
return $default(_that.totalCount,_that.workflows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_count')  int totalCount,  List<WorkflowResponse> workflows)?  $default,) {final _that = this;
switch (_that) {
case _ListWorkflowsResponse() when $default != null:
return $default(_that.totalCount,_that.workflows);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListWorkflowsResponse implements ListWorkflowsResponse {
  const _ListWorkflowsResponse({@JsonKey(name: 'total_count') required this.totalCount, required final  List<WorkflowResponse> workflows}): _workflows = workflows;
  factory _ListWorkflowsResponse.fromJson(Map<String, dynamic> json) => _$ListWorkflowsResponseFromJson(json);

@override@JsonKey(name: 'total_count') final  int totalCount;
 final  List<WorkflowResponse> _workflows;
@override List<WorkflowResponse> get workflows {
  if (_workflows is EqualUnmodifiableListView) return _workflows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workflows);
}


/// Create a copy of ListWorkflowsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListWorkflowsResponseCopyWith<_ListWorkflowsResponse> get copyWith => __$ListWorkflowsResponseCopyWithImpl<_ListWorkflowsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListWorkflowsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListWorkflowsResponse&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other._workflows, _workflows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCount,const DeepCollectionEquality().hash(_workflows));

@override
String toString() {
  return 'ListWorkflowsResponse(totalCount: $totalCount, workflows: $workflows)';
}


}

/// @nodoc
abstract mixin class _$ListWorkflowsResponseCopyWith<$Res> implements $ListWorkflowsResponseCopyWith<$Res> {
  factory _$ListWorkflowsResponseCopyWith(_ListWorkflowsResponse value, $Res Function(_ListWorkflowsResponse) _then) = __$ListWorkflowsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_count') int totalCount, List<WorkflowResponse> workflows
});




}
/// @nodoc
class __$ListWorkflowsResponseCopyWithImpl<$Res>
    implements _$ListWorkflowsResponseCopyWith<$Res> {
  __$ListWorkflowsResponseCopyWithImpl(this._self, this._then);

  final _ListWorkflowsResponse _self;
  final $Res Function(_ListWorkflowsResponse) _then;

/// Create a copy of ListWorkflowsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCount = null,Object? workflows = null,}) {
  return _then(_ListWorkflowsResponse(
totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,workflows: null == workflows ? _self._workflows : workflows // ignore: cast_nullable_to_non_nullable
as List<WorkflowResponse>,
  ));
}


}

// dart format on

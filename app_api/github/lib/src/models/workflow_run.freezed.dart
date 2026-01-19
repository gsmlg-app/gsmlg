// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workflow_run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RunActor {

 int get id; String get login;@JsonKey(name: 'avatar_url') String? get avatarUrl;
/// Create a copy of RunActor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunActorCopyWith<RunActor> get copyWith => _$RunActorCopyWithImpl<RunActor>(this as RunActor, _$identity);

  /// Serializes this RunActor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunActor&&(identical(other.id, id) || other.id == id)&&(identical(other.login, login) || other.login == login)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,login,avatarUrl);

@override
String toString() {
  return 'RunActor(id: $id, login: $login, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $RunActorCopyWith<$Res>  {
  factory $RunActorCopyWith(RunActor value, $Res Function(RunActor) _then) = _$RunActorCopyWithImpl;
@useResult
$Res call({
 int id, String login,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class _$RunActorCopyWithImpl<$Res>
    implements $RunActorCopyWith<$Res> {
  _$RunActorCopyWithImpl(this._self, this._then);

  final RunActor _self;
  final $Res Function(RunActor) _then;

/// Create a copy of RunActor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? login = null,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RunActor].
extension RunActorPatterns on RunActor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RunActor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RunActor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RunActor value)  $default,){
final _that = this;
switch (_that) {
case _RunActor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RunActor value)?  $default,){
final _that = this;
switch (_that) {
case _RunActor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String login, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunActor() when $default != null:
return $default(_that.id,_that.login,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String login, @JsonKey(name: 'avatar_url')  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _RunActor():
return $default(_that.id,_that.login,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String login, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _RunActor() when $default != null:
return $default(_that.id,_that.login,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RunActor implements RunActor {
  const _RunActor({required this.id, required this.login, @JsonKey(name: 'avatar_url') this.avatarUrl});
  factory _RunActor.fromJson(Map<String, dynamic> json) => _$RunActorFromJson(json);

@override final  int id;
@override final  String login;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;

/// Create a copy of RunActor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunActorCopyWith<_RunActor> get copyWith => __$RunActorCopyWithImpl<_RunActor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RunActorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunActor&&(identical(other.id, id) || other.id == id)&&(identical(other.login, login) || other.login == login)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,login,avatarUrl);

@override
String toString() {
  return 'RunActor(id: $id, login: $login, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$RunActorCopyWith<$Res> implements $RunActorCopyWith<$Res> {
  factory _$RunActorCopyWith(_RunActor value, $Res Function(_RunActor) _then) = __$RunActorCopyWithImpl;
@override @useResult
$Res call({
 int id, String login,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class __$RunActorCopyWithImpl<$Res>
    implements _$RunActorCopyWith<$Res> {
  __$RunActorCopyWithImpl(this._self, this._then);

  final _RunActor _self;
  final $Res Function(_RunActor) _then;

/// Create a copy of RunActor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? login = null,Object? avatarUrl = freezed,}) {
  return _then(_RunActor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WorkflowRunResponse {

 int get id;@JsonKey(name: 'node_id') String? get nodeId; String? get name;@JsonKey(name: 'head_branch') String? get headBranch;@JsonKey(name: 'head_sha') String? get headSha; String? get path;@JsonKey(name: 'display_title') String? get displayTitle;@JsonKey(name: 'run_number') int get runNumber; String? get event; String? get status; String? get conclusion;@JsonKey(name: 'workflow_id') int get workflowId;@JsonKey(name: 'html_url') String? get htmlUrl;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(name: 'run_started_at') DateTime? get runStartedAt; RunActor? get actor;@JsonKey(name: 'triggering_actor') RunActor? get triggeringActor;
/// Create a copy of WorkflowRunResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkflowRunResponseCopyWith<WorkflowRunResponse> get copyWith => _$WorkflowRunResponseCopyWithImpl<WorkflowRunResponse>(this as WorkflowRunResponse, _$identity);

  /// Serializes this WorkflowRunResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkflowRunResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.headBranch, headBranch) || other.headBranch == headBranch)&&(identical(other.headSha, headSha) || other.headSha == headSha)&&(identical(other.path, path) || other.path == path)&&(identical(other.displayTitle, displayTitle) || other.displayTitle == displayTitle)&&(identical(other.runNumber, runNumber) || other.runNumber == runNumber)&&(identical(other.event, event) || other.event == event)&&(identical(other.status, status) || other.status == status)&&(identical(other.conclusion, conclusion) || other.conclusion == conclusion)&&(identical(other.workflowId, workflowId) || other.workflowId == workflowId)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.runStartedAt, runStartedAt) || other.runStartedAt == runStartedAt)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.triggeringActor, triggeringActor) || other.triggeringActor == triggeringActor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nodeId,name,headBranch,headSha,path,displayTitle,runNumber,event,status,conclusion,workflowId,htmlUrl,createdAt,updatedAt,runStartedAt,actor,triggeringActor);

@override
String toString() {
  return 'WorkflowRunResponse(id: $id, nodeId: $nodeId, name: $name, headBranch: $headBranch, headSha: $headSha, path: $path, displayTitle: $displayTitle, runNumber: $runNumber, event: $event, status: $status, conclusion: $conclusion, workflowId: $workflowId, htmlUrl: $htmlUrl, createdAt: $createdAt, updatedAt: $updatedAt, runStartedAt: $runStartedAt, actor: $actor, triggeringActor: $triggeringActor)';
}


}

/// @nodoc
abstract mixin class $WorkflowRunResponseCopyWith<$Res>  {
  factory $WorkflowRunResponseCopyWith(WorkflowRunResponse value, $Res Function(WorkflowRunResponse) _then) = _$WorkflowRunResponseCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'node_id') String? nodeId, String? name,@JsonKey(name: 'head_branch') String? headBranch,@JsonKey(name: 'head_sha') String? headSha, String? path,@JsonKey(name: 'display_title') String? displayTitle,@JsonKey(name: 'run_number') int runNumber, String? event, String? status, String? conclusion,@JsonKey(name: 'workflow_id') int workflowId,@JsonKey(name: 'html_url') String? htmlUrl,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'run_started_at') DateTime? runStartedAt, RunActor? actor,@JsonKey(name: 'triggering_actor') RunActor? triggeringActor
});


$RunActorCopyWith<$Res>? get actor;$RunActorCopyWith<$Res>? get triggeringActor;

}
/// @nodoc
class _$WorkflowRunResponseCopyWithImpl<$Res>
    implements $WorkflowRunResponseCopyWith<$Res> {
  _$WorkflowRunResponseCopyWithImpl(this._self, this._then);

  final WorkflowRunResponse _self;
  final $Res Function(WorkflowRunResponse) _then;

/// Create a copy of WorkflowRunResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nodeId = freezed,Object? name = freezed,Object? headBranch = freezed,Object? headSha = freezed,Object? path = freezed,Object? displayTitle = freezed,Object? runNumber = null,Object? event = freezed,Object? status = freezed,Object? conclusion = freezed,Object? workflowId = null,Object? htmlUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? runStartedAt = freezed,Object? actor = freezed,Object? triggeringActor = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nodeId: freezed == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,headBranch: freezed == headBranch ? _self.headBranch : headBranch // ignore: cast_nullable_to_non_nullable
as String?,headSha: freezed == headSha ? _self.headSha : headSha // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,displayTitle: freezed == displayTitle ? _self.displayTitle : displayTitle // ignore: cast_nullable_to_non_nullable
as String?,runNumber: null == runNumber ? _self.runNumber : runNumber // ignore: cast_nullable_to_non_nullable
as int,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,conclusion: freezed == conclusion ? _self.conclusion : conclusion // ignore: cast_nullable_to_non_nullable
as String?,workflowId: null == workflowId ? _self.workflowId : workflowId // ignore: cast_nullable_to_non_nullable
as int,htmlUrl: freezed == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,runStartedAt: freezed == runStartedAt ? _self.runStartedAt : runStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as RunActor?,triggeringActor: freezed == triggeringActor ? _self.triggeringActor : triggeringActor // ignore: cast_nullable_to_non_nullable
as RunActor?,
  ));
}
/// Create a copy of WorkflowRunResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RunActorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $RunActorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}/// Create a copy of WorkflowRunResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RunActorCopyWith<$Res>? get triggeringActor {
    if (_self.triggeringActor == null) {
    return null;
  }

  return $RunActorCopyWith<$Res>(_self.triggeringActor!, (value) {
    return _then(_self.copyWith(triggeringActor: value));
  });
}
}


/// Adds pattern-matching-related methods to [WorkflowRunResponse].
extension WorkflowRunResponsePatterns on WorkflowRunResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkflowRunResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkflowRunResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkflowRunResponse value)  $default,){
final _that = this;
switch (_that) {
case _WorkflowRunResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkflowRunResponse value)?  $default,){
final _that = this;
switch (_that) {
case _WorkflowRunResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'node_id')  String? nodeId,  String? name, @JsonKey(name: 'head_branch')  String? headBranch, @JsonKey(name: 'head_sha')  String? headSha,  String? path, @JsonKey(name: 'display_title')  String? displayTitle, @JsonKey(name: 'run_number')  int runNumber,  String? event,  String? status,  String? conclusion, @JsonKey(name: 'workflow_id')  int workflowId, @JsonKey(name: 'html_url')  String? htmlUrl, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'run_started_at')  DateTime? runStartedAt,  RunActor? actor, @JsonKey(name: 'triggering_actor')  RunActor? triggeringActor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkflowRunResponse() when $default != null:
return $default(_that.id,_that.nodeId,_that.name,_that.headBranch,_that.headSha,_that.path,_that.displayTitle,_that.runNumber,_that.event,_that.status,_that.conclusion,_that.workflowId,_that.htmlUrl,_that.createdAt,_that.updatedAt,_that.runStartedAt,_that.actor,_that.triggeringActor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'node_id')  String? nodeId,  String? name, @JsonKey(name: 'head_branch')  String? headBranch, @JsonKey(name: 'head_sha')  String? headSha,  String? path, @JsonKey(name: 'display_title')  String? displayTitle, @JsonKey(name: 'run_number')  int runNumber,  String? event,  String? status,  String? conclusion, @JsonKey(name: 'workflow_id')  int workflowId, @JsonKey(name: 'html_url')  String? htmlUrl, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'run_started_at')  DateTime? runStartedAt,  RunActor? actor, @JsonKey(name: 'triggering_actor')  RunActor? triggeringActor)  $default,) {final _that = this;
switch (_that) {
case _WorkflowRunResponse():
return $default(_that.id,_that.nodeId,_that.name,_that.headBranch,_that.headSha,_that.path,_that.displayTitle,_that.runNumber,_that.event,_that.status,_that.conclusion,_that.workflowId,_that.htmlUrl,_that.createdAt,_that.updatedAt,_that.runStartedAt,_that.actor,_that.triggeringActor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'node_id')  String? nodeId,  String? name, @JsonKey(name: 'head_branch')  String? headBranch, @JsonKey(name: 'head_sha')  String? headSha,  String? path, @JsonKey(name: 'display_title')  String? displayTitle, @JsonKey(name: 'run_number')  int runNumber,  String? event,  String? status,  String? conclusion, @JsonKey(name: 'workflow_id')  int workflowId, @JsonKey(name: 'html_url')  String? htmlUrl, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'run_started_at')  DateTime? runStartedAt,  RunActor? actor, @JsonKey(name: 'triggering_actor')  RunActor? triggeringActor)?  $default,) {final _that = this;
switch (_that) {
case _WorkflowRunResponse() when $default != null:
return $default(_that.id,_that.nodeId,_that.name,_that.headBranch,_that.headSha,_that.path,_that.displayTitle,_that.runNumber,_that.event,_that.status,_that.conclusion,_that.workflowId,_that.htmlUrl,_that.createdAt,_that.updatedAt,_that.runStartedAt,_that.actor,_that.triggeringActor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkflowRunResponse implements WorkflowRunResponse {
  const _WorkflowRunResponse({required this.id, @JsonKey(name: 'node_id') this.nodeId, this.name, @JsonKey(name: 'head_branch') this.headBranch, @JsonKey(name: 'head_sha') this.headSha, this.path, @JsonKey(name: 'display_title') this.displayTitle, @JsonKey(name: 'run_number') required this.runNumber, this.event, this.status, this.conclusion, @JsonKey(name: 'workflow_id') required this.workflowId, @JsonKey(name: 'html_url') this.htmlUrl, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'run_started_at') this.runStartedAt, this.actor, @JsonKey(name: 'triggering_actor') this.triggeringActor});
  factory _WorkflowRunResponse.fromJson(Map<String, dynamic> json) => _$WorkflowRunResponseFromJson(json);

@override final  int id;
@override@JsonKey(name: 'node_id') final  String? nodeId;
@override final  String? name;
@override@JsonKey(name: 'head_branch') final  String? headBranch;
@override@JsonKey(name: 'head_sha') final  String? headSha;
@override final  String? path;
@override@JsonKey(name: 'display_title') final  String? displayTitle;
@override@JsonKey(name: 'run_number') final  int runNumber;
@override final  String? event;
@override final  String? status;
@override final  String? conclusion;
@override@JsonKey(name: 'workflow_id') final  int workflowId;
@override@JsonKey(name: 'html_url') final  String? htmlUrl;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(name: 'run_started_at') final  DateTime? runStartedAt;
@override final  RunActor? actor;
@override@JsonKey(name: 'triggering_actor') final  RunActor? triggeringActor;

/// Create a copy of WorkflowRunResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkflowRunResponseCopyWith<_WorkflowRunResponse> get copyWith => __$WorkflowRunResponseCopyWithImpl<_WorkflowRunResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkflowRunResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkflowRunResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.nodeId, nodeId) || other.nodeId == nodeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.headBranch, headBranch) || other.headBranch == headBranch)&&(identical(other.headSha, headSha) || other.headSha == headSha)&&(identical(other.path, path) || other.path == path)&&(identical(other.displayTitle, displayTitle) || other.displayTitle == displayTitle)&&(identical(other.runNumber, runNumber) || other.runNumber == runNumber)&&(identical(other.event, event) || other.event == event)&&(identical(other.status, status) || other.status == status)&&(identical(other.conclusion, conclusion) || other.conclusion == conclusion)&&(identical(other.workflowId, workflowId) || other.workflowId == workflowId)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.runStartedAt, runStartedAt) || other.runStartedAt == runStartedAt)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.triggeringActor, triggeringActor) || other.triggeringActor == triggeringActor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nodeId,name,headBranch,headSha,path,displayTitle,runNumber,event,status,conclusion,workflowId,htmlUrl,createdAt,updatedAt,runStartedAt,actor,triggeringActor);

@override
String toString() {
  return 'WorkflowRunResponse(id: $id, nodeId: $nodeId, name: $name, headBranch: $headBranch, headSha: $headSha, path: $path, displayTitle: $displayTitle, runNumber: $runNumber, event: $event, status: $status, conclusion: $conclusion, workflowId: $workflowId, htmlUrl: $htmlUrl, createdAt: $createdAt, updatedAt: $updatedAt, runStartedAt: $runStartedAt, actor: $actor, triggeringActor: $triggeringActor)';
}


}

/// @nodoc
abstract mixin class _$WorkflowRunResponseCopyWith<$Res> implements $WorkflowRunResponseCopyWith<$Res> {
  factory _$WorkflowRunResponseCopyWith(_WorkflowRunResponse value, $Res Function(_WorkflowRunResponse) _then) = __$WorkflowRunResponseCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'node_id') String? nodeId, String? name,@JsonKey(name: 'head_branch') String? headBranch,@JsonKey(name: 'head_sha') String? headSha, String? path,@JsonKey(name: 'display_title') String? displayTitle,@JsonKey(name: 'run_number') int runNumber, String? event, String? status, String? conclusion,@JsonKey(name: 'workflow_id') int workflowId,@JsonKey(name: 'html_url') String? htmlUrl,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'run_started_at') DateTime? runStartedAt, RunActor? actor,@JsonKey(name: 'triggering_actor') RunActor? triggeringActor
});


@override $RunActorCopyWith<$Res>? get actor;@override $RunActorCopyWith<$Res>? get triggeringActor;

}
/// @nodoc
class __$WorkflowRunResponseCopyWithImpl<$Res>
    implements _$WorkflowRunResponseCopyWith<$Res> {
  __$WorkflowRunResponseCopyWithImpl(this._self, this._then);

  final _WorkflowRunResponse _self;
  final $Res Function(_WorkflowRunResponse) _then;

/// Create a copy of WorkflowRunResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nodeId = freezed,Object? name = freezed,Object? headBranch = freezed,Object? headSha = freezed,Object? path = freezed,Object? displayTitle = freezed,Object? runNumber = null,Object? event = freezed,Object? status = freezed,Object? conclusion = freezed,Object? workflowId = null,Object? htmlUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? runStartedAt = freezed,Object? actor = freezed,Object? triggeringActor = freezed,}) {
  return _then(_WorkflowRunResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nodeId: freezed == nodeId ? _self.nodeId : nodeId // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,headBranch: freezed == headBranch ? _self.headBranch : headBranch // ignore: cast_nullable_to_non_nullable
as String?,headSha: freezed == headSha ? _self.headSha : headSha // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,displayTitle: freezed == displayTitle ? _self.displayTitle : displayTitle // ignore: cast_nullable_to_non_nullable
as String?,runNumber: null == runNumber ? _self.runNumber : runNumber // ignore: cast_nullable_to_non_nullable
as int,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,conclusion: freezed == conclusion ? _self.conclusion : conclusion // ignore: cast_nullable_to_non_nullable
as String?,workflowId: null == workflowId ? _self.workflowId : workflowId // ignore: cast_nullable_to_non_nullable
as int,htmlUrl: freezed == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,runStartedAt: freezed == runStartedAt ? _self.runStartedAt : runStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as RunActor?,triggeringActor: freezed == triggeringActor ? _self.triggeringActor : triggeringActor // ignore: cast_nullable_to_non_nullable
as RunActor?,
  ));
}

/// Create a copy of WorkflowRunResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RunActorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $RunActorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}/// Create a copy of WorkflowRunResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RunActorCopyWith<$Res>? get triggeringActor {
    if (_self.triggeringActor == null) {
    return null;
  }

  return $RunActorCopyWith<$Res>(_self.triggeringActor!, (value) {
    return _then(_self.copyWith(triggeringActor: value));
  });
}
}


/// @nodoc
mixin _$ListWorkflowRunsResponse {

@JsonKey(name: 'total_count') int get totalCount;@JsonKey(name: 'workflow_runs') List<WorkflowRunResponse> get workflowRuns;
/// Create a copy of ListWorkflowRunsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListWorkflowRunsResponseCopyWith<ListWorkflowRunsResponse> get copyWith => _$ListWorkflowRunsResponseCopyWithImpl<ListWorkflowRunsResponse>(this as ListWorkflowRunsResponse, _$identity);

  /// Serializes this ListWorkflowRunsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListWorkflowRunsResponse&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other.workflowRuns, workflowRuns));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCount,const DeepCollectionEquality().hash(workflowRuns));

@override
String toString() {
  return 'ListWorkflowRunsResponse(totalCount: $totalCount, workflowRuns: $workflowRuns)';
}


}

/// @nodoc
abstract mixin class $ListWorkflowRunsResponseCopyWith<$Res>  {
  factory $ListWorkflowRunsResponseCopyWith(ListWorkflowRunsResponse value, $Res Function(ListWorkflowRunsResponse) _then) = _$ListWorkflowRunsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_count') int totalCount,@JsonKey(name: 'workflow_runs') List<WorkflowRunResponse> workflowRuns
});




}
/// @nodoc
class _$ListWorkflowRunsResponseCopyWithImpl<$Res>
    implements $ListWorkflowRunsResponseCopyWith<$Res> {
  _$ListWorkflowRunsResponseCopyWithImpl(this._self, this._then);

  final ListWorkflowRunsResponse _self;
  final $Res Function(ListWorkflowRunsResponse) _then;

/// Create a copy of ListWorkflowRunsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCount = null,Object? workflowRuns = null,}) {
  return _then(_self.copyWith(
totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,workflowRuns: null == workflowRuns ? _self.workflowRuns : workflowRuns // ignore: cast_nullable_to_non_nullable
as List<WorkflowRunResponse>,
  ));
}

}


/// Adds pattern-matching-related methods to [ListWorkflowRunsResponse].
extension ListWorkflowRunsResponsePatterns on ListWorkflowRunsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListWorkflowRunsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListWorkflowRunsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListWorkflowRunsResponse value)  $default,){
final _that = this;
switch (_that) {
case _ListWorkflowRunsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListWorkflowRunsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ListWorkflowRunsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_count')  int totalCount, @JsonKey(name: 'workflow_runs')  List<WorkflowRunResponse> workflowRuns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListWorkflowRunsResponse() when $default != null:
return $default(_that.totalCount,_that.workflowRuns);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_count')  int totalCount, @JsonKey(name: 'workflow_runs')  List<WorkflowRunResponse> workflowRuns)  $default,) {final _that = this;
switch (_that) {
case _ListWorkflowRunsResponse():
return $default(_that.totalCount,_that.workflowRuns);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_count')  int totalCount, @JsonKey(name: 'workflow_runs')  List<WorkflowRunResponse> workflowRuns)?  $default,) {final _that = this;
switch (_that) {
case _ListWorkflowRunsResponse() when $default != null:
return $default(_that.totalCount,_that.workflowRuns);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListWorkflowRunsResponse implements ListWorkflowRunsResponse {
  const _ListWorkflowRunsResponse({@JsonKey(name: 'total_count') required this.totalCount, @JsonKey(name: 'workflow_runs') required final  List<WorkflowRunResponse> workflowRuns}): _workflowRuns = workflowRuns;
  factory _ListWorkflowRunsResponse.fromJson(Map<String, dynamic> json) => _$ListWorkflowRunsResponseFromJson(json);

@override@JsonKey(name: 'total_count') final  int totalCount;
 final  List<WorkflowRunResponse> _workflowRuns;
@override@JsonKey(name: 'workflow_runs') List<WorkflowRunResponse> get workflowRuns {
  if (_workflowRuns is EqualUnmodifiableListView) return _workflowRuns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workflowRuns);
}


/// Create a copy of ListWorkflowRunsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListWorkflowRunsResponseCopyWith<_ListWorkflowRunsResponse> get copyWith => __$ListWorkflowRunsResponseCopyWithImpl<_ListWorkflowRunsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListWorkflowRunsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListWorkflowRunsResponse&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other._workflowRuns, _workflowRuns));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCount,const DeepCollectionEquality().hash(_workflowRuns));

@override
String toString() {
  return 'ListWorkflowRunsResponse(totalCount: $totalCount, workflowRuns: $workflowRuns)';
}


}

/// @nodoc
abstract mixin class _$ListWorkflowRunsResponseCopyWith<$Res> implements $ListWorkflowRunsResponseCopyWith<$Res> {
  factory _$ListWorkflowRunsResponseCopyWith(_ListWorkflowRunsResponse value, $Res Function(_ListWorkflowRunsResponse) _then) = __$ListWorkflowRunsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_count') int totalCount,@JsonKey(name: 'workflow_runs') List<WorkflowRunResponse> workflowRuns
});




}
/// @nodoc
class __$ListWorkflowRunsResponseCopyWithImpl<$Res>
    implements _$ListWorkflowRunsResponseCopyWith<$Res> {
  __$ListWorkflowRunsResponseCopyWithImpl(this._self, this._then);

  final _ListWorkflowRunsResponse _self;
  final $Res Function(_ListWorkflowRunsResponse) _then;

/// Create a copy of ListWorkflowRunsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCount = null,Object? workflowRuns = null,}) {
  return _then(_ListWorkflowRunsResponse(
totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,workflowRuns: null == workflowRuns ? _self._workflowRuns : workflowRuns // ignore: cast_nullable_to_non_nullable
as List<WorkflowRunResponse>,
  ));
}


}

// dart format on

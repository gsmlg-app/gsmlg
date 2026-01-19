// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RepoOwner {

 int get id; String get login;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'html_url') String? get htmlUrl; String? get type;
/// Create a copy of RepoOwner
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepoOwnerCopyWith<RepoOwner> get copyWith => _$RepoOwnerCopyWithImpl<RepoOwner>(this as RepoOwner, _$identity);

  /// Serializes this RepoOwner to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepoOwner&&(identical(other.id, id) || other.id == id)&&(identical(other.login, login) || other.login == login)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,login,avatarUrl,htmlUrl,type);

@override
String toString() {
  return 'RepoOwner(id: $id, login: $login, avatarUrl: $avatarUrl, htmlUrl: $htmlUrl, type: $type)';
}


}

/// @nodoc
abstract mixin class $RepoOwnerCopyWith<$Res>  {
  factory $RepoOwnerCopyWith(RepoOwner value, $Res Function(RepoOwner) _then) = _$RepoOwnerCopyWithImpl;
@useResult
$Res call({
 int id, String login,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'html_url') String? htmlUrl, String? type
});




}
/// @nodoc
class _$RepoOwnerCopyWithImpl<$Res>
    implements $RepoOwnerCopyWith<$Res> {
  _$RepoOwnerCopyWithImpl(this._self, this._then);

  final RepoOwner _self;
  final $Res Function(RepoOwner) _then;

/// Create a copy of RepoOwner
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? login = null,Object? avatarUrl = freezed,Object? htmlUrl = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,htmlUrl: freezed == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RepoOwner].
extension RepoOwnerPatterns on RepoOwner {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepoOwner value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepoOwner() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepoOwner value)  $default,){
final _that = this;
switch (_that) {
case _RepoOwner():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepoOwner value)?  $default,){
final _that = this;
switch (_that) {
case _RepoOwner() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String login, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'html_url')  String? htmlUrl,  String? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepoOwner() when $default != null:
return $default(_that.id,_that.login,_that.avatarUrl,_that.htmlUrl,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String login, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'html_url')  String? htmlUrl,  String? type)  $default,) {final _that = this;
switch (_that) {
case _RepoOwner():
return $default(_that.id,_that.login,_that.avatarUrl,_that.htmlUrl,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String login, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'html_url')  String? htmlUrl,  String? type)?  $default,) {final _that = this;
switch (_that) {
case _RepoOwner() when $default != null:
return $default(_that.id,_that.login,_that.avatarUrl,_that.htmlUrl,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepoOwner implements RepoOwner {
  const _RepoOwner({required this.id, required this.login, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'html_url') this.htmlUrl, this.type});
  factory _RepoOwner.fromJson(Map<String, dynamic> json) => _$RepoOwnerFromJson(json);

@override final  int id;
@override final  String login;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'html_url') final  String? htmlUrl;
@override final  String? type;

/// Create a copy of RepoOwner
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepoOwnerCopyWith<_RepoOwner> get copyWith => __$RepoOwnerCopyWithImpl<_RepoOwner>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepoOwnerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepoOwner&&(identical(other.id, id) || other.id == id)&&(identical(other.login, login) || other.login == login)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,login,avatarUrl,htmlUrl,type);

@override
String toString() {
  return 'RepoOwner(id: $id, login: $login, avatarUrl: $avatarUrl, htmlUrl: $htmlUrl, type: $type)';
}


}

/// @nodoc
abstract mixin class _$RepoOwnerCopyWith<$Res> implements $RepoOwnerCopyWith<$Res> {
  factory _$RepoOwnerCopyWith(_RepoOwner value, $Res Function(_RepoOwner) _then) = __$RepoOwnerCopyWithImpl;
@override @useResult
$Res call({
 int id, String login,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'html_url') String? htmlUrl, String? type
});




}
/// @nodoc
class __$RepoOwnerCopyWithImpl<$Res>
    implements _$RepoOwnerCopyWith<$Res> {
  __$RepoOwnerCopyWithImpl(this._self, this._then);

  final _RepoOwner _self;
  final $Res Function(_RepoOwner) _then;

/// Create a copy of RepoOwner
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? login = null,Object? avatarUrl = freezed,Object? htmlUrl = freezed,Object? type = freezed,}) {
  return _then(_RepoOwner(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,htmlUrl: freezed == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RepoResponse {

 int get id; String get name;@JsonKey(name: 'full_name') String get fullName; RepoOwner get owner;@JsonKey(name: 'private') bool get isPrivate;@JsonKey(name: 'html_url') String? get htmlUrl; String? get description; bool? get fork;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(name: 'pushed_at') DateTime? get pushedAt;@JsonKey(name: 'git_url') String? get gitUrl;@JsonKey(name: 'ssh_url') String? get sshUrl;@JsonKey(name: 'clone_url') String? get cloneUrl;@JsonKey(name: 'default_branch') String? get defaultBranch;@JsonKey(name: 'stargazers_count') int? get stargazersCount;@JsonKey(name: 'watchers_count') int? get watchersCount;@JsonKey(name: 'forks_count') int? get forksCount;@JsonKey(name: 'open_issues_count') int? get openIssuesCount; String? get language;@JsonKey(name: 'has_issues') bool? get hasIssues;@JsonKey(name: 'has_projects') bool? get hasProjects;@JsonKey(name: 'has_wiki') bool? get hasWiki;@JsonKey(name: 'has_pages') bool? get hasPages;@JsonKey(name: 'has_downloads') bool? get hasDownloads; bool? get archived; bool? get disabled; String? get visibility;
/// Create a copy of RepoResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepoResponseCopyWith<RepoResponse> get copyWith => _$RepoResponseCopyWithImpl<RepoResponse>(this as RepoResponse, _$identity);

  /// Serializes this RepoResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepoResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.fork, fork) || other.fork == fork)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.pushedAt, pushedAt) || other.pushedAt == pushedAt)&&(identical(other.gitUrl, gitUrl) || other.gitUrl == gitUrl)&&(identical(other.sshUrl, sshUrl) || other.sshUrl == sshUrl)&&(identical(other.cloneUrl, cloneUrl) || other.cloneUrl == cloneUrl)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch)&&(identical(other.stargazersCount, stargazersCount) || other.stargazersCount == stargazersCount)&&(identical(other.watchersCount, watchersCount) || other.watchersCount == watchersCount)&&(identical(other.forksCount, forksCount) || other.forksCount == forksCount)&&(identical(other.openIssuesCount, openIssuesCount) || other.openIssuesCount == openIssuesCount)&&(identical(other.language, language) || other.language == language)&&(identical(other.hasIssues, hasIssues) || other.hasIssues == hasIssues)&&(identical(other.hasProjects, hasProjects) || other.hasProjects == hasProjects)&&(identical(other.hasWiki, hasWiki) || other.hasWiki == hasWiki)&&(identical(other.hasPages, hasPages) || other.hasPages == hasPages)&&(identical(other.hasDownloads, hasDownloads) || other.hasDownloads == hasDownloads)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.disabled, disabled) || other.disabled == disabled)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,fullName,owner,isPrivate,htmlUrl,description,fork,createdAt,updatedAt,pushedAt,gitUrl,sshUrl,cloneUrl,defaultBranch,stargazersCount,watchersCount,forksCount,openIssuesCount,language,hasIssues,hasProjects,hasWiki,hasPages,hasDownloads,archived,disabled,visibility]);

@override
String toString() {
  return 'RepoResponse(id: $id, name: $name, fullName: $fullName, owner: $owner, isPrivate: $isPrivate, htmlUrl: $htmlUrl, description: $description, fork: $fork, createdAt: $createdAt, updatedAt: $updatedAt, pushedAt: $pushedAt, gitUrl: $gitUrl, sshUrl: $sshUrl, cloneUrl: $cloneUrl, defaultBranch: $defaultBranch, stargazersCount: $stargazersCount, watchersCount: $watchersCount, forksCount: $forksCount, openIssuesCount: $openIssuesCount, language: $language, hasIssues: $hasIssues, hasProjects: $hasProjects, hasWiki: $hasWiki, hasPages: $hasPages, hasDownloads: $hasDownloads, archived: $archived, disabled: $disabled, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class $RepoResponseCopyWith<$Res>  {
  factory $RepoResponseCopyWith(RepoResponse value, $Res Function(RepoResponse) _then) = _$RepoResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'full_name') String fullName, RepoOwner owner,@JsonKey(name: 'private') bool isPrivate,@JsonKey(name: 'html_url') String? htmlUrl, String? description, bool? fork,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'pushed_at') DateTime? pushedAt,@JsonKey(name: 'git_url') String? gitUrl,@JsonKey(name: 'ssh_url') String? sshUrl,@JsonKey(name: 'clone_url') String? cloneUrl,@JsonKey(name: 'default_branch') String? defaultBranch,@JsonKey(name: 'stargazers_count') int? stargazersCount,@JsonKey(name: 'watchers_count') int? watchersCount,@JsonKey(name: 'forks_count') int? forksCount,@JsonKey(name: 'open_issues_count') int? openIssuesCount, String? language,@JsonKey(name: 'has_issues') bool? hasIssues,@JsonKey(name: 'has_projects') bool? hasProjects,@JsonKey(name: 'has_wiki') bool? hasWiki,@JsonKey(name: 'has_pages') bool? hasPages,@JsonKey(name: 'has_downloads') bool? hasDownloads, bool? archived, bool? disabled, String? visibility
});


$RepoOwnerCopyWith<$Res> get owner;

}
/// @nodoc
class _$RepoResponseCopyWithImpl<$Res>
    implements $RepoResponseCopyWith<$Res> {
  _$RepoResponseCopyWithImpl(this._self, this._then);

  final RepoResponse _self;
  final $Res Function(RepoResponse) _then;

/// Create a copy of RepoResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? fullName = null,Object? owner = null,Object? isPrivate = null,Object? htmlUrl = freezed,Object? description = freezed,Object? fork = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? pushedAt = freezed,Object? gitUrl = freezed,Object? sshUrl = freezed,Object? cloneUrl = freezed,Object? defaultBranch = freezed,Object? stargazersCount = freezed,Object? watchersCount = freezed,Object? forksCount = freezed,Object? openIssuesCount = freezed,Object? language = freezed,Object? hasIssues = freezed,Object? hasProjects = freezed,Object? hasWiki = freezed,Object? hasPages = freezed,Object? hasDownloads = freezed,Object? archived = freezed,Object? disabled = freezed,Object? visibility = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as RepoOwner,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,htmlUrl: freezed == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fork: freezed == fork ? _self.fork : fork // ignore: cast_nullable_to_non_nullable
as bool?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pushedAt: freezed == pushedAt ? _self.pushedAt : pushedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,gitUrl: freezed == gitUrl ? _self.gitUrl : gitUrl // ignore: cast_nullable_to_non_nullable
as String?,sshUrl: freezed == sshUrl ? _self.sshUrl : sshUrl // ignore: cast_nullable_to_non_nullable
as String?,cloneUrl: freezed == cloneUrl ? _self.cloneUrl : cloneUrl // ignore: cast_nullable_to_non_nullable
as String?,defaultBranch: freezed == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as String?,stargazersCount: freezed == stargazersCount ? _self.stargazersCount : stargazersCount // ignore: cast_nullable_to_non_nullable
as int?,watchersCount: freezed == watchersCount ? _self.watchersCount : watchersCount // ignore: cast_nullable_to_non_nullable
as int?,forksCount: freezed == forksCount ? _self.forksCount : forksCount // ignore: cast_nullable_to_non_nullable
as int?,openIssuesCount: freezed == openIssuesCount ? _self.openIssuesCount : openIssuesCount // ignore: cast_nullable_to_non_nullable
as int?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,hasIssues: freezed == hasIssues ? _self.hasIssues : hasIssues // ignore: cast_nullable_to_non_nullable
as bool?,hasProjects: freezed == hasProjects ? _self.hasProjects : hasProjects // ignore: cast_nullable_to_non_nullable
as bool?,hasWiki: freezed == hasWiki ? _self.hasWiki : hasWiki // ignore: cast_nullable_to_non_nullable
as bool?,hasPages: freezed == hasPages ? _self.hasPages : hasPages // ignore: cast_nullable_to_non_nullable
as bool?,hasDownloads: freezed == hasDownloads ? _self.hasDownloads : hasDownloads // ignore: cast_nullable_to_non_nullable
as bool?,archived: freezed == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool?,disabled: freezed == disabled ? _self.disabled : disabled // ignore: cast_nullable_to_non_nullable
as bool?,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RepoResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepoOwnerCopyWith<$Res> get owner {
  
  return $RepoOwnerCopyWith<$Res>(_self.owner, (value) {
    return _then(_self.copyWith(owner: value));
  });
}
}


/// Adds pattern-matching-related methods to [RepoResponse].
extension RepoResponsePatterns on RepoResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepoResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepoResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepoResponse value)  $default,){
final _that = this;
switch (_that) {
case _RepoResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepoResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RepoResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'full_name')  String fullName,  RepoOwner owner, @JsonKey(name: 'private')  bool isPrivate, @JsonKey(name: 'html_url')  String? htmlUrl,  String? description,  bool? fork, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'pushed_at')  DateTime? pushedAt, @JsonKey(name: 'git_url')  String? gitUrl, @JsonKey(name: 'ssh_url')  String? sshUrl, @JsonKey(name: 'clone_url')  String? cloneUrl, @JsonKey(name: 'default_branch')  String? defaultBranch, @JsonKey(name: 'stargazers_count')  int? stargazersCount, @JsonKey(name: 'watchers_count')  int? watchersCount, @JsonKey(name: 'forks_count')  int? forksCount, @JsonKey(name: 'open_issues_count')  int? openIssuesCount,  String? language, @JsonKey(name: 'has_issues')  bool? hasIssues, @JsonKey(name: 'has_projects')  bool? hasProjects, @JsonKey(name: 'has_wiki')  bool? hasWiki, @JsonKey(name: 'has_pages')  bool? hasPages, @JsonKey(name: 'has_downloads')  bool? hasDownloads,  bool? archived,  bool? disabled,  String? visibility)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepoResponse() when $default != null:
return $default(_that.id,_that.name,_that.fullName,_that.owner,_that.isPrivate,_that.htmlUrl,_that.description,_that.fork,_that.createdAt,_that.updatedAt,_that.pushedAt,_that.gitUrl,_that.sshUrl,_that.cloneUrl,_that.defaultBranch,_that.stargazersCount,_that.watchersCount,_that.forksCount,_that.openIssuesCount,_that.language,_that.hasIssues,_that.hasProjects,_that.hasWiki,_that.hasPages,_that.hasDownloads,_that.archived,_that.disabled,_that.visibility);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'full_name')  String fullName,  RepoOwner owner, @JsonKey(name: 'private')  bool isPrivate, @JsonKey(name: 'html_url')  String? htmlUrl,  String? description,  bool? fork, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'pushed_at')  DateTime? pushedAt, @JsonKey(name: 'git_url')  String? gitUrl, @JsonKey(name: 'ssh_url')  String? sshUrl, @JsonKey(name: 'clone_url')  String? cloneUrl, @JsonKey(name: 'default_branch')  String? defaultBranch, @JsonKey(name: 'stargazers_count')  int? stargazersCount, @JsonKey(name: 'watchers_count')  int? watchersCount, @JsonKey(name: 'forks_count')  int? forksCount, @JsonKey(name: 'open_issues_count')  int? openIssuesCount,  String? language, @JsonKey(name: 'has_issues')  bool? hasIssues, @JsonKey(name: 'has_projects')  bool? hasProjects, @JsonKey(name: 'has_wiki')  bool? hasWiki, @JsonKey(name: 'has_pages')  bool? hasPages, @JsonKey(name: 'has_downloads')  bool? hasDownloads,  bool? archived,  bool? disabled,  String? visibility)  $default,) {final _that = this;
switch (_that) {
case _RepoResponse():
return $default(_that.id,_that.name,_that.fullName,_that.owner,_that.isPrivate,_that.htmlUrl,_that.description,_that.fork,_that.createdAt,_that.updatedAt,_that.pushedAt,_that.gitUrl,_that.sshUrl,_that.cloneUrl,_that.defaultBranch,_that.stargazersCount,_that.watchersCount,_that.forksCount,_that.openIssuesCount,_that.language,_that.hasIssues,_that.hasProjects,_that.hasWiki,_that.hasPages,_that.hasDownloads,_that.archived,_that.disabled,_that.visibility);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'full_name')  String fullName,  RepoOwner owner, @JsonKey(name: 'private')  bool isPrivate, @JsonKey(name: 'html_url')  String? htmlUrl,  String? description,  bool? fork, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'pushed_at')  DateTime? pushedAt, @JsonKey(name: 'git_url')  String? gitUrl, @JsonKey(name: 'ssh_url')  String? sshUrl, @JsonKey(name: 'clone_url')  String? cloneUrl, @JsonKey(name: 'default_branch')  String? defaultBranch, @JsonKey(name: 'stargazers_count')  int? stargazersCount, @JsonKey(name: 'watchers_count')  int? watchersCount, @JsonKey(name: 'forks_count')  int? forksCount, @JsonKey(name: 'open_issues_count')  int? openIssuesCount,  String? language, @JsonKey(name: 'has_issues')  bool? hasIssues, @JsonKey(name: 'has_projects')  bool? hasProjects, @JsonKey(name: 'has_wiki')  bool? hasWiki, @JsonKey(name: 'has_pages')  bool? hasPages, @JsonKey(name: 'has_downloads')  bool? hasDownloads,  bool? archived,  bool? disabled,  String? visibility)?  $default,) {final _that = this;
switch (_that) {
case _RepoResponse() when $default != null:
return $default(_that.id,_that.name,_that.fullName,_that.owner,_that.isPrivate,_that.htmlUrl,_that.description,_that.fork,_that.createdAt,_that.updatedAt,_that.pushedAt,_that.gitUrl,_that.sshUrl,_that.cloneUrl,_that.defaultBranch,_that.stargazersCount,_that.watchersCount,_that.forksCount,_that.openIssuesCount,_that.language,_that.hasIssues,_that.hasProjects,_that.hasWiki,_that.hasPages,_that.hasDownloads,_that.archived,_that.disabled,_that.visibility);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepoResponse implements RepoResponse {
  const _RepoResponse({required this.id, required this.name, @JsonKey(name: 'full_name') required this.fullName, required this.owner, @JsonKey(name: 'private') required this.isPrivate, @JsonKey(name: 'html_url') this.htmlUrl, this.description, this.fork, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'pushed_at') this.pushedAt, @JsonKey(name: 'git_url') this.gitUrl, @JsonKey(name: 'ssh_url') this.sshUrl, @JsonKey(name: 'clone_url') this.cloneUrl, @JsonKey(name: 'default_branch') this.defaultBranch, @JsonKey(name: 'stargazers_count') this.stargazersCount, @JsonKey(name: 'watchers_count') this.watchersCount, @JsonKey(name: 'forks_count') this.forksCount, @JsonKey(name: 'open_issues_count') this.openIssuesCount, this.language, @JsonKey(name: 'has_issues') this.hasIssues, @JsonKey(name: 'has_projects') this.hasProjects, @JsonKey(name: 'has_wiki') this.hasWiki, @JsonKey(name: 'has_pages') this.hasPages, @JsonKey(name: 'has_downloads') this.hasDownloads, this.archived, this.disabled, this.visibility});
  factory _RepoResponse.fromJson(Map<String, dynamic> json) => _$RepoResponseFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'full_name') final  String fullName;
@override final  RepoOwner owner;
@override@JsonKey(name: 'private') final  bool isPrivate;
@override@JsonKey(name: 'html_url') final  String? htmlUrl;
@override final  String? description;
@override final  bool? fork;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(name: 'pushed_at') final  DateTime? pushedAt;
@override@JsonKey(name: 'git_url') final  String? gitUrl;
@override@JsonKey(name: 'ssh_url') final  String? sshUrl;
@override@JsonKey(name: 'clone_url') final  String? cloneUrl;
@override@JsonKey(name: 'default_branch') final  String? defaultBranch;
@override@JsonKey(name: 'stargazers_count') final  int? stargazersCount;
@override@JsonKey(name: 'watchers_count') final  int? watchersCount;
@override@JsonKey(name: 'forks_count') final  int? forksCount;
@override@JsonKey(name: 'open_issues_count') final  int? openIssuesCount;
@override final  String? language;
@override@JsonKey(name: 'has_issues') final  bool? hasIssues;
@override@JsonKey(name: 'has_projects') final  bool? hasProjects;
@override@JsonKey(name: 'has_wiki') final  bool? hasWiki;
@override@JsonKey(name: 'has_pages') final  bool? hasPages;
@override@JsonKey(name: 'has_downloads') final  bool? hasDownloads;
@override final  bool? archived;
@override final  bool? disabled;
@override final  String? visibility;

/// Create a copy of RepoResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepoResponseCopyWith<_RepoResponse> get copyWith => __$RepoResponseCopyWithImpl<_RepoResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepoResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepoResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.owner, owner) || other.owner == owner)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.fork, fork) || other.fork == fork)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.pushedAt, pushedAt) || other.pushedAt == pushedAt)&&(identical(other.gitUrl, gitUrl) || other.gitUrl == gitUrl)&&(identical(other.sshUrl, sshUrl) || other.sshUrl == sshUrl)&&(identical(other.cloneUrl, cloneUrl) || other.cloneUrl == cloneUrl)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch)&&(identical(other.stargazersCount, stargazersCount) || other.stargazersCount == stargazersCount)&&(identical(other.watchersCount, watchersCount) || other.watchersCount == watchersCount)&&(identical(other.forksCount, forksCount) || other.forksCount == forksCount)&&(identical(other.openIssuesCount, openIssuesCount) || other.openIssuesCount == openIssuesCount)&&(identical(other.language, language) || other.language == language)&&(identical(other.hasIssues, hasIssues) || other.hasIssues == hasIssues)&&(identical(other.hasProjects, hasProjects) || other.hasProjects == hasProjects)&&(identical(other.hasWiki, hasWiki) || other.hasWiki == hasWiki)&&(identical(other.hasPages, hasPages) || other.hasPages == hasPages)&&(identical(other.hasDownloads, hasDownloads) || other.hasDownloads == hasDownloads)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.disabled, disabled) || other.disabled == disabled)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,fullName,owner,isPrivate,htmlUrl,description,fork,createdAt,updatedAt,pushedAt,gitUrl,sshUrl,cloneUrl,defaultBranch,stargazersCount,watchersCount,forksCount,openIssuesCount,language,hasIssues,hasProjects,hasWiki,hasPages,hasDownloads,archived,disabled,visibility]);

@override
String toString() {
  return 'RepoResponse(id: $id, name: $name, fullName: $fullName, owner: $owner, isPrivate: $isPrivate, htmlUrl: $htmlUrl, description: $description, fork: $fork, createdAt: $createdAt, updatedAt: $updatedAt, pushedAt: $pushedAt, gitUrl: $gitUrl, sshUrl: $sshUrl, cloneUrl: $cloneUrl, defaultBranch: $defaultBranch, stargazersCount: $stargazersCount, watchersCount: $watchersCount, forksCount: $forksCount, openIssuesCount: $openIssuesCount, language: $language, hasIssues: $hasIssues, hasProjects: $hasProjects, hasWiki: $hasWiki, hasPages: $hasPages, hasDownloads: $hasDownloads, archived: $archived, disabled: $disabled, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class _$RepoResponseCopyWith<$Res> implements $RepoResponseCopyWith<$Res> {
  factory _$RepoResponseCopyWith(_RepoResponse value, $Res Function(_RepoResponse) _then) = __$RepoResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'full_name') String fullName, RepoOwner owner,@JsonKey(name: 'private') bool isPrivate,@JsonKey(name: 'html_url') String? htmlUrl, String? description, bool? fork,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'pushed_at') DateTime? pushedAt,@JsonKey(name: 'git_url') String? gitUrl,@JsonKey(name: 'ssh_url') String? sshUrl,@JsonKey(name: 'clone_url') String? cloneUrl,@JsonKey(name: 'default_branch') String? defaultBranch,@JsonKey(name: 'stargazers_count') int? stargazersCount,@JsonKey(name: 'watchers_count') int? watchersCount,@JsonKey(name: 'forks_count') int? forksCount,@JsonKey(name: 'open_issues_count') int? openIssuesCount, String? language,@JsonKey(name: 'has_issues') bool? hasIssues,@JsonKey(name: 'has_projects') bool? hasProjects,@JsonKey(name: 'has_wiki') bool? hasWiki,@JsonKey(name: 'has_pages') bool? hasPages,@JsonKey(name: 'has_downloads') bool? hasDownloads, bool? archived, bool? disabled, String? visibility
});


@override $RepoOwnerCopyWith<$Res> get owner;

}
/// @nodoc
class __$RepoResponseCopyWithImpl<$Res>
    implements _$RepoResponseCopyWith<$Res> {
  __$RepoResponseCopyWithImpl(this._self, this._then);

  final _RepoResponse _self;
  final $Res Function(_RepoResponse) _then;

/// Create a copy of RepoResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? fullName = null,Object? owner = null,Object? isPrivate = null,Object? htmlUrl = freezed,Object? description = freezed,Object? fork = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? pushedAt = freezed,Object? gitUrl = freezed,Object? sshUrl = freezed,Object? cloneUrl = freezed,Object? defaultBranch = freezed,Object? stargazersCount = freezed,Object? watchersCount = freezed,Object? forksCount = freezed,Object? openIssuesCount = freezed,Object? language = freezed,Object? hasIssues = freezed,Object? hasProjects = freezed,Object? hasWiki = freezed,Object? hasPages = freezed,Object? hasDownloads = freezed,Object? archived = freezed,Object? disabled = freezed,Object? visibility = freezed,}) {
  return _then(_RepoResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,owner: null == owner ? _self.owner : owner // ignore: cast_nullable_to_non_nullable
as RepoOwner,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,htmlUrl: freezed == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fork: freezed == fork ? _self.fork : fork // ignore: cast_nullable_to_non_nullable
as bool?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pushedAt: freezed == pushedAt ? _self.pushedAt : pushedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,gitUrl: freezed == gitUrl ? _self.gitUrl : gitUrl // ignore: cast_nullable_to_non_nullable
as String?,sshUrl: freezed == sshUrl ? _self.sshUrl : sshUrl // ignore: cast_nullable_to_non_nullable
as String?,cloneUrl: freezed == cloneUrl ? _self.cloneUrl : cloneUrl // ignore: cast_nullable_to_non_nullable
as String?,defaultBranch: freezed == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as String?,stargazersCount: freezed == stargazersCount ? _self.stargazersCount : stargazersCount // ignore: cast_nullable_to_non_nullable
as int?,watchersCount: freezed == watchersCount ? _self.watchersCount : watchersCount // ignore: cast_nullable_to_non_nullable
as int?,forksCount: freezed == forksCount ? _self.forksCount : forksCount // ignore: cast_nullable_to_non_nullable
as int?,openIssuesCount: freezed == openIssuesCount ? _self.openIssuesCount : openIssuesCount // ignore: cast_nullable_to_non_nullable
as int?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,hasIssues: freezed == hasIssues ? _self.hasIssues : hasIssues // ignore: cast_nullable_to_non_nullable
as bool?,hasProjects: freezed == hasProjects ? _self.hasProjects : hasProjects // ignore: cast_nullable_to_non_nullable
as bool?,hasWiki: freezed == hasWiki ? _self.hasWiki : hasWiki // ignore: cast_nullable_to_non_nullable
as bool?,hasPages: freezed == hasPages ? _self.hasPages : hasPages // ignore: cast_nullable_to_non_nullable
as bool?,hasDownloads: freezed == hasDownloads ? _self.hasDownloads : hasDownloads // ignore: cast_nullable_to_non_nullable
as bool?,archived: freezed == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool?,disabled: freezed == disabled ? _self.disabled : disabled // ignore: cast_nullable_to_non_nullable
as bool?,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RepoResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepoOwnerCopyWith<$Res> get owner {
  
  return $RepoOwnerCopyWith<$Res>(_self.owner, (value) {
    return _then(_self.copyWith(owner: value));
  });
}
}

// dart format on

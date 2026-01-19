// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GitHubUserResponse {

 int get id; String get login;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'html_url') String? get htmlUrl; String? get name; String? get email; String? get bio; String? get company; String? get location;@JsonKey(name: 'public_repos') int? get publicRepos;@JsonKey(name: 'public_gists') int? get publicGists; int? get followers; int? get following;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of GitHubUserResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitHubUserResponseCopyWith<GitHubUserResponse> get copyWith => _$GitHubUserResponseCopyWithImpl<GitHubUserResponse>(this as GitHubUserResponse, _$identity);

  /// Serializes this GitHubUserResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitHubUserResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.login, login) || other.login == login)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.publicRepos, publicRepos) || other.publicRepos == publicRepos)&&(identical(other.publicGists, publicGists) || other.publicGists == publicGists)&&(identical(other.followers, followers) || other.followers == followers)&&(identical(other.following, following) || other.following == following)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,login,avatarUrl,htmlUrl,name,email,bio,company,location,publicRepos,publicGists,followers,following,createdAt,updatedAt);

@override
String toString() {
  return 'GitHubUserResponse(id: $id, login: $login, avatarUrl: $avatarUrl, htmlUrl: $htmlUrl, name: $name, email: $email, bio: $bio, company: $company, location: $location, publicRepos: $publicRepos, publicGists: $publicGists, followers: $followers, following: $following, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GitHubUserResponseCopyWith<$Res>  {
  factory $GitHubUserResponseCopyWith(GitHubUserResponse value, $Res Function(GitHubUserResponse) _then) = _$GitHubUserResponseCopyWithImpl;
@useResult
$Res call({
 int id, String login,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'html_url') String? htmlUrl, String? name, String? email, String? bio, String? company, String? location,@JsonKey(name: 'public_repos') int? publicRepos,@JsonKey(name: 'public_gists') int? publicGists, int? followers, int? following,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$GitHubUserResponseCopyWithImpl<$Res>
    implements $GitHubUserResponseCopyWith<$Res> {
  _$GitHubUserResponseCopyWithImpl(this._self, this._then);

  final GitHubUserResponse _self;
  final $Res Function(GitHubUserResponse) _then;

/// Create a copy of GitHubUserResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? login = null,Object? avatarUrl = freezed,Object? htmlUrl = freezed,Object? name = freezed,Object? email = freezed,Object? bio = freezed,Object? company = freezed,Object? location = freezed,Object? publicRepos = freezed,Object? publicGists = freezed,Object? followers = freezed,Object? following = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,htmlUrl: freezed == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,publicRepos: freezed == publicRepos ? _self.publicRepos : publicRepos // ignore: cast_nullable_to_non_nullable
as int?,publicGists: freezed == publicGists ? _self.publicGists : publicGists // ignore: cast_nullable_to_non_nullable
as int?,followers: freezed == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as int?,following: freezed == following ? _self.following : following // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GitHubUserResponse].
extension GitHubUserResponsePatterns on GitHubUserResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitHubUserResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitHubUserResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitHubUserResponse value)  $default,){
final _that = this;
switch (_that) {
case _GitHubUserResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitHubUserResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GitHubUserResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String login, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'html_url')  String? htmlUrl,  String? name,  String? email,  String? bio,  String? company,  String? location, @JsonKey(name: 'public_repos')  int? publicRepos, @JsonKey(name: 'public_gists')  int? publicGists,  int? followers,  int? following, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitHubUserResponse() when $default != null:
return $default(_that.id,_that.login,_that.avatarUrl,_that.htmlUrl,_that.name,_that.email,_that.bio,_that.company,_that.location,_that.publicRepos,_that.publicGists,_that.followers,_that.following,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String login, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'html_url')  String? htmlUrl,  String? name,  String? email,  String? bio,  String? company,  String? location, @JsonKey(name: 'public_repos')  int? publicRepos, @JsonKey(name: 'public_gists')  int? publicGists,  int? followers,  int? following, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GitHubUserResponse():
return $default(_that.id,_that.login,_that.avatarUrl,_that.htmlUrl,_that.name,_that.email,_that.bio,_that.company,_that.location,_that.publicRepos,_that.publicGists,_that.followers,_that.following,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String login, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'html_url')  String? htmlUrl,  String? name,  String? email,  String? bio,  String? company,  String? location, @JsonKey(name: 'public_repos')  int? publicRepos, @JsonKey(name: 'public_gists')  int? publicGists,  int? followers,  int? following, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GitHubUserResponse() when $default != null:
return $default(_that.id,_that.login,_that.avatarUrl,_that.htmlUrl,_that.name,_that.email,_that.bio,_that.company,_that.location,_that.publicRepos,_that.publicGists,_that.followers,_that.following,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GitHubUserResponse implements GitHubUserResponse {
  const _GitHubUserResponse({required this.id, required this.login, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'html_url') this.htmlUrl, this.name, this.email, this.bio, this.company, this.location, @JsonKey(name: 'public_repos') this.publicRepos, @JsonKey(name: 'public_gists') this.publicGists, this.followers, this.following, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _GitHubUserResponse.fromJson(Map<String, dynamic> json) => _$GitHubUserResponseFromJson(json);

@override final  int id;
@override final  String login;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'html_url') final  String? htmlUrl;
@override final  String? name;
@override final  String? email;
@override final  String? bio;
@override final  String? company;
@override final  String? location;
@override@JsonKey(name: 'public_repos') final  int? publicRepos;
@override@JsonKey(name: 'public_gists') final  int? publicGists;
@override final  int? followers;
@override final  int? following;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of GitHubUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitHubUserResponseCopyWith<_GitHubUserResponse> get copyWith => __$GitHubUserResponseCopyWithImpl<_GitHubUserResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GitHubUserResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitHubUserResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.login, login) || other.login == login)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.publicRepos, publicRepos) || other.publicRepos == publicRepos)&&(identical(other.publicGists, publicGists) || other.publicGists == publicGists)&&(identical(other.followers, followers) || other.followers == followers)&&(identical(other.following, following) || other.following == following)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,login,avatarUrl,htmlUrl,name,email,bio,company,location,publicRepos,publicGists,followers,following,createdAt,updatedAt);

@override
String toString() {
  return 'GitHubUserResponse(id: $id, login: $login, avatarUrl: $avatarUrl, htmlUrl: $htmlUrl, name: $name, email: $email, bio: $bio, company: $company, location: $location, publicRepos: $publicRepos, publicGists: $publicGists, followers: $followers, following: $following, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GitHubUserResponseCopyWith<$Res> implements $GitHubUserResponseCopyWith<$Res> {
  factory _$GitHubUserResponseCopyWith(_GitHubUserResponse value, $Res Function(_GitHubUserResponse) _then) = __$GitHubUserResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String login,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'html_url') String? htmlUrl, String? name, String? email, String? bio, String? company, String? location,@JsonKey(name: 'public_repos') int? publicRepos,@JsonKey(name: 'public_gists') int? publicGists, int? followers, int? following,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$GitHubUserResponseCopyWithImpl<$Res>
    implements _$GitHubUserResponseCopyWith<$Res> {
  __$GitHubUserResponseCopyWithImpl(this._self, this._then);

  final _GitHubUserResponse _self;
  final $Res Function(_GitHubUserResponse) _then;

/// Create a copy of GitHubUserResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? login = null,Object? avatarUrl = freezed,Object? htmlUrl = freezed,Object? name = freezed,Object? email = freezed,Object? bio = freezed,Object? company = freezed,Object? location = freezed,Object? publicRepos = freezed,Object? publicGists = freezed,Object? followers = freezed,Object? following = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_GitHubUserResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,htmlUrl: freezed == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,publicRepos: freezed == publicRepos ? _self.publicRepos : publicRepos // ignore: cast_nullable_to_non_nullable
as int?,publicGists: freezed == publicGists ? _self.publicGists : publicGists // ignore: cast_nullable_to_non_nullable
as int?,followers: freezed == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as int?,following: freezed == following ? _self.following : following // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

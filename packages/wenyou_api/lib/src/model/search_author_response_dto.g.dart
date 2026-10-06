// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_author_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SearchAuthorResponseDto extends SearchAuthorResponseDto {
  @override
  final RpIdentityResponseDto? rpIdentity;
  @override
  final String id;
  @override
  final String username;

  factory _$SearchAuthorResponseDto([
    void Function(SearchAuthorResponseDtoBuilder)? updates,
  ]) => (SearchAuthorResponseDtoBuilder()..update(updates))._build();

  _$SearchAuthorResponseDto._({
    this.rpIdentity,
    required this.id,
    required this.username,
  }) : super._();
  @override
  SearchAuthorResponseDto rebuild(
    void Function(SearchAuthorResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SearchAuthorResponseDtoBuilder toBuilder() =>
      SearchAuthorResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchAuthorResponseDto &&
        rpIdentity == other.rpIdentity &&
        id == other.id &&
        username == other.username;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rpIdentity.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchAuthorResponseDto')
          ..add('rpIdentity', rpIdentity)
          ..add('id', id)
          ..add('username', username))
        .toString();
  }
}

class SearchAuthorResponseDtoBuilder
    implements
        Builder<SearchAuthorResponseDto, SearchAuthorResponseDtoBuilder> {
  _$SearchAuthorResponseDto? _$v;

  RpIdentityResponseDtoBuilder? _rpIdentity;
  RpIdentityResponseDtoBuilder get rpIdentity =>
      _$this._rpIdentity ??= RpIdentityResponseDtoBuilder();
  set rpIdentity(RpIdentityResponseDtoBuilder? rpIdentity) =>
      _$this._rpIdentity = rpIdentity;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  SearchAuthorResponseDtoBuilder() {
    SearchAuthorResponseDto._defaults(this);
  }

  SearchAuthorResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rpIdentity = $v.rpIdentity?.toBuilder();
      _id = $v.id;
      _username = $v.username;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchAuthorResponseDto other) {
    _$v = other as _$SearchAuthorResponseDto;
  }

  @override
  void update(void Function(SearchAuthorResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchAuthorResponseDto build() => _build();

  _$SearchAuthorResponseDto _build() {
    _$SearchAuthorResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$SearchAuthorResponseDto._(
            rpIdentity: _rpIdentity?.build(),
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'SearchAuthorResponseDto',
              'id',
            ),
            username: BuiltValueNullFieldError.checkNotNull(
              username,
              r'SearchAuthorResponseDto',
              'username',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rpIdentity';
        _rpIdentity?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'SearchAuthorResponseDto',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

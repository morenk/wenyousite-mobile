// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_session_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminSessionResponseDto extends AdminSessionResponseDto {
  @override
  final BuiltMap<String, JsonObject?> session;
  @override
  final BuiltMap<String, JsonObject?> user;
  @override
  final String csrfToken;

  factory _$AdminSessionResponseDto([
    void Function(AdminSessionResponseDtoBuilder)? updates,
  ]) => (AdminSessionResponseDtoBuilder()..update(updates))._build();

  _$AdminSessionResponseDto._({
    required this.session,
    required this.user,
    required this.csrfToken,
  }) : super._();
  @override
  AdminSessionResponseDto rebuild(
    void Function(AdminSessionResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminSessionResponseDtoBuilder toBuilder() =>
      AdminSessionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminSessionResponseDto &&
        session == other.session &&
        user == other.user &&
        csrfToken == other.csrfToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, session.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, csrfToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminSessionResponseDto')
          ..add('session', session)
          ..add('user', user)
          ..add('csrfToken', csrfToken))
        .toString();
  }
}

class AdminSessionResponseDtoBuilder
    implements
        Builder<AdminSessionResponseDto, AdminSessionResponseDtoBuilder> {
  _$AdminSessionResponseDto? _$v;

  MapBuilder<String, JsonObject?>? _session;
  MapBuilder<String, JsonObject?> get session =>
      _$this._session ??= MapBuilder<String, JsonObject?>();
  set session(MapBuilder<String, JsonObject?>? session) =>
      _$this._session = session;

  MapBuilder<String, JsonObject?>? _user;
  MapBuilder<String, JsonObject?> get user =>
      _$this._user ??= MapBuilder<String, JsonObject?>();
  set user(MapBuilder<String, JsonObject?>? user) => _$this._user = user;

  String? _csrfToken;
  String? get csrfToken => _$this._csrfToken;
  set csrfToken(String? csrfToken) => _$this._csrfToken = csrfToken;

  AdminSessionResponseDtoBuilder() {
    AdminSessionResponseDto._defaults(this);
  }

  AdminSessionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _session = $v.session.toBuilder();
      _user = $v.user.toBuilder();
      _csrfToken = $v.csrfToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminSessionResponseDto other) {
    _$v = other as _$AdminSessionResponseDto;
  }

  @override
  void update(void Function(AdminSessionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminSessionResponseDto build() => _build();

  _$AdminSessionResponseDto _build() {
    _$AdminSessionResponseDto _$result;
    try {
      _$result =
          _$v ??
          _$AdminSessionResponseDto._(
            session: session.build(),
            user: user.build(),
            csrfToken: BuiltValueNullFieldError.checkNotNull(
              csrfToken,
              r'AdminSessionResponseDto',
              'csrfToken',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'session';
        session.build();
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminSessionResponseDto',
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

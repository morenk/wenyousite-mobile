// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'joined_thread_reference_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$JoinedThreadReferenceResponseDto
    extends JoinedThreadReferenceResponseDto {
  @override
  final String id;
  @override
  final String? title;

  factory _$JoinedThreadReferenceResponseDto([
    void Function(JoinedThreadReferenceResponseDtoBuilder)? updates,
  ]) => (JoinedThreadReferenceResponseDtoBuilder()..update(updates))._build();

  _$JoinedThreadReferenceResponseDto._({required this.id, this.title})
    : super._();
  @override
  JoinedThreadReferenceResponseDto rebuild(
    void Function(JoinedThreadReferenceResponseDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  JoinedThreadReferenceResponseDtoBuilder toBuilder() =>
      JoinedThreadReferenceResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is JoinedThreadReferenceResponseDto &&
        id == other.id &&
        title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'JoinedThreadReferenceResponseDto')
          ..add('id', id)
          ..add('title', title))
        .toString();
  }
}

class JoinedThreadReferenceResponseDtoBuilder
    implements
        Builder<
          JoinedThreadReferenceResponseDto,
          JoinedThreadReferenceResponseDtoBuilder
        > {
  _$JoinedThreadReferenceResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  JoinedThreadReferenceResponseDtoBuilder() {
    JoinedThreadReferenceResponseDto._defaults(this);
  }

  JoinedThreadReferenceResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(JoinedThreadReferenceResponseDto other) {
    _$v = other as _$JoinedThreadReferenceResponseDto;
  }

  @override
  void update(void Function(JoinedThreadReferenceResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  JoinedThreadReferenceResponseDto build() => _build();

  _$JoinedThreadReferenceResponseDto _build() {
    final _$result =
        _$v ??
        _$JoinedThreadReferenceResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'JoinedThreadReferenceResponseDto',
            'id',
          ),
          title: title,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

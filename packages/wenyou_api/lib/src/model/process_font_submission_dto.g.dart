// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_font_submission_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProcessFontSubmissionDto extends ProcessFontSubmissionDto {
  @override
  final String requestId;

  factory _$ProcessFontSubmissionDto([
    void Function(ProcessFontSubmissionDtoBuilder)? updates,
  ]) => (ProcessFontSubmissionDtoBuilder()..update(updates))._build();

  _$ProcessFontSubmissionDto._({required this.requestId}) : super._();
  @override
  ProcessFontSubmissionDto rebuild(
    void Function(ProcessFontSubmissionDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ProcessFontSubmissionDtoBuilder toBuilder() =>
      ProcessFontSubmissionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProcessFontSubmissionDto && requestId == other.requestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'ProcessFontSubmissionDto',
    )..add('requestId', requestId)).toString();
  }
}

class ProcessFontSubmissionDtoBuilder
    implements
        Builder<ProcessFontSubmissionDto, ProcessFontSubmissionDtoBuilder> {
  _$ProcessFontSubmissionDto? _$v;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  ProcessFontSubmissionDtoBuilder() {
    ProcessFontSubmissionDto._defaults(this);
  }

  ProcessFontSubmissionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _requestId = $v.requestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProcessFontSubmissionDto other) {
    _$v = other as _$ProcessFontSubmissionDto;
  }

  @override
  void update(void Function(ProcessFontSubmissionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProcessFontSubmissionDto build() => _build();

  _$ProcessFontSubmissionDto _build() {
    final _$result =
        _$v ??
        _$ProcessFontSubmissionDto._(
          requestId: BuiltValueNullFieldError.checkNotNull(
            requestId,
            r'ProcessFontSubmissionDto',
            'requestId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

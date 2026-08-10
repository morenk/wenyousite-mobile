// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_moderation_appeal_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ResolveModerationAppealDtoOutcomeEnum
_$resolveModerationAppealDtoOutcomeEnum_UPHELD =
    const ResolveModerationAppealDtoOutcomeEnum._('UPHELD');
const ResolveModerationAppealDtoOutcomeEnum
_$resolveModerationAppealDtoOutcomeEnum_OVERTURNED =
    const ResolveModerationAppealDtoOutcomeEnum._('OVERTURNED');
const ResolveModerationAppealDtoOutcomeEnum
_$resolveModerationAppealDtoOutcomeEnum_unknownDefaultOpenApi =
    const ResolveModerationAppealDtoOutcomeEnum._('unknownDefaultOpenApi');

ResolveModerationAppealDtoOutcomeEnum
_$resolveModerationAppealDtoOutcomeEnumValueOf(String name) {
  switch (name) {
    case 'UPHELD':
      return _$resolveModerationAppealDtoOutcomeEnum_UPHELD;
    case 'OVERTURNED':
      return _$resolveModerationAppealDtoOutcomeEnum_OVERTURNED;
    case 'unknownDefaultOpenApi':
      return _$resolveModerationAppealDtoOutcomeEnum_unknownDefaultOpenApi;
    default:
      return _$resolveModerationAppealDtoOutcomeEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<ResolveModerationAppealDtoOutcomeEnum>
_$resolveModerationAppealDtoOutcomeEnumValues =
    BuiltSet<ResolveModerationAppealDtoOutcomeEnum>(
      const <ResolveModerationAppealDtoOutcomeEnum>[
        _$resolveModerationAppealDtoOutcomeEnum_UPHELD,
        _$resolveModerationAppealDtoOutcomeEnum_OVERTURNED,
        _$resolveModerationAppealDtoOutcomeEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<ResolveModerationAppealDtoOutcomeEnum>
_$resolveModerationAppealDtoOutcomeEnumSerializer =
    _$ResolveModerationAppealDtoOutcomeEnumSerializer();

class _$ResolveModerationAppealDtoOutcomeEnumSerializer
    implements PrimitiveSerializer<ResolveModerationAppealDtoOutcomeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'UPHELD': 'UPHELD',
    'OVERTURNED': 'OVERTURNED',
    'unknownDefaultOpenApi': 'unknown_default_open_api',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'UPHELD': 'UPHELD',
    'OVERTURNED': 'OVERTURNED',
    'unknown_default_open_api': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ResolveModerationAppealDtoOutcomeEnum,
  ];
  @override
  final String wireName = 'ResolveModerationAppealDtoOutcomeEnum';

  @override
  Object serialize(
    Serializers serializers,
    ResolveModerationAppealDtoOutcomeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ResolveModerationAppealDtoOutcomeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ResolveModerationAppealDtoOutcomeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$ResolveModerationAppealDto extends ResolveModerationAppealDto {
  @override
  final ResolveModerationAppealDtoOutcomeEnum outcome;
  @override
  final String note;

  factory _$ResolveModerationAppealDto([
    void Function(ResolveModerationAppealDtoBuilder)? updates,
  ]) => (ResolveModerationAppealDtoBuilder()..update(updates))._build();

  _$ResolveModerationAppealDto._({required this.outcome, required this.note})
    : super._();
  @override
  ResolveModerationAppealDto rebuild(
    void Function(ResolveModerationAppealDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ResolveModerationAppealDtoBuilder toBuilder() =>
      ResolveModerationAppealDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResolveModerationAppealDto &&
        outcome == other.outcome &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, outcome.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResolveModerationAppealDto')
          ..add('outcome', outcome)
          ..add('note', note))
        .toString();
  }
}

class ResolveModerationAppealDtoBuilder
    implements
        Builder<ResolveModerationAppealDto, ResolveModerationAppealDtoBuilder> {
  _$ResolveModerationAppealDto? _$v;

  ResolveModerationAppealDtoOutcomeEnum? _outcome;
  ResolveModerationAppealDtoOutcomeEnum? get outcome => _$this._outcome;
  set outcome(ResolveModerationAppealDtoOutcomeEnum? outcome) =>
      _$this._outcome = outcome;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ResolveModerationAppealDtoBuilder() {
    ResolveModerationAppealDto._defaults(this);
  }

  ResolveModerationAppealDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _outcome = $v.outcome;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResolveModerationAppealDto other) {
    _$v = other as _$ResolveModerationAppealDto;
  }

  @override
  void update(void Function(ResolveModerationAppealDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResolveModerationAppealDto build() => _build();

  _$ResolveModerationAppealDto _build() {
    final _$result =
        _$v ??
        _$ResolveModerationAppealDto._(
          outcome: BuiltValueNullFieldError.checkNotNull(
            outcome,
            r'ResolveModerationAppealDto',
            'outcome',
          ),
          note: BuiltValueNullFieldError.checkNotNull(
            note,
            r'ResolveModerationAppealDto',
            'note',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

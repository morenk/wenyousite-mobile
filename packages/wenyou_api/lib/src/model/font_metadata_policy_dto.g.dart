// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_metadata_policy_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FontMetadataPolicyDtoRevalidateAfterMsEnum
_$fontMetadataPolicyDtoRevalidateAfterMsEnum_n300000 =
    const FontMetadataPolicyDtoRevalidateAfterMsEnum._('n300000');
const FontMetadataPolicyDtoRevalidateAfterMsEnum
_$fontMetadataPolicyDtoRevalidateAfterMsEnum_unknownDefaultOpenApi =
    const FontMetadataPolicyDtoRevalidateAfterMsEnum._('unknownDefaultOpenApi');

FontMetadataPolicyDtoRevalidateAfterMsEnum
_$fontMetadataPolicyDtoRevalidateAfterMsEnumValueOf(String name) {
  switch (name) {
    case 'n300000':
      return _$fontMetadataPolicyDtoRevalidateAfterMsEnum_n300000;
    case 'unknownDefaultOpenApi':
      return _$fontMetadataPolicyDtoRevalidateAfterMsEnum_unknownDefaultOpenApi;
    default:
      return _$fontMetadataPolicyDtoRevalidateAfterMsEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontMetadataPolicyDtoRevalidateAfterMsEnum>
_$fontMetadataPolicyDtoRevalidateAfterMsEnumValues =
    BuiltSet<FontMetadataPolicyDtoRevalidateAfterMsEnum>(
      const <FontMetadataPolicyDtoRevalidateAfterMsEnum>[
        _$fontMetadataPolicyDtoRevalidateAfterMsEnum_n300000,
        _$fontMetadataPolicyDtoRevalidateAfterMsEnum_unknownDefaultOpenApi,
      ],
    );

const FontMetadataPolicyDtoNegativeCacheMsEnum
_$fontMetadataPolicyDtoNegativeCacheMsEnum_n30000 =
    const FontMetadataPolicyDtoNegativeCacheMsEnum._('n30000');
const FontMetadataPolicyDtoNegativeCacheMsEnum
_$fontMetadataPolicyDtoNegativeCacheMsEnum_unknownDefaultOpenApi =
    const FontMetadataPolicyDtoNegativeCacheMsEnum._('unknownDefaultOpenApi');

FontMetadataPolicyDtoNegativeCacheMsEnum
_$fontMetadataPolicyDtoNegativeCacheMsEnumValueOf(String name) {
  switch (name) {
    case 'n30000':
      return _$fontMetadataPolicyDtoNegativeCacheMsEnum_n30000;
    case 'unknownDefaultOpenApi':
      return _$fontMetadataPolicyDtoNegativeCacheMsEnum_unknownDefaultOpenApi;
    default:
      return _$fontMetadataPolicyDtoNegativeCacheMsEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontMetadataPolicyDtoNegativeCacheMsEnum>
_$fontMetadataPolicyDtoNegativeCacheMsEnumValues =
    BuiltSet<FontMetadataPolicyDtoNegativeCacheMsEnum>(
      const <FontMetadataPolicyDtoNegativeCacheMsEnum>[
        _$fontMetadataPolicyDtoNegativeCacheMsEnum_n30000,
        _$fontMetadataPolicyDtoNegativeCacheMsEnum_unknownDefaultOpenApi,
      ],
    );

const FontMetadataPolicyDtoReservationBytesEnum
_$fontMetadataPolicyDtoReservationBytesEnum_n65536 =
    const FontMetadataPolicyDtoReservationBytesEnum._('n65536');
const FontMetadataPolicyDtoReservationBytesEnum
_$fontMetadataPolicyDtoReservationBytesEnum_unknownDefaultOpenApi =
    const FontMetadataPolicyDtoReservationBytesEnum._('unknownDefaultOpenApi');

FontMetadataPolicyDtoReservationBytesEnum
_$fontMetadataPolicyDtoReservationBytesEnumValueOf(String name) {
  switch (name) {
    case 'n65536':
      return _$fontMetadataPolicyDtoReservationBytesEnum_n65536;
    case 'unknownDefaultOpenApi':
      return _$fontMetadataPolicyDtoReservationBytesEnum_unknownDefaultOpenApi;
    default:
      return _$fontMetadataPolicyDtoReservationBytesEnum_unknownDefaultOpenApi;
  }
}

final BuiltSet<FontMetadataPolicyDtoReservationBytesEnum>
_$fontMetadataPolicyDtoReservationBytesEnumValues =
    BuiltSet<FontMetadataPolicyDtoReservationBytesEnum>(
      const <FontMetadataPolicyDtoReservationBytesEnum>[
        _$fontMetadataPolicyDtoReservationBytesEnum_n65536,
        _$fontMetadataPolicyDtoReservationBytesEnum_unknownDefaultOpenApi,
      ],
    );

Serializer<FontMetadataPolicyDtoRevalidateAfterMsEnum>
_$fontMetadataPolicyDtoRevalidateAfterMsEnumSerializer =
    _$FontMetadataPolicyDtoRevalidateAfterMsEnumSerializer();
Serializer<FontMetadataPolicyDtoNegativeCacheMsEnum>
_$fontMetadataPolicyDtoNegativeCacheMsEnumSerializer =
    _$FontMetadataPolicyDtoNegativeCacheMsEnumSerializer();
Serializer<FontMetadataPolicyDtoReservationBytesEnum>
_$fontMetadataPolicyDtoReservationBytesEnumSerializer =
    _$FontMetadataPolicyDtoReservationBytesEnumSerializer();

class _$FontMetadataPolicyDtoRevalidateAfterMsEnumSerializer
    implements PrimitiveSerializer<FontMetadataPolicyDtoRevalidateAfterMsEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n300000': '300000',
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '300000': 'n300000',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    FontMetadataPolicyDtoRevalidateAfterMsEnum,
  ];
  @override
  final String wireName = 'FontMetadataPolicyDtoRevalidateAfterMsEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontMetadataPolicyDtoRevalidateAfterMsEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontMetadataPolicyDtoRevalidateAfterMsEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontMetadataPolicyDtoRevalidateAfterMsEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontMetadataPolicyDtoNegativeCacheMsEnumSerializer
    implements PrimitiveSerializer<FontMetadataPolicyDtoNegativeCacheMsEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n30000': '30000',
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '30000': 'n30000',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    FontMetadataPolicyDtoNegativeCacheMsEnum,
  ];
  @override
  final String wireName = 'FontMetadataPolicyDtoNegativeCacheMsEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontMetadataPolicyDtoNegativeCacheMsEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontMetadataPolicyDtoNegativeCacheMsEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontMetadataPolicyDtoNegativeCacheMsEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontMetadataPolicyDtoReservationBytesEnumSerializer
    implements PrimitiveSerializer<FontMetadataPolicyDtoReservationBytesEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n65536': '65536',
    'unknownDefaultOpenApi': '11184809',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '65536': 'n65536',
    '11184809': 'unknownDefaultOpenApi',
  };

  @override
  final Iterable<Type> types = const <Type>[
    FontMetadataPolicyDtoReservationBytesEnum,
  ];
  @override
  final String wireName = 'FontMetadataPolicyDtoReservationBytesEnum';

  @override
  Object serialize(
    Serializers serializers,
    FontMetadataPolicyDtoReservationBytesEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  FontMetadataPolicyDtoReservationBytesEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => FontMetadataPolicyDtoReservationBytesEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$FontMetadataPolicyDto extends FontMetadataPolicyDto {
  @override
  final FontMetadataPolicyDtoRevalidateAfterMsEnum revalidateAfterMs;
  @override
  final FontMetadataPolicyDtoNegativeCacheMsEnum negativeCacheMs;
  @override
  final FontMetadataPolicyDtoReservationBytesEnum reservationBytes;
  @override
  final bool revalidateOnForeground;
  @override
  final bool revalidateOnPickerOpen;
  @override
  final bool coalesceUnknownVersions;

  factory _$FontMetadataPolicyDto([
    void Function(FontMetadataPolicyDtoBuilder)? updates,
  ]) => (FontMetadataPolicyDtoBuilder()..update(updates))._build();

  _$FontMetadataPolicyDto._({
    required this.revalidateAfterMs,
    required this.negativeCacheMs,
    required this.reservationBytes,
    required this.revalidateOnForeground,
    required this.revalidateOnPickerOpen,
    required this.coalesceUnknownVersions,
  }) : super._();
  @override
  FontMetadataPolicyDto rebuild(
    void Function(FontMetadataPolicyDtoBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FontMetadataPolicyDtoBuilder toBuilder() =>
      FontMetadataPolicyDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FontMetadataPolicyDto &&
        revalidateAfterMs == other.revalidateAfterMs &&
        negativeCacheMs == other.negativeCacheMs &&
        reservationBytes == other.reservationBytes &&
        revalidateOnForeground == other.revalidateOnForeground &&
        revalidateOnPickerOpen == other.revalidateOnPickerOpen &&
        coalesceUnknownVersions == other.coalesceUnknownVersions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, revalidateAfterMs.hashCode);
    _$hash = $jc(_$hash, negativeCacheMs.hashCode);
    _$hash = $jc(_$hash, reservationBytes.hashCode);
    _$hash = $jc(_$hash, revalidateOnForeground.hashCode);
    _$hash = $jc(_$hash, revalidateOnPickerOpen.hashCode);
    _$hash = $jc(_$hash, coalesceUnknownVersions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FontMetadataPolicyDto')
          ..add('revalidateAfterMs', revalidateAfterMs)
          ..add('negativeCacheMs', negativeCacheMs)
          ..add('reservationBytes', reservationBytes)
          ..add('revalidateOnForeground', revalidateOnForeground)
          ..add('revalidateOnPickerOpen', revalidateOnPickerOpen)
          ..add('coalesceUnknownVersions', coalesceUnknownVersions))
        .toString();
  }
}

class FontMetadataPolicyDtoBuilder
    implements Builder<FontMetadataPolicyDto, FontMetadataPolicyDtoBuilder> {
  _$FontMetadataPolicyDto? _$v;

  FontMetadataPolicyDtoRevalidateAfterMsEnum? _revalidateAfterMs;
  FontMetadataPolicyDtoRevalidateAfterMsEnum? get revalidateAfterMs =>
      _$this._revalidateAfterMs;
  set revalidateAfterMs(
    FontMetadataPolicyDtoRevalidateAfterMsEnum? revalidateAfterMs,
  ) => _$this._revalidateAfterMs = revalidateAfterMs;

  FontMetadataPolicyDtoNegativeCacheMsEnum? _negativeCacheMs;
  FontMetadataPolicyDtoNegativeCacheMsEnum? get negativeCacheMs =>
      _$this._negativeCacheMs;
  set negativeCacheMs(
    FontMetadataPolicyDtoNegativeCacheMsEnum? negativeCacheMs,
  ) => _$this._negativeCacheMs = negativeCacheMs;

  FontMetadataPolicyDtoReservationBytesEnum? _reservationBytes;
  FontMetadataPolicyDtoReservationBytesEnum? get reservationBytes =>
      _$this._reservationBytes;
  set reservationBytes(
    FontMetadataPolicyDtoReservationBytesEnum? reservationBytes,
  ) => _$this._reservationBytes = reservationBytes;

  bool? _revalidateOnForeground;
  bool? get revalidateOnForeground => _$this._revalidateOnForeground;
  set revalidateOnForeground(bool? revalidateOnForeground) =>
      _$this._revalidateOnForeground = revalidateOnForeground;

  bool? _revalidateOnPickerOpen;
  bool? get revalidateOnPickerOpen => _$this._revalidateOnPickerOpen;
  set revalidateOnPickerOpen(bool? revalidateOnPickerOpen) =>
      _$this._revalidateOnPickerOpen = revalidateOnPickerOpen;

  bool? _coalesceUnknownVersions;
  bool? get coalesceUnknownVersions => _$this._coalesceUnknownVersions;
  set coalesceUnknownVersions(bool? coalesceUnknownVersions) =>
      _$this._coalesceUnknownVersions = coalesceUnknownVersions;

  FontMetadataPolicyDtoBuilder() {
    FontMetadataPolicyDto._defaults(this);
  }

  FontMetadataPolicyDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _revalidateAfterMs = $v.revalidateAfterMs;
      _negativeCacheMs = $v.negativeCacheMs;
      _reservationBytes = $v.reservationBytes;
      _revalidateOnForeground = $v.revalidateOnForeground;
      _revalidateOnPickerOpen = $v.revalidateOnPickerOpen;
      _coalesceUnknownVersions = $v.coalesceUnknownVersions;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FontMetadataPolicyDto other) {
    _$v = other as _$FontMetadataPolicyDto;
  }

  @override
  void update(void Function(FontMetadataPolicyDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FontMetadataPolicyDto build() => _build();

  _$FontMetadataPolicyDto _build() {
    final _$result =
        _$v ??
        _$FontMetadataPolicyDto._(
          revalidateAfterMs: BuiltValueNullFieldError.checkNotNull(
            revalidateAfterMs,
            r'FontMetadataPolicyDto',
            'revalidateAfterMs',
          ),
          negativeCacheMs: BuiltValueNullFieldError.checkNotNull(
            negativeCacheMs,
            r'FontMetadataPolicyDto',
            'negativeCacheMs',
          ),
          reservationBytes: BuiltValueNullFieldError.checkNotNull(
            reservationBytes,
            r'FontMetadataPolicyDto',
            'reservationBytes',
          ),
          revalidateOnForeground: BuiltValueNullFieldError.checkNotNull(
            revalidateOnForeground,
            r'FontMetadataPolicyDto',
            'revalidateOnForeground',
          ),
          revalidateOnPickerOpen: BuiltValueNullFieldError.checkNotNull(
            revalidateOnPickerOpen,
            r'FontMetadataPolicyDto',
            'revalidateOnPickerOpen',
          ),
          coalesceUnknownVersions: BuiltValueNullFieldError.checkNotNull(
            coalesceUnknownVersions,
            r'FontMetadataPolicyDto',
            'coalesceUnknownVersions',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';

ProfileCoverModel? mapProfileCover(ProfileCoverResponseDto? dto) {
  if (dto == null) return null;
  final web = _mapVariant(
    url: dto.url,
    mediumUrl: dto.mediumUrl,
    width: dto.width,
    height: dto.height,
  );
  if (web == null) return null;
  final mobileDto = dto.mobile;
  final mobile = mobileDto == null
      ? null
      : _mapVariant(
          url: mobileDto.url,
          mediumUrl: mobileDto.mediumUrl,
          width: mobileDto.width,
          height: mobileDto.height,
        );
  return ProfileCoverModel(web: web, mobile: mobile);
}

ProfileCoverVariant? _mapVariant({
  required String url,
  required String? mediumUrl,
  required num? width,
  required num? height,
}) {
  final safeOriginal = _safeHttpUrl(url);
  if (safeOriginal == null) return null;
  final safeMedium = _safeHttpUrl(mediumUrl);
  return ProfileCoverVariant(
    url: safeMedium ?? safeOriginal,
    width: _positiveInt(width),
    height: _positiveInt(height),
  );
}

String? _safeHttpUrl(String? value) {
  if (value == null) return null;
  final uri = Uri.tryParse(value);
  if (uri == null ||
      !uri.hasScheme ||
      (uri.scheme != 'https' && uri.scheme != 'http')) {
    return null;
  }
  return value;
}

int? _positiveInt(num? value) {
  if (value == null || !value.isFinite || value <= 0 || value % 1 != 0) {
    return null;
  }
  return value.toInt();
}

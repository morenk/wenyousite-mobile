import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_upload_policy.dart';

Map<String, MediaAudio> mapMediaAudios(Iterable<AudioMediaDto>? values) =>
    mediaAudiosFromJson([
      for (final value in values ?? const <AudioMediaDto>[])
        {
          'sourceUrl': value.sourceUrl,
          'mediaId': value.mediaId,
          'contentType':
              value.contentType == AudioMediaDtoContentTypeEnum.audioSlashMpeg
              ? 'audio/mpeg'
              : null,
          'size': value.size,
          'durationMs': value.durationMs,
        },
    ]);

AudioUploadPolicy? mapAudioUploadPolicy(AudioUploadCapabilityDto? value) =>
    value == null
    ? null
    : AudioUploadPolicy.parse({
        'version': value.version == AudioUploadCapabilityDtoVersionEnum.n1
            ? 1
            : null,
        'maxBytes': value.maxBytes,
        'maxDurationMs': value.maxDurationMs,
        'contentTypes': [
          for (final type in value.contentTypes)
            switch (type) {
              AudioUploadCapabilityDtoContentTypesEnum.audioSlashMpeg =>
                'audio/mpeg',
              AudioUploadCapabilityDtoContentTypesEnum.audioSlashMp4 =>
                'audio/mp4',
              AudioUploadCapabilityDtoContentTypesEnum.audioSlashWav =>
                'audio/wav',
              AudioUploadCapabilityDtoContentTypesEnum.audioSlashOgg =>
                'audio/ogg',
              AudioUploadCapabilityDtoContentTypesEnum.audioSlashFlac =>
                'audio/flac',
              _ => null,
            },
        ],
        'outputContentType':
            value.outputContentType ==
                AudioUploadCapabilityDtoOutputContentTypeEnum.audioSlashMpeg
            ? 'audio/mpeg'
            : null,
      });

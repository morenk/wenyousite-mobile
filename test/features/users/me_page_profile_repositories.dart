import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_repository_ports.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/users/application/user_repository_ports.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';
import 'package:wenyousite_mobile/features/wallet/application/wallet_repository_ports.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'me_page_session_fixtures.dart';

Future<ProviderContainer> mePageTestAuthenticatedContainer(
  MeProfileRepository repository, {
  AvatarImagePicker? avatarPicker,
  ProfileCoverImagePicker? profileCoverPicker,
  ProfileCoverRepository? profileCoverRepository,
  ImageCropProcessor? imageCropProcessor,
  MediaUploadGateway? mediaRepository,
  AvatarRepository? avatarRepository,
  PublicUserRepository? publicUserRepository,
  WalletRepository? walletRepository,
  MomentRepository? momentRepository,
  bool stickersEnabled = false,
}) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(MePageTestMemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(MePageTestFakeSessionRemote()),
      stickersEnabledProvider.overrideWithValue(stickersEnabled),
      meProfileRepositoryProvider.overrideWithValue(repository),
      publicUserRepositoryProvider.overrideWithValue(
        publicUserRepository ?? MePageTestFakePublicUserRepository(),
      ),
      walletRepositoryProvider.overrideWithValue(
        walletRepository ?? MePageTestFakeWalletRepository(),
      ),
      if (momentRepository != null)
        momentRepositoryProvider.overrideWithValue(momentRepository),
      avatarImagePickerPortProvider.overrideWithValue(
        avatarPicker ?? MePageTestFakeAvatarPicker(null),
      ),
      profileCoverImagePickerPortProvider.overrideWithValue(
        profileCoverPicker ?? const MePageTestFakeProfileCoverPicker(null),
      ),
      profileCoverRepositoryProvider.overrideWithValue(
        profileCoverRepository ?? MePageTestFakeProfileCoverRepository(),
      ),
      imageCropProcessorPortProvider.overrideWithValue(
        imageCropProcessor ?? MePageTestFakeImageCropProcessor(),
      ),
      mediaUploadGatewayPortProvider.overrideWithValue(
        mediaRepository ?? MePageTestFakeMediaRepository(),
      ),
      if (avatarRepository != null)
        avatarRepositoryProvider.overrideWithValue(avatarRepository),
    ],
  );
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(mePageTestTokens);
  return container;
}

class MePageTestFakeProfileCoverPicker implements ProfileCoverImagePicker {
  const MePageTestFakeProfileCoverPicker(this.input, {this.failure});

  final MediaUploadInput? input;
  final Object? failure;

  @override
  Future<MediaUploadInput?> pickProfileCoverFromGallery() async {
    if (failure case final error?) throw error;
    return input;
  }
}

class MePageTestDeferredProfileCoverPicker implements ProfileCoverImagePicker {
  final mePageTestSelection = Completer<MediaUploadInput?>();

  void complete(MediaUploadInput? input) => mePageTestSelection.complete(input);

  @override
  Future<MediaUploadInput?> pickProfileCoverFromGallery() =>
      mePageTestSelection.future;
}

class MePageTestDeferredAvatarPicker implements AvatarImagePicker {
  final mePageTestSelection = Completer<MediaUploadInput?>();

  void complete(MediaUploadInput? input) => mePageTestSelection.complete(input);

  @override
  Future<MediaUploadInput?> pickAvatarFromGallery() =>
      mePageTestSelection.future;
}

class MePageTestFakeProfileCoverRepository implements ProfileCoverRepository {
  int setCalls = 0;
  int removeCalls = 0;

  @override
  Future<ProfileCoverUpdateResult> removeProfileCover() async {
    removeCalls += 1;
    return ProfileCoverUpdateResult(
      profileCover: null,
      updatedAt: DateTime.utc(2026, 8, 16),
    );
  }

  @override
  Future<ProfileCoverUpdateResult> setProfileCover({
    required String webMediaId,
    required String mobileMediaId,
  }) async {
    setCalls += 1;
    return ProfileCoverUpdateResult(
      profileCover: const ProfileCoverModel(
        web: ProfileCoverVariant(url: 'https://cdn.example.com/cover-web.webp'),
        mobile: ProfileCoverVariant(
          url: 'https://cdn.example.com/cover-mobile.webp',
        ),
      ),
      updatedAt: DateTime.utc(2026, 8, 16),
    );
  }
}

class MePageTestFakeImageCropProcessor implements ImageCropProcessor {
  int coverCropCalls = 0;
  NormalizedCropRect? lastWebCrop;
  NormalizedCropRect? lastMobileCrop;

  @override
  Future<CropImageSource> prepare(MediaUploadInput input) async {
    return CropImageSource(
      original: input,
      previewBytes: mePageTestPreviewBytes,
      width: 160,
      height: 90,
    );
  }

  @override
  Future<MediaUploadInput> cropAvatar(
    CropImageSource source,
    NormalizedCropRect crop,
  ) async => mePageTestCroppedPreviewInput;

  @override
  Future<MediaUploadInput> cropImage(
    CropImageSource source,
    NormalizedCropRect crop,
  ) async => source.original;

  @override
  Future<ProfileCoverImageSelection> cropProfileCover(
    CropImageSource source, {
    required NormalizedCropRect webCrop,
    required NormalizedCropRect mobileCrop,
  }) async {
    coverCropCalls += 1;
    lastWebCrop = webCrop;
    lastMobileCrop = mobileCrop;
    return ProfileCoverImageSelection(
      web: mePageTestCroppedPreviewInput,
      mobile: mePageTestCroppedPreviewInput,
    );
  }
}

class MePageTestFakeAvatarPicker implements AvatarImagePicker {
  MePageTestFakeAvatarPicker(this.input, {this.failure});

  final MediaUploadInput? input;
  final Object? failure;

  @override
  Future<MediaUploadInput?> pickAvatarFromGallery() async {
    if (failure case final error?) throw error;
    return input;
  }
}

class MePageTestFakeMediaRepository implements MediaUploadGateway {
  int uploadCalls = 0;

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    uploadCalls += 1;
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length,
        totalBytes: input.bytes.length,
      ),
    );
    return MePageTestImmediateUploadOperation(
      const UploadedEditorImage(
        mediaId: 'media-avatar-1',
        url: 'https://cdn.example.com/avatar.webp',
      ),
    );
  }
}

class MePageTestDeferredMediaGateway implements MediaUploadGateway {
  final operations = <Completer<UploadedEditorImage>>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    final completion = Completer<UploadedEditorImage>();
    operations.add(completion);
    return MePageTestFutureUploadOperation(completion.future);
  }

  void complete(int index) {
    operations[index].complete(
      UploadedEditorImage(
        mediaId: 'media-preview-${index + 1}',
        url: 'https://cdn.example.com/preview-${index + 1}.webp',
      ),
    );
  }
}

class MePageTestFailingProfileCoverUploadGateway implements MediaUploadGateway {
  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    return MePageTestFutureUploadOperation(
      Future.error(
        const ApiFailure(
          userMessage: '背景图上传失败，请重试。',
          requestId: 'cover-upload-request',
          source: FailureSource.content,
          reason: FailureReason.contractViolation,
          diagnosticCode: 'media.cover.fixture.rejected',
        ),
      ),
    );
  }
}

class MePageTestFutureUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  MePageTestFutureUploadOperation(this.result);

  @override
  final Future<UploadedEditorImage> result;

  @override
  void cancel() {}
}

class MePageTestImmediateUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  MePageTestImmediateUploadOperation(UploadedEditorImage value)
    : result = Future.value(value);

  @override
  final Future<UploadedEditorImage> result;

  @override
  void cancel() {}
}

class MePageTestFakeAvatarRepository implements AvatarRepository {
  MePageTestFakeAvatarRepository({this.onSet});

  final Future<AvatarUpdateResult> Function(String mediaId)? onSet;
  int setCalls = 0;
  int removeCalls = 0;
  String? lastMediaId;

  @override
  Future<AvatarUpdateResult> setAvatar(String mediaId) async {
    setCalls += 1;
    lastMediaId = mediaId;
    return onSet?.call(mediaId) ?? mePageTestAvatarSetResult;
  }

  @override
  Future<AvatarUpdateResult> removeAvatar() async {
    removeCalls += 1;
    return mePageTestAvatarRemoveResult;
  }
}

class MePageTestFakeMeProfileRepository implements MeProfileRepository {
  MePageTestFakeMeProfileRepository({
    this.failFetchOnce = false,
    MeProfileModel? initialProfile,
  }) : profile = initialProfile ?? mePageTestProfile;

  bool failFetchOnce;
  int fetchCalls = 0;
  int updateCalls = 0;
  MeProfilePatch? lastPatch;
  MeProfileModel profile;
  Completer<MeProfileModel>? mePageTestNextFetch;

  void deferNextFetch(Completer<MeProfileModel> result) {
    mePageTestNextFetch = result;
  }

  @override
  Future<MeProfileModel> fetchMe() async {
    fetchCalls += 1;
    final nextFetch = mePageTestNextFetch;
    if (nextFetch != null) {
      mePageTestNextFetch = null;
      return nextFetch.future;
    }
    if (failFetchOnce) {
      failFetchOnce = false;
      throw const ApiFailure(
        userMessage: '暂时无法连接温油站，请检查网络。',
        requestId: 'me-request-id',
      );
    }
    return profile;
  }

  @override
  Future<MeProfileUpdateResult> updateMe(MeProfilePatch patch) async {
    updateCalls += 1;
    lastPatch = patch;
    final result = MeProfileUpdateResult(
      email: profile.email,
      username: patch.username ?? profile.username,
      avatarUrl: profile.avatarUrl,
      bio: patch.bio ?? profile.bio,
      level: profile.level,
      experience: profile.experience,
      currentLevelExperience: profile.currentLevelExperience,
      nextLevelExperience: profile.nextLevelExperience,
      receivedTipTotal: profile.receivedTipTotal,
      receivedTipCount: profile.receivedTipCount,
      showRecentReplies: patch.showRecentReplies ?? profile.showRecentReplies,
      showPlayedThreads: patch.showPlayedThreads ?? profile.showPlayedThreads,
      showBookmarks: patch.showBookmarks ?? profile.showBookmarks,
      updatedAt: profile.updatedAt.add(const Duration(minutes: 1)),
    );
    profile = profile.apply(result);
    return result;
  }
}

class MePageTestFakePublicUserRepository implements PublicUserRepository {
  int fetchUserCalls = 0;
  int activityCalls = 0;
  int createdCalls = 0;
  int playedCalls = 0;
  int replyCalls = 0;

  @override
  Future<PublicUserActivitySummary> fetchActivitySummary(String userId) async {
    activityCalls += 1;
    return const PublicUserActivitySummary(
      momentCount: 7,
      createdThreadCount: 3,
      playedThreadCount: 2,
      replyCount: 18,
    );
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchBookmarks(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async => const CursorPage(items: [], hasMore: false);

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchCreatedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async {
    createdCalls += 1;
    return CursorPage(
      items: [
        PublicUserThreadModel(
          id: 'thread-mine',
          title: '我创建的星海主题',
          status: PublicUserThreadStatus.recruiting,
          isPrivate: false,
          ownerName: mePageTestProfile.username,
          ownerLevel: mePageTestProfile.level,
          createdAt: DateTime.utc(2026, 8, 15),
          memberCount: 3,
          postCount: 8,
        ),
      ],
      hasMore: false,
    );
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchPlayedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) async {
    playedCalls += 1;
    return const CursorPage(items: [], hasMore: false);
  }

  @override
  Future<List<PublicUserReplyModel>> fetchRecentReplies(String userId) async {
    replyCalls += 1;
    return const [];
  }

  @override
  Future<PublicUserProfileModel> fetchUser(String userId) {
    fetchUserCalls += 1;
    throw UnimplementedError();
  }
}

class MePageTestFakeWalletRepository implements WalletRepository {
  MePageTestFakeWalletRepository({this.balance = '41'});

  final String balance;
  int walletCalls = 0;

  @override
  Future<WalletSummary> fetchWallet() async {
    walletCalls += 1;
    return WalletSummary(
      balance: balance,
      receivedTipTotal: '18',
      receivedTipCount: 6,
    );
  }

  @override
  Future<CursorPage<WalletTransaction>> fetchTransactions({
    String? cursor,
    int limit = 20,
  }) async => const CursorPage(items: [], hasMore: false);

  @override
  Future<DailyCheckInResult> checkIn() => throw UnimplementedError();

  @override
  Future<TipResult> tip(
    TipTarget target, {
    required String amount,
    required String clientRequestId,
  }) => throw UnimplementedError();
}

class MePageTestFakeProfileMomentRepository extends Fake
    implements MomentRepository {
  int userCalls = 0;

  @override
  Future<CursorPage<MomentCard>> fetchUserMoments({
    required String userId,
    String? cursor,
    int limit = 20,
  }) async {
    userCalls += 1;
    return CursorPage(
      items: [
        for (var index = 0; index < 40; index++)
          mePageTestProfileMomentCard(index),
      ],
      hasMore: false,
    );
  }
}

MomentCard mePageTestProfileMomentCard(int index) {
  final timestamp = DateTime.utc(2026, 8, 20, 12);
  return MomentCard(
    id: 'profile-moment-$index',
    author: const MomentAuthor(id: 'user-1', username: '温柔测试员', level: 4),
    title: '动态 $index',
    contentExcerpt: '用于验证个人主页联动滚动的动态内容。',
    coverType: MomentCoverType.text,
    textCoverTheme: MomentTextCoverTheme.mint,
    imageCount: 0,
    likeCount: 0,
    commentCount: 0,
    bookmarkCount: 0,
    tipTotal: '0',
    viewerLiked: false,
    viewerBookmarked: false,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

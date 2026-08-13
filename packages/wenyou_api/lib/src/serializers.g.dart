// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers =
    (Serializers().toBuilder()
          ..add($ApiPaginatedSuccessEnvelope.serializer)
          ..add($ApiSuccessEnvelope.serializer)
          ..add(AddThreadTagDto.serializer)
          ..add(AdminAccountReasonDto.serializer)
          ..add(AdminAccountsCancel200Response.serializer)
          ..add(AdminAccountsInvite201Response.serializer)
          ..add(AdminAccountsList200Response.serializer)
          ..add(AdminAccountsResponseDto.serializer)
          ..add(AdminAccountsRevoke200Response.serializer)
          ..add(AdminAccountsTransfer201Response.serializer)
          ..add(AdminAuditActorResponseDto.serializer)
          ..add(AdminAuditActorResponseDtoRoleEnum.serializer)
          ..add(AdminAuditLogResponseDto.serializer)
          ..add(AdminAuditLogResponseDtoActionEnum.serializer)
          ..add(AdminAuditLogResponseDtoTargetTypeEnum.serializer)
          ..add(AdminAuthChallenge200Response.serializer)
          ..add(AdminAuthLogout200Response.serializer)
          ..add(AdminAuthSession200Response.serializer)
          ..add(AdminAuthStepUpChallenge200Response.serializer)
          ..add(AdminAuthVerify200Response.serializer)
          ..add(AdminAuthVerifyStepUp200Response.serializer)
          ..add(AdminCapabilityResponseDto.serializer)
          ..add(AdminCapabilityResponseDtoRoleEnum.serializer)
          ..add(AdminChallengeResponseDto.serializer)
          ..add(AdminChallengeVerifyDto.serializer)
          ..add(AdminContentModerationResponseDto.serializer)
          ..add(AdminContentModerationResponseDtoTargetTypeEnum.serializer)
          ..add(AdminDashboardActivityMetricsDto.serializer)
          ..add(AdminDashboardDistributionItemDto.serializer)
          ..add(AdminDashboardDistributions200Response.serializer)
          ..add(AdminDashboardDistributionsResponseDto.serializer)
          ..add(AdminDashboardOverview200Response.serializer)
          ..add(AdminDashboardOverviewResponseDto.serializer)
          ..add(AdminDashboardPeriodMetricsDto.serializer)
          ..add(AdminDashboardRangeResponseDto.serializer)
          ..add(AdminDashboardSnapshotDto.serializer)
          ..add(AdminDashboardTimeseries200Response.serializer)
          ..add(AdminDashboardTimeseriesPointDto.serializer)
          ..add(AdminDashboardTimeseriesResponseDto.serializer)
          ..add(AdminGetHistory200Response.serializer)
          ..add(AdminIndex200Response.serializer)
          ..add(AdminInviteAcceptanceAccept201Response.serializer)
          ..add(AdminInviteCreatedResponseDto.serializer)
          ..add(AdminLoginChallengeDto.serializer)
          ..add(AdminModerationAppealsList200Response.serializer)
          ..add(AdminModerationAppealsResolve201Response.serializer)
          ..add(AdminModerationGetUser200Response.serializer)
          ..add(AdminModerationHideContent200Response.serializer)
          ..add(AdminModerationListAuditLogs200Response.serializer)
          ..add(AdminModerationListUsers200Response.serializer)
          ..add(AdminModerationRestoreContent200Response.serializer)
          ..add(AdminModerationRevokeSanction200Response.serializer)
          ..add(AdminModerationSanctionUser201Response.serializer)
          ..add(AdminModerationUpdateRole200Response.serializer)
          ..add(AdminNotificationUserResponseDto.serializer)
          ..add(AdminPreviewRecipients201Response.serializer)
          ..add(AdminRecipientCountResponseDto.serializer)
          ..add(AdminReportResponseDto.serializer)
          ..add(AdminReportResponseDtoReasonCodeEnum.serializer)
          ..add(AdminReportResponseDtoStatusEnum.serializer)
          ..add(AdminReportResponseDtoTargetTypeEnum.serializer)
          ..add(AdminReportsFindAll200Response.serializer)
          ..add(AdminReportsFindOne200Response.serializer)
          ..add(AdminReportsResolve200Response.serializer)
          ..add(AdminSearchUsers200Response.serializer)
          ..add(AdminSendSystemNotification201Response.serializer)
          ..add(AdminSessionResponseDto.serializer)
          ..add(AdminStepUpResponseDto.serializer)
          ..add(AdminSystemNotificationHistoryItemDto.serializer)
          ..add(AdminSystemNotificationHistoryResponseDto.serializer)
          ..add(AdminTaxonomyCreateCategory201Response.serializer)
          ..add(AdminTaxonomyCreateTag201Response.serializer)
          ..add(AdminTaxonomyListCategories200Response.serializer)
          ..add(AdminTaxonomyListTags200Response.serializer)
          ..add(AdminTaxonomyUpdateCategory200Response.serializer)
          ..add(AdminTaxonomyUpdateTag200Response.serializer)
          ..add(AdminUserModerationResponseDto.serializer)
          ..add(AdminUserModerationResponseDtoModerationStatusEnum.serializer)
          ..add(AdminUserModerationResponseDtoRoleEnum.serializer)
          ..add(AdminUserSanctionResponseDto.serializer)
          ..add(AdminUserSanctionResponseDtoTypeEnum.serializer)
          ..add(AdminUserSearchItemDto.serializer)
          ..add(AdminUserSearchItemDtoRoleEnum.serializer)
          ..add(AdminUserSearchResponseDto.serializer)
          ..add(ApiCapabilitiesResponseDto.serializer)
          ..add(ApiErrorEnvelope.serializer)
          ..add(ApiMetaResponseDto.serializer)
          ..add(ApiPaginationMeta.serializer)
          ..add(ApiSuccessEnvelopeCodeEnum.serializer)
          ..add(AppealAccessTokenResponseDto.serializer)
          ..add(AuthChangePassword200Response.serializer)
          ..add(AuthForgotPassword200Response.serializer)
          ..add(AuthListSessions200Response.serializer)
          ..add(AuthLogin200Response.serializer)
          ..add(AuthLogout200Response.serializer)
          ..add(AuthRefresh200Response.serializer)
          ..add(AuthRequestChangeEmailCode200Response.serializer)
          ..add(AuthRequestCode200Response.serializer)
          ..add(AuthResendVerification200Response.serializer)
          ..add(AuthResetPassword200Response.serializer)
          ..add(AuthResponseDto.serializer)
          ..add(AuthRevokeSession200Response.serializer)
          ..add(AuthVerifyAndComplete200Response.serializer)
          ..add(AuthVerifyChangeEmail200Response.serializer)
          ..add(AuthVerifyEmail200Response.serializer)
          ..add(BlockedUserRecordResponseDto.serializer)
          ..add(BookmarkFolderResponseDto.serializer)
          ..add(BookmarkResponseDto.serializer)
          ..add(BookmarkThreadCountResponseDto.serializer)
          ..add(BookmarkThreadResponseDto.serializer)
          ..add(BookmarkThreadResponseDtoStatusEnum.serializer)
          ..add(BookmarkThreadResponseDtoVisibilityEnum.serializer)
          ..add(BookmarksCreate201Response.serializer)
          ..add(BookmarksCreateFolder201Response.serializer)
          ..add(BookmarksFindAll200Response.serializer)
          ..add(BookmarksFindFolders200Response.serializer)
          ..add(BookmarksMove200Response.serializer)
          ..add(BookmarksRemove200Response.serializer)
          ..add(BusinessErrorCode.serializer)
          ..add(ChangeEmailRequestDto.serializer)
          ..add(ChangeEmailVerifyDto.serializer)
          ..add(ChangePasswordDto.serializer)
          ..add(ConfirmUploadDto.serializer)
          ..add(ConfirmUploadResponseDto.serializer)
          ..add(CreateAdminInviteDto.serializer)
          ..add(CreateBookmarkDto.serializer)
          ..add(CreateBookmarkFolderDto.serializer)
          ..add(CreateDirectConversationDto.serializer)
          ..add(CreateDirectMessageDto.serializer)
          ..add(CreateDraftDto.serializer)
          ..add(CreateManagedTagDto.serializer)
          ..add(CreateModerationAppealDto.serializer)
          ..add(CreateMomentCommentDto.serializer)
          ..add(CreateMomentDto.serializer)
          ..add(CreateNotificationCampaignDto.serializer)
          ..add(CreateNotificationCampaignDtoDestinationTypeEnum.serializer)
          ..add(CreatePostDto.serializer)
          ..add(CreateReportDto.serializer)
          ..add(CreateReportDtoReasonCodeEnum.serializer)
          ..add(CreateReportDtoTargetTypeEnum.serializer)
          ..add(CreateSubscriptionDto.serializer)
          ..add(CreateSubscriptionDtoTypeEnum.serializer)
          ..add(CreateSubthreadDto.serializer)
          ..add(CreateSubthreadDtoPostingPolicyEnum.serializer)
          ..add(CreateTagDto.serializer)
          ..add(CreateThreadCategoryDto.serializer)
          ..add(CreateThreadDto.serializer)
          ..add(CreateThreadDtoVisibilityEnum.serializer)
          ..add(CreateUploadUrlDto.serializer)
          ..add(CreateUploadUrlDtoContentTypeEnum.serializer)
          ..add(CurrentThreadMembershipResponseDto.serializer)
          ..add(CurrentThreadMembershipResponseDtoRoleEnum.serializer)
          ..add(CurrentUserResponseDto.serializer)
          ..add(CurrentUserResponseDtoRoleEnum.serializer)
          ..add(DailyCheckInResponseDto.serializer)
          ..add(DailyCheckInResponseDtoRewardAmountEnum.serializer)
          ..add(DeleteDraftResponseDto.serializer)
          ..add(DiceRollResponseDto.serializer)
          ..add(DirectConversationLookupResponseDto.serializer)
          ..add(DirectConversationLookupResponseDtoContactStateEnum.serializer)
          ..add(DirectConversationResponseDto.serializer)
          ..add(DirectConversationResponseDtoRequestDirectionEnum.serializer)
          ..add(DirectConversationResponseDtoStatusEnum.serializer)
          ..add(DirectConversationStartResponseDto.serializer)
          ..add(DirectConversationsArchive200Response.serializer)
          ..add(DirectConversationsCreate201Response.serializer)
          ..add(DirectConversationsFindAll200Response.serializer)
          ..add(DirectConversationsFindById200Response.serializer)
          ..add(DirectConversationsFindByUser200Response.serializer)
          ..add(DirectConversationsHandleRequest200Response.serializer)
          ..add(DirectConversationsMarkRead200Response.serializer)
          ..add(DirectConversationsMessages200Response.serializer)
          ..add(DirectConversationsSend201Response.serializer)
          ..add(DirectConversationsUnread200Response.serializer)
          ..add(DirectMessageMediaResponseDto.serializer)
          ..add(DirectMessagePreviewResponseDto.serializer)
          ..add(DirectMessageRecallResponseDto.serializer)
          ..add(DirectMessageResponseDto.serializer)
          ..add(DirectMessageStickerResponseDto.serializer)
          ..add(DirectMessageUserResponseDto.serializer)
          ..add(DirectMessagesRecall200Response.serializer)
          ..add(DirectUnreadCountResponseDto.serializer)
          ..add(DraftDefaultSubthreadResponseDto.serializer)
          ..add(DraftResponseDto.serializer)
          ..add(DraftSlotUsageResponseDto.serializer)
          ..add(DraftThreadCountResponseDto.serializer)
          ..add(DraftThreadResponseDto.serializer)
          ..add(DraftThreadResponseDtoStatusEnum.serializer)
          ..add(DraftThreadResponseDtoVisibilityEnum.serializer)
          ..add(DraftsCreate201Response.serializer)
          ..add(DraftsFindAll200Response.serializer)
          ..add(DraftsFindById200Response.serializer)
          ..add(DraftsRemove200Response.serializer)
          ..add(DraftsSlotUsage200Response.serializer)
          ..add(DraftsUpdate200Response.serializer)
          ..add(EconomyCheckIn200Response.serializer)
          ..add(EconomyGetWallet200Response.serializer)
          ..add(EconomyTipMoment201Response.serializer)
          ..add(EconomyTipThread201Response.serializer)
          ..add(EconomyTipUser201Response.serializer)
          ..add(EconomyTransactions200Response.serializer)
          ..add(FloorResponseDto.serializer)
          ..add(FloorResponseDtoKindEnum.serializer)
          ..add(ForgotPasswordDto.serializer)
          ..add(HandleDirectRequestDto.serializer)
          ..add(HandleDirectRequestDtoActionEnum.serializer)
          ..add(HealthCheck200Response.serializer)
          ..add(HealthCheck200ResponseAllOfData.serializer)
          ..add(HomeThreadListItemResponseDto.serializer)
          ..add(HomeThreadListItemResponseDtoStatusEnum.serializer)
          ..add(HomeThreadListItemResponseDtoVisibilityEnum.serializer)
          ..add(ImportStickerDirectMessageDto.serializer)
          ..add(ImportStickerMediaDto.serializer)
          ..add(ImportStickerPostImageDto.serializer)
          ..add(InviteLinkResponseDto.serializer)
          ..add(InviteOwnerResponseDto.serializer)
          ..add(InvitePreviewResponseDto.serializer)
          ..add(InviteThreadPreviewResponseDto.serializer)
          ..add(InviteThreadPreviewResponseDtoStatusEnum.serializer)
          ..add(IssueAppealTokenDto.serializer)
          ..add(JoinedThreadMemberResponseDto.serializer)
          ..add(JoinedThreadMemberResponseDtoRoleEnum.serializer)
          ..add(JoinedThreadReferenceResponseDto.serializer)
          ..add(LoginDto.serializer)
          ..add(LogoutDto.serializer)
          ..add(MarkDirectConversationReadDto.serializer)
          ..add(MediaConfirmUpload200Response.serializer)
          ..add(MediaGetMedia200Response.serializer)
          ..add(MediaGetUploadUrl201Response.serializer)
          ..add(MediaResponseDto.serializer)
          ..add(MediaResponseDtoStatusEnum.serializer)
          ..add(MentionCandidateDto.serializer)
          ..add(MentionCandidateDtoRelationEnum.serializer)
          ..add(MentionCandidatesResponseDto.serializer)
          ..add(MessageResponseDto.serializer)
          ..add(MetaGetMeta200Response.serializer)
          ..add(MobileCompatibilityDto.serializer)
          ..add(MobileDeviceRegister200Response.serializer)
          ..add(MobileDeviceResponseDto.serializer)
          ..add(MobileDeviceResponseDtoPlatformEnum.serializer)
          ..add(MobileDeviceUnregister200Response.serializer)
          ..add(MobilePlatformCompatibilityDto.serializer)
          ..add(ModerateContentDto.serializer)
          ..add(ModerationAppealAppellantResponseDto.serializer)
          ..add(ModerationAppealDecisionResponseDto.serializer)
          ..add(ModerationAppealDecisionResponseDtoActionEnum.serializer)
          ..add(ModerationAppealDecisionResponseDtoPolicyCodeEnum.serializer)
          ..add(ModerationAppealDecisionResponseDtoTargetTypeEnum.serializer)
          ..add(ModerationAppealResponseDto.serializer)
          ..add(ModerationAppealResponseDtoStatusEnum.serializer)
          ..add(ModerationCaseResponseDto.serializer)
          ..add(ModerationCaseResponseDtoStatusEnum.serializer)
          ..add(ModerationCaseResponseDtoTargetTypeEnum.serializer)
          ..add(ModerationCasesGet200Response.serializer)
          ..add(ModerationCasesList200Response.serializer)
          ..add(ModerationCasesResolve201Response.serializer)
          ..add(ModerationDecisionPublicResponseDto.serializer)
          ..add(ModerationDecisionPublicResponseDtoActionEnum.serializer)
          ..add(ModerationDecisionPublicResponseDtoPolicyCodeEnum.serializer)
          ..add(ModerationDecisionPublicResponseDtoTargetTypeEnum.serializer)
          ..add(MomentActionResponseDto.serializer)
          ..add(MomentCardResponseDto.serializer)
          ..add(MomentCardResponseDtoCoverTypeEnum.serializer)
          ..add(MomentCardResponseDtoTextCoverThemeEnum.serializer)
          ..add(MomentCommentResponseDto.serializer)
          ..add(MomentDeleteResponseDto.serializer)
          ..add(MomentDetailResponseDto.serializer)
          ..add(MomentDetailResponseDtoCoverTypeEnum.serializer)
          ..add(MomentDetailResponseDtoTextCoverThemeEnum.serializer)
          ..add(MomentMediaResponseDto.serializer)
          ..add(MomentReplyTargetResponseDto.serializer)
          ..add(MomentRootCommentResponseDto.serializer)
          ..add(MomentSearchResponseDto.serializer)
          ..add(MomentSearchResponseDtoCoverTypeEnum.serializer)
          ..add(MomentSearchResponseDtoTextCoverThemeEnum.serializer)
          ..add(MomentStickerResponseDto.serializer)
          ..add(MomentsBookmark201Response.serializer)
          ..add(MomentsBookmarks200Response.serializer)
          ..add(MomentsCommentAuthors200Response.serializer)
          ..add(MomentsCommentsList200Response.serializer)
          ..add(MomentsCreate201Response.serializer)
          ..add(MomentsCreateComment201Response.serializer)
          ..add(MomentsDetail200Response.serializer)
          ..add(MomentsLike201Response.serializer)
          ..add(MomentsList200Response.serializer)
          ..add(MomentsRemove200Response.serializer)
          ..add(MomentsRemoveComment200Response.serializer)
          ..add(MomentsReplies200Response.serializer)
          ..add(MomentsUnbookmark200Response.serializer)
          ..add(MomentsUnlike200Response.serializer)
          ..add(MomentsUpdate200Response.serializer)
          ..add(MoveBookmarkDto.serializer)
          ..add(NotificationAudienceDto.serializer)
          ..add(NotificationAudienceDtoRolesEnum.serializer)
          ..add(NotificationCampaignCancel200Response.serializer)
          ..add(NotificationCampaignCreate201Response.serializer)
          ..add(NotificationCampaignList200Response.serializer)
          ..add(NotificationCampaignPreview200Response.serializer)
          ..add(NotificationCampaignResponseDto.serializer)
          ..add(NotificationCampaignResponseDtoAudienceRoleEnum.serializer)
          ..add(NotificationCampaignResponseDtoStatusEnum.serializer)
          ..add(NotificationFromUserResponseDto.serializer)
          ..add(NotificationLikerResponseDto.serializer)
          ..add(NotificationMomentCommentResponseDto.serializer)
          ..add(NotificationMomentResponseDto.serializer)
          ..add(NotificationPayloadResponseDto.serializer)
          ..add(NotificationPayloadResponseDtoSchemaVersionEnum.serializer)
          ..add(NotificationPostResponseDto.serializer)
          ..add(NotificationResponseDto.serializer)
          ..add(NotificationResponseDtoTypeEnum.serializer)
          ..add(NotificationTargetResponseDto.serializer)
          ..add(NotificationTargetResponseDtoKindEnum.serializer)
          ..add(NotificationThreadResponseDto.serializer)
          ..add(NotificationsFindAll200Response.serializer)
          ..add(NotificationsMarkAllAsRead200Response.serializer)
          ..add(NotificationsRemove200Response.serializer)
          ..add(NotificationsSetReadStatus200Response.serializer)
          ..add(NotificationsUnreadCount200Response.serializer)
          ..add(OwnBookmarkThreadResponseDto.serializer)
          ..add(OwnBookmarkThreadResponseDtoStatusEnum.serializer)
          ..add(OwnBookmarkThreadResponseDtoVisibilityEnum.serializer)
          ..add(ParentPostResponseDto.serializer)
          ..add(PostAuthorResponseDto.serializer)
          ..add(PostCountResponseDto.serializer)
          ..add(PostDetailResponseDto.serializer)
          ..add(PostDetailResponseDtoKindEnum.serializer)
          ..add(PostResponseDto.serializer)
          ..add(PostResponseDtoKindEnum.serializer)
          ..add(PostSubthreadResponseDto.serializer)
          ..add(PostThreadResponseDto.serializer)
          ..add(PostsCreate201Response.serializer)
          ..add(PostsFindById200Response.serializer)
          ..add(PostsFindFloors200Response.serializer)
          ..add(PostsFindReplies200Response.serializer)
          ..add(PostsRemove200Response.serializer)
          ..add(PostsUpdate200Response.serializer)
          ..add(PostsUpsertBody200Response.serializer)
          ..add(PrivateUserResponseDto.serializer)
          ..add(PrivateUserResponseDtoRoleEnum.serializer)
          ..add(ProfileCoverResponseDto.serializer)
          ..add(ProgressionResponseDto.serializer)
          ..add(PublicUserResponseDto.serializer)
          ..add(PublicUserResponseDtoAccountStatusEnum.serializer)
          ..add(PublicUserResponseDtoRoleEnum.serializer)
          ..add(RecentReplyDiceResponseDto.serializer)
          ..add(RecentReplyResponseDto.serializer)
          ..add(RecentReplySubthreadResponseDto.serializer)
          ..add(RecentReplyThreadResponseDto.serializer)
          ..add(RefreshDto.serializer)
          ..add(RegisterCodeResponseDto.serializer)
          ..add(RegisterMobileDeviceDto.serializer)
          ..add(RegisterMobileDeviceDtoPlatformEnum.serializer)
          ..add(ReorderStickersDto.serializer)
          ..add(ReorderSubthreadsDto.serializer)
          ..add(ReorderedSubthreadResponseDto.serializer)
          ..add(ReplyResponseDto.serializer)
          ..add(ReplyResponseDtoKindEnum.serializer)
          ..add(ReplyTargetResponseDto.serializer)
          ..add(ReportResponseDto.serializer)
          ..add(ReportResponseDtoReasonCodeEnum.serializer)
          ..add(ReportResponseDtoStatusEnum.serializer)
          ..add(ReportResponseDtoTargetTypeEnum.serializer)
          ..add(ReportUserSummaryDto.serializer)
          ..add(ReportUserSummaryDtoRoleEnum.serializer)
          ..add(ReportsCreate201Response.serializer)
          ..add(RequestCodeDto.serializer)
          ..add(ResendVerificationDto.serializer)
          ..add(ResetPasswordDto.serializer)
          ..add(ResolveModerationAppealDto.serializer)
          ..add(ResolveModerationAppealDtoOutcomeEnum.serializer)
          ..add(ResolveModerationCaseDto.serializer)
          ..add(ResolveModerationCaseDtoActionEnum.serializer)
          ..add(ResolveModerationCaseDtoOutcomeEnum.serializer)
          ..add(ResolveModerationCaseDtoPolicyCodeEnum.serializer)
          ..add(ResolveReportDto.serializer)
          ..add(ResolveReportDtoActionEnum.serializer)
          ..add(ResolveReportDtoOutcomeEnum.serializer)
          ..add(RevokeSanctionDto.serializer)
          ..add(RevokeSessionResponseDto.serializer)
          ..add(SanctionUserDto.serializer)
          ..add(SanctionUserDtoTypeEnum.serializer)
          ..add(SaveThreadAggregateDto.serializer)
          ..add(SaveThreadAggregateDtoStatusEnum.serializer)
          ..add(SaveThreadAggregateDtoVisibilityEnum.serializer)
          ..add(SearchAuthorResponseDto.serializer)
          ..add(SearchPostResponseDto.serializer)
          ..add(SearchResultResponseDto.serializer)
          ..add(SearchSearch200Response.serializer)
          ..add(SearchSearchMoments200Response.serializer)
          ..add(SearchSearchPosts200Response.serializer)
          ..add(SearchSearchThreads200Response.serializer)
          ..add(SearchSearchUsers200Response.serializer)
          ..add(SearchSubthreadReferenceResponseDto.serializer)
          ..add(SearchThreadCountResponseDto.serializer)
          ..add(SearchThreadOwnerResponseDto.serializer)
          ..add(SearchThreadReferenceResponseDto.serializer)
          ..add(SearchThreadResponseDto.serializer)
          ..add(SearchUserResponseDto.serializer)
          ..add(SendSystemNotificationDto.serializer)
          ..add(SessionResponseDto.serializer)
          ..add(SessionResponseDtoPlatformEnum.serializer)
          ..add(SetAvatarDto.serializer)
          ..add(SetDirectConversationArchiveDto.serializer)
          ..add(SetProfileCoverDto.serializer)
          ..add(SetReadStatusDto.serializer)
          ..add(SiteOperationalSettingsGet200Response.serializer)
          ..add(SiteOperationalSettingsResponseDto.serializer)
          ..add(SiteOperationalSettingsUpdate200Response.serializer)
          ..add(StickerAssetResponseDto.serializer)
          ..add(StickerCollectionResponseDto.serializer)
          ..add(StickerImportResponseDto.serializer)
          ..add(StickerImportResponseDtoStatusEnum.serializer)
          ..add(StickersGetCollection200Response.serializer)
          ..add(StickersGetImport200Response.serializer)
          ..add(StickersImportDirectMessage201Response.serializer)
          ..add(StickersImportMedia201Response.serializer)
          ..add(StickersImportPostImage201Response.serializer)
          ..add(StickersRemove200Response.serializer)
          ..add(StickersReorder200Response.serializer)
          ..add(SubscriptionResponseDto.serializer)
          ..add(SubscriptionResponseDtoTypeEnum.serializer)
          ..add(SubscriptionThreadResponseDto.serializer)
          ..add(SubscriptionsCreate201Response.serializer)
          ..add(SubscriptionsFindAll200Response.serializer)
          ..add(SubscriptionsRemove200Response.serializer)
          ..add(SubthreadCountResponseDto.serializer)
          ..add(SubthreadResponseDto.serializer)
          ..add(SubthreadResponseDtoPostingPolicyEnum.serializer)
          ..add(SubthreadThreadReferenceResponseDto.serializer)
          ..add(SubthreadThreadReferenceResponseDtoVisibilityEnum.serializer)
          ..add(SubthreadsCreate201Response.serializer)
          ..add(SubthreadsFindAll200Response.serializer)
          ..add(SubthreadsFindById200Response.serializer)
          ..add(SubthreadsRemove200Response.serializer)
          ..add(SubthreadsReorder200Response.serializer)
          ..add(SubthreadsUpdate200Response.serializer)
          ..add(TagResponseDto.serializer)
          ..add(TagsCreate200Response.serializer)
          ..add(TagsGetById200Response.serializer)
          ..add(TagsSearch200Response.serializer)
          ..add(ThreadBodyPostResponseDto.serializer)
          ..add(ThreadCapabilitiesResponseDto.serializer)
          ..add(ThreadCategoriesList200Response.serializer)
          ..add(ThreadCategoryResponseDto.serializer)
          ..add(ThreadCountResponseDto.serializer)
          ..add(ThreadDetailResponseDto.serializer)
          ..add(ThreadDetailResponseDtoStatusEnum.serializer)
          ..add(ThreadDetailResponseDtoVisibilityEnum.serializer)
          ..add(ThreadLikeResponseDto.serializer)
          ..add(ThreadListCountResponseDto.serializer)
          ..add(ThreadListDefaultSubthreadResponseDto.serializer)
          ..add(ThreadListItemResponseDto.serializer)
          ..add(ThreadListItemResponseDtoStatusEnum.serializer)
          ..add(ThreadListItemResponseDtoVisibilityEnum.serializer)
          ..add(ThreadMemberResponseDto.serializer)
          ..add(ThreadMemberResponseDtoRoleEnum.serializer)
          ..add(ThreadMembersExitMember200Response.serializer)
          ..add(ThreadMembersFindAll200Response.serializer)
          ..add(ThreadMembersJoin201Response.serializer)
          ..add(ThreadMembersUpdateMember200Response.serializer)
          ..add(ThreadMembersUpdateMemberRequest.serializer)
          ..add(ThreadMembersUpdateMemberRequestRoleEnum.serializer)
          ..add(ThreadSearchSearchPosts200Response.serializer)
          ..add(ThreadSubthreadCountResponseDto.serializer)
          ..add(ThreadSubthreadResponseDto.serializer)
          ..add(ThreadSubthreadResponseDtoPostingPolicyEnum.serializer)
          ..add(ThreadTagRelationResponseDto.serializer)
          ..add(ThreadTagResponseDto.serializer)
          ..add(ThreadTagsAdd201Response.serializer)
          ..add(ThreadTagsFindAll200Response.serializer)
          ..add(ThreadTagsRemove200Response.serializer)
          ..add(ThreadsCreate201Response.serializer)
          ..add(ThreadsCreateInviteLink200Response.serializer)
          ..add(ThreadsFindAll200Response.serializer)
          ..add(ThreadsFindById200Response.serializer)
          ..add(ThreadsFindDrafts200Response.serializer)
          ..add(ThreadsJoinByInviteLink200Response.serializer)
          ..add(ThreadsLike201Response.serializer)
          ..add(ThreadsPreviewInviteLink200Response.serializer)
          ..add(ThreadsRemove200Response.serializer)
          ..add(ThreadsSaveAggregate200Response.serializer)
          ..add(ThreadsUnlike200Response.serializer)
          ..add(ThreadsUpdate200Response.serializer)
          ..add(TipRequestDto.serializer)
          ..add(TipResponseDto.serializer)
          ..add(TransferSuperAdminDto.serializer)
          ..add(UnreadNotificationCountResponseDto.serializer)
          ..add(UpdateAdminRoleDto.serializer)
          ..add(UpdateAdminRoleDtoRoleEnum.serializer)
          ..add(UpdateDraftDto.serializer)
          ..add(UpdateManagedTagDto.serializer)
          ..add(UpdateMomentDto.serializer)
          ..add(UpdatePostDto.serializer)
          ..add(UpdateSiteSettingsDto.serializer)
          ..add(UpdateSubthreadDto.serializer)
          ..add(UpdateSubthreadDtoPostingPolicyEnum.serializer)
          ..add(UpdateThreadCategoryDto.serializer)
          ..add(UpdateThreadDto.serializer)
          ..add(UpdateThreadDtoStatusEnum.serializer)
          ..add(UpdateThreadDtoVisibilityEnum.serializer)
          ..add(UpdateUserDto.serializer)
          ..add(UploadUrlResponseDto.serializer)
          ..add(UpsertBodyDto.serializer)
          ..add(UserActivitySummaryResponseDto.serializer)
          ..add(UserConditionDto.serializer)
          ..add(UserConditionDtoRoleEnum.serializer)
          ..add(UserFollowRecordResponseDto.serializer)
          ..add(UserModerationAppealsAppeal201Response.serializer)
          ..add(UserModerationAppealsIssueToken200Response.serializer)
          ..add(UserModerationAppealsMine200Response.serializer)
          ..add(UserMomentsList200Response.serializer)
          ..add(UserProfile.serializer)
          ..add(UserSocialCountResponseDto.serializer)
          ..add(UserStickerResponseDto.serializer)
          ..add(UsersDeleteMe200Response.serializer)
          ..add(UsersFollowBlock200Response.serializer)
          ..add(UsersFollowBlocks200Response.serializer)
          ..add(UsersFollowFollow200Response.serializer)
          ..add(UsersFollowFollowers200Response.serializer)
          ..add(UsersFollowFollowing200Response.serializer)
          ..add(UsersFollowUnblock200Response.serializer)
          ..add(UsersFollowUnfollow200Response.serializer)
          ..add(UsersFollowUserFollowers200Response.serializer)
          ..add(UsersFollowUserFollowing200Response.serializer)
          ..add(UsersGetMe200Response.serializer)
          ..add(UsersGetUser200Response.serializer)
          ..add(UsersGetUserActivitySummary200Response.serializer)
          ..add(UsersGetUserBookmarks200Response.serializer)
          ..add(UsersGetUserCreatedThreads200Response.serializer)
          ..add(UsersGetUserPlayedThreads200Response.serializer)
          ..add(UsersGetUserRecentReplies200Response.serializer)
          ..add(UsersMentionCandidates200Response.serializer)
          ..add(UsersRemoveAvatar200Response.serializer)
          ..add(UsersRemoveProfileCover200Response.serializer)
          ..add(UsersSearch200Response.serializer)
          ..add(UsersSetAvatar200Response.serializer)
          ..add(UsersSetProfileCover200Response.serializer)
          ..add(UsersUpdateMe200Response.serializer)
          ..add(VerifyAndCompleteDto.serializer)
          ..add(VerifyEmailDto.serializer)
          ..add(WalletResponseDto.serializer)
          ..add(WalletTransactionResponseDto.serializer)
          ..add(WalletTransactionResponseDtoDirectionEnum.serializer)
          ..add(WalletTransactionResponseDtoTypeEnum.serializer)
          ..add(WalletTransactionTargetResponseDto.serializer)
          ..add(WalletTransactionTargetResponseDtoTypeEnum.serializer)
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(AdminAuditLogResponseDto),
            ]),
            () => ListBuilder<AdminAuditLogResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(AdminDashboardDistributionItemDto),
            ]),
            () => ListBuilder<AdminDashboardDistributionItemDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(AdminDashboardDistributionItemDto),
            ]),
            () => ListBuilder<AdminDashboardDistributionItemDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(AdminDashboardDistributionItemDto),
            ]),
            () => ListBuilder<AdminDashboardDistributionItemDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(AdminDashboardDistributionItemDto),
            ]),
            () => ListBuilder<AdminDashboardDistributionItemDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(AdminDashboardDistributionItemDto),
            ]),
            () => ListBuilder<AdminDashboardDistributionItemDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(AdminDashboardTimeseriesPointDto),
            ]),
            () => ListBuilder<AdminDashboardTimeseriesPointDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(AdminReportResponseDto),
            ]),
            () => ListBuilder<AdminReportResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(AdminSystemNotificationHistoryItemDto),
            ]),
            () => ListBuilder<AdminSystemNotificationHistoryItemDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(AdminUserModerationResponseDto),
            ]),
            () => ListBuilder<AdminUserModerationResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(AdminUserSearchItemDto),
            ]),
            () => ListBuilder<AdminUserSearchItemDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(BlockedUserRecordResponseDto),
            ]),
            () => ListBuilder<BlockedUserRecordResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(BookmarkFolderResponseDto),
            ]),
            () => ListBuilder<BookmarkFolderResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(BookmarkThreadResponseDto),
            ]),
            () => ListBuilder<BookmarkThreadResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(BuiltMap, const [
                const FullType(String),
                const FullType.nullable(JsonObject),
              ]),
            ]),
            () => ListBuilder<BuiltMap<String, JsonObject?>>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(BuiltMap, const [
                const FullType(String),
                const FullType.nullable(JsonObject),
              ]),
            ]),
            () => ListBuilder<BuiltMap<String, JsonObject?>>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(BuiltMap, const [
                const FullType(String),
                const FullType.nullable(JsonObject),
              ]),
            ]),
            () => ListBuilder<BuiltMap<String, JsonObject?>>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(BuiltMap, const [
                const FullType(String),
                const FullType.nullable(JsonObject),
              ]),
            ]),
            () => ListBuilder<BuiltMap<String, JsonObject?>>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(DiceRollResponseDto),
            ]),
            () => ListBuilder<DiceRollResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(DiceRollResponseDto),
            ]),
            () => ListBuilder<DiceRollResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(DiceRollResponseDto),
            ]),
            () => ListBuilder<DiceRollResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(DiceRollResponseDto),
            ]),
            () => ListBuilder<DiceRollResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(DiceRollResponseDto),
            ]),
            () => ListBuilder<DiceRollResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(ReplyResponseDto)]),
            () => ListBuilder<ReplyResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(DirectConversationResponseDto),
            ]),
            () => ListBuilder<DirectConversationResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(DirectMessageResponseDto),
            ]),
            () => ListBuilder<DirectMessageResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(DraftResponseDto)]),
            () => ListBuilder<DraftResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(DraftThreadResponseDto),
            ]),
            () => ListBuilder<DraftThreadResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(FloorResponseDto)]),
            () => ListBuilder<FloorResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(HomeThreadListItemResponseDto),
            ]),
            () => ListBuilder<HomeThreadListItemResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(MentionCandidateDto),
            ]),
            () => ListBuilder<MentionCandidateDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ModerationAppealResponseDto),
            ]),
            () => ListBuilder<ModerationAppealResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ModerationCaseResponseDto),
            ]),
            () => ListBuilder<ModerationCaseResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ModerationDecisionPublicResponseDto),
            ]),
            () => ListBuilder<ModerationDecisionPublicResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(MomentCardResponseDto),
            ]),
            () => ListBuilder<MomentCardResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(MomentCardResponseDto),
            ]),
            () => ListBuilder<MomentCardResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(MomentCardResponseDto),
            ]),
            () => ListBuilder<MomentCardResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(MomentCommentResponseDto),
            ]),
            () => ListBuilder<MomentCommentResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(MomentCommentResponseDto),
            ]),
            () => ListBuilder<MomentCommentResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(MomentMediaResponseDto),
            ]),
            () => ListBuilder<MomentMediaResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(MomentRootCommentResponseDto),
            ]),
            () => ListBuilder<MomentRootCommentResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(MomentSearchResponseDto),
            ]),
            () => ListBuilder<MomentSearchResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(NotificationAudienceDtoRolesEnum),
            ]),
            () => ListBuilder<NotificationAudienceDtoRolesEnum>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(NotificationCampaignResponseDto),
            ]),
            () => ListBuilder<NotificationCampaignResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(NotificationLikerResponseDto),
            ]),
            () => ListBuilder<NotificationLikerResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(NotificationResponseDto),
            ]),
            () => ListBuilder<NotificationResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(OwnBookmarkThreadResponseDto),
            ]),
            () => ListBuilder<OwnBookmarkThreadResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(PostAuthorResponseDto),
            ]),
            () => ListBuilder<PostAuthorResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(PostAuthorResponseDto),
            ]),
            () => ListBuilder<PostAuthorResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(RecentReplyDiceResponseDto),
            ]),
            () => ListBuilder<RecentReplyDiceResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(RecentReplyResponseDto),
            ]),
            () => ListBuilder<RecentReplyResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ReorderedSubthreadResponseDto),
            ]),
            () => ListBuilder<ReorderedSubthreadResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(ReplyResponseDto)]),
            () => ListBuilder<ReplyResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(SearchPostResponseDto),
            ]),
            () => ListBuilder<SearchPostResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(SearchPostResponseDto),
            ]),
            () => ListBuilder<SearchPostResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(SearchThreadResponseDto),
            ]),
            () => ListBuilder<SearchThreadResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(SearchUserResponseDto),
            ]),
            () => ListBuilder<SearchUserResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(SearchUserResponseDto),
            ]),
            () => ListBuilder<SearchUserResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(SearchThreadResponseDto),
            ]),
            () => ListBuilder<SearchThreadResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(SearchPostResponseDto),
            ]),
            () => ListBuilder<SearchPostResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(SessionResponseDto),
            ]),
            () => ListBuilder<SessionResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(SubscriptionResponseDto),
            ]),
            () => ListBuilder<SubscriptionResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(SubthreadResponseDto),
            ]),
            () => ListBuilder<SubthreadResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(TagResponseDto)]),
            () => ListBuilder<TagResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(TagResponseDto)]),
            () => ListBuilder<TagResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ThreadCategoryResponseDto),
            ]),
            () => ListBuilder<ThreadCategoryResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ThreadCategoryResponseDto),
            ]),
            () => ListBuilder<ThreadCategoryResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ThreadListItemResponseDto),
            ]),
            () => ListBuilder<ThreadListItemResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ThreadListItemResponseDto),
            ]),
            () => ListBuilder<ThreadListItemResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ThreadMemberResponseDto),
            ]),
            () => ListBuilder<ThreadMemberResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ThreadSubthreadResponseDto),
            ]),
            () => ListBuilder<ThreadSubthreadResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ThreadTagRelationResponseDto),
            ]),
            () => ListBuilder<ThreadTagRelationResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ThreadTagRelationResponseDto),
            ]),
            () => ListBuilder<ThreadTagRelationResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ThreadTagRelationResponseDto),
            ]),
            () => ListBuilder<ThreadTagRelationResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ThreadTagRelationResponseDto),
            ]),
            () => ListBuilder<ThreadTagRelationResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(ThreadTagRelationResponseDto),
            ]),
            () => ListBuilder<ThreadTagRelationResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(String)]),
            () => ListBuilder<String>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(UserConditionDtoRoleEnum),
            ]),
            () => ListBuilder<UserConditionDtoRoleEnum>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(UserFollowRecordResponseDto),
            ]),
            () => ListBuilder<UserFollowRecordResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(UserFollowRecordResponseDto),
            ]),
            () => ListBuilder<UserFollowRecordResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(UserFollowRecordResponseDto),
            ]),
            () => ListBuilder<UserFollowRecordResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(UserFollowRecordResponseDto),
            ]),
            () => ListBuilder<UserFollowRecordResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(UserStickerResponseDto),
            ]),
            () => ListBuilder<UserStickerResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(UserStickerResponseDto),
            ]),
            () => ListBuilder<UserStickerResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(StickerImportResponseDto),
            ]),
            () => ListBuilder<StickerImportResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [
              const FullType(WalletTransactionResponseDto),
            ]),
            () => ListBuilder<WalletTransactionResponseDto>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(num)]),
            () => ListBuilder<num>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltList, const [const FullType(num)]),
            () => ListBuilder<num>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType(BuiltMap, const [
                const FullType(String),
                const FullType.nullable(JsonObject),
              ]),
            ]),
            () => MapBuilder<String, BuiltMap<String, JsonObject?>>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType(BuiltMap, const [
                const FullType(String),
                const FullType.nullable(JsonObject),
              ]),
            ]),
            () => MapBuilder<String, BuiltMap<String, JsonObject?>>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType(BuiltMap, const [
                const FullType(String),
                const FullType.nullable(JsonObject),
              ]),
            ]),
            () => MapBuilder<String, BuiltMap<String, JsonObject?>>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject),
            ]),
            () => MapBuilder<String, JsonObject?>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject),
            ]),
            () => MapBuilder<String, JsonObject?>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject),
            ]),
            () => MapBuilder<String, JsonObject?>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject),
            ]),
            () => MapBuilder<String, JsonObject?>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject),
            ]),
            () => MapBuilder<String, JsonObject?>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject),
            ]),
            () => MapBuilder<String, JsonObject?>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject),
            ]),
            () => MapBuilder<String, JsonObject?>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject),
            ]),
            () => MapBuilder<String, JsonObject?>(),
          )
          ..addBuilderFactory(
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject),
            ]),
            () => MapBuilder<String, JsonObject?>(),
          ))
        .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

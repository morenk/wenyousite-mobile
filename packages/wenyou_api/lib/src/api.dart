//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart';
import 'package:wenyou_api/src/serializers.dart';
import 'package:wenyou_api/src/auth/api_key_auth.dart';
import 'package:wenyou_api/src/auth/basic_auth.dart';
import 'package:wenyou_api/src/auth/bearer_auth.dart';
import 'package:wenyou_api/src/auth/oauth.dart';
import 'package:wenyou_api/src/api/admin_api.dart';
import 'package:wenyou_api/src/api/admin_accounts_api.dart';
import 'package:wenyou_api/src/api/admin_appeals_api.dart';
import 'package:wenyou_api/src/api/admin_auth_api.dart';
import 'package:wenyou_api/src/api/admin_campaigns_api.dart';
import 'package:wenyou_api/src/api/admin_cases_api.dart';
import 'package:wenyou_api/src/api/admin_dashboard_api.dart';
import 'package:wenyou_api/src/api/admin_moderation_api.dart';
import 'package:wenyou_api/src/api/admin_operations_api.dart';
import 'package:wenyou_api/src/api/admin_reports_api.dart';
import 'package:wenyou_api/src/api/admin_taxonomy_api.dart';
import 'package:wenyou_api/src/api/auth_api.dart';
import 'package:wenyou_api/src/api/bookmarks_api.dart';
import 'package:wenyou_api/src/api/direct_messages_api.dart';
import 'package:wenyou_api/src/api/drafts_api.dart';
import 'package:wenyou_api/src/api/health_api.dart';
import 'package:wenyou_api/src/api/media_api.dart';
import 'package:wenyou_api/src/api/meta_api.dart';
import 'package:wenyou_api/src/api/mobile_devices_api.dart';
import 'package:wenyou_api/src/api/moderation_appeals_api.dart';
import 'package:wenyou_api/src/api/moments_api.dart';
import 'package:wenyou_api/src/api/notifications_api.dart';
import 'package:wenyou_api/src/api/posts_api.dart';
import 'package:wenyou_api/src/api/reports_api.dart';
import 'package:wenyou_api/src/api/search_api.dart';
import 'package:wenyou_api/src/api/stickers_api.dart';
import 'package:wenyou_api/src/api/subscriptions_api.dart';
import 'package:wenyou_api/src/api/subthreads_api.dart';
import 'package:wenyou_api/src/api/tags_api.dart';
import 'package:wenyou_api/src/api/thread_categories_api.dart';
import 'package:wenyou_api/src/api/threads_api.dart';
import 'package:wenyou_api/src/api/users_api.dart';
import 'package:wenyou_api/src/api/wallet_api.dart';

class WenyouApi {
  static const String basePath = r'https://wenyou.site';

  final Dio dio;
  final Serializers serializers;

  WenyouApi({
    Dio? dio,
    Serializers? serializers,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : this.serializers = serializers ?? standardSerializers,
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the OAuth token associated with the given [name].
  ///
  /// If no [OAuthInterceptor] is registered or no token exists for the given
  /// [name], this method has no effect.
  void removeOAuthToken(String name) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens.remove(name);
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the bearer authentication token associated with the given [name].
  ///
  /// If no [BearerAuthInterceptor] is registered or no token exists for the
  /// given [name], this method has no effect.
  void removeBearerAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens.remove(name);
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  /// Removes the basic authentication credentials associated with the given [name].
  ///
  /// If no [BasicAuthInterceptor] is registered or no credentials exist for the
  /// given [name], this method has no effect.
  void removeBasicAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo.remove(name);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Removes the API key associated with the given [name].
  ///
  /// If no [ApiKeyAuthInterceptor] is registered or no API key exists for the
  /// given [name], this method has no effect.
  void removeApiKey(String name) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys.remove(name);
    }
  }

  /// Get AdminApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminApi getAdminApi() {
    return AdminApi(dio, serializers);
  }

  /// Get AdminAccountsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminAccountsApi getAdminAccountsApi() {
    return AdminAccountsApi(dio, serializers);
  }

  /// Get AdminAppealsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminAppealsApi getAdminAppealsApi() {
    return AdminAppealsApi(dio, serializers);
  }

  /// Get AdminAuthApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminAuthApi getAdminAuthApi() {
    return AdminAuthApi(dio, serializers);
  }

  /// Get AdminCampaignsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminCampaignsApi getAdminCampaignsApi() {
    return AdminCampaignsApi(dio, serializers);
  }

  /// Get AdminCasesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminCasesApi getAdminCasesApi() {
    return AdminCasesApi(dio, serializers);
  }

  /// Get AdminDashboardApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminDashboardApi getAdminDashboardApi() {
    return AdminDashboardApi(dio, serializers);
  }

  /// Get AdminModerationApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminModerationApi getAdminModerationApi() {
    return AdminModerationApi(dio, serializers);
  }

  /// Get AdminOperationsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminOperationsApi getAdminOperationsApi() {
    return AdminOperationsApi(dio, serializers);
  }

  /// Get AdminReportsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminReportsApi getAdminReportsApi() {
    return AdminReportsApi(dio, serializers);
  }

  /// Get AdminTaxonomyApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AdminTaxonomyApi getAdminTaxonomyApi() {
    return AdminTaxonomyApi(dio, serializers);
  }

  /// Get AuthApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AuthApi getAuthApi() {
    return AuthApi(dio, serializers);
  }

  /// Get BookmarksApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  BookmarksApi getBookmarksApi() {
    return BookmarksApi(dio, serializers);
  }

  /// Get DirectMessagesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DirectMessagesApi getDirectMessagesApi() {
    return DirectMessagesApi(dio, serializers);
  }

  /// Get DraftsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DraftsApi getDraftsApi() {
    return DraftsApi(dio, serializers);
  }

  /// Get HealthApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  HealthApi getHealthApi() {
    return HealthApi(dio, serializers);
  }

  /// Get MediaApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  MediaApi getMediaApi() {
    return MediaApi(dio, serializers);
  }

  /// Get MetaApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  MetaApi getMetaApi() {
    return MetaApi(dio, serializers);
  }

  /// Get MobileDevicesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  MobileDevicesApi getMobileDevicesApi() {
    return MobileDevicesApi(dio, serializers);
  }

  /// Get ModerationAppealsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ModerationAppealsApi getModerationAppealsApi() {
    return ModerationAppealsApi(dio, serializers);
  }

  /// Get MomentsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  MomentsApi getMomentsApi() {
    return MomentsApi(dio, serializers);
  }

  /// Get NotificationsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  NotificationsApi getNotificationsApi() {
    return NotificationsApi(dio, serializers);
  }

  /// Get PostsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PostsApi getPostsApi() {
    return PostsApi(dio, serializers);
  }

  /// Get ReportsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ReportsApi getReportsApi() {
    return ReportsApi(dio, serializers);
  }

  /// Get SearchApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SearchApi getSearchApi() {
    return SearchApi(dio, serializers);
  }

  /// Get StickersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  StickersApi getStickersApi() {
    return StickersApi(dio, serializers);
  }

  /// Get SubscriptionsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SubscriptionsApi getSubscriptionsApi() {
    return SubscriptionsApi(dio, serializers);
  }

  /// Get SubthreadsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SubthreadsApi getSubthreadsApi() {
    return SubthreadsApi(dio, serializers);
  }

  /// Get TagsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  TagsApi getTagsApi() {
    return TagsApi(dio, serializers);
  }

  /// Get ThreadCategoriesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ThreadCategoriesApi getThreadCategoriesApi() {
    return ThreadCategoriesApi(dio, serializers);
  }

  /// Get ThreadsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ThreadsApi getThreadsApi() {
    return ThreadsApi(dio, serializers);
  }

  /// Get UsersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  UsersApi getUsersApi() {
    return UsersApi(dio, serializers);
  }

  /// Get WalletApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  WalletApi getWalletApi() {
    return WalletApi(dio, serializers);
  }
}

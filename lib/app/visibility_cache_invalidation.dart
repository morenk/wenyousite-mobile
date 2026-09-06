import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/editor/application/mention_candidates_controller.dart';
import 'package:wenyousite_mobile/features/home/application/home_feed_controller.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_bookmark_list_controller.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/search/application/search_controller.dart';
import 'package:wenyousite_mobile/features/social/application/bookmark_list_controller.dart';
import 'package:wenyousite_mobile/features/social/application/user_relation_list_controller.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/users/application/me_profile_controller.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';

void invalidateVisibilityCaches(ProviderContainer container) {
  container.invalidate(homeFeedControllerProvider);
  container.invalidate(momentFeedControllerProvider);
  container.invalidate(momentDetailControllerProvider);
  container.invalidate(momentCommentContextProvider);
  container.invalidate(searchControllerProvider);
  container.invalidate(threadPostSearchControllerProvider);
  container.invalidate(threadDetailControllerProvider);
  container.invalidate(threadPostTargetProvider);
  container.invalidate(postDiscussionControllerProvider);
  container.invalidate(publicUserControllerProvider);
  container.invalidate(meUserContentControllerProvider);
  container.invalidate(meProfileControllerProvider);
  container.invalidate(userRelationListControllerProvider);
  container.invalidate(bookmarkListControllerProvider);
  container.invalidate(momentBookmarkListControllerProvider);
  container.invalidate(notificationListControllerProvider);
  container.invalidate(notificationUnreadControllerProvider);
  container.invalidate(directConversationListControllerProvider);
  container.invalidate(directConversationControllerProvider);
  container.invalidate(directUnreadControllerProvider);
  container.invalidate(mentionCandidatesControllerProvider);
}

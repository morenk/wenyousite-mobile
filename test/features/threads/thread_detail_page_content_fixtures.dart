import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

import 'thread_detail_page_collaboration_repositories.dart';

final threadDetailPageTestSideFloor = ThreadFloorModel(
  id: 'floor-2',
  floorNumber: 1,
  author: threadDetailPageTestAuthor,
  body: const ThreadBodyModel(markdown: '支线楼层'),
  createdAt: threadDetailPageTestRecentFixtureTime,
  isDeleted: false,
  replyCount: 0,
  replies: const [],
);

final threadDetailPageTestPaginatedFloor = ThreadFloorModel(
  id: 'floor-page',
  floorNumber: 2,
  author: threadDetailPageTestAuthor,
  body: const ThreadBodyModel(markdown: '分页新增内容'),
  createdAt: threadDetailPageTestRecentFixtureTime,
  isDeleted: false,
  replyCount: 0,
  replies: const [],
);

final threadDetailPageTestTargetFloor = ThreadFloorModel(
  id: 'floor-target',
  floorNumber: 9,
  author: threadDetailPageTestAuthor,
  body: const ThreadBodyModel(markdown: '目标楼层内容'),
  createdAt: threadDetailPageTestRecentFixtureTime,
  isDeleted: false,
  replyCount: 0,
  replies: const [],
);

final threadDetailPageTestLatestFloorPost = ThreadLatestPostModel(
  id: 'floor-target',
  threadId: 'thread-1',
  subthreadId: 'subthread-2',
  createdAt: threadDetailPageTestRecentFixtureTime,
);

final threadDetailPageTestHomeThread = ThreadFeedCardModel(
  id: 'thread-1',
  title: '星海旅团',
  categorySlug: 'RPG',
  status: ThreadFeedStatus.recruiting,
  isPinned: false,
  ownerId: 'user-1',
  ownerName: '温柔测试员',
  ownerLevel: 3,
  tags: const [],
  coverImageUrls: const [],
  memberCount: 5,
  playerCount: 2,
  postCount: 12,
  tipTotal: '8',
  lastActivityAt: DateTime.utc(2026, 8, 9, 12),
);

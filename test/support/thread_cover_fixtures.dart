import 'package:wenyou_api/wenyou_api.dart';

ThreadCoverMediaResponseDto animatedThreadCoverFixture([
  String url = 'https://cdn.example.com/cover.jpg',
]) => ThreadCoverMediaResponseDto(
  (cover) => cover
    ..url = url
    ..animated = true
    ..posterUrl = 'https://cdn.example.com/cover_poster.webp',
);

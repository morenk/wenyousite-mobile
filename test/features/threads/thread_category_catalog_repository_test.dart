import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_category_catalog_repository.dart';

void main() {
  test('公开分类目录保留服务端用户 label 并过滤停用项', () async {
    final api = _MockThreadCategoriesApi();
    when(
      () => api.threadCategoriesList(extra: any(named: 'extra')),
    ).thenAnswer((_) async => _response());

    final result = await ApiThreadCategoryCatalogRepository(
      api,
    ).fetchThreadCategories();

    expect(result, hasLength(1));
    expect(result.single.slug, 'DEDUCTION');
    expect(result.single.name, '演绎');
    final extra =
        verify(
              () => api.threadCategoriesList(extra: captureAny(named: 'extra')),
            ).captured.single
            as Map<String, dynamic>?;
    expect(extra?['skipAuth'], isTrue);
  });
}

class _MockThreadCategoriesApi extends Mock implements ThreadCategoriesApi {}

Response<ThreadCategoriesList200Response> _response() {
  final now = DateTime.utc(2026, 8, 23);
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/thread-categories'),
    data: ThreadCategoriesList200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.addAll([
          ThreadCategoryResponseDto(
            (category) => category
              ..id = 'category-deduction'
              ..slug = 'DEDUCTION'
              ..name = '演绎'
              ..sortOrder = 2
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
          ),
          ThreadCategoryResponseDto(
            (category) => category
              ..id = 'category-archived'
              ..slug = 'ARCHIVED_WORLD'
              ..name = '旧分类'
              ..sortOrder = 1
              ..isActive = false
              ..createdAt = now
              ..updatedAt = now,
          ),
        ]),
    ),
  );
}

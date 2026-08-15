class ContentDraft {
  const ContentDraft({
    required this.id,
    required this.userId,
    required this.slot,
    required this.content,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final int slot;
  final String content;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ContentDraftSlotUsage {
  const ContentDraftSlotUsage({
    required this.usedSlots,
    required this.maxSlots,
    required this.occupiedSlots,
  });

  const ContentDraftSlotUsage.empty()
    : usedSlots = 0,
      maxSlots = 5,
      occupiedSlots = const {};

  final int usedSlots;
  final int maxSlots;
  final Set<int> occupiedSlots;

  bool get isFull => usedSlots >= maxSlots;
}

class ContentDraftCollection {
  const ContentDraftCollection({required this.drafts, required this.usage});

  final List<ContentDraft> drafts;
  final ContentDraftSlotUsage usage;
}

class ContentDraftConflict {
  const ContentDraftConflict({
    required this.latest,
    required this.pendingContent,
  });

  final ContentDraft latest;
  final String pendingContent;
}

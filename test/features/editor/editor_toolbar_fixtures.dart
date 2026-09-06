String editorToolbarTestDiceMarkdown(int count) =>
    List.generate(count, (index) {
      final suffix = index.toString().padLeft(12, '0');
      return '[[dice:v1:00000000-0000-4000-8000-$suffix:1d6]]';
    }).join(' ');

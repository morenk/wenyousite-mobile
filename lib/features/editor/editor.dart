/// Public presentation surface for embedding the Markdown editor in another
/// feature. Business-specific compose workflows stay in their owning feature.
library;

export 'presentation/editor_embed_builders.dart' show wenyouEditorEmbedBuilders;
export 'presentation/editor_text_styles.dart' show wenyouEditorTextStyles;
export 'presentation/editor_toolbar.dart'
    show
        WenyouComposerDock,
        WenyouComposerSurface,
        WenyouEditorCapabilities,
        WenyouEditorToolbar,
        WenyouEditorToolbarController;
export 'presentation/mention_suggestions.dart' show MentionSuggestions;
export 'presentation/rich_editor_session.dart'
    show RichEditorSelectionPlacement, RichEditorSession;

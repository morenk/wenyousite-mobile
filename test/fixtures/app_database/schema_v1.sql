CREATE TABLE local_editor_snapshots (
  id TEXT NOT NULL PRIMARY KEY,
  context_type TEXT NOT NULL,
  context_id TEXT NULL,
  body TEXT NOT NULL,
  metadata_json TEXT NOT NULL,
  client_request_id TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE TABLE pending_create_operations (
  client_request_id TEXT NOT NULL PRIMARY KEY,
  operation_type TEXT NOT NULL,
  normalized_payload TEXT NOT NULL,
  state TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);

PRAGMA user_version = 1;

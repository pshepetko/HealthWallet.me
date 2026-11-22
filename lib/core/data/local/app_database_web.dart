import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web connection backed by drift's `sqlite3.wasm` build.
///
/// Requires the `web/sqlite3.wasm` binary and the `web/drift_worker.js` worker
/// (compiled from drift 2.21.0) to be served alongside the app. Drift probes
/// the browser and picks the best persistent storage backend (OPFS or
/// IndexedDB), falling back to in-memory only if no persistence is available.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'health_wallet',
      sqlite3Uri: Uri.base.resolve('sqlite3.wasm'),
      driftWorkerUri: Uri.base.resolve('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}

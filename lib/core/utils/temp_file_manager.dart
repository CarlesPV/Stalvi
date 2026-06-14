import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:konta/core/errors/app_exceptions.dart';
import 'package:konta/domain/repositories/i_export_service.dart';

/// Manages the lifecycle of temporary export files:
/// write → share → delete.
///
/// **Security contract**: Files are written to [getTemporaryDirectory()] which
/// is isolated to the app's sandbox on both iOS and Android. After [Share.shareXFiles]
/// resolves (the system has accepted the file for sharing), [cleanUp] is called
/// to delete the file from local storage so that unencrypted data does not linger
/// in the cache.
class TempFileManager {
  const TempFileManager();

  /// Writes [result] bytes to the system temp directory, invokes the native
  /// share sheet, and then **immediately deletes** the temp file regardless
  /// of the share outcome.
  ///
  /// Returns the [ShareResult] so callers can inspect the share status.
  Future<ShareResult> writeShareAndCleanUp(ExportResult result) async {
    File? tempFile;
    try {
      final dir = await getTemporaryDirectory();
      tempFile = File('${dir.path}/${result.filename}');

      // Write bytes — temp directory is app-sandboxed on iOS/Android.
      await tempFile.writeAsBytes(result.bytes, flush: true);

      final shareResult = await Share.shareXFiles(
        [XFile(tempFile.path, mimeType: result.mimeType)],
        subject: result.filename,
      );

      return shareResult;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ExportFileException(
        message: 'Failed to share export file "${result.filename}"',
        code: 'SHARE_FAILED',
        details: e,
      );
    } finally {
      // Always clean up — even on exceptions — to prevent data leakage.
      await cleanUp(tempFile);
    }
  }

  /// Deletes [file] if it exists. Silently ignores errors (e.g. already deleted).
  Future<void> cleanUp(File? file) async {
    if (file == null) return;
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort deletion. Log in production with a crash reporter.
    }
  }
}

/// Exception thrown when file writing or sharing fails.
class ExportFileException extends AppException {
  const ExportFileException({
    required super.message,
    super.code,
    super.details,
  });
}

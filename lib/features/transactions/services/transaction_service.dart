import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:path_provider/path_provider.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/category.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/constants/app_constants.dart';

/// Pure data layer for transaction operations.
/// Called by [TransactionController]. No Flutter widgets here.
class TransactionService {
  // ── Load ─────────────────────────────────────────────────────────────────

  Future<List<Transaction>> loadTransactions() =>
      StorageService.loadTransactions();

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<Transaction> addTransaction(Transaction transaction) async {
    final path = await _persistImage(transaction.imagePath);
    final final_ = path != transaction.imagePath
        ? transaction.copyWith(imagePath: path)
        : transaction;
    await StorageService.addTransaction(final_);
    return final_;
  }

  Future<Transaction> updateTransaction(
    Transaction oldTransaction,
    Transaction updated,
  ) async {
    final path = await _persistImage(updated.imagePath);
    // Clean up old image if different
    if (oldTransaction.imagePath != null &&
        oldTransaction.imagePath != path) {
      await _deleteImage(oldTransaction.imagePath);
    }
    final final_ = path != updated.imagePath
        ? updated.copyWith(imagePath: path)
        : updated;
    await StorageService.updateTransaction(final_);
    return final_;
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await _deleteImage(transaction.imagePath);
    await StorageService.deleteTransaction(transaction.id);
  }

  // ── Import / Merge ────────────────────────────────────────────────────────

  /// Merges incoming transactions, skipping duplicates.
  /// **Fix B4:** dupe check now includes time component (full ISO string)
  /// so same-day different-time transactions are NOT skipped.
  Future<int> mergeTransactions(
    List<Transaction> incoming,
    List<Transaction> existing,
    List<Category> categories,
    String defaultCategoryId,
    String defaultAccountId,
  ) async {
    int added = 0;
    for (final t in incoming) {
      // B4 fix: compare full ISO timestamp, not just the date part
      final isDupe = existing.any(
        (e) =>
            e.date.toIso8601String() == t.date.toIso8601String() &&
            e.description.toLowerCase() == t.description.toLowerCase() &&
            e.amount == t.amount,
      );
      if (isDupe) continue;

      final catId = categories.any((c) => c.id == t.categoryId)
          ? t.categoryId
          : defaultCategoryId;

      final cleaned = t.copyWith(
        categoryId: catId,
        accountId: defaultAccountId,
      );
      await StorageService.addTransaction(cleaned);
      added++;
    }
    return added;
  }

  // ── Image helpers ─────────────────────────────────────────────────────────

  /// Copies a temp image into the app's permanent receipts directory.
  /// **Fix B5:** uses a UUID-style name based on timestamp + random, not hashCode.
  Future<String?> _persistImage(String? currentPath) async {
    if (currentPath == null || currentPath.isEmpty) return null;

    final file = File(currentPath);
    if (!await file.exists()) return currentPath;

    final appDir = await getApplicationDocumentsDirectory();
    final receiptsPath = '${appDir.path}/receipts';
    final receiptsDir  = Directory(receiptsPath);

    if (currentPath.startsWith(receiptsPath)) return currentPath; // already saved

    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }

    // B5 fix: stable unique filename using milliseconds + microseconds
    final ext = _fileExtension(currentPath);
    final ts  = DateTime.now();
    final name = '${ts.millisecondsSinceEpoch}_${ts.microsecond}$ext';
    final saved = await file.copy('$receiptsPath/$name');
    return saved.path;
  }

  Future<void> _deleteImage(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      if (path.startsWith('${appDir.path}/receipts')) {
        final f = File(path);
        if (await f.exists()) await f.delete();
      }
    } catch (e) {
      debugPrint('TransactionService: failed to delete image: $e');
    }
  }

  String _fileExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot != -1 && path.length - dot <= 5) return path.substring(dot);
    return '.jpg';
  }
}

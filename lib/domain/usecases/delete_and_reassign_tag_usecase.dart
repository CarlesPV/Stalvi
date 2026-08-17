import '../repositories/i_tag_repository.dart';
import '../repositories/i_transaction_repository.dart';

import '../repositories/i_automatic_transaction_repository.dart';

class DeleteAndReassignTagUseCase {
  final ITagRepository _tagRepo;
  final ITransactionRepository _transactionRepo;
  final IAutomaticTransactionRepository _automaticTransactionRepo;

  DeleteAndReassignTagUseCase(
    this._tagRepo,
    this._transactionRepo,
    this._automaticTransactionRepo,
  );

  /// Checks if a tag is in use by any standard or automatic transaction.
  Future<bool> isTagInUse(String tagId) async {
    final transactions = await _transactionRepo
        .watchFilteredTransactions(TransactionQueryFilter(tagId: tagId))
        .first;
    if (transactions.isNotEmpty) return true;

    final autoTransactions =
        await _automaticTransactionRepo.watchAllAutomaticTransactions().first;
    return autoTransactions.any(
      (tx) => (tx.tagId == tagId || tx.labelId == tagId) && !tx.isDeleted,
    );
  }

  /// Reassigns transactions from [oldTagId] to [newTagId],
  /// then soft-deletes [oldTagId].
  Future<void> execute({
    required String oldTagId,
    required String newTagId,
  }) async {
    if (oldTagId == newTagId) {
      throw ArgumentError('New tag cannot be the same as the old tag');
    }

    final oldTag = await _tagRepo.getTagById(oldTagId);
    final newTag = await _tagRepo.getTagById(newTagId);

    if (oldTag == null || newTag == null) {
      throw StateError('Tag not found');
    }

    final transactions = await _transactionRepo
        .watchFilteredTransactions(TransactionQueryFilter(tagId: oldTagId))
        .first;

    final oldTagName = oldTag.name;
    final newTagName = newTag.name;

    for (var tx in transactions) {
      String? updatedNotes = tx.notes;

      // Simple replacement. Note: this might replace substrings in unrelated words,
      // but given the current query uses LIKE '%tag.name%', it's consistent.
      if (updatedNotes != null && updatedNotes.contains(oldTagName)) {
        updatedNotes = updatedNotes.replaceAll(oldTagName, newTagName);
      }

      final updatedTx = tx.copyWith(
        tagId: newTagId,
        notes: updatedNotes,
        modifiedAt: DateTime.now(),
      );

      await _transactionRepo.updateTransaction(updatedTx);
    }

    final autoTransactions =
        await _automaticTransactionRepo.watchAllAutomaticTransactions().first;
    final linkedAuto = autoTransactions.where(
      (tx) => tx.tagId == oldTagId || tx.labelId == oldTagId,
    );
    for (var tx in linkedAuto) {
      final updatedTx = tx.copyWith(
        tagId: tx.tagId == oldTagId ? newTagId : tx.tagId,
        labelId: tx.labelId == oldTagId ? newTagId : tx.labelId,
      );
      await _automaticTransactionRepo.updateAutomaticTransaction(updatedTx);
    }

    await _tagRepo.deleteTag(oldTagId);
  }
}

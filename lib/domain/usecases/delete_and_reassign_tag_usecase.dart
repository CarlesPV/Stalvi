import '../repositories/i_tag_repository.dart';
import '../repositories/i_transaction_repository.dart';

class DeleteAndReassignTagUseCase {
  final ITagRepository _tagRepo;
  final ITransactionRepository _transactionRepo;

  DeleteAndReassignTagUseCase(this._tagRepo, this._transactionRepo);

  /// Checks if a tag is in use by any transaction.
  Future<bool> isTagInUse(String tagId) async {
    final transactions = await _transactionRepo
        .watchFilteredTransactions(TransactionQueryFilter(tagId: tagId))
        .first;
    return transactions.isNotEmpty;
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
      if (tx.notes != null && tx.notes!.contains(oldTagName)) {
        // Simple replacement. Note: this might replace substrings in unrelated words,
        // but given the current query uses LIKE '%tag.name%', it's consistent.
        final updatedNotes = tx.notes!.replaceAll(oldTagName, newTagName);
        final updatedTx = tx.copyWith(
          notes: updatedNotes,
          modifiedAt: DateTime.now(),
        );
        await _transactionRepo.updateTransaction(updatedTx);
      }
    }

    await _tagRepo.deleteTag(oldTagId);
  }
}

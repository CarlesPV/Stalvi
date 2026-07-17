import '../repositories/i_trash_repository.dart';

/// Automatically purges items that have been in the trash for more than 30 days.
class AutoPurgeUseCase {
  final ITrashRepository _trashRepository;

  AutoPurgeUseCase(this._trashRepository);

  Future<void> execute() async {
    final threshold = DateTime.now().subtract(const Duration(days: 30));
    await _trashRepository.purgeOldItems(threshold);
  }
}

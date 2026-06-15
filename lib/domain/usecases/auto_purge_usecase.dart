import '../../data/database/daos/trash_dao.dart';

class AutoPurgeUseCase {
  final TrashDao _trashDao;

  AutoPurgeUseCase(this._trashDao);

  /// Automatically purges items that have been in the trash for more than 30 days.
  Future<void> execute() async {
    final threshold = DateTime.now().subtract(const Duration(days: 30));
    await _trashDao.purgeOldItems(threshold);
  }
}

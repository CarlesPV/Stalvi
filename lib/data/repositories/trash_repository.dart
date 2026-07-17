import 'package:stalvi/data/database/daos/savings_goal_dao.dart';
import 'package:stalvi/data/database/daos/trash_dao.dart';
import 'package:stalvi/domain/entities/trash_item.dart';
import 'package:stalvi/domain/repositories/i_trash_repository.dart';

/// Concrete implementation of [ITrashRepository] backed by [TrashDao] and [SavingsGoalDao].
class TrashRepository implements ITrashRepository {
  final TrashDao _trashDao;
  final SavingsGoalDao _savingsGoalDao;

  TrashRepository({
    required TrashDao trashDao,
    required SavingsGoalDao savingsGoalDao,
  })  : _trashDao = trashDao,
        _savingsGoalDao = savingsGoalDao;

  @override
  Future<List<TrashItem>> getTrashItems() => _trashDao.getTrashItems();

  @override
  Stream<List<TrashItem>> watchTrashItems() => _trashDao.watchTrashItems();

  @override
  Future<void> restoreItem(String id, TrashItemType type) =>
      _trashDao.restoreItem(id, type);

  @override
  Future<void> deleteItemPermanently(String id, TrashItemType type) =>
      _trashDao.deleteItemPermanently(id, type);

  @override
  Future<void> purgeOldItems(DateTime threshold) =>
      _trashDao.purgeOldItems(threshold);

  @override
  Future<void> cascadeRestoreSavingsGoal(String id) =>
      _savingsGoalDao.cascadeRestore(id);

  @override
  Future<void> cascadeSoftDeleteSavingsGoal(String id) =>
      _savingsGoalDao.cascadeSoftDelete(id);
}

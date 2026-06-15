import '../../data/database/daos/trash_dao.dart';
import '../entities/trash_item.dart';

class TrashUsecases {
  final TrashDao _trashDao;

  TrashUsecases(this._trashDao);

  Future<List<TrashItem>> getTrashItems() => _trashDao.getTrashItems();

  Future<void> restoreItem(String id, TrashItemType type) =>
      _trashDao.restoreItem(id, type);

  Future<void> deleteItemPermanently(String id, TrashItemType type) =>
      _trashDao.deleteItemPermanently(id, type);
}

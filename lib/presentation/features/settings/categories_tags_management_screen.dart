import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/errors/app_exceptions.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/tag.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/category_icon_picker.dart';
import 'package:uuid/uuid.dart';

class CategoriesTagsManagementScreen extends ConsumerStatefulWidget {
  const CategoriesTagsManagementScreen({super.key});

  @override
  ConsumerState<CategoriesTagsManagementScreen> createState() =>
      _CategoriesTagsManagementScreenState();
}

class _CategoriesTagsManagementScreenState
    extends ConsumerState<CategoriesTagsManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategory() {
    CategoryDialog.show(context, ref);
  }

  void _showAddTag() {
    TagDialog.show(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoriesAndTags),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.categories),
            Tab(text: l10n.tags),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_CategoriesTab(), _TagsTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddCategory();
          } else {
            _showAddTag();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Color _parseCategoryHexColor(String hexString) {
  if (hexString.isEmpty) return Colors.grey;
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  try {
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (_) {
    return Colors.grey;
  }
}

class _CategoriesTab extends ConsumerWidget {
  const _CategoriesTab();

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
    List<Category> allCategories,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    bool inUse = false;
    try {
      inUse = await ref
          .read(deleteAndReassignCategoryUseCaseProvider)
          .isCategoryInUse(category.id);
    } on CategoryInUseByAutomaticTransactionException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryInUseByAutoTxMessage(category.name)),
          duration: const Duration(seconds: 4),
        ),
      );
      if (!context.mounted) return;
      _showReassignDialog(context, ref, category);
      return;
    }

    if (!context.mounted) return;

    if (inUse) {
      if (!context.mounted) return;
      _showReassignDialog(context, ref, category);
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          scrollable: true,
          title: Text(l10n.deleteCategoryTitle),
          content: Text(l10n.deleteCategoryConfirm(category.name)),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.btnCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l10n.btnDelete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await ref.read(categoryRepositoryProvider).deleteCategory(category.id);
      }
    }
  }

  void _showReassignDialog(
    BuildContext context,
    WidgetRef ref,
    Category categoryToDel,
  ) {
    final l10n = AppLocalizations.of(context)!;
    String? selectedNewCategoryId;
    final otherCategories =
        ref.read(replacementCategoriesProvider(categoryToDel));

    if (otherCategories.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorNoOtherCategories)));
      return;
    }

    selectedNewCategoryId = otherCategories.first.id;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text(l10n.categoryInUseTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.categoryInUseMessage(categoryToDel.name)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedNewCategoryId,
                      items: otherCategories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        _parseCategoryHexColor(c.color),
                                    child: Icon(
                                      CategoryIconPicker.iconDataForKey(c.icon),
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(c.name),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => selectedNewCategoryId = val);
                      },
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.btnCancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedNewCategoryId != null) {
                      await ref
                          .read(deleteAndReassignCategoryUseCaseProvider)
                          .execute(
                            oldCategoryId: categoryToDel.id,
                            newCategoryId: selectedNewCategoryId!,
                          );
                      if (context.mounted) Navigator.pop(ctx);
                    }
                  },
                  child: Text(l10n.btnReassignAndDelete),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesListProvider);
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(child: Text(l10n.noCategories));
        }
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _parseCategoryHexColor(category.color),
                child: Icon(
                  CategoryIconPicker.iconDataForKey(category.icon),
                  color: Colors.white,
                ),
              ),
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(category.name),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        CategoryDialog.show(context, ref, category: category),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _confirmDelete(context, ref, category, categories),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('${l10n.unexpectedError}: $e')),
    );
  }
}

class _TagsTab extends ConsumerWidget {
  const _TagsTab();

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Tag tag,
    List<Tag> allTags,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final inUse =
        await ref.read(deleteAndReassignTagUseCaseProvider).isTagInUse(tag.id);
    if (!context.mounted) return;

    if (inUse) {
      _showReassignDialog(context, ref, tag, allTags);
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          scrollable: true,
          title: Text(l10n.deleteTagTitle),
          content: Text(l10n.deleteTagConfirm(tag.name)),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.btnCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l10n.btnDelete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await ref.read(tagRepositoryProvider).deleteTag(tag.id);
        ref.invalidate(tagsListProvider);
      }
    }
  }

  void _showReassignDialog(
    BuildContext context,
    WidgetRef ref,
    Tag tagToDel,
    List<Tag> allTags,
  ) {
    final l10n = AppLocalizations.of(context)!;
    String? selectedNewTagId;
    final otherTags = allTags.where((t) => t.id != tagToDel.id).toList();

    if (otherTags.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorNoOtherTags)));
      return;
    }

    selectedNewTagId = otherTags.first.id;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text(l10n.tagInUseTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.tagInUseMessage(tagToDel.name)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedNewTagId,
                      items: otherTags
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.id,
                              child: Text(t.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => selectedNewTagId = val);
                      },
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.btnCancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedNewTagId != null) {
                      await ref
                          .read(deleteAndReassignTagUseCaseProvider)
                          .execute(
                            oldTagId: tagToDel.id,
                            newTagId: selectedNewTagId!,
                          );
                      ref.invalidate(tagsListProvider);
                      if (context.mounted) Navigator.pop(ctx);
                    }
                  },
                  child: Text(l10n.btnReassignAndDelete),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tagsAsync = ref.watch(tagsListProvider);
    return tagsAsync.when(
      data: (tags) {
        if (tags.isEmpty) return Center(child: Text(l10n.noTags));
        return ListView.builder(
          itemCount: tags.length,
          itemBuilder: (context, index) {
            final tag = tags[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.tag)),
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(tag.name),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => TagDialog.show(context, ref, tag: tag),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, ref, tag, tags),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('${l10n.unexpectedError}: $e')),
    );
  }
}

class CategoryDialog extends StatefulWidget {
  final Category? category;
  final WidgetRef ref;
  const CategoryDialog({super.key, this.category, required this.ref});

  static Future<String?> show(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => CategoryDialog(category: category, ref: ref),
    );
  }

  @override
  State<CategoryDialog> createState() => CategoryDialogState();
}

class CategoryDialogState extends State<CategoryDialog> {
  final _nameController = TextEditingController();
  String _selectedColor = '#2196F3';
  String _selectedIcon = 'category';
  final List<String> _colors = [
    '#2196F3',
    '#4CAF50',
    '#FFC107',
    '#E91E63',
    '#9C27B0',
    '#FF5722',
    '#00BCD4',
    '#009688',
    '#8BC34A',
    '#CDDC39',
    '#FF9800',
    '#F44336',
    '#795548',
    '#607D8B',
    '#673AB7',
    '#3F51B5',
    '#EC407A',
    '#26A69A',
    '#D4E157',
    '#FF7043',
    '#8D6E63',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedColor = widget.category!.color;
      _selectedIcon =
          widget.category!.icon.isNotEmpty ? widget.category!.icon : 'category';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.category == null
                  ? l10n.addCategoryTitle
                  : l10n.editCategoryTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              maxLength: 31,
              decoration: InputDecoration(
                labelText: l10n.labelCategoryName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: _colors.map((colorHex) {
                final color = _parseCategoryHexColor(colorHex);
                final isSelected = _selectedColor == colorHex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorHex),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircleAvatar(
                        backgroundColor: color,
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.labelIcon,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 8),
            CategoryIconPicker(
              selectedIcon: _selectedIcon,
              onIconSelected: (key) => setState(() => _selectedIcon = key),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) return;
                final repo = widget.ref.read(categoryRepositoryProvider);
                if (widget.category == null) {
                  final newId = const Uuid().v4();
                  await repo.createCategory(
                    Category(
                      id: newId,
                      name: _nameController.text.trim(),
                      icon: _selectedIcon,
                      color: _selectedColor,
                      createdAt: DateTime.now(),
                      modifiedAt: DateTime.now(),
                    ),
                  );
                  if (context.mounted) Navigator.pop(context, newId);
                } else {
                  await repo.updateCategory(
                    widget.category!.copyWith(
                      name: _nameController.text.trim(),
                      icon: _selectedIcon,
                      color: _selectedColor,
                      modifiedAt: DateTime.now(),
                    ),
                  );
                  if (context.mounted) {
                    Navigator.pop(context, widget.category!.id);
                  }
                }
              },
              child: Text(l10n.btnSave),
            ),
          ],
        ),
      ),
    );
  }
}

class TagDialog extends StatefulWidget {
  final Tag? tag;
  final WidgetRef ref;
  const TagDialog({super.key, this.tag, required this.ref});

  static Future<String?> show(BuildContext context, WidgetRef ref, {Tag? tag}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => TagDialog(tag: tag, ref: ref),
    );
  }

  @override
  State<TagDialog> createState() => TagDialogState();
}

class TagDialogState extends State<TagDialog> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.tag != null) {
      _nameController.text = widget.tag!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.tag == null ? l10n.addTagTitle : l10n.editTagTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              maxLength: 31,
              decoration: InputDecoration(
                labelText: l10n.labelTagName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) return;
                final repo = widget.ref.read(tagRepositoryProvider);
                if (widget.tag == null) {
                  final newId = const Uuid().v4();
                  await repo.createTag(
                    Tag(
                      id: newId,
                      name: _nameController.text.trim(),
                      createdAt: DateTime.now(),
                      modifiedAt: DateTime.now(),
                    ),
                  );
                  widget.ref.invalidate(tagsListProvider);
                  if (context.mounted) Navigator.pop(context, newId);
                } else {
                  await repo.updateTag(
                    widget.tag!.copyWith(
                      name: _nameController.text.trim(),
                      modifiedAt: DateTime.now(),
                    ),
                  );
                  widget.ref.invalidate(tagsListProvider);
                  if (context.mounted) Navigator.pop(context, widget.tag!.id);
                }
              },
              child: Text(l10n.btnSave),
            ),
          ],
        ),
      ),
    );
  }
}

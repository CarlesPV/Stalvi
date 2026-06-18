import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/domain/entities/category.dart';
import 'package:stalvi/domain/entities/tag.dart';
import 'package:stalvi/presentation/providers/repository_providers.dart';
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
    _CategoryDialog.show(context, ref);
  }

  void _showAddTag() {
    _TagDialog.show(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Categories & Tags'), // Assuming hardcoded or we can use l10n
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Tags'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CategoriesTab(),
          _TagsTab(),
        ],
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

class _CategoriesTab extends ConsumerWidget {
  const _CategoriesTab();

  void _confirmDelete(BuildContext context, WidgetRef ref, Category category,
      List<Category> allCategories) async {
    final inUse = await ref
        .read(deleteAndReassignCategoryUseCaseProvider)
        .isCategoryInUse(category.id);
    if (!context.mounted) return;

    if (inUse) {
      _showReassignDialog(context, ref, category, allCategories);
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Category?'),
          content: Text('Are you sure you want to delete ${category.name}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await ref.read(categoryRepositoryProvider).deleteCategory(category.id);
      }
    }
  }

  void _showReassignDialog(BuildContext context, WidgetRef ref,
      Category categoryToDel, List<Category> allCategories) {
    String? selectedNewCategoryId;
    final otherCategories =
        allCategories.where((c) => c.id != categoryToDel.id).toList();

    if (otherCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No other categories to reassign transactions to.')),
      );
      return;
    }

    selectedNewCategoryId = otherCategories.first.id;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Category in use'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      '${categoryToDel.name} is used by existing transactions. Please select a category to reassign them to:'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedNewCategoryId,
                    items: otherCategories
                        .map((c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (val) {
                      setState(() => selectedNewCategoryId = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
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
                  child: const Text('Reassign & Delete'),
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
    final categoriesAsync = ref.watch(categoriesListProvider);
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty)
          return const Center(child: Text('No categories'));
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(int.parse(
                    category.color.replaceFirst('#', 'ff'),
                    radix: 16)),
                child: const Icon(Icons.category,
                    color: Colors.white), // Simplified icon handling
              ),
              title: Text(category.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        _CategoryDialog.show(context, ref, category: category),
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
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _TagsTab extends ConsumerWidget {
  const _TagsTab();

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Tag tag, List<Tag> allTags) async {
    final inUse =
        await ref.read(deleteAndReassignTagUseCaseProvider).isTagInUse(tag.id);
    if (!context.mounted) return;

    if (inUse) {
      _showReassignDialog(context, ref, tag, allTags);
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Tag?'),
          content: Text('Are you sure you want to delete ${tag.name}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
      BuildContext context, WidgetRef ref, Tag tagToDel, List<Tag> allTags) {
    String? selectedNewTagId;
    final otherTags = allTags.where((t) => t.id != tagToDel.id).toList();

    if (otherTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No other tags to reassign transactions to.')),
      );
      return;
    }

    selectedNewTagId = otherTags.first.id;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tag in use'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      '${tagToDel.name} is used by existing transactions. Please select a tag to reassign them to:'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedNewTagId,
                    items: otherTags
                        .map((t) =>
                            DropdownMenuItem(value: t.id, child: Text(t.name)))
                        .toList(),
                    onChanged: (val) {
                      setState(() => selectedNewTagId = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
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
                  child: const Text('Reassign & Delete'),
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
    final tagsAsync = ref.watch(tagsListProvider);
    return tagsAsync.when(
      data: (tags) {
        if (tags.isEmpty) return const Center(child: Text('No tags'));
        return ListView.builder(
          itemCount: tags.length,
          itemBuilder: (context, index) {
            final tag = tags[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.tag)),
              title: Text(tag.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _TagDialog.show(context, ref, tag: tag),
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
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final Category? category;
  final WidgetRef ref;
  const _CategoryDialog({this.category, required this.ref});

  static void show(BuildContext context, WidgetRef ref, {Category? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CategoryDialog(category: category, ref: ref),
    );
  }

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _nameController = TextEditingController();
  String _selectedColor = '#2196F3';
  final List<String> _colors = [
    '#2196F3',
    '#4CAF50',
    '#FFC107',
    '#E91E63',
    '#9C27B0',
    '#FF5722'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.category == null ? 'Add Category' : 'Edit Category',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
                labelText: 'Category Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _colors.map((colorHex) {
              final color =
                  Color(int.parse(colorHex.replaceFirst('#', 'ff'), radix: 16));
              final isSelected = _selectedColor == colorHex;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = colorHex),
                child: CircleAvatar(
                  backgroundColor: color,
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.trim().isEmpty) return;
              final repo = widget.ref.read(categoryRepositoryProvider);
              if (widget.category == null) {
                await repo.createCategory(Category(
                  id: const Uuid().v4(),
                  name: _nameController.text.trim(),
                  icon: 'category', // Simplified
                  color: _selectedColor,
                  createdAt: DateTime.now(),
                  modifiedAt: DateTime.now(),
                ));
              } else {
                await repo.updateCategory(widget.category!.copyWith(
                  name: _nameController.text.trim(),
                  color: _selectedColor,
                  modifiedAt: DateTime.now(),
                ));
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}

class _TagDialog extends StatefulWidget {
  final Tag? tag;
  final WidgetRef ref;
  const _TagDialog({this.tag, required this.ref});

  static void show(BuildContext context, WidgetRef ref, {Tag? tag}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _TagDialog(tag: tag, ref: ref),
    );
  }

  @override
  State<_TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<_TagDialog> {
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.tag == null ? 'Add Tag' : 'Edit Tag',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
                labelText: 'Tag Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.trim().isEmpty) return;
              final repo = widget.ref.read(tagRepositoryProvider);
              if (widget.tag == null) {
                await repo.createTag(Tag(
                  id: const Uuid().v4(),
                  name: _nameController.text.trim(),
                  createdAt: DateTime.now(),
                  modifiedAt: DateTime.now(),
                ));
              } else {
                await repo.updateTag(widget.tag!.copyWith(
                  name: _nameController.text.trim(),
                  modifiedAt: DateTime.now(),
                ));
              }
              widget.ref.invalidate(tagsListProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}

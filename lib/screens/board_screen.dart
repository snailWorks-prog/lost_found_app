import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../models/claims_model.dart';
import '../models/items_model.dart';
import '../widgets/error_view.dart';
import '../widgets/item_card.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  int _selectedTypeIndex = 0;
  String _searchQuery = '';
  String _selectedLocationFilter = 'Все корпуса';

  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CampusItem> _filterItems(List<CampusItem> allItems) {
    return allItems.where((item) {
      // 1. Segment filter
      if (_selectedTypeIndex == 1 && item.type != ItemType.found) {
        return false;
      }
      if (_selectedTypeIndex == 2 && item.type != ItemType.lost) {
        return false;
      }

      // 2. Location chip filter
      if (_selectedLocationFilter == 'Корпус 3 (FCIM)' &&
          !item.location.toLowerCase().contains('корпус 3')) {
        return false;
      }
      if (_selectedLocationFilter == 'Общежития' &&
          !item.location.toLowerCase().contains('общежит')) {
        return false;
      }
      if (_selectedLocationFilter == 'Библиотека' &&
          !item.location.toLowerCase().contains('библио')) {
        return false;
      }

      // 3. Search query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchLoc = item.location.toLowerCase().contains(q);
        final matchDesc = item.description.toLowerCase().contains(q);
        if (!matchTitle && !matchLoc && !matchDesc) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ItemsModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Бюро находок кампуса'),
        actions: [
          Consumer<ClaimsModel>(
            builder: (context, claimsModel, child) {
              return IconButton(
                tooltip: 'Мои заявки',
                onPressed: () => context.push('/my-items'),
                icon: Badge.count(
                  count: claimsModel.count,
                  isLabelVisible: claimsModel.count > 0,
                  child: const Icon(Icons.bookmark_outline),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: [
                      ButtonSegment(
                        value: 0,
                        label: Text('Все (${model.items.length})'),
                      ),
                      const ButtonSegment(value: 1, label: Text('Найдено')),
                      const ButtonSegment(value: 2, label: Text('Потеряно')),
                    ],
                    selected: {_selectedTypeIndex},
                    onSelectionChanged: (set) {
                      setState(() => _selectedTypeIndex = set.first);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/board/new'),
        icon: const Icon(Icons.add),
        label: const Text('Подать объявление'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Поиск по названию или аудитории...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                for (final loc in [
                  'Все корпуса',
                  'Корпус 3 (FCIM)',
                  'Общежития',
                  'Библиотека'
                ]) ...[
                  FilterChip(
                    label: Text(loc),
                    selected: _selectedLocationFilter == loc,
                    onSelected: (_) {
                      setState(() => _selectedLocationFilter = loc);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Builder(
              builder: (context) {
                if (model.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (model.error != null) {
                  return ErrorView(
                    message: model.error!,
                    onRetry: () => context.read<ItemsModel>().load(),
                  );
                }

                final filteredItems = _filterItems(model.items);
                if (filteredItems.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => context.read<ItemsModel>().load(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 100),
                        Center(
                          child: Text(
                            'Объявлений по вашему запросу не найдено',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<ItemsModel>().load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return ItemCard(
                        item: item,
                        onTap: () => context.push('/board/${item.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

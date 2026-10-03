import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../widgets/status_badge.dart';

class ItemDetailsScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailsScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Экран сам ищет объект по id из адреса (без extra)
    final item = mockItems.firstWhere(
          (element) => element.id == itemId,
      orElse: () => mockItems.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали объявления'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: scheme.outline),
                    const SizedBox(height: 8),
                    Text(
                      'Фотография вещи (#${item.id})',
                      style: TextStyle(color: scheme.outline),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusBadge.item(
                  itemType: item.type,
                  isResolved: item.isResolved,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: scheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.location_on, color: scheme.primary),
                      title: const Text('Место обнаружения / утери'),
                      subtitle: Text(item.location),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.access_time, color: scheme.primary),
                      title: const Text('Дата и время'),
                      subtitle: Text(item.date),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.category_outlined, color: scheme.primary),
                      title: const Text('Категория'),
                      subtitle: Text(item.category),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Подробное описание',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push('/board/$itemId/claim'),
              icon: const Icon(Icons.front_hand_outlined),
              label: const Text('Это моя вещь (Подать заявку)'),
            ),
          ],
        ),
      ),
    );
  }
}
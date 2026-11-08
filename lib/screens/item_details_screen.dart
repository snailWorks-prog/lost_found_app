import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/items_model.dart';
import '../widgets/error_view.dart';
import '../widgets/status_badge.dart';

class ItemDetailsScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailsScreen({super.key, required this.itemId});

  String _getApiBase() {
    if (kIsWeb) return 'http://localhost:8080';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  Future<void> _deleteItem(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Удалить объявление?'),
        content: const Text(
          'Вы действительно хотите удалить это объявление? Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      final error = await context.read<ItemsModel>().removeItem(id);
      if (!context.mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления: $error')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Объявление успешно удалено')),
        );
        context.pop();
      }
    }
  }

  Future<void> _toggleStatus(BuildContext context, String id) async {
    final error = await context.read<ItemsModel>().toggleResolved(id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления статуса: $error')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Статус объявления обновлён')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final model = context.watch<ItemsModel>();
    final item = model.byId(itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали объявления')),
        body: model.isLoading
            ? const Center(child: CircularProgressIndicator())
            : model.error != null
                ? ErrorView(
                    message: model.error!,
                    onRetry: () => context.read<ItemsModel>().load(),
                  )
                : const Center(
                    child: Text('Объявление не существует или было удалено'),
                  ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали объявления'),
        actions: [
          IconButton(
            tooltip: 'Удалить объявление',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteItem(context, item.id),
          ),
        ],
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
              clipBehavior: Clip.antiAlias,
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      '${_getApiBase()}${item.imageUrl}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_outlined,
                                size: 64, color: scheme.outline),
                            const SizedBox(height: 8),
                            Text(
                              'Не удалось загрузить фото',
                              style: TextStyle(color: scheme.outline),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64, color: scheme.outline),
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
                      leading:
                          Icon(Icons.category_outlined, color: scheme.primary),
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
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _toggleStatus(context, item.id),
              icon: Icon(item.isResolved
                  ? Icons.replay_outlined
                  : Icons.check_circle_outline),
              label: Text(
                item.isResolved
                    ? 'Вернуть в активные'
                    : 'Отметить как возвращённое',
              ),
            ),
            const SizedBox(height: 8),
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

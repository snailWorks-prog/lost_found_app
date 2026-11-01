import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/claims_model.dart';
import '../models/items_model.dart';
import '../widgets/error_view.dart';
import '../widgets/item_card.dart';
import '../widgets/status_badge.dart';

class MyItemsScreen extends StatelessWidget {
  const MyItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final itemsModel = context.watch<ItemsModel>();
    final claimsModel = context.watch<ClaimsModel>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Моя активность'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Мои объявления (${itemsModel.items.length})'),
              Tab(text: 'Мои заявки (${claimsModel.claims.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Вкладка 1: Мои объявления
            Builder(
              builder: (context) {
                if (itemsModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (itemsModel.error != null) {
                  return ErrorView(
                    message: itemsModel.error!,
                    onRetry: () => context.read<ItemsModel>().load(),
                  );
                }
                if (itemsModel.items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => context.read<ItemsModel>().load(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text('У вас пока нет объявлений')),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => context.read<ItemsModel>().load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: itemsModel.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = itemsModel.items[index];
                      return ItemCard(
                        item: item,
                        onTap: () => context.push('/board/${item.id}'),
                      );
                    },
                  ),
                );
              },
            ),

            // Вкладка 2: Мои заявки
            Builder(
              builder: (context) {
                if (claimsModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (claimsModel.error != null) {
                  return ErrorView(
                    message: claimsModel.error!,
                    onRetry: () => context.read<ClaimsModel>().load(),
                  );
                }
                if (claimsModel.claims.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => context.read<ClaimsModel>().load(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text('У вас пока нет заявок')),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => context.read<ClaimsModel>().load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: claimsModel.claims.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final claim = claimsModel.claims[index];
                      return Dismissible(
                        key: ValueKey(claim.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              title: const Text('Удалить заявку?'),
                              content: const Text(
                                'Вы действительно хотите отозвать эту заявку?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogCtx, false),
                                  child: const Text('Отмена'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogCtx, true),
                                  child: const Text('Удалить'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) async {
                          final error = await context
                              .read<ClaimsModel>()
                              .removeClaim(claim.id);
                          if (context.mounted && error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ошибка удаления: $error'),
                              ),
                            );
                          }
                        },
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            title: Text(claim.itemTitle),
                            subtitle:
                                Text('Доказательство: ${claim.proofDescription}'),
                            trailing:
                                StatusBadge.claim(claimStatus: claim.status),
                            onTap: () =>
                                context.push('/my-items/chat/${claim.id}'),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

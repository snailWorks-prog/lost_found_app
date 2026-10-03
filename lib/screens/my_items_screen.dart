import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../widgets/item_card.dart';
import '../widgets/status_badge.dart';

class MyItemsScreen extends StatelessWidget {
  const MyItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Моя активность'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Мои объявления (3)'),
              Tab(text: 'Мои заявки (2)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = mockItems[index];
                return ItemCard(
                  item: item,
                  onTap: () => context.push('/board/${item.id}'),
                );
              },
            ),
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockClaims.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final claim = mockClaims[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(claim.itemTitle),
                    subtitle: Text('Доказательство: ${claim.proofDescription}'),
                    trailing: StatusBadge.claim(claimStatus: claim.status),
                    onTap: () => context.push('/my-items/chat/${claim.id}'),
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
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/mock_lost_found_repository.dart';
import '../models/claims_model.dart';
import '../models/items_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _simulateError;

  @override
  void initState() {
    super.initState();
    _simulateError = context.read<MockLostFoundRepository>().simulateError;
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Выйти из профиля?'),
        content: const Text(
          'Вы уверены, что хотите завершить сеанс на этом устройстве?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Да, выйти'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы вышли из профиля')),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final itemsModel = context.watch<ItemsModel>();
    final claimsModel = context.watch<ClaimsModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль пользователя'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                'СГ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Семион Георгиев',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Группа TI-236 · Факультет FCIM',
              style: TextStyle(color: scheme.outline),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              color: scheme.surfaceContainerLow,
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.email_outlined),
                    title: Text('Корпоративная почта'),
                    subtitle: Text('semion.georgiev@isa.utm.md'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.phone_outlined),
                    title: Text('Телефон для связи'),
                    subtitle: Text('+373 60 123 456'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Статистика активности',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: scheme.surfaceContainerLow,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: const Text('Активных объявлений'),
                    trailing: Text(
                      '${itemsModel.activeCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Возвращено вещей'),
                    trailing: Text(
                      '${itemsModel.resolvedCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bookmark_outline),
                    title: const Text('Моих заявок'),
                    trailing: Text(
                      '${claimsModel.count}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Отладка и симуляция',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: scheme.surfaceContainerLow,
              child: SwitchListTile(
                title: const Text('Симулировать сбой сети'),
                subtitle: const Text(
                  'Запросы к Mock-репозиторию будут возвращать ошибку сети',
                ),
                secondary: Icon(
                  Icons.wifi_off_outlined,
                  color:
                      _simulateError ? scheme.error : scheme.onSurfaceVariant,
                ),
                value: _simulateError,
                onChanged: (value) {
                  setState(() {
                    _simulateError = value;
                  });
                  context.read<MockLostFoundRepository>().simulateError =
                      value;
                },
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Выйти из профиля'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
      // go: раздел с вкладками уходит из стека
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Статистика возвратов'),
                    subtitle: const Text('Найдено и возвращено: 3 вещи'),
                    trailing: Icon(Icons.verified, color: scheme.primary),
                  ),
                ],
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
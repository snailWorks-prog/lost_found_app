import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onLogout;

  const ProfileScreen({super.key, this.onLogout});

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
              onPressed: onLogout ?? () {},
              icon: const Icon(Icons.logout),
              label: const Text('Выйти из профиля'),
            ),
          ],
        ),
      ),
    );
  }
}
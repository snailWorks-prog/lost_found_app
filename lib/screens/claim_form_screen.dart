import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';

class ClaimFormScreen extends StatefulWidget {
  final String itemId;

  const ClaimFormScreen({super.key, required this.itemId});

  @override
  State<ClaimFormScreen> createState() => _ClaimFormScreenState();
}

class _ClaimFormScreenState extends State<ClaimFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _proofController = TextEditingController();

  @override
  void dispose() {
    _proofController.dispose();
    super.dispose();
  }

  void _submitClaim() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Заявка отправлена владельцу!')),
    );
    // Переход в чат по заявке
    context.pushReplacement('/my-items/chat/c1');
  }

  @override
  Widget build(BuildContext context) {
    final item = mockItems.firstWhere(
          (element) => element.id == widget.itemId,
      orElse: () => mockItems.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Подтверждение владения'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Вы заявляете права на:',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Место: ${item.location}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Доказательство владения *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _proofController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText:
                  'Опишите скрытые детали (наклейки, царапины, обои экрана, содержимое брелока)...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Опишите приметы вещи для подтверждения';
                  }
                  if (value.trim().length < 15) {
                    return 'Укажите более подробные приметы (минимум 15 символов)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Файл подтверждения прикреплён')),
                  );
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Прикрепить подтверждающее фото'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitClaim,
                child: const Text('Отправить заявку и перейти в диалог'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../models/claims_model.dart';
import '../models/items_model.dart';

class ClaimFormScreen extends StatefulWidget {
  final String itemId;

  const ClaimFormScreen({super.key, required this.itemId});

  @override
  State<ClaimFormScreen> createState() => _ClaimFormScreenState();
}

class _ClaimFormScreenState extends State<ClaimFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _proofController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _proofController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim(CampusItem? item) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final draft = CampusClaim(
      id: '0',
      itemTitle: item?.title ?? 'Предмет #${widget.itemId}',
      proofDescription: _proofController.text.trim(),
      date: 'Только что',
      status: ClaimStatus.pending,
    );

    final error = await context.read<ClaimsModel>().addClaim(draft);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка отправки заявки: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заявка отправлена владельцу!')),
      );
      context.pushReplacement('/my-items');
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsModel = context.watch<ItemsModel>();
    final item = itemsModel.byId(widget.itemId);

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
                        item?.title ?? 'Загрузка предмета...',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (item != null)
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
                enabled: !_isSubmitting,
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
                onPressed: _isSubmitting
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Файл подтверждения прикреплён'),
                          ),
                        );
                      },
                icon: const Icon(Icons.attach_file),
                label: const Text('Прикрепить подтверждающее фото'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSubmitting ? null : () => _submitClaim(item),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Отправить заявку и перейти в список'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

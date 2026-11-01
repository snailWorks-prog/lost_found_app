import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../models/items_model.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _selectedType = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final draft = CampusItem(
      id: '0',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      date: 'Только что',
      type: _selectedType == 0 ? ItemType.found : ItemType.lost,
      category: 'Разное',
    );

    final error = await context.read<ItemsModel>().addItem(draft);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Объявление добавлено: ${draft.title}')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новое объявление'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Тип объявления:'),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Я нашёл вещь')),
                  ButtonSegment(value: 1, label: Text('Я потерял вещь')),
                ],
                selected: {_selectedType},
                onSelectionChanged: _isSubmitting
                    ? null
                    : (set) => setState(() => _selectedType = set.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Название предмета *',
                  hintText: 'Напр. Пропуск в библиотеку',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Укажите название предмета';
                  }
                  if (value.trim().length < 3) {
                    return 'Название должно быть не короче 3 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                enabled: !_isSubmitting,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Место (корпус, аудитория, этаж) *',
                  hintText: 'Корпус 3, аудитория 3-215',
                  prefixIcon: Icon(Icons.place_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Укажите место обнаружения или утери';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                enabled: !_isSubmitting,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Подробное описание *',
                  hintText: 'Опишите цвет, особые приметы, где именно лежал...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Описание обязательно';
                  }
                  if (value.trim().length < 10) {
                    return 'Опишите вещь подробнее (минимум 10 символов)';
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
                            content: Text('Фото успешно прикреплено (макет)'),
                          ),
                        );
                      },
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Прикрепить фотографию'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSubmitting ? null : _save,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Опубликовать объявление'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

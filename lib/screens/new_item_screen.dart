import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Объявление добавлено: ${_titleController.text.trim()}')),
    );
    context.pop();
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
                onSelectionChanged: (set) => setState(() => _selectedType = set.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Фото успешно прикреплено (макет)')),
                  );
                },
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Прикрепить фотографию'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Text('Опубликовать объявление'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
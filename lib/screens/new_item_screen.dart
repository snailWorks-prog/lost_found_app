import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/file_api.dart';
import '../data/models.dart';

import '../data/result.dart';
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
  bool _uploadingImage = false;
  String? _uploadedImageUrl;

  static const _samplePngBytes = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _attachPhoto() async {
    setState(() => _uploadingImage = true);

    final res = await context.read<FileApi>().uploadBytes(
          _samplePngBytes,
          'item_photo.png',
        );

    if (!mounted) return;

    setState(() => _uploadingImage = false);

    switch (res) {
      case Ok(:final value):
        setState(() => _uploadedImageUrl = value);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Фото загружено на сервер: $value')),
        );
      case Err(:final msg):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки фото: $msg'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
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
      imageUrl: _uploadedImageUrl,
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
                onPressed: (_isSubmitting || _uploadingImage)
                    ? null
                    : _attachPhoto,
                icon: _uploadingImage
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _uploadedImageUrl != null
                            ? Icons.check_circle_outlined
                            : Icons.add_a_photo_outlined,
                      ),
                label: Text(
                  _uploadedImageUrl != null
                      ? 'Фото прикреплено ($_uploadedImageUrl)'
                      : 'Прикрепить фотографию',
                ),
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

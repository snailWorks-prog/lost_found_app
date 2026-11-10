import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;
  String? _imageError;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _getApiBase() {
    if (kIsWeb) return 'http://localhost:8080';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploadingImage = true;
        _imageError = null;
      });

      final bytes = await pickedFile.readAsBytes();
      if (!mounted) return;
      final fileApi = context.read<FileApi>();
      final result = await fileApi.uploadBytes(bytes, pickedFile.name);

      if (!mounted) return;

      switch (result) {
        case Ok(:final value):
          setState(() {
            _uploadedImageUrl = value;
            _isUploadingImage = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Фотография успешно загружена на сервер'),
            ),
          );
        case Err(:final msg):
          setState(() {
            _isUploadingImage = false;
            _imageError = msg;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка загрузки: $msg')),
          );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploadingImage = false;
        _imageError = 'Не удалось выбрать фото';
      });
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
              if (_isUploadingImage)
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Загрузка фотографии на сервер...'),
                      ],
                    ),
                  ),
                )
              else if (_uploadedImageUrl != null)
                Stack(
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        '${_getApiBase()}$_uploadedImageUrl',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                          child: Icon(Icons.broken_image_outlined, size: 48),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton.filled(
                        onPressed: _isSubmitting || _isUploadingImage
                            ? null
                            : () => setState(() => _uploadedImageUrl = null),
                        icon: const Icon(Icons.delete_outline),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                        tooltip: 'Удалить фото',
                      ),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: (_isSubmitting || _isUploadingImage)
                      ? null
                      : _pickAndUploadImage,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Прикрепить фотографию из галереи'),
                ),
              if (_imageError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _imageError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
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

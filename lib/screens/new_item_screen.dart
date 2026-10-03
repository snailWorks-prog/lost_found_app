import 'package:flutter/material.dart';

class NewItemScreen extends StatelessWidget {
  const NewItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новое объявление'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
              selected: const {0},
              onSelectionChanged: (_) {},
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Название предмета *',
                hintText: 'Напр. Пропуск в библиотеку',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Место (корпус, аудитория, этаж) *',
                hintText: 'Корпус 3, аудитория 3-215',
                prefixIcon: Icon(Icons.place_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Подробное описание *',
                hintText: 'Опишите цвет, особые приметы, где именно лежал...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Прикрепить фотографию'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Опубликовать объявление'),
            ),
          ],
        ),
      ),
    );
  }
}
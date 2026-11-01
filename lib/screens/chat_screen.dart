import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/claims_model.dart';
import '../widgets/error_view.dart';

class ChatScreen extends StatefulWidget {
  final String claimId;

  const ChatScreen({super.key, required this.claimId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClaimsModel>().loadMessages(widget.claimId);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    final error =
        await context.read<ClaimsModel>().sendMessage(widget.claimId, text);

    if (!mounted) return;

    setState(() => _isSending = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка отправки: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final claimsModel = context.watch<ClaimsModel>();
    final messages = claimsModel.getMessages(widget.claimId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Диалог по заявке', style: TextStyle(fontSize: 16)),
            Text(
              'Заявка #${widget.claimId}',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: scheme.surfaceContainerHighest,
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: scheme.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Договоритесь о времени и безопасном месте передачи (напр. в холле корпуса).',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (claimsModel.isLoadingMessages) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (claimsModel.messagesError != null) {
                  return ErrorView(
                    message: claimsModel.messagesError!,
                    onRetry: () => context
                        .read<ClaimsModel>()
                        .loadMessages(widget.claimId),
                  );
                }

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Сообщений пока нет. Начните диалог!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return Align(
                      alignment: msg.isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: msg.isMe
                              ? scheme.primary
                              : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                            bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: msg.isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.text,
                              style: TextStyle(
                                color: msg.isMe
                                    ? scheme.onPrimary
                                    : scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg.time,
                              style: TextStyle(
                                fontSize: 10,
                                color: msg.isMe
                                    ? scheme.onPrimary.withAlpha(180)
                                    : scheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      enabled: !_isSending,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Напишите сообщение...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

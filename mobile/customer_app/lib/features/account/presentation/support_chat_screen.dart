import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/premium.dart';

class _Message {
  const _Message(this.text, this.mine, this.at);

  final String text;
  final bool mine;
  final DateTime at;
}

/// A chat with the support team. Replies are canned until a backend exists.
/// TODO(support): connect to the support chat service.
class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_Message>[
    _Message(
      'Hello! Need a hand with something? Tell me what you need and I will '
      'help you figure it out.',
      false,
      DateTime.now(),
    ),
  ];
  bool _typing = false;
  Timer? _reply;

  @override
  void dispose() {
    _reply?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text, true, DateTime.now()));
      _typing = true;
      _input.clear();
    });
    _toEnd();
    _reply?.cancel();
    _reply = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(
          _Message(
            'Thanks for reaching out. A support agent will reply here '
            'shortly.',
            false,
            DateTime.now(),
          ),
        );
      });
      _toEnd();
    });
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 280),
          curve: premiumEase,
        );
      }
    });
  }

  String _time(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'am' : 'pm'}';
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScope(
      child: Scaffold(
        backgroundColor: AppInk.canvas,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: const PremiumTopBar(
                  title: 'HerCare support',
                  subtitle: 'We usually reply in a few minutes',
                ),
              ),
              const Divider(height: 1, color: AppInk.hairline),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  itemCount: _messages.length + (_typing ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == _messages.length) return const _Typing();
                    final m = _messages[i];
                    return _Bubble(message: m, time: _time(m.at));
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  10,
                  12,
                  10 + MediaQuery.viewInsetsOf(context).bottom * 0,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppInk.hairline)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF7F4),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _input,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _send(),
                          textInputAction: TextInputAction.send,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Enter your query...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _input.text.trim().isEmpty
                            ? const Color(0xFFFDEDE4)
                            : AppColors.lavender,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        tooltip: 'Send',
                        onPressed: _send,
                        icon: const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.time});

  final _Message message;
  final String time;

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: mine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: mine ? AppColors.lavender : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(mine ? 18 : 4),
                bottomRight: Radius.circular(mine ? 4 : 18),
              ),
              border: mine ? null : Border.all(color: AppInk.hairline),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: mine ? Colors.white : AppInk.text,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD)),
          ),
        ],
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppInk.hairline),
        ),
        child: const Text(
          '...',
          style: TextStyle(fontSize: 18, height: 0.6, color: AppInk.muted),
        ),
      ),
    );
  }
}

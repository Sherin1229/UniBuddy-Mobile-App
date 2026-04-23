import 'package:flutter/material.dart';
import 'package:unibuddy/core/theme/app_colors.dart';
import 'package:unibuddy/shared/widgets/animated_app_background.dart';

class LiveSessionRoomPage extends StatefulWidget {
  final String groupName;
  final String subject;
  final int joinedCount;
  final String sessionTitle;

  const LiveSessionRoomPage({
    super.key,
    required this.groupName,
    required this.subject,
    required this.joinedCount,
    required this.sessionTitle,
  });

  @override
  State<LiveSessionRoomPage> createState() => _LiveSessionRoomPageState();
}

enum _LiveTab { notes, resources }

class _LiveSessionRoomPageState extends State<LiveSessionRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  _LiveTab _activeTab = _LiveTab.notes;
  bool _micOn = true;
  bool _videoOn = false;
  bool _isScreenSharing = false;
  bool _handRaised = false;

  final List<_SessionNoteItem> _notes = [
    _SessionNoteItem(
      id: 'n1',
      author: 'Mei Lin',
      text:
          'Session Overview\n\nTopic: Today\'s main focus is on core concepts from our agenda.\n\n- Review key definitions\n- Solve guided problems\n- Clarify confusion points',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
  ];

  final List<_ChatMessageItem> _messages = [
    _ChatMessageItem(
      sender: 'Priya Sharma',
      message: 'Hey everyone! Ready to get started?',
      sentAt: DateTime.now().subtract(const Duration(minutes: 4)),
      isMe: false,
    ),
    _ChatMessageItem(
      sender: 'Carlos Rivera',
      message: 'I reviewed last week\'s examples, especially recursion.',
      sentAt: DateTime.now().subtract(const Duration(minutes: 3)),
      isMe: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessageItem(
          sender: 'You',
          message: text,
          sentAt: DateTime.now(),
          isMe: true,
        ),
      );
      _messageController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showNoteEditor({int? editIndex}) {
    final isEditing = editIndex != null;
    final controller = TextEditingController(
      text: isEditing ? _notes[editIndex].text : '',
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Note' : 'Add Note'),
          content: SizedBox(
            width: 560,
            child: TextField(
              controller: controller,
              minLines: 8,
              maxLines: 14,
              decoration: const InputDecoration(
                hintText: 'Write notes for this session...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                setState(() {
                  if (isEditing) {
                    _notes[editIndex] = _notes[editIndex].copyWith(
                      text: text,
                      updatedAt: DateTime.now(),
                    );
                  } else {
                    _notes.insert(
                      0,
                      _SessionNoteItem(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        author: 'You',
                        text: text,
                        updatedAt: DateTime.now(),
                      ),
                    );
                  }
                });
                Navigator.pop(dialogContext);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AnimatedAppBackground(),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  groupName: widget.groupName,
                  subject: widget.subject,
                  joinedCount: widget.joinedCount,
                  sessionTitle: widget.sessionTitle,
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 1024;

                      final content = Column(
                        children: [
                          _SessionTabs(
                            activeTab: _activeTab,
                            onChange: (tab) => setState(() => _activeTab = tab),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                12,
                                14,
                                12,
                              ),
                              child: _activeTab == _LiveTab.notes
                                  ? _NotesPanel(
                                      notes: _notes,
                                      formatTime: _formatTime,
                                      onEdit: (index) =>
                                          _showNoteEditor(editIndex: index),
                                      onAdd: _showNoteEditor,
                                    )
                                  : Center(
                                      child: Text(
                                        'Resources coming soon',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      );

                      final chat = _ChatPanel(
                        messages: _messages,
                        controller: _messageController,
                        scrollController: _chatScrollController,
                        onSend: _sendMessage,
                        formatTime: _formatTime,
                      );

                      if (compact) {
                        return Column(
                          children: [
                            Expanded(child: content),
                            Container(
                              height: 260,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: AppColors.border),
                                ),
                              ),
                              child: chat,
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: content),
                          SizedBox(width: 320, child: chat),
                        ],
                      );
                    },
                  ),
                ),
                _BottomControls(
                  micOn: _micOn,
                  videoOn: _videoOn,
                  screenSharing: _isScreenSharing,
                  handRaised: _handRaised,
                  onToggleMic: () => setState(() => _micOn = !_micOn),
                  onToggleVideo: () => setState(() => _videoOn = !_videoOn),
                  onToggleScreen: () =>
                      setState(() => _isScreenSharing = !_isScreenSharing),
                  onToggleHand: () =>
                      setState(() => _handRaised = !_handRaised),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String groupName;
  final String subject;
  final int joinedCount;
  final String sessionTitle;
  final VoidCallback onBack;

  const _TopBar({
    required this.groupName,
    required this.subject,
    required this.joinedCount,
    required this.sessionTitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.95),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, color: AppColors.success, size: 8),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 16, color: AppColors.border),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$subject • $sessionTitle',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$joinedCount joined',
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 14),
            label: const Text('Back to Group'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: BorderSide(color: AppColors.border),
              textStyle: const TextStyle(fontSize: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

class _SessionTabs extends StatelessWidget {
  final _LiveTab activeTab;
  final ValueChanged<_LiveTab> onChange;

  const _SessionTabs({required this.activeTab, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.92),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _TabButton(
            selected: activeTab == _LiveTab.notes,
            icon: Icons.note_alt_outlined,
            label: 'Shared Notes',
            onTap: () => onChange(_LiveTab.notes),
          ),
          const SizedBox(width: 8),
          _TabButton(
            selected: activeTab == _LiveTab.resources,
            icon: Icons.menu_book_outlined,
            label: 'Resources',
            onTap: () => onChange(_LiveTab.resources),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TabButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 15, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotesPanel extends StatelessWidget {
  final List<_SessionNoteItem> notes;
  final String Function(DateTime) formatTime;
  final ValueChanged<int> onEdit;
  final VoidCallback onAdd;

  const _NotesPanel({
    required this.notes,
    required this.formatTime,
    required this.onEdit,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: notes.isEmpty
                ? const Center(
                    child: Text(
                      'No notes yet. Add the first note for this session.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: notes.length,
                    separatorBuilder: (_, _) =>
                        Divider(color: AppColors.border, height: 20),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.note_alt_outlined,
                                size: 14,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'by ${note.author}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatTime(note.updatedAt),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () => onEdit(index),
                                icon: const Icon(Icons.edit, size: 13),
                                label: const Text('Edit'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.accent,
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            note.text,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Note'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: BorderSide(color: AppColors.border),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatPanel extends StatelessWidget {
  final List<_ChatMessageItem> messages;
  final TextEditingController controller;
  final ScrollController scrollController;
  final VoidCallback onSend;
  final String Function(DateTime) formatTime;

  const _ChatPanel({
    required this.messages,
    required this.controller,
    required this.scrollController,
    required this.onSend,
    required this.formatTime,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.92),
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.forum_outlined,
                  color: AppColors.textPrimary,
                  size: 17,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Session Chat',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${messages.length} messages',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final m = messages[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: m.isMe
                          ? AppColors.accent
                          : AppColors.primaryBrand,
                      child: Text(
                        _initials(m.sender),
                        style: const TextStyle(
                          color: AppColors.textOnDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                m.sender,
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formatTime(m.sentAt),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              m.message,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => onSend(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Send a message...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onSend,
                  icon: const Icon(
                    Icons.send,
                    size: 16,
                    color: AppColors.textOnDark,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size(30, 30),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final bool micOn;
  final bool videoOn;
  final bool screenSharing;
  final bool handRaised;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleScreen;
  final VoidCallback onToggleHand;

  const _BottomControls({
    required this.micOn,
    required this.videoOn,
    required this.screenSharing,
    required this.handRaised,
    required this.onToggleMic,
    required this.onToggleVideo,
    required this.onToggleScreen,
    required this.onToggleHand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Center(
        child: Wrap(
          spacing: 8,
          children: [
            _BottomAction(
              icon: micOn ? Icons.mic : Icons.mic_off,
              text: micOn ? 'Mic On' : 'Mic Off',
              active: micOn,
              onTap: onToggleMic,
            ),
            _BottomAction(
              icon: videoOn ? Icons.videocam : Icons.videocam_off,
              text: videoOn ? 'Video On' : 'Video Off',
              active: videoOn,
              onTap: onToggleVideo,
            ),
            _BottomAction(
              icon: Icons.screen_share,
              text: screenSharing ? 'Sharing' : 'Share Screen',
              active: screenSharing,
              onTap: onToggleScreen,
            ),
            _BottomAction(
              icon: Icons.back_hand_outlined,
              text: handRaised ? 'Hand Raised' : 'Raise Hand',
              active: handRaised,
              onTap: onToggleHand,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _BottomAction({
    required this.icon,
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active ? AppColors.accent : AppColors.backgroundLight;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textPrimary),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionNoteItem {
  final String id;
  final String author;
  final String text;
  final DateTime updatedAt;

  const _SessionNoteItem({
    required this.id,
    required this.author,
    required this.text,
    required this.updatedAt,
  });

  _SessionNoteItem copyWith({
    String? author,
    String? text,
    DateTime? updatedAt,
  }) {
    return _SessionNoteItem(
      id: id,
      author: author ?? this.author,
      text: text ?? this.text,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class _ChatMessageItem {
  final String sender;
  final String message;
  final DateTime sentAt;
  final bool isMe;

  const _ChatMessageItem({
    required this.sender,
    required this.message,
    required this.sentAt,
    required this.isMe,
  });
}

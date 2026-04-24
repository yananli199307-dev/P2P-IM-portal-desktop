import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/group.dart';
import '../services/api_service.dart';

class GroupMessage {
  final int id;
  final String content;
  final String senderName;
  final bool isFromOwner;
  final DateTime createdAt;
  final String? fileUrl;
  final String? fileName;
  final String messageType;

  GroupMessage({
    required this.id,
    required this.content,
    required this.senderName,
    required this.isFromOwner,
    required this.createdAt,
    this.fileUrl,
    this.fileName,
    this.messageType = 'text',
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json['id'],
      content: json['content'] ?? '',
      senderName: json['sender_name'] ?? 'Unknown',
      isFromOwner: json['is_from_owner'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      messageType: json['message_type'] ?? 'text',
    );
  }
}

class GroupChatScreen extends StatefulWidget {
  final Group group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<GroupMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      List<Map<String, dynamic>> messagesData;
      if (widget.group.isOwner) {
        messagesData = await ApiService().getGroupMessages(widget.group.id);
      } else {
        messagesData = await ApiService().getGroupMessagesByUuid(widget.group.groupUuid!);
      }
      setState(() {
        _messages = messagesData.map((m) => GroupMessage.fromJson(m)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    try {
      await ApiService().sendGroupMessage(widget.group.id, content);
      _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送失败: $e')),
      );
    }
  }

  Future<void> _sendFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final path = result.files.single.path;
    if (path == null) return;

    try {
      await ApiService().sendGroupFileMessage(widget.group.id, path);
      _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送文件失败: $e')),
      );
    }
  }

  void _showGroupSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('群成员'),
            onTap: () {
              Navigator.pop(context);
              _showMembersDialog();
            },
          ),
          if (widget.group.isOwner) ...[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('修改群名'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('解散群组', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDissolveDialog();
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('退出群组', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showLeaveDialog();
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showMembersDialog() {
    // TODO: 显示群成员列表
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: widget.group.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改群名'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ApiService().updateGroupName(widget.group.id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDissolveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('解散群组'),
        content: const Text('确定要解散这个群组吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ApiService().dissolveGroup(widget.group.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('解散'),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出群组'),
        content: const Text('确定要退出这个群组吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ApiService().leaveGroup(widget.group.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.group.name),
              Text(
                widget.group.isOwner ? '群主' : '成员',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showGroupSettings,
            ),
          ],
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageItem(message);
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _sendFile,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: '输入消息...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(GroupMessage message) {
    final isMe = message.isFromOwner;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.senderName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            Text(message.content),
          ],
        ),
      ),
    );
  }
}

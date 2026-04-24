import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/group.dart';
import 'group_chat_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  List<Group> _groups = [];
  bool _isLoading = true;
  Group? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final groupsData = await ApiService().getGroups();
      setState(() {
        _groups = groupsData.map((g) => Group.fromJson(g)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建群组'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: '群组名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ApiService().createGroup(nameController.text);
                Navigator.pop(context);
                _loadGroups();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('创建失败: $e')),
                );
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左侧群组列表
        SizedBox(
          width: 300,
          child: Column(
            children: [
              AppBar(
                title: const Text('群组'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showCreateGroupDialog,
                  ),
                ],
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _groups.length,
                        itemBuilder: (context, index) {
                          final group = _groups[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(group.name[0].toUpperCase()),
                            ),
                            title: Text(group.name),
                            subtitle: group.isOwner 
                                ? const Text('群主', style: TextStyle(color: Colors.blue))
                                : const Text('成员'),
                            selected: _selectedGroup?.id == group.id,
                            onTap: () {
                              setState(() {
                                _selectedGroup = group;
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // 右侧聊天区域
        Expanded(
          child: _selectedGroup == null
              ? const Center(child: Text('请选择群组'))
              : GroupChatScreen(group: _selectedGroup!),
        ),
      ],
    );
  }
}

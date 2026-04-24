import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/contact.dart';
import 'chat_detail_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];
  bool _isLoading = true;
  Contact? _selectedContact;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await ApiService().getContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左侧联系人列表
        SizedBox(
          width: 300,
          child: Column(
            children: [
              AppBar(
                title: const Text('联系人'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // 添加联系人
                    },
                  ),
                ],
              ),
              // My Agent 入口
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text('🤖'),
                ),
                title: const Text('My Agent'),
                subtitle: const Text('AI 助手'),
                selected: _selectedContact == null,
                onTap: () {
                  setState(() {
                    _selectedContact = null;
                  });
                },
              ),
              const Divider(),
              // 联系人列表
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final contact = _contacts[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(contact.displayName[0].toUpperCase()),
                            ),
                            title: Text(contact.displayName),
                            subtitle: Text(contact.portalUrl),
                            selected: _selectedContact?.id == contact.id,
                            onTap: () {
                              setState(() {
                                _selectedContact = contact;
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
          child: _selectedContact == null
              ? const Center(child: Text('请选择联系人'))
              : ChatDetailScreen(contact: _selectedContact!),
        ),
      ],
    );
  }
}

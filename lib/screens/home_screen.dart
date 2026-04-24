import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import 'contacts_screen.dart';
import 'chat_screen.dart';
import 'groups_screen.dart';
import 'agent_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  int _selectedIndex = 0;
  final WebSocketService _wsService = WebSocketService();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initWebSocket();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _wsService.disconnect();
    super.dispose();
  }

  Future<void> _initWebSocket() async {
    final token = await ApiService().getToken();
    final portalUrl = await ApiService().getPortalUrl();
    
    if (token != null && portalUrl != null) {
      await _wsService.connect(
        baseUrl: portalUrl,
        token: token,
        onConnect: () {
          setState(() {
            _isConnected = true;
          });
        },
        onDisconnect: () {
          setState(() {
            _isConnected = false;
          });
        },
      );
    }
  }

  @override
  void onWindowClose() async {
    // 最小化到托盘而不是关闭
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ContactsScreen(),
      const ChatScreen(),
      const GroupsScreen(),
      const AgentChatScreen(),
    ];

    final destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.contacts_outlined),
        selectedIcon: Icon(Icons.contacts),
        label: Text('联系人'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.chat_outlined),
        selectedIcon: Icon(Icons.chat),
        label: Text('消息'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.group_outlined),
        selectedIcon: Icon(Icons.group),
        label: Text('群组'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.smart_toy_outlined),
        selectedIcon: Icon(Icons.smart_toy),
        label: Text('Agent'),
      ),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: destinations,
            trailing: IconButton(
              icon: Icon(
                _isConnected ? Icons.circle : Icons.circle_outlined,
                color: _isConnected ? Colors.green : Colors.red,
                size: 12,
              ),
              onPressed: () {},
              tooltip: _isConnected ? '已连接' : '未连接',
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

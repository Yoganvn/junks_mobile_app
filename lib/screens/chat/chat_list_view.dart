import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../models/chat_item.dart';
import 'chat_detail_view.dart'; // Nanti dibuat di langkah 4

class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final ProductService _productService = ProductService();
  List<ChatItem> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    final data = await _productService.getChats();
    if (mounted) {
      setState(() {
        _chats = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Inbox", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.mark_chat_read_outlined, color: Colors.black), onPressed: () {})
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF222222)))
          : ListView.separated(
              itemCount: _chats.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(chat.avatarUrl),
                      ),
                      if (chat.unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          ),
                        ),
                    ],
                  ),
                  title: Text(chat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(
                    chat.message, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: chat.unreadCount > 0 ? Colors.black87 : Colors.grey, fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(chat.time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      if (chat.unreadCount > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF222222), borderRadius: BorderRadius.circular(10)),
                          child: Text(chat.unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                        )
                      ]
                    ],
                  ),
                  onTap: () {
                    // Masuk ke Room Chat
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailView(name: chat.name)));
                  },
                );
              },
            ),
    );
  }
}
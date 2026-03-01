import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healtime_app/models/auth_provider.dart';
import 'package:healtime_app/models/doctor.dart';
import 'package:healtime_app/utils/api_service.dart';
import 'package:healtime_app/widgets/safe_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<dynamic> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    final auth = context.read<AuthProvider>();
    if (auth.userId == null) return;

    try {
      final contacts = await ApiService.getChatContacts(auth.userId!);
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error fetching chat contacts: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return DateFormat('hh:mm a').format(date);
      } else if (date.year == now.year &&
          date.month == now.month &&
          (now.day - date.day) == 1) {
        return 'Yesterday';
      } else {
        return DateFormat('MM/dd/yy').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              final isDoctor =
                  context.read<AuthProvider>().role == UserRole.doctor;
              context.go(isDoctor ? '/doctor-dashboard' : '/patient-dashboard');
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
          ? const Center(child: Text('No messages yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _contacts.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return ListTile(
                  leading: SafeImageWidget(
                    image: contact['imageUrl'],
                    width: 56,
                    height: 56,
                    borderRadius: 28,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    contact['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (contact['role'] == 'doctor' &&
                          contact['specialty'] != null) ...[
                        Text(
                          contact['specialty'],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      Text(
                        contact['lastMessage'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(contact['timestamp'] ?? ''),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(
                        Symbols.chevron_right,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () {
                    // Create a dummy Doctor object to pass to the ChatScreen
                    // The ChatScreen only really needs the peerId and peerName.
                    final dummyDoc = Doctor(
                      id: contact['id'] ?? '',
                      name: contact['name'] ?? 'Unknown',
                      specialty: contact['specialty'] ?? '',
                      clinic: '',
                      imageUrl: contact['imageUrl'] ?? '',
                      rating: 0,
                      reviews: 0,
                      experience: 0,
                      nextAvailable: '',
                    );
                    context.push('/chat-room', extra: dummyDoc).then((_) {
                      // Refresh when returning back to this screen
                      _fetchContacts();
                    });
                  },
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math';

class FriendsTab extends StatefulWidget {
  const FriendsTab({Key? key}) : super(key: key);

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  int _selectedTab = 0; // 0 = Friends List, 1 = Requests

  final List<Map<String, String>> _statusUsers = [
    {
      'name': 'Sophia',
      'avatar': 'https://randomuser.me/api/portraits/women/1.jpg',
    },
    {
      'name': 'Ethan',
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Olivia',
      'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {'name': 'Noah', 'avatar': 'https://randomuser.me/api/portraits/men/2.jpg'},
    {
      'name': 'Ava',
      'avatar': 'https://randomuser.me/api/portraits/women/3.jpg',
    },
  ];

  final List<Map<String, String>> _friends = [
    {
      'name': 'Liam',
      'avatar': 'https://randomuser.me/api/portraits/men/3.jpg',
      'active': 'Active 2h ago',
    },
    {
      'name': 'Chloe',
      'avatar': 'https://randomuser.me/api/portraits/women/4.jpg',
      'active': 'Active 1d ago',
    },
    {
      'name': 'Jackson',
      'avatar': 'https://randomuser.me/api/portraits/men/4.jpg',
      'active': 'Active 30m ago',
    },
    {
      'name': 'Isabella',
      'avatar': 'https://randomuser.me/api/portraits/women/5.jpg',
      'active': 'Active 1h ago',
    },
  ];

  // Mock requests count
  final int requestsCount = 3;

  @override
  Widget build(BuildContext context) {
    // Sample fitness images (replace with video URLs if using video_player)
    final List<String> fitnessImages = [
      'https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg',
      'https://images.pexels.com/photos/414029/pexels-photo-414029.jpeg',
      'https://images.pexels.com/photos/2780761/pexels-photo-2780761.jpeg',
      'https://images.pexels.com/photos/2261482/pexels-photo-2261482.jpeg',
      'https://images.pexels.com/photos/1552106/pexels-photo-1552106.jpeg',
    ];
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Text(
                'Friends',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.black,
                ),
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    SizedBox(width: 12),
                    Icon(Icons.search, color: Colors.black38),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Manrope',
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: Colors.black38,
                            fontFamily: 'Manrope',
                          ),
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _FriendsTabButton(
                      label: 'Friends List',
                      selected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                    _FriendsTabButton(
                      label: 'Requests',
                      selected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            if (_selectedTab == 0) ...[
              // Status section
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                child: const Text(
                  'Status',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _statusUsers.length + 1,
                  separatorBuilder: (context, i) => const SizedBox(width: 16),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      // Add status card
                      return _AddStatusCard();
                    }
                    final user = _statusUsers[i - 1];
                    final random = Random(user['name']!.hashCode);
                    final imageUrl = fitnessImages[random.nextInt(fitnessImages.length)];
                    return _StatusCard(
                      name: user['name']!,
                      avatar: user['avatar']!,
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.95),
                          builder: (context) {
                            return _StatusViewer(
                              avatar: user['avatar']!,
                              name: user['name']!,
                              time: 'Today, 2:58 pm',
                              imageUrl: imageUrl,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              // Friends section
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
                child: const Text(
                  'Friends',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: _friends.length,
                  separatorBuilder: (context, i) => const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  itemBuilder: (context, i) {
                    final friend = _friends[i];
                    return _FriendListTile(
                      name: friend['name']!,
                      avatar: friend['avatar']!,
                      active: friend['active']!,
                    );
                  },
                ),
              ),
            ] else ...[
              // Requests tab placeholder
              const Expanded(
                child: Center(
                  child: Text(
                    'No requests',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      color: Colors.black38,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FriendsTabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FriendsTabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: selected ? Colors.black : Colors.black54,
                  ),
                ),
              ),
            ),
            if (label == 'Requests' && (context.findAncestorStateOfType<_FriendsTabState>()?.requestsCount ?? 0) > 0)
              Positioned(
                top: 6,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Text(
                    '${context.findAncestorStateOfType<_FriendsTabState>()?.requestsCount ?? 0}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/10.jpg'),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Add status',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String name;
  final String avatar;
  final VoidCallback? onTap;
  const _StatusCard({required this.name, required this.avatar, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 3),
              ),
              child: CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(avatar),
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusViewer extends StatelessWidget {
  final String avatar;
  final String name;
  final String time;
  final String imageUrl;
  const _StatusViewer({required this.avatar, required this.name, required this.time, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 24,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(avatar),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
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

class _FriendListTile extends StatelessWidget {
  final String name;
  final String avatar;
  final String active;
  const _FriendListTile({required this.name, required this.avatar, required this.active});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(avatar, width: 48, height: 48, fit: BoxFit.cover),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        active,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      horizontalTitleGap: 16,
      minLeadingWidth: 0,
    );
  }
}

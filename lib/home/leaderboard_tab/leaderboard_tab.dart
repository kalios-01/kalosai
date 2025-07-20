import 'package:flutter/material.dart';

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({Key? key}) : super(key: key);

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  int _selectedTab = 1; // 0 = Global, 1 = Friends

  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Ethan',
      'score': 12345,
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
      'isYou': true,
    },
    {
      'name': 'Noah',
      'score': 11223,
      'avatar': 'https://randomuser.me/api/portraits/men/2.jpg',
    },
    {
      'name': 'Liam',
      'score': 10111,
      'avatar': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
    {
      'name': 'Oliver',
      'score': 9999,
      'avatar': 'https://randomuser.me/api/portraits/men/4.jpg',
    },
    {
      'name': 'Elijah',
      'score': 8888,
      'avatar': 'https://randomuser.me/api/portraits/men/5.jpg',
    },
    {
      'name': 'Lucas',
      'score': 7777,
      'avatar': 'https://randomuser.me/api/portraits/men/6.jpg',
    },
    {
      'name': 'Mason',
      'score': 6666,
      'avatar': 'https://randomuser.me/api/portraits/men/7.jpg',
    },
    {
      'name': 'Logan',
      'score': 5555,
      'avatar': 'https://randomuser.me/api/portraits/men/8.jpg',
    },
  ];

  final List<Map<String, dynamic>> _friendsLeaderboard = [
    {
      'name': 'Ethan',
      'score': 12345,
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
      'isYou': true,
    },
    {
      'name': 'Noah',
      'score': 11223,
      'avatar': 'https://randomuser.me/api/portraits/men/2.jpg',
    },
    {
      'name': 'Liam',
      'score': 10111,
      'avatar': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
    {
      'name': 'Chloe',
      'score': 9000,
      'avatar': 'https://randomuser.me/api/portraits/women/4.jpg',
    },
    {
      'name': 'Isabella',
      'score': 8500,
      'avatar': 'https://randomuser.me/api/portraits/women/5.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: const Text(
              'Leaderboard',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.black,
              ),
            ),
          ),
          // Segmented control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _LeaderboardTabButton(
                    label: 'Global',
                    selected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  _LeaderboardTabButton(
                    label: 'Friends',
                    selected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Leaderboard list
          Expanded(
            child: Builder(
              builder: (context) {
                final list = _selectedTab == 0
                    ? _users
                    : (_friendsLeaderboard..sort((a, b) => b['score'].compareTo(a['score'])));
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  itemCount: list.length,
                  separatorBuilder: (context, i) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  itemBuilder: (context, i) {
                    final user = list[i];
                    return _LeaderboardListTile(
                      rank: i + 1,
                      name: user['name'],
                      score: user['score'],
                      avatar: user['avatar'],
                      isYou: user['isYou'] ?? false,
                      onTap: _selectedTab == 0 && !(user['isYou'] ?? false)
                          ? () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 48,
                                            backgroundImage: NetworkImage(user['avatar']),
                                            backgroundColor: const Color(0xFFF3F4F6),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            user['name'],
                                            style: const TextStyle(
                                              fontFamily: 'Manrope',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '@${user['name'].toString().toLowerCase()}',
                                            style: const TextStyle(
                                              fontFamily: 'Manrope',
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                textStyle: const TextStyle(
                                                  fontFamily: 'Manrope',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              child: const Text('Add Friend'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LeaderboardTabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
      ),
    );
  }
}

class _LeaderboardListTile extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final String avatar;
  final bool isYou;
  final VoidCallback? onTap;
  const _LeaderboardListTile({required this.rank, required this.name, required this.score, required this.avatar, this.isYou = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget? medal;
    if (rank == 1) {
      medal = const _MedalIcon(icon: Icons.emoji_events, color: Color(0xFFFFC700));
    } else if (rank == 2) {
      medal = const _MedalIcon(icon: Icons.emoji_events, color: Color(0xFFD1D5DB));
    } else if (rank == 3) {
      medal = const _MedalIcon(icon: Icons.emoji_events, color: Color(0xFFF97316));
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text(
              '$rank',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: rank <= 3 ? Colors.black : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 8),
            Stack(
              alignment: Alignment.topLeft,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(avatar),
                  backgroundColor: const Color(0xFFF3F4F6),
                ),
                if (medal != null)
                  Positioned(
                    left: -8,
                    top: -8,
                    child: medal,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  if (isYou)
                    const Text(
                      'You',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              score.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ','),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedalIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _MedalIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color, size: 28);
  }
} 
import 'package:flutter/material.dart';

void main() => runApp(const KingLive());

class C {
  static const black = Color(0xFF060604);
  static const panel = Color(0xFF151109);
  static const gold = Color(0xFFD6A71E);
  static const bright = Color(0xFFFFD86B);
  static const ivory = Color(0xFFFFF7E4);
  static const muted = Color(0xFFB9AE96);
  static const red = Color(0xFFA51018);
  static const green = Color(0xFF2BCB8B);
}

class KingLive extends StatelessWidget {
  const KingLive({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'KING LIVE',
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: C.black,
          colorScheme: ColorScheme.fromSeed(
            seedColor: C.gold,
            brightness: Brightness.dark,
            primary: C.gold,
            secondary: C.bright,
            surface: C.panel,
          ),
        ),
        home: const Intro(),
      );
}

class Bg extends StatelessWidget {
  const Bg({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050403), Color(0xFF251503), Color(0xFF050403)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -100,
              left: -100,
              child: glow(320),
            ),
            Positioned(
              bottom: -140,
              right: -100,
              child: glow(380),
            ),
            SafeArea(child: child),
          ],
        ),
      );

  Widget glow(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [C.gold.withValues(alpha: .20), Colors.transparent],
          ),
        ),
      );
}

class Intro extends StatelessWidget {
  const Intro({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Bg(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: RoyalCard(
                gold: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.workspace_premium, size: 78, color: C.bright),
                    const SizedBox(height: 12),
                    const Text('KING LIVE', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
                    const SizedBox(height: 8),
                    const Text('Royal live streaming • dating • games • PK battles • gifts', textAlign: TextAlign.center, style: TextStyle(color: C.muted, height: 1.45)),
                    const SizedBox(height: 18),
                    const Text('18+ only', style: TextStyle(color: C.bright, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: GoldButton(
                        text: 'Enter with demo Google account',
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Shell())),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  final pages = const [Home(), Ranking(), Messages(), Profile()];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: index, children: pages),
        bottomNavigationBar: Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              nav(Icons.home_rounded, 'Home', 0),
              nav(Icons.emoji_events_outlined, 'Ranks', 1),
              Expanded(
                child: Center(
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoLive())),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [C.bright, C.gold]),
                      ),
                      child: const Icon(Icons.add, color: Colors.black, size: 34),
                    ),
                  ),
                ),
              ),
              nav(Icons.chat_bubble_outline, 'Messages', 2),
              nav(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      );

  Widget nav(IconData icon, String label, int i) => Expanded(
        child: InkWell(
          onTap: () => setState(() => index = i),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: index == i ? C.bright : C.muted),
              Text(label, style: TextStyle(fontSize: 10, color: index == i ? C.bright : C.muted)),
            ],
          ),
        ),
      );
}

class Home extends StatelessWidget {
  const Home({super.key});
  static const rooms = [
    ('Ayesha Queen', 'Good vibes only ✨', 'AQ', '1.2K'),
    ('Ali Gaming', 'Rank Push Live 🚀', 'AG', '1.1K'),
    ('Maya Official', 'Let’s chat 💬', 'MO', '940'),
    ('Hamza Jutt', 'Late Night Talks 🌙', 'HJ', '860'),
  ];

  @override
  Widget build(BuildContext context) => Bg(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.search),
                        const Spacer(),
                        const Text('KING LIVE', style: TextStyle(color: C.bright, fontSize: 27, fontWeight: FontWeight.w900)),
                        const Spacer(),
                        IconButton(onPressed: () => info(context, 'Notifications', '🎁 Gift received\n👤 New follower\n⚔ PK invite'), icon: const Icon(Icons.notifications_none)),
                      ],
                    ),
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [Pill('Popular', true), Pill('Following', false), Pill('Nearby', false), Pill('New', false), Pill('PK', false)]),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(14),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: rooms.length,
                itemBuilder: (_, i) {
                  final r = rooms[i];
                  return InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LiveRoom(name: r.$1, initials: r.$3, host: false))),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: C.gold.withValues(alpha: .55)),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [i.isEven ? const Color(0xFF5A1117) : const Color(0xFF12331E), const Color(0xFF090806)],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(child: Avatar(r.$3, 70)),
                          Positioned(left: 8, top: 8, child: tag('LIVE')),
                          Positioned(right: 8, top: 10, child: Text('◉ ${r.$4}')),
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.$1, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                                Text(r.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: RoyalCard(
                  gold: true,
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium, color: C.bright, size: 48),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Be a Star!\nGo live, receive gifts and grow your royal rank.', style: TextStyle(height: 1.45))),
                      GoldButton(text: 'Go Live', compact: true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoLive()))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class LiveRoom extends StatefulWidget {
  const LiveRoom({super.key, required this.name, required this.initials, required this.host});
  final String name;
  final String initials;
  final bool host;
  @override
  State<LiveRoom> createState() => _LiveRoomState();
}

class _LiveRoomState extends State<LiveRoom> {
  final feed = <String>['viewer22: 🔥🔥🔥', 'aliZ: welcome back!', 'Maya: amazing room 👑'];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Bg(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    tag('👁 3.4k'),
                    const Spacer(),
                    if (widget.host)
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: C.red),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('End Live'),
                      )
                    else
                      GoldButton(text: '+ Follow', compact: true, onTap: () {}),
                  ],
                ),
              ),
              if (widget.host)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  color: const Color(0xFFE85420),
                  child: const Text('⚠ Host not visible — return within 30s', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Avatar(widget.initials, 96),
                    const SizedBox(height: 12),
                    Text(widget.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                    const Text('👑 Royal Room', style: TextStyle(color: C.bright, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: feed.take(3).map((text) => Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: .70), borderRadius: BorderRadius.circular(18)),
                      child: Text(text, style: const TextStyle(fontSize: 12)),
                    )).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 5, 8, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    action(Icons.mic_none, () {}),
                    action(Icons.camera_alt_outlined, () {}),
                    action(Icons.auto_awesome, gifts),
                    action(Icons.emoji_emotions_outlined, () {}),
                    action(Icons.sports_kabaddi_outlined, () => info(context, 'PK Challenge', 'Invite another host for a timed battle. Gifts determine the score.')),
                    action(Icons.more_horiz, () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget action(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: .75), border: Border.all(color: C.gold.withValues(alpha: .5))),
          child: Icon(icon),
        ),
      );

  void gifts() {
    const gifts = ['🌹 10', '💛 120', '✈️ 6999', '👑 7999', '🏎️ 8999', '🦁 9999'];
    showModalBottomSheet(
      context: context,
      backgroundColor: C.panel,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Send a Royal Gift', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: gifts.map((gift) => InkWell(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => feed.insert(0, 'You sent $gift'));
                },
                child: RoyalCard(child: Text(gift, style: const TextStyle(fontSize: 20))),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class GoLive extends StatelessWidget {
  const GoLive({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Go Live')),
        body: Bg(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const RoyalCard(
                gold: true,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.camera_alt_outlined, size: 48, color: C.bright), Text('Upload Cover'), Text('16:9 recommended', style: TextStyle(color: C.muted))])),
                ),
              ),
              const SizedBox(height: 14),
              const TextField(decoration: InputDecoration(labelText: 'Room title', filled: true)),
              const SizedBox(height: 10),
              const TextField(decoration: InputDecoration(labelText: 'Category', hintText: 'Chat / Dating / Gaming / Challenges', filled: true)),
              const SizedBox(height: 12),
              const RoyalCard(child: Text('🛡 Moderation ON • Comments ON • Followers All')),
              const SizedBox(height: 16),
              GoldButton(text: 'Start Live', onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LiveRoom(name: 'King Host', initials: 'KH', host: true)))),
            ],
          ),
        ),
      );
}

class Ranking extends StatelessWidget {
  const Ranking({super.key});
  @override
  Widget build(BuildContext context) => Bg(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Leaderboard', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            const SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [Pill('Top Sender', true), Pill('Top Host', false), Pill('Top Agency', false), Pill('Top PK Host', false)])),
            const SizedBox(height: 10),
            const Row(children: [Pill('Daily', true), Pill('Weekly', false), Pill('Monthly', false)]),
            const SizedBox(height: 24),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [podium('Ayesha', 'AQ', '🥈', 100), podium('Zayn', 'Z', '🥇', 145), podium('Bilal', 'B', '🥉', 86)]),
            const SizedBox(height: 16),
            for (var i = 4; i <= 8; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RoyalCard(
                  child: Row(children: [Text('#$i', style: const TextStyle(color: C.bright, fontWeight: FontWeight.w900)), const SizedBox(width: 12), Expanded(child: Text('Host_$i')), Text('${30 - i * 2}k', style: const TextStyle(color: C.bright, fontWeight: FontWeight.w900))]),
                ),
              ),
          ],
        ),
      );

  Widget podium(String name, String initials, String medal, double height) => Expanded(
        child: Column(
          children: [
            Avatar(initials, 42),
            const SizedBox(height: 6),
            Text(name),
            Container(
              height: height,
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(18)), gradient: LinearGradient(colors: [C.bright, C.gold])),
              child: Center(child: Text(medal, style: const TextStyle(fontSize: 31))),
            ),
          ],
        ),
      );
}

class Messages extends StatelessWidget {
  const Messages({super.key});
  @override
  Widget build(BuildContext context) {
    const rows = [('AQ', 'Ayesha Queen', 'Sent a gift 👑 King Crown'), ('AG', 'Ali Gaming', 'See you live tonight!'), ('MO', 'Maya Official', 'Thanks for the follow!'), ('HJ', 'Hamza Jutt', 'Typing…')];
    return Bg(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Messages', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: RoyalCard(
                child: Row(children: [Avatar(row.$1, 28), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(row.$2, style: const TextStyle(fontWeight: FontWeight.w900)), Text(row.$3, style: const TextStyle(color: C.muted))])), const Icon(Icons.chevron_right, color: C.gold)]),
              ),
            ),
        ],
      ),
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) => Bg(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(child: Avatar('AQ', 68)),
            const SizedBox(height: 10),
            const Center(child: Text('Ayesha Queen', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900))),
            const Center(child: Text('@ayesha_q', style: TextStyle(color: C.muted))),
            const SizedBox(height: 10),
            const Center(child: Pill('Lv.68  👑 VIP 1', true)),
            const SizedBox(height: 16),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Metric('302', 'Following'), Metric('18.4K', 'Followers')]),
            const SizedBox(height: 14),
            const RoyalCard(child: Text('About Me\n\nLive with passion, laugh with heart. Royal creator, PK fan and challenge lover.', style: TextStyle(height: 1.5))),
            const SizedBox(height: 10),
            option(context, Icons.account_balance_wallet_outlined, 'Wallet', const Wallet()),
            option(context, Icons.groups_2_outlined, 'Agencies', const Agencies()),
            option(context, Icons.palette_outlined, 'Royal Themes', const Themes()),
            option(context, Icons.shield_outlined, 'Privacy & Safety', null),
          ],
        ),
      );
}

class Wallet extends StatelessWidget {
  const Wallet({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Wallet')),
        body: Bg(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const RoyalCard(gold: true, child: Column(children: [Text('Coin Balance', style: TextStyle(color: C.muted)), Text('12,450', style: TextStyle(fontSize: 42, color: C.bright, fontWeight: FontWeight.w900)), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Metric('3,200', 'Diamonds'), Metric('890', 'Beans')])])),
              const SizedBox(height: 12),
              Row(children: [Expanded(child: GoldButton(text: 'Recharge', onTap: () => info(context, 'Recharge', '1,000 coins — Rs 250\n5,000 coins — Rs 1,200\n12,000 coins — Rs 2,800\n30,000 coins — Rs 6,500'))), const SizedBox(width: 8), Expanded(child: GoldButton(text: 'Withdraw', onTap: () => info(context, 'Withdraw', '890 Beans ≈ Rs 44,500\nBank Transfer • JazzCash • Easypaisa')))]),
              const SizedBox(height: 16),
              const Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              transaction('Recharge', '+5,000', C.green),
              transaction('Gift sent', '-1,200', C.red),
              transaction('Withdrawal', '-3,000', C.red),
              transaction('Gift received', '+850', C.green),
            ],
          ),
        ),
      );
}

class Agencies extends StatelessWidget {
  const Agencies({super.key});
  @override
  Widget build(BuildContext context) {
    const rows = [('Grafixers Agency', '124 hosts • ⭐ 4.9 • Verified'), ('Royal Streamers', '42 hosts • ⭐ 4.8 • Elite'), ('Rising Stars', '86 hosts • ⭐ 4.8 • Top'), ('Velvet Circle', '57 hosts • ⭐ 4.7 • Open')];
    return Scaffold(
      appBar: AppBar(title: const Text('Agency List')),
      body: Bg(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search agencies', filled: true)),
            const SizedBox(height: 12),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: RoyalCard(
                  child: Row(children: [const CircleAvatar(backgroundColor: Color(0x332C240C), child: Icon(Icons.apartment, color: C.bright)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(row.$1, style: const TextStyle(fontWeight: FontWeight.w900)), Text(row.$2, style: const TextStyle(color: C.muted))])), GoldButton(text: 'Join', compact: true, onTap: () {})]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Themes extends StatelessWidget {
  const Themes({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Theme')),
        body: const Bg(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              RoyalCard(gold: true, child: ListTile(leading: Icon(Icons.castle, color: C.bright), title: Text('Royal Palace'), subtitle: Text('Gold • crimson • emerald ambience'))),
              SizedBox(height: 10),
              RoyalCard(child: ListTile(leading: Icon(Icons.dark_mode, color: C.bright), title: Text('Obsidian Gold'), subtitle: Text('Black and gold high contrast'))),
              SizedBox(height: 10),
              RoyalCard(child: ListTile(leading: Icon(Icons.workspace_premium, color: C.bright), title: Text('Crimson Crown'), subtitle: Text('Royal red and gold treatment'))),
            ],
          ),
        ),
      );
}

class RoyalCard extends StatelessWidget {
  const RoyalCard({super.key, required this.child, this.gold = false});
  final Widget child;
  final bool gold;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .68),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: (gold ? C.bright : C.gold).withValues(alpha: .55)),
          boxShadow: [BoxShadow(color: C.gold.withValues(alpha: .08), blurRadius: 18)],
        ),
        child: child,
      );
}

class GoldButton extends StatelessWidget {
  const GoldButton({super.key, required this.text, required this.onTap, this.compact = false});
  final String text;
  final VoidCallback onTap;
  final bool compact;
  @override
  Widget build(BuildContext context) => Container(
        height: compact ? 42 : 52,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [C.bright, C.gold]), borderRadius: BorderRadius.circular(16)),
        child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.black, shadowColor: Colors.transparent),
          onPressed: onTap,
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
      );
}

class Pill extends StatelessWidget {
  const Pill(this.text, this.selected, {super.key});
  final String text;
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(right: 7),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(color: selected ? C.gold : Colors.black.withValues(alpha: .70), borderRadius: BorderRadius.circular(25), border: Border.all(color: C.gold.withValues(alpha: .4))),
        child: Text(text, style: TextStyle(color: selected ? Colors.black : C.ivory, fontWeight: FontWeight.w800)),
      );
}

class Avatar extends StatelessWidget {
  const Avatar(this.initials, this.radius, {super.key});
  final String initials;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
        width: radius * 2,
        height: radius * 2,
        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [C.bright, C.red])),
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF17120B)),
          child: Center(child: Text(initials, style: TextStyle(fontSize: radius * .48, color: C.bright, fontWeight: FontWeight.w900))),
        ),
      );
}

class Metric extends StatelessWidget {
  const Metric(this.value, this.label, {super.key});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: C.muted))]);
}

Widget option(BuildContext context, IconData icon, String label, Widget? page) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: page == null ? () => info(context, label, 'Privacy, blocked users, reporting and moderation controls are part of the production architecture.') : () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: RoyalCard(child: Row(children: [Icon(icon, color: C.bright), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))), const Icon(Icons.chevron_right, color: C.gold)])),
      ),
    );

Widget tag(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: .72), borderRadius: BorderRadius.circular(14), border: Border.all(color: C.gold.withValues(alpha: .4))),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
    );

Widget transaction(String title, String amount, Color color) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: RoyalCard(child: Row(children: [Expanded(child: Text(title)), Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.w900))])),
    );

void info(BuildContext context, String title, String body) => showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: C.panel,
        title: Text(title),
        content: Text(body),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );

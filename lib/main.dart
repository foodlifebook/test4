import 'package:flutter/material.dart';

void main() => runApp(const KingLiveApp());

class K {
  static const black = Color(0xFF070705);
  static const panel = Color(0xFF14110B);
  static const gold = Color(0xFFD6A71E);
  static const bright = Color(0xFFFFD86B);
  static const ivory = Color(0xFFFFF7E4);
  static const muted = Color(0xFFB9AE96);
  static const red = Color(0xFF9C1118);
  static const green = Color(0xFF27C98A);
}

class KingLiveApp extends StatelessWidget {
  const KingLiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KING LIVE',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: K.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: K.gold,
          brightness: Brightness.dark,
          primary: K.gold,
          secondary: K.bright,
          surface: K.panel,
        ),
      ),
      home: const AgeGate(),
    );
  }
}

class RoyalBg extends StatelessWidget {
  const RoyalBg({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF050504), Color(0xFF1C1204), Color(0xFF050504)],
          stops: [0, .48, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(top: -120, left: -70, child: RoyalGlow(size: 320)),
          const Positioned(top: 250, right: -110, child: RoyalGlow(size: 300)),
          const Positioned(bottom: -160, left: 10, child: RoyalGlow(size: 360)),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class RoyalGlow extends StatelessWidget {
  const RoyalGlow({super.key, required this.size});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [K.gold.withOpacity(.22), Colors.transparent],
          ),
        ),
      );
}

class AgeGate extends StatelessWidget {
  const AgeGate({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: RoyalBg(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CardX(
                gold: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.workspace_premium, size: 78, color: K.bright),
                    const SizedBox(height: 14),
                    const Text('KING LIVE', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    const Text('Royal live streaming • social • PK • gifts • challenges', textAlign: TextAlign.center, style: TextStyle(color: K.muted, height: 1.5)),
                    const SizedBox(height: 18),
                    const Text('18+ only', style: TextStyle(color: K.bright, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 18),
                    SizedBox(width: double.infinity, child: GoldButton('I am 18 or older', () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())))),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: RoyalBg(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, size: 84, color: K.bright),
                  const SizedBox(height: 14),
                  const Text('Enter the Royal Room', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, child: GoldButton('Continue with Google', () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Shell())))),
                  const SizedBox(height: 12),
                  const Text('Test build uses a local demo account. Production Firebase/Google Auth can replace this entry.', textAlign: TextAlign.center, style: TextStyle(color: K.muted, fontSize: 12)),
                ],
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
  int i = 0;
  final pages = const [HomePage(), RankingPage(), MessagesPage(), ProfilePage()];
  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: i, children: pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: K.gold.withOpacity(.35)))),
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
          child: Row(
            children: [
              nav(Icons.home_rounded, 'Home', 0),
              nav(Icons.emoji_events_outlined, 'Ranks', 1),
              Expanded(
                child: Center(
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoLivePage())),
                    child: Container(width: 58, height: 58, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [K.bright, K.gold])), child: const Icon(Icons.add, color: Colors.black, size: 34)),
                  ),
                ),
              ),
              nav(Icons.chat_bubble_outline, 'Messages', 2),
              nav(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      );

  Widget nav(IconData icon, String label, int index) => Expanded(
        child: InkWell(
          onTap: () => setState(() => i = index),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: i == index ? K.bright : K.muted),
            Text(label, style: TextStyle(fontSize: 10, color: i == index ? K.bright : K.muted)),
          ]),
        ),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const rooms = [
    ('Ayesha Queen', 'Good vibes only ✨', '1.2K', 'AQ'),
    ('Ali Gaming', 'Rank Push Live 🚀', '1.1K', 'AG'),
    ('Maya Official', 'Let’s chat 💬', '940', 'MO'),
    ('Hamza Jutt', 'Late Night Talks 🌙', '860', 'HJ'),
  ];

  @override
  Widget build(BuildContext context) => RoyalBg(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: header(context)),
          SliverPadding(
            padding: const EdgeInsets.all(14),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .72, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: rooms.length,
              itemBuilder: (_, i) => roomCard(context, rooms[i], i),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: CardX(
                gold: true,
                child: Row(children: [
                  const Icon(Icons.workspace_premium, color: K.bright, size: 50),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Be a Star!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text('Go live, earn gifts and grow your royal rank.', style: TextStyle(color: K.muted))])),
                  GoldButton('Go Live', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoLivePage())), compact: true),
                ]),
              ),
            ),
          ),
        ]),
      );

  Widget header(BuildContext context) => Container(
        color: Colors.black.withOpacity(.55),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(children: [
          Row(children: [
            const Icon(Icons.search, color: K.ivory),
            const Spacer(),
            const Text('KING LIVE', style: TextStyle(color: K.bright, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const Spacer(),
            IconButton(onPressed: () => showInfo(context, 'Notifications', '🎁 Gift received\n👤 New follower\n⚔ PK invite\n💵 Salary credited'), icon: const Icon(Icons.notifications_none, color: K.ivory)),
          ]),
          const SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [ChipX('Popular', true), ChipX('Following', false), ChipX('Nearby', false), ChipX('New', false), ChipX('PK', false)])),
        ]),
      );

  Widget roomCard(BuildContext context, (String, String, String, String) r, int n) => InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LiveRoomPage(name: r.$1, initials: r.$4, host: false))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: K.gold.withOpacity(.55)),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [n.isEven ? const Color(0xFF541015) : const Color(0xFF102316), const Color(0xFF090806)]),
          ),
          child: Stack(children: [
            Center(child: HeroAvatar(r.$4, 76)),
            Positioned(left: 8, top: 8, child: badge('LIVE')),
            Positioned(right: 8, top: 10, child: Text('◉ ${r.$3}', style: const TextStyle(fontWeight: FontWeight.w800))),
            Positioned(left: 10, right: 10, bottom: 12, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), Text(r.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: K.muted))])),
          ]),
        ),
      );
}

class LiveRoomPage extends StatefulWidget {
  const LiveRoomPage({super.key, required this.name, required this.initials, required this.host});
  final String name;
  final String initials;
  final bool host;
  @override
  State<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends State<LiveRoomPage> {
  final feed = ['viewer22: 🔥🔥🔥', 'aliZ: welcome back!', 'Maya: 👑 amazing room'];
  @override
  Widget build(BuildContext context) => Scaffold(
        body: RoyalBg(
          child: Column(children: [
            Padding(padding: const EdgeInsets.all(12), child: Row(children: [badge('👁 3.4k'), const Spacer(), if (widget.host) FilledButton(style: FilledButton.styleFrom(backgroundColor: K.red), onPressed: () => Navigator.pop(context), child: const Text('End Live')) else GoldButton('+ Follow', () {}, compact: true)])),
            if (widget.host) Container(width: double.infinity, padding: const EdgeInsets.all(10), color: const Color(0xFFE75220), child: const Text('⚠ Host not visible — return within 30s', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900))),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [HeroAvatar(widget.initials, 102), const SizedBox(height: 14), Text(widget.name, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), const Text('👑 Royal Room', style: TextStyle(color: K.bright, fontWeight: FontWeight.w800))])),
            Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: feed.map((e) => Container(margin: const EdgeInsets.only(top: 5), padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: Colors.black.withOpacity(.7), borderRadius: BorderRadius.circular(18)), child: Text(e, style: const TextStyle(fontSize: 12)))).toList()))),
            Padding(padding: const EdgeInsets.fromLTRB(10, 6, 10, 14), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [action(Icons.mic_none, () {}), action(Icons.camera_alt_outlined, () {}), action(Icons.auto_awesome, gifts), action(Icons.emoji_emotions_outlined, () {}), action(Icons.sports_kabaddi_outlined, () => showInfo(context, 'PK Challenge', 'Invite another host for a timed head-to-head battle. Gifts determine the score.')), action(Icons.more_horiz, () {})])),
          ]),
        ),
      );

  Widget action(IconData icon, VoidCallback tap) => InkWell(onTap: tap, child: Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(.72), border: Border.all(color: K.gold.withOpacity(.5))), child: Icon(icon)));
  void gifts() => showModalBottomSheet(context: context, backgroundColor: K.panel, builder: (_) => Padding(padding: const EdgeInsets.all(18), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Send a Royal Gift', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 16), Wrap(spacing: 14, runSpacing: 14, children: ['🌹 10', '🦁 9999', '🏎️ 8999', '👑 7999', '✈️ 6999', '💛 120'].map((e) => InkWell(onTap: () { Navigator.pop(context); setState(() => feed.insert(0, 'You sent $e')); }, child: CardX(child: Text(e, style: const TextStyle(fontSize: 20)))).toList()))])));
}

class GoLivePage extends StatelessWidget {
  const GoLivePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Go Live')),
        body: RoyalBg(
          child: ListView(padding: const EdgeInsets.all(18), children: [
            const CardX(gold: true, child: AspectRatio(aspectRatio: 16 / 9, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.camera_alt_outlined, color: K.bright, size: 48), Text('Upload Cover'), Text('16:9 recommended', style: TextStyle(color: K.muted))])))),
            const SizedBox(height: 14),
            const TextField(decoration: InputDecoration(labelText: 'Room title', filled: true)),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: 'Category', hintText: 'Chat / Dating / Gaming / Challenges', filled: true)),
            const SizedBox(height: 12),
            const CardX(child: Text('🛡 Moderation ON  •  Comments ON  •  Followers All')),
            const SizedBox(height: 16),
            GoldButton('Start Live', () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LiveRoomPage(name: 'King Host', initials: 'KH', host: true)))),
          ]),
        ),
      );
}

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});
  @override
  Widget build(BuildContext context) => RoyalBg(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Leaderboard', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [ChipX('Top Sender', true), ChipX('Top Host', false), ChipX('Top Agency', false), ChipX('Top PK Host', false)])),
          const SizedBox(height: 10),
          const Row(children: [ChipX('Daily', true), ChipX('Weekly', false), ChipX('Monthly', false)]),
          const SizedBox(height: 22),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [podium('Ayesha', 'AQ', '🥈', 100), podium('Zayn', 'Z', '🥇', 145), podium('Bilal', 'B', '🥉', 86)]),
          const SizedBox(height: 16),
          for (var i = 4; i <= 8; i++) Padding(padding: const EdgeInsets.only(bottom: 8), child: CardX(child: Row(children: [Text('#$i', style: const TextStyle(color: K.bright, fontWeight: FontWeight.w900)), const SizedBox(width: 12), Expanded(child: Text('Host_$i')), Text('${30 - i * 2}k', style: const TextStyle(color: K.bright, fontWeight: FontWeight.w900))]))),
        ]),
      );
  Widget podium(String n, String init, String medal, double h) => Expanded(child: Column(children: [HeroAvatar(init, 44), const SizedBox(height: 6), Text(n), Container(height: h, margin: const EdgeInsets.all(4), decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(18)), gradient: const LinearGradient(colors: [K.bright, K.gold])), child: Center(child: Text(medal, style: const TextStyle(fontSize: 32))))]));
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});
  @override
  Widget build(BuildContext context) {
    const data = [('AQ', 'Ayesha Queen', 'Sent a gift 👑 King Crown'), ('AG', 'Ali Gaming', 'See you live tonight!'), ('MO', 'Maya Official', 'Thanks for the follow!'), ('HJ', 'Hamza Jutt', 'Typing…')];
    return RoyalBg(child: ListView(padding: const EdgeInsets.all(16), children: [const Text('Messages', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 14), for (final e in data) Padding(padding: const EdgeInsets.only(bottom: 9), child: CardX(child: Row(children: [HeroAvatar(e.$1, 30), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.$2, style: const TextStyle(fontWeight: FontWeight.w900)), Text(e.$3, style: const TextStyle(color: K.muted))])), const Icon(Icons.chevron_right, color: K.gold)]))) ]));
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => RoyalBg(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          const Row(children: [Spacer(), Icon(Icons.settings_outlined, color: K.bright)]),
          const Center(child: HeroAvatar('AQ', 70)),
          const SizedBox(height: 10),
          const Center(child: Text('Ayesha Queen', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900))),
          const Center(child: Text('@ayesha_q', style: TextStyle(color: K.muted))),
          const SizedBox(height: 10),
          const Center(child: ChipX('Lv. 68  👑 VIP 1', true)),
          const SizedBox(height: 16),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [stat('302', 'Following'), stat('18.4K', 'Followers')]),
          const SizedBox(height: 14),
          const CardX(child: Text('About Me\n\nLive with passion, laugh with heart. Royal creator, PK fan and challenge lover.', style: TextStyle(height: 1.5))),
          const SizedBox(height: 10),
          menu(context, Icons.account_balance_wallet_outlined, 'Wallet', const WalletPage()),
          menu(context, Icons.groups_2_outlined, 'Agencies', const AgencyPage()),
          menu(context, Icons.palette_outlined, 'Royal Themes', const ThemePage()),
          menu(context, Icons.shield_outlined, 'Privacy & Safety', null),
        ]),
      );
}

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Wallet')), body: RoyalBg(child: ListView(padding: const EdgeInsets.all(16), children: [
    const CardX(gold: true, child: Column(children: [Text('Coin Balance', style: TextStyle(color: K.muted)), Text('12,450', style: TextStyle(color: K.bright, fontSize: 42, fontWeight: FontWeight.w900)), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [stat('3,200', 'Diamonds'), stat('890', 'Beans')])])),
    const SizedBox(height: 12),
    Row(children: [Expanded(child: GoldButton('Recharge', () => showInfo(context, 'Recharge', '1,000 coins — Rs 250\n5,000 coins — Rs 1,200\n12,000 coins — Rs 2,800\n30,000 coins — Rs 6,500'))), const SizedBox(width: 8), Expanded(child: GoldButton('Withdraw', () => showInfo(context, 'Withdraw', '890 Beans ≈ Rs 44,500\nBank Transfer • JazzCash • Easypaisa')))]),
    const SizedBox(height: 16), const Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
    tx('Recharge', '+5,000', K.green), tx('Gift sent', '-1,200', K.red), tx('Withdrawal', '-3,000', K.red), tx('Gift received', '+850', K.green),
  ])));
}

class AgencyPage extends StatelessWidget {
  const AgencyPage({super.key});
  @override
  Widget build(BuildContext context) {
    const a = [('Grafixers Agency', '124 hosts • ⭐ 4.9 • Verified'), ('Royal Streamers', '42 hosts • ⭐ 4.8 • Elite'), ('Rising Stars', '86 hosts • ⭐ 4.8 • Top'), ('Velvet Circle', '57 hosts • ⭐ 4.7 • Open')];
    return Scaffold(appBar: AppBar(title: const Text('Agency List')), body: RoyalBg(child: ListView(padding: const EdgeInsets.all(16), children: [const TextField(decoration: InputDecoration(hintText: 'Search agencies', prefixIcon: Icon(Icons.search), filled: true)), const SizedBox(height: 12), for (final e in a) Padding(padding: const EdgeInsets.only(bottom: 9), child: CardX(child: Row(children: [const CircleAvatar(backgroundColor: Color(0x332C240C), child: Icon(Icons.apartment, color: K.bright)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.$1, style: const TextStyle(fontWeight: FontWeight.w900)), Text(e.$2, style: const TextStyle(color: K.muted))])), GoldButton('Join', () {}, compact: true)]))) ])));
  }
}

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Theme')), body: RoyalBg(child: ListView(padding: const EdgeInsets.all(16), children: const [CardX(gold: true, child: ListTile(leading: Icon(Icons.castle, color: K.bright), title: Text('Royal Palace'), subtitle: Text('Gold • crimson • emerald ambience'))), SizedBox(height: 10), CardX(child: ListTile(leading: Icon(Icons.dark_mode, color: K.bright), title: Text('Obsidian Gold'), subtitle: Text('Black and gold high contrast'))), SizedBox(height: 10), CardX(child: ListTile(leading: Icon(Icons.workspace_premium, color: K.bright), title: Text('Crimson Crown'), subtitle: Text('Royal red and gold treatment')))])));
}

class CardX extends StatelessWidget {
  const CardX({super.key, required this.child, this.gold = false});
  final Widget child;
  final bool gold;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.black.withOpacity(.69), borderRadius: BorderRadius.circular(20), border: Border.all(color: (gold ? K.bright : K.gold).withOpacity(.55)), boxShadow: [BoxShadow(color: K.gold.withOpacity(.08), blurRadius: 18)]), child: child);
}

class GoldButton extends StatelessWidget {
  const GoldButton(this.label, this.tap, {super.key, this.compact = false});
  final String label;
  final VoidCallback tap;
  final bool compact;
  @override
  Widget build(BuildContext context) => Container(height: compact ? 42 : 52, decoration: BoxDecoration(gradient: const LinearGradient(colors: [K.bright, K.gold]), borderRadius: BorderRadius.circular(16)), child: FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.black, shadowColor: Colors.transparent), onPressed: tap, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900))));
}

class ChipX extends StatelessWidget {
  const ChipX(this.text, this.selected, {super.key});
  final String text;
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(right: 7), padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9), decoration: BoxDecoration(color: selected ? K.gold : Colors.black.withOpacity(.7), borderRadius: BorderRadius.circular(25), border: Border.all(color: K.gold.withOpacity(.4))), child: Text(text, style: TextStyle(color: selected ? Colors.black : K.ivory, fontWeight: FontWeight.w800)));
}

class HeroAvatar extends StatelessWidget {
  const HeroAvatar(this.initials, this.radius, {super.key});
  final String initials;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(width: radius * 2, height: radius * 2, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [K.bright, K.red]), boxShadow: [BoxShadow(color: K.gold.withOpacity(.25), blurRadius: 22)]), padding: const EdgeInsets.all(3), child: Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF17120B)), child: Center(child: Text(initials, style: TextStyle(fontSize: radius * .52, color: K.bright, fontWeight: FontWeight.w900)))));
}

class stat extends StatelessWidget {
  const stat(this.n, this.t, {super.key});
  final String n;
  final String t;
  @override
  Widget build(BuildContext context) => Column(children: [Text(n, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), Text(t, style: const TextStyle(color: K.muted))]);
}

Widget menu(BuildContext context, IconData icon, String label, Widget? page) => Padding(padding: const EdgeInsets.only(bottom: 8), child: InkWell(onTap: page == null ? () => showInfo(context, label, 'Privacy, blocked users, reporting, moderation and account controls are included in the production source.') : () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)), child: CardX(child: Row(children: [Icon(icon, color: K.bright), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))), const Icon(Icons.chevron_right, color: K.gold)]))));

Widget badge(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(.72), borderRadius: BorderRadius.circular(14), border: Border.all(color: K.gold.withOpacity(.4))), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)));

Widget tx(String title, String amount, Color c) => Padding(padding: const EdgeInsets.only(top: 8), child: CardX(child: Row(children: [Expanded(child: Text(title)), Text(amount, style: TextStyle(color: c, fontWeight: FontWeight.w900))])));

void showInfo(BuildContext context, String title, String body) => showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: K.panel, title: Text(title), content: Text(body), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));

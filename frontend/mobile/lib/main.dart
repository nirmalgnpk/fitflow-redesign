// =============================================================
//  FITFLOW - Single file Flutter UI  (lib/main.dart)
//  Screens: Login, Home, Workouts, Progress, Workout Session,
//           AI Planner, Community, Nutrition, Profile (+Calendar)
//  No extra packages needed - just replace lib/main.dart and run.
// =============================================================

import 'dart:async'; // for Timer (workout countdown)
import 'dart:math' as math; // for pi (used in the circle charts)
import 'package:flutter/material.dart';

void main() {
  runApp(const FitflowApp());
}

// -------------------------------------------------------------
// 1. COLORS (change these to re-theme the whole app)
// -------------------------------------------------------------
class AppColors {
  static const bg = Color(0xFF17181B); // page background
  static const card = Color(0xFF24262B); // card background
  static const border = Color(0xFF3A3D44); // thin borders
  static const orange = Color(0xFFF47C20); // main accent colour
  static const muted = Color(0xFF9A9DA5); // grey sub text
}

// Reusable FitFlow logo. If the image cannot be loaded, show a fitness icon.
class FitFlowLogo extends StatelessWidget {
  final double size;
  final Color fallbackColor;
  const FitFlowLogo({
    super.key,
    this.size = 36,
    this.fallbackColor = AppColors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/fitflow_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.fitness_center,
        size: size * 0.8,
        color: fallbackColor,
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. ROOT APP
// -------------------------------------------------------------
class FitflowApp extends StatelessWidget {
  const FitflowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitflow',
      debugShowCheckedModeBanner: false, // hides the red DEBUG banner
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.orange,
          brightness: Brightness.dark,
        ),
      ),
      home: const LoginPage(), // first screen
    );
  }
}

// -------------------------------------------------------------
// 3. SAMPLE DATA (fake data - later replace with your backend)
// -------------------------------------------------------------
class Workout {
  final String name;
  final String detail;
  final int cal;
  final String category;
  final IconData icon;
  const Workout(this.name, this.detail, this.cal, this.category, this.icon);
}

const List<Workout> allWorkouts = [
  Workout('Crunch', '3 x 40s', 80, 'Core', Icons.self_improvement),
  Workout('Plank Hold', '3 x 60s', 60, 'Core', Icons.accessibility_new),
  Workout('Bicep Curl', '3 x 12 reps', 70, 'Arms', Icons.fitness_center),
  Workout('Tricep Dips', '3 x 15 reps', 75, 'Arms', Icons.fitness_center),
  Workout('Push-ups', '4 x 12 reps', 90, 'Chest', Icons.sports_gymnastics),
  Workout('Bench Press', '4 x 10 reps', 110, 'Chest', Icons.fitness_center),
  Workout('Pull-ups', '3 x 8 reps', 100, 'Back', Icons.sports_gymnastics),
  Workout('Deadlift', '4 x 8 reps', 130, 'Back', Icons.fitness_center),
];

// -------------------------------------------------------------
// 4. SMALL REUSABLE WIDGETS
// -------------------------------------------------------------

// A rounded dark card. Pass onTap to make it clickable.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool outlined;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                )
              : null,
          child: child,
        ),
      ),
    );
  }
}

// Section title with a small grey sub title
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionTitle(this.title, {super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          if (subtitle != null)
            Text(subtitle!,
                style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        ],
      ),
    );
  }
}

// Small rounded chip (All / Core / Arms ...)
class Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const Pill(
      {super.key,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.orange : AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : AppColors.muted,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// Square icon button with optional red/orange badge (messages, bell)
class IconBox extends StatelessWidget {
  final IconData icon;
  final int badge;
  final VoidCallback? onTap;
  const IconBox({super.key, required this.icon, this.badge = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 22),
          ),
          if (badge > 0)
            Positioned(
              right: -4,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(8)),
                child: Text('$badge',
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

// Page title row used on Workouts / AI / Community pages
class PageTitle extends StatelessWidget {
  final String title;
  const PageTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const Row(children: [
            IconBox(icon: Icons.chat_bubble_outline),
            SizedBox(width: 10),
            IconBox(icon: Icons.notifications_none, badge: 10),
          ]),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 5. LOGIN PAGE
// -------------------------------------------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true; // show/hide password

  @override
  void dispose() {
    // always dispose controllers to free memory
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 70),
              // Logo circle
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                    color: AppColors.orange, shape: BoxShape.circle),
                child: const FitFlowLogo(size: 64, fallbackColor: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('Fitflow',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orange)),
              const Text('Your smarter way to train',
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 50),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Email',
                    style: TextStyle(color: Colors.grey.shade300)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration('Enter your email'),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Password',
                    style: TextStyle(color: Colors.grey.shade300)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _password,
                obscureText: _hidePassword,
                decoration: _decoration(
                  'Enter your password',
                  suffix: IconButton(
                    icon: Icon(_hidePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forget Password',
                      style: TextStyle(color: AppColors.muted)),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  // Demo only: no real login check yet.
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    );
                  },
                  child: const Text('Sign in',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 6. MAIN SHELL (bottom navigation + 5 tabs)
// -------------------------------------------------------------
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0; // which tab is selected

  final _pages = const [
    HomePage(),
    WorkoutsPage(),
    AiPage(),
    CommunityPage(),
    ProfilePage(),
  ];

  final _icons = const [
    Icons.home_rounded,
    Icons.fitness_center,
    Icons.auto_awesome,
    Icons.groups_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps every tab alive (state is not lost)
      body: SafeArea(bottom: false, child: IndexedStack(index: _index, children: _pages)),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_icons.length, (i) {
              final selected = i == _index;
              return GestureDetector(
                onTap: () => setState(() => _index = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 46,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.orange : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icons[i],
                      color: selected ? Colors.white : Colors.grey.shade400),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 7. HOME PAGE
// -------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _filter = 'All'; // selected workout category
  final _filters = ['All', 'Core', 'Arms', 'Chest', 'Back'];

  // multi-select chips (level + goal)
  final Set<String> _chips = {'Beginner', 'Lose Weight'};
  final _chipNames = [
    'Beginner',
    'Medium',
    'Pro',
    'Lose Weight',
    'Muscle Gain',
    'Hiit Rush'
  ];

  @override
  Widget build(BuildContext context) {
    // filter the workout list using the selected category
    final list = _filter == 'All'
        ? allWorkouts
        : allWorkouts.where((w) => w.category == _filter).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      children: [
        // ---------- Header ----------
        Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.orange,
              child: Text('K',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good Morning!',
                      style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  Text('Kaveesha',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const IconBox(icon: Icons.chat_bubble_outline),
            const SizedBox(width: 10),
            const IconBox(icon: Icons.notifications_none, badge: 10),
          ],
        ),
        const SizedBox(height: 22),

        // ---------- Orange banner ----------
        Container(
          height: 165,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFFF47C20), Color(0xFFFF9A4D)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(Icons.directions_run,
                    size: 130, color: Colors.white.withValues(alpha: 0.35)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('7-Day Streak\nChallenge is Live!',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.2)),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.orange),
                    onPressed: () {},
                    child: const Text('Join now'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // banner dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(AppColors.orange, 30),
            _dot(AppColors.border, 18),
            _dot(AppColors.border, 18),
          ],
        ),

        // ---------- Today's progress ----------
        const SectionTitle("Today's Progress", subtitle: 'Small steps, big changes'),
        Row(children: [
          Expanded(child: _statTile(Icons.directions_walk, '2500/3000', 'Steps', '10%')),
          const SizedBox(width: 10),
          Expanded(child: _statTile(Icons.local_fire_department_outlined, '320/820', 'Calories Burn', '5%')),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _statTile(Icons.timer_outlined, '10', 'Active Time (m)', '2%')),
          const SizedBox(width: 10),
          Expanded(child: _statTile(Icons.place_outlined, '4.2/5', 'Distance (km)', '8%')),
        ]),

        // ---------- Categories ----------
        const SectionTitle('Categories'),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _CategoryCircle(Icons.self_improvement, 'Core'),
            _CategoryCircle(Icons.accessibility_new, 'Full Body'),
            _CategoryCircle(Icons.fitness_center, 'Arm'),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _chipNames.map((name) {
            return Pill(
              label: name,
              selected: _chips.contains(name),
              onTap: () => setState(() {
                // toggle: remove if selected, add if not
                _chips.contains(name) ? _chips.remove(name) : _chips.add(name);
              }),
            );
          }).toList(),
        ),

        // ---------- News ----------
        const SectionTitle('News'),
        AppCard(
          outlined: true,
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: const Center(
            child: Column(children: [
              Text('CLASSIC 21',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('21-Day Challenge',
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          outlined: true,
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: const Center(
            child: Text('Workday Recharge',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),

        // ---------- Weekly goal ----------
        const SizedBox(height: 14),
        const AppCard(
          outlined: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weekly Goal',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              SizedBox(height: 4),
              Text('4 of 5 workouts completed',
                  style: TextStyle(color: AppColors.muted)),
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: LinearProgressIndicator(
                  value: 0.8,
                  minHeight: 8,
                  color: AppColors.orange,
                  backgroundColor: AppColors.border,
                ),
              ),
            ],
          ),
        ),

        // ---------- Latest workout ----------
        const SectionTitle('Latest Workout', subtitle: 'Every session counts'),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _filters
                .map((f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Pill(
                        label: f,
                        selected: _filter == f,
                        onTap: () => setState(() => _filter = f),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        ...list.map((w) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WorkoutTile(workout: w),
            )),
      ],
    );
  }

  // little progress bar dot
  Widget _dot(Color c, double w) => Container(
        width: w,
        height: 5,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration:
            BoxDecoration(color: c, borderRadius: BorderRadius.circular(5)),
      );

  // one stat card (Steps, Calories ...) - tap opens Progress page
  Widget _statTile(IconData icon, String value, String label, String change) {
    return AppCard(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ProgressPage())),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Flexible(
                      child: Text(label,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 11)),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.trending_up,
                        size: 12, color: AppColors.orange),
                    Text(change,
                        style: const TextStyle(
                            color: AppColors.orange, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryCircle(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 32, color: AppColors.orange),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

// One row in the workout list - tap to start the workout
class WorkoutTile extends StatelessWidget {
  final Workout workout;
  const WorkoutTile({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WorkoutSessionPage(workout: workout)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(workout.icon, color: AppColors.orange, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.name,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600)),
                Text(workout.detail,
                    style: const TextStyle(color: AppColors.muted)),
                Text('${workout.cal} cal',
                    style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          const Icon(Icons.play_circle_fill, color: AppColors.orange, size: 32),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 8. WORKOUTS PAGE (tab)
// -------------------------------------------------------------
class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageTitle('Workouts'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              // quick links to Progress & Nutrition pages
              Row(children: [
                Expanded(
                  child: _linkCard(context, Icons.show_chart, 'Progress',
                      const ProgressPage()),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _linkCard(context, Icons.restaurant_menu, 'Nutrition',
                      const NutritionPage()),
                ),
              ]),
              const SectionTitle('All Workouts', subtitle: 'Tap to start'),
              ...allWorkouts.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: WorkoutTile(workout: w),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _linkCard(
      BuildContext context, IconData icon, String label, Widget page) {
    return AppCard(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Column(
        children: [
          Icon(icon, color: AppColors.orange, size: 30),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 9. PROGRESS PAGE (line chart)
// -------------------------------------------------------------
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Row(
          children: [
            FitFlowLogo(size: 30),
            SizedBox(width: 10),
            Text('Progress', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AppCard(
            outlined: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Progress',
                    style: TextStyle(color: AppColors.muted)),
                SizedBox(height: 4),
                Text('4 / 5 workouts',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // legend
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(AppColors.orange, 'Category 1'),
              SizedBox(width: 14),
              _Legend(Color(0xFF6EA8FE), 'Category 2'),
              SizedBox(width: 14),
              _Legend(Color(0xFF7BD88F), 'Category 3'),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            child: SizedBox(
              height: 230,
              child: CustomPaint(
                size: Size.infinite,
                painter: LineChartPainter(
                  series: const [
                    [40, 25, 30, 18],
                    [27, 35, 55, 30],
                    [33, 40, 38, 28],
                  ],
                  colors: const [
                    AppColors.orange,
                    Color(0xFF6EA8FE),
                    Color(0xFF7BD88F),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _BigStat('Minutes', '128')),
              SizedBox(width: 12),
              Expanded(child: _BigStat('Calories', '820')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  const _Legend(this.color, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 14, height: 8, color: color),
      const SizedBox(width: 5),
      Text(text, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
    ]);
  }
}

class _BigStat extends StatelessWidget {
  final String label;
  final String value;
  const _BigStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      outlined: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orange)),
        ],
      ),
    );
  }
}

// Draws a smooth multi-line chart (no chart package needed)
class LineChartPainter extends CustomPainter {
  final List<List<double>> series;
  final List<Color> colors;
  LineChartPainter({required this.series, required this.colors});

  static const double minY = 15;
  static const double maxY = 60;

  void _text(Canvas canvas, String text, Offset offset) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: const TextStyle(color: AppColors.muted, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const left = 28.0;
    const bottom = 22.0;
    final w = size.width - left;
    final h = size.height - bottom;

    // horizontal grid lines + y labels
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (double v = 15; v <= 60; v += 15) {
      final y = h - (v - minY) / (maxY - minY) * h;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), grid);
      _text(canvas, v.toInt().toString(), Offset(0, y - 6));
    }

    // x labels
    final n = series.first.length;
    for (int i = 0; i < n; i++) {
      final x = left + i * w / (n - 1);
      _text(canvas, 'Label ${i + 1}', Offset(x - 14, h + 6));
    }

    // each line
    for (int s = 0; s < series.length; s++) {
      final pts = <Offset>[];
      for (int i = 0; i < n; i++) {
        final x = left + i * w / (n - 1);
        final y = h - (series[s][i] - minY) / (maxY - minY) * h;
        pts.add(Offset(x, y));
      }
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (int i = 0; i < pts.length - 1; i++) {
        final midX = (pts[i].dx + pts[i + 1].dx) / 2;
        // cubic curve makes the line smooth
        path.cubicTo(midX, pts[i].dy, midX, pts[i + 1].dy, pts[i + 1].dx,
            pts[i + 1].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = colors[s]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      for (final p in pts) {
        canvas.drawCircle(p, 3.5, Paint()..color = colors[s]);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter old) => true;
}

// Draws a donut / ring chart. values are fractions (0.0 - 1.0)
class DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double stroke;
  DonutPainter(
      {required this.values, required this.colors, this.stroke = 12});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.width / 2 - stroke / 2,
    );
    // grey track behind
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    double start = -math.pi / 2; // start from top
    for (int i = 0; i < values.length; i++) {
      final sweep = values[i] * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = values.length == 1 ? StrokeCap.round : StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutPainter old) => true;
}

// -------------------------------------------------------------
// 10. WORKOUT SESSION PAGE (countdown timer)
// -------------------------------------------------------------
class WorkoutSessionPage extends StatefulWidget {
  final Workout workout;
  const WorkoutSessionPage({super.key, required this.workout});

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  static const int _total = 45; // seconds per exercise
  int _secondsLeft = _total;
  int _step = 0; // current exercise number
  bool _running = true;
  Timer? _timer;

  // [name, reps]
  final _exercises = const [
    ['Squats', '12 reps'],
    ['Push-ups', '10 reps'],
    ['Lunges', '12 reps'],
    ['Plank', '40 sec'],
  ];

  @override
  void initState() {
    super.initState();
    // tick every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_running) return;
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) _next();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // stop timer when leaving the page
    super.dispose();
  }

  void _next() {
    if (_step < _exercises.length - 1) {
      _step++;
      _secondsLeft = _total;
    } else {
      _timer?.cancel();
      _secondsLeft = 0;
      _running = false;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Workout complete! 🎉'),
          content: const Text('Great job, keep the streak going.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // leave page
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  String get _timeText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final current = _exercises[_step];
    final hasNext = _step < _exercises.length - 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Row(
          children: [
            FitFlowLogo(size: 30),
            SizedBox(width: 10),
            Text('FitFlow', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Timer ring
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: DonutPainter(
                      values: [_secondsLeft / _total],
                      colors: const [AppColors.orange],
                      stroke: 10,
                    ),
                  ),
                  Text(_timeText,
                      style: const TextStyle(
                          fontSize: 38, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('${widget.workout.category} · Beginner',
                style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(current[0],
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(current[1],
                  style: const TextStyle(color: AppColors.muted)),
            ),
            const SizedBox(height: 14),
            AppCard(
              outlined: true,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    hasNext ? 'Next: ${_exercises[_step + 1][0]}' : 'Last exercise!',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                // pause / resume
                SizedBox(
                  height: 50,
                  width: 54,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _running = !_running),
                    child: Icon(_running ? Icons.pause : Icons.play_arrow),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white),
                      onPressed: () => setState(_next),
                      child: Text(hasNext ? 'Next Exercise' : 'Finish'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Keep your core tight and breathe steadily.',
                style: TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 14),
            // exercise picture placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.fitness_center,
                    size: 70, color: AppColors.border),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 11. AI PLANNER PAGE (tab) - simple fake chat
// -------------------------------------------------------------
class _Msg {
  final String text;
  final bool isUser;
  _Msg(this.text, this.isUser);
}

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final _controller = TextEditingController();
  final List<_Msg> _messages = [
    _Msg('Hi Kaveesha! Tell me about your goal and I will build a plan.', false),
  ];
  String _metric = 'Time';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text, true));
      // fake AI reply (connect your ai-service here later)
      _messages.add(_Msg(
          'Great! I suggest 30 min workouts, 4 days/week focusing on strength.',
          false));
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageTitle('AI Workout Planner'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            children: [
              // summary card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: ['Time', 'Energy', 'Weight']
                          .map((m) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Pill(
                                  label: m,
                                  selected: _metric == m,
                                  onTap: () => setState(() => _metric = m),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('+18% this week',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.orange)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const AppCard(
                outlined: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What is your goal?',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('Build strength and improve fitness',
                        style: TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const AppCard(
                outlined: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preferences',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('30 min • 4 days/week',
                        style: TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // chat bubbles
              ..._messages.map((m) => Align(
                    alignment:
                        m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: m.isUser ? AppColors.orange : AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(m.text),
                    ),
                  )),
            ],
          ),
        ),
        // input box
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.image_outlined, color: AppColors.muted),
                const SizedBox(width: 10),
                const Icon(Icons.mic_none, color: AppColors.muted),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'What would you like to know?',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.arrow_circle_up,
                      color: AppColors.orange, size: 30),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// 12. COMMUNITY PAGE (tab)
// -------------------------------------------------------------
class Post {
  final String user;
  final String time;
  final String text;
  int likes;
  int comments;
  bool liked;
  Post(this.user, this.time, this.text, this.likes, this.comments,
      {this.liked = false});
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<Post> _posts = [
    Post('Alex', '10 min ago', 'Completed 30 min strength workout.', 24, 8),
    Post('Maya', '1 hr ago', 'New weekly goal achieved!', 18, 4),
    Post('Autumn Phillips', '3 hr ago',
        'Discipline is the bridge between goals and results.', 200, 745),
  ];
  final _stories = ['meilanyz', 'rahm4tt', 'chindyyy', 'berl1an', 'bryant15'];

  // Bottom sheet to write a new post
  void _newPost() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      builder: (ctx) => Padding(
        // moves the sheet above the keyboard
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Share your win...'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    setState(() => _posts.insert(
                        0, Post('You', 'just now', controller.text.trim(), 0, 0)));
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: _newPost,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const PageTitle('Social'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                // search bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(children: [
                    Icon(Icons.search, color: AppColors.muted),
                    SizedBox(width: 10),
                    Text('Find workouts, tips, or friends',
                        style: TextStyle(color: AppColors.muted)),
                  ]),
                ),
                const SizedBox(height: 16),
                // stories row
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _stories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (_, i) => Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.orange, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.card,
                            child: Text(_stories[i][0].toUpperCase(),
                                style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(_stories[i],
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // posts
                ..._posts.map(_postCard),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _postCard(Post p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: AppColors.orange,
                child: Text(p.user[0],
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.user,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(p.time,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: AppColors.muted),
            ]),
            const SizedBox(height: 12),
            Text(p.text, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Row(children: [
              // like button
              GestureDetector(
                onTap: () => setState(() {
                  p.liked = !p.liked;
                  p.liked ? p.likes++ : p.likes--;
                }),
                child: Row(children: [
                  Icon(p.liked ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.orange),
                  const SizedBox(width: 4),
                  Text('${p.likes}'),
                ]),
              ),
              const SizedBox(width: 22),
              const Icon(Icons.chat_bubble_outline,
                  size: 20, color: AppColors.muted),
              const SizedBox(width: 4),
              Text('${p.comments}'),
            ]),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 13. NUTRITION PAGE
// -------------------------------------------------------------
class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // meals: name -> kcal
    const meals = {
      'Breakfast': 420,
      'Lunch': 560,
      'Dinner': 0,
      'Snacks': 440,
    };
    final total = meals.values.fold<int>(0, (a, b) => a + b); // 1420 kcal

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Row(
          children: [
            FitFlowLogo(size: 30),
            SizedBox(width: 10),
            Text('Nutrition', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Today's nutrition",
              style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 14),
          // calorie ring
          Center(
            child: SizedBox(
              width: 170,
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(170, 170),
                    painter: DonutPainter(
                      values: const [1840 / 2200],
                      colors: const [AppColors.orange],
                      stroke: 12,
                    ),
                  ),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('1,840',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      Text('Kcal', style: TextStyle(fontSize: 16)),
                      Text('of 2,200 kcal',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _macro('P', 'Protein', 112, 150, const Color(0xFF6EA8FE)),
          _macro('C', 'Carbs', 210, 280, AppColors.orange),
          _macro('F', 'Fat', 58, 80, const Color(0xFF7BD88F)),
          const SizedBox(height: 14),
          SizedBox(
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Meals total: $total kcal')),
                );
              },
              child: const Text('Calculate'),
            ),
          ),
          const SizedBox(height: 18),
          // meal cards (2 per row)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: meals.entries.map((e) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 52) / 2,
                child: AppCard(
                  outlined: true,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('${e.value} kcal',
                          style: const TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // macro split donut
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: DonutPainter(
                  values: const [0.30, 0.50, 0.20],
                  colors: const [
                    Color(0xFF6EA8FE),
                    AppColors.orange,
                    Color(0xFF7BD88F),
                  ],
                  stroke: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // one macro progress bar row
  Widget _macro(String letter, String name, int value, int goal, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
              width: 24,
              child: Text(letter,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value / goal,
                minHeight: 8,
                color: color,
                backgroundColor: AppColors.border,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('$value g',
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 14. PROFILE PAGE (tab) + CALENDAR
// -------------------------------------------------------------
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // profile rows (label, value)
    const info = [
      ['Name', 'Kaveesha'],
      ['Username', '@kavee'],
      ['Age', '23'],
      ['Height', '175 cm'],
      ['Weight', '60 kg'],
      ['Fitness Goal', 'Build Muscle'],
      ['Activity Level', 'Intermediate'],
      ['Workout Days', '5 days/week'],
      ['Preferred Workout', 'Strength Training'],
      ['Duration', '45-60 min'],
      ['Target Weight', '75 kg'],
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),
        const Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.orange,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text('Kaveesha',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        const Center(
          child: Text('Fitness journey · 24 days active',
              style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profile information',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 10),
              ...info.map((row) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(row[0],
                            style: const TextStyle(color: AppColors.muted)),
                        Text(row[1]),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const CalendarCard(),
        const SizedBox(height: 18),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              // go back to login and clear all previous pages
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ),
      ],
    );
  }
}

// Simple month calendar (built by hand, no package)
class CalendarCard extends StatefulWidget {
  const CalendarCard({super.key});

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  int _selected = DateTime.now().day;

  static const _names = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  static const _week = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta, 1);
      _selected = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final offset = _month.weekday % 7; // Sunday = 0
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final rows = ((offset + daysInMonth) / 7).ceil();

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // month header with arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left)),
              Text('${_names[_month.month - 1]} ${_month.year}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right)),
            ],
          ),
          // weekday names
          Row(
            children: _week
                .map((d) => Expanded(
                      child: Center(
                          child: Text(d,
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 12))),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          // day cells
          for (int r = 0; r < rows; r++)
            Row(
              children: List.generate(7, (c) {
                final day = r * 7 + c - offset + 1;
                if (day < 1 || day > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 38));
                }
                final selected = day == _selected;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = day),
                    child: Container(
                      height: 34,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.orange : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('$day',
                            style: TextStyle(
                                fontSize: 13,
                                color: selected
                                    ? Colors.white
                                    : Colors.grey.shade300)),
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
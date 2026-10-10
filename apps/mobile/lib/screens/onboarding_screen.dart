import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = PageController(initialPage: 0);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView(
              controller: ctrl,
              children: const [
                _Page(icon: Icons.privacy_tip, title: 'Your calls stay yours', body: 'Calls are never recorded unless the other side taps Approve.'),
                _Page(icon: Icons.timer, title: 'They can stop it anytime', body: 'Withdrawing consent stops saving within 2 seconds. Both sides are told.'),
                _Page(icon: Icons.history, title: 'History you control', body: 'Pick 24h, 7d, 30d or 90d. Videos delete themselves; the log stays.'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/auth'), child: const Text('Skip')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(onPressed: () => Navigator.pushReplacementNamed(context, '/auth'), child: const Text('Next')),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _Page({required this.icon, required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 72, color: const Color(0xFF1A73E8)),
        const SizedBox(height: 24),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(body, textAlign: TextAlign.center),
      ]),
    );
  }
}

// Shared widgets. Rule from T0: recording status is never color-only.
import 'package:flutter/material.dart';
import '../core/app_tokens.dart';

class CgRecordingPill extends StatelessWidget {
  final String timeText; // e.g. 04:32
  const CgRecordingPill({super.key, required this.timeText});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Recording indicator, ${AppTokens.recordingLabel} $timeText',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTokens.recordingAlert,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const _BlinkingDot(),
          const SizedBox(width: 8),
          Text('${AppTokens.recordingLabel} $timeText',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();
  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c,
      child: const Icon(Icons.circle, size: 10, color: Colors.white),
    );
  }
}

class CgEmptyState extends StatelessWidget {
  final String text;
  final String actionLabel;
  final VoidCallback? onAction;
  const CgEmptyState({super.key, required this.text, this.actionLabel = 'Start a call', this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.inbox, size: 48, color: AppTokens.secondary),
        const SizedBox(height: 12),
        Text(text, style: const TextStyle(fontSize: 14)),
        if (onAction != null) ...[
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ]),
    );
  }
}

class CgErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const CgErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: AppTokens.error),
        const SizedBox(height: 12),
        const Text('Could not load — Retry', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary),
          child: const Text('Retry'),
        ),
      ]),
    );
  }
}

class CgOfflineBanner extends StatelessWidget {
  const CgOfflineBanner({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTokens.warning,
      padding: const EdgeInsets.all(8),
      child: const Text('No connection — saving paused, requests queued',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

class CgNotice extends StatelessWidget {
  final String text;
  final String actionLabel;
  final VoidCallback? onAction;
  const CgNotice({super.key, required this.text, this.actionLabel = 'Review', this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: AppTokens.textPrimary, borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
      child: Row(children: [
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13))),
        TextButton(onPressed: onAction, child: Text(actionLabel, style: const TextStyle(color: AppTokens.primary))),
      ]),
    );
  }
}

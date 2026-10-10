// Recording + delete dialogs. Copy matches design/components.md exactly — both platforms show this.
import 'package:flutter/material.dart';
import '../core/app_tokens.dart';

Future<bool> cgRequestDialog(BuildContext context, {required String who, required String purpose, required int minutes, required String quality, required bool audio, required bool video}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => AlertDialog(
      title: const Text('Allow recording?'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$who · purpose: $purpose · $minutes min · $quality · ${audio ? 'audio' : 'no audio'}${video ? ' + video' : ''}'),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Decline')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primary),
          child: const Text('Approve'),
        ),
      ],
    ),
  ).then((v) => v ?? false);
}

Future<bool> cgWithdrawDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Withdraw consent?'),
      content: const Text('Saving stops within 2 seconds. Both sides are told. This is logged.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep going')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppTokens.error),
          child: const Text('Stop saving'),
        ),
      ],
    ),
  ).then((v) => v ?? false);
}

Future<bool> cgDeleteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete forever?'),
      content: const Text('Video + thumbnails gone now. Log entry stays ~12 months.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppTokens.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  ).then((v) => v ?? false);
}

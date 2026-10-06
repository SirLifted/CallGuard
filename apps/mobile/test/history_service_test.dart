// Stage Q: history follows the server list; delete refreshes.
import 'package:flutter_test/flutter_test.dart';
import 'package:callguard/recording/history_service.dart';

void main() {
  HistoryService make({List<Map<String, dynamic>> rows = const [], bool fail = false, List<String> removed = const []}) {
    final gone = List<String>.from(removed);
    return HistoryService(
      loader: () => fail ? Future.error('down') : Future.value(rows),
      remover: (id) async => gone.add(id),
    );
  }

  test('refresh fills server rows', () async {
    final svc = make(rows: [
      {'id': 'a', 'status': 'STOPPED'}
    ]);
    await svc.refresh();
    expect(svc.state.items.length, 1);
    expect(svc.state.loading, isFalse);
    expect(svc.state.error, '');
  });

  test('failure shows Retry wording per T0', () async {
    final svc = make(fail: true);
    await svc.refresh();
    expect(svc.state.items, isEmpty);
    expect(svc.state.error, 'Could not load — Retry');
  });

  test('remove deletes then refreshes', () async {
    final gone = <String>[];
    final svc = HistoryService(
      loader: () async => [],
      remover: (id) async => gone.add(id),
    );
    await svc.remove('r1');
    expect(gone, ['r1']);
    expect(svc.state.items, isEmpty);
  });
}

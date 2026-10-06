// Stage E app side: history list state.
// Plain language: shows what the server lists. Expired/shredded rows simply stop appearing;
// the app never hides or keeps anything on its own.
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryState {
  final List<Map<String, dynamic>> items;
  final bool loading;
  final String error;
  const HistoryState({this.items = const [], this.loading = false, this.error = ''});

  HistoryState copyWith({List<Map<String, dynamic>>? items, bool? loading, String? error}) {
    return HistoryState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class HistoryService extends StateNotifier<HistoryState> {
  final Future<List<Map<String, dynamic>>> Function() loader;
  final Future<void> Function(String id) remover;
  HistoryService({required this.loader, required this.remover}) : super(const HistoryState());

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: '');
    try {
      state = state.copyWith(items: await loader(), loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: 'Could not load — Retry');
    }
  }

  Future<void> remove(String id) async {
    // Delete-forever confirm lives in the dialog (T0 wording); this just calls it then refreshes.
    await remover(id);
    await refresh();
  }
}

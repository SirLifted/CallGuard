// Saved contacts (favorites): the app's own address book, same on web/PC/phone.
// Reads/writes the favorites table directly (RLS: own rows only).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesState {
  final List<Map<String, dynamic>> items; // [{id, display_name}]
  final bool loading;
  final String error;
  const FavoritesState({this.items = const [], this.loading = false, this.error = ''});

  bool isFav(String id) => items.any((e) => e['id'] == id);

  FavoritesState copyWith({List<Map<String, dynamic>>? items, bool? loading, String? error}) {
    return FavoritesState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class FavoritesService extends StateNotifier<FavoritesState> {
  FavoritesService() : super(const FavoritesState());

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: '');
    try {
      final client = Supabase.instance.client;
      final favRows =
          await client.from('favorites').select('fav_user_id') as List;
      final ids = [for (final r in favRows) (r as Map)['fav_user_id'] as String];
      if (ids.isEmpty) {
        state = state.copyWith(items: const [], loading: false);
        return;
      }
      final users =
          await client.from('users').select('id,display_name').inFilter('id', ids) as List;
      state = state.copyWith(
          items: [for (final u in users) (u as Map).cast<String, dynamic>()], loading: false);
    } catch (_) {
      state = state.copyWith(loading: false, error: 'Could not load — Retry');
    }
  }

  Future<void> toggle(String favUserId) async {
    try {
      final client = Supabase.instance.client;
      final me = client.auth.currentUser!.id;
      if (state.isFav(favUserId)) {
        await client.from('favorites').delete().eq('user_id', me).eq('fav_user_id', favUserId);
      } else {
        await client.from('favorites').insert({'user_id': me, 'fav_user_id': favUserId});
      }
      await refresh();
    } catch (_) {
      state = state.copyWith(error: 'Could not save — Retry');
    }
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesService, FavoritesState>((ref) => FavoritesService());

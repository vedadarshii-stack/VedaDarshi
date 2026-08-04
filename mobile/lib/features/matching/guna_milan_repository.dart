import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/vedika/vedika_client.dart';
import 'guna_milan_data.dart';

/// Ashtakoota Gun Milan matching — wraps `POST /v2/astrology/guna-milan`.
///
/// **In-memory cache only**, unlike panchang/horoscope which cache to
/// Firestore once per day — a match result here is cheap to recompute and
/// there's no "once per day per language" cost pressure, since this screen
/// is only ever reached by an explicit user action (the Select screen's
/// "Match Kundlis" CTA), never loaded eagerly on app start. Keyed by BOTH
/// partners' birth params (a [GunaMilanMatchRequest] record), so re-opening
/// the result for the same two people within one app session is instant
/// and free instead of a second billed call.
class GunaMilanRepository {
  GunaMilanRepository(this._client);

  final VedikaClient _client;
  final Map<GunaMilanMatchRequest, GunaMilanResult> _cache = {};

  Future<GunaMilanResult> match(GunaMilanMatchRequest request) async {
    final cached = _cache[request];
    if (cached != null) return cached;

    final data = await _client.post(
      '/v2/astrology/guna-milan',
      body: {
        'male': request.male.toJson(),
        'female': request.female.toJson(),
      },
    );
    final result = GunaMilanResult.fromJson(data);
    _cache[request] = result;
    return result;
  }
}

final gunaMilanRepositoryProvider = Provider<GunaMilanRepository>((ref) {
  return GunaMilanRepository(ref.watch(vedikaClientProvider));
});

/// One Gun Milan match result, cached per [GunaMilanMatchRequest].
///
/// Riverpod's `.family` already dedupes concurrent watchers of the SAME
/// request (e.g. a rebuild mid-flight), and [GunaMilanRepository]'s own
/// cache map makes a genuinely repeated request (returning to this screen
/// later in the session) resolve instantly instead of a second network
/// call. Call `ref.invalidate(gunaMilanResultProvider(request))` to force a
/// retry after a failure — the repository cache only ever stores
/// successes, so invalidating a failed request re-hits the network rather
/// than replaying the same error.
final gunaMilanResultProvider =
    FutureProvider.family<GunaMilanResult, GunaMilanMatchRequest>((
      ref,
      request,
    ) {
      return ref.watch(gunaMilanRepositoryProvider).match(request);
    });

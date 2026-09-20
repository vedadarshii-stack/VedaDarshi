import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_controller.dart';

/// Muhurat descriptions authored in the admin console.
///
/// BUILT 20 Sep 2026, completing the Muhurat Content CMS. The console could
/// already write the twelve `muhuratContent/{kind}` documents, but nothing in
/// `mobile/lib` read them, so the screen carried a "saved, but not live yet"
/// notice.
///
/// ## These OVERRIDE a shipped default; they do not fill a blank
///
/// Unlike festivals, every one of these twelve already has copy in the app:
/// the seven choghadiya meanings are l10n keys in all five languages (see
/// `_bestForText` in `muhurat_timings_screen.dart`), and the five windows
/// have localised names. So an authored row REPLACES a working translated
/// string.
///
/// ⚠️ **That makes a bad edit here a wrong astrological claim, not a typo.**
/// Rahu Kaal is inauspicious by definition; a description saying otherwise
/// would contradict the warning tint the same card is painted with. The
/// override exists because the client asked for editorial control, and the
/// resolution order below is what keeps it safe: an EMPTY or unpublished
/// document changes nothing, so the shipped translation is the floor rather
/// than something a blank field can erase.
class CmsMuhuratRepository {
  CmsMuhuratRepository(this._locale);

  final String _locale;

  static const String collectionName = 'muhuratContent';

  /// Published descriptions keyed by the console's fixed `kind` id.
  ///
  /// The twelve ids are a closed set the console enforces — `rahuKaal`,
  /// `yamaganda`, `gulika`, `abhijit`, `brahmaMuhurta`, and
  /// `choghadiya{Kaal,Shubh,Rog,Udveg,Char,Labh,Amrit}`. An id outside that
  /// set simply never matches a lookup, so a stray document is inert rather
  /// than a crash.
  Future<Map<String, String>> fetchByKind() async {
    final snap = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('status', isEqualTo: 'published')
        .get();

    final byKind = <String, String>{};
    for (final doc in snap.docs) {
      final text = _localized(doc.data()['description'], _locale);
      // A published-but-empty document must NOT shadow the bundled
      // translation — that is how an editor who publishes a half-finished row
      // would otherwise blank the line for every user.
      if (text == null || text.trim().isEmpty) continue;
      byKind[doc.id] = text.trim();
    }
    return byKind;
  }

  /// locale → `en` → any non-empty, same contract as quotes and festivals.
  static String? _localized(dynamic field, String locale) {
    if (field is String) return field;
    if (field is! Map) return null;
    final map = field.cast<String, dynamic>();
    for (final key in [locale, 'en']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    for (final value in map.values) {
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }
}

/// Published muhurat descriptions by kind; empty on any failure.
///
/// Empty means "nothing authored", which is the normal state and correctly
/// leaves every existing translated string in place.
final cmsMuhuratProvider = FutureProvider<Map<String, String>>((ref) async {
  final locale = ref.watch(localeControllerProvider)?.languageCode ?? 'en';
  try {
    return await CmsMuhuratRepository(locale).fetchByKind();
  } catch (_) {
    return const {};
  }
});

/// The console's `kind` id for each of the five named windows.
///
/// Kept beside the repository rather than at the call site so the app and the
/// console cannot drift: these strings must match `MUHURAT_KINDS` in
/// `admin/src/lib/muhurat.ts` exactly, and a mismatch is silent — the lookup
/// just never hits.
abstract final class MuhuratKindIds {
  static const String rahuKaal = 'rahuKaal';
  static const String yamaganda = 'yamaganda';
  static const String gulika = 'gulika';
  static const String abhijit = 'abhijit';
  static const String brahmaMuhurta = 'brahmaMuhurta';

  /// `'Labh'` → `'choghadiyaLabh'`. Vedika's period names arrive in mixed
  /// spellings and casings (`Kaal`/`Kala`), so the caller normalises first
  /// and passes the canonical suffix.
  static String choghadiya(String canonicalSuffix) =>
      'choghadiya$canonicalSuffix';
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../kundli/kundli_repository.dart';
import '../profile/birth_profile_repository.dart';
import 'zodiac_sign.dart';

/// The signed-in user's OWN rashi, derived from their birth details.
///
/// ADDED 21 Aug 2026, replacing `HoroscopeStaticData.userSignId`, which was
/// the constant `'simha'`. Every user of the app — whatever their birth date
/// — was shown "Simha · Leo" as their sign on the Home horoscope teaser, on
/// the Horoscope detail screen, and as the "Your sign" badge in the all-signs
/// grid. A profile born 1 Jan 1995 was told they were a Leo.
///
/// ## Why the MOON sign, not the Sun sign
///
/// Vedic astrology reads the horoscope from the Moon's rashi (chandra
/// rashi), not the Sun sign that Western horoscopes use. `KundliData.moonSign`
/// is exactly that, and it comes from the same `/v2/astrology/kundli` call
/// the Kundli screen already makes — so for a user who has opened their
/// chart this costs nothing, and for one who hasn't it is a single call
/// cached for a year against unchanging birth details.
///
/// Deriving a Sun sign locally from the birth date would have been cheaper
/// and would have been WRONG for this app: it answers a different question,
/// and would disagree with the Kundli screen's own Rashi row for most users.
///
/// ## Resolves to null rather than guessing
///
/// Returns `null` while the profile or chart is loading, when no profile
/// exists (a guest), on a failed fetch, or when Vedika returns a `moonSign`
/// this app does not recognise. Callers must render a neutral state for
/// null — **never** substitute a default sign. Showing the wrong rashi is
/// the bug this provider exists to fix, and a fallback would reintroduce it
/// in a quieter form.
final userZodiacSignProvider = Provider<ZodiacSign?>((ref) {
  final profile = ref.watch(birthProfileProvider).valueOrNull;
  if (profile == null) return null;

  // Reuses the exact request the Kundli screen builds, so both share one
  // cached fetch rather than issuing two billed calls for the same chart.
  final request = KundliRequest.fromBirthProfile(profile);
  final kundli = ref.watch(kundliDataProvider(request)).valueOrNull;

  return zodiacSignFromEnglishName(kundli?.moonSign);
});

/// Maps an English rashi name as Vedika spells it (e.g. `"Sagittarius"`) to
/// the app's [ZodiacSign], or `null` if it matches none.
///
/// Case- and whitespace-insensitive because this crosses an API boundary and
/// the exact casing is not part of any contract we control.
ZodiacSign? zodiacSignFromEnglishName(String? englishName) {
  final needle = englishName?.trim().toLowerCase();
  if (needle == null || needle.isEmpty) return null;
  for (final sign in kZodiacSigns) {
    if (sign.englishName.toLowerCase() == needle) return sign;
  }
  return null;
}

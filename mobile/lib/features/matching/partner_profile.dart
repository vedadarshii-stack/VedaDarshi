import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/birth_profile.dart';

/// The OTHER person in a Gun Milan match, held for the current session.
///
/// ADDED 21 Aug 2026. Until now there was no way to supply one: both
/// "Change" buttons on the Kundli Matching screen were `onTap: () {}`, the
/// bride card was a permanent empty state, and the Result screen fell back
/// to `GunMilanStaticData.placeholderBridePartnerParams` — a hardcoded
/// Mumbai 1997 chart labelled "Ananya".
///
/// That fallback produced a real, specific verdict — "13.5 out of 36 · Not
/// recommended for marriage" — against a person who does not exist, and
/// offered it as a downloadable report. The constant's own doc comment said
/// **"Do not let this silently reach production"**; it had. This provider is
/// what lets the Result screen require a real second chart instead.
///
/// ## Deliberately NOT persisted
///
/// This is somebody else's date, time and place of birth — personal data
/// about a third party who is not the account holder and has not consented
/// to anything. Persisting it would mean storing it in Firestore under the
/// user's tree with no UI to review or delete it, and the privacy policy
/// currently describes stored birth details as the account owner's own.
/// Keeping it in memory means a match is an act, not a record: the user
/// enters the details, gets the reading, and nothing is retained.
///
/// When multi-profile support lands (the family & friends feature the Birth
/// Details footer already promises) this should become a saved profile with
/// a proper management screen — at which point the consent and deletion
/// story has to be designed, not inherited from here.
class PartnerProfile extends Notifier<BirthProfile?> {
  @override
  BirthProfile? build() => null;

  void set(BirthProfile profile) => state = profile;

  void clear() => state = null;
}

final partnerProfileProvider = NotifierProvider<PartnerProfile, BirthProfile?>(
  PartnerProfile.new,
);

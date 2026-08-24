import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/birth_profile.dart';

/// Extra people whose charts the user wants to look at — family, friends —
/// held for the current session.
///
/// ADDED 21 Aug 2026. The Kundli screen's "Add family or friend" button was
/// `onTap: () {}`: a fully-styled dashed control that did nothing, and the
/// only honest entry point the app had for a feature the Birth Details
/// footer already promises.
///
/// ## A LIST, and separate from the Gun Milan partner
///
/// Deliberately not the same slot as `partnerProfileProvider`. They hold the
/// same shape of data, but they are different intents: one is "the person I
/// am matching against", the other is "people whose charts I look at". Share
/// one slot and adding a family member here silently replaces the partner
/// you were about to match — a data-loss bug with no visible cause.
///
/// A list rather than a single value because "family or friend" is plural by
/// name, and a user comparing two relatives' charts should not have to
/// re-enter one to see the other.
///
/// ## Not persisted — same reasoning as the match partner
///
/// These are other people's birth details. Storing them would put a third
/// party's personal data in Firestore under this account with no UI to
/// review or delete it, and the privacy policy describes stored birth
/// details as the account owner's own. They live for the session.
///
/// When real multi-profile support lands (the `/users/{uid}/birthProfiles`
/// subcollection was built to hold more than the `primary` document for
/// exactly this reason), this becomes the migration target — and the consent
/// and deletion story has to be designed then, not inherited from here.
class GuestProfiles extends Notifier<List<BirthProfile>> {
  @override
  List<BirthProfile> build() => const [];

  void add(BirthProfile profile) {
    state = [...state, profile];
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.length) return;
    final next = [...state]..removeAt(index);
    state = next;
  }
}

final guestProfilesProvider =
    NotifierProvider<GuestProfiles, List<BirthProfile>>(GuestProfiles.new);

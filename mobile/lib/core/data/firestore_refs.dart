/// Centralised Firestore path constants — kept here so collection/document
/// names are never scattered as string literals across the data layer.
library;

/// Top-level collection holding one document per signed-in user, keyed by
/// their Firebase Auth `uid` (`/users/{uid}`).
const String usersCollection = 'users';

/// SUBCOLLECTION of `/users/{uid}` (i.e. `/users/{uid}/birthProfiles/...`) —
/// deliberately NOT a field on the user document, because the approved
/// product design promises the ability to add family & friends birth
/// profiles later (see the Birth Details screen's footer copy). Modelling
/// this as a subcollection from day one means that future multi-profile
/// support is additive: no migration of the user document's shape is needed.
const String birthProfilesCollection = 'birthProfiles';

/// Reserved document id, within [birthProfilesCollection], for the birth
/// profile belonging to the account owner themselves (as opposed to a future
/// family/friend profile, which would get its own generated id).
const String primaryProfileId = 'primary';

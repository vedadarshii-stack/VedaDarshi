/// Strips a trailing vendor-attribution line from free-text fields Vedika
/// sometimes returns (AI-generated interpretation/prediction copy, seen live
/// as `"…might shape your long term growth? — Vedika"` on a Gun Milan
/// `interpretation.marriageProspects` sentence, 26 Aug 2026). Vedika is our
/// upstream data vendor and must never be visible to end users — see
/// `projects/CLAUDE.md`'s Vedika API integration section — so any prose
/// field parsed from a Vedika response body is expected to run through
/// [stripVedikaAttribution] at the parse boundary before it ever reaches a
/// widget.
///
/// Only strips a trailing attribution — never touches attributions embedded
/// mid-sentence, which would risk mangling real content Vedika legitimately
/// returned.
library;

/// Matches a trailing "— Vedika" (or "-- vedika", "-Vedika.", "―Vedika", …)
/// at the very end of the string, allowing any whitespace before the dash
/// (including a line break, so the attribution can sit on its own line) and
/// an optional trailing period. Case-insensitive since Vedika's own casing
/// of its name in generated copy isn't guaranteed.
///
/// The dash character class covers the hyphen-minus, en dash, em dash,
/// horizontal bar and minus sign — the variants a text-generation model is
/// realistically going to reach for.
final RegExp _trailingVedikaAttribution = RegExp(
  r'\s*[-‐‑‒–—―−]{1,2}\s*vedika\.?\s*$',
  caseSensitive: false,
);

/// Removes a trailing "— Vedika"-style attribution from [text], if present,
/// and trims the result. Returns `null` for `null`/blank input, or when
/// stripping the attribution leaves nothing behind.
///
/// Safe to call on every free-text field parsed from a Vedika response —
/// short structured values (a sign name, a lucky color, a date) can never
/// match, since the pattern requires a dash immediately followed by
/// "vedika" at the string's end.
String? stripVedikaAttribution(String? text) {
  if (text == null) return null;
  final stripped = text.replaceFirst(_trailingVedikaAttribution, '').trim();
  return stripped.isEmpty ? null : stripped;
}

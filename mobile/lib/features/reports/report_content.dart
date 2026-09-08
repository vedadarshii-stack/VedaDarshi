import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';
import '../kundli/kundli_json.dart';

/// A premium report's readable content, normalised into titled sections of
/// short lines.
///
/// BUILT 2 Sep 2026 for the client's request: *"for reports after clicking
/// show sample glimpse report … so that it can engage users"*. Before this,
/// tapping a report card either opened the paywall showing nothing at all
/// (premium) or did literally nothing (free).
///
/// ## Why one shared shape instead of eight screens
///
/// Each of the eight reports comes from a DIFFERENT Vedika endpoint with a
/// completely different response shape — career returns `careerTiming`,
/// health returns `vulnerabilities`, numerology returns four numbered
/// `interpretations`. Eight bespoke screens would be eight places to keep
/// consistent with the glimpse/paywall behaviour. Instead each endpoint gets
/// a small ADAPTER below that maps its own fields into these sections, and
/// one screen renders them.
///
/// ## Section titles are semantic, not per-report
///
/// [ReportSectionKind] is a fixed, small vocabulary so its titles are seven
/// l10n keys rather than twenty-four. Each adapter picks the kind that is
/// TRUE of the field it is mapping — never a bucket chosen to make the
/// layout look full.
///
/// ## Every line is Vedika's own text
///
/// Nothing here invents content. Where a line needs a label ("Best day",
/// "Life path"), the label is ours and localised by the caller; the VALUE is
/// always a string the API returned. If an endpoint gives us nothing, the
/// report renders empty and the screen says so — see the "must be REAL" note
/// on `PremiumGlimpse`.
@immutable
class ReportContent {
  const ReportContent({this.sections = const []});

  final List<ReportSection> sections;

  bool get isEmpty => sections.every((section) => section.lines.isEmpty);
}

/// The seven kinds of section any report can contain. Deliberately generic:
/// see the class doc on [ReportContent].
enum ReportSectionKind {
  overview,
  highlights,
  timing,
  guidance,
  remedies,
  strengths,
  challenges,
}

@immutable
class ReportSection {
  const ReportSection(this.kind, this.lines);

  final ReportSectionKind kind;
  final List<ReportLine> lines;
}

/// One line of a report. [label] is an optional short lead-in rendered in
/// the ink colour before [text]; both are shown as-is.
@immutable
class ReportLine {
  const ReportLine(this.text, {this.label});

  final String? label;
  final String text;
}

/// Builds a [ReportContent] for `reportId` out of the raw `data` object its
/// endpoint returned.
///
/// Unknown ids and unexpected payloads yield an EMPTY report rather than
/// throwing — a report we cannot read must degrade to "nothing to show",
/// never to a crash or to invented filler.
ReportContent buildReportContent(
  String reportId,
  Map<String, dynamic> json,
  AppLocalizations l10n,
) {
  return switch (reportId) {
    'complete' => _complete(json, l10n),
    'career' => _career(json, l10n),
    'marriage' => _marriage(json, l10n),
    'health' => _health(json),
    'wealth' => _wealth(json, l10n),
    'sadeSati' => _sadeSati(json, l10n),
    'gemstone' => _gemstone(json, l10n),
    'numerology' => _numerology(json, l10n),
    _ => const ReportContent(),
  };
}

// ---------------------------------------------------------------------------
// Adapters. One per endpoint; each reads only fields observed on a live
// response (probed 2 Sep 2026), and each field is individually optional.
// ---------------------------------------------------------------------------

/// `POST /v2/reports/complete` — the Complete Life Report the client
/// reported as missing. Same payload shape as `/v2/reports/birth-chart-report`
/// (verified), so it carries the whole natal reading: ascendant, moon sign,
/// yogas and all twelve houses.
ReportContent _complete(Map<String, dynamic> json, AppLocalizations l10n) {
  final overview = <ReportLine>[
    if (json['ascendantSign'] case final String sign when sign.isNotEmpty)
      ReportLine(sign, label: l10n.lblLagna),
    if (json['moonSign'] case final String sign when sign.isNotEmpty)
      ReportLine(sign, label: l10n.lblRashi),
  ];
  final yogas = _mapList(json['yogas'], (item) {
    final name = item['name'] as String?;
    final meaning = parseFreeText(item['meaning']);
    if (name == null) return null;
    return ReportLine(meaning ?? '', label: name);
  });
  final houses = _mapList(json['houses'], (item) {
    final interpretation = parseFreeText(item['interpretation']);
    if (interpretation == null) return null;
    final significance = item['significance'] as String?;
    return ReportLine(interpretation, label: significance);
  });
  return ReportContent(
    sections: [
      ReportSection(ReportSectionKind.overview, overview),
      ReportSection(ReportSectionKind.highlights, yogas),
      ReportSection(ReportSectionKind.guidance, houses),
    ],
  );
}

/// `POST /v2/reports/career-report`.
ReportContent _career(Map<String, dynamic> json, AppLocalizations l10n) {
  final overview = <ReportLine>[
    if (json['workStyle'] case final String value when value.isNotEmpty)
      ReportLine(value),
    if (json['tenthHouseSign'] case final String sign when sign.isNotEmpty)
      ReportLine(sign, label: l10n.lblCareerHouse),
    if (json['tenthLord'] case final String lord when lord.isNotEmpty)
      ReportLine(lord, label: l10n.lblCareerLord),
  ];
  final highlights = <ReportLine>[
    for (final career in parseStrings(json['primaryCareers']))
      ReportLine(career),
    ..._mapList(json['careerIndicators'], (item) {
      final role = item['role'] as String?;
      if (role == null) return null;
      return ReportLine(role, label: item['planet'] as String?);
    }),
  ];
  final timing = _mapList(json['careerTiming'], (item) {
    final influence = item['influence'] as String?;
    if (influence == null) return null;
    return ReportLine(influence, label: item['period'] as String?);
  });
  return ReportContent(
    sections: [
      ReportSection(ReportSectionKind.overview, overview),
      ReportSection(ReportSectionKind.highlights, highlights),
      ReportSection(ReportSectionKind.timing, timing),
    ],
  );
}

/// `POST /v2/reports/marriage-report`.
ReportContent _marriage(Map<String, dynamic> json, AppLocalizations l10n) {
  final overview = <ReportLine>[
    if (parseFreeText(json['assessment']) case final value?) ReportLine(value),
    if (parseFreeText(json['summary']) case final value?) ReportLine(value),
  ];
  final highlights = <ReportLine>[
    if (json['seventhHouseSign'] case final String sign when sign.isNotEmpty)
      ReportLine(sign, label: l10n.lblPartnershipHouse),
    if (json['seventhLord'] case final String lord when lord.isNotEmpty)
      ReportLine(lord, label: l10n.lblPartnershipLord),
    if (json['venusSign'] case final String sign when sign.isNotEmpty)
      ReportLine(sign, label: l10n.lblVenus),
  ];
  return ReportContent(
    sections: [
      ReportSection(ReportSectionKind.overview, overview),
      ReportSection(ReportSectionKind.highlights, highlights),
    ],
  );
}

/// `POST /v2/reports/health-report`.
ReportContent _health(Map<String, dynamic> json) {
  final vulnerabilities = _mapList(json['vulnerabilities'], (item) {
    final description = parseFreeText(item['description']);
    if (description == null) return null;
    return ReportLine(description, label: item['bodyArea'] as String?);
  });
  final healing = _mapList(json['healingPeriods'], (item) {
    final advice = parseFreeText(item['advice']);
    final description = parseFreeText(item['description']);
    final text = advice ?? description;
    if (text == null) return null;
    return ReportLine(text, label: item['planet'] as String?);
  });
  return ReportContent(
    sections: [
      ReportSection(ReportSectionKind.challenges, vulnerabilities),
      ReportSection(ReportSectionKind.timing, healing),
    ],
  );
}

/// `POST /v2/career/finance/wealth-timing`. Note the useful content is
/// nested under `prediction`, with the headline guidance at the top level.
ReportContent _wealth(Map<String, dynamic> json, AppLocalizations l10n) {
  final prediction = _asMap(json['prediction']) ?? const {};
  final overview = <ReportLine>[
    if (parseFreeText(json['guidance']) case final value?) ReportLine(value),
    if (parseFreeText(json['rationale']) case final value?) ReportLine(value),
  ];
  final areas = _mapList(prediction['areas'], (item) {
    final description = parseFreeText(item['description']);
    if (description == null) return null;
    return ReportLine(description, label: item['area'] as String?);
  });
  final dasha = _asMap(prediction['dasha']) ?? const {};
  final timing = <ReportLine>[
    if (dasha['mahaDashaLord'] case final String lord when lord.isNotEmpty)
      ReportLine(lord, label: l10n.lblMahadasha),
    if (dasha['antarDashaLord'] case final String lord when lord.isNotEmpty)
      ReportLine(lord, label: l10n.lblAntardasha),
  ];
  final remedies = [
    for (final remedy in parseStrings(prediction['remedies']))
      ReportLine(remedy),
  ];
  return ReportContent(
    sections: [
      ReportSection(ReportSectionKind.overview, overview),
      ReportSection(ReportSectionKind.highlights, areas),
      ReportSection(ReportSectionKind.timing, timing),
      ReportSection(ReportSectionKind.remedies, remedies),
    ],
  );
}

/// `POST /v2/astrology/sade-sati`. This endpoint uses snake_case keys where
/// the `/v2/reports/*` family uses camelCase — read both rather than
/// assuming one convention across Vedika.
ReportContent _sadeSati(Map<String, dynamic> json, AppLocalizations l10n) {
  final guidance = _asMap(json['guidance']) ?? const {};
  final overview = <ReportLine>[
    if (json['phase_name'] case final String phase when phase.isNotEmpty)
      ReportLine(phase, label: l10n.lblPhase),
    if (parseFreeText(json['description']) case final value?)
      ReportLine(value),
  ];
  final guidanceLines = <ReportLine>[
    if (parseFreeText(guidance['summary']) case final value?)
      ReportLine(value),
    for (final item in parseStrings(guidance['do'])) ReportLine(item),
  ];
  final challenges = [
    for (final item in parseStrings(guidance['avoid'])) ReportLine(item),
    for (final item in parseStrings(json['effects'])) ReportLine(item),
  ];
  final remedies = <ReportLine>[
    if (parseFreeText(guidance['mantra']) case final value?)
      ReportLine(value, label: l10n.lblMantra),
    for (final item in parseStrings(json['remedies'])) ReportLine(item),
  ];
  return ReportContent(
    sections: [
      ReportSection(ReportSectionKind.overview, overview),
      ReportSection(ReportSectionKind.guidance, guidanceLines),
      ReportSection(ReportSectionKind.challenges, challenges),
      ReportSection(ReportSectionKind.remedies, remedies),
    ],
  );
}

/// `POST /v2/astrology/remedies/gemstone`. The response is a list of
/// `crystals`, one per weak planet, each nesting its own gemstone / mantra /
/// charity / fasting advice.
ReportContent _gemstone(Map<String, dynamic> json, AppLocalizations l10n) {
  final highlights = <ReportLine>[];
  final remedies = <ReportLine>[];
  for (final entry in _listOfMaps(json['crystals'])) {
    final planet = entry['planet'] as String?;
    final gemstone = _asMap(entry['gemstone']) ?? const {};
    if (gemstone['gemstone'] case final String name when name.isNotEmpty) {
      highlights.add(ReportLine(name, label: planet));
    }
    if (gemstone['metal'] case final String metal when metal.isNotEmpty) {
      final weight = gemstone['weight'] as String?;
      highlights.add(
        ReportLine(weight == null ? metal : '$metal · $weight',
            label: l10n.lblSetting),
      );
    }
    if (gemstone['dayToWear'] case final String day when day.isNotEmpty) {
      highlights.add(ReportLine(day, label: l10n.lblDayToWear));
    }
    final mantra = _asMap(entry['mantra']) ?? const {};
    if (mantra['mantra'] case final String value when value.isNotEmpty) {
      remedies.add(ReportLine(value, label: planet));
    }
  }
  return ReportContent(
    sections: [
      ReportSection(ReportSectionKind.highlights, highlights),
      ReportSection(ReportSectionKind.remedies, remedies),
    ],
  );
}

/// `POST /v2/astrology/numerology/complete-report`.
///
/// ⚠️ **REWRITTEN 8 Sep 2026 — this adapter had been reading a shape the live
/// API never returns.** It looked for top-level `lifePath` / `destinyNumber` /
/// `soulNumber` / `personalityNumber` and an `interpretations` map. In
/// production every one of those is **null**: the six numbers are nested under
/// **`coreNumbers`**, and each one carries its own description, keywords,
/// strengths and challenges rather than living in a parallel map.
///
/// The result was an adapter that produced an entirely EMPTY [ReportContent]
/// from a perfectly good HTTP 200, which the screen rendered as
/// `reportEmptyMessage` — indistinguishable from "this report does not exist"
/// and easily mistaken for the API never being called at all. Numerology was
/// the ONLY one of the eight affected; the other seven were re-verified
/// against live production payloads in the same pass.
///
/// The legacy branch is kept: it costs a few lines and lets an
/// already-cached sandbox-shaped payload still render rather than going blank.
///
/// **Lesson: an adapter verified against the sandbox is not verified.** The
/// sandbox served a different JSON shape for this endpoint, so the original
/// verification pass was measuring the wrong thing.
ReportContent _numerology(Map<String, dynamic> json, AppLocalizations l10n) {
  final core = _asMap(json['coreNumbers']);
  return core == null
      ? _numerologyLegacy(json, l10n)
      : _numerologyCoreNumbers(core, l10n);
}

/// The live production shape: `coreNumbers.{lifePath,destiny,soulUrge,…}`.
ReportContent _numerologyCoreNumbers(
  Map<String, dynamic> core,
  AppLocalizations l10n,
) {
  // Ordered most-significant first rather than alphabetically — a reader
  // looks for their life path number, not their maturity number, and the
  // premium glimpse cuts the list off partway.
  final ordered = <(String, String)>[
    ('lifePath', l10n.lblLifePath),
    ('destiny', l10n.lblDestiny),
    ('soulUrge', l10n.lblSoulUrge),
    ('personality', l10n.lblPersonality),
    ('birthday', l10n.lblBirthdayNumber),
    ('maturity', l10n.lblMaturity),
  ];

  final overview = <ReportLine>[];

  // ⚠️ DE-DUPLICATION IS REQUIRED HERE, not a nicety.
  //
  // Numerology derives six numbers from one person, and two of them
  // frequently land on the SAME digit — this chart returns soulUrge 6 and
  // personality 6. Vedika keys its text off the digit, so both entries carry
  // a byte-identical description, life lesson, strengths list and challenges
  // list. Rendered naively that repeats whole paragraphs and chips verbatim
  // on screen, which reads as a bug rather than as two numbers agreeing.
  //
  // Prose keeps ONE copy and merges the labels ("Soul urge · Personality"),
  // which is both shorter and more informative than either repeating it or
  // silently dropping the second number. Chips collapse case-insensitively.
  final byText = <String, List<String>>{};
  final lessonByText = <String, List<String>>{};
  final strengths = <String, ReportLine>{};
  final challenges = <String, ReportLine>{};

  for (final (key, label) in ordered) {
    final entry = _asMap(core[key]);
    if (entry == null) continue;

    if (parseInt(entry['number']) case final value?) {
      overview.add(ReportLine('$value', label: label));
    }
    // The description is the actual reading for that number, so it is
    // labelled with the number's name — otherwise six paragraphs arrive with
    // no indication of which is which.
    if (parseFreeText(entry['description']) case final value?) {
      (byText[value] ??= <String>[]).add(label);
    }
    if (parseFreeText(entry['lifeLesson']) case final value?) {
      (lessonByText[value] ??= <String>[]).add(label);
    }
    for (final item in parseStrings(entry['strengths'])) {
      strengths.putIfAbsent(item.toLowerCase(), () => ReportLine(item));
    }
    for (final item in parseStrings(entry['challenges'])) {
      challenges.putIfAbsent(item.toLowerCase(), () => ReportLine(item));
    }
  }

  List<ReportLine> merged(Map<String, List<String>> source) => [
    for (final entry in source.entries)
      ReportLine(entry.key, label: entry.value.join(' · ')),
  ];

  return ReportContent(
    sections: [
      ReportSection(ReportSectionKind.overview, overview),
      ReportSection(ReportSectionKind.highlights, merged(byText)),
      ReportSection(ReportSectionKind.guidance, merged(lessonByText)),
      ReportSection(ReportSectionKind.strengths, strengths.values.toList()),
      ReportSection(ReportSectionKind.challenges, challenges.values.toList()),
    ],
  );
}

/// The older flat shape, kept so a cached sandbox-era payload still renders.
ReportContent _numerologyLegacy(
  Map<String, dynamic> json,
  AppLocalizations l10n,
) {
  final interpretations = _asMap(json['interpretations']) ?? const {};
  ReportLine? number(String key, String label) {
    final value = parseInt(json[key]);
    return value == null ? null : ReportLine('$value', label: label);
  }

  final overview = <ReportLine>[
    ?number('lifePath', l10n.lblLifePath),
    ?number('destinyNumber', l10n.lblDestiny),
    ?number('soulNumber', l10n.lblSoulUrge),
    ?number('personalityNumber', l10n.lblPersonality),
  ];
  final highlights = <ReportLine>[];
  final strengths = <ReportLine>[];
  final challenges = <ReportLine>[];
  for (final key in const ['lifePath', 'destiny', 'soul', 'personality']) {
    final entry = _asMap(interpretations[key]);
    if (entry == null) continue;
    if (parseFreeText(entry['description']) case final value?) {
      highlights.add(ReportLine(value, label: entry['keywords'] as String?));
    }
    for (final item in parseStrings(entry['strengths'])) {
      strengths.add(ReportLine(item));
    }
    for (final item in parseStrings(entry['challenges'])) {
      challenges.add(ReportLine(item));
    }
  }
  return ReportContent(
    sections: [
      ReportSection(ReportSectionKind.overview, overview),
      ReportSection(ReportSectionKind.highlights, highlights),
      ReportSection(ReportSectionKind.strengths, strengths),
      ReportSection(ReportSectionKind.challenges, challenges),
    ],
  );
}

// ---------------------------------------------------------------------------
// Small JSON helpers. `kundli_json.dart` covers scalars and string lists;
// these two cover the list-of-objects and nested-object shapes the report
// endpoints use.
// ---------------------------------------------------------------------------

Map<String, dynamic>? _asMap(dynamic value) =>
    value is Map<String, dynamic> ? value : null;

List<Map<String, dynamic>> _listOfMaps(dynamic value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map<String, dynamic>) item,
  ];
}

List<ReportLine> _mapList(
  dynamic value,
  ReportLine? Function(Map<String, dynamic>) build,
) {
  return [
    for (final item in _listOfMaps(value)) ?build(item),
  ];
}

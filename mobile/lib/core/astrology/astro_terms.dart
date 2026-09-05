/// Native-script names for the CLOSED astrology vocabulary Vedika returns in
/// Latin transliteration.
///
/// BUILT 2 Sep 2026. The client asked, twice: *"whatever the language
/// selected by user output also in same language"*.
///
/// ## Why this exists at all
///
/// **Vedika cannot answer in another language.** Probed against PRODUCTION on
/// 2 Sep 2026: `?lang=hi`, `?language=hi`, `?locale=hi` and an
/// `Accept-Language: hi` request header all return identical English, and the
/// panchang terms come back as Latin transliteration ("Shashthi", "Bharani")
/// rather than Devanagari. So no request-side flag fixes this.
///
/// What CAN be fixed is the part of the output that is a **closed set**. A
/// tithi is always one of 16, a nakshatra one of 27, a yoga one of 27 — these
/// are fixed Sanskrit vocabularies with established native spellings, and
/// they are also the words a user actually reads at a glance on Panchang and
/// Kundli. Translating them here covers most of the visible surface without
/// touching a single API call.
///
/// **This does NOT translate the free-text paragraphs** — predictions,
/// interpretations, remedies. Those are open-ended prose and only Vedika (or
/// a paid translation pass) can localise them. Do not let this file create
/// the impression the whole app is translated.
///
/// ## The lookup is normalization-based, not exact-match
///
/// Vedika is inconsistent about spacing, case and diacritics across
/// endpoints ("Purva Phalguni", "purva_phalguni", "PurvaPhalguni" are all
/// plausible), so keys are reduced to lowercase alphanumerics before
/// matching. That makes the table robust to a spelling change upstream.
///
/// ## Unknown terms pass through UNCHANGED
///
/// A term that is not in the table returns exactly what Vedika sent. That is
/// deliberate: showing the English name is honest, whereas guessing at a
/// transliteration would put invented words in front of the user. If a term
/// shows in English, the fix is to add a row here — never to approximate it
/// at the call site.
///
/// ⚠️ **These are drafts and need a native-speaker/client review**, the same
/// caveat every other translation in this project carries. Tamil especially:
/// its nakshatra names are traditional Tamil words (Ardra → திருவாதிரை), not
/// transliterations of the Sanskrit, so an error here is a real word rather
/// than an odd spelling. The Tamil months are the Tamil solar months, which
/// map to the lunar masa only approximately.
library;

import 'dart:ui';

/// One term in the four non-English app languages. English needs no entry —
/// it is what Vedika already sent.
class _T {
  const _T(this.hi, this.te, this.ta, this.kn);

  final String hi;
  final String te;
  final String ta;
  final String kn;

  String? forLanguage(String code) => switch (code) {
    'hi' => hi,
    'te' => te,
    'ta' => ta,
    'kn' => kn,
    _ => null,
  };
}

/// Which vocabulary a term belongs to. Passing the right one matters: several
/// words appear in more than one set with different native forms — "Shravana"
/// is both a nakshatra and a lunar month, "Magha" both a nakshatra and a
/// month, "Jyeshtha" both a nakshatra and a month.
enum AstroTermKind {
  nakshatra,
  tithi,
  yoga,
  karana,
  vara,
  rashi,
  graha,
  masa,
  paksha,

  /// Gregorian month names, for the Panchang date line. Distinct from
  /// [masa], which is the LUNAR month — the two never coincide and must not
  /// share a table.
  gregorianMonth,

  /// Gregorian weekday names. Shares its English keys with [vara] but kept
  /// separate so a change to one cannot silently alter the other.
  gregorianWeekday,

  /// Lucky-colour names. A small closed set in practice — Vedika returns
  /// plain colour words ("Crimson", "Indigo", "Orange").
  colour,

  /// Compass directions, for the "Direction" glance tile and lucky
  /// direction.
  direction,

  /// The seven choghadiya period names (Amrit, Shubh, Labh, Char, Rog, Kaal,
  /// Udveg). A fixed classical set, so fully translatable — unlike the
  /// one-line descriptions Vedika ships alongside them.
  choghadiya,

  /// Vedika's overall-auspiciousness verdict words ("Good", "Excellent",
  /// "Challenging"). A small closed set, unlike the prose sentence that
  /// accompanies them.
  quality,
}

/// Returns [term] in [locale]'s script, or [term] unchanged when the language
/// is English or the word is not in the table.
///
/// Null-safe on purpose: every Vedika field this is applied to is nullable,
/// so callers can pass straight through without a guard.
String? localizeAstroTerm(String? term, AstroTermKind kind, Locale locale) {
  if (term == null) return null;
  final trimmed = term.trim();
  if (trimmed.isEmpty) return trimmed;

  final direct = _tableFor(kind)[_normalize(trimmed)];
  if (direct != null) {
    return direct.forLanguage(locale.languageCode) ?? trimmed;
  }

  // COMPOUND VALUES (added 4 Sep 2026). Vedika returns lucky colours and
  // directions as phrases — "Black or Blue", "White or Pink", "North-East" —
  // and a whole-string lookup misses every one of them. The client saw
  // exactly that: a lone "Black or Blue" sitting in an otherwise Telugu
  // glance grid.
  //
  // Only attempted for the small word-list vocabularies. A nakshatra or yoga
  // name can legitimately contain a separator ("Budha-Aditya"), and splitting
  // those would produce nonsense, so they keep the strict whole-string match
  // above.
  if (kind == AstroTermKind.colour || kind == AstroTermKind.direction) {
    final joined = _localizeCompound(trimmed, kind, locale);
    if (joined != null) return joined;
  }
  return trimmed;
}

/// Translates each word of a phrase like "Black or Blue", preserving the
/// connector. Returns null unless EVERY part is known — a half-translated
/// "నలుపు or Blue" would look broken, so it is better to leave the original
/// English intact and add the missing row to the table.
String? _localizeCompound(String value, AstroTermKind kind, Locale locale) {
  final table = _tableFor(kind);
  final match = RegExp(
    r'^(.+?)\s*(or|and|/|-|&)\s*(.+)$',
    caseSensitive: false,
  ).firstMatch(value);
  if (match == null) return null;

  final left = table[_normalize(match.group(1)!)]?.forLanguage(
    locale.languageCode,
  );
  final right = table[_normalize(match.group(3)!)]?.forLanguage(
    locale.languageCode,
  );
  if (left == null || right == null) return null;

  final connector = match.group(2)!.toLowerCase();
  // "/" and "-" are punctuation and stay as-is; "or"/"and" are words and get
  // translated via the same table so the phrase reads naturally.
  final joiner = switch (connector) {
    'or' => _connectorOr.forLanguage(locale.languageCode) ?? 'or',
    'and' => _connectorAnd.forLanguage(locale.languageCode) ?? 'and',
    _ => connector,
  };
  return connector == '/' || connector == '-'
      ? '$left$joiner$right'
      : '$left $joiner $right';
}

const _T _connectorOr = _T('या', 'లేదా', 'அல்லது', 'ಅಥವಾ');
const _T _connectorAnd = _T('और', 'మరియు', 'மற்றும்', 'ಮತ್ತು');

Map<String, _T> _tableFor(AstroTermKind kind) => switch (kind) {
  AstroTermKind.nakshatra => _nakshatra,
  AstroTermKind.tithi => _tithi,
  AstroTermKind.yoga => _yoga,
  AstroTermKind.karana => _karana,
  AstroTermKind.vara => _vara,
  AstroTermKind.rashi => _rashi,
  AstroTermKind.graha => _graha,
  AstroTermKind.masa => _masa,
  AstroTermKind.paksha => _paksha,
  AstroTermKind.gregorianMonth => _gmonth,
  AstroTermKind.gregorianWeekday => _vara,
  AstroTermKind.colour => _colour,
  AstroTermKind.direction => _direction,
  AstroTermKind.choghadiya => _choghadiya,
  AstroTermKind.quality => _quality,
};

/// Lowercase, alphanumerics only — see the class doc on why matching is not
/// exact.
String _normalize(String value) {
  final buffer = StringBuffer();
  for (final rune in value.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    if (RegExp(r'[a-z0-9]').hasMatch(char)) buffer.write(char);
  }
  return buffer.toString();
}

const Map<String, _T> _nakshatra = {
  'ashwini': _T('अश्विनी', 'అశ్విని', 'அசுவினி', 'ಅಶ್ವಿನಿ'),
  'bharani': _T('भरणी', 'భరణి', 'பரணி', 'ಭರಣಿ'),
  'krittika': _T('कृत्तिका', 'కృత్తిక', 'கிருத்திகை', 'ಕೃತ್ತಿಕಾ'),
  'rohini': _T('रोहिणी', 'రోహిణి', 'ரோகிணி', 'ರೋಹಿಣಿ'),
  'mrigashira': _T('मृगशिरा', 'మృగశిర', 'மிருகசீரிடம்', 'ಮೃಗಶಿರ'),
  'ardra': _T('आर्द्रा', 'ఆరుద్ర', 'திருவாதிரை', 'ಆರ್ದ್ರಾ'),
  'punarvasu': _T('पुनर्वसु', 'పునర్వసు', 'புனர்பூசம்', 'ಪುನರ್ವಸು'),
  'pushya': _T('पुष्य', 'పుష్యమి', 'பூசம்', 'ಪುಷ್ಯ'),
  'ashlesha': _T('आश्लेषा', 'ఆశ్లేష', 'ஆயில்யம்', 'ಆಶ್ಲೇಷ'),
  'magha': _T('मघा', 'మఖ', 'மகம்', 'ಮಘ'),
  'purvaphalguni': _T('पूर्व फाल्गुनी', 'పుబ్బ', 'பூரம்', 'ಪೂರ್ವ ಫಾಲ್ಗುಣಿ'),
  'uttaraphalguni': _T('उत्तर फाल्गुनी', 'ఉత్తర', 'உத்திரம்', 'ಉತ್ತರ ಫಾಲ್ಗುಣಿ'),
  'hasta': _T('हस्त', 'హస్త', 'அஸ்தம்', 'ಹಸ್ತ'),
  'chitra': _T('चित्रा', 'చిత్త', 'சித்திரை', 'ಚಿತ್ರಾ'),
  'swati': _T('स्वाति', 'స్వాతి', 'சுவாதி', 'ಸ್ವಾತಿ'),
  'vishakha': _T('विशाखा', 'విశాఖ', 'விசாகம்', 'ವಿಶಾಖ'),
  'anuradha': _T('अनुराधा', 'అనూరాధ', 'அனுஷம்', 'ಅನುರಾಧ'),
  'jyeshtha': _T('ज्येष्ठा', 'జ్యేష్ఠ', 'கேட்டை', 'ಜ್ಯೇಷ್ಠ'),
  'mula': _T('मूल', 'మూల', 'மூலம்', 'ಮೂಲ'),
  'purvaashadha': _T('पूर्वाषाढ़ा', 'పూర్వాషాఢ', 'பூராடம்', 'ಪೂರ್ವಾಷಾಢ'),
  'uttaraashadha': _T('उत्तराषाढ़ा', 'ఉత్తరాషాఢ', 'உத்திராடம்', 'ಉತ್ತರಾಷಾಢ'),
  'shravana': _T('श्रवण', 'శ్రవణం', 'திருவோணம்', 'ಶ್ರವಣ'),
  'dhanishta': _T('धनिष्ठा', 'ధనిష్ఠ', 'அவிட்டம்', 'ಧನಿಷ್ಠ'),
  'shatabhisha': _T('शतभिषा', 'శతభిషం', 'சதயம்', 'ಶತಭಿಷ'),
  'purvabhadrapada': _T('पूर्व भाद्रपद', 'పూర్వాభాద్ర', 'பூரட்டாதி', 'ಪೂರ್ವಾ ಭಾದ್ರಪದ'),
  'uttarabhadrapada': _T('उत्तर भाद्रपद', 'ఉత్తరాభాద్ర', 'உத்திரட்டாதி', 'ಉತ್ತರಾ ಭಾದ್ರಪದ'),
  'revati': _T('रेवती', 'రేవతి', 'ரேவதி', 'ರೇವತಿ'),
};

const Map<String, _T> _tithi = {
  'pratipada': _T('प्रतिपदा', 'పాడ్యమి', 'பிரதமை', 'ಪಾಡ್ಯ'),
  'dwitiya': _T('द्वितीया', 'విదియ', 'துவிதியை', 'ಬಿದಿಗೆ'),
  'tritiya': _T('तृतीया', 'తదియ', 'திரிதியை', 'ತದಿಗೆ'),
  'chaturthi': _T('चतुर्थी', 'చవితి', 'சதுர்த்தி', 'ಚೌತಿ'),
  'panchami': _T('पंचमी', 'పంచమి', 'பஞ்சமி', 'ಪಂಚಮಿ'),
  'shashthi': _T('षष्ठी', 'షష్ఠి', 'சஷ்டி', 'ಷಷ್ಠಿ'),
  'saptami': _T('सप्तमी', 'సప్తమి', 'சப்தமி', 'ಸಪ್ತಮಿ'),
  'ashtami': _T('अष्टमी', 'అష్టమి', 'அஷ்டமி', 'ಅಷ್ಟಮಿ'),
  'navami': _T('नवमी', 'నవమి', 'நவமி', 'ನವಮಿ'),
  'dashami': _T('दशमी', 'దశమి', 'தசமி', 'ದಶಮಿ'),
  'ekadashi': _T('एकादशी', 'ఏకాదశి', 'ஏகாதசி', 'ಏಕಾದಶಿ'),
  'dwadashi': _T('द्वादशी', 'ద్వాదశి', 'துவாதசி', 'ದ್ವಾದಶಿ'),
  'trayodashi': _T('त्रयोदशी', 'త్రయోదశి', 'திரயோதசி', 'ತ್ರಯೋದಶಿ'),
  'chaturdashi': _T('चतुर्दशी', 'చతుర్దశి', 'சதுர்த்தசி', 'ಚತುರ್ದಶಿ'),
  'purnima': _T('पूर्णिमा', 'పౌర్ణమి', 'பௌர்ணமி', 'ಹುಣ್ಣಿಮೆ'),
  'amavasya': _T('अमावस्या', 'అమావాస్య', 'அமாவாசை', 'ಅಮಾವಾಸ್ಯೆ'),
};

const Map<String, _T> _yoga = {
  'vishkambha': _T('विष्कम्भ', 'విష్కంభ', 'விஷ்கம்பம்', 'ವಿಷ್ಕಂಭ'),
  'priti': _T('प्रीति', 'ప్రీతి', 'பிரீதி', 'ಪ್ರೀತಿ'),
  'ayushman': _T('आयुष्मान्', 'ఆయుష్మాన్', 'ஆயுஷ்மான்', 'ಆಯುಷ್ಮಾನ್'),
  'saubhagya': _T('सौभाग्य', 'సౌభాగ్య', 'சௌபாக்கியம்', 'ಸೌಭಾಗ್ಯ'),
  'shobhana': _T('शोभन', 'శోభన', 'சோபனம்', 'ಶೋಭನ'),
  'atiganda': _T('अतिगण्ड', 'అతిగండ', 'அதிகண்டம்', 'ಅತಿಗಂಡ'),
  'sukarma': _T('सुकर्मा', 'సుకర్మ', 'சுகர்மா', 'ಸುಕರ್ಮ'),
  'dhriti': _T('धृति', 'ధృతి', 'திருதி', 'ಧೃತಿ'),
  'shula': _T('शूल', 'శూల', 'சூலம்', 'ಶೂಲ'),
  'ganda': _T('गण्ड', 'గండ', 'கண்டம்', 'ಗಂಡ'),
  'vriddhi': _T('वृद्धि', 'వృద్ధి', 'விருத்தி', 'ವೃದ್ಧಿ'),
  'dhruva': _T('ध्रुव', 'ధ్రువ', 'துருவம்', 'ಧ್ರುವ'),
  'vyaghata': _T('व्याघात', 'వ్యాఘాత', 'வியாகாதம்', 'ವ್ಯಾಘಾತ'),
  'harshana': _T('हर्षण', 'హర్షణ', 'ஹர்ஷணம்', 'ಹರ್ಷಣ'),
  'vajra': _T('वज्र', 'వజ్ర', 'வஜ்ரம்', 'ವಜ್ರ'),
  'siddhi': _T('सिद्धि', 'సిద్ధి', 'சித்தி', 'ಸಿದ್ಧಿ'),
  'vyatipata': _T('व्यतीपात', 'వ్యతీపాత', 'வியதீபாதம்', 'ವ್ಯತೀಪಾತ'),
  'variyana': _T('वरीयान्', 'వరీయాన్', 'வரீயான்', 'ವರೀಯಾನ್'),
  'parigha': _T('परिघ', 'పరిఘ', 'பரிகம்', 'ಪರಿಘ'),
  'shiva': _T('शिव', 'శివ', 'சிவம்', 'ಶಿವ'),
  'siddha': _T('सिद्ध', 'సిద్ధ', 'சித்தம்', 'ಸಿದ್ಧ'),
  'sadhya': _T('साध्य', 'సాధ్య', 'சாத்தியம்', 'ಸಾಧ್ಯ'),
  'shubha': _T('शुभ', 'శుభ', 'சுபம்', 'ಶುಭ'),
  'shukla': _T('शुक्ल', 'శుక్ల', 'சுக்கிலம்', 'ಶುಕ್ಲ'),
  'brahma': _T('ब्रह्म', 'బ్రహ్మ', 'பிரம்மம்', 'ಬ್ರಹ್ಮ'),
  'indra': _T('इन्द्र', 'ఇంద్ర', 'இந்திரம்', 'ಇಂದ್ರ'),
  'vaidhriti': _T('वैधृति', 'వైధృతి', 'வைதிருதி', 'ವೈಧೃತಿ'),
};

const Map<String, _T> _karana = {
  'bava': _T('बव', 'బవ', 'பவம்', 'ಬವ'),
  'balava': _T('बालव', 'బాలవ', 'பாலவம்', 'ಬಾಲವ'),
  'kaulava': _T('कौलव', 'కౌలవ', 'கௌலவம்', 'ಕೌಲವ'),
  'taitila': _T('तैतिल', 'తైతిల', 'தைதிலம்', 'ತೈತಿಲ'),
  'garaja': _T('गर', 'గరజ', 'கரசை', 'ಗರಜ'),
  'vanija': _T('वणिज', 'వణిజ', 'வணிசை', 'ವಣಿಜ'),
  'vishti': _T('विष्टि', 'విష్టి', 'விட்டி', 'ವಿಷ್ಟಿ'),
  'shakuni': _T('शकुनि', 'శకుని', 'சகுனி', 'ಶಕುನಿ'),
  'chatushpada': _T('चतुष्पाद', 'చతుష్పాద', 'சதுஷ்பாதம்', 'ಚತುಷ್ಪಾದ'),
  'naga': _T('नाग', 'నాగ', 'நாகம்', 'ನಾಗ'),
  'kimstughna': _T('किंस्तुघ्न', 'కింస్తుఘ్న', 'கிம்ஸ்துக்னம்', 'ಕಿಂಸ್ತುಘ್ನ'),
};

const Map<String, _T> _vara = {
  'sunday': _T('रविवार', 'ఆదివారం', 'ஞாயிறு', 'ಭಾನುವಾರ'),
  'monday': _T('सोमवार', 'సోమవారం', 'திங்கள்', 'ಸೋಮವಾರ'),
  'tuesday': _T('मंगलवार', 'మంగళవారం', 'செவ்வாய்', 'ಮಂಗಳವಾರ'),
  'wednesday': _T('बुधवार', 'బుధవారం', 'புதன்', 'ಬುಧವಾರ'),
  'thursday': _T('गुरुवार', 'గురువారం', 'வியாழன்', 'ಗುರುವಾರ'),
  'friday': _T('शुक्रवार', 'శుక్రవారం', 'வெள்ளி', 'ಶುಕ್ರವಾರ'),
  'saturday': _T('शनिवार', 'శనివారం', 'சனி', 'ಶನಿವಾರ'),
};

const Map<String, _T> _rashi = {
  'aries': _T('मेष', 'మేషం', 'மேஷம்', 'ಮೇಷ'),
  'taurus': _T('वृषभ', 'వృషభం', 'ரிஷபம்', 'ವೃಷಭ'),
  'gemini': _T('मिथुन', 'మిథునం', 'மிதுனம்', 'ಮಿಥುನ'),
  'cancer': _T('कर्क', 'కర్కాటకం', 'கடகம்', 'ಕರ್ಕಾಟಕ'),
  'leo': _T('सिंह', 'సింహం', 'சிம்மம்', 'ಸಿಂಹ'),
  'virgo': _T('कन्या', 'కన్య', 'கன்னி', 'ಕನ್ಯಾ'),
  'libra': _T('तुला', 'తుల', 'துலாம்', 'ತುಲಾ'),
  'scorpio': _T('वृश्चिक', 'వృశ్చికం', 'விருச்சிகம்', 'ವೃಶ್ಚಿಕ'),
  'sagittarius': _T('धनु', 'ధనుస్సు', 'தனுசு', 'ಧನು'),
  'capricorn': _T('मकर', 'మకరం', 'மகரம்', 'ಮಕರ'),
  'aquarius': _T('कुम्भ', 'కుంభం', 'கும்பம்', 'ಕುಂಭ'),
  'pisces': _T('मीन', 'మీనం', 'மீனம்', 'ಮೀನ'),
};

const Map<String, _T> _graha = {
  'sun': _T('सूर्य', 'సూర్యుడు', 'சூரியன்', 'ಸೂರ್ಯ'),
  'moon': _T('चन्द्र', 'చంద్రుడు', 'சந்திரன்', 'ಚಂದ್ರ'),
  'mars': _T('मंगल', 'కుజుడు', 'செவ்வாய்', 'ಮಂಗಳ'),
  'mercury': _T('बुध', 'బుధుడు', 'புதன்', 'ಬುಧ'),
  'jupiter': _T('गुरु', 'గురుడు', 'குரு', 'ಗುರು'),
  'venus': _T('शुक्र', 'శుక్రుడు', 'சுக்கிரன்', 'ಶುಕ್ರ'),
  'saturn': _T('शनि', 'శని', 'சனி', 'ಶನಿ'),
  'rahu': _T('राहु', 'రాహువు', 'ராகு', 'ರಾಹು'),
  'ketu': _T('केतु', 'కేతువు', 'கேது', 'ಕೇತು'),
  'ascendant': _T('लग्न', 'లగ్నం', 'லக்னம்', 'ಲಗ್ನ'),
};

const Map<String, _T> _masa = {
  'chaitra': _T('चैत्र', 'చైత్రం', 'சித்திரை', 'ಚೈತ್ರ'),
  'vaishakha': _T('वैशाख', 'వైశాఖం', 'வைகாசி', 'ವೈಶಾಖ'),
  'jyeshtha': _T('ज्येष्ठ', 'జ్యేష్ఠం', 'ஆனி', 'ಜ್ಯೇಷ್ಠ'),
  'ashadha': _T('आषाढ़', 'ఆషాఢం', 'ஆடி', 'ಆಷಾಢ'),
  'shravana': _T('श्रावण', 'శ్రావణం', 'ஆவணி', 'ಶ್ರಾವಣ'),
  'bhadrapada': _T('भाद्रपद', 'భాద్రపదం', 'புரட்டாசி', 'ಭಾದ್ರಪದ'),
  'ashwina': _T('आश्विन', 'ఆశ్వయుజం', 'ஐப்பசி', 'ಆಶ್ವಯುಜ'),
  'kartika': _T('कार्तिक', 'కార్తీకం', 'கார்த்திகை', 'ಕಾರ್ತಿಕ'),
  'margashirsha': _T('मार्गशीर्ष', 'మార్గశిరం', 'மார்கழி', 'ಮಾರ್ಗಶಿರ'),
  'pausha': _T('पौष', 'పుష్యం', 'தை', 'ಪುಷ್ಯ'),
  'magha': _T('माघ', 'మాఘం', 'மாசி', 'ಮಾಘ'),
  'phalguna': _T('फाल्गुन', 'ఫాల్గుణం', 'பங்குனி', 'ಫಾಲ್ಗುಣ'),
};

const Map<String, _T> _paksha = {
  'shukla': _T('शुक्ल', 'శుక్ల', 'சுக்கில', 'ಶುಕ್ಲ'),
  'krishna': _T('कृष्ण', 'కృష్ణ', 'கிருஷ்ண', 'ಕೃಷ್ಣ'),
};


const Map<String, _T> _gmonth = {
  'january': _T('जनवरी', 'జనవరి', 'ஜனவரி', 'ಜನವರಿ'),
  'february': _T('फ़रवरी', 'ఫిబ్రవరి', 'பிப்ரவரி', 'ಫೆಬ್ರವರಿ'),
  'march': _T('मार्च', 'మార్చి', 'மார்ச்', 'ಮಾರ್ಚ್'),
  'april': _T('अप्रैल', 'ఏప్రిల్', 'ஏப்ரல்', 'ಏಪ್ರಿಲ್'),
  'may': _T('मई', 'మే', 'மே', 'ಮೇ'),
  'june': _T('जून', 'జూన్', 'ஜூன்', 'ಜೂನ್'),
  'july': _T('जुलाई', 'జూలై', 'ஜூலை', 'ಜುಲೈ'),
  'august': _T('अगस्त', 'ఆగస్టు', 'ஆகஸ்ட்', 'ಆಗಸ್ಟ್'),
  'september': _T('सितंबर', 'సెప్టెంబర్', 'செப்டம்பர்', 'ಸೆಪ್ಟೆಂಬರ್'),
  'october': _T('अक्टूबर', 'అక్టోబర్', 'அக்டோபர்', 'ಅಕ್ಟೋಬರ್'),
  'november': _T('नवंबर', 'నవంబర్', 'நவம்பர்', 'ನವೆಂಬರ್'),
  'december': _T('दिसंबर', 'డిసెంబర్', 'டிசம்பர்', 'ಡಿಸೆಂಬರ್'),
};

/// Native-script name for a yoga, e.g. `"Gaja Kesari Yoga"` →
/// `"గజ కేసరి యోగం"`.
///
/// BUILT 4 Sep 2026 from a client screenshot: the Kundli Predictions glimpse
/// rendered its chrome in Telugu but every yoga heading in English.
///
/// ## Why this needs its own function rather than another table row
///
/// Vedika's yoga names are COMPOUND, and only part of each is translatable.
/// Sampled across three real charts, they come in these shapes:
///
/// ```
/// Gaja Kesari Yoga
/// Dhana Yoga (2-11)
/// Raja Yoga Conjunction (10L+5L: Saturn+Mercury in 7H)
/// Neecha Bhanga Raja Yoga (Jupiter — dispositor Saturn in kendra (H7))
/// Duryoga
/// ```
///
/// So it splits into three parts and treats each correctly:
///
///  1. **The parenthetical qualifier is left ALONE.** It is chart notation —
///     house numbers, lord abbreviations, planet names — not prose. `(2-11)`
///     means the same in every language, and `(10L+5L: Saturn+Mercury in 7H)`
///     is the shorthand an astrologer reads. Translating it would be wrong
///     even where possible, and mangling it would be worse.
///  2. **The base name is looked up** in [_yoga] — a closed classical
///     vocabulary, exactly like the nakshatras.
///  3. **The word "Yoga" itself is translated** and re-appended, since it is
///     a common noun in all five languages.
///
/// An unknown yoga falls through UNCHANGED, same rule as every other term:
/// English is honest, an invented Sanskrit transliteration is not.
String? localizeYogaName(String? name, Locale locale) {
  if (name == null) return null;
  final trimmed = name.trim();
  if (trimmed.isEmpty || locale.languageCode == 'en') return trimmed;

  final paren = trimmed.indexOf('(');
  final head = (paren == -1 ? trimmed : trimmed.substring(0, paren)).trim();
  final tail = paren == -1 ? '' : ' ${trimmed.substring(paren).trim()}';

  // Whole-string match first — it catches single-word names like "Duryoga"
  // where "Yoga" is fused into the term and must not be split off.
  final whole = _yogaName[_normalize(head)]?.forLanguage(locale.languageCode);
  if (whole != null) return '$whole$tail';

  // Otherwise: "<base> Yoga" → "<localized base> <localized 'yoga'>".
  final lower = head.toLowerCase();
  if (!lower.endsWith('yoga')) return trimmed;
  final base = head.substring(0, head.length - 4).trim();
  final localizedBase = _yogaName[_normalize(base)]?.forLanguage(
    locale.languageCode,
  );
  if (localizedBase == null) return trimmed;
  final yogaWord = _yogaName['yoga']!.forLanguage(locale.languageCode)!;
  return '$localizedBase $yogaWord$tail';
}

/// Classical yoga vocabulary. Keys are the BASE name with any trailing
/// "Yoga" and parenthetical removed — see [localizeYogaName].
///
/// Covers every name observed across sampled real charts plus the standard
/// classical set (the five Pancha Mahapurusha yogas, the Moon yogas, the
/// Raja/Dhana families). Add a row when a new one shows in English.
const Map<String, _T> _yogaName = {
  'yoga': _T('योग', 'యోగం', 'யோகம்', 'ಯೋಗ'),
  // Pancha Mahapurusha
  'ruchaka': _T('रुचक', 'రుచక', 'ருசக', 'ರುಚಕ'),
  'bhadra': _T('भद्र', 'భద్ర', 'பத்ர', 'ಭದ್ರ'),
  'hamsa': _T('हंस', 'హంస', 'ஹம்ஸ', 'ಹಂಸ'),
  'malavya': _T('मालव्य', 'మాలవ్య', 'மாலவ்ய', 'ಮಾಲವ್ಯ'),
  'sasa': _T('शश', 'శశ', 'சச', 'ಶಶ'),
  // Moon-based
  'gajakesari': _T('गज केसरी', 'గజ కేసరి', 'கஜ கேசரி', 'ಗಜ ಕೇಸರಿ'),
  'sunapha': _T('सुनफा', 'సునఫ', 'சுனபா', 'ಸುನಫ'),
  'anapha': _T('अनफा', 'అనఫ', 'அனபா', 'ಅನಫ'),
  'durudhara': _T('दुरुधरा', 'దురుధర', 'துருதரா', 'ದುರುಧರ'),
  'kemadruma': _T('केमद्रुम', 'కేమద్రుమ', 'கேமத்ரும', 'ಕೇಮದ್ರುಮ'),
  'chandramangala': _T('चंद्र मंगल', 'చంద్ర మంగళ', 'சந்திர மங்கள', 'ಚಂದ್ರ ಮಂಗಳ'),
  'adhi': _T('अधि', 'అధి', 'அதி', 'ಅಧಿ'),
  // Sun-based
  'veshi': _T('वेशी', 'వేశి', 'வேசி', 'ವೇಶಿ'),
  'voshi': _T('वोशी', 'వోశి', 'வோசி', 'ವೋಶಿ'),
  'ubhayachari': _T('उभयचरी', 'ఉభయచరి', 'உபயசாரி', 'ಉಭಯಚರಿ'),
  'budhaaditya': _T('बुध-आदित्य', 'బుధ-ఆదిత్య', 'புத-ஆதித்ய', 'ಬುಧ-ಆದಿತ್ಯ'),
  // Raja / Dhana families
  'raja': _T('राज', 'రాజ', 'ராஜ', 'ರಾಜ'),
  'dhana': _T('धन', 'ధన', 'தன', 'ಧನ'),
  'neechabhangaraja': _T(
    'नीच भंग राज',
    'నీచ భంగ రాజ',
    'நீச பங்க ராஜ',
    'ನೀಚ ಭಂಗ ರಾಜ',
  ),
  'vipreetaraja': _T('विपरीत राज', 'విపరీత రాజ', 'விபரீத ராஜ', 'ವಿಪರೀತ ರಾಜ'),
  'viparitaraja': _T('विपरीत राज', 'విపరీత రాజ', 'விபரீத ராஜ', 'ವಿಪರೀತ ರಾಜ'),
  'sunapharaja': _T('सुनफा राज', 'సునఫ రాజ', 'சுனபா ராஜ', 'ಸುನಫ ರಾಜ'),
  'dharmakarmadhipati': _T(
    'धर्म-कर्माधिपति',
    'ధర్మ-కర్మాధిపతి',
    'தர்ம-கர்மாதிபதி',
    'ಧರ್ಮ-ಕರ್ಮಾಧಿಪತಿ',
  ),
  'rajayogaconjunction': _T(
    'राज योग युति',
    'రాజ యోగ యుతి',
    'ராஜ யோக சேர்க்கை',
    'ರಾಜ ಯೋಗ ಸಂಯೋಗ',
  ),
  'rajayogamutualaspect': _T(
    'राज योग परस्पर दृष्टि',
    'రాజ యోగ పరస్పర దృష్టి',
    'ராஜ யோக பரஸ்பர பார்வை',
    'ರಾಜ ಯೋಗ ಪರಸ್ಪರ ದೃಷ್ಟಿ',
  ),
  'rajayogaparivartana': _T(
    'राज योग परिवर्तन',
    'రాజ యోగ పరివర్తన',
    'ராஜ யோக பரிவர்த்தன',
    'ರಾಜ ಯೋಗ ಪರಿವರ್ತನ',
  ),
  'parivartana': _T('परिवर्तन', 'పరివర్తన', 'பரிவர்த்தன', 'ಪರಿವರ್ತನ'),
  // Benefic / malefic singles
  'amala': _T('अमल', 'అమల', 'அமல', 'ಅಮಲ'),
  'akriti': _T('आकृति', 'ఆకృతి', 'ஆகிருதி', 'ಆಕೃತಿ'),
  'ardhachandra': _T('अर्धचंद्र', 'అర్ధచంద్ర', 'அர்த்தசந்திர', 'ಅರ್ಧಚಂದ್ರ'),
  'dama': _T('दम', 'దమ', 'தம', 'ದಮ'),
  'duryoga': _T('दुर्योग', 'దుర్యోగం', 'துர்யோகம்', 'ದುರ್ಯೋಗ'),
  'grahan': _T('ग्रहण', 'గ్రహణ', 'கிரகண', 'ಗ್ರಹಣ'),
  'harsha': _T('हर्ष', 'హర్ష', 'ஹர்ஷ', 'ಹರ್ಷ'),
  'indu': _T('इंदु', 'ఇందు', 'இந்து', 'ಇಂದು'),
  'kahala': _T('कहल', 'కహల', 'கஹல', 'ಕಹಲ'),
  'lakshmi': _T('लक्ष्मी', 'లక్ష్మి', 'லக்ஷ்மி', 'ಲಕ್ಷ್ಮಿ'),
  'mridanga': _T('मृदंग', 'మృదంగ', 'மிருதங்க', 'ಮೃದಂಗ'),
  'nirbhagya': _T('निर्भाग्य', 'నిర్భాగ్య', 'நிர்பாக்ய', 'ನಿರ್ಭಾಗ್ಯ'),
  'pushkala': _T('पुष्कल', 'పుష్కల', 'புஷ்கல', 'ಪುಷ್ಕಲ'),
  'saraswati': _T('सरस्वती', 'సరస్వతి', 'சரஸ்வதி', 'ಸರಸ್ವತಿ'),
  'shakata': _T('शकट', 'శకట', 'சகட', 'ಶಕಟ'),
  'shapit': _T('शापित', 'శాపిత', 'சாபித', 'ಶಾಪಿತ'),
  'subhakartari': _T('शुभकर्तरी', 'శుభకర్తరి', 'சுபகர்த்தரி', 'ಶುಭಕರ್ತರಿ'),
  'vasumati': _T('वसुमती', 'వసుమతి', 'வசுமதி', 'ವಸುಮತಿ'),
  'veena': _T('वीणा', 'వీణ', 'வீணை', 'ವೀಣಾ'),
  'mahabhagya': _T('महाभाग्य', 'మహాభాగ్య', 'மகாபாக்ய', 'ಮಹಾಭಾಗ್ಯ'),
  'chandra': _T('चंद्र', 'చంద్ర', 'சந்திர', 'ಚಂದ್ರ'),
  'budha': _T('बुध', 'బుధ', 'புத', 'ಬುಧ'),
  'guru': _T('गुरु', 'గురు', 'குரு', 'ಗುರು'),
  'shukra': _T('शुक्र', 'శుక్ర', 'சுக்ர', 'ಶುಕ್ರ'),
  'kesari': _T('केसरी', 'కేసరి', 'கேசரி', 'ಕೇಸರಿ'),
  'akhandasamrajya': _T(
    'अखंड साम्राज्य',
    'అఖండ సామ్రాజ్య',
    'அகண்ட சாம்ராஜ்ய',
    'ಅಖಂಡ ಸಾಮ್ರಾಜ್ಯ',
  ),
};

const Map<String, _T> _colour = {
  'red': _T('लाल', 'ఎరుపు', 'சிவப்பு', 'ಕೆಂಪು'),
  'crimson': _T('क्रिमसन', 'ఎరుపు', 'கருஞ்சிவப்பு', 'ಕಡುಕೆಂಪು'),
  'maroon': _T('मैरून', 'మెరూన్', 'மெரூன்', 'ಮರೂನ್'),
  'orange': _T('नारंगी', 'నారింజ', 'ஆரஞ்சு', 'ಕಿತ್ತಳೆ'),
  'saffron': _T('केसरिया', 'కాషాయం', 'காவி', 'ಕೇಸರಿ'),
  'yellow': _T('पीला', 'పసుపు', 'மஞ்சள்', 'ಹಳದಿ'),
  'gold': _T('सुनहरा', 'బంగారు', 'தங்கம்', 'ಚಿನ್ನ'),
  'green': _T('हरा', 'ఆకుపచ్చ', 'பச்சை', 'ಹಸಿರು'),
  'blue': _T('नीला', 'నీలం', 'நீலம்', 'ನೀಲಿ'),
  'indigo': _T('जामुनी नीला', 'ఇండిగో', 'கருநீலம்', 'ಇಂಡಿಗೊ'),
  'violet': _T('बैंगनी', 'ఊదా', 'ஊதா', 'ನೇರಳೆ'),
  'purple': _T('बैंगनी', 'ఊదా', 'ஊதா', 'ನೇರಳೆ'),
  'pink': _T('गुलाबी', 'గులాబీ', 'இளஞ்சிவப்பு', 'ಗುಲಾಬಿ'),
  'white': _T('सफ़ेद', 'తెలుపు', 'வெள்ளை', 'ಬಿಳಿ'),
  'black': _T('काला', 'నలుపు', 'கருப்பு', 'ಕಪ್ಪು'),
  'grey': _T('धूसर', 'బూడిద', 'சாம்பல்', 'ಬೂದು'),
  'gray': _T('धूसर', 'బూడిద', 'சாம்பல்', 'ಬೂದು'),
  'brown': _T('भूरा', 'గోధుమ', 'பழுப்பு', 'ಕಂದು'),
  'silver': _T('चाँदी', 'వెండి', 'வெள்ளி', 'ಬೆಳ್ಳಿ'),
  'cream': _T('क्रीम', 'క్రీమ్', 'கிரீம்', 'ಕ್ರೀಮ್'),
};

const Map<String, _T> _direction = {
  'east': _T('पूर्व', 'తూర్పు', 'கிழக்கு', 'ಪೂರ್ವ'),
  'west': _T('पश्चिम', 'పడమర', 'மேற்கு', 'ಪಶ್ಚಿಮ'),
  'north': _T('उत्तर', 'ఉత్తరం', 'வடக்கு', 'ಉತ್ತರ'),
  'south': _T('दक्षिण', 'దక్షిణం', 'தெற்கு', 'ದಕ್ಷಿಣ'),
  'northeast': _T('ईशान', 'ఈశాన్యం', 'வடகிழக்கு', 'ಈಶಾನ್ಯ'),
  'northwest': _T('वायव्य', 'వాయవ్యం', 'வடமேற்கு', 'ವಾಯುವ್ಯ'),
  'southeast': _T('आग्नेय', 'ఆగ్నేయం', 'தென்கிழக்கு', 'ಆಗ್ನೇಯ'),
  'southwest': _T('नैऋत्य', 'నైరుతి', 'தென்மேற்கு', 'ನೈಋತ್ಯ'),
};

const Map<String, _T> _choghadiya = {
  'amrit': _T('अमृत', 'అమృత', 'அமிர்த', 'ಅಮೃತ'),
  'amrita': _T('अमृत', 'అమృత', 'அமிர்த', 'ಅಮೃತ'),
  'shubh': _T('शुभ', 'శుభ', 'சுப', 'ಶುಭ'),
  'shubha': _T('शुभ', 'శుభ', 'சுப', 'ಶುಭ'),
  'labh': _T('लाभ', 'లాభ', 'லாப', 'ಲಾಭ'),
  'labha': _T('लाभ', 'లాభ', 'லாப', 'ಲಾಭ'),
  'char': _T('चर', 'చర', 'சர', 'ಚರ'),
  'chara': _T('चर', 'చర', 'சர', 'ಚರ'),
  'rog': _T('रोग', 'రోగ', 'ரோக', 'ರೋಗ'),
  'roga': _T('रोग', 'రోగ', 'ரோக', 'ರೋಗ'),
  'kaal': _T('काल', 'కాల', 'கால', 'ಕಾಲ'),
  'kala': _T('काल', 'కాల', 'கால', 'ಕಾಲ'),
  'udveg': _T('उद्वेग', 'ఉద్వేగ', 'உத்வேக', 'ಉದ್ವೇಗ'),
  'udvega': _T('उद्वेग', 'ఉద్వేగ', 'உத்வேக', 'ಉದ್ವೇಗ'),
};

const Map<String, _T> _quality = {
  'excellent': _T('उत्तम', 'అత్యుత్తమం', 'மிகச் சிறந்தது', 'ಅತ್ಯುತ್ತಮ'),
  'verygood': _T('बहुत अच्छा', 'చాలా మంచిది', 'மிக நல்லது', 'ತುಂಬಾ ಒಳ್ಳೆಯದು'),
  'good': _T('अच्छा', 'మంచిది', 'நல்லது', 'ಒಳ್ಳೆಯದು'),
  'favorable': _T('अनुकूल', 'అనుకూలం', 'சாதகமானது', 'ಅನುಕೂಲಕರ'),
  'favourable': _T('अनुकूल', 'అనుకూలం', 'சாதகமானது', 'ಅನುಕೂಲಕರ'),
  'average': _T('सामान्य', 'సాధారణం', 'சராசரி', 'ಸಾಧಾರಣ'),
  'neutral': _T('तटस्थ', 'తటస్థం', 'நடுநிலை', 'ತಟಸ್ಥ'),
  'moderate': _T('मध्यम', 'మధ్యస్థం', 'மிதமானது', 'ಮಧ್ಯಮ'),
  'challenging': _T('चुनौतीपूर्ण', 'సవాలుతో కూడినది', 'சவாலானது', 'ಸವಾಲಿನ'),
  'difficult': _T('कठिन', 'కష్టం', 'கடினமானது', 'ಕಠಿಣ'),
  'inauspicious': _T('अशुभ', 'అశుభం', 'அசுபம்', 'ಅಶುಭ'),
  'auspicious': _T('शुभ', 'శుభం', 'சுபம்', 'ಶುಭ'),
};

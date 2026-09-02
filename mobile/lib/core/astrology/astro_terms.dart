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
  final table = _tableFor(kind)[_normalize(trimmed)];
  return table?.forLanguage(locale.languageCode) ?? trimmed;
}

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


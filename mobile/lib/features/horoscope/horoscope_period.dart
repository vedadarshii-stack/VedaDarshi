/// Which period a horoscope reading is shown for.
///
/// Shared between `horoscope_signs_screen.dart` (the Daily / Weekly /
/// Monthly / Yearly chip selector) and `horoscope_detail_screen.dart` (which
/// switches provider/layout by period) — pulled into its own tiny file
/// rather than staying private to either screen, since both need it.
enum HoroscopePeriod { daily, weekly, monthly, yearly }

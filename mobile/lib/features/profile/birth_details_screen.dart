import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/geo/city.dart';
import '../../core/geo/place_search.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_dashboard_screen.dart';
import 'birth_profile.dart';
import 'birth_profile_repository.dart';

/// Debounce delay before firing a place search as the user types.
const Duration _searchDebounce = Duration(milliseconds: 250);

/// Birth Details Setup screen, matching the approved Figma "A5 · Birth
/// Details Setup" (node 8:2) concept.
///
/// Shared post-sign-in step reached after a SUCCESSFUL Google, phone-OTP or
/// guest sign-in (see `lib/features/profile/post_sign_in_route.dart`) when
/// the signed-in identity doesn't already have a saved [BirthProfile].
/// Saving proceeds to [HomeDashboardScreen], clearing the nav stack.
class BirthDetailsScreen extends ConsumerStatefulWidget {
  const BirthDetailsScreen({super.key});

  @override
  ConsumerState<BirthDetailsScreen> createState() => _BirthDetailsScreenState();
}

class _BirthDetailsScreenState extends ConsumerState<BirthDetailsScreen> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _placeController = TextEditingController();
  final _placeFocusNode = FocusNode();

  Gender? _gender;
  DateTime? _dateOfBirth;
  TimeOfDay? _timeOfBirth;
  bool _isBirthTimeUnknown = false;
  City? _selectedCity;

  List<PlaceSuggestion> _searchResults = const [];
  Timer? _debounceTimer;
  bool _wasPlaceFocused = false;
  bool _isResolvingPlace = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Google sign-in supplies a display name — prefill it so returning
    // Google users don't have to retype it. Guarded: reading currentUser
    // touches FirebaseAuth.instance, which throws if Firebase isn't
    // initialised. A missing name is a cosmetic loss, never a reason to
    // fail to render the screen.
    try {
      final displayName = ref
          .read(authServiceProvider)
          .currentUser
          ?.displayName;
      if (displayName != null && displayName.trim().isNotEmpty) {
        _nameController.text = displayName.trim();
      }
    } catch (_) {
      // No Firebase user available (guest, or Firebase not ready).
    }
    _nameController.addListener(_onFieldChanged);
    _nameFocusNode.addListener(_onFieldChanged);
    _placeFocusNode.addListener(_onFieldChanged);
    _placeFocusNode.addListener(_onPlaceFocusChanged);
    _placeController.addListener(_onPlaceQueryChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.removeListener(_onFieldChanged);
    _nameFocusNode.removeListener(_onFieldChanged);
    _placeFocusNode.removeListener(_onFieldChanged);
    _placeFocusNode.removeListener(_onPlaceFocusChanged);
    _placeController.removeListener(_onPlaceQueryChanged);
    _nameController.dispose();
    _nameFocusNode.dispose();
    _placeController.dispose();
    _placeFocusNode.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  /// Starts a new Google Places session exactly once per "focus → search →
  /// pick" interaction, not once per keystroke — Google only bills an
  /// autocomplete-then-details sequence as a single session when every call
  /// in it shares the same token (see [PlaceSearch.startSession]).
  void _onPlaceFocusChanged() {
    final isFocused = _placeFocusNode.hasFocus;
    if (isFocused && !_wasPlaceFocused) {
      ref.read(placeSearchProvider).startSession();
    }
    _wasPlaceFocused = isFocused;
  }

  void _onPlaceQueryChanged() {
    // Any manual edit to the text invalidates a previously selected city —
    // the geo chip and its derived offset must not linger against stale
    // text.
    if (_selectedCity != null &&
        _placeController.text != _selectedCity!.displayLabel) {
      setState(() => _selectedCity = null);
    }

    _debounceTimer?.cancel();
    final query = _placeController.text;
    if (query.trim().isEmpty) {
      setState(() => _searchResults = const []);
      return;
    }
    _debounceTimer = Timer(_searchDebounce, () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    final results = await ref.read(placeSearchProvider).search(query);
    if (!mounted) return;
    // Ignore results for a query that's since been superseded by newer
    // typing (the field's current text no longer matches what we searched).
    if (_placeController.text != query) return;
    setState(() => _searchResults = results);
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    setState(() {
      _placeController.text = suggestion.label;
      _searchResults = const [];
      _isResolvingPlace = true;
    });
    _placeFocusNode.unfocus();
    final city = await ref.read(placeSearchProvider).resolve(suggestion);
    if (!mounted) return;
    setState(() {
      _isResolvingPlace = false;
      if (city != null) {
        _selectedCity = city;
      }
    });
    if (city == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.placeResolveFailed)));
    }
  }

  ThemeData _pickerTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.saffron,
        onPrimary: Colors.white,
        surface: AppColors.cream,
        onSurface: AppColors.ink,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: _dateOfBirth ?? DateTime(1995),
      builder: (context, child) =>
          Theme(data: _pickerTheme(context), child: child!),
    );
    if (!mounted || picked == null) return;
    setState(() => _dateOfBirth = picked);
  }

  Future<void> _pickTime() async {
    if (_isBirthTimeUnknown) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfBirth ?? const TimeOfDay(hour: 6, minute: 0),
      builder: (context, child) =>
          Theme(data: _pickerTheme(context), child: child!),
    );
    if (!mounted || picked == null) return;
    setState(() => _timeOfBirth = picked);
  }

  void _toggleBirthTimeUnknown() {
    setState(() => _isBirthTimeUnknown = !_isBirthTimeUnknown);
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _gender != null &&
      _dateOfBirth != null &&
      (_timeOfBirth != null || _isBirthTimeUnknown) &&
      _selectedCity != null &&
      !_isSaving;

  Future<void> _save() async {
    if (!_canSave) return;
    final city = _selectedCity!;
    final date = _dateOfBirth!;
    final time = _isBirthTimeUnknown
        ? const TimeOfDay(hour: 12, minute: 0)
        : _timeOfBirth!;

    setState(() => _isSaving = true);
    final profile = BirthProfile(
      fullName: _nameController.text.trim(),
      gender: _gender!,
      dateOfBirth: date,
      timeOfBirth: time,
      isBirthTimeUnknown: _isBirthTimeUnknown,
      city: city,
    );
    try {
      await ref.read(birthProfileRepositoryProvider).save(profile);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil<void>(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isCompact = MediaQuery.sizeOf(context).height < 840;
    final gap = isCompact ? 14.0 : 20.0;
    final showDropdown = _placeFocusNode.hasFocus && _searchResults.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: isCompact ? 32 : 64,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.birthTitle,
                style: AppFonts.heading(
                  locale,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.birthSubtitle,
                style: AppFonts.body(
                  locale,
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
              SizedBox(height: gap),
              _FieldLabel(text: l10n.birthFullNameLabel, locale: locale),
              _FieldBox(
                isActive: _nameFocusNode.hasFocus,
                child: TextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  textCapitalization: TextCapitalization.words,
                  style: AppFonts.body(
                    locale,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: l10n.birthNameHint,
                    hintStyle: AppFonts.body(
                      locale,
                      fontSize: 14,
                      color: AppColors.hint,
                    ),
                  ),
                ),
              ),
              SizedBox(height: gap),
              _FieldLabel(text: l10n.birthGenderLabel, locale: locale),
              _GenderPicker(
                l10n: l10n,
                locale: locale,
                selected: _gender,
                onSelect: (g) => setState(() => _gender = g),
              ),
              SizedBox(height: gap),
              _FieldLabel(text: l10n.birthDobLabel, locale: locale),
              _FieldBox(
                onTap: _pickDate,
                trailing: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.hint,
                ),
                child: Text(
                  _dateOfBirth != null
                      ? BirthProfile.formatDate(_dateOfBirth!)
                      : l10n.birthDateHint,
                  style: AppFonts.body(
                    locale,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _dateOfBirth != null
                        ? AppColors.ink
                        : AppColors.hint,
                  ),
                ),
              ),
              SizedBox(height: gap),
              _FieldLabel(text: l10n.birthTobLabel, locale: locale),
              Opacity(
                opacity: _isBirthTimeUnknown ? 0.55 : 1,
                child: _FieldBox(
                  onTap: _isBirthTimeUnknown ? null : _pickTime,
                  trailing: Icon(
                    Icons.schedule_outlined,
                    size: 18,
                    color: AppColors.hint,
                  ),
                  child: Text(
                    _isBirthTimeUnknown
                        ? l10n.birthTimeUnknownValue
                        : (_timeOfBirth != null
                              ? BirthProfile.formatTime(_timeOfBirth!)
                              : l10n.birthTimeHint),
                    style: AppFonts.body(
                      locale,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _timeOfBirth != null || _isBirthTimeUnknown
                          ? AppColors.ink
                          : AppColors.hint,
                    ),
                  ),
                ),
              ),
              SizedBox(height: gap),
              _FieldLabel(text: l10n.birthPlaceLabel, locale: locale),
              _FieldBox(
                isActive: _placeFocusNode.hasFocus,
                trailing: _isResolvingPlace
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.saffron,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.place_outlined,
                        size: 18,
                        color: AppColors.hint,
                      ),
                child: TextField(
                  controller: _placeController,
                  focusNode: _placeFocusNode,
                  style: AppFonts.body(
                    locale,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: l10n.birthPlaceHint,
                    hintStyle: AppFonts.body(
                      locale,
                      fontSize: 14,
                      color: AppColors.hint,
                    ),
                  ),
                ),
              ),
              if (showDropdown)
                _PlaceResultsDropdown(
                  l10n: l10n,
                  locale: locale,
                  results: _searchResults,
                  onSelect: _selectSuggestion,
                  attribution: ref.read(placeSearchProvider).attribution,
                ),
              if (_selectedCity != null && _dateOfBirth != null) ...[
                const SizedBox(height: 10),
                _GeoChip(
                  l10n: l10n,
                  locale: locale,
                  city: _selectedCity!,
                  dateOfBirth: _dateOfBirth!,
                  timeOfBirth: _isBirthTimeUnknown
                      ? const TimeOfDay(hour: 12, minute: 0)
                      : (_timeOfBirth ?? const TimeOfDay(hour: 12, minute: 0)),
                ),
              ],
              SizedBox(height: gap),
              _UnknownTimeCheckbox(
                l10n: l10n,
                locale: locale,
                checked: _isBirthTimeUnknown,
                onTap: _toggleBirthTimeUnknown,
              ),
              SizedBox(height: gap),
              _SaveButton(
                l10n: l10n,
                locale: locale,
                enabled: _canSave,
                loading: _isSaving,
                onTap: _save,
              ),
              SizedBox(height: gap),
              Center(
                child: Text(
                  l10n.birthFooter,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(
                    locale,
                    fontSize: 12,
                    color: AppColors.hint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Uppercased, letter-spaced section label sitting above every field on this
/// screen (e.g. "FULL NAME", "GENDER").
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.locale});

  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        // toUpperCase() is a no-op on scripts without case (Devanagari,
        // Telugu, Tamil, Kannada), so this is safe across all 5 locales —
        // it only visibly affects the Latin (English) label text.
        text.toUpperCase(),
        style: AppFonts.body(
          locale,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.muted,
          letterSpacing: 0.24,
        ),
      ),
    );
  }
}

/// Shared white/rounded field container used by every input on this screen.
/// Optionally tappable (date/place fields) and optionally shows [trailing]
/// (calendar/clock/place icons). The border turns saffron while [isActive].
class _FieldBox extends StatelessWidget {
  const _FieldBox({
    required this.child,
    this.trailing,
    this.isActive = false,
    this.onTap,
  });

  final Widget child;
  final Widget? trailing;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? AppColors.saffron : AppColors.cardBorder,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: child),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );

    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: box),
    );
  }
}

/// Row of 3 selectable gender pills.
class _GenderPicker extends StatelessWidget {
  const _GenderPicker({
    required this.l10n,
    required this.locale,
    required this.selected,
    required this.onSelect,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final Gender? selected;
  final ValueChanged<Gender> onSelect;

  @override
  Widget build(BuildContext context) {
    final options = [
      (Gender.male, l10n.genderMale),
      (Gender.female, l10n.genderFemale),
      (Gender.other, l10n.genderOther),
    ];
    return Row(
      children: [
        for (final (gender, label) in options) ...[
          Expanded(
            child: _GenderPill(
              label: label,
              locale: locale,
              isSelected: selected == gender,
              onTap: () => onSelect(gender),
            ),
          ),
          if (gender != options.last.$1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _GenderPill extends StatelessWidget {
  const _GenderPill({
    required this.label,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.genderSelectedBg : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? AppColors.saffron : AppColors.cardBorder,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: AppFonts.body(
                  locale,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.genderSelectedText
                      : AppColors.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline results list shown directly under the place field — a normal
/// widget in the form's Column (not an Overlay), so it scrolls with the
/// rest of the form.
class _PlaceResultsDropdown extends StatelessWidget {
  const _PlaceResultsDropdown({
    required this.l10n,
    required this.locale,
    required this.results,
    required this.onSelect,
    required this.attribution,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final List<PlaceSuggestion> results;
  final ValueChanged<PlaceSuggestion> onSelect;

  /// Licence/ToS-required attribution for whichever provider (GeoNames or
  /// Google) actually served [results] — computed by the parent (which has
  /// `ref`) and passed down rather than read here, so this widget can stay
  /// a plain [StatelessWidget].
  final String attribution;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < results.length; i++)
            _PlaceResultRow(
              suggestion: results[i],
              locale: locale,
              highlighted: i == 0,
              onTap: () => onSelect(results[i]),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
            child: Align(
              alignment: Alignment.centerRight,
              // Licence/ToS requirement: this text belongs to whichever
              // provider (GeoNames CC BY 4.0 or Google) actually served the
              // results shown above, and must always be displayed
              // alongside them.
              child: Text(
                attribution,
                style: AppFonts.body(
                  locale,
                  fontSize: 8.5,
                  color: AppColors.hint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceResultRow extends StatelessWidget {
  const _PlaceResultRow({
    required this.suggestion,
    required this.locale,
    required this.highlighted,
    required this.onTap,
  });

  final PlaceSuggestion suggestion;
  final Locale locale;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? AppColors.cream : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Icon(Icons.place, size: 14, color: AppColors.hint),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion.label,
                  style: AppFonts.body(
                    locale,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirms the auto-detected coordinates/offset/timezone once a birth city
/// is selected, recomputed whenever the city, date or time changes.
class _GeoChip extends StatelessWidget {
  const _GeoChip({
    required this.l10n,
    required this.locale,
    required this.city,
    required this.dateOfBirth,
    required this.timeOfBirth,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final City city;
  final DateTime dateOfBirth;
  final TimeOfDay timeOfBirth;

  @override
  Widget build(BuildContext context) {
    final latSuffix = city.latitude >= 0 ? 'N' : 'S';
    final lonSuffix = city.longitude >= 0 ? 'E' : 'W';
    final latLabel = '${city.latitude.abs().toStringAsFixed(3)}°$latSuffix';
    final lonLabel = '${city.longitude.abs().toStringAsFixed(3)}°$lonSuffix';
    final offset = utcOffsetLabelFor(city, dateOfBirth, timeOfBirth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.geoChipBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        l10n.birthGeoDetected(latLabel, lonLabel, offset, city.timezoneId),
        style: AppFonts.body(
          locale,
          fontSize: 9.5,
          color: AppColors.geoChipText,
        ),
      ),
    );
  }
}

/// "I don't know my exact birth time" checkbox row.
class _UnknownTimeCheckbox extends StatelessWidget {
  const _UnknownTimeCheckbox({
    required this.l10n,
    required this.locale,
    required this.checked,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      label: l10n.birthTimeUnknown,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: checked ? AppColors.saffron : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.otpBorderFilled,
                      width: 1.5,
                    ),
                  ),
                  child: checked
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    l10n.birthTimeUnknown,
                    style: AppFonts.body(
                      locale,
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width "Create My Profile ✨" CTA, disabled until the form is
/// complete. Shares the saffron-gradient pill recipe of the Welcome/Login
/// screen's `_GetOtpButton`.
class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.l10n,
    required this.locale,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: l10n.birthSave,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.saffron.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                gradient: enabled ? AppColors.saffronGradient : null,
                color: enabled
                    ? null
                    : AppColors.saffron.withValues(alpha: 0.35),
              ),
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        l10n.birthSave,
                        style: AppFonts.body(
                          locale,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

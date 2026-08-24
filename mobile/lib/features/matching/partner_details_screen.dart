import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/geo/city.dart';
import '../../core/geo/place_search.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../profile/birth_profile.dart';

/// Collects the OTHER person's birth details for a Gun Milan match.
///
/// ADDED 21 Aug 2026 — the missing screen behind the Kundli Matching
/// screen's two inert "Change" buttons. See [partnerProfileProvider] for why
/// what it collects is held in memory rather than saved.
///
/// Intentionally a slimmer form than `birth_details_screen.dart`: that one
/// creates the ACCOUNT's own profile and so carries onboarding copy, the
/// Google-prefilled name and the save-to-Firestore path. This one collects
/// four facts for one calculation and returns them.
///
/// Birth time is required here, unlike the account profile's
/// "I don't know my birth time" escape hatch. Gun Milan is computed from the
/// Moon's nakshatra, which moves roughly one pada every hour — a guessed
/// noon would produce a confident 36-guna score that is simply wrong, and
/// the user has no way to tell. Better to require the time than to return a
/// marriage verdict built on a placeholder.
class PartnerDetailsScreen extends ConsumerStatefulWidget {
  const PartnerDetailsScreen({
    super.key,
    this.initialGender = Gender.female,
    this.initial,
  });

  final Gender initialGender;

  /// Pre-fills the form when editing someone already entered.
  final BirthProfile? initial;

  @override
  ConsumerState<PartnerDetailsScreen> createState() =>
      _PartnerDetailsScreenState();
}

class _PartnerDetailsScreenState extends ConsumerState<PartnerDetailsScreen> {
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();

  late Gender _gender = widget.initialGender;
  DateTime? _dateOfBirth;
  TimeOfDay? _timeOfBirth;
  City? _city;

  List<PlaceSuggestion> _suggestions = const [];
  Timer? _debounce;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.initial;
    if (existing != null) {
      _nameController.text = existing.fullName;
      _placeController.text = existing.city.name;
      _gender = existing.gender;
      _dateOfBirth = existing.dateOfBirth;
      _timeOfBirth = existing.timeOfBirth;
      _city = existing.city;
    }
    ref.read(placeSearchProvider).startSession();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _dateOfBirth != null &&
      _timeOfBirth != null &&
      _city != null;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfBirth ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _timeOfBirth = picked);
  }

  void _onPlaceChanged(String value) {
    _debounce?.cancel();
    // Typing after a selection invalidates it — the coordinates on file no
    // longer match what the field says. Same rule as the Birth Details
    // screen, and it matters more here: a stale city would silently move
    // the partner's chart to another place.
    if (_city != null) setState(() => _city = null);
    final query = value.trim();
    if (query.length < 2) {
      setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final results = await ref.read(placeSearchProvider).search(query);
        if (mounted) setState(() => _suggestions = results);
      } catch (_) {
        if (mounted) setState(() => _suggestions = const []);
      }
    });
  }

  Future<void> _selectPlace(PlaceSuggestion suggestion) async {
    setState(() => _isResolving = true);
    try {
      final city = await ref.read(placeSearchProvider).resolve(suggestion);
      if (city == null || !mounted) return;
      setState(() {
        _city = city;
        _placeController.text = city.name;
        _suggestions = const [];
      });
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  /// RETURNS the profile rather than storing it — changed 21 Aug 2026 so
  /// this form can serve more than one caller.
  ///
  /// It was written specifically for Gun Milan and wrote straight into
  /// `partnerProfileProvider`. The Kundli screen's "Add family or friend"
  /// button needs exactly the same four facts about exactly the same kind
  /// of person, but stores them somewhere else — and the two must not share
  /// a slot, or adding a family member would silently replace the partner
  /// you were about to match against. Popping the value lets each caller
  /// decide where it goes.
  void _save() {
    if (!_canSave) return;
    Navigator.of(context).pop(
      BirthProfile(
        fullName: _nameController.text.trim(),
        gender: _gender,
        dateOfBirth: _dateOfBirth!,
        timeOfBirth: _timeOfBirth!,
        isBirthTimeUnknown: false,
        city: _city!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          l10n.partnerDetailsTitle,
          style: AppFonts.heading(
            locale,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _Label(l10n.birthFullNameLabel, locale: locale),
          TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            decoration: _decoration(l10n.birthNameHint),
            style: AppFonts.body(locale, fontSize: 14, color: AppColors.ink),
          ),
          const SizedBox(height: 16),

          _Label(l10n.birthGenderLabel, locale: locale),
          Row(
            children: [
              for (final gender in Gender.values) ...[
                _GenderPill(
                  gender: gender,
                  isSelected: _gender == gender,
                  locale: locale,
                  l10n: l10n,
                  onTap: () => setState(() => _gender = gender),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 16),

          _Label(l10n.birthDobLabel, locale: locale),
          _PickerField(
            text: _dateOfBirth == null
                ? l10n.birthDateHint
                : BirthProfile.formatDate(_dateOfBirth!),
            isPlaceholder: _dateOfBirth == null,
            icon: Icons.calendar_today_outlined,
            locale: locale,
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),

          _Label(l10n.birthTobLabel, locale: locale),
          _PickerField(
            text: _timeOfBirth == null
                ? l10n.birthTimeHint
                : BirthProfile.formatTime(_timeOfBirth!),
            isPlaceholder: _timeOfBirth == null,
            icon: Icons.access_time,
            locale: locale,
            onTap: _pickTime,
          ),
          const SizedBox(height: 16),

          _Label(l10n.birthPlaceLabel, locale: locale),
          TextField(
            controller: _placeController,
            onChanged: _onPlaceChanged,
            decoration: _decoration(l10n.birthPlaceHint),
            style: AppFonts.body(locale, fontSize: 14, color: AppColors.ink),
          ),
          if (_isResolving)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          for (final suggestion in _suggestions)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined, size: 18),
              title: Text(
                suggestion.label,
                style: AppFonts.body(
                  locale,
                  fontSize: 13,
                  color: AppColors.ink,
                ),
              ),
              onTap: () => _selectPlace(suggestion),
            ),
          if (_city != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${_city!.latitude.toStringAsFixed(3)}°, '
                '${_city!.longitude.toStringAsFixed(3)}° · '
                '${_city!.timezoneId}',
                style: AppFonts.body(
                  locale,
                  fontSize: 11.5,
                  color: AppColors.hint,
                ),
              ),
            ),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _canSave ? _save : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.saffron,
                disabledBackgroundColor: AppColors.saffron.withValues(
                  alpha: 0.35,
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                l10n.partnerDetailsSave,
                style: AppFonts.body(
                  locale,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppColors.cardBorder),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.locale});

  final String text;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppFonts.body(
          locale,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.hint,
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.text,
    required this.isPlaceholder,
    required this.icon,
    required this.locale,
    required this.onTap,
  });

  final String text;
  final bool isPlaceholder;
  final IconData icon;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: AppColors.hint),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: AppFonts.body(
                  locale,
                  fontSize: 14,
                  color: isPlaceholder ? AppColors.hint : AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderPill extends StatelessWidget {
  const _GenderPill({
    required this.gender,
    required this.isSelected,
    required this.locale,
    required this.l10n,
    required this.onTap,
  });

  final Gender gender;
  final bool isSelected;
  final Locale locale;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = switch (gender) {
      Gender.male => l10n.genderMale,
      Gender.female => l10n.genderFemale,
      Gender.other => l10n.genderOther,
    };
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.saffron : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: isSelected ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: AppFonts.body(
            locale,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

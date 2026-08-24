import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/geo/place_search.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import 'panchang_location.dart';

/// Lets the user pin the city their panchang is computed for, or return to
/// automatic detection.
///
/// ADDED 21 Aug 2026. The Profile screen has had a "Panchang location" row
/// since the design was built, but it was an inert no-op showing the
/// hardcoded string 'Hyderabad'. This is the screen behind it.
///
/// Why a manual override exists at all, when the app now reads coarse GPS:
/// detection can be wrong or unavailable (permission denied, location off,
/// no fix indoors), and someone may legitimately want another city's timings
/// — planning a trip, or following the panchang of a family temple town. An
/// explicit choice must always beat inference, so [panchangLocationProvider]
/// checks the override first.
///
/// Search reuses [placeSearchProvider] — the same Google-Places-with-offline-
/// fallback stack the Birth Details screen uses, so behaviour, attribution
/// and offline degradation are identical and there is no second search
/// implementation to keep in step.
class PanchangLocationScreen extends ConsumerStatefulWidget {
  const PanchangLocationScreen({super.key});

  @override
  ConsumerState<PanchangLocationScreen> createState() =>
      _PanchangLocationScreenState();
}

class _PanchangLocationScreenState
    extends ConsumerState<PanchangLocationScreen> {
  final _controller = TextEditingController();
  List<PlaceSuggestion> _suggestions = const [];
  Timer? _debounce;
  bool _isSearching = false;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    // Places bills per session, not per keystroke — same pattern as the
    // Birth Details screen.
    ref.read(placeSearchProvider).startSession();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _isSearching = true);
    try {
      final results = await ref.read(placeSearchProvider).search(query);
      if (!mounted) return;
      setState(() => _suggestions = results);
    } catch (_) {
      if (!mounted) return;
      setState(() => _suggestions = const []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _select(PlaceSuggestion suggestion) async {
    setState(() => _isResolving = true);
    try {
      final city = await ref.read(placeSearchProvider).resolve(suggestion);
      if (city == null || !mounted) return;
      await ref
          .read(panchangLocationOverrideProvider.notifier)
          .setCity(city);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  Future<void> _useAutomatic() async {
    await ref.read(panchangLocationOverrideProvider.notifier).setCity(null);
    // Re-run detection so returning to Panchang reflects the change at once
    // rather than after the next cold start.
    ref.invalidate(deviceCityProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final resolved = ref.watch(panchangLocationProvider);
    final override = ref.watch(panchangLocationOverrideProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          l10n.profilePanchangLocation,
          style: AppFonts.heading(
            locale,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _CurrentCard(resolved: resolved, locale: locale),
          const SizedBox(height: 18),
          TextField(
            controller: _controller,
            onChanged: _onQueryChanged,
            style: AppFonts.body(locale, fontSize: 14, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: l10n.birthPlaceHint,
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ),
          if (_isSearching || _isResolving)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          for (final suggestion in _suggestions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined, size: 20),
              title: Text(
                suggestion.label,
                style: AppFonts.body(
                  locale,
                  fontSize: 13.5,
                  color: AppColors.ink,
                ),
              ),
              onTap: _isResolving ? null : () => _select(suggestion),
            ),
          if (override != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _useAutomatic,
              icon: const Icon(Icons.my_location, size: 18),
              label: Text(
                l10n.panchangLocationUseAutomatic,
                style: AppFonts.body(
                  locale,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.saffron,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shows the city in force and — importantly — WHERE IT CAME FROM.
///
/// A user who sees the wrong city needs to know whether the app detected it,
/// inherited it from their birth details, or was told to use it, because
/// that determines what they should do about it.
class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.resolved, required this.locale});

  final PanchangLocation resolved;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String sourceLabel = switch (resolved.source) {
      PanchangLocationSource.manual => l10n.panchangLocationSourceManual,
      PanchangLocationSource.device => l10n.panchangLocationSourceDevice,
      PanchangLocationSource.birthProfile =>
        l10n.panchangLocationSourceBirthProfile,
      PanchangLocationSource.fallback => l10n.panchangLocationSourceFallback,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.place, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resolved.city.name,
                  style: AppFonts.heading(
                    locale,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sourceLabel,
                  style: AppFonts.body(
                    locale,
                    fontSize: 11.5,
                    color: AppColors.hint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

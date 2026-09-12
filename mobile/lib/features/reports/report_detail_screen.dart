import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/motion/app_motion.dart';
import '../../core/purchases/purchases_providers.dart';
import '../../core/purchases/purchases_service.dart';
import '../../core/purchases/report_catalogue.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/premium_glimpse.dart';
import '../../l10n/app_localizations.dart';
import '../kundli/kundli_repository.dart';
import '../premium/purchase_error_messages.dart';
import '../premium/subscription_paywall_screen.dart';
import '../profile/birth_profile_repository.dart';
import 'package:printing/printing.dart';

import 'report_content.dart';
import 'report_labels.dart';
import 'report_pdf.dart';
import 'report_repository.dart';
import 'reports_static_data.dart';

/// One premium report, opened from a card on the Premium Reports screen.
///
/// BUILT 2 Sep 2026 for the client's request: *"for reports after clicking
/// show sample glimpse report set like that so that it can engage users"*.
///
/// Before this, tapping a PREMIUM card pushed the paywall straight away and a
/// FREE card did nothing at all — so the whole Reports screen was seven rows
/// that led nowhere. Now every card opens this screen, which fetches the
/// user's OWN report from Vedika and shows it.
///
/// ## The premium/free split is the only branch
///
/// A free report ([ReportAccess.free] — Gemstone and Numerology) renders in
/// full. A premium one renders through [PremiumGlimpse]: the same real
/// content, cut off partway with an upgrade CTA underneath. The content
/// fetched is identical either way; only the presentation differs.
///
/// Since 9 Sep 2026 a SUBSCRIBER gets the full body — the screen reads
/// `subscriptionStatusValueProvider`. Before that it did not, so paying
/// changed nothing the user could see, which is what the client reported as
/// *"i upgraded into premium but its not reflecting"*.
///
/// ⚠️ **Still a CLIENT-SIDE gate, not server-side enforcement.** The full
/// payload is fetched before the gate is applied, so the gradient hides
/// content the device already holds. That is fine for an upsell teaser and
/// NOT fine as the only thing standing between a free user and paid content —
/// the body must eventually be served behind a server-side entitlement check.
class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.report});

  final AstrologyReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final profile = ref.watch(birthProfileProvider).value;
    final birth = profile == null
        ? null
        : KundliRequest.fromBirthProfile(profile);
    final contentAsync = birth == null
        ? null
        : ref.watch(
            reportContentProvider(
              ReportRequest(reportId: report.id, birth: birth),
            ),
          );

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
          children: [
            _Header(
              title: reportTitle(report.id, l10n),
              locale: locale,
            ),
            const SizedBox(height: 18),
            _IntroCard(report: report, l10n: l10n, locale: locale),
            const SizedBox(height: 18),
            if (contentAsync == null)
              // No saved birth profile → no chart → nothing honest to show.
              _Message(l10n.reportEmptyMessage, locale: locale)
            else
              contentAsync.when(
                loading: () => const _Loading(),
                error: (error, stackTrace) => _Message(
                  l10n.kundliLoadErrorMessage,
                  locale: locale,
                  onRetry: () => ref.invalidate(
                    reportContentProvider(
                      ReportRequest(reportId: report.id, birth: birth!),
                    ),
                  ),
                ),
                // Built HERE, not in the repository: the labels are
                // localized, so the same cached payload has to render in
                // whatever language is active right now.
                data: (payload) => _Body(
                  report: report,
                  content: buildReportContent(report.id, payload, l10n),
                  l10n: l10n,
                  locale: locale,
                  // TWO ways to see a full report:
                  //  1. having BOUGHT this one report outright, or
                  //  2. it being a free report to begin with.
                  // Ownership is the server-written ledger, not anything the
                  // client can assert.
                  //
                  // ⚠️ A SUBSCRIPTION NO LONGER UNLOCKS REPORTS (12 Sep 2026,
                  // client: *"we can't give free for subscription users, just
                  // give discounts as respective plans"*). Until then any paid
                  // tier read every premium report for free, so the 14 report
                  // SKUs were unsellable to exactly the users most likely to
                  // buy them.
                  //
                  // What replaces it is NOT built yet and must not be faked
                  // here: the per-tier discount (5/10/15/20%) cannot be
                  // applied client-side because Play sets the price per SKU,
                  // and Platinum's one free Complete Report per month is a
                  // server-side grant that does not exist. Both are tracked in
                  // `claudedocs/vedika-prebuilt-reports.md`. Granting access
                  // here to approximate either one would put entitlement back
                  // on the client, which this codebase refuses everywhere.
                  hasPaidAccess:
                      (ref.watch(ownedReportsProvider).valueOrNull ?? const {})
                          .contains(report.id),
                  purchasable: ref
                      .watch(reportCatalogueProvider)
                      .valueOrNull?[report.id],
                  personName: profile?.fullName ?? '',
                  birthSummary: profile?.summaryLine ?? '',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.report,
    required this.content,
    required this.l10n,
    required this.locale,
    required this.hasPaidAccess,
    required this.purchasable,
    required this.personName,
    required this.birthSummary,
  });

  final AstrologyReport report;
  final ReportContent content;
  final AppLocalizations l10n;
  final Locale locale;

  /// Whether the reader may see the full body — subscription, outright
  /// purchase, or a free report. `false` also while RevenueCat has not
  /// answered yet; see the note at the `PremiumGlimpse` below.
  final bool hasPaidAccess;

  /// This report as a one-time purchase, when Play offers it. `null` for the
  /// three products with no deliverable data (see [reportSkus]) and whenever
  /// the store is unreachable — in both cases the glimpse simply falls back
  /// to the subscription CTA rather than showing a Buy button that cannot
  /// complete.
  final PurchasableReport? purchasable;

  /// Printed on the PDF cover, so a shared file says whose chart it is.
  final String personName;
  final String birthSummary;

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return _Message(l10n.reportEmptyMessage, locale: locale);
    }

    final sections = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, section) in content.sections.indexed)
          if (section.lines.isNotEmpty)
            EntranceFadeSlide(
              index: index,
              child: _Section(
                section: section,
                report: report,
                l10n: l10n,
                locale: locale,
              ),
            ),
      ],
    );

    // ⚠️ THE PAID PATH, added 9 Sep 2026. Until now this line was the ONLY
    // branch: a premium report was cut off by [PremiumGlimpse] for everyone,
    // subscribers included, so paying changed nothing a user could see.
    //
    // While RevenueCat has not answered, `hasPaidAccess` is false and the
    // glimpse shows. That is the deliberate direction to fail in: a
    // subscriber briefly sees a teaser that then expands, rather than a free
    // user briefly seeing the whole report.
    if (report.access == ReportAccess.free || hasPaidAccess) {
      // ⚠️ The download button lives ONLY here, on the unlocked path.
      // Offering it beside a glimpse would export the cut-off teaser as a
      // finished document — the gradient hides content the device already
      // holds, so the PDF would contain the paid text in full. That is the
      // one place this client-side gate would actually leak.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          sections,
          const SizedBox(height: 18),
          _DownloadPdfButton(
            reportId: report.id,
            content: content,
            l10n: l10n,
            locale: locale,
            personName: personName,
            birthSummary: birthSummary,
          ),
        ],
      );
    }

    // BUY-ONCE, added 10 Sep 2026. When Play offers this single report, the
    // glimpse's CTA becomes "Unlock this report · ₹x" instead of a
    // subscription pitch — someone reading the Marriage Report wants THAT
    // report, and asking them to commit to a monthly plan first is the same
    // mistake the AI-pack sheet fixed. The subscription stays reachable
    // underneath, because for a heavy reader it is the better deal.
    final offer = purchasable;
    if (offer != null) {
      return _BuyableGlimpse(
        offer: offer,
        sections: sections,
        l10n: l10n,
        locale: locale,
      );
    }

    return PremiumGlimpse(
      locale: locale,
      previewHeight: 260,
      ctaLabel: l10n.reportGlimpseCta,
      subtitle: l10n.reportGlimpseSubtitle,
      onUpgrade: () => Navigator.of(
        context,
      ).push(fadeThroughRoute(const SubscriptionPaywallScreen())),
      child: sections,
    );
  }
}

/// A glimpse whose CTA buys this one report.
///
/// Stateful only to guard against a double tap opening two Play sheets.
class _BuyableGlimpse extends ConsumerStatefulWidget {
  const _BuyableGlimpse({
    required this.offer,
    required this.sections,
    required this.l10n,
    required this.locale,
  });

  final PurchasableReport offer;
  final Widget sections;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  ConsumerState<_BuyableGlimpse> createState() => _BuyableGlimpseState();
}

class _BuyableGlimpseState extends ConsumerState<_BuyableGlimpse> {
  bool _isBusy = false;

  Future<void> _buy() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final l10n = widget.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(purchasesServiceProvider)
          .purchaseConsumable(widget.offer.package);
      if (!mounted) return;
      // No "unlocked!" claim: ownership is granted by the RevenueCat webhook
      // and arrives through `ownedReportsProvider`, a live Firestore stream,
      // which expands this screen on its own. Asserting success here would be
      // claiming something not yet observed.
      messenger.showSnackBar(SnackBar(content: Text(l10n.aiPackPurchased)));
    } on PurchaseException catch (e) {
      if (!mounted) return;
      if (e.reason == PurchaseFailure.cancelled) return;
      messenger.showSnackBar(
        SnackBar(content: Text(purchaseFailureMessage(l10n, e.reason))),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumGlimpse(
          locale: widget.locale,
          previewHeight: 260,
          // Play's own localized price, never formatted by us.
          ctaLabel:
              '${widget.l10n.reportBuyOnce} · ${widget.offer.priceString}',
          isBusy: _isBusy,
          subtitle: widget.l10n.reportGlimpseSubtitle,
          onUpgrade: _buy,
          child: widget.sections,
        ),
        const SizedBox(height: 6),
        Center(
          child: Semantics(
            button: true,
            child: PressableScale(
              borderRadius: BorderRadius.circular(999),
              onTap: () => Navigator.of(context).push(
                fadeThroughRoute(const SubscriptionPaywallScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  widget.l10n.reportBuyOrSubscribe,
                  style: AppFonts.body(
                    widget.locale,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.saffron,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One section of a report, laid out according to **what its lines actually
/// are** rather than in one flat list.
///
/// REBUILT 8 Sep 2026 on client feedback that the report view "is not good".
/// Every line used to render identically — a saffron label above muted body
/// text, stacked 10px apart on the bare page. That collapsed three genuinely
/// different kinds of content into one shape, and it fell apart as soon as
/// the reports carried real production data: numerology alone returns 30
/// strengths and 24 challenges, so the screen became ~70 identical
/// paragraphs with no way to scan it.
///
/// Three layouts now, chosen by [ReportSectionKind]:
///
/// | Kind | Content it holds | Layout |
/// |---|---|---|
/// | overview | short labelled values ("Life path 8") | stat tiles |
/// | strengths / challenges | bare short phrases ("Ambition") | chips |
/// | everything else | labelled prose paragraphs | one card, hairline-split |
///
/// Each layout **falls back to prose** when its content does not fit the
/// assumption — a long "overview" value or a chip-length that turns out to be
/// a sentence renders as a paragraph instead of overflowing. The adapters in
/// `report_content.dart` are shared across eight endpoints with quite
/// different payloads, so the layout cannot assume the shape holds.
class _Section extends StatelessWidget {
  const _Section({
    required this.section,
    required this.report,
    required this.l10n,
    required this.locale,
  });

  final ReportSection section;
  final AstrologyReport report;
  final AppLocalizations l10n;
  final Locale locale;

  /// Longest value still rendered as a stat tile / chip. Beyond this the text
  /// is a sentence, not a token, and belongs in a paragraph.
  static const int _shortValue = 26;
  static const int _shortChip = 42;

  /// A short labelled value — "Career house: Virgo", "Life path: 8".
  bool _isStatLine(ReportLine l) =>
      section.kind == ReportSectionKind.overview &&
      (l.label?.isNotEmpty ?? false) &&
      l.text.length <= _shortValue;

  /// A bare short phrase — "Ambition", "Workaholic".
  bool _isChipLine(ReportLine l) =>
      (section.kind == ReportSectionKind.strengths ||
          section.kind == ReportSectionKind.challenges) &&
      (l.label?.isEmpty ?? true) &&
      l.text.length <= _shortChip;

  @override
  Widget build(BuildContext context) {
    // ⚠️ Partitioned PER LINE, not all-or-nothing.
    //
    // The first version demoted an entire section to prose if any single line
    // failed the test, which is how Career's overview ended up as three
    // paragraphs: two of its lines are clean tile values (Virgo, Mercury) and
    // the third happens to be a 53-character sentence. One sentence should
    // not cost the other two their layout. Sade Sati's overview had the same
    // shape ("Phase: No Sade Sati" behind a 66-character explanation).
    //
    // A section can therefore render as up to three stacked blocks. In
    // practice it is one or two; the ordering below puts the scannable part
    // first, which is the whole point of separating them.
    final tiles = <ReportLine>[];
    final chips = <ReportLine>[];
    final prose = <ReportLine>[];
    for (final line in section.lines) {
      if (_isStatLine(line)) {
        tiles.add(line);
      } else if (_isChipLine(line)) {
        chips.add(line);
      } else {
        prose.add(line);
      }
    }

    // Strengths read as affirmations and challenges as cautions, so they take
    // the palette's existing positive/ashubh pair rather than the report's
    // own accent — the distinction is the point of the section.
    final isStrength = section.kind == ReportSectionKind.strengths;

    final blocks = <Widget>[
      if (tiles.isNotEmpty)
        _StatGrid(lines: tiles, report: report, locale: locale),
      if (chips.isNotEmpty)
        _ChipWrap(
          lines: chips,
          locale: locale,
          background: isStrength ? AppColors.tileGreenBg : AppColors.ashubhBg,
          foreground: isStrength ? AppColors.tileGreenFg : AppColors.ashubhFg,
        ),
      if (prose.isNotEmpty)
        _ProseCard(lines: prose, report: report, locale: locale),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: reportSectionTitle(section.kind, l10n),
            count: section.lines.length,
            locale: locale,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < blocks.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            blocks[i],
          ],
        ],
      ),
    );
  }
}

/// Section title plus a count, so a long list announces its own length
/// instead of the reader discovering it by scrolling.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.locale,
  });

  final String title;
  final int count;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            title,
            style: AppFonts.heading(
              locale,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
        // Only worth showing once a section is long enough that its size is
        // information. "1" next to a single paragraph is noise.
        if (count > 2) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              '$count',
              style: AppFonts.body(
                locale,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Short labelled values as tiles — "Life path 8", "Lagna Sagittarius".
///
/// A [Wrap] rather than a fixed-column grid: Indic labels run 30–60% longer
/// than English (a rule this codebase has paid for before), so a two-column
/// grid that fits "Life path" clips "జీవన మార్గం". Tiles size to their own
/// content and reflow.
class _StatGrid extends StatelessWidget {
  const _StatGrid({
    required this.lines,
    required this.report,
    required this.locale,
  });

  final List<ReportLine> lines;
  final AstrologyReport report;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final line in lines)
          Container(
            constraints: const BoxConstraints(minWidth: 96),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: report.tileBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line.text,
                  // Playfair for the value: these are the headline facts of
                  // the report and the display face is what makes them read
                  // as such rather than as another data row.
                  style: AppFonts.heading(
                    locale,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: report.tileFg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  line.label ?? '',
                  style: AppFonts.body(
                    locale,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Bare short phrases as chips. This is what turns numerology's 30 strengths
/// from thirty stacked paragraphs into something scannable at a glance.
class _ChipWrap extends StatelessWidget {
  const _ChipWrap({
    required this.lines,
    required this.locale,
    required this.background,
    required this.foreground,
  });

  final List<ReportLine> lines;
  final Locale locale;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final line in lines)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              line.text,
              style: AppFonts.body(
                locale,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: foreground,
              ),
            ),
          ),
      ],
    );
  }
}

/// Labelled paragraphs in ONE card, split by hairlines.
///
/// One card per line was the obvious alternative and is worse: six cards of
/// prose read as six unrelated things, where the section is one thing with
/// six parts. The rules do the separating; the card does the grouping.
class _ProseCard extends StatelessWidget {
  const _ProseCard({
    required this.lines,
    required this.report,
    required this.locale,
  });

  final List<ReportLine> lines;
  final AstrologyReport report;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: _ProseLine(
                line: lines[i],
                report: report,
                locale: locale,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProseLine extends StatelessWidget {
  const _ProseLine({
    required this.line,
    required this.report,
    required this.locale,
  });

  final ReportLine line;
  final AstrologyReport report;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final label = line.label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label.isNotEmpty) ...[
          Text(
            label,
            style: AppFonts.body(
              locale,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: report.tileFg,
            ),
          ),
          const SizedBox(height: 5),
        ],
        if (line.text.isNotEmpty)
          Text(
            line.text,
            style: AppFonts.body(
              locale,
              fontSize: 13.5,
              // 1.5 line height: these are multi-sentence readings, and the
              // default leading makes a paragraph of them a solid block.
              height: 1.5,
              color: AppColors.ink,
            ),
          ),
      ],
    );
  }
}

/// Title + description card, so the screen names the report before its
/// content loads rather than opening on a bare spinner.
class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.report,
    required this.l10n,
    required this.locale,
  });

  final AstrologyReport report;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: report.tileBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(report.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reportDescription(report.id, l10n),
              style: AppFonts.body(
                locale,
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.locale});

  final String title;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          child: PressableScale(
            borderRadius: BorderRadius.circular(999),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Icon(Icons.arrow_back, size: 18, color: AppColors.ink),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.heading(
              locale,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: i == 0 ? 20 : 54,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {required this.locale, this.onRetry});

  final String text;
  final Locale locale;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppFonts.body(locale, fontSize: 13, color: AppColors.muted),
          ),
          if (onRetry case final retry?) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: retry, child: Text(l10n.retry)),
          ],
        ],
      ),
    );
  }
}

/// "Download PDF", on every report the reader is entitled to see in full.
///
/// BUILT 10 Sep 2026. Uses `Printing.sharePdf`, which opens Android's share
/// sheet — that is what lets the user save to Files, send on WhatsApp, or
/// print, without the app asking for storage permission. Writing to external
/// storage ourselves would need a permission the app does not currently
/// request and that Play scrutinises.
class _DownloadPdfButton extends StatefulWidget {
  const _DownloadPdfButton({
    required this.reportId,
    required this.content,
    required this.l10n,
    required this.locale,
    required this.personName,
    required this.birthSummary,
  });

  final String reportId;
  final ReportContent content;
  final AppLocalizations l10n;
  final Locale locale;
  final String personName;
  final String birthSummary;

  @override
  State<_DownloadPdfButton> createState() => _DownloadPdfButtonState();
}

class _DownloadPdfButtonState extends State<_DownloadPdfButton> {
  bool _isBusy = false;

  Future<void> _download() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await ReportPdf.build(
        reportId: widget.reportId,
        content: widget.content,
        l10n: widget.l10n,
        personName: widget.personName,
        birthSummary: widget.birthSummary,
      );
      if (!mounted) return;
      // A filename the user can find again — "document.pdf" in a Downloads
      // folder of thirty files is not a deliverable.
      final safeTitle = reportTitle(widget.reportId, widget.l10n)
          .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-|-$'), '');
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Vedadarshi-$safeTitle.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('Report PDF failed: $e');
      messenger.showSnackBar(
        SnackBar(content: Text(widget.l10n.reportPdfFailed)),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: PressableScale(
        borderRadius: BorderRadius.circular(999),
        onTap: _download,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: _isBusy
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.saffron),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.download_rounded,
                      size: 17,
                      color: AppColors.saffron,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.l10n.reportDownloadPdf,
                      style: AppFonts.body(
                        widget.locale,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.saffron,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

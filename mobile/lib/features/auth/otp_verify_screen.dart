import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_placeholder_screen.dart';
import 'auth_error_messages.dart';

/// Number of digits in the OTP code.
const int _kOtpLength = 6;

/// Seconds the "Resend" action stays disabled after an OTP is (re)sent.
const int _kResendCooldownSeconds = 30;

/// OTP verification screen, matching the approved Figma "A4 · OTP Verify"
/// (node 7:27) concept.
///
/// Reached from [WelcomeLoginScreen] after a phone OTP has been requested.
/// Confirms the 6-digit SMS code via [AuthService.verifyOtp] and, on
/// success, proceeds to [HomePlaceholderScreen] clearing the nav stack.
class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.phoneE164,
    required this.verificationId,
    required this.resendToken,
  });

  /// The phone number (E.164, e.g. `+919876543210`) the code was sent to.
  final String phoneE164;

  /// Opaque Firebase verification session id for the code currently in
  /// flight — passed to [AuthService.verifyOtp].
  final String verificationId;

  /// Token from the initiating [AuthService.sendOtp] call, forwarded to a
  /// follow-up call when the user taps "Resend" so Firebase reuses the same
  /// SMS session.
  final int? resendToken;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  late final List<TextEditingController> _controllers = List.generate(
    _kOtpLength,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _focusNodes = List.generate(
    _kOtpLength,
    (_) => FocusNode(),
  );

  late String _verificationId = widget.verificationId;
  int? _resendToken;

  Timer? _countdownTimer;
  int _secondsRemaining = _kResendCooldownSeconds;

  bool _isVerifying = false;
  bool _isResending = false;
  bool _autoSubmitTriggered = false;

  @override
  void initState() {
    super.initState();
    _resendToken = widget.resendToken;
    for (final controller in _controllers) {
      controller.addListener(_onBoxStateChanged);
    }
    for (final focusNode in _focusNodes) {
      focusNode.addListener(_onBoxStateChanged);
    }
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Purely triggers a rebuild so box borders react to focus/text changes —
  // the actual OTP-entry logic (advancing focus, distributing pastes, auto
  // submit) lives in [_handleChanged] and [_handleBackspaceOnEmpty].
  void _onBoxStateChanged() => setState(() {});

  bool get _allDigitsFilled =>
      _controllers.every((controller) => controller.text.length == 1);

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _secondsRemaining = _kResendCooldownSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Masks [phoneE164] as e.g. `+91 98••• ••210`: the leading `+`/country
  /// code and first 2 local digits stay visible, the last 3 local digits
  /// stay visible, and everything in between is masked. Degrades gracefully
  /// for short/odd-length input instead of throwing a range error.
  String _maskPhone(String phoneE164) {
    final hasPlus = phoneE164.startsWith('+');
    final digits = phoneE164.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return phoneE164;

    // The app only ever collects 10-digit local numbers (see
    // WelcomeLoginScreen's phone field), so anything beyond the trailing 10
    // digits is treated as the country code.
    final countryCodeLen = digits.length > 10 ? digits.length - 10 : 0;
    final countryCode = digits.substring(0, countryCodeLen);
    final local = digits.substring(countryCodeLen);

    String masked;
    if (local.length <= 1) {
      masked = local;
    } else if (local.length <= 5) {
      // Too short to keep both a 2-digit head and 3-digit tail visible —
      // mask everything except the last digit.
      masked =
          '${'•' * (local.length - 1)}${local.substring(local.length - 1)}';
    } else {
      final visibleStart = local.substring(0, 2);
      final visibleEnd = local.substring(local.length - 3);
      final maskedLen = local.length - 5;
      if (maskedLen <= 3) {
        masked = '$visibleStart${'•' * maskedLen} $visibleEnd';
      } else {
        final firstMaskLen = (maskedLen / 2).ceil();
        final secondMaskLen = maskedLen - firstMaskLen;
        masked =
            '$visibleStart${'•' * firstMaskLen} '
            '${'•' * secondMaskLen}$visibleEnd';
      }
    }

    final prefix = hasPlus ? '+' : '';
    return countryCode.isEmpty
        ? '$prefix$masked'
        : '$prefix$countryCode $masked';
  }

  void _clearBoxes() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _autoSubmitTriggered = false;
    _focusNodes.first.requestFocus();
  }

  /// Handles both single-digit typing and multi-digit paste/autofill (some
  /// platforms briefly bypass the per-box `maxLength: 1` formatter when
  /// autofilling an SMS code, delivering the whole code to whichever box is
  /// focused).
  void _handleChanged(int index, String rawValue) {
    final digits = rawValue.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 1) {
      for (var i = 0; i < _kOtpLength; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      for (final node in _focusNodes) {
        node.unfocus();
      }
      if (digits.length < _kOtpLength) {
        _focusNodes[digits.length].requestFocus();
      }
      _maybeAutoSubmit();
      return;
    }

    if (_controllers[index].text != digits) {
      _controllers[index].text = digits;
    }

    if (digits.isNotEmpty) {
      if (index < _kOtpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    _maybeAutoSubmit();
  }

  void _handleBackspaceOnEmpty(int index) {
    if (index == 0 || _controllers[index].text.isNotEmpty) return;
    _controllers[index - 1].clear();
    _focusNodes[index - 1].requestFocus();
  }

  void _maybeAutoSubmit() {
    if (_autoSubmitTriggered || !_allDigitsFilled) return;
    _autoSubmitTriggered = true;
    unawaited(_verify());
  }

  Future<void> _verify() async {
    if (_isVerifying) return;
    final code = _controllers.map((c) => c.text).join();
    if (code.length != _kOtpLength) {
      _autoSubmitTriggered = false;
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final authService = ref.read(authServiceProvider);
    setState(() => _isVerifying = true);
    try {
      await authService.verifyOtp(
        verificationId: _verificationId,
        smsCode: code,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil<void>(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePlaceholderScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      final message = authErrorMessage(l10n, e.code);
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      _clearBoxes();
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _autoSubmitTriggered = false;
        });
      }
    }
  }

  Future<void> _resend() async {
    if (_isResending || _secondsRemaining > 0) return;

    final l10n = AppLocalizations.of(context)!;
    final authService = ref.read(authServiceProvider);
    setState(() => _isResending = true);
    try {
      final result = await authService.sendOtp(
        phoneE164: widget.phoneE164,
        resendToken: _resendToken,
      );
      if (!mounted) return;

      if (result.autoVerified) {
        Navigator.of(context).pushAndRemoveUntil<void>(
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomePlaceholderScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
          (route) => false,
        );
        return;
      }

      setState(() {
        _verificationId = result.verificationId;
        _resendToken = result.resendToken;
      });
      _startCountdown();
      _clearBoxes();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.otpResent)));
    } on AuthException catch (e) {
      if (!mounted) return;
      final message = authErrorMessage(l10n, e.code);
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final maskedPhone = _maskPhone(widget.phoneE164);

    // Compact phones get tighter spacing so the whole screen fits without
    // scrolling; taller screens keep the roomier Figma proportions.
    final isCompact = MediaQuery.sizeOf(context).height < 840;
    final gap = isCompact ? 18.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: isCompact ? 24 : 48,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackButton(onTap: () => Navigator.of(context).pop()),
              SizedBox(height: gap),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.otpTitle,
                    style: AppFonts.heading(
                      locale,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.otpSubtitle(maskedPhone),
                    style: AppFonts.body(
                      locale,
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: gap),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _kOtpLength; i++) ...[
                    _buildOtpBox(i),
                    if (i != _kOtpLength - 1) const SizedBox(width: 10),
                  ],
                ],
              ),
              SizedBox(height: gap),
              // Wrap, not Row: the "Didn't receive the code? / Resend in…"
              // pair runs far wider than the screen in Tamil and Kannada, so
              // it must be allowed to break onto a second line.
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      l10n.otpNoCode,
                      style: AppFonts.body(
                        locale,
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                    if (_secondsRemaining > 0)
                      Text(
                        l10n.otpResendIn(_formatCountdown(_secondsRemaining)),
                        style: AppFonts.body(
                          locale,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.saffron,
                        ),
                      )
                    else
                      InkWell(
                        onTap: _isResending ? null : _resend,
                        child: Text(
                          l10n.otpResend,
                          style: AppFonts.body(
                            locale,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.saffron,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: gap),
              _VerifyButton(
                label: l10n.otpVerify,
                locale: locale,
                enabled: _allDigitsFilled,
                loading: _isVerifying,
                onTap: _verify,
              ),
              SizedBox(height: gap),
              Center(
                child: Text(
                  l10n.otpPrivacy,
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

  Widget _buildOtpBox(int index) {
    final controller = _controllers[index];
    final focusNode = _focusNodes[index];
    final hasDigit = controller.text.isNotEmpty;
    final isFocused = focusNode.hasFocus;

    Border border;
    List<BoxShadow>? shadow;
    if (isFocused) {
      border = Border.all(color: AppColors.saffron, width: 1.5);
      shadow = [
        BoxShadow(
          color: AppColors.saffron.withValues(alpha: 0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (hasDigit) {
      border = Border.all(color: AppColors.otpBorderFilled);
    } else {
      border = Border.all(color: AppColors.cardBorder);
    }

    return Expanded(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 52),
          child: AspectRatio(
            aspectRatio: 52 / 60,
            child: Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace) {
                  _handleBackspaceOnEmpty(index);
                }
                return KeyEventResult.ignored;
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: border,
                  boxShadow: shadow,
                ),
                child: Center(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    showCursor: true,
                    cursorColor: AppColors.saffron,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                    ),
                    // Digits are always Latin regardless of the active app
                    // locale.
                    style: AppFonts.body(
                      const Locale('en'),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                    onChanged: (value) => _handleChanged(index, value),
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

/// The 44×44 circular back button in the top-left corner.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: AppColors.cardBorder)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back, size: 18, color: AppColors.ink),
        ),
      ),
    );
  }
}

/// Full-width "Verify & Continue" CTA, disabled until all 6 digits are
/// entered and showing a spinner in place of the label while verifying.
/// Shares the saffron-gradient pill recipe of the Welcome/Login screen's
/// `_GetOtpButton`.
class _VerifyButton extends StatelessWidget {
  const _VerifyButton({
    required this.label,
    required this.locale,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final Locale locale;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = enabled && !loading;
    return Semantics(
      button: true,
      enabled: isActive,
      label: label,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: isActive
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
            onTap: isActive ? onTap : null,
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                gradient: isActive ? AppColors.saffronGradient : null,
                color: isActive
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
                        label,
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

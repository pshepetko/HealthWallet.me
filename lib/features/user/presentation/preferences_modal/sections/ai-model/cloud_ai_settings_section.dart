import 'package:flutter/material.dart';
import 'package:healthwithme/core/config/constants/shared_prefs_constants.dart';
import 'package:healthwithme/core/di/injection.dart';
import 'package:healthwithme/core/theme/app_color.dart';
import 'package:healthwithme/core/theme/app_insets.dart';
import 'package:healthwithme/core/theme/app_text_style.dart';
import 'package:healthwithme/core/utils/build_context_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _CloudAiMode {
  auto,
  onDevice,
  cloud;

  String get storageValue {
    switch (this) {
      case _CloudAiMode.auto:
        return 'auto';
      case _CloudAiMode.onDevice:
        return 'onDevice';
      case _CloudAiMode.cloud:
        return 'cloud';
    }
  }

  static _CloudAiMode fromStorage(String? value) {
    switch (value) {
      case 'onDevice':
        return _CloudAiMode.onDevice;
      case 'cloud':
        return _CloudAiMode.cloud;
      case 'auto':
      default:
        return _CloudAiMode.auto;
    }
  }
}

/// Provider selection, explicit cloud consent and local fallback controls.
///
/// Persists directly to [SharedPreferences] using the same keys consumed by
/// `AiProviderResolver`, so no extra BLoC wiring is required.
class CloudAiSettingsSection extends StatefulWidget {
  const CloudAiSettingsSection({super.key});

  @override
  State<CloudAiSettingsSection> createState() => _CloudAiSettingsSectionState();
}

class _CloudAiSettingsSectionState extends State<CloudAiSettingsSection> {
  late final SharedPreferences _prefs;
  late _CloudAiMode _mode;
  late bool _consent;
  late bool _fallback;

  @override
  void initState() {
    super.initState();
    _prefs = getIt<SharedPreferences>();
    _mode = _CloudAiMode.fromStorage(
      _prefs.getString(SharedPrefsConstants.aiProviderMode),
    );
    _consent =
        _prefs.getBool(SharedPrefsConstants.cloudAiConsentGiven) ?? false;
    _fallback =
        _prefs.getBool(SharedPrefsConstants.cloudFallbackToLocal) ?? true;
  }

  Future<void> _setMode(_CloudAiMode mode) async {
    setState(() => _mode = mode);
    await _prefs.setString(
      SharedPrefsConstants.aiProviderMode,
      mode.storageValue,
    );
  }

  Future<void> _setConsent(bool value) async {
    setState(() => _consent = value);
    await _prefs.setBool(SharedPrefsConstants.cloudAiConsentGiven, value);
    if (!value && _mode == _CloudAiMode.cloud) {
      // Cloud without consent cannot run; switch back to Auto so the resolver
      // can pick a usable provider instead of silently failing.
      await _setMode(_CloudAiMode.auto);
    }
  }

  Future<void> _setFallback(bool value) async {
    setState(() => _fallback = value);
    await _prefs.setBool(SharedPrefsConstants.cloudFallbackToLocal, value);
  }

  String get _modelName {
    final configured =
        _prefs.getString(SharedPrefsConstants.cloudAiModelName)?.trim();
    if (configured == null || configured.isEmpty) return 'gemini-2.5-flash';
    return configured;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = context.theme.dividerColor;
    final textColor = context.primaryTextColor;
    final secondaryTextColor = context.secondaryTextColor;
    final showCloudOptions = _mode != _CloudAiMode.onDevice;

    return Container(
      padding: const EdgeInsets.all(Insets.smallNormal),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: Insets.small),
              Expanded(
                child: Text(
                  context.l10n.aiProviderSectionTitle,
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.extraSmall),
          Text(
            context.l10n.aiProviderSectionDescription,
            style: AppTextStyle.labelSmall.copyWith(
              color: secondaryTextColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: Insets.small),
          _buildModeOption(
            context,
            mode: _CloudAiMode.auto,
            title: context.l10n.aiProviderAuto,
            description: context.l10n.aiProviderAutoDescription,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
          _buildModeOption(
            context,
            mode: _CloudAiMode.onDevice,
            title: context.l10n.aiProviderOnDevice,
            description: context.l10n.aiProviderOnDeviceDescription,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
          _buildModeOption(
            context,
            mode: _CloudAiMode.cloud,
            title: context.l10n.aiProviderCloud,
            description: context.l10n.aiProviderCloudDescription,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
          if (showCloudOptions) ...[
            const SizedBox(height: Insets.small),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Insets.small,
                vertical: Insets.extraSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${context.l10n.aiCloudModelLabel}: $_modelName',
                      style: AppTextStyle.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Insets.small),
            _buildConsentTile(
              context,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            ),
            if (_mode == _CloudAiMode.cloud && !_consent) ...[
              const SizedBox(height: Insets.extraSmall),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.l10n.aiCloudConsentRequired,
                      style: AppTextStyle.labelSmall.copyWith(
                        color: AppColors.warning,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: Insets.extraSmall),
            _buildFallbackTile(
              context,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeOption(
    BuildContext context, {
    required _CloudAiMode mode,
    required String title,
    required String description,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final selected = _mode == mode;
    return InkWell(
      onTap: () => _setMode(mode),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.extraSmall,
          vertical: Insets.extraSmall,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 18,
              color: selected ? AppColors.primary : secondaryTextColor,
            ),
            const SizedBox(width: Insets.small),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.labelLarge.copyWith(
                      color: textColor,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyle.labelSmall.copyWith(
                      color: secondaryTextColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentTile(
    BuildContext context, {
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return InkWell(
      onTap: () => _setConsent(!_consent),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Insets.extraSmall),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _consent,
                onChanged: (value) => _setConsent(value ?? false),
          activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: Insets.small),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.aiCloudConsentTitle,
                    style: AppTextStyle.labelLarge.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.aiCloudConsentDescription,
                    style: AppTextStyle.labelSmall.copyWith(
                      color: secondaryTextColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackTile(
    BuildContext context, {
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.aiCloudFallbackTitle,
                style: AppTextStyle.labelLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.aiCloudFallbackDescription,
                style: AppTextStyle.labelSmall.copyWith(
                  color: secondaryTextColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: _fallback,
          onChanged: _setFallback,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }
}

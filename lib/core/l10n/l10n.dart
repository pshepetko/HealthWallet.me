import 'package:flutter/material.dart';
import 'package:healthwithme/core/l10n/arb/app_localizations.dart';

export 'package:healthwithme/core/l10n/arb/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:healthwithme/app/view/app.dart';
import 'package:healthwithme/bootstrap.dart';
import 'package:healthwithme/core/config/firebase/firebase_bootstrap.dart';
import 'package:healthwithme/core/di/injection.dart';
import 'package:healthwithme/core/services/deep_link_service.dart';
import 'package:healthwithme/core/services/share_intent_service.dart';
import 'package:healthwithme/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:healthwithme/firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await FirebaseBootstrap.initializeSafely(
    optionsBuilder: () => DefaultFirebaseOptions.currentPlatform,
  );

  await configureDependencies();

  getIt<ShareIntentService>().initialize();
  getIt<DeepLinkService>().initialize();
  getIt<ScanBloc>().add(const ScanInitialised());

  FlutterNativeSplash.remove();

  await bootstrap(() => const App());
}

import 'dart:typed_data';

import 'package:healthwithme/features/wallet_pass/domain/entity/emergency_card_data.dart';

enum WalletPassType { apple, google }

abstract class WalletPassRepository {
  Future<Uint8List> generateApplePass({
    required EmergencyCardData cardData,
    required String patientId,
  });

  Future<String> generateGooglePassJson({
    required EmergencyCardData cardData,
    required String patientId,
  });
}

import 'dart:async';
import 'dart:typed_data';

enum TransferStatus {
  idle,
  connecting,
  transferring,
  completed,
  batchCompleted,
  failed,
  cancelled,
}

enum PeerType {
  sender,
  receiver,
  android,
  ios,
  unknown,
}

class TransferProgress {
  final double progress;
  final int bytesTransferred;
  final int totalBytes;
  final TransferStatus status;
  final String? error;

  const TransferProgress({
    this.progress = 0.0,
    this.bytesTransferred = 0,
    this.totalBytes = 0,
    this.status = TransferStatus.idle,
    this.error,
  });
}

class ReceivedData {
  final String? id;
  final String? name;
  final String? fileName;
  final int? size;
  final Uint8List? bytes;
  final String? content;
  final dynamic data;
  final Map<String, dynamic>? metadata;

  const ReceivedData({
    this.id,
    this.name,
    this.fileName,
    this.size,
    this.bytes,
    this.content,
    this.data,
    this.metadata,
  });
}

class AirdropService {
  final _progressController = StreamController<TransferProgress>.broadcast();
  final _statusController = StreamController<TransferStatus>.broadcast();
  final _receivedController = StreamController<ReceivedData>.broadcast();
  final _peerDiscoveryController = StreamController<Map<String, dynamic>>.broadcast();
  final _invitationController = StreamController<Map<String, dynamic>>.broadcast();
  final _receivedFilesController = StreamController<List<String>>.broadcast();
  final _killSignalController = StreamController<dynamic>.broadcast();
  final _sessionEndedController = StreamController<dynamic>.broadcast();
  final _sessionExtendRequestController = StreamController<int>.broadcast();
  final _sessionExtendAcceptedController = StreamController<int>.broadcast();
  final _sessionExtendRejectedController = StreamController<dynamic>.broadcast();
  final _viewingStartedController = StreamController<dynamic>.broadcast();
  final _invitationRejectedController = StreamController<dynamic>.broadcast();
  final _wifiToggleNeededController = StreamController<dynamic>.broadcast();
  final _connectionHealthController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<TransferProgress> get progressStream => _progressController.stream;
  Stream<TransferStatus> get statusStream => _statusController.stream;
  Stream<ReceivedData> get receivedDataStream => _receivedController.stream;
  Stream<Map<String, dynamic>> get peerDiscoveryStream =>
      _peerDiscoveryController.stream;
  Stream<Map<String, dynamic>> get invitationStream =>
      _invitationController.stream;
  Stream<List<String>> get receivedFilesStream =>
      _receivedFilesController.stream;
  Stream<dynamic> get killSignalStream => _killSignalController.stream;
  Stream<dynamic> get sessionEndedStream => _sessionEndedController.stream;
  Stream<int> get sessionExtendRequestStream =>
      _sessionExtendRequestController.stream;
  Stream<int> get sessionExtendAcceptedStream =>
      _sessionExtendAcceptedController.stream;
  Stream<dynamic> get sessionExtendRejectedStream =>
      _sessionExtendRejectedController.stream;
  Stream<dynamic> get viewingStartedStream => _viewingStartedController.stream;
  Stream<dynamic> get invitationRejectedStream =>
      _invitationRejectedController.stream;
  Stream<dynamic> get wifiToggleNeededStream =>
      _wifiToggleNeededController.stream;
  Stream<Map<String, dynamic>> get connectionHealthStream =>
      _connectionHealthController.stream;

  Future<void> initialize({bool useBluetooth = false}) async {}

  Future<void> startAdvertising({
    String? deviceName,
    bool useBluetooth = false,
  }) async {}

  Future<void> stopAdvertising() async {}

  Future<void> startDiscovery({bool useBluetooth = false}) async {}

  Future<void> stopDiscovery() async {}

  Future<void> startSymmetricDiscovery({
    String? deviceName,
    bool useBluetooth = false,
  }) async {}

  Future<void> selectDevice({String? deviceId, dynamic peer}) async {}

  Future<void> addFiles({List<String>? filePaths, List<dynamic>? files}) async {}

  Future<void> receiveDataInMemory({
    dynamic peer,
    bool useBluetooth = false,
    bool enabled = true,
  }) async {}

  Future<void> acceptInvitation({
    String? invitationId,
    dynamic invitation,
  }) async {}

  Future<void> rejectInvitation({
    String? invitationId,
    dynamic invitation,
  }) async {}

  Future<void> disconnect() async {}

  Future<void> cancelTransfer() async {}

  Future<void> startReady({bool useBluetooth = false}) async {}

  Future<void> sendKillSignal() async {}

  Future<void> sendExtendRequest({int? durationSeconds}) async {}

  Future<void> sendExtendAccepted({int? durationSeconds}) async {}

  Future<void> sendExtendRejected() async {}

  Future<void> sendViewingStarted() async {}

  Future<void> sendData({
    required dynamic peer,
    Uint8List? bytes,
    String? content,
    String? fileName,
  }) async {
    throw UnsupportedError(
        'Airdrop proximity transfer is disabled in local build.');
  }

  Future<void> dispose() async {
    await _progressController.close();
    await _statusController.close();
    await _receivedController.close();
    await _peerDiscoveryController.close();
    await _invitationController.close();
    await _receivedFilesController.close();
    await _killSignalController.close();
    await _sessionEndedController.close();
    await _sessionExtendRequestController.close();
    await _sessionExtendAcceptedController.close();
    await _sessionExtendRejectedController.close();
    await _viewingStartedController.close();
    await _invitationRejectedController.close();
    await _wifiToggleNeededController.close();
    await _connectionHealthController.close();
  }
}

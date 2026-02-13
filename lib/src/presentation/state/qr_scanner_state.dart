import 'package:flutter/material.dart';
import '../../application/services/qr_scanner_service.dart';

/// Etats possibles du scanner QR.
enum ScannerStatus {
  idle,
  scanning,
  processing,
  success,
  alreadyPresent,
  error,
}

/// State management pour le scanner QR.
/// Gere le cycle de vie du scan : idle -> scanning -> processing -> success/error.
class QrScannerState extends ChangeNotifier {
  final QrScannerService _service;

  QrScannerState(this._service);

  ScannerStatus _status = ScannerStatus.idle;
  ScannerStatus get status => _status;

  ScanResult? _lastResult;
  ScanResult? get lastResult => _lastResult;

  String _seanceId = '';
  String get seanceId => _seanceId;

  bool _isRapidMode = false;
  bool get isRapidMode => _isRapidMode;

  int _scanCount = 0;
  int get scanCount => _scanCount;

  bool _isTorchOn = false;
  bool get isTorchOn => _isTorchOn;

  /// Definit la seance active pour l'enregistrement des presences.
  void setSeanceId(String id) {
    _seanceId = id;
    notifyListeners();
  }

  /// Active/desactive le mode entree rapide.
  void toggleRapidMode() {
    _isRapidMode = !_isRapidMode;
    notifyListeners();
  }

  /// Active/desactive la torche.
  void toggleTorch() {
    _isTorchOn = !_isTorchOn;
    notifyListeners();
  }

  /// Demarre le mode scanning.
  void startScanning() {
    _status = ScannerStatus.scanning;
    _lastResult = null;
    notifyListeners();
  }

  /// Traite un code QR scanne.
  Future<void> processQrCode(String qrCode) async {
    if (_status == ScannerStatus.processing) return;

    _status = ScannerStatus.processing;
    notifyListeners();

    try {
      if (_seanceId.isEmpty) {
        _lastResult = ScanResult.failure(
          'Aucune seance active. Veuillez ouvrir une seance.',
        );
        _status = ScannerStatus.error;
        notifyListeners();
        return;
      }

      final result = await _service.identifyQrCode(qrCode, _seanceId);
      _lastResult = result;

      if (!result.success) {
        _status = ScannerStatus.error;
        notifyListeners();
        return;
      }

      if (result.dejaPresent) {
        _status = ScannerStatus.alreadyPresent;
        notifyListeners();
        return;
      }

      // Enregistrement de la presence
      await _service.enregistrerPresence(
        typeProfil: result.typeProfil!,
        profilId: result.profilId!,
        seanceId: _seanceId,
      );

      _scanCount++;
      _status = ScannerStatus.success;
      notifyListeners();
    } catch (e) {
      _lastResult = ScanResult.failure('Erreur lors du traitement : $e');
      _status = ScannerStatus.error;
      notifyListeners();
    }
  }

  /// Reinitialise le scanner pour un nouveau scan.
  void resetForNextScan() {
    _status = ScannerStatus.scanning;
    _lastResult = null;
    notifyListeners();
  }

  /// Reinitialise completement le state.
  void reset() {
    _status = ScannerStatus.idle;
    _lastResult = null;
    _scanCount = 0;
    _isTorchOn = false;
    notifyListeners();
  }
}

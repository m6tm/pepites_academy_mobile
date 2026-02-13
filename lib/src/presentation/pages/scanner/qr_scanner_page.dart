import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../injection_container.dart';
import '../../state/qr_scanner_state.dart';
import '../../theme/app_colors.dart';
import 'widgets/scan_result_badge.dart';
import 'widgets/scanner_overlay.dart';

/// Page de scan QR plein ecran avec design Glassmorphism.
/// Permet de scanner les codes QR des academiciens et encadreurs
/// pour enregistrer leur presence a une seance.
class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with SingleTickerProviderStateMixin {
  late final QrScannerState _scannerState;
  late final MobileScannerController _cameraController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scannerState = QrScannerState(DependencyInjection.qrScannerService);

    // Seance par defaut pour le mode demo
    _scannerState.setSeanceId('seance_active');
    _scannerState.startScanning();

    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scannerState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scannerState.removeListener(_onStateChanged);
    _scannerState.dispose();
    _cameraController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera en arriere-plan
          _buildCameraPreview(),

          // Overlay avec viseur glassmorphism
          const ScannerOverlay(),

          // Barre superieure avec controles
          _buildTopBar(),

          // Indicateur de statut en bas
          _buildBottomPanel(),

          // Badge de resultat (affiche apres un scan)
          if (_scannerState.status == ScannerStatus.success ||
              _scannerState.status == ScannerStatus.alreadyPresent ||
              _scannerState.status == ScannerStatus.error)
            _buildResultOverlay(),
        ],
      ),
    );
  }

  /// Preview de la camera avec le scanner QR.
  Widget _buildCameraPreview() {
    return MobileScanner(
      controller: _cameraController,
      onDetect: _onBarcodeDetected,
    );
  }

  /// Gestion de la detection d'un code QR.
  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing) return;
    if (_scannerState.status != ScannerStatus.scanning) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    _isProcessing = true;
    _scannerState.processQrCode(barcode.rawValue!).then((_) {
      // En mode rapide, reinitialiser apres un delai
      if (_scannerState.isRapidMode &&
          _scannerState.status == ScannerStatus.success) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _isProcessing = false;
            _scannerState.resetForNextScan();
          }
        });
      } else {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _isProcessing = false;
          }
        });
      }
    });
  }

  /// Barre superieure avec titre, torche et mode rapide.
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    // Compteur de scans
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.people_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_scannerState.scanCount}',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Titre
                    Text(
                      'Scanner QR',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    // Bouton torche
                    _buildGlassIconButton(
                      icon: _scannerState.isTorchOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      isActive: _scannerState.isTorchOn,
                      onTap: () {
                        _scannerState.toggleTorch();
                        _cameraController.toggleTorch();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Panneau inferieur avec mode rapide et instructions.
  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Instructions animees
              if (_scannerState.status == ScannerStatus.scanning)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Text(
                    'Placez le code QR dans le viseur',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // Bouton mode rapide
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.speed_rounded,
                          color: _scannerState.isRapidMode
                              ? AppColors.primary
                              : Colors.white70,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Entree Rapide',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Enchainer les scans automatiquement',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _scannerState.isRapidMode,
                          onChanged: (_) => _scannerState.toggleRapidMode(),
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Overlay affichant le resultat du scan.
  Widget _buildResultOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          _isProcessing = false;
          _scannerState.resetForNextScan();
        },
        child: Container(
          color: Colors.black.withValues(alpha: 0.6),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ScanResultBadge(
                result: _scannerState.lastResult,
                status: _scannerState.status,
                onDismiss: () {
                  _isProcessing = false;
                  _scannerState.resetForNextScan();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Bouton icone avec effet glassmorphism.
  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white70,
          size: 20,
        ),
      ),
    );
  }
}

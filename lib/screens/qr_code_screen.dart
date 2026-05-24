import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().student;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ─── Student Card ──────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(80),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ]
              ),
              child: Column(
                children: [
                  Text(
                    student?.fullName ?? 'Student',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${student?.studentId ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  if (student?.group != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Group: ${student?.group ?? ''} • ${student?.year ?? ''}',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fade(duration: 400.ms).slideY(begin: -0.1, curve: Curves.easeOutQuad),
            const SizedBox(height: 32),
            // ─── QR Code ──────────────────────────────────
            () {
              final qrCode = student?.qrCode;
              if (qrCode != null && qrCode.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary.withAlpha(50), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(40),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: qrCode,
                          size: 220,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Show this code to mark attendance',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        qrCode,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondary.withAlpha(150),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).fade(duration: 500.ms).scaleXY(begin: 0.9, curve: Curves.easeOutBack);
              } else {
                return Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: 80,
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'QR Code not available',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }
            }(),
          ],
        ),
      ),
    );
  }
}

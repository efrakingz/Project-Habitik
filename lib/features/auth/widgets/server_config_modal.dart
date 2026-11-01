import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/socket_service.dart';
import 'package:habitik/core/services/server_discovery_service.dart';
import 'package:habitik/shared/widgets/feedback/feedback.dart';

class ServerConfigModal extends StatefulWidget {
  const ServerConfigModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ServerConfigModal(),
    );
  }

  @override
  State<ServerConfigModal> createState() => _ServerConfigModalState();
}

class _ServerConfigModalState extends State<ServerConfigModal> {
  late bool _isRailway;
  late final TextEditingController _localUrlCtrl;
  bool _testingConnection = false;
  bool _discoveringServer = false;
  String? _testStatusMessage;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    final current = ApiClient.baseUrl;
    _isRailway = current.contains('railway.app');

    if (!_isRailway) {
      _localUrlCtrl = TextEditingController(text: current);
    } else {
      _localUrlCtrl = TextEditingController(text: 'http://192.168.1.10:3000');
    }
  }

  @override
  void dispose() {
    _localUrlCtrl.dispose();
    super.dispose();
  }

  String get _targetUrl {
    if (_isRailway) {
      return ApiClient.productionBaseUrl;
    }
    String text = _localUrlCtrl.text.trim();
    if (!text.startsWith('http://') && !text.startsWith('https://')) {
      text = 'http://$text';
    }
    final withoutSlash = text.replaceAll(RegExp(r'/+$'), '');
    return withoutSlash;
  }

  Future<void> _autoDiscoverServer() async {
    setState(() {
      _discoveringServer = true;
      _testStatusMessage = null;
      _testSuccess = null;
    });

    try {
      final discoveredUrl = await ServerDiscoveryService().discoverServer();
      if (!mounted) return;

      if (discoveredUrl != null && discoveredUrl.isNotEmpty) {
        setState(() {
          _isRailway = false;
          _localUrlCtrl.text = discoveredUrl;
        });

        // Probar conexión automáticamente para medir latencia
        await _testConnection();

        if (!mounted) return;
        HabitikFeedback.showSuccess(
          context,
          '¡Servidor local detectado en $discoveredUrl!',
        );
      } else {
        setState(() {
          _testSuccess = false;
          _testStatusMessage =
              '🔍 No se encontró el servidor automáticamente en la red Wi-Fi.\n'
              'Verifica que la notebook esté encendida con el Panel de Control e ingresa la IP manualmente.';
        });
        HabitikFeedback.showError(
          context,
          'No se localizó el servidor. Ingresa la IP manualmente.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testSuccess = false;
        _testStatusMessage = 'Error al escanear la red: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _discoveringServer = false);
      }
    }
  }

  void _openQrScanner() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (sheetCtx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(sheetCtx).size.height * 0.75,
          child: Column(
            children: [
              AppBar(
                title: Text(
                  'Escanear QR del Panel Web',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(sheetCtx).pop(),
                ),
              ),
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      final raw = barcode.rawValue?.trim();
                      if (raw != null && raw.isNotEmpty && raw.startsWith('http')) {
                        Navigator.of(sheetCtx).pop();
                        setState(() {
                          _isRailway = false;
                          _localUrlCtrl.text = raw;
                        });
                        _testConnection();
                        HabitikFeedback.showSuccess(
                          context,
                          'Código QR reconocido: $raw',
                        );
                        break;
                      }
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Apunta al código QR en el Panel de Control de tu notebook',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _testingConnection = true;
      _testStatusMessage = null;
      _testSuccess = null;
    });

    final target = _targetUrl;
    final sw = Stopwatch()..start();
    try {
      final res = await http.get(Uri.parse('$target/')).timeout(const Duration(seconds: 4));
      sw.stop();
      if (!mounted) return;
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(res.body);
        final appName = body['app'] ?? 'Habitik Backend';
        setState(() {
          _testSuccess = true;
          _testStatusMessage = '✅ Conexión exitosa con $appName (${sw.elapsedMilliseconds} ms)';
        });
      } else {
        setState(() {
          _testSuccess = false;
          _testStatusMessage = '⚠️ El servidor respondió con error (${res.statusCode}).';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testSuccess = false;
        _testStatusMessage =
            '❌ No se pudo conectar a $target.\nVerifica que la notebook y este dispositivo estén en la misma red Wi-Fi.';
      });
    } finally {
      if (mounted) {
        setState(() => _testingConnection = false);
      }
    }
  }

  Future<void> _saveAndApply() async {
    final finalUrl = _targetUrl;
    await ApiClient.saveCustomBaseUrl(finalUrl);
    SocketService.disconnect();

    if (!mounted) return;
    HabitikFeedback.showSuccess(
      context,
      _isRailway
          ? 'Conectado a la nube (Railway)'
          : 'Conectado al servidor local ($finalUrl)',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF132218) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: HabitikColors.green500.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.dns_rounded,
                    color: HabitikColors.green500,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Servidor de Conexión',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : HabitikColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Selecciona dónde está corriendo el backend',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              title: '☁️ Nube (Railway)',
              subtitle: 'Servidor oficial online',
              isSelected: _isRailway,
              onTap: () {
                setState(() {
                  _isRailway = true;
                  _testStatusMessage = null;
                });
              },
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              title: '💻 Servidor Local (Wi-Fi / Notebook)',
              subtitle: 'Modo contingencia feria sin internet',
              isSelected: !_isRailway,
              onTap: () {
                setState(() {
                  _isRailway = false;
                  _testStatusMessage = null;
                });
              },
              isDark: isDark,
            ),
            if (!_isRailway) ...[
              const SizedBox(height: 16),
              // Botones de acción rápida: Auto-detectar y Escanear QR
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (_discoveringServer || _testingConnection)
                          ? null
                          : _autoDiscoverServer,
                      icon: _discoveringServer
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.radar_rounded, size: 18),
                      label: Text(
                        _discoveringServer ? 'Buscando...' : 'Auto-Detectar en Wi-Fi',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HabitikColors.green600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  if (isMobile) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _openQrScanner,
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                      label: Text(
                        'Escanear QR',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Dirección IP del Servidor Local (Notebook):',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? HabitikColors.green300 : HabitikColors.green700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _localUrlCtrl,
                keyboardType: TextInputType.url,
                style: GoogleFonts.firaCode(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'http://192.168.1.10:3000',
                  hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
                  prefixIcon: const Icon(Icons.wifi_tethering, size: 20),
                  filled: true,
                  fillColor: isDark ? Colors.black26 : const Color(0xFFF1F5F9),
                  helperText: 'Consulta la IP que muestra el Panel de Control Web en tu notebook.',
                  helperStyle: GoogleFonts.outfit(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white24 : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: HabitikColors.green500, width: 2),
                  ),
                ),
              ),
            ],
            if (_testStatusMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _testSuccess == true
                      ? HabitikColors.green500.withValues(alpha: 0.15)
                      : Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _testSuccess == true ? HabitikColors.green500 : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  _testStatusMessage!,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _testSuccess == true ? HabitikColors.green400 : Colors.redAccent,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _testingConnection ? null : _testConnection,
                    icon: _testingConnection
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bolt_rounded, size: 18),
                    label: Text(
                      _testingConnection ? 'Probando...' : 'Probar Conexión',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark ? Colors.white38 : Colors.grey[400]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAndApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HabitikColors.green500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Guardar y Usar',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? HabitikColors.green500.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? HabitikColors.green500
                : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? HabitikColors.green500 : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? HabitikColors.green500 : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

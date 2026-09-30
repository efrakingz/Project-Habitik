import 'package:flutter/material.dart';
import 'package:habitik/core/services/session_service.dart';

class ExtraLifeDialog extends StatelessWidget {
  final VoidCallback onBuyLife;
  final VoidCallback onFinish;

  const ExtraLifeDialog({
    super.key,
    required this.onBuyLife,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final userCoins = SessionService().currentUser?.monedas ?? 0;
    final hasEnoughCoins = userCoins >= 5;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFEBEE),
                border: Border.all(color: const Color(0xFFFFCDD2), width: 2),
              ),
              alignment: Alignment.center,
              child: const Text('💔', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),

            const Text(
              '¡Te has quedado sin vidas!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFFB71C1C),
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              '¿Deseas comprar 1 vida extra para continuar tu racha y acumular más XP?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF555555),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // Saldo actual y precio
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Costo de 1 vida: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF795548),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: const [
                        Text('🪙', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 4),
                        Text(
                          '5 monedas',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Tu saldo actual: $userCoins monedas',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: hasEnoughCoins
                    ? const Color(0xFF388E3C)
                    : const Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(height: 20),

            // Botón comprar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: hasEnoughCoins ? onBuyLife : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE040FB),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.favorite_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'COMPRAR 1 VIDA (5 🪙)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Botón terminar partida
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: onFinish,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF757575),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'TERMINAR PARTIDA',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

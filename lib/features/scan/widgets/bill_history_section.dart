import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/data/models/bill_record.dart';

/// Sección de historial y auditoría de boletas registradas (HU 3.2, Criterio 4).
/// Muestra los registros históricos vinculados a sus respaldos documentales (PDF/Imagen) o ingreso manual.
class BillHistorySection extends StatelessWidget {
  final List<BillRecord> bills;

  const BillHistorySection({
    super.key,
    required this.bills,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        isDarkModeNotifier.value;
    final currencyFormatter = NumberFormat.currency(
      locale: 'es_CL',
      symbol: r'$',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de la sección
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Historial de Auditoría',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : HabitikColors.green900,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? HabitikColors.green500.withValues(alpha: 0.15)
                        : HabitikColors.green100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${bills.length}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? HabitikColors.green400 : HabitikColors.green800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (bills.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? HabitikColors.darkCardBg : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white12 : HabitikColors.divider,
              ),
            ),
            child: Column(
              children: [
                const Text('📋', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 10),
                Text(
                  'Aún no hay boletas auditadas',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : HabitikColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Captura una boleta o ingresa tus datos manualmente para mantener íntegro el historial de consumo de tu hogar.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    color: isDark ? Colors.white54 : HabitikColors.textLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bills.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final bill = bills[index];
              final isLuz = bill.isElectricidad;
              final serviceColor = isLuz ? HabitikColors.amber500 : HabitikColors.blue500;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? HabitikColors.darkCardBg : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : HabitikColors.divider,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.15)
                          : HabitikColors.green900.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila Superior: Servicio + Proveedor + Monto
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: serviceColor.withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isLuz ? '⚡' : '💧',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bill.proveedor,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : HabitikColors.textDark,
                                ),
                              ),
                              Text(
                                '${bill.tipoServicio} • ${dateFormat.format(bill.periodoDesde)} al ${dateFormat.format(bill.periodoHasta)}',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : HabitikColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormatter.format(bill.monto),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : HabitikColors.green900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // Fila Inferior: Consumo + Fuente + Respaldo Documental
                    Row(
                      children: [
                        // Consumo
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? HabitikColors.darkInputFill
                                : HabitikColors.green50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '📊 ${bill.consumo} ${bill.unidad}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? HabitikColors.green400 : HabitikColors.green800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Etiqueta de fuente (OCR o Manual)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bill.entrySource == 'ocr_confirmed'
                                ? '🔍 OCR Confirmado'
                                : '✍️ Manual',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                            ),
                          ),
                        ),
                        const Spacer(),

                        // Respaldo Documental Vinculado (Criterio 4)
                        if (bill.hasDocumentBackup && bill.documentName != null)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (bill.documentType == 'pdf'
                                        ? Colors.redAccent
                                        : HabitikColors.blue500)
                                    .withValues(alpha: isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    bill.documentType == 'pdf'
                                        ? Icons.picture_as_pdf_rounded
                                        : Icons.image_rounded,
                                    size: 13,
                                    color: bill.documentType == 'pdf'
                                        ? Colors.redAccent
                                        : HabitikColors.blue500,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      bill.documentName!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white70 : HabitikColors.textMid,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Text(
                            'Sin doc. adjunto',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: isDark ? Colors.white38 : HabitikColors.textHint,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

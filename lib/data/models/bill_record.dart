/// Modelo inmutable para el registro histórico y auditoría de boletas de servicios
/// (HU 3.2: Carga Manual y Respaldo Documental).
class BillRecord {
  final String id;
  final String tipoServicio; // 'Electricidad' | 'Agua'
  final String proveedor;
  final DateTime periodoDesde;
  final DateTime periodoHasta;
  final double consumo;
  final String unidad; // 'kWh' | 'm³'
  final int monto; // en CLP
  final DateTime fechaVencimiento;
  final String entrySource; // 'ocr_confirmed' | 'manual'
  final bool hasDocumentBackup;
  final String? documentName;
  final String? documentType; // 'pdf' | 'imagen'
  final int? documentSizeBytes;
  final DateTime createdAt;

  const BillRecord({
    required this.id,
    required this.tipoServicio,
    required this.proveedor,
    required this.periodoDesde,
    required this.periodoHasta,
    required this.consumo,
    required this.unidad,
    required this.monto,
    required this.fechaVencimiento,
    required this.entrySource,
    this.hasDocumentBackup = false,
    this.documentName,
    this.documentType,
    this.documentSizeBytes,
    required this.createdAt,
  });

  /// Instancia vacía por defecto para evitar nulls
  static final BillRecord empty = BillRecord(
    id: '',
    tipoServicio: 'Electricidad',
    proveedor: '',
    periodoDesde: DateTime.fromMillisecondsSinceEpoch(0),
    periodoHasta: DateTime.fromMillisecondsSinceEpoch(0),
    consumo: 0.0,
    unidad: 'kWh',
    monto: 0,
    fechaVencimiento: DateTime.fromMillisecondsSinceEpoch(0),
    entrySource: 'manual',
    hasDocumentBackup: false,
    documentName: null,
    documentType: null,
    documentSizeBytes: null,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Retorna si el servicio es electricidad
  bool get isElectricidad => tipoServicio.toLowerCase() == 'electricidad';

  /// Retorna si el servicio es agua
  bool get isAgua => tipoServicio.toLowerCase() == 'agua';

  BillRecord copyWith({
    String? id,
    String? tipoServicio,
    String? proveedor,
    DateTime? periodoDesde,
    DateTime? periodoHasta,
    double? consumo,
    String? unidad,
    int? monto,
    DateTime? fechaVencimiento,
    String? entrySource,
    bool? hasDocumentBackup,
    String? documentName,
    String? documentType,
    int? documentSizeBytes,
    DateTime? createdAt,
  }) {
    return BillRecord(
      id: id ?? this.id,
      tipoServicio: tipoServicio ?? this.tipoServicio,
      proveedor: proveedor ?? this.proveedor,
      periodoDesde: periodoDesde ?? this.periodoDesde,
      periodoHasta: periodoHasta ?? this.periodoHasta,
      consumo: consumo ?? this.consumo,
      unidad: unidad ?? this.unidad,
      monto: monto ?? this.monto,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      entrySource: entrySource ?? this.entrySource,
      hasDocumentBackup: hasDocumentBackup ?? this.hasDocumentBackup,
      documentName: documentName ?? this.documentName,
      documentType: documentType ?? this.documentType,
      documentSizeBytes: documentSizeBytes ?? this.documentSizeBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Deserialización defensiva tolerante a snake_case y variaciones de backend
  factory BillRecord.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    final tipoServicioRaw =
        json['service_type'] ?? json['tipo_servicio'] ?? 'Electricidad';
    final tipoServicioNormalizado =
        tipoServicioRaw.toString().toLowerCase().contains('agua')
            ? 'Agua'
            : 'Electricidad';

    final unidadRaw = json['unit'] ?? json['unidad'];
    final unidadNormalizada = unidadRaw != null && unidadRaw.toString().isNotEmpty
        ? unidadRaw.toString()
        : (tipoServicioNormalizado == 'Agua' ? 'm³' : 'kWh');

    return BillRecord(
      id: json['id']?.toString() ?? '',
      tipoServicio: tipoServicioNormalizado,
      proveedor: json['provider']?.toString() ?? json['proveedor']?.toString() ?? '',
      periodoDesde: parseDate(json['period_from'] ?? json['periodo_desde']),
      periodoHasta: parseDate(json['period_to'] ?? json['periodo_hasta']),
      consumo: parseDouble(json['consumption'] ?? json['consumo']),
      unidad: unidadNormalizada,
      monto: parseInt(json['amount'] ?? json['monto']),
      fechaVencimiento: parseDate(json['due_date'] ?? json['fecha_vencimiento']),
      entrySource: json['entry_source']?.toString() ??
          json['fuente_ingreso']?.toString() ??
          'manual',
      hasDocumentBackup: json['has_document_backup'] == true ||
          json['tiene_respaldo'] == true ||
          (json['document_name'] != null &&
              json['document_name'].toString().isNotEmpty),
      documentName: json['document_name']?.toString() ?? json['nombre_archivo']?.toString(),
      documentType: json['document_type']?.toString() ?? json['tipo_archivo']?.toString(),
      documentSizeBytes: json['document_size_bytes'] != null
          ? parseInt(json['document_size_bytes'])
          : null,
      createdAt: parseDate(json['created_at'] ?? json['fecha_registro']),
    );
  }

  /// Serialización estructurada para el endpoint POST /bills y caché local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_type': tipoServicio.toLowerCase(),
      'tipo_servicio': tipoServicio,
      'provider': proveedor,
      'proveedor': proveedor,
      'period_from': periodoDesde.toIso8601String().split('T').first,
      'periodo_desde': periodoDesde.toIso8601String().split('T').first,
      'period_to': periodoHasta.toIso8601String().split('T').first,
      'periodo_hasta': periodoHasta.toIso8601String().split('T').first,
      'consumption': consumo,
      'consumo': consumo,
      'unit': unidad,
      'unidad': unidad,
      'amount': monto,
      'monto': monto,
      'due_date': fechaVencimiento.toIso8601String().split('T').first,
      'fecha_vencimiento': fechaVencimiento.toIso8601String().split('T').first,
      'entry_source': entrySource,
      'has_document_backup': hasDocumentBackup,
      if (documentName != null) 'document_name': documentName,
      if (documentType != null) 'document_type': documentType,
      if (documentSizeBytes != null) 'document_size_bytes': documentSizeBytes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'BillRecord(id: $id, tipo: $tipoServicio, proveedor: $proveedor, consumo: $consumo $unidad, monto: \$$monto, fuente: $entrySource, doc: $documentName)';
  }
}

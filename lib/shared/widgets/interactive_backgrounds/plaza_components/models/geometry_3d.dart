import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Vertex3D {
  final double x;
  final double y;
  final double z;
  const Vertex3D(this.x, this.y, this.z);

  Vertex3D normalized() {
    final len = math.sqrt(x * x + y * y + z * z);
    if (len == 0) return const Vertex3D(0, 0, 0);
    return Vertex3D(x / len, y / len, z / len);
  }

  Vertex3D rotateX(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Vertex3D(x, y * cosA - z * sinA, y * sinA + z * cosA);
  }

  Vertex3D rotateY(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Vertex3D(x * cosA + z * sinA, y, -x * sinA + z * cosA);
  }
}

class Face3D {
  final int a;
  final int b;
  final int c;
  const Face3D(this.a, this.b, this.c);
}

class GeodesicSphere {
  final List<Vertex3D> vertices;
  final List<Face3D> faces;

  GeodesicSphere(this.vertices, this.faces);

  static GeodesicSphere createIcosahedron() {
    final t = (1.0 + math.sqrt(5.0)) / 2.0;
    final verts = [
      Vertex3D(-1, t, 0),
      Vertex3D(1, t, 0),
      Vertex3D(-1, -t, 0),
      Vertex3D(1, -t, 0),
      Vertex3D(0, -1, t),
      Vertex3D(0, 1, t),
      Vertex3D(0, -1, -t),
      Vertex3D(0, 1, -t),
      Vertex3D(t, 0, -1),
      Vertex3D(t, 0, 1),
      Vertex3D(-t, 0, -1),
      Vertex3D(-t, 0, 1),
    ].map((v) => v.normalized()).toList();

    const faces = [
      Face3D(0, 11, 5),
      Face3D(0, 5, 1),
      Face3D(0, 1, 7),
      Face3D(0, 7, 10),
      Face3D(0, 10, 11),
      Face3D(1, 5, 9),
      Face3D(5, 11, 4),
      Face3D(11, 10, 2),
      Face3D(10, 7, 6),
      Face3D(7, 1, 8),
      Face3D(3, 9, 4),
      Face3D(3, 4, 2),
      Face3D(3, 2, 6),
      Face3D(3, 6, 8),
      Face3D(3, 8, 9),
      Face3D(4, 9, 5),
      Face3D(2, 4, 11),
      Face3D(6, 2, 10),
      Face3D(8, 6, 7),
      Face3D(9, 8, 1),
    ];
    return GeodesicSphere(verts, faces);
  }

  GeodesicSphere subdivide() {
    final newVertices = List<Vertex3D>.from(vertices);
    final newFaces = <Face3D>[];
    final midpointCache = <String, int>{};

    int getMidpoint(int p1, int p2) {
      final key = p1 < p2 ? '${p1}_$p2' : '${p2}_$p1';
      if (midpointCache.containsKey(key)) {
        return midpointCache[key]!;
      }
      final v1 = newVertices[p1];
      final v2 = newVertices[p2];
      final mid = Vertex3D(
        (v1.x + v2.x) / 2,
        (v1.y + v2.y) / 2,
        (v1.z + v2.z) / 2,
      ).normalized();
      newVertices.add(mid);
      final index = newVertices.length - 1;
      midpointCache[key] = index;
      return index;
    }

    for (final face in faces) {
      final a = face.a;
      final b = face.b;
      final c = face.c;

      final ab = getMidpoint(a, b);
      final bc = getMidpoint(b, c);
      final ca = getMidpoint(c, a);

      newFaces.add(Face3D(a, ab, ca));
      newFaces.add(Face3D(b, bc, ab));
      newFaces.add(Face3D(c, ca, bc));
      newFaces.add(Face3D(ab, bc, ca));
    }

    return GeodesicSphere(newVertices, newFaces);
  }

  // Pre-rotate all vertices. Done once per component instance for optimized rendering.
  List<Vertex3D> getRotatedVertices(double pitch, double yaw) {
    final cosP = math.cos(pitch);
    final sinP = math.sin(pitch);
    final cosY = math.cos(yaw);
    final sinY = math.sin(yaw);

    return vertices.map((v) {
      // rotateX (pitch)
      final y2 = v.y * cosP - v.z * sinP;
      final z2 = v.y * sinP + v.z * cosP;
      // rotateY (yaw)
      final rx = v.x * cosY + z2 * sinY;
      final ry = y2;
      final rz = -v.x * sinY + z2 * cosY;
      return Vertex3D(rx, ry, rz);
    }).toList();
  }

  // Render method utilizing pre-rotated vertices. Thread-safe with no shared mutable instance lists.
  void renderGeodesicSphere(
    Canvas canvas,
    Offset center,
    double radius,
    List<Vertex3D> rotatedVertices,
    TreePalette palette,
    Paint borderPaint,
  ) {
    final lightDir = const Vertex3D(-1.0, -1.0, 1.2).normalized();

    final List<Offset> positionsBuffer = [];
    final List<Color> colorsBuffer = [];
    final List<Offset> borderBuffer = [];

    for (final face in faces) {
      final p1 = rotatedVertices[face.a];
      final p2 = rotatedVertices[face.b];
      final p3 = rotatedVertices[face.c];

      final ux = p2.x - p1.x;
      final uy = p2.y - p1.y;
      final uz = p2.z - p1.z;
      final vx = p3.x - p1.x;
      final vy = p3.y - p1.y;
      final vz = p3.z - p1.z;
      final nx = uy * vz - uz * vy;
      final ny = uz * vx - ux * vz;
      final nz = ux * vy - uy * vx;

      final len = math.sqrt(nx * nx + ny * ny + nz * nz);
      if (len == 0) continue;

      var normalX = nx / len;
      var normalY = ny / len;
      var normalZ = nz / len;

      final centerX = (p1.x + p2.x + p3.x) / 3.0;
      final centerY = (p1.y + p2.y + p3.y) / 3.0;
      final centerZ = (p1.z + p2.z + p3.z) / 3.0;
      final dotOutward =
          normalX * centerX + normalY * centerY + normalZ * centerZ;
      if (dotOutward < 0) {
        normalX = -normalX;
        normalY = -normalY;
        normalZ = -normalZ;
      }

      if (normalZ <= 0.0) continue;

      final dot =
          normalX * lightDir.x + normalY * lightDir.y + normalZ * lightDir.z;
      final intensity = (dot + 1.0) / 2.0;

      Color faceColor;
      if (intensity < 0.5) {
        faceColor = Color.lerp(
          palette.shadowColor,
          palette.midColor,
          intensity * 2.0,
        )!;
      } else {
        faceColor = Color.lerp(
          palette.midColor,
          palette.brightColor,
          (intensity - 0.5) * 2.0,
        )!;
      }

      final screenPt1 = Offset(
        center.dx + p1.x * radius,
        center.dy + p1.y * radius,
      );
      final screenPt2 = Offset(
        center.dx + p2.x * radius,
        center.dy + p2.y * radius,
      );
      final screenPt3 = Offset(
        center.dx + p3.x * radius,
        center.dy + p3.y * radius,
      );

      positionsBuffer.addAll([screenPt1, screenPt2, screenPt3]);
      colorsBuffer.addAll([faceColor, faceColor, faceColor]);

      if (borderPaint.color.a > 0) {
        borderBuffer.addAll([
          screenPt1,
          screenPt2,
          screenPt2,
          screenPt3,
          screenPt3,
          screenPt1,
        ]);
      }
    }

    if (positionsBuffer.isNotEmpty) {
      final verticesObj = ui.Vertices(
        ui.VertexMode.triangles,
        positionsBuffer,
        colors: colorsBuffer,
      );
      canvas.drawVertices(verticesObj, BlendMode.srcOver, Paint());
    }

    if (borderPaint.color.a > 0 && borderBuffer.isNotEmpty) {
      canvas.drawPoints(ui.PointMode.lines, borderBuffer, borderPaint);
    }
  }
}

enum TreeType { lime, grass, forest }

class TreePalette {
  final Color shadowColor;
  final Color midColor;
  final Color brightColor;

  const TreePalette({
    required this.shadowColor,
    required this.midColor,
    required this.brightColor,
  });

  static const lime = TreePalette(
    shadowColor: Color(0xFF33691E),
    midColor: Color(0xFF68B733),
    brightColor: Color(0xFFDCF690),
  );

  static const grass = TreePalette(
    shadowColor: Color(0xFF1B5E20),
    midColor: Color(0xFF4CAF50),
    brightColor: Color(0xFFA3E552),
  );

  static const forest = TreePalette(
    shadowColor: Color(0xFF0F3D0E),
    midColor: Color(0xFF1B5E20),
    brightColor: Color(0xFF7CB342),
  );

  static const limeNight = TreePalette(
    shadowColor: Color(0xFF06150E),
    midColor: Color(0xFF0A2E1C),
    brightColor: Color(0xFF388E65),
  );

  static const grassNight = TreePalette(
    shadowColor: Color(0xFF04100B),
    midColor: Color(0xFF072416),
    brightColor: Color(0xFF2E7B54),
  );

  static const forestNight = TreePalette(
    shadowColor: Color(0xFF020B07),
    midColor: Color(0xFF051B10),
    brightColor: Color(0xFF225F40),
  );
}

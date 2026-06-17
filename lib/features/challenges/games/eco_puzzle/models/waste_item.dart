import 'package:flutter/material.dart';

class WasteItem {
  final String id;
  final String binType;
  final String name;

  const WasteItem({required this.id, required this.binType, required this.name});
}

class BinData {
  final String type;
  final String name;
  final Color color;
  final IconData icon;

  const BinData({required this.type, required this.name, required this.color, required this.icon});
}

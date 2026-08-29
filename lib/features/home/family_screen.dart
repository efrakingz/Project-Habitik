import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
import 'package:habitik/shared/widgets/avatar/avatar.dart';
import 'package:habitik/shared/widgets/cards/cards.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  List<FamilyMember> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    final user = SessionService().currentUser;
    if (user == null || user.familyId == null || user.familyId!.isEmpty) {
      if (mounted) {
        setState(() {
          _members = FamilyMember.mockList;
          _loading = false;
        });
      }
      return;
    }

    try {
      final response = await ApiClient().get('/familia/miembros');
      if (!mounted) return;

      final List<dynamic> data = jsonDecode(response.body);
      final list = data.map((j) => FamilyMember.fromJson(j)).toList();

      setState(() {
        _members = list;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _members = FamilyMember.mockList;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = SessionService().currentUser;
    final familyName = user?.familyName ?? 'Hogar Familiar';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: HabitikColors.heroGreen),
        child: SafeArea(
          bottom: false,
          child: ScreenShell(
            titulo: 'Muro del Hogar',
            subtitulo: '🏡 $familyName',
            showBackButton: true,
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                children: [
                  const HeroBannerCard(
                    emoji: '👥',
                    title: 'Integrantes del Hogar',
                    description: 'Puntos de experiencia y ahorro ecológico acumulados.',
                  ),

                  const SizedBox(height: 16),

                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _members.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final m = _members[i];
                        final isFirst = i == 0;
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2E22) : Colors.white,
                            borderRadius: HabitikRadius.md_,
                            border: Border.all(
                              color: isFirst
                                  ? HabitikColors.amber400
                                  : (isDark ? const Color(0x20FFFFFF) : Colors.grey.shade200),
                              width: isFirst ? 2 : 1,
                            ),
                            boxShadow: HabitikShadows.card,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${i + 1}º',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: isFirst ? HabitikColors.amber400 : (isDark ? Colors.white70 : HabitikColors.textLight),
                                ),
                              ),
                              const SizedBox(width: 12),
                              UserAvatar(
                                letra: m.avatarLetra,
                                colorHex: m.avatarColor,
                                radius: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          m.nombre,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            color: isDark ? Colors.white : HabitikColors.textDark,
                                          ),
                                        ),
                                        if (m.rol == 'jefe' || m.rol == 'admin') ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: HabitikColors.amber400,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'JEFE',
                                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Nivel ${m.nivel}',
                                      style: TextStyle(
                                        color: isDark ? HabitikColors.green200 : HabitikColors.textLight,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: HabitikColors.green50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '⚡ ${m.xp} XP',
                                  style: const TextStyle(
                                    color: HabitikColors.green700,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/core/services/api_client.dart';
import 'package:habitik/core/services/session_service.dart';
import 'package:habitik/data/models/family_member.dart';
import 'package:habitik/shared/widgets/layout/layout.dart';
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
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final path = (user.familyId != null && user.familyId!.isNotEmpty)
          ? '/familia/miembros?family_id=${user.familyId}'
          : '/familia/miembros';

      final response = await ApiClient().get(path);
      if (!mounted) return;

      final dynamic data = jsonDecode(response.body);
      if (data is List) {
        final list = data
            .map((j) => FamilyMember.fromJson(j as Map<String, dynamic>))
            .toList();

        setState(() {
          _members = list;
          _loading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('⚠️ Error cargando miembros de la familia: $e');
    }

    if (mounted) {
      setState(() {
        _members = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionService().currentUser;
    final familyName = user?.familyName ?? 'Hogar Familiar';

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ScreenShell(
            titulo: 'Muro del Hogar',
            subtitulo: '🏡 $familyName',
            showBackButton: true,
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                children: [
                  HeroBannerCard(
                    emoji: '🏡',
                    subtitle: 'Hogar',
                    title: familyName,
                    compact: true,
                    trailing: _members.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? HabitikColors.green900.withValues(alpha: 0.45)
                                  : HabitikColors.green100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_members.length} miembros',
                              style: TextStyle(
                                color: isDark ? HabitikColors.green200 : HabitikColors.green800,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: HabitikColors.green500),
                    )
                  else if (_members.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2E22) : Colors.white,
                        borderRadius: HabitikRadius.lg_,
                        border: Border.all(
                          color: isDark ? const Color(0x30FFFFFF) : Colors.grey.shade200,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text('👥', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(
                            'No hay miembros registrados aún',
                            style: TextStyle(
                              color: isDark ? Colors.white : HabitikColors.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Invita a tu familia desde tu perfil para ver su progreso aquí.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: HabitikColors.textLight, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Builder(
                      builder: (context) {
                        final maxXP = _members.fold<int>(
                          1,
                          (prev, elem) => elem.xp > prev ? elem.xp : prev,
                        );
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _members.length,
                          itemBuilder: (context, i) {
                            return RankingCard(
                              position: i + 1,
                              member: _members[i],
                              maxXp: maxXP,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

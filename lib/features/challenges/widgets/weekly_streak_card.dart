import 'package:flutter/material.dart';
import 'package:habitik/core/theme/theme.dart';
import 'package:habitik/shared/widgets/icons/game_icons.dart';

const _kAnimFast = Duration(milliseconds: 200);

class WeeklyStreakCard extends StatelessWidget {
  final List<bool> days;
  const WeeklyStreakCard({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: HabitikColors.fireStreak,
        borderRadius: HabitikRadius.lg_,
        border: Border.all(color: Colors.white, width: 3.0),
        boxShadow: HabitikShadows.colored(HabitikColors.orange400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              GameFireIcon(size: 16),
              SizedBox(width: 6),
              Text(
                'Racha Semanal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.asMap().entries.map((e) {
              final done = e.value;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: _kAnimFast,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: done ? Colors.white : Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      labels[e.key],
                      style: TextStyle(
                        color: done ? HabitikColors.orange400 : Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[e.key],
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

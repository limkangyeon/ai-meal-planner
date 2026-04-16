import 'package:flutter/material.dart';

import '../models/meal_plan.dart';
import '../utils/app_theme.dart';

/// 영양 정보 요약 카드
class NutritionSummaryCard extends StatelessWidget {
  final NutritionInfo nutrition;

  const NutritionSummaryCard({
    super.key,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 총 칼로리
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppTheme.secondaryOrange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                '${nutrition.calories}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'kcal',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 영양소 바
          _buildNutritionBar(),

          const SizedBox(height: 16),

          // 영양소 상세
          Row(
            children: [
              Expanded(
                child: _buildNutrientDetail(
                  '탄수화물',
                  '${nutrition.carbohydrates.toInt()}g',
                  Colors.blue.shade400,
                  Icons.grain,
                ),
              ),
              Expanded(
                child: _buildNutrientDetail(
                  '단백질',
                  '${nutrition.protein.toInt()}g',
                  Colors.red.shade400,
                  Icons.egg,
                ),
              ),
              Expanded(
                child: _buildNutrientDetail(
                  '지방',
                  '${nutrition.fat.toInt()}g',
                  Colors.amber.shade400,
                  Icons.water_drop,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionBar() {
    final total = nutrition.carbohydrates + nutrition.protein + nutrition.fat;
    
    if (total == 0) {
      return const SizedBox.shrink();
    }

    final carbRatio = nutrition.carbohydrates / total;
    final proteinRatio = nutrition.protein / total;
    final fatRatio = nutrition.fat / total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            Expanded(
              flex: (carbRatio * 100).round(),
              child: Container(color: Colors.blue.shade400),
            ),
            Expanded(
              flex: (proteinRatio * 100).round(),
              child: Container(color: Colors.red.shade400),
            ),
            Expanded(
              flex: (fatRatio * 100).round(),
              child: Container(color: Colors.amber.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientDetail(
    String name,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/// 원형 영양 차트 (선택사항)
class NutritionPieChart extends StatelessWidget {
  final NutritionInfo nutrition;
  final double size;

  const NutritionPieChart({
    super.key,
    required this.nutrition,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final total = nutrition.carbohydrates + nutrition.protein + nutrition.fat;
    
    if (total == 0) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            '영양 정보 없음',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PieChartPainter(
          carbs: nutrition.carbohydrates / total,
          protein: nutrition.protein / total,
          fat: nutrition.fat / total,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${nutrition.calories}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'kcal',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double carbs;
  final double protein;
  final double fat;

  _PieChartPainter({
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 16.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -3.14159 / 2; // 12시 방향부터 시작

    // 탄수화물
    paint.color = Colors.blue.shade400;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      carbs * 2 * 3.14159,
      false,
      paint,
    );
    startAngle += carbs * 2 * 3.14159;

    // 단백질
    paint.color = Colors.red.shade400;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      protein * 2 * 3.14159,
      false,
      paint,
    );
    startAngle += protein * 2 * 3.14159;

    // 지방
    paint.color = Colors.amber.shade400;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fat * 2 * 3.14159,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 일일 목표 대비 진행률 위젯
class DailyNutritionProgress extends StatelessWidget {
  final NutritionInfo current;
  final NutritionInfo target;

  const DailyNutritionProgress({
    super.key,
    required this.current,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '일일 목표',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgressRow(
            '칼로리',
            current.calories.toDouble(),
            target.calories.toDouble(),
            'kcal',
            AppTheme.secondaryOrange,
          ),
          const SizedBox(height: 12),
          _buildProgressRow(
            '탄수화물',
            current.carbohydrates,
            target.carbohydrates,
            'g',
            Colors.blue.shade400,
          ),
          const SizedBox(height: 12),
          _buildProgressRow(
            '단백질',
            current.protein,
            target.protein,
            'g',
            Colors.red.shade400,
          ),
          const SizedBox(height: 12),
          _buildProgressRow(
            '지방',
            current.fat,
            target.fat,
            'g',
            Colors.amber.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(
    String label,
    double current,
    double target,
    String unit,
    Color color,
  ) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '${current.toInt()} / ${target.toInt()} $unit',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

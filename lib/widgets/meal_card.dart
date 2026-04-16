import 'package:flutter/material.dart';

import '../models/meal_plan.dart';
import '../utils/app_theme.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onRegenerate;

  const MealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.onLike,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  // 끼니 아이콘
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        meal.type.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 끼니 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.type.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          meal.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 칼로리
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${meal.nutrition.calories}kcal',
                      style: const TextStyle(
                        color: AppTheme.secondaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              // 설명
              if (meal.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  meal.description!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // 영양소 바
              const SizedBox(height: 12),
              _buildNutritionBar(),
              
              // 조리 시간 & 액션 버튼
              const SizedBox(height: 12),
              Row(
                children: [
                  // 조리 시간
                  if (meal.cookingTime != null) ...[
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${meal.cookingTime}분',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  
                  // 재료 수
                  Icon(
                    Icons.list_alt,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '재료 ${meal.ingredients.length}개',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // 좋아요 버튼
                  if (onLike != null)
                    IconButton(
                      onPressed: onLike,
                      icon: Icon(
                        meal.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: meal.isLiked ? Colors.red : Colors.grey,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  
                  // 재생성 버튼
                  if (onRegenerate != null)
                    IconButton(
                      onPressed: onRegenerate,
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.grey.shade600,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionBar() {
    final total = meal.nutrition.carbohydrates +
        meal.nutrition.protein +
        meal.nutrition.fat;
    
    if (total == 0) return const SizedBox.shrink();

    final carbRatio = meal.nutrition.carbohydrates / total;
    final proteinRatio = meal.nutrition.protein / total;
    final fatRatio = meal.nutrition.fat / total;

    return Column(
      children: [
        // 바
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
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
        ),
        const SizedBox(height: 8),
        
        // 레전드
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNutrientLabel(
              '탄수화물',
              '${meal.nutrition.carbohydrates.toInt()}g',
              Colors.blue.shade400,
            ),
            _buildNutrientLabel(
              '단백질',
              '${meal.nutrition.protein.toInt()}g',
              Colors.red.shade400,
            ),
            _buildNutrientLabel(
              '지방',
              '${meal.nutrition.fat.toInt()}g',
              Colors.amber.shade400,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientLabel(String name, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$name $value',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

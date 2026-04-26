// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:app/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
class CategoryBadge extends StatelessWidget {
  final String category;
  final bool large;
  final bool animate;


  const CategoryBadge({
    Key? key,
    required this.category,
    required this.large,
    required this.animate,
  }) : super(key: key);


  @override
  Widget build(BuildContext context){
    final meta = AppConstants.categoryMeta(category);
    final color = Color(meta.color);

    Widget badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 7 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1
        )

      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            meta.icon, style: TextStyle(
              color: color,
              fontSize: large ? 13 : 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2
            ),
          )
        ],
      ),
    );

    if(animate){
      badge = badge.animate().scale(
        begin: const Offset(0.5, 0.5),
        end: const Offset(1.0, 1.0),
        duration: 400.ms,
        curve: Curves.elasticOut
      ).fade(duration: 200.ms);
    }
    return badge;
  }


  
}

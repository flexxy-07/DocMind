import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../widgets/technical_button.dart';

class DocumentsEmptyView extends StatelessWidget {
  final bool isSearch;
  final VoidCallback onClear;

  const DocumentsEmptyView({super.key, required this.isSearch, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearch ? Icons.search_off_rounded : Icons.inventory_2_outlined,
            size: 64,
            color: ObsidianColors.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            isSearch ? 'NO INTELLIGENCE FOUND' : 'ARCHIVE IS EMPTY',
            style: ObsidianTypography.technicalLabel.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch ? 'TRY ADJUSTING YOUR FILTER' : 'INGEST A DOCUMENT TO BEGIN',
            style: ObsidianTypography.labelSmall,
          ),
          if (isSearch) ...[
            const SizedBox(height: 32),
            TechnicalButton(
              label: 'CLEAR FILTER',
              onTap: onClear,
              width: 200,
            ),
          ],
        ],
      ),
    );
  }
}

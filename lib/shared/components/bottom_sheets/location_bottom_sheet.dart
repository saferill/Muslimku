import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class LocationBottomSheet extends StatelessWidget {
  const LocationBottomSheet({
    super.key,
    required this.currentValue,
    required this.onSelected,
    this.onAutoDetect,
  });

  final String currentValue;
  final Future<void> Function(String) onSelected;
  final Future<void> Function()? onAutoDetect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Pilih lokasi salat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            if (onAutoDetect != null) ...<Widget>[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await onAutoDetect!.call();
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('Auto Detect'),
                ),
              ),
              const SizedBox(height: 12),
            ],
            ...AppConstants.popularLocations.map(
              (location) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(location),
                trailing: currentValue == location
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () async {
                  await onSelected(location);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

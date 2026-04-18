import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';

class LocationBottomSheet extends StatefulWidget {
  const LocationBottomSheet({
    super.key,
    required this.currentValue,
    required this.onSelected,
    this.onAutoDetect,
    this.onManualSearch,
  });

  final String currentValue;
  final Future<void> Function(String) onSelected;
  final Future<void> Function()? onAutoDetect;
  final Future<void> Function(String)? onManualSearch;

  @override
  State<LocationBottomSheet> createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends State<LocationBottomSheet> {
  final TextEditingController _manualController = TextEditingController();

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

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
            const SizedBox(height: 10),
            const Text(
              'Gunakan deteksi otomatis, pilih kota preset, atau cari kota/alamatmu secara manual.',
              style: TextStyle(
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            if (widget.onManualSearch != null) ...<Widget>[
              TextField(
                controller: _manualController,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'Cari kota atau koordinat',
                  hintText: 'Contoh: Solo, Indonesia / -7.566, 110.816',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onSubmitted: (_) => _runManualSearch(context),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _runManualSearch(context),
                  icon: const Icon(Icons.travel_explore_rounded),
                  label: const Text('Gunakan hasil pencarian manual'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.onAutoDetect != null) ...<Widget>[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await widget.onAutoDetect!.call();
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('Deteksi Otomatis'),
                ),
              ),
              const SizedBox(height: 12),
            ],
            ...AppConstants.popularLocations.map(
              (location) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(location),
                trailing: widget.currentValue == location
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () async {
                  await widget.onSelected(location);
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

  Future<void> _runManualSearch(BuildContext context) async {
    final value = _manualController.text.trim();
    if (value.isEmpty || widget.onManualSearch == null) return;
    await widget.onManualSearch!(value);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}

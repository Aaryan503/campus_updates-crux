import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_updates/providers/filters_provider.dart';

class FiltersScreen extends ConsumerWidget {
  const FiltersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilters = ref.watch(filtersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Filters'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 4,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Filter by Club Type",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                SwitchListTile(
                  value: currentFilters[Filter.technical]!,
                  onChanged: (isOperated) {
                    ref
                        .read(filtersProvider.notifier)
                        .setFilter(Filter.technical, isOperated);
                  },
                  title: Text(
                    "Technical Clubs",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  ),
                  subtitle: Text(
                    "Include/exclude Technical Clubs",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                  ),
                  trackColor: Theme.of(context).switchTheme.trackColor,
                  thumbColor: Theme.of(context).switchTheme.thumbColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                SwitchListTile(
                  value: currentFilters[Filter.cultural]!,
                  onChanged: (isOperated) {
                    ref
                        .read(filtersProvider.notifier)
                        .setFilter(Filter.cultural, isOperated);
                  },
                  title: Text(
                    "Cultural Clubs",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  ),
                  subtitle: Text(
                    "Include/exclude Cultural Clubs",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                  ),
                  trackColor: Theme.of(context).switchTheme.trackColor,
                  thumbColor: Theme.of(context).switchTheme.thumbColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                SwitchListTile(
                  value: currentFilters[Filter.sports]!,
                  onChanged: (isOperated) {
                    ref
                        .read(filtersProvider.notifier)
                        .setFilter(Filter.sports, isOperated);
                  },
                  title: Text(
                    "Sports Clubs",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  ),
                  subtitle: Text(
                    "Include/exclude Sports Clubs",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                  ),
                  trackColor: Theme.of(context).switchTheme.trackColor,
                  thumbColor: Theme.of(context).switchTheme.thumbColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

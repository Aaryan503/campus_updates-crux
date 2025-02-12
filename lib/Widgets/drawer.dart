import 'package:campus_updates/Screens/auth.dart';
import 'package:campus_updates/providers/filters_provider.dart';
import 'package:campus_updates/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterDrawer extends ConsumerWidget {
  const FilterDrawer({super.key, required this.onSelectScreen});

  final void Function(String identifier) onSelectScreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final isDarkMode = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_available,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Text(
                  'Events',
                  style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.calendar_today,
              size: 28,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              'Current Events',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              onSelectScreen('events');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              size: 28,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              'Filters',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              onSelectScreen('filters');
            },
          ),
          SwitchListTile(
            title: Text(
              'Dark Mode',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            value: isDarkMode,
            onChanged: (value) {
              themeNotifier.toggleTheme(value);
            },
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: theme.colorScheme.primary),
              ),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  ref.read(filtersProvider.notifier).resetFilters();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const AuthScreen()),
                  );
                } catch (error) {
                  rethrow;
                }
              },
              icon: Icon(
                Icons.exit_to_app,
                color: theme.textTheme.bodyMedium?.color,
              ),
              label: Text(
                'Logout',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

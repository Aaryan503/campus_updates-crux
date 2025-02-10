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
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_available,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Text(
                  'Events',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.calendar_today,
              size: 28,
              color: Colors.blue.shade800,
            ),
            title: const Text(
              'Current Events',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              onSelectScreen('events');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              size: 28,
              color: Colors.blue.shade800,
            ),
            title: const Text(
              'Filters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              onSelectScreen('filters');
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode', 
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),),
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
                side: BorderSide(color: Colors.blue.shade800),
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
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
              label: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

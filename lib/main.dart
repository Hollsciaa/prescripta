import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prescripta/screens/client_management_screen.dart';
import 'package:prescripta/screens/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prescripta/screens/partner_catalog_screen.dart';
import 'package:prescripta/screens/profile_screen.dart';
import 'package:prescripta/screens/saved_pdfs_screen.dart';
import 'package:prescripta/screens/settings_screen.dart';
import 'screens/dashboard_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:prescripta/screens/register_screen.dart';
import 'package:prescripta/screens/admin_users_screen.dart';
import 'package:prescripta/screens/theme_provider.dart';
import 'package:prescripta/screens/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:prescripta/screens/saved_pdfs_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('fr'), Locale('en')],
      path: 'lib/translations', // <- dossier où sont tes fichiers JSON
      fallbackLocale: Locale('fr'),
      startLocale: Locale('fr'),
      child: MyApp(),
    ),
  );
}

final storage = FlutterSecureStorage();

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/dashboard', builder: (context, state) => DashboardScreen()),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    GoRoute(
      path: '/admin-users',
      builder: (context, state) => AdminUsersScreen(),
    ),
    GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
    GoRoute(path: '/settings', builder: (context, state) => SettingsScreen()),
    GoRoute(
      path: '/manage-clients',
      builder: (context, state) => ClientManagementScreen(),
    ),
    GoRoute(
      path: '/partner-catalog',
      builder: (context, state) => PartnerCatalogScreen(),
    ),
    GoRoute(
      path: '/saved-pdfs',
      builder: (context, state) => SavedPdfsScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Prescripta',
            theme:
                themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            routerConfig: _router,

            // 🔽 Intégration easy_localization
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
          );
        },
      ),
    );
  }
}

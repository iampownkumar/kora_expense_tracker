import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/utils/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/accounts/account_controller.dart';
import 'features/transactions/transaction_controller.dart';
import 'features/credit_cards/credit_card_controller.dart';
import 'features/reports/reports_controller.dart';
import 'features/settings/settings_controller.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.initialize();
  runApp(const KoraApp());
}

class KoraApp extends StatelessWidget {
  const KoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Build the AccountController first (no dependencies) ─────────────────
    final accountController = AccountController();

    // ── TransactionController depends on AccountController ───────────────────
    final transactionController = TransactionController(
      accountController: accountController,
    );

    // ── CreditCardController depends on TransactionController ────────────────
    final creditCardController = CreditCardController(
      transactionController: transactionController,
      accountController: accountController,
    );

    // ── ReportsController aggregates Account + Transaction ───────────────────
    final reportsController = ReportsController(
      transactionController: transactionController,
      accountController: accountController,
    );

    // ── SettingsController: no dependencies ──────────────────────────────────
    final settingsController = SettingsController();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: accountController),
        ChangeNotifierProvider.value(value: transactionController),
        ChangeNotifierProvider.value(value: creditCardController),
        ChangeNotifierProvider.value(value: reportsController),
        ChangeNotifierProvider.value(value: settingsController),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settingsController.settings.themeModeEnum,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ta', ''),
              Locale('hi', ''),
            ],
            locale: const Locale('en', ''),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

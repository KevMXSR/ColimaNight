import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/firestore_cost_optimizer.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/views/splash_loading_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el optimizador de costos de Firestore (Spark 0-cost guard)
  FirestoreCostOptimizer.instance.initialize();

  // En plataformas móviles bloquea orientación vertical para experiencia inmersiva nightlife;
  // en Web y Escritorio permite adaptación libre al tamaño de ventana.
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: ColimaNightApp(),
    ),
  );
}

class ColimaNightApp extends StatelessWidget {
  const ColimaNightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ColimaNight',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashLoadingView(),
    );
  }
}

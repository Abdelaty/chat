import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:whatsup/common/theme.dart';
import 'package:whatsup/common/util/constants.dart';
import 'package:whatsup/common/util/logger.dart';
import 'package:whatsup/config.dart';
import 'package:whatsup/features/call/service/call_invitation.dart';
import 'package:whatsup/features/startup/pages/startup.dart';
import 'package:whatsup/router.dart';

import 'common/util/run_mode.dart';

final Logger logger = AppLogger.getLogger('init');

void main() async {
  logger.i("Initializing app in ${RunModeExtension.currentMode.name} mode");
  await dotenv.load(fileName: '.env');
  final navigatorKey = GlobalKey<NavigatorState>();
  WidgetsFlutterBinding.ensureInitialized();
  CallInvitationService.attachNavigatorKey(navigatorKey);
  CallInvitationService.useSysCallUI();

  if (RunModeExtension.currentMode.isDebug) {
    // https://github.com/flutter/flutter/issues/10713
    // hide keyboard on hot restart
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  await Firebase.initializeApp(
    name: dotenv.get("FIREBASE_PROJECT_ID"),
    options: AppConfig.firebaseSettings,
  );
  await FirebaseAppCheck.instance.activate();
  logger.e('errrror${dotenv.get("FIREBASE_PROJECT_ID")}');

  runApp(
    ProviderScope(
      observers: [ProviderStateChangeObserver()],
      child: App(navigatorKey: navigatorKey),
    ),
  );
}

class App extends ConsumerWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const App({
    required this.navigatorKey,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeNotifierProvider);
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: kAppName,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode:
          themeNotifier == Brightness.light ? ThemeMode.light : ThemeMode.dark,
      onGenerateRoute: PageRouter.generateRoutes,
      home: const StartUp(),
    );
  }
}

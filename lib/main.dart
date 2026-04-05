import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/isar_database.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/add_link_screen.dart';

final databaseProvider = Provider<IsarDatabase>((ref) {
  throw UnimplementedError('databaseProvider는 main에서 override 되어야 합니다.');
});

void main() async {
  // Flutter 엔진과 프레임워크가 연결되었는지 확인
  WidgetsFlutterBinding.ensureInitialized();

  // DB 인스턴스 생성 및 초기화
  final isarDatabase = IsarDatabase();
  await isarDatabase.initialize();

  runApp(
    // Riverpod을 사용하기 위해 앱 최상단을 ProviderScope로 감싸줌
    ProviderScope(
      overrides: [
        // 미리 초기화해둔 DB 인스턴스 주입
        databaseProvider.overrideWithValue(isarDatabase),
      ],
      child: const LinkClipApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LinkClipApp extends StatefulWidget {
  const LinkClipApp({super.key});

  @override
  State<LinkClipApp> createState() => _LinkClipAppState();
}

class _LinkClipAppState extends State<LinkClipApp> {
  late StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();

    // 1. 앱이 백그라운드나 켜진 상태에서 외부 공유를 받았을 때
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> value) {
          _handleSharedLinks(value);
        });

    // 2. 앱이 완전히 꺼져 있는 상태(Terminated)에서 외부 공유로 앱이 켜졌을 때
    ReceiveSharingIntent.instance.getInitialMedia().then((
      List<SharedMediaFile> value,
    ) {
      _handleSharedLinks(value);
    });
  }

  void _handleSharedLinks(List<SharedMediaFile> value) {
    if (value.isNotEmpty) {
      // 공유받은 텍스트(URL 등) 추출. receive_sharing_intent 1.8+에서는 path로 텍스트가 넘어올 수도 있습니다.
      final String sharedText = value.first.path;
      print("💡 [Share Extension] 공유받은 링크: $sharedText");

      if (sharedText.isNotEmpty) {
        // 네비게이터를 사용해 AddLinkScreen으로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => AddLinkScreen(initialUrl: sharedText),
            ),
          );
        });
      }

      // 인텐트 초기화 (동일한 링크 무한 반복 방지)
      ReceiveSharingIntent.instance.reset();
    }
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 글로벌 네비게이션 키 연결
      title: "LinkClip Clone",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

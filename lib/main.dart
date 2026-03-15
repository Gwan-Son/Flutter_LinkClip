import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/isar_database.dart';

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

class LinkClipApp extends StatelessWidget {
  const LinkClipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "LinkClip Clone",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 테스트
      home: const Scaffold(
        body: Center(
          child: Text('LinkClip 클론 시작!'),
        ),
      ),
    );
  }
}

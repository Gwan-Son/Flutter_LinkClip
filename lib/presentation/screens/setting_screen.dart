import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:linkclip_flutter/domain/models/link_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/link_provider.dart';
import '../../data/isar_database.dart';
import '../../main.dart'; // To access databaseProvider

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  bool _isReindexing = false;
  bool _isReloadingThumbnails = false;

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _resetAllData() async {
    final db = ref.read(databaseProvider);
    await db.isar.writeTxn(() async {
      await db.isar.linkItems.clear();
    });
    // Refresh links
    ref.read(linkListProvider.notifier).build();

    if (mounted) {
      _showToast(context, '모든 URL이 초기화되었습니다.');
    }
  }

  Future<void> _reindexAll() async {
    setState(() => _isReindexing = true);
    await Future.delayed(const Duration(seconds: 1)); // Mocking
    setState(() => _isReindexing = false);
    if (mounted) {
      _showToast(context, 'Spotlight 재색인이 완료되었습니다.');
    }
  }

  Future<void> _reloadThumbnails() async {
    setState(() => _isReloadingThumbnails = true);
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Mocking since actual impl needs DB query + metadata fetcher
    setState(() => _isReloadingThumbnails = false);
    if (mounted) {
      _showToast(context, '썸네일 로딩을 완료했습니다.');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'id1593572580@gmail.com',
      queryParameters: {'subject': 'LinkClip 앱 문의', 'body': '앱 버전: 1.0 (1)'},
    );

    try {
      final launched = await launchUrl(emailLaunchUri);
      if (!launched) {
        throw Exception('Could not launch email');
      }
    } catch (e) {
      await Clipboard.setData(
        const ClipboardData(text: 'id1593572580@gmail.com'),
      );
      if (mounted) {
        _showToast(context, '이메일 주소 복사');
      }
    }
  }

  Future<void> _openLink(String urlStr) async {
    final url = Uri.parse(urlStr);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '설정',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('완료', style: TextStyle(fontSize: 16)),
          ),
        ],
        automaticallyImplyLeading:
            false, // iOS modal styles don't show back if it's pushed as modal
      ),
      body: ListView(
        children: [
          // 앱 정보 섹션
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 20),
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.link,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LinkClip',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '버전 1.0 (1)',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 데이터 관리
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '데이터 관리',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    _isReindexing
                        ? CupertinoIcons.arrow_2_circlepath_circle_fill
                        : CupertinoIcons.arrow_2_circlepath,
                    color: Colors.blue,
                  ),
                  title: Text(
                    _isReindexing ? 'Spotlight 재색인 중...' : 'Spotlight 재색인',
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: _reindexAll,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Icon(
                    _isReloadingThumbnails
                        ? CupertinoIcons.photo_fill
                        : CupertinoIcons.photo,
                    color: Colors.green,
                  ),
                  title: Text(
                    _isReloadingThumbnails ? '썸네일 다시 로딩 중...' : '썸네일 다시 로딩',
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: _reloadThumbnails,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(CupertinoIcons.trash, color: Colors.red),
                  title: const Text(
                    '저장된 URL 초기화',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('모든 URL을 삭제하시겠습니까?'),
                        content: const Text('이 작업은 되돌릴 수 없습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              '취소',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _resetAllData();
                            },
                            child: const Text(
                              '삭제',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 지원
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
            child: Text(
              '지원',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(CupertinoIcons.mail, color: Colors.blue),
                  title: const Text('문의하기', style: TextStyle(fontSize: 16)),
                  onTap: _sendEmail,
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(
                    CupertinoIcons.hand_raised,
                    color: Colors.blue,
                  ),
                  title: const Text(
                    '개인정보 처리방침',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(
                    CupertinoIcons.arrow_up_right,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () => _openLink(
                    "https://raw.githubusercontent.com/Gwan-Son/LinkClip/refs/heads/main/privacy/privacy.md",
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(
                    CupertinoIcons.doc_text,
                    color: Colors.blue,
                  ),
                  title: const Text('이용약관', style: TextStyle(fontSize: 16)),
                  trailing: const Icon(
                    CupertinoIcons.arrow_up_right,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () => _openLink(
                    "https://raw.githubusercontent.com/Gwan-Son/LinkClip/refs/heads/main/privacy/service.md",
                  ),
                ),
              ],
            ),
          ),

          // 정보
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
            child: Text(
              '정보',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(
                CupertinoIcons.star_fill,
                color: Colors.amber,
              ),
              title: const Text('앱 평가하기', style: TextStyle(fontSize: 16)),
              trailing: const Icon(
                CupertinoIcons.arrow_up_right,
                size: 14,
                color: Colors.grey,
              ),
              onTap: () => _openLink("https://apps.apple.com/app/id"),
            ),
          ),

          const SizedBox(height: 48),

          // 푸터
          const Center(
            child: Text(
              '@ 2025 Linkclip. All rights reserved.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

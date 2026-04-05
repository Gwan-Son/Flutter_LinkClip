import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/metadata_fetcher.dart';
import '../../domain/providers/category_provider.dart';
import '../../domain/providers/link_provider.dart';
import '../../domain/models/category.dart';

class AddLinkScreen extends ConsumerStatefulWidget {
  final String? initialUrl; // 공유 확장 등을 통해 진입했을 때 자동으로 채울 URL

  const AddLinkScreen({super.key, this.initialUrl});

  @override
  ConsumerState<AddLinkScreen> createState() => _AddLinkScreenState();
}

class _AddLinkScreenState extends ConsumerState<AddLinkScreen> {
  late final TextEditingController _urlController;
  final TextEditingController _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // initialUrl이 있다면 기본값으로 넣고 시작, 없다면 빈 문자열
    _urlController = TextEditingController(text: widget.initialUrl ?? '');

    // 만약 전달받은 URL이 있다면 앱 켜지자마자 바로 메타데이터 가져오기!
    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchMetadata();
      });
    }
  }

  bool _isLoading = false;
  LinkMetadata? _metadata; // URL로 가져온 데이터 껍데기
  Category? _selectedCategory; // 저장할 타겟 카테고리

  @override
  void dispose() {
    _urlController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  // URL로 메타데이터 긁어오기
  Future<void> _fetchMetadata() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final metadata = await MetadataFetcher.fetch(url);

    // 결과 저장 및 로딩 종료
    setState(() {
      _metadata = metadata;
      _isLoading = false;
    });
  }

  // 실제 Isar DB에 링크 저장하기
  void _saveLink() {
    if (_metadata == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL 파싱 데이터를 먼저 가져와주세요!')),
      );
      return;
    }

    // Provider를 읽어서 데이터 저장
    ref
        .read(linkListProvider.notifier)
        .addLink(
          url: _urlController.text.trim(),
          title: _metadata!.title,
          description: _metadata!.description,
          imageUrl: _metadata!.imageUrl,
          memo: _memoController.text.trim(),
          category: _selectedCategory,
        );

    // 완료 후 이전 화면으로 돌아가기
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // 저장 가능한 카테고리 리스트 불러오기
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('새 파도(링크) 추가')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. URL 입력 및 불러오기 영역
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL 주소',
                      hintText: 'https://example.com',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _fetchMetadata, // 로딩 중엔 터치 막기
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('확인'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. 파싱된 미리보기 영역
            if (_metadata != null) ...[
              const Text(
                '가져온 정보 미리보기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_metadata!.imageUrl != null)
                Image.network(
                  _metadata!.imageUrl!,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              Text(
                '제목: ${_metadata!.title ?? '없음'}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
            ],

            // 3. 메모 작성 영역
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: '간단한 메모 (선택)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // 4. 저장할 카테고리 선택 영역
            DropdownButtonFormField<Category?>(
              decoration: const InputDecoration(
                labelText: '카테고리 (선택사항)',
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedCategory,
              items: [
                const DropdownMenuItem<Category?>(
                  value: null,
                  child: Text('카테고리 없음 (선택 안함)'),
                ),
                ...categories.map((cat) {
                  return DropdownMenuItem<Category?>(
                    value: cat,
                    child: Text(cat.name),
                  );
                }),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),
            const SizedBox(height: 32),

            // 5. 완료/저장 버튼
            FilledButton(
              onPressed: _metadata != null ? _saveLink : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
              child: const Text('링크 저장하기', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

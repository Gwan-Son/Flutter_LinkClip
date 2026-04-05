import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/metadata_fetcher.dart';
import '../../domain/providers/category_provider.dart';
import '../../domain/providers/link_provider.dart';
import '../common/category_icons.dart';

// LinkClip 앱 테마 색상 (ShareView.swift의 mainColor: #FFC277)
const Color _mainColor = Color(0xFFFFC277);
const Color _mainColorLight = Color(0x33FFC277); // 20% opacity

class AddLinkScreen extends ConsumerStatefulWidget {
  final String? initialUrl;

  const AddLinkScreen({super.key, this.initialUrl});

  @override
  ConsumerState<AddLinkScreen> createState() => _AddLinkScreenState();
}

class _AddLinkScreenState extends ConsumerState<AddLinkScreen> {
  late final TextEditingController _titleController;
  final TextEditingController _memoController = TextEditingController();

  bool _isLoading = false;
  LinkMetadata? _metadata;
  final Set<int> _selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();

    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchMetadata();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _fetchMetadata() async {
    final url = widget.initialUrl ?? '';
    if (url.isEmpty) return;

    setState(() => _isLoading = true);

    final metadata = await MetadataFetcher.fetch(url);

    setState(() {
      _metadata = metadata;
      _isLoading = false;
      // 제목이 비어있으면 메타데이터의 제목 또는 호스트로 채우기
      if (_titleController.text.isEmpty) {
        final host = Uri.tryParse(url)?.host ?? '';
        _titleController.text = metadata.title ?? host;
      }
    });
  }

  void _saveLink() {
    final url = widget.initialUrl?.trim() ?? '';
    if (url.isEmpty) return;

    final categories = ref.read(categoryProvider);
    final selectedCategories = categories
        .where((c) => _selectedCategoryIds.contains(c.id))
        .toList();

    ref.read(linkListProvider.notifier).addLink(
          url: url,
          title: _titleController.text.trim().isNotEmpty
              ? _titleController.text.trim()
              : (Uri.tryParse(url)?.host ?? '제목 없음'),
          description: _metadata?.description,
          imageUrl: _metadata?.imageUrl,
          memo: _memoController.text.trim(),
          category: selectedCategories.isNotEmpty ? selectedCategories.first : null,
        );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('URL 저장됨'),
        content: const Text('URL이 성공적으로 저장되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('확인', style: TextStyle(color: _mainColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final urlString = widget.initialUrl ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Large title style (navigationBarTitleDisplayMode: .large)
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '취소',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        leadingWidth: 70,
        title: const Text(
          'URL 저장',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: urlString.isNotEmpty ? _saveLink : null,
            icon: Icon(
              CupertinoIcons.checkmark_alt,
              size: 16,
              color: urlString.isNotEmpty ? _mainColor : Colors.grey,
            ),
            label: Text(
              '저장',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: urlString.isNotEmpty ? _mainColor : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _mainColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. 제목 섹션 ──────────────────────────────
                  _SectionHeader(
                    icon: CupertinoIcons.pencil,
                    title: '제목',
                  ),
                  const SizedBox(height: 12),
                  _StyledTextField(
                    controller: _titleController,
                    hintText: 'URL 제목을 입력하세요',
                  ),
                  const SizedBox(height: 28),

                  // ── 2. 카테고리 섹션 ──────────────────────────
                  Row(
                    children: [
                      const Icon(CupertinoIcons.tag, color: _mainColor, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        '카테고리',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(여러 개 선택 가능)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  categories.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              '등록된 카테고리가 없습니다',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: categories.map((category) {
                            final isSelected =
                                _selectedCategoryIds.contains(category.id);
                            final color = Color(category.colorValue);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedCategoryIds.remove(category.id);
                                  } else {
                                    _selectedCategoryIds.add(category.id);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isSelected ? color : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? color
                                        : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(13),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CategoryIcons.icons[
                                          category.iconIndex ?? 0],
                                      size: 15,
                                      color: isSelected ? Colors.white : color,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      category.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 28),

                  // ── 3. 메모 섹션 ──────────────────────────────
                  Row(
                    children: [
                      const Icon(CupertinoIcons.doc_text, color: _mainColor, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        '메모',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(선택사항)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // TextEditor-style memo field with placeholder overlay
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _mainColorLight, width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        if (_memoController.text.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Text(
                              '링크에 대한 메모를 남겨보세요',
                              style: TextStyle(
                                color: Color(0x80000000),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        TextField(
                          controller: _memoController,
                          onChanged: (_) => setState(() {}),
                          minLines: 4,
                          maxLines: null,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── 4. URL 정보 섹션 ──────────────────────────
                  _SectionHeader(
                    icon: CupertinoIcons.link,
                    title: 'URL 정보',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _mainColorLight, width: 1),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      urlString.isNotEmpty ? urlString : '—',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

// ── 공통 섹션 헤더 위젯 ─────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _mainColor, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── 공통 스타일 텍스트 필드 ────────────────────────

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _StyledTextField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _mainColorLight, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0x80000000)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

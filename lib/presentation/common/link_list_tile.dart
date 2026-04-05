import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/link_item.dart';
import '../../domain/providers/link_provider.dart';

class LinkListTile extends ConsumerWidget {
  final LinkItem link;

  const LinkListTile({super.key, required this.link});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelectionMode = ref.watch(multiSelectionModeProvider);
    final selectedLinks = ref.watch(selectedLinksProvider);
    final isSelected = selectedLinks.contains(link.id);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      pressedOpacity: 0.5,
      onPressed: () {
        if (isSelectionMode) {
          // 선택 모드: Set에 항목을 추가하거나 제거
          final notifier = ref.read(selectedLinksProvider.notifier);
          final updatedSet = Set<int>.from(notifier.state);
          if (isSelected) {
            updatedSet.remove(link.id);
          } else {
            updatedSet.add(link.id);
          }
          notifier.state = updatedSet;
        } else {
          try {
            final uri = Uri.parse(link.url);
            launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            print('URL 열기 실패: $e');
          }
        }
      },
      child: GestureDetector(
        onLongPress: () {
          if (isSelectionMode) return; // 선택 모드일 땐 롱프레스 비활성화
          // iOS 스타일 컨텍스트 팝업 (액션 시트) 띄우기
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              title: Text('링크 옵션'),
              message: Text(link.title ?? '이 링크를 어떻게 할까요?'),
              actions: <CupertinoActionSheetAction>[
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    ref.read(linkListProvider.notifier).deleteLink(link.id);
                    Navigator.pop(context);
                  },
                  child: const Text('삭제하기'),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('취소'),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsetsGeometry.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 선택 모드 시 표시될 체크 원형 아이콘
              if (isSelectionMode) ...[
                Icon(
                  isSelected
                      ? CupertinoIcons.check_mark_circled_solid
                      : CupertinoIcons.circle,
                  color: isSelected ? Colors.blueAccent : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: link.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: link.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => _fallbackIcon(),
                        )
                      : _fallbackIcon(),
                ),
              ),
              const SizedBox(
                width: 16,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.title ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      link.relativeTime,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              SFIcon(
                SFIcons.sf_chevron_forward,
                color: Colors.grey,
                fontSize: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        SFIcons.sf_link,
        color: Colors.grey,
        size: 20,
      ),
    );
  }
}

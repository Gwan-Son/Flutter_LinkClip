import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/link_item.dart';

class LinkCardView extends StatelessWidget {
  final LinkItem link; // 보여줄 데이터 인스턴스

  const LinkCardView({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      pressedOpacity: 0.5,
      onPressed: () {
        try {
          final uri = Uri.parse(link.url);
          launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          print('URL 열기 실패: $e');
        }
      },
      child: Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 썸네일 이미지 영역
            Padding(
              padding: const EdgeInsets.only(
                left: 6,
                right: 6,
                top: 8,
                bottom: 6,
              ),
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildThumbnail(),
                ),
              ),
            ),

            // 2. 하단 텍스트 정보 영역
            Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 8,
                top: 6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 링크 제목
                  Text(
                    link.title ?? '제목 없음',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis, // ... 처리
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 썸네일을 그려주는 별도 함수
  Widget _buildThumbnail() {
    // 이미지가 없으면 회색 배경에 아이콘 띄우기
    if (link.imageUrl == null || link.imageUrl!.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(SFIcons.sf_link, size: 20, color: Colors.grey),
      );
    }

    // 네트워크 이미지를 원활하게 가져오고 캐싱하는 CachedNetworkImage 위젯
    return CachedNetworkImage(
      imageUrl: link.imageUrl!,
      fit: BoxFit.cover, // AspectRatio 공간을 꽉 채우게
      placeholder: (context, url) => Container(
        color: Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      ),
    );
  }
}

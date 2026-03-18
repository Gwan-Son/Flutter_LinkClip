import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/link_item.dart';

class LinkCardView extends StatelessWidget {
  final LinkItem link; // 보여줄 데이터 인스턴스

  const LinkCardView({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 썸네일 이미지 영역
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildThumbnail(),
          ),

          // 2. 하단 텍스트 정보 영역
          Padding(
            padding: const EdgeInsets.all(12.0),
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
                const SizedBox(height: 4),
                // 사용자가 남긴 메모
                if (link.memo != null && link.memo!.isNotEmpty) ...[
                  Text(
                    link.memo!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // 원본 URL 주소
                Text(
                  link.url,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 썸네일을 그려주는 별도 함수
  Widget _buildThumbnail() {
    // 이미지가 없으면 회색 배경에 아이콘 띄우기
    if (link.imageUrl == null || link.imageUrl!.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.link, size: 40, color: Colors.grey),
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

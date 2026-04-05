import 'package:metadata_fetch/metadata_fetch.dart';

// 파싱된 데이터를 담을 데이터 클래스
class LinkMetadata {
  final String? title;
  final String? description;
  final String? imageUrl;

  LinkMetadata({this.title, this.description, this.imageUrl});
}

class MetadataFetcher {
  // 웹사이트에서 데이터를 긁어와서 LinkMetadata 객체로 반환해주는 함수
  static Future<LinkMetadata> fetch(String urlString) async {
    try {
      // urlString에 http/https가 없으면 기본으로 https://를 붙여줌
      final validUrl = urlString.startsWith('http')
          ? urlString
          : 'https://$urlString';

      // metadata_fetch 패키지의 extract 함수가 알아서 HTML의 <title>, <image>를 파싱해줌
      // 무한 대기(Hang) 방지를 위한 타임아웃 5초 설정
      var data = await MetadataFetch.extract(
        validUrl,
      ).timeout(const Duration(seconds: 5));

      if (data == null) {
        // 크롤링에 실패하거나 메타데이터가 없는 사이트인 경우
        return _fallbackMetadata(validUrl);
      }

      // 타이틀이 파싱되지 않았을 때 URL 자체의 호스트명을 도출하여 타이틀로 대체
      String? finalTitle = data.title;
      if (finalTitle == null || finalTitle.trim().isEmpty) {
        finalTitle = _extractHostname(validUrl);
      }

      return LinkMetadata(
        title: finalTitle,
        description: data.description,
        imageUrl: data.image,
      );
    } catch (e) {
      // 잘못된 url이거나 네트워크 에러, 타임아웃이 발생했을 때
      print('메타데이터 파싱 에러: $e');
      return _fallbackMetadata(urlString);
    }
  }

  // 예외 시 도메인 이름이라도 띄워주기 위한 폴백(Fallback) 함수
  static LinkMetadata _fallbackMetadata(String url) {
    return LinkMetadata(
      title: _extractHostname(url),
      description: null,
      imageUrl: null,
    );
  }

  // URL에서 도메인 부분(hostname)만 파싱하는 유틸리티
  static String? _extractHostname(String url) {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      if (uri.host.isNotEmpty) {
        return uri.host;
      }
    } catch (_) {}
    return "알 수 없는 링크";
  }
}

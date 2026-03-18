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
      var data = await MetadataFetch.extract(validUrl);

      if (data == null) {
        // 크롤링에 실패하거나 메타데이터가 없는 사이트인 경우
        return LinkMetadata();
      }

      return LinkMetadata(
        title: data.title,
        description: data.description,
        imageUrl: data.image,
      );
    } catch (e) {
      // 잘못된 url이거나 네트워크 에러가 났을 때 앱이 죽지않도록 예외 처리
      print('메타데이터 파싱 에러: $e');
      return LinkMetadata();
    }
  }
}

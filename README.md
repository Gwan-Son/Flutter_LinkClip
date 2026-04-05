# LinkClip Flutter

## 기존 LinkClip을 Flutter로 클론 코딩

기존에 Swift/SwiftUI로 제작한 iOS 앱 [LinkClip](https://github.com/Gwan-Son/LinkClip)을 Flutter로 재구현하는 클론 코딩 프로젝트입니다.  
동일한 UI/UX와 핵심 기능을 Flutter + Riverpod 아키텍처로 이식하는 것을 목표로 합니다.

## 목차
- [LinkClip Flutter](#linkclip-flutter)
  - [기존 LinkClip을 Flutter로 클론 코딩](#기존-linkclip을-flutter로-클론-코딩)
  - [목차](#목차)
- [👀 미리 보기](#-미리-보기)
- [📐 아키텍처 요약](#-아키텍처-요약)
    - [레이어 설명](#레이어-설명)
- [🔍 Native와 비교](#-native와-비교)
- [📦 사용 패키지](#-사용-패키지)
- [📁 파일 구조](#-파일-구조)

---

# 👀 미리 보기
<div>
  <img width=24.5% src="https://github.com/user-attachments/assets/26f1bc43-03fa-474b-aa0d-ab9c34330ac5" />
  <img width=24.5% src="https://github.com/user-attachments/assets/80cde260-4ba3-469c-af7e-f1b2c391b01d" />
  <img width=24.5% src="https://github.com/user-attachments/assets/7ce80a5d-7aec-48af-b233-47a296f27737" />
  <img width=24.5% src="https://github.com/user-attachments/assets/e2e578db-3559-4446-a3b1-18ad451ff5de" />
</div>

---

# 📐 아키텍처 요약

Flutter Riverpod 기반의 **단방향 데이터 흐름** 아키텍처를 채택했습니다.

```
UI (Screens / Widgets)
        │
        ▼  ref.watch / ref.read
  Providers (Riverpod)
        │
        ▼
  Notifiers (비즈니스 로직)
        │
        ▼
  IsarDatabase (로컬 영구 저장소)
```

### 레이어 설명

| 레이어 | 역할 | 주요 파일 |
|--------|------|-----------|
| **Presentation** | UI 렌더링, 사용자 이벤트 처리 | `screens/`, `common/` |
| **Domain** | 비즈니스 로직, 상태 관리 | `providers/`, `models/` |
| **Data** | DB 접근, 메타데이터 수집 | `isar_database.dart`, `metadata_fetcher.dart` |

---

# 🔍 Native와 비교

기존 Swift/SwiftUI 버전과 Flutter 버전의 주요 구현 방식 차이입니다.

| 항목 | Swift (Native) | Flutter |
|------|----------------|---------|
| **UI 프레임워크** | SwiftUI | Flutter (Material + Cupertino) |
| **상태 관리** | `@State`, `@Query` (SwiftData) | Riverpod (`Notifier`, `StateProvider`) |
| **로컬 DB** | SwiftData | Isar |
| **비동기 처리** | `async/await` | `async/await` (Dart) |
| **링크 추가 화면** | `ShareView.swift` | `AddLinkScreen` |
| **카테고리 추가** | `AddCategoryView.swift` | `CategoryAddScreen` |
| **카테고리 관리** | `CategoryManagementView.swift` | `CategoryManageScreen` |
| **카테고리 수정** | `CategoryEditView.swift` | `CategoryEditScreen` |
| **설정 화면** | `SettingView.swift` | `SettingScreen` |
| **공유 확장** | Share Extension (UIKit) | `receive_sharing_intent` |
| **메타데이터** | `ThumbnailService` + URLSession | `metadata_fetch` 패키지 |
| **이미지 캐싱** | `AsyncImage` | `cached_network_image` |

---

# 📦 사용 패키지

| 패키지 | 용도 |
|--------|------|
| `flutter_riverpod` | 전역 상태 관리 |
| `isar` + `isar_flutter_libs` | 로컬 NoSQL 데이터베이스 |
| `path_provider` | 앱 내 파일 경로 탐색 |
| `metadata_fetch` | URL에서 OG 태그·썸네일 추출 |
| `cached_network_image` | 네트워크 이미지 캐싱 |
| `url_launcher` | 외부 브라우저 · 메일 앱 열기 |
| `share_plus` | 링크 공유 기능 |
| `receive_sharing_intent` | 다른 앱에서 URL 공유받기 |
| `go_router` | 화면 라우팅 |
| `cupertino_icons` | iOS 스타일 아이콘 |
| `build_runner` + `isar_generator` | Isar 코드 생성 (dev) |

---

# 📁 파일 구조

```
lib/
├── main.dart                        # 앱 진입점, Isar 초기화
├── core/                            # (예정) 공통 상수, 테마
├── data/
│   ├── isar_database.dart           # Isar DB 래퍼 (CRUD)
│   └── metadata_fetcher.dart        # URL 메타데이터 수집
├── domain/
│   ├── models/
│   │   ├── category.dart            # 카테고리 Isar 모델
│   │   ├── category.g.dart          # (generated) Isar 스키마
│   │   ├── link_item.dart           # 링크 Isar 모델
│   │   ├── link_item.g.dart         # (generated) Isar 스키마
│   │   └── sort_option.dart         # 정렬 옵션 enum
│   └── providers/
│       ├── category_provider.dart   # 카테고리 상태 관리 (Riverpod)
│       └── link_provider.dart       # 링크 상태 관리 (Riverpod)
└── presentation/
    ├── common/
    │   ├── category_chip.dart       # 카테고리 필터 칩 위젯
    │   ├── category_icons.dart      # 공용 아이콘 팔레트
    │   ├── link_card_view.dart      # 링크 카드 위젯 (그리드 모드)
    │   └── link_list_tile.dart      # 링크 리스트 타일 위젯
    └── screens/
        ├── home_screen.dart         # 홈 화면 (링크 목록, 카테고리 필터)
        ├── add_link_screen.dart     # 링크 추가 화면 (ShareView 이식)
        ├── category_add_screen.dart # 카테고리 추가 화면
        ├── category_manage_screen.dart # 카테고리 관리 · 수정 화면
        └── setting_screen.dart      # 설정 화면
```

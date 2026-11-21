<details open>
<summary>🇹🇭 ภาษาไทย — สถาปัตยกรรมและโครงสร้างโปรเจกต์ (คลิกเพื่อย่อ/ขยาย)</summary>

## ภาพรวมสถาปัตยกรรม

โปรเจกต์นี้ใช้สถาปัตยกรรมแบบ Clean/Layered และมีการแยกหน้าที่ชัดเจนตามหลัก 1 ไฟล์ 1 หน้าที่:

- **Data-Driven:** เนื้อหาส่วนตัวอยู่ใน `assets/my_content/` แยกออกจากโค้ด UI ใน `lib/`
- **State Management:** ใช้ `ValueNotifier` + `ValueListenableBuilder` เท่านั้น โดยไม่เพิ่มแพ็กเกจ state management ภายนอก
- **Responsive UI:** ใช้ `LayoutTokens` และแยก Section, Navigation, Modal และ Widget กลางเป็นไฟล์เฉพาะ
- **Web Storage:** อ่าน/เขียนธีมและภาษาเริ่มต้นผ่าน `package:web` และ `localStorage`

## โครงสร้างโฟลเดอร์และไฟล์

```text
.
├── lib/
│   ├── main.dart                    # Entry point เท่านั้น
│   ├── app/
│   │   ├── app_bootstrap.dart       # สร้าง Controller และค่าเริ่มต้น
│   │   └── portfolio_app.dart       # ประกอบ MaterialApp และ Theme
│   ├── core/
│   │   ├── state/app_state.dart     # ValueNotifier ทั้งหมดของเว็บ
│   │   ├── l10n/app_strings.dart    # ข้อความ UI สองภาษา
│   │   ├── storage/local_storage_service.dart
│   │   ├── theme/app_colors.dart
│   │   ├── theme/app_theme.dart
│   │   └── theme/layout_tokens.dart
│   ├── data/
│   │   ├── models/                  # 1 Model ต่อ 1 ไฟล์
│   │   └── repositories/content_repository.dart
│   ├── services/pdf/resume_pdf_service.dart
│   └── presentation/
│       ├── pages/portfolio_page.dart
│       ├── navigation/portfolio_navigation.dart
│       ├── sections/
│       │   ├── hero/
│       │   │   ├── hero_section.dart
│       │   │   ├── hero_ocean_backdrop.dart
│       │   │   └── hero_profile_card.dart
│       │   ├── about/
│       │   │   ├── about_section.dart
│       │   │   ├── about_photo_card.dart
│       │   │   └── about_skills_grid.dart
│       │   ├── footer/footer_section.dart # Contact actions and copyright
│       ├── modals/
│       └── widgets/
│           ├── ocean_wave_divider.dart
│           └── back_to_top_button.dart
├── assets/my_content/
│   ├── profile/profile.json
│   ├── projects/projects.json
│   ├── links/links.json
│   ├── images/
│   └── fonts/Sarabun-*.ttf
├── web/
├── vercel.json
├── scripts/
└── .github/
```

## การไหลของข้อมูลในระบบ

```text
JSON ใน assets/my_content
  -> ContentRepository
  -> Data Models
  -> AppState (ValueNotifier)
  -> PortfolioPage / Sections / Modals
  -> ResumePdfService
```

## แผนที่การแก้ไขด่วน

| ต้องการแก้ | เปิดไฟล์ |
|---|---|
| สีและ Light/Dark Theme | `lib/core/theme/app_colors.dart`, `lib/core/theme/app_theme.dart` |
| ข้อความ UI สองภาษา | `lib/core/l10n/app_strings.dart` |
| Breakpoints, Spacing, Typography | `lib/core/theme/layout_tokens.dart` |
| ภาษาและธีมเริ่มต้น | `lib/core/storage/local_storage_service.dart` |
| สถานะภาษา/ธีม/Scroll/Filter/PDF | `lib/core/state/app_state.dart` |
| ข้อมูลส่วนตัวและผลงาน | `assets/my_content/` |
| การโหลด JSON | `lib/data/repositories/content_repository.dart` |
| โครงสร้างหน้าและ Scroll Spy | `lib/presentation/pages/portfolio_page.dart` |
| Navbar และ Mobile Drawer | `lib/presentation/navigation/portfolio_navigation.dart` |
| Hero Banner และ Portrait Card | `lib/presentation/sections/hero/` |
| คลื่นทะเลและ Footer/Contact | `lib/presentation/widgets/ocean_wave_divider.dart`, `lib/presentation/sections/footer/footer_section.dart` |
| การ์ดผลงานและ Modal | `lib/presentation/sections/projects/projects_section.dart` |
| All Projects / Detail / Lightbox | `lib/presentation/modals/` |
| Resume PDF | `lib/services/pdf/resume_pdf_service.dart` |

</details>

<details>
<summary>🇬🇧 English — Architecture &amp; Project Structure (Click to expand/collapse)</summary>

## Architecture Overview

The project follows Clean/Layered Architecture with clear Single Responsibility boundaries:

- **Data-Driven:** Personal content lives in `assets/my_content/`, separate from UI code in `lib/`
- **State Management:** Uses only `ValueNotifier` with `ValueListenableBuilder`
- **Responsive UI:** Uses `LayoutTokens` and dedicated Section, Navigation, Modal, and shared widget files
- **Web Storage:** Reads and writes locale/theme preferences through `package:web` and `localStorage`

## Project Structure

```text
.
├── lib/
│   ├── main.dart                    # Application entry point only
│   ├── app/
│   │   ├── app_bootstrap.dart       # Initial state/controller bootstrap
│   │   └── portfolio_app.dart       # MaterialApp and theme wiring
│   ├── core/
│   │   ├── state/app_state.dart     # Portfolio ValueNotifiers
│   │   ├── l10n/app_strings.dart    # Localized UI strings
│   │   ├── storage/local_storage_service.dart
│   │   ├── theme/app_colors.dart
│   │   ├── theme/app_theme.dart
│   │   └── theme/layout_tokens.dart
│   ├── data/
│   │   ├── models/                  # One model per file
│   │   └── repositories/content_repository.dart
│   ├── services/pdf/resume_pdf_service.dart
│   └── presentation/
│       ├── pages/portfolio_page.dart
│       ├── navigation/portfolio_navigation.dart
│       ├── sections/
│       │   ├── hero/
│       │   │   ├── hero_section.dart
│       │   │   ├── hero_ocean_backdrop.dart
│       │   │   └── hero_profile_card.dart
│       │   ├── about/
│       │   │   ├── about_section.dart
│       │   │   ├── about_photo_card.dart
│       │   │   └── about_skills_grid.dart
│       │   ├── footer/footer_section.dart # Contact actions and copyright
│       ├── modals/
│       └── widgets/
│           ├── ocean_wave_divider.dart
│           └── back_to_top_button.dart
├── assets/my_content/
│   ├── profile/profile.json
│   ├── projects/projects.json
│   ├── links/links.json
│   ├── images/
│   └── fonts/Sarabun-*.ttf
├── web/
├── vercel.json
├── scripts/
└── .github/
```

## Data Flow

```text
JSON in assets/my_content
  -> ContentRepository
  -> Data Models
  -> AppState (ValueNotifier)
  -> PortfolioPage / Sections / Modals
  -> ResumePdfService
```

## Quick Maintenance Map

| Change | Open |
|---|---|
| Colors and Light/Dark Theme | `lib/core/theme/app_colors.dart`, `lib/core/theme/app_theme.dart` |
| Localized UI strings | `lib/core/l10n/app_strings.dart` |
| Breakpoints, spacing, typography | `lib/core/theme/layout_tokens.dart` |
| Initial locale and theme | `lib/core/storage/local_storage_service.dart` |
| Locale/theme/scroll/filter/PDF state | `lib/core/state/app_state.dart` |
| Profile and project content | `assets/my_content/` |
| JSON loading | `lib/data/repositories/content_repository.dart` |
| Page structure and Scroll Spy | `lib/presentation/pages/portfolio_page.dart` |
| Navbar and Mobile Drawer | `lib/presentation/navigation/portfolio_navigation.dart` |
| Hero banner and portrait card | `lib/presentation/sections/hero/` |
| Ocean waves and Footer/Contact | `lib/presentation/widgets/ocean_wave_divider.dart`, `lib/presentation/sections/footer/footer_section.dart` |
| Project cards and project section | `lib/presentation/sections/projects/projects_section.dart` |
| All Projects / Detail / Lightbox | `lib/presentation/modals/` |
| Resume PDF | `lib/services/pdf/resume_pdf_service.dart` |

</details>
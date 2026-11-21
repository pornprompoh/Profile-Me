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
│   ├── main.dart                    # จุดเริ่มต้นแอปพลิเคชัน
│   ├── app/
│   │   ├── app_bootstrap.dart       # สร้างค่าเริ่มต้นของแอป
│   │   └── portfolio_app.dart       # ประกอบ MaterialApp และ Theme
│   ├── core/
│   │   ├── l10n/app_strings.dart    # ข้อความ UI คงที่สองภาษา
│   │   ├── state/
│   │   │   ├── app_state.dart       # ValueNotifier ของแอป
│   │   │   └── app_state_scope.dart # เข้าถึงสถานะจาก UI
│   │   ├── storage/local_storage_service.dart # ภาษา/ธีมใน localStorage
│   │   └── theme/
│   │       ├── app_colors.dart      # ชุดสี Ocean Wave
│   │       ├── app_theme.dart       # Light/Dark Theme
│   │       └── layout_tokens.dart   # Breakpoints และ Layout Tokens
│   ├── data/
│   │   ├── models/
│   │   │   ├── content_models.dart  # จุด export รวม Model
│   │   │   ├── education_model.dart # ประวัติการศึกษา
│   │   │   ├── experience_model.dart # ประสบการณ์ทำงาน
│   │   │   ├── links_model.dart      # ลิงก์โซเชียล/โครงการ
│   │   │   ├── localized_text.dart   # ข้อความไทย/อังกฤษ
│   │   │   ├── profile_language_model.dart # ภาษาที่ใช้และระดับ
│   │   │   ├── profile_model.dart    # ข้อมูลโปรไฟล์รวม
│   │   │   ├── project_model.dart    # ข้อมูลและการเรียงผลงาน
│   │   │   └── skill_group_model.dart # กลุ่มทักษะ
│   │   └── repositories/
│   │       └── content_repository.dart # โหลด JSON เป็น Models
│   ├── services/
│   │   └── pdf/
│   │       └── resume_pdf_service.dart # สร้างและดาวน์โหลด Resume PDF
│   └── presentation/
│       ├── portfolio_ui.dart        # รวม UI parts ใน Presentation layer
│       ├── pages/
│       │   ├── portfolio_page.dart    # ประกอบหน้า Portfolio
│       │   └── portfolio_scroll_controller.dart # Scroll Spy/Smooth Scroll
│       ├── navigation/
│       │   ├── mobile_drawer.dart # เมนูนำทางบนมือถือ
│       │   └── portfolio_navigation.dart # Sticky Navbar และ Resume Button
│       ├── modals/
│       │   ├── all_projects_modal.dart # หน้าต่างผลงานทั้งหมด
│       │   ├── category_filter_bar.dart # ตัวกรองหมวดแนวนอน
│       │   ├── image_lightbox_dialog.dart # แสดงภาพขยาย/ซูม
│       │   └── project_modals.dart    # รายละเอียดโครงการ
│       ├── sections/
│       │   ├── about/
│       │   │   ├── about_photo_card.dart # รูปใน About
│       │   │   ├── about_section.dart # ประกอบ Section About
│       │   │   └── about_skills_grid.dart # การ์ดทักษะ
│       │   ├── footer/footer_section.dart # ช่องทางติดต่อและลิขสิทธิ์
│       │   ├── hero/
│       │   │   ├── hero_ocean_backdrop.dart # พื้นหลังและลายน้ำ
│       │   │   ├── hero_profile_card.dart # รูป/แกลเลอรีโปรไฟล์
│       │   │   └── hero_section.dart    # ประกอบ Section Hero
│       │   ├── projects/
│       │   │   ├── project_card.dart    # การ์ดโครงการ
│       │   │   └── projects_section.dart # ตัวกรองและ Grid
│       │   └── timeline/timeline_section.dart # เส้นเวลา
│       └── widgets/
│           ├── back_to_top_button.dart # ปุ่มกลับด้านบน
│           ├── brand_logo.dart           # Brand icon beside Pornprom # ปุ่มกลับด้านบน
│           ├── brand_logo.dart           # ไอคอนแบรนด์ด้านชื่อ Pornprom # ปุ่มกลับด้านบน
│           ├── brand_icon.dart          # ไอคอนแบรนด์
│           ├── ocean_wave_divider.dart  # ตัวแบ่งคลื่นทะเล
│           ├── project_link_button.dart # ลิงก์โครงการ
│           ├── reveal_effects.dart      # Reveal/Hover effects
│           └── section_widgets.dart     # Container และ Header กลาง
├── assets/my_content/
│   ├── profile/profile.json
│   ├── projects/projects.json
│   ├── links/links.json
│   ├── images/
│   └── fonts/Sarabun-*.ttf
├── web/
├── .github/
├── scripts/
├── vercel.json
└── pubspec.yaml
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

## คู่มือ Deploy

ดูขั้นตอน GitHub Actions CI และการตั้งค่า Production บน Vercel ที่ [DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md)

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
│   ├── main.dart                    # Application entry point
│   ├── app/
│   │   ├── app_bootstrap.dart       # Creates initial app state
│   │   └── portfolio_app.dart       # MaterialApp and theme wiring
│   ├── core/
│   │   ├── l10n/app_strings.dart    # Static localized UI strings
│   │   ├── state/
│   │   │   ├── app_state.dart       # App ValueNotifiers
│   │   │   └── app_state_scope.dart # Access shared state from UI
│   │   ├── storage/local_storage_service.dart # Locale/theme persistence
│   │   └── theme/
│   │       ├── app_colors.dart      # Ocean Wave palette
│   │       ├── app_theme.dart       # Light/Dark Theme
│   │       └── layout_tokens.dart   # Breakpoints and layout tokens
│   ├── data/
│   │   ├── models/
│   │   │   ├── content_models.dart  # Model export barrel
│   │   │   ├── education_model.dart # Education records
│   │   │   ├── experience_model.dart # Work experience
│   │   │   ├── links_model.dart      # Social and project links
│   │   │   ├── localized_text.dart   # Thai/English text
│   │   │   ├── profile_language_model.dart # Languages and proficiency
│   │   │   ├── profile_model.dart    # Combined profile data
│   │   │   ├── project_model.dart    # Project data and sorting
│   │   │   └── skill_group_model.dart # Skill groups
│   │   └── repositories/
│   │       └── content_repository.dart # JSON loading and model mapping
│   ├── services/
│   │   └── pdf/
│   │       └── resume_pdf_service.dart # Resume PDF generation/download
│   └── presentation/
│       ├── portfolio_ui.dart        # Presentation-layer UI parts library
│       ├── pages/
│       │   ├── portfolio_page.dart    # Portfolio page composition
│       │   └── portfolio_scroll_controller.dart # Scroll Spy/Smooth Scroll
│       ├── navigation/
│       │   ├── mobile_drawer.dart # Mobile navigation drawer
│       │   └── portfolio_navigation.dart # Sticky Navbar and Resume Button
│       ├── modals/
│       │   ├── all_projects_modal.dart # All projects dialog
│       │   ├── category_filter_bar.dart # Horizontal category filter
│       │   ├── image_lightbox_dialog.dart # Zoomable image viewer
│       │   └── project_modals.dart    # Project details dialog
│       ├── sections/
│       │   ├── about/
│       │   │   ├── about_photo_card.dart # About portrait
│       │   │   ├── about_section.dart # About section composition
│       │   │   └── about_skills_grid.dart # Skills card
│       │   ├── footer/footer_section.dart # Contact and copyright
│       │   ├── hero/
│       │   │   ├── hero_ocean_backdrop.dart # Ocean background and watermark
│       │   │   ├── hero_profile_card.dart # Profile portrait/gallery
│       │   │   └── hero_section.dart    # Hero section composition
│       │   ├── projects/
│       │   │   ├── project_card.dart    # Project card
│       │   │   └── projects_section.dart # Filters and responsive grid
│       │   └── timeline/timeline_section.dart # Timeline section
│       └── widgets/
│           ├── back_to_top_button.dart # Back-to-top control
│           ├── brand_icon.dart          # Brand icons
│           ├── ocean_wave_divider.dart  # Ocean divider
│           ├── project_link_button.dart # Project link control
│           ├── reveal_effects.dart      # Reveal/hover effects
│           └── section_widgets.dart     # Shared section container/header
├── assets/my_content/
│   ├── profile/profile.json
│   ├── projects/projects.json
│   ├── links/links.json
│   ├── images/
│   └── fonts/Sarabun-*.ttf
├── web/
├── .github/
├── scripts/
├── vercel.json
└── pubspec.yaml
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
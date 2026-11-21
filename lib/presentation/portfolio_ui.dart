/// หน้าที่หลัก: ประกาศ UI library สำหรับส่วนต่าง ๆ ของหน้า Portfolio
library;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/l10n/app_strings.dart';
import '../core/state/app_state.dart';
import '../core/state/app_state_scope.dart';
import '../core/storage/local_storage_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/layout_tokens.dart';
import '../data/models/content_models.dart';
import '../data/repositories/content_repository.dart';
import '../services/pdf/resume_pdf_service.dart';
import 'modals/all_projects_modal.dart';
import 'pages/portfolio_scroll_controller.dart';
import 'widgets/brand_icon.dart';
import 'widgets/project_link_button.dart';
import 'widgets/section_widgets.dart';

part 'navigation/portfolio_navigation.dart';
part 'navigation/mobile_drawer.dart';
part 'pages/portfolio_page.dart';
part 'widgets/reveal_effects.dart';
part 'widgets/ocean_wave_divider.dart';
part 'sections/hero/hero_section.dart';
part 'sections/hero/hero_ocean_backdrop.dart';
part 'sections/hero/hero_profile_card.dart';
part 'sections/about/about_section.dart';
part 'sections/about/about_photo_card.dart';
part 'sections/about/about_skills_grid.dart';
part 'sections/timeline/timeline_section.dart';
part 'sections/projects/projects_section.dart';
part 'sections/projects/project_card.dart';
part 'modals/project_modals.dart';
part 'modals/image_lightbox_dialog.dart';
part 'sections/footer/footer_section.dart';
part 'widgets/back_to_top_button.dart';

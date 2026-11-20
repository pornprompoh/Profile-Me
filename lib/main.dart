import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/state/app_state.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'data/models/content_models.dart';
import 'data/repositories/content_repository.dart';
import 'presentation/modals/all_projects_modal.dart';
import 'core/theme/layout_tokens.dart';
import 'presentation/widgets/section_widgets.dart';
import 'presentation/widgets/project_link_button.dart';
import 'services/pdf/resume_pdf_service.dart';
import 'app/app_bootstrap.dart';

part 'app/portfolio_app.dart';
part 'presentation/pages/portfolio_page.dart';
part 'presentation/navigation/portfolio_navigation.dart';
part 'presentation/widgets/reveal_effects.dart';
part 'presentation/sections/hero/hero_section.dart';
part 'presentation/sections/about/about_section.dart';
part 'presentation/sections/timeline/timeline_section.dart';
part 'presentation/sections/projects/projects_section.dart';
part 'presentation/modals/project_modals.dart';
part 'presentation/sections/contact/contact_footer.dart';

// หน้าที่หลัก: จุดเริ่มต้นของแอปพลิเคชัน
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PortfolioApp());
}

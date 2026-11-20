import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BrandIcon extends StatelessWidget {
  const BrandIcon({required this.name, this.size = 18, super.key});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalized = name.toLowerCase();
    final FaIconData icon;
    Color? color;

    if (normalized.contains('github')) {
      icon = FontAwesomeIcons.github;
    } else if (normalized.contains('facebook')) {
      icon = FontAwesomeIcons.facebookF;
      color = const Color(0xFF1877F2);
    } else if (normalized.contains('instagram')) {
      icon = FontAwesomeIcons.instagram;
    } else if (normalized.contains('youtube')) {
      icon = FontAwesomeIcons.youtube;
    } else if (normalized.contains('linkedin')) {
      icon = FontAwesomeIcons.linkedinIn;
    } else {
      return Icon(Icons.link, size: size);
    }

    return FaIcon(icon, size: size, color: color);
  }
}

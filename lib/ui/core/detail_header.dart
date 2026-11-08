import 'package:flutter/material.dart';
import 'package:player/theme_data/neo_style.dart';

/// Shared responsive identity panel for album, artist and playlist details.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.artwork,
    this.onSubtitleTap,
    this.action,
  });
  final String title;
  final String subtitle;
  final Widget artwork;
  final VoidCallback? onSubtitleTap;
  final Widget? action;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 600;
      final imageSize = wide
          ? 180.0
            : (constraints.maxWidth - 80).clamp(0.0, 220.0);
      final image = SizedBox(
        width: imageSize,
        height: imageSize,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: artwork,
        ),
      );
      final info = Column(
        crossAxisAlignment: wide
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onSubtitleTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                subtitle,
                textAlign: wide ? TextAlign.start : TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      );
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Container(
          decoration: NeoStyle.raised(context, radius: 24),
          padding: const EdgeInsets.all(20),
          child: Material(
            type: MaterialType.transparency,
            child: wide
                ? Row(
                    children: [
                      image,
                      const SizedBox(width: 24),
                      Expanded(child: info),
                    ],
                  )
                : Column(children: [image, const SizedBox(height: 20), info]),
          ),
        ),
      );
    },
  );
}

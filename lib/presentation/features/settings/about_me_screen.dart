import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/presentation/providers/locale_provider.dart';

class AboutMeScreen extends ConsumerStatefulWidget {
  const AboutMeScreen({super.key});

  @override
  ConsumerState<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends ConsumerState<AboutMeScreen> {
  String _markdownData = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  Future<void> _loadMarkdown() async {
    try {
      final locale = ref.read(localeProvider);
      final langCode = locale.languageCode;

      String assetPath = 'assets/legal/about_me_en.md';
      if (langCode == 'es') {
        assetPath = 'assets/legal/about_me_es.md';
      } else if (langCode == 'ca') {
        assetPath = 'assets/legal/about_me_ca.md';
      }

      final data = await rootBundle.loadString(assetPath);
      setState(() {
        _markdownData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _markdownData = AppLocalizations.of(context)!.errorLoadingContent;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://github.com/CarlesPV');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorCouldNotLaunchUrl),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutMe)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Markdown(
                      data: _markdownData,
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          launchUrl(Uri.parse(href));
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: _launchUrl,
                      icon: const Icon(Icons.open_in_new),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.aboutMeGithubButton),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

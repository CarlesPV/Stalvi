import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:stalvi/core/l10n/app_localizations.dart';

/// A premium, stateless presentation viewer for legal texts (Terms and Conditions / Privacy Policy).
///
/// It reads markdown files from local assets and parses them into styled Flutter widgets dynamically
/// to prevent displaying raw markdown syntax (since a markdown package is not explicitly imported).
class TermsAndConditionsViewer extends StatelessWidget {
  /// Whether to initialize the viewer showing the Privacy Policy.
  final bool showPrivacyPolicy;

  const TermsAndConditionsViewer({
    super.key,
    this.showPrivacyPolicy = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final localeCode = Localizations.localeOf(context).languageCode;
    const supportedCodes = ['en', 'es', 'ca'];
    final lang = supportedCodes.contains(localeCode) ? localeCode : 'en';

    final title = showPrivacyPolicy
        ? (l10n?.privacyPolicy ?? 'Privacy Policy')
        : (l10n?.termsAndConditions ?? 'Terms and Conditions');

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _LegalDocumentView(
        assetPath: showPrivacyPolicy
            ? 'assets/legal/privacy_$lang.md'
            : 'assets/legal/terms_$lang.md',
        fallbackContent: showPrivacyPolicy
            ? _getPrivacyFallback(lang)
            : _getTermsFallback(lang),
      ),
    );
  }

  // --- Fallback raw strings in case assets are not accessible ---

  String _getTermsFallback(String lang) {
    if (lang == 'es') {
      return '# Términos y Condiciones\n\n'
          'Bienvenido a Stalvi. Estos Términos y Condiciones rigen el uso de la aplicación móvil sin conexión Stalvi. Al crear un perfil y usar esta aplicación, aceptas estos términos.\n\n'
          '## 1. Almacenamiento Local First\n'
          '* **Datos Locales**: Stalvi almacena todos tus datos financieros, cuentas, transacciones y categorías localmente en tu dispositivo.\n'
          '* **Seguridad y Cifrado**: Tus datos están protegidos en el dispositivo mediante el cifrado de base de datos SQLCipher y Flutter Secure Storage.\n\n'
          '## 2. Responsabilidad del Usuario\n'
          '* **Copia de Seguridad**: Dado que Stalvi es una aplicación local-first y no sube tus datos a ningún servidor remoto, eres el único responsable de realizar copias de seguridad de tu dispositivo y archivos de base de datos.\n'
          '* **Pérdida de Datos**: Si pierdes tu dispositivo o lo reinicias sin una copia de seguridad, tus registros financieros no se podrán recuperar.\n\n'
          '## 3. Privacidad\n'
          'No recopilamos, transmitimos ni vendemos tus datos personales o financieros. Tus datos te pertenecen por completo.\n\n'
          '## 4. Actualizaciones de los Términos\n'
          'Nos reservamos el derecho de actualizar estos términos en cualquier momento. El uso continuado de la aplicación constituye la aceptación de los términos actualizados.';
    } else if (lang == 'ca') {
      return '# Termes i Condicions\n\n'
          'Benvingut a Stalvi. Aquests Termes i Condicions regeixen l\'ús de l\'aplicació mòbil sense connexió Stalvi. Al crear un perfil i utilitzar aquesta aplicació, acceptes aquests termes.\n\n'
          '## 1. Emmagatzematge Local First\n'
          '* **Dades Locals**: Stalvi emmagatzema totes les teves dades financeres, comptes, transaccions i categories localment al teu dispositiu.\n'
          '* **Seguretat i Xifratge**: Les teves dades estan protegides al dispositiu mitjançant el xifratge de base de dades SQLCipher i Flutter Secure Storage.\n\n'
          '## 2. Responsabilitat de l\'Usuari\n'
          '* **Còpia de Seguretat**: Com que Stalvi és una aplicació local-first i no puja les teves dades a cap servidor remot, ets l\'únic responsable de fer còpies de seguretat del teu dispositiu i fitxers de base de dades.\n'
          '* **Pèrdua de Dades**: Si perds el dispositiu o el reinicies sense una còpia de seguretat, els teus registres financers no es podran recuperar.\n\n'
          '## 3. Privacitat\n'
          'No recopilem, transmetem ni venem les teves dades personals o financeres. Les teves dades et pertanyen per complet.\n\n'
          '## 4. Actualitzacions dels Termes\n'
          'Ens reservem el dret d\'actualitzar aquests termes en qualsevol moment. L\'ús continuat de l\'aplicació constitueix l\'acceptació dels termes actualitzats.';
    }
    return '# Terms and Conditions\n\n'
        'Welcome to Stalvi. These Terms and Conditions govern your use of the Stalvi offline mobile application. By creating a profile and using this application, you agree to these terms.\n\n'
        '## 1. Local-First Storage\n'
        '* **Local Data**: Stalvi stores all your financial data, accounts, transactions, and categories locally on your device.\n'
        '* **Security & Encryption**: Your data is secured on-device using SQLCipher database encryption and Flutter Secure Storage.\n\n'
        '## 2. User Responsibility\n'
        '* **Device Backup**: Since Stalvi is a local-first application and does not upload your data to any remote server, you are solely responsible for backing up your device and database files.\n'
        '* **Loss of Data**: If you lose your device or reset it without a backup, your financial records cannot be recovered.\n\n'
        '## 3. Privacy\n'
        'We do not collect, transmit, or sell your personal or financial data. Your data belongs entirely to you.\n\n'
        '## 4. Updates to Terms\n'
        'We reserve the right to update these terms at any time. Your continued use of the application constitutes acceptance of any updated terms.';
  }

  String _getPrivacyFallback(String lang) {
    if (lang == 'es') {
      return '# Política de Privacidad\n\n'
          'Tu privacidad es extremadamente importante para nosotros. Esta Política de Privacidad explica cómo Stalvi maneja tu información.\n\n'
          '## 1. Cero Recopilación de Datos\n'
          '* **Datos Personales**: No recopilamos ningún dato personal como nombre, nombre de usuario o información de contacto.\n'
          '* **Datos Financieros**: Todos los registros de transacciones, saldos de cuentas y presupuestos se guardan estrictamente en tu dispositivo. No tenemos un servidor central y no tenemos acceso a tus datos financieros.\n\n'
          '## 2. Seguridad\n'
          '* **Autenticación del Dispositivo**: Stalvi utiliza el PIN del dispositivo y la autenticación biométrica (huella dactilar o FaceID) para asegurar el acceso a la aplicación.\n'
          '* **Cifrado**: La base de datos local está cifrada con SQLCipher utilizando una clave criptográfica generada y almacenada de forma segura en el llavero/Keystore del dispositivo.\n\n'
          '## 3. Servicios de Terceros\n'
          'No utilizamos herramientas de seguimiento, análisis ni SDK de publicidad de terceros que recopilen o compartan tus datos.\n\n'
          '## 4. Contacto\n'
          'Si tienes alguna pregunta o comentario sobre nuestras prácticas de privacidad, puedes contactarnos en privacy@stalvi.app.';
    } else if (lang == 'ca') {
      return '# Política de Privacitat\n\n'
          'La teva privacitat és extremadament important per a nosaltres. Aquesta Política de Privacitat explica com Stalvi gestiona la teva informació.\n\n'
          '## 1. Zero Recopilació de Dades\n'
          '* **Dades Personales**: No recopilem cap dada personal com el nom, nom d\'usuari o informació de contacte.\n'
          '* **Dades Financeres**: Tots els registres de transaccions, saldos de comptes i pressupostos es guarden estrictament al teu dispositiu. No tenim cap servidor central i no tenim accés a les teves dades financeres.\n\n'
          '## 2. Seguretat\n'
          '* **Autenticació del Dispositiu**: Stalvi utilitza el PIN del dispositiu i l\'autenticació biomètrica (petjada digital o FaceID) per assegurar l\'accés a l\'aplicació.\n'
          '* **Xifratge**: La base de datos local està xifrada amb SQLCipher utilitzant una clau criptogràfica generada i emmagatzemada de forma segura al clauer/Keystore del dispositiu.\n\n'
          '## 3. Serveis de Tercers\n'
          'No utilitzem eines de seguiment, anàlisi ni SDK de publicitat de tercers que recopilin o comparteixin les teves dades.\n\n'
          '## 4. Contacte\n'
          'Si tens algun dubte o comentari sobre les nostres pràctiques de privacitat, pots contactar amb nosaltres a privacy@stalvi.app.';
    }
    return '# Privacy Policy\n\n'
        'Your privacy is extremely important to us. This Privacy Policy explains how Stalvi handles your information.\n\n'
        '## 1. Zero Data Collection\n'
        '* **Personal Data**: We do not collect any personal data such as name, username, or contact information.\n'
        '* **Financial Data**: All transaction logs, account balances, and budgets are kept strictly on your device. We have no backend server and no access to your financial data.\n\n'
        '## 2. Security\n'
        '* **Device Authentication**: Stalvi uses device PIN and biometric authentication (Fingerprint or FaceID) to secure access to the app.\n'
        '* **Encryption**: The local database is encrypted using SQLCipher with a cryptographic key generated and stored securely in the device\'s keychain/Keystore.\n\n'
        '## 3. Third-Party Services\n'
        'We do not use any tracking tools, analytics, or third-party advertising SDKs that collect or share your data.\n\n'
        '## 4. Contact Us\n'
        'If you have any questions or feedback regarding our privacy practices, you can contact us at privacy@stalvi.app.';
  }
}

class _LegalDocumentView extends StatelessWidget {
  final String assetPath;
  final String fallbackContent;

  const _LegalDocumentView({
    required this.assetPath,
    required this.fallbackContent,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future:
          rootBundle.loadString(assetPath).catchError((_) => fallbackContent),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final content = snapshot.data ?? fallbackContent;
        final parsedWidgets = _parseMarkdown(content, context);

        return Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: parsedWidgets,
            ),
          ),
        );
      },
    );
  }

  /// Custom lightweight line-by-line Markdown parsing utility.
  ///
  /// Maps headers (#, ##, ###), lists (*, -), empty lines, and normal text to
  /// rich styled widgets without outputting raw markup characters.
  List<Widget> _parseMarkdown(String markdown, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lines = markdown.split('\n');
    final widgets = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('# ')) {
        // Main Header (H1)
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 10),
            child: Text(
              line.substring(2),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        // Section Header (H2)
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Text(
              line.substring(3),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: -0.2,
              ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        // Sub Header (H3)
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Text(
              line.substring(4),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        );
      } else if (line.startsWith('* ') || line.startsWith('- ')) {
        // List Item
        final text = line.substring(2);
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7, right: 10),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildFormattedText(text, theme, colorScheme),
                ),
              ],
            ),
          ),
        );
      } else {
        // Regular Paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildFormattedText(line, theme, colorScheme),
          ),
        );
      }
    }

    return widgets;
  }

  /// Formats text containing simple markdown elements like bolding (`**text**`).
  Widget _buildFormattedText(
    String text,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final regex = RegExp(r'\*\*(.*?)\*\*');
    final matches = regex.allMatches(text);
    if (matches.isEmpty) {
      return Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      );
    }

    final spans = <TextSpan>[];
    var start = 0;
    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      );
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }
}

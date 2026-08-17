import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';

/// A premium presentation viewer for legal texts (Terms and Conditions / Privacy Policy).
///
/// Loads Markdown legal documents from local assets for the active language ('en', 'es', 'ca')
/// and parses them into responsive, styled, scrollable widgets.
class TermsAndConditionsViewer extends StatelessWidget {
  /// Whether to display the Privacy Policy instead of Terms and Conditions.
  final bool showPrivacyPolicy;

  const TermsAndConditionsViewer({super.key, this.showPrivacyPolicy = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final localeCode = Localizations.localeOf(context).languageCode;
    const supportedCodes = ['en', 'es', 'ca'];
    final lang = supportedCodes.contains(localeCode) ? localeCode : 'en';

    final termsTitle = l10n?.termsAndConditions ?? 'Terms and Conditions';
    final privacyTitle = l10n?.privacyPolicy ?? 'Privacy Policy';
    final currentTitle = showPrivacyPolicy ? privacyTitle : termsTitle;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          currentTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: showPrivacyPolicy
          ? _LegalDocumentView(
              key: const Key('privacy_policy_view'),
              assetPath: 'assets/legal/privacy_$lang.md',
              fallbackContent: _getPrivacyFallback(lang),
            )
          : _LegalDocumentView(
              key: const Key('terms_and_conditions_view'),
              assetPath: 'assets/legal/terms_$lang.md',
              fallbackContent: _getTermsFallback(lang),
            ),
    );
  }

  // --- Fallback strings with complete legal content in 3 supported languages ---

  static String _getTermsFallback(String lang) {
    if (lang == 'es') {
      return '''# Términos y Condiciones de Uso

**Fecha de entrada en vigor:** 17 de agosto de 2026

Lea detenidamente estos Términos y Condiciones ("Términos", "Acuerdo") antes de descargar, instalar, acceder o utilizar la aplicación móvil Stalvi (la "Aplicación" o "App").

Este Acuerdo constituye un contrato legalmente vinculante entre usted (el "Usuario", "usted" o "su") y los desarrolladores y operadores de Stalvi ("Stalvi", "nosotros", "nuestro" o "nuestros").

Al descargar, instalar, abrir, acceder o utilizar la Aplicación, usted reconoce explícitamente, declara y garantiza que ha leído, comprendido y acepta estar sujeto a todos los términos, condiciones, exenciones de responsabilidad y obligaciones establecidas en el presente documento. Si no está de acuerdo con la totalidad de estos Términos, no está autorizado para acceder ni utilizar la Aplicación y debe desinstalarla y eliminarla de inmediato y de forma permanente de su dispositivo.

---

## 1. Descripción del Servicio y Funcionalidad Principal
Stalvi es una herramienta de gestión financiera personal centrada en la privacidad y diseñada bajo una arquitectura local (*local-first*). Permite a los usuarios registrar, categorizar, supervisar y analizar sus ingresos, gastos, presupuestos, objetivos de ahorro y transacciones recurrentes directamente en sus dispositivos móviles personales.

---

## 2. Arquitectura Local-First y Cifrado SQLCipher
- **Almacenamiento Exclusivamente Local:** Stalvi funciona bajo una estricta **arquitectura local (*local-first*)**. Todos los registros de transacciones, saldos de cuentas, presupuestos, categorías, resúmenes de PIN y preferencias se almacenan exclusivamente en su dispositivo. Stalvi no transmite, respalda, sincroniza, almacena ni procesa sus datos financieros en servidores externos o servicios en la nube.
- **Cifrado SQLCipher AES-256:** La base de datos SQLite subyacente se cifra en reposo mediante **SQLCipher con cifrado AES de 256 bits**. Las claves criptográficas están protegidas mediante interfaces de almacenamiento seguro del sistema respaldadas por hardware nativo (Android KeyStore / iOS Keychain a través de `flutter_secure_storage`).
- **Sin Acceso Remoto ni Puertas Traseras:** Los desarrolladores no tienen ningún acceso a su dispositivo, a su PIN, a sus claves de cifrado ni a su base de datos.

---

## 3. Procesamiento en Segundo Plano y Tareas Automatizadas de WorkManager
- **Ejecución en Segundo Plano en el Dispositivo:** Stalvi utiliza mecanismos de ejecución en segundo plano del sistema (**WorkManager** en Android, **BGTaskScheduler** en iOS) para ejecutar tareas automatizadas localmente sin necesidad de que el usuario abra la aplicación.
- **Alcance del Trabajo en Segundo Plano:** La ejecución en segundo plano se limita a:
  1. Procesar de forma transparente e idempotente las transacciones recurrentes programadas para actualizar el libro contable sin duplicados.
  2. Actualizar las fuentes de respaldo de tipos de cambio de divisas cuando se detecte una conexión activa a Internet.
  3. Programar notificaciones locales para pagos pendientes o recordatorios de facturas.
- **Exención sobre la Programación del SO:** El momento exacto de ejecución de las tareas en segundo plano está sujeto a las políticas de optimización de batería del sistema operativo. Stalvi no garantiza la ejecución al minuto exacto de dichas tareas.

---

## 4. Exención de Responsabilidad Financiera, Fiscal y de Divisas (Cero Responsabilidad)

### 4.1. Herramienta Exclusivamente Informativa y de Registro Personal
STALVI ES UNA APLICACIÓN PURAMENTE INFORMATIVA, DE REGISTRO DE DATOS PERSONALES Y SEGUIMIENTO ESTADÍSTICO. STALVI NO ES UN BANCO, INSTITUCIÓN FINANCIERA, ASESOR DE INVERSIONES, CONTADOR PÚBLICO NI SERVICIO DE ASESORÍA FISCAL.

NI LA APLICACIÓN NI SUS DESARROLLADORES PRESTAN ASESORAMIENTO LEGAL, FISCAL, CONTABLE, DE INVERSIÓN, HIPOTECARIO, CREDITICIO O FINANCIERO DE NINGÚN TIPO. NINGÚN CONTENIDO, CÁLCULO, RESUMEN, GRÁFICO, INFORME O ESTADÍSTICA PRODUCIDO POR LA APLICACIÓN DEBERÁ INTERPRETARSE COMO PLANIFICACIÓN FINANCIERA O ASESORAMIENTO PROFESIONAL.

### 4.2. Cero Responsabilidad por Pérdidas Financieras, Pérdida de Datos y Errores de Cálculo
USTED RECONOCE Y ACEPTA EXPRESAMENTE QUE LOS DESARROLLADORES, MANTENEDORES Y PROPIETARIOS DE STALVI ASUMEN **CERO RESPONSABILIDAD Y CERO OBLIGACIÓN** BAJO CUALQUIER CIRCUNSTANCIA POR CUALQUIER:
- PÉRDIDA FINANCIERA, GASTO INESPERADO, SOBREGIRO BANCARIO, COMISIÓN BANCARIA, DEUDA, ESTIMACIÓN PRESUPUESTARIA INEXACTA O DECISIÓN DE INVERSIÓN DESAFORTUNADA RESULTANTE DIRECTA O INDIRECTAMENTE DEL USO O DE LA CONFIANZA EN LA APLICACIÓN;
- PÉRDIDA DE DATOS, CORRUPCIÓN O INACCESIBILIDAD DE SU BASE DE DATOS DEBIDO A FALLAS DEL DISPOSITIVO, PIN OLVIDADO, ERRORES DE SOFTWARE O FALTA DE COPIAS DE SEGURIDAD;
- DISCREPANCIA DE CÁLCULO, ERROR DE REDONDEO, ERROR ALGORÍTMICO O COMPUTACIONAL EN LOS TOTALES DE TRANSACCIONES, SALDOS, GASTOS RECURRENTES O PROYECCIONES ESTADÍSTICAS;
- PROBLEMA FISCAL, ESTIMACIÓN INCORRECTA DE DEDUCCIONES FISCALES, OMISIÓN O DECLARACIÓN INEXACTA ANTE CUALQUIER AUTORIDAD TRIBUTARIA;
- INEXACTITUD, DESFASE O DISCREPANCIA EN LA CONVERSIÓN DE DIVISAS, TIPOS DE CAMBIO, CÁLCULOS MULTIDIVISA O CÁLCULOS DE TIPOS DE CAMBIO HISTÓRICOS.

USTED ES EL ÚNICO RESPONSABLE DE VERIFICAR LA EXACTITUD DE TODAS LAS TRANSACCIONES, CÁLCULOS Y DATOS FINANCIEROS CON LOS EXTRACTOS OFICIALES EMITIDOS POR SU BANCO O INSTITUCIÓN FINANCIERA.

---

## 5. Responsabilidad del Usuario y Copia de Seguridad de Datos
- **PIN o Autenticación Biométrica Olvidada:** Debido a que todos los datos están cifrados en el dispositivo con claves gestionadas por sus credenciales locales, si olvida su PIN o pierde el acceso biométrico, su base de datos será inaccesible e ilegible. **Los desarrolladores no pueden restablecer su PIN ni recuperar sus datos cifrados.**
- **Pérdida o Daño del Dispositivo:** Si su dispositivo se pierde, daña, roba, restablece de fábrica o si desinstala la App sin exportar previamente una copia de seguridad cifrada, sus datos financieros se perderán permanentemente.
- **Responsabilidad de Copia de Seguridad:** Usted es el único responsable de realizar copias de seguridad periódicas cifradas o exportaciones CSV y transferirlas a un almacenamiento externo seguro.

---

## 6. Política de Uso Aceptable y Conductas Prohibidas
Usted acepta utilizar la Aplicación únicamente para fines personales y legales, y en cumplimiento de todas las leyes locales, nacionales e internacionales aplicables.

Usted acepta explícitamente **NO**:
1. Utilizar la Aplicación para actividades financieras ilegales, fraudulentas o no autorizadas, incluyendo blanqueo de capitales, evasión de sanciones o fraude fiscal;
2. Descompilar, realizar ingeniería inversa, desmontar, descifrar, intentar derivar el código fuente o modificar la Aplicación, salvo en la medida permitida por las licencias de código abierto aplicables;
3. Eludir, desactivar o interferir con las funciones de seguridad de la Aplicación, incluida la verificación de PIN, protección biométrica, cifrado de base de datos o mecanismos de exportación;
4. Introducir virus, troyanos, malware o código malicioso que comprometa la integridad del dispositivo o de la base de datos;
5. Alquilar, arrendar, prestar, vender, sublicenciar, distribuir o explotar comercialmente la Aplicación o cualquier parte de la misma.

---

## 7. Concesión de Licencia y Propiedad Intelectual
Stalvi le otorga una licencia revocable, no exclusiva, intransferible, limitada y personal para instalar y utilizar la Aplicación en dispositivos compatibles de su propiedad o bajo su control.

Todos los derechos de propiedad intelectual, títulos e intereses en la Aplicación —incluidos el código, la arquitectura de software, el diseño UI/UX, temas visuales, gráficos, iconos, logotipos y documentación— siguen siendo propiedad exclusiva de Stalvi y sus licenciantes. Todos los derechos no concedidos expresamente quedan reservados.

---

## 8. Exención de Garantías ("TAL CUAL" y "SEGÚN DISPONIBILIDAD")
EN LA MEDIDA MÁXIMA PERMITIDA POR LA LEY APLICABLE, LA APLICACIÓN SE PROPORCIONA ESTRICTAMENTE **"TAL CUAL"** Y **"SEGÚN DISPONIBILIDAD"**, CON TODAS SUS POSIBLES FALLAS Y SIN GARANTÍA DE NINGÚN TIPO.

STALVI DESESTIMA TODA GARANTÍA, EXPRESA, IMPLÍCITA O LEGAL, INCLUYENDO GARANTÍAS IMPLÍCITAS DE COMERCIABILIDAD, CALIDAD SATISFACTORIA, IDONEIDAD PARA UN PROPÓSITO PARTICULAR, TÍTULO Y NO INFRACCIÓN. STALVI NO GARANTIZA QUE LA APLICACIÓN FUNCIONE DE FORMA ININTERRUMPIDA, SEGURA O LIBRE DE ERRORES.

---

## 9. Limitación de Responsabilidad
EN LA MEDIDA MÁXIMA PERMITIDA POR LA LEY APLICABLE, EN NINGÚN CASO STALVI, SUS DESARROLLADORES, AFILIADOS, DIRECTIVOS, AGENTES O PROVEEDORES SERÁN RESPONSABLES DE NINGÚN DAÑO DIRECTO, INDIRECTO, INCIDENTAL, ESPECIAL, PUNITIVO O CONSECUENTE (INCLUYENDO PÉRDIDAS DE GANANCIAS, DATOS, INGRESOS, AHORROS, INTERRUPCIÓN DE ACTIVIDAD O ERRORES DE CÁLCULO FINANCIERO) DERIVADO DEL USO O LA INCAPACIDAD DE USO DE LA APLICACIÓN.

---

## 10. Términos Específicos para App Store y Google Play Store
- **Términos de Apple App Store:** Usted reconoce que este Acuerdo se celebra únicamente entre usted y Stalvi, y no con Apple Inc. Apple no es responsable de la Aplicación ni de su contenido, mantenimiento o servicios de soporte. Apple no tiene obligación alguna de prestar servicios de mantenimiento o soporte con respecto a la Aplicación. En la máxima medida permitida por la ley, Apple no tendrá ninguna obligación de garantía con respecto a la Aplicación. Apple y las subsidiarias de Apple son terceros beneficiarios de este Acuerdo y tendrán derecho a hacer cumplir este Acuerdo contra usted.
- **Términos de Google Play Store:** Usted reconoce que Google LLC no es responsable de prestar mantenimiento, soporte o resolver reclamaciones relativas a la Aplicación.

---

## 11. Ley Aplicable y Jurisdicción
Estos Términos y el uso de la Aplicación se regirán e interpretarán de conformidad con las leyes de España y las regulaciones de la Unión Europea. Cualquier disputa o reclamación que surja de o en relación con este Acuerdo se someterá a la jurisdicción exclusiva de los tribunales competentes de España.

---

## 12. Divisibilidad, Modificaciones y Contacto
- **Divisibilidad:** Si alguna disposición de estos Términos se considera inválida o inaplicable, se modificará en la medida mínima necesaria y el resto permanecerá en pleno vigor.
- **Modificaciones:** Nos reservamos el derecho de actualizar estos Términos en cualquier momento. El uso continuado tras los cambios constituye la aceptación de los Términos modificados.
- **Contacto:** Para consultas legales, contacte al desarrollador en GitHub en:  
  [https://github.com/CarlesPV](https://github.com/CarlesPV)''';
    } else if (lang == 'ca') {
      return '''# Termes i Condicions d'Ús

**Data d'entrada en vigor:** 17 d'agost de 2026

Llegeix detingudament aquests Termes i Condicions ("Termes", "Acord") abans de descarregar, instal·lar, accedir o utilitzar l'aplicació mòbil Stalvi (l'"Aplicació" o "App").

Aquest Acord constitueix un contracte legalment vinculant entre tu (l'"Usuari", "tu" o "el teu") i els desenvolupadors i operadors de Stalvi ("Stalvi", "nosaltres", "nostre" o "nostres").

En descarregar, instal·lar, obrir, accedir o utilitzar l'Aplicació, reconeixes explícitament, declares i garanteixes que has llegit, entès i acceptes complir tots els termes, condicions, exempcions de responsabilitat i obligacions establertes en aquest document. Si no estàs d'acord amb la totalitat d'aquests Termes, no estàs autoritzat per accedir ni utilitzar l'Aplicació i has de desinstal·lar-la i eliminar-la immediatament i de forma permanent del teu dispositiu.

---

## 1. Descripció del Servei i Funcionalitat Principal
Stalvi és una eina de gestió financera personal centrada en la privadesa i dissenyada sota una arquitectura local (*local-first*). Permet als usuaris registrar, categoritzar, supervisar i analitzar els seus ingressos, despeses, pressupostos, objectius d'estalvi i transaccions recurrents directament en els seus dispositius mòbils personals.

---

## 2. Arquitectura Local-First i Xifratge SQLCipher
- **Emmagatzematge Exclusivament Local:** Stalvi funciona sota una estricta **arquitectura local (*local-first*)**. Tots els registres de transaccions, saldos de comptes, pressupostos, categories, resums de PIN i preferències s'emmagatzemen exclusivament al teu dispositiu. Stalvi no transmet, revalida, sincronitza, emmagatzema ni processa les teves dades financeres en servidors externs o serveis al núvol.
- **Xifratge SQLCipher AES-256:** La base de dades SQLite subadjacent es xifra en repòs mitjançant **SQLCipher amb xifratge AES de 256 bits**. Les claus criptogràfiques estan protegides mitjançant interfícies d'emmagatzematge segur del sistema mantingudes per hardware natiu (Android KeyStore / iOS Keychain a través de `flutter_secure_storage`).
- **Sense Accés Remot ni Portes del Darrere:** Els desenvolupadors no tenen cap accés al teu dispositiu, al teu PIN, les teves claus de xifratge ni la teva base de dades.

---

## 3. Processament en Segon Pla i Tasques Automatitzades de WorkManager
- **Execució en Segon Pla al Dispositiu:** Stalvi utilitza mecanismes d'execució en segon pla del sistema (**WorkManager** a Android, **BGTaskScheduler** a iOS) per executar tasques automatitzades localment sense necessitat que l'usuari obri l'aplicació.
- **Abast del Treball en Segon Pla:** L'execució en segon pla es limita a:
  1. Processar de forma transparent i idempotent les transaccions recurrents programades per actualitzar el llibre comptable sense duplicats.
  2. Actualitzar les fonts de suport de tipus de canvi de divises quan es detecti una connexió activa a Internet.
  3. Programar notificacions locals per a pagaments pendents o recordatoris de factures.
- **Exempció sobre la Programació de l'SO:** El moment exacte d'execució de les tasques en segon pla està subjecte a les polítiques d'optimització de bateria del sistema operatiu. Stalvi no garanteix l'execució al minut exacte de tals tasques.

---

## 4. Exempció de Responsabilitat Financera, Fiscal i de Divises (Zero Responsabilitat)

### 4.1. Eina Exclusivament Informativa i de Registre Personal
STALVI ÉS UNA APLICACIÓ PURAMENT INFORMATIVA, DE REGISTRE DE DADES PERSONALS I SEGUIMENT ESTADÍSTIC. STALVI NO ÉS UN BANC, INSTITUCIÓ FINANCERA, ASSESSOR D'INVERSIONS, COMPTABLE PÚBLIC NI SERVEI D'ASSESSORAMENT FISCAL.

NI L'APLICACIÓ NI ELS SEUS DESENVOLUPADORS PRESTEN ASSESSORAMENT LEGAL, FISCAL, COMPTABLE, D'INVERSIÓ, HIPOTECARI, CREDITICI O FINANCER DE CAP MENA. CAP CONTINGUT, CÀLCUL, RESUM, GRÀFIC, INFORME O ESTADÍSTICA PRODUÏDA PER L'APLICACIÓ S'HAURÀ D'INTERPRETAR COM A PLANIFICACIÓ FINANCERA O ASSESSORAMENT PROFESSIONAL.

### 4.2. Zero Responsabilitat per Pèrdues Financeres, Pèrdua de Dades i Errors de Càlcul
RECONEIXES I ACCEPTES EXPRESSEMENT QUE ELS DESENVOLUPADORS, MANTENIDORS I PROPIETARIS DE STALVI ASSUMEIXEN **ZERO RESPONSABILITAT I ZERO OBLIGACIÓ** SOTA QUALSEVOL CIRCUMSTÀNCIA PER QUALSEVOL:
- PÈRDUA FINANCERA, DESPESA INESPERADA, DESCOBERT BANCARI, COMISSIÓ BANCÀRIA, DEUTE, ESTIMACIÓ PRESSUPOSTÀRIA INEXACTA O DECISIÓ D'INVERSIÓ DESAFORTUNADA RESULTANT DIRECTAMENT O INDIRECTA DE L'ÚS O DE LA CONFIANÇA EN L'APLICACIÓ;
- PÈRDUA DE DADES, CORRUPCIÓ O INACCESSIBILITAT DE LA TEVA BASE DE DADES A CAUSA DE FALLADES DEL DISPOSITIU, PIN OBLIDAT, ERRORS DE PROGRAMARI O MANCA DE CÒPIES DE SEGURETAT;
- DISCREPÀNCIA DE CÀLCUL, ERROR D'ARRODONIMENT, ERROR ALGORÍTMIC O COMPUTACIONAL EN ELS TOTALS DE TRANSACCIONS, SALDOS, DESPESES RECURRENTS O PROJECCIONS ESTADÍSTIQUES;
- PROBLEMA FISCAL, ESTIMACIÓ INCORRECTA DE DEDUCCIONS FISCALS, OMISSIÓ O DECLARACIÓ INEXACTA DAVANT QUALSEVOL AUTORITAT TRIBUTÀRIA;
- INEXACTITUD, DESFASE O DISCREPÀNCIA EN LA CONVERSIÓ DE DIVISES, TIPUS DE CANVI, CÀLCULS MULTIDIVISA O CÀLCULS DE TIPUS DE CANVI HISTÒRICS.

ETS L'ÚNIC RESPONSIBLE DE VERIFICAR L'EXACTITUD DE TOTES LES TRANSACCIONS, CÀLCULS I DADES FINANCERES AMB ELS EXTRACTES OFICIALS EMESOS PEL TEU BANC O INSTITUCIÓ FINANCERA.

---

## 5. Responsabilitat de l'Usuari i Còpia de Seguretat de Dades
- **PIN o Autenticació Biomètrica Oblidada:** Atès que totes les dades estan xifrades al dispositiu amb claus gestionades per les teves credencials locals, si oblides el teu PIN o perds l'accés biomètric, la teva base de dades serà inaccessible i il·legible. **Els desenvolupadors no poden restablir el teu PIN ni recuperar les teves dades xifrades.**
- **Pèrdua o Dany del Dispositiu:** Si el teu dispositiu es perd, danya, roba, restableix de fàbrica o si desinstal·les l'App sense exportar prèviament una còpia de seguretat xifrada, les teves dades financeres es perdran permanentment.
- **Responsabilitat de Còpia de Seguretat:** Ets l'únic responsable de realitzar còpies de seguretat periòdiques xifrades o exportacions CSV i transferir-les a un emmagatzematge extern segur.

---

## 6. Política d'Ús Acceptable i Conductes Prohibides
Acceptes utilitzar l'Aplicació únicament per a finalitats personals i legals, i complint totes les lleis locals, nacionals i internacionals aplicables.

Acceptes explícitament **NO**:
1. Utilitzar l'Aplicació per a activitats financeres il·legals, fraudulentes o no autoritzades, incloent blanqueig de capitals, evasió de sancions o frau fiscal;
2. Descompilar, realitzar enginyeria inversa, desmuntar, desxifrar, intentar derivar el codi font o modificar l'Aplicació, excepte en la mesura permesa per les llicències de codi obert aplicables;
3. Eludir, desactivar o interferir amb les funcions de seguretat de l'Aplicació, inclosa la verificació de PIN, protecció biomètrica, xifratge de base de dades o mecanismes d'exportació;
4. Introduir virus, troians, programari maliciós o codi maliciós que comprometi la integritat del dispositiu o de la base de dades;
5. Llogar, arrendar, prestar, vendre, subllicenciar, distribuir o explotar comercialment l'Aplicació o qualsevol part d'aquesta.

---

## 7. Concessió de Llicència i Propietat Intel·lectual
Stalvi et concedeix una llicència revocable, no exclusiva, intransferible, limitada i personal per instal·lar i utilitzar l'Aplicació en dispositius compatibles de la teva propietat o sota el teu control.

Tots els drets de propietat intel·lectual, títols i interessos en l'Aplicació —inclosos el codi, l'arquitectura de programari, el disseny UI/UX, temes visuals, gràfics, icones, logotips i documentació— continuen sent propietat exclusiva de Stalvi i els seus llicenciants. Tots els drets no concedits expressament queden reservats.

---

## 8. Exempció de Garanties ("TAL QUAL" i "SEGONS DISPONIBILITAT")
EN LA MESURA MÀXIMA PERMESA PER LA LLEI APLICABLE, L'APLICACIÓ ES PROPORCIONA ESTRICTAMENT **"TAL QUAL"** I **"SEGONS DISPONIBILITAT"**, AMB TOTES LES SEVES POSSIBLES FALTES I SENSE GARANTIA DE CAP MENA.

STALVI DESESTIMA TOTA GARANTIA, EXPRESSA, IMPLÍCITA O LEGAL, INCLOENT GARANTIES IMPLÍCITES DE COMERCIABILITAT, QUALITAT SATISFACTÒRIA, IDONEÏTAT PER A UNA FINALITAT PARTICULAR, TÍTOL I NO INFRACCIÓ. STALVI NO GARANTEIX QUE L'APLICACIÓ FUNCIONI DE FORMA ININTERROMPUDA, SEGURA O LLIURE D'ERRORS.

---

## 9. Limitació de Responsabilitat
EN LA MESURA MÀXIMA PERMESA PER LA LLEI APLICABLE, EN CAP CAS STALVI, ELS SEUS DESENVOLUPADORS, AFILIATS, DIRECTIUS, AGENTS O PROVEÏDORS SERAN RESPONSABLES DE CAP DANY DIRECTE, INDIRECTE, INCIDENTAL, ESPECIAL, PUNITIU O CONSEQÜENT (INCLOENT PÈRDUES DE GUANYS, DADES, INGRESSOS, ESTALVIS, INTERRUPCIÓ D'ACTIVITAT O ERRORS DE CÀLCUL FINANCER) DERIVAT DE L'ÚS O LA INCAPACITAT D'ÚS DE L'APLICACIÓ.

---

## 10. Termes Específics per a l'App Store i Google Play Store
- **Termes de l'Apple App Store:** Reconeixes que aquest Acord es celebra únicament entre tu i Stalvi, i no amb Apple Inc. Apple no és responsable de l'Aplicació ni del seu contingut, manteniment o serveis de suport. Apple no té cap obligació de prestar serveis de manteniment o suport respecte a l'Aplicació. En la màxima mesura permesa per la llei, Apple no tindrà cap obligació de garantia respecte a l'Aplicació. Apple i les subsidiàries d'Apple són tercers beneficiaris d'aquest Acord i tindran dret a fer complir aquest Acord contra tu.
- **Termes de Google Play Store:** Reconeixes que Google LLC no és responsable de prestar manteniment, suport o resoldre reclamacions relatives a l'Aplicació.

---

## 11. Llei Aplicable i Jurisdicció
Aquests Termes i l'ús de l'Aplicació es regiran i interpretaran de conformitat amb les lleis d'Espanya i les regulacions de la Unió Europea. Qualsevol disputa o reclamació que sorgeixi de o en relació amb aquest Acord es sotmetrà a la jurisdicció exclusiva dels tribunals competents d'Espanya.

---

## 12. Divisibilitat, Modificacions i Contacte
- **Divisibilitat:** Si alguna disposició d'aquests Termes es considera invàlida o inaplicable, es modificarà en la mesura mínima necessària i la resta romandrà en ple vigor.
- **Modificacions:** Ens reservem el dret d'actualitzar aquests Termes en qualsevol moment. L'ús continuat després dels canvis constitueix l'acceptació dels Termes modificats.
- **Contacte:** Per a consultes legals, contacta amb el desenvolupador a GitHub a:  
  [https://github.com/CarlesPV](https://github.com/CarlesPV)''';
    }
    return '''# Terms and Conditions of Use

**Effective Date:** August 17, 2026

Please read these Terms and Conditions ("Terms", "Agreement") carefully before downloading, installing, accessing, or using the Stalvi mobile application (the "Application" or "App").

This Agreement constitutes a legally binding contract between you (the "User", "you", or "your") and the developers and operators of Stalvi ("Stalvi", "we", "us", or "our").

By downloading, installing, opening, accessing, or using the Application, you explicitly acknowledge, represent, and warrant that you have read, understood, and agree to be bound by all terms, conditions, disclaimers, and obligations set forth herein. If you do not agree to all of these Terms, you are not authorized to access or use the Application, and you must immediately uninstall and permanently remove the Application from your device.

---

## 1. Description of Service & Core Functionality
Stalvi is a privacy-focused, local-first personal financial management tool designed to enable users to record, categorize, monitor, and analyze their personal income, expenses, budgets, savings targets, and recurring transactions strictly on their personal mobile devices.

---

## 2. Local-First Architecture & SQLCipher Encryption
- **Local-Only Storage:** Stalvi operates on a strict **local-first architecture**. All transaction logs, account balances, budgets, categories, PIN hashes, and custom preferences are stored exclusively on your device. Stalvi does not transmit, back up, sync, store, or process your financial data on external servers or cloud services.
- **SQLCipher AES-256 Encryption:** The underlying SQLite database is encrypted at rest using **SQLCipher with AES-256 bit encryption**. Cryptographic keys are protected using native hardware-backed secure storage interfaces (Android KeyStore / iOS Keychain via `flutter_secure_storage`).
- **No Remote Access or Backdoors:** The developers have zero access to your device, your PIN, your encryption keys, or your database.

---

## 3. Background Processing & Automated WorkManager Tasks
- **On-Device Background Execution:** Stalvi relies on system background execution mechanisms (**WorkManager** on Android, **BGTaskScheduler** on iOS) to execute automated tasks locally without requiring the user to open the app.
- **Scope of Background Work:** Background execution is limited to:
  1. Idempotently processing scheduled recurring transactions to update ledger records without duplicate creation.
  2. Refreshing offline currency conversion fallbacks when an active Internet connection is detected.
  3. Scheduling local push notifications for due payments or bill reminders.
- **OS Scheduling Disclaimers:** Background task timing is governed by the operating system's battery optimization and job scheduling policies. Stalvi makes no warranty regarding the exact minute-level execution of background tasks.

---

## 4. Financial, Tax, and Currency Disclaimer (Zero Liability)

### 4.1. Informational & Personal Tracking Tool Only
STALVI IS PURELY AN INFORMATIONAL, PERSONAL DATA RECORDING AND STATISTICAL TRACKING APPLICATION. STALVI IS NOT A BANK, FINANCIAL INSTITUTION, INVESTMENT ADVISOR, CERTIFIED PUBLIC ACCOUNTANT, OR TAX ADVISORY SERVICE.

NEITHER THE APPLICATION NOR ITS DEVELOPERS PROVIDE LEGAL, TAX, ACCOUNTING, INVESTMENT, MORTGAGE, LOAN, OR FINANCIAL ADVICE OF ANY KIND. NO CONTENT, COMPUTATION, SUMMARY, CHART, REPORT, OR STATISTIC PRODUCED BY THE APPLICATION SHOULD BE CONSTRUED AS FINANCIAL PLANNING OR PROFESSIONAL ADVICE.

### 4.2. Zero Liability for Financial Losses, Data Loss & Miscalculations
YOU EXPRESSLY ACKNOWLEDGE AND AGREE THAT THE DEVELOPERS, MAINTAINERS, AND OWNERS OF STALVI ASSUME **ZERO LIABILITY AND ZERO RESPONSIBILITY** UNDER ANY CIRCUMSTANCE FOR ANY:
- FINANCIAL LOSSES, UNEXPECTED EXPENSES, OVERDRAFTS, BANK FEES, DEBTS, INACCURATE BUDGET ESTIMATES, OR POOR INVESTMENT DECISIONS RESULTING DIRECTLY OR INDIRECTLY FROM YOUR USE OF OR RELIANCE UPON THE APPLICATION;
- DATA LOSS, CORRUPTION, OR INACCESSIBILITY OF YOUR DATABASE DUE TO DEVICE FAILURE, FORGOTTEN PIN, SOFTWARE BUGS, OR FAILURE TO MAINTAIN BACKUPS;
- CALCULATION DISCREPANCIES, ROUNDING ERRORS, ALGORITHMIC MISCALCULATIONS, OR COMPUTATIONAL ERRORS IN TRANSACTION TOTALS, BALANCES, RECURRING EXPENSES, OR STATISTICAL PROJECTIONS;
- TAX ISSUES, INCORRECT TAX DEDUCTION ESTIMATES, OMISSIONS, OR MISREPORTING TO ANY TAX AUTHORITY;
- INACCURACIES, LAGS, OR DISCREPANCIES IN CURRENCY CONVERSIONS, EXCHANGE RATES, DUAL-CURRENCY COMPUTATIONS, OR HISTORICAL RATE CALCULATIONS.

YOU ARE SOLELY RESPONSIBLE FOR VERIFYING THE ACCURACY OF ALL TRANSACTIONS, CALCULATIONS, AND FINANCIAL DATA AGAINST OFFICIAL STATEMENTS ISSUED BY YOUR BANK OR FINANCIAL INSTITUTION.

---

## 5. User Responsibility & Data Backup
- **Forgotten PIN / Biometrics:** Because all data is encrypted on-device with keys managed by your device credentials, forgetting your PIN or losing biometric access will render your database unreadable. **The developers cannot reset your PIN or recover your encrypted data.**
- **Device Loss or Corruption:** If your device is lost, damaged, stolen, factory reset, or if the App is uninstalled without exporting an encrypted backup file, your financial data is permanently lost.
- **Backup Responsibility:** You are solely responsible for creating regular encrypted database backups or CSV exports and transferring them to secure off-device storage.

---

## 6. Acceptable Use Policy & Prohibited Conduct
You agree to use the Application only for lawful, personal purposes and in compliance with all applicable local, national, and international laws.

You explicitly agree **NOT** to:
1. Use the Application for unlawful, fraudulent, or unauthorized financial activities, including money laundering, sanctions evasion, or tax fraud;
2. Decompile, reverse engineer, disassemble, decrypt, attempt to derive source code, or modify the Application, except as allowed by applicable open-source licenses;
3. Circumvent, disable, or tamper with security features of the Application, including PIN verification, biometric protection, database encryption, or export mechanisms;
4. Introduce viruses, Trojan horses, malware, or malicious code that compromises device or database integrity;
5. Rent, lease, lend, sell, sublicense, distribute, or commercially exploit the Application or any portion thereof.

---

## 7. License Grant and Intellectual Property
Stalvi grants you a revocable, non-exclusive, non-transferable, limited, personal license to install and use the Application on compatible devices owned or controlled by you.

All intellectual property rights, titles, and interests in the Application—including code, software architecture, UI/UX design, visual themes, graphics, icons, logos, and documentation—remain the exclusive property of Stalvi and its licensors. All rights not expressly granted are reserved.

---

## 8. Disclaimer of Warranties ("AS-IS" and "AS-AVAILABLE")
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE APPLICATION IS PROVIDED STRICTLY ON AN **"AS-IS"** AND **"AS-AVAILABLE"** BASIS, WITH ALL FAULTS AND DEFECTS, AND WITHOUT WARRANTY OF ANY KIND.

STALVI DISCLAIMS ALL WARRANTIES, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT. STALVI DOES NOT WARRANT THAT THE APPLICATION WILL OPERATE UNINTERRUPTED, SECURELY, OR ERROR-FREE.

---

## 9. Limitation of Liability
TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL STALVI, ITS DEVELOPERS, AFFILIATES, OFFICERS, AGENTS, OR SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, PUNITIVE, EXEMPLARY, OR CONSEQUENTIAL DAMAGES WHATSOEVER (INCLUDING LOSS OF PROFITS, DATA, REVENUE, SAVINGS, BUSINESS INTERRUPTION, OR FINANCIAL MISCALCULATIONS) ARISING OUT OF OR IN CONNECTION WITH YOUR USE OR INABILITY TO USE THE APPLICATION.

---

## 10. App Store & Google Play Store Platform Terms
- **Apple App Store Terms:** You acknowledge that this Agreement is concluded between you and Stalvi only, and not with Apple Inc. Apple is not responsible for the Application or its content, maintenance, or support services. Apple has no obligation whatsoever to furnish any maintenance or support services with respect to the Application. To the maximum extent permitted by applicable law, Apple will have no warranty obligation whatsoever with respect to the Application. Apple and Apple's subsidiaries are third-party beneficiaries of this Agreement and will have the right to enforce this Agreement against you.
- **Google Play Store Terms:** You acknowledge that Google LLC is not responsible for providing maintenance, support, or resolving claims regarding the Application.

---

## 11. Governing Law and Dispute Resolution
These Terms and your use of the Application shall be governed by and construed in accordance with the laws of Spain and the regulations of the European Union. Any dispute or claim arising out of or in connection with this Agreement shall be submitted to the exclusive jurisdiction of the competent courts of Spain.

---

## 12. Severability, Modifications & Contact
- **Severability:** If any provision of these Terms is held invalid or unenforceable, that provision will be modified to the minimum extent necessary, and the remaining provisions will remain in full force.
- **Modifications:** We reserve the right to update these Terms at any time. Continued use of the App following changes constitutes acceptance of modified Terms.
- **Contact:** For legal inquiries, contact the developer via GitHub at:  
  [https://github.com/CarlesPV](https://github.com/CarlesPV)''';
  }

  static String _getPrivacyFallback(String lang) {
    if (lang == 'es') {
      return '''# Política de Privacidad

**Fecha de entrada en vigor:** 17 de agosto de 2026

## 1. Introducción
Bienvenido a **Stalvi** ("nosotros", "nuestro" o "la Aplicación"). Stalvi es una aplicación de gestión de finanzas personales diseñada con arquitectura local (*local-first*) y bajo la filosofía de privacidad desde el diseño (*privacy-by-design*). Estamos firmemente comprometidos a proteger su privacidad y a garantizar que sus datos financieros permanezcan confidenciales, seguros y bajo su control exclusivo.

Esta Política de Privacidad detalla nuestras prácticas de tratamiento de datos, arquitectura de seguridad y estándares de cumplimiento normativo, incluyendo:
- **Reglamento General de Protección de Datos (RGPD)** de la Unión Europea (Reglamento (UE) 2016/679).
- **Ley Orgánica de Protección de Datos Personales y garantía de los derechos digitales (LOPDGDD 3/2018)** de España.
- **California Consumer Privacy Act (CCPA)**, modificada por la **California Privacy Rights Act (CPRA)**.
- **Directrices de Revisión de App Store de Apple** (Sección 5.1 - Privacidad, Recopilación y Almacenamiento de Datos).
- **Políticas para Desarrolladores de Google Play** (Datos de Usuario, Servicios Financieros y requisitos de Divulgación Destacada).

Al utilizar Stalvi, usted reconoce y acepta las prácticas de privacidad descritas en este documento.

---

## 2. Cero Telemetría y Cero Recopilación de Datos Personales
Stalvi opera bajo un modelo estricto de **Cero Telemetría**:
- **Sin Recopilación de Datos por el Desarrollador:** No recopilamos, almacenamos, rastreamos, procesamos ni vendemos ninguno de sus datos personales, financieros o de comportamiento.
- **Sin Registro de Usuario:** Stalvi no requiere la creación de cuentas de usuario, registro por correo electrónico, verificación por número de teléfono ni inicio de sesión en servicios en la nube.
- **Sin SDKs de Análisis o Seguimiento de Terceros:** La Aplicación contiene cero herramientas de telemetría de terceros, agregadores de informes de fallos (p. ej., Firebase Analytics, Sentry, Mixpanel), marcos publicitarios o herramientas de elaboración de perfiles de comportamiento.

---

## 3. Arquitectura Local-First y Cifrado SQLCipher (AES-256)
Todos los datos introducidos o generados dentro de Stalvi (incluidas transacciones financieras, saldos de cuentas, presupuestos, reglas recurrentes, categorías, etiquetas y preferencias) se almacenan exclusivamente en su dispositivo físico.

- **Cifrado de Base de Datos SQLCipher AES-256:** La base de datos SQLite subyacente se cifra en reposo mediante **SQLCipher con cifrado AES de 256 bits**. Sus datos financieros resultan ilegibles sin la clave criptográfica.
- **Gestión Segura de Claves en Hardware:** Las claves criptográficas y las credenciales de acceso se aíslan y gestionan de forma segura utilizando el KeyStore nativo del dispositivo (Android) o Keychain (iOS) a través de interfaces de almacenamiento seguro del sistema (`flutter_secure_storage`).
- **Autenticación Biométrica y PIN:** El acceso a la Aplicación está protegido en el dispositivo mediante mecanismos biométricos (Face ID, Touch ID, huella dactilar) o un Número de Identificación Personal (PIN) definido por el usuario.
- **Aislamiento Absoluto de Datos:** Puesto que ningún dato se transmite a servidores externos, su información está protegida frente a brechas de datos remotas, ataques a servidores, intercepciones de red y minería de datos corporativa.

---

## 4. Ejecución de Tareas en Segundo Plano en el Dispositivo
Stalvi utiliza programadores nativos del sistema en segundo plano (**WorkManager** en Android, **BGTaskScheduler** en iOS) para mantener actualizados los registros financieros sin intervención del usuario.

- **Propósito de las Tareas en Segundo Plano:** La ejecución en segundo plano se limita estrictamente a:
  1. Evaluar las transacciones recurrentes programadas de forma idempotente para evitar entradas duplicadas.
  2. Actualizar las fuentes de respaldo de tipos de cambio de divisas sin conexión cuando haya conectividad a Internet.
  3. Emitir notificaciones locales para recordatorios de facturas o pagos programados.
- **Operación Exclusivamente Local:** Todas las operaciones en segundo plano se ejecutan **100% localmente en su dispositivo**. Las tareas en segundo plano no recopilan, registran ni filtran telemetría, identificadores de dispositivo o datos financieros hacia servidores remotos.

---

## 5. Conectividad a Internet y APIs Abiertas Anónimas
Stalvi está diseñado para funcionar completamente sin conexión. La **única** situación en la que la Aplicación inicia una solicitud de red saliente es para consultar los tipos de cambio de divisas públicos.

- **Solicitudes Anónimas de Tipos de Cambio:** Cuando se actualizan las divisas, Stalvi consulta una API pública de tipos de cambio de terceros mediante HTTPS cifrado.
- **Sin Transmisión de Identificadores:** Estas solicitudes contienen estrictamente los parámetros HTTP estándar necesarios para obtener las tablas de tipos de cambio públicas (p. ej., códigos de moneda base y destino). **Nunca** se envían credenciales de usuario, identificadores de dispositivo, tokens vinculados a la IP, importes de transacciones o saldos de cuentas.
- **Sin Publicidad ni Corredores de Datos:** No mantenemos alianzas con anunciantes, redes de afiliados, proveedores de seguimiento ni corredores de datos (*data brokers*).

---

## 6. Propiedad de Datos, Control y Cumplimiento de Derechos

### 6.1. Derechos en la UE / España (RGPD y LOPDGDD 3/2018)
Bajo el RGPD y la LOPDGDD, los interesados tienen derechos de acceso, rectificación, supresión, limitación del tratamiento, oposición y portabilidad de datos:
- **Ejercicio Directo de Derechos:** Dado que todo el tratamiento se realiza localmente bajo su control físico, usted ejerce todos los derechos del interesado directamente en la interfaz de la Aplicación (p. ej., modificando transacciones, exportando archivos o borrando bases de datos).
- **Sin Acceso por el Desarrollador:** Puesto que no conservamos, transmitimos ni almacenamos sus datos en ningún servidor, no podemos acceder, generar, modificar ni eliminar sus datos personales en su nombre.

### 6.2. Residentes de California (CCPA / CPRA)
- **No Venta ni Intercambio:** Stalvi **no vende, alquila ni comparte** su información personal con terceros a cambio de contraprestación monetaria o de otro valor.
- **Derecho a Conocer y Eliminar:** Usted ejerce su derecho a conocer y eliminar todos los datos financieros personales almacenados directamente a través de la interfaz local de la Aplicación.

---

## 7. Retención y Eliminación Permanente de Datos
- **Exportación de Datos:** Puede exportar sus datos en cualquier momento en formatos estándar (archivos de copia de seguridad cifrados o hojas de cálculo CSV) para su respaldo personal o migración.
- **Borrado Permanente:** Puede activar la acción **"Eliminar Todos los Datos"** en la configuración de la Aplicación. Esto elimina de forma permanente todos los archivos de bases de datos locales cifradas y preferencias del dispositivo. La desinstalación de la Aplicación también elimina todos los archivos de bases de datos locales.

---

## 8. Privacidad de Menores
Stalvi no está dirigido a menores de 16 años (o 13 años bajo COPPA). No recopilamos a sabiendas datos personales de menores. Puesto que todos los datos residen localmente en el dispositivo, los padres y tutores mantienen la supervisión completa del uso del dispositivo.

---

## 9. Cumplimiento de Políticas de App Store y Google Play
- **Directrices de Revisión de App Store (5.1.1 y 5.1.2):** Stalvi revela todo el uso de datos, limita la recopilación a cero y proporciona control total de los datos al usuario.
- **Políticas para Desarrolladores de Google Play:** Stalvi cumple con las políticas de Datos de Usuario, Servicios Financieros y divulgación de tareas WorkManager en segundo plano al mantener el procesamiento 100% local y cero intercambio de datos.

---

## 10. Actualizaciones de la Política e Información de Contacto
Podemos actualizar esta Política de Privacidad para reflejar mejoras del software o cambios normativos. Las actualizaciones se incluirán en los lanzamientos de la aplicación y en el repositorio.

Para consultas sobre privacidad, contacte al desarrollador:
- **Repositorio de GitHub y Soporte:** [https://github.com/CarlesPV](https://github.com/CarlesPV)''';
    } else if (lang == 'ca') {
      return '''# Política de Privadesa

**Data d'entrada en vigor:** 17 d'agost de 2026

## 1. Introducció
Benvingut a **Stalvi** ("nosaltres", "nostre" o "l'Aplicació"). Stalvi és una aplicació de gestió de finances personals dissenyada amb arquitectura local (*local-first*) i sota la filosofia de privadesa des del disseny (*privacy-by-design*). Estem fermament compromesos a protegir la teva privadesa i a garantir que les teves dades financeres romanguin confidencials, segures i sota el teu control exclusiu.

Aquesta Política de Privadesa detalla les nostres pràctiques de tractament de dades, arquitectura de seguretat i estàndards de compliment normatiu, incloent:
- **Reglament General de Protecció de Dades (RGPD)** de la Unió Europea (Reglament (UE) 2016/679).
- **Llei Orgànica de Protecció de Dades Personals i garantia dels drets digitals (LOPDGDD 3/2018)** d'Espanya.
- **California Consumer Privacy Act (CCPA)**, esmenada per la **California Privacy Rights Act (CPRA)**.
- **Directrius de Revisió de l'App Store d'Apple** (Secció 5.1 - Privadesa, Recopilació i Emmagatzematge de Dades).
- **Polítiques per a Desenvolupadors de Google Play** (Dades d'Usuari, Serveis Financers i requisits de Divulgació Destacada).

En utilitzar Stalvi, reconeixes i acceptes les pràctiques de privadesa descrites en aquest document.

---

## 2. Zero Telemetria i Zero Recopilació de Dades Personals
Stalvi opera sota un model estricte de **Zero Telemetria**:
- **Sense Recopilació de Dades pel Desenvolupador:** No recopilem, emmagatzemem, rastregem, processem ni venem cap de les teves dades personals, financeres o de comportament.
- **Sense Registre d'Usuari:** Stalvi no requereix la creació de comptes d'usuari, registre per correu electrònic, verificació per número de telèfon ni inici de sessió en serveis al núvol.
- **Sense SDKs d'Anàlisi o Seguiment de Tercers:** L'Aplicació conté zero eines de telemetria de tercers, agregadors d'informes d'errades (p. ex., Firebase Analytics, Sentry, Mixpanel), marcs publicitaris o eines d'elaboració de perfils de comportament.

---

## 3. Arquitectura Local-First i Xifratge SQLCipher (AES-256)
Totes les dades introduïdes o generades dins de Stalvi (incloses transaccions financeres, saldos de comptes, pressupostos, regles recurrents, categories, etiquetes i preferències) s'emmagatzemen exclusivament al teu dispositiu físic.

- **Xifratge de Base de Dades SQLCipher AES-256:** La base de dades SQLite subadjacent es xifra en repòs mitjançant **SQLCipher amb xifratge AES de 256 bits**. Les teves dades financeres resulten il·legibles sense la clau criptogràfica.
- **Gestió Segura de Claus en Hardware:** Les claus criptogràfiques i les credencials d'accés s'aïllen i gestionen de forma segura utilitzant el KeyStore natiu del dispositiu (Android) o Keychain (iOS) a través d'interfícies d'emmagatzematge segur del sistema (`flutter_secure_storage`).
- **Autenticació Biomètrica i PIN:** L'accés a l'Aplicació està protegit al dispositiu mitjançant mecanismes biomètrics (Face ID, Touch ID, empremta dactilar) o un Número d'Identificació Personal (PIN) definit per l'usuari.
- **Aïllament Absolut de Dades:** Atès que cap dada es transmet a servidors externs, la teva informació està protegida enfront de bretxes de dades remotes, atacs a servidors, intercepcions de xarxa i mineria de dades corporativa.

---

## 4. Execució de Tasques en Segon Pla al Dispositiu
Stalvi utilitza programadors natius del sistema en segon pla (**WorkManager** a Android, **BGTaskScheduler** a iOS) per mantenir actualitzats els registres financers sense intervenció de l'usuari.

- **Propòsit de les Tasques en Segon Pla:** L'execució en segon pla es limita estrictament a:
  1. Avaluar les transaccions recurrents programades de forma idempotent per evitar entrades duplicades.
  2. Actualitzar les fonts de suport de tipus de canvi de divises sense connexió quan hi hagi connectivitat a Internet.
  3. Emetre notificacions locals per a recordatoris de factures o pagaments programats.
- **Operació Exclusivament Local:** Totes les operacions en segon pla s'executen **100% localment al teu dispositiu**. Les tasques en segon pla no recopilen, enregistren ni filtren telemetria, identificadors de dispositiu o dades financeres cap a servidors remots.

---

## 5. Connectivitat a Internet i APIs Obertes Anònimes
Stalvi està dissenyat per funcionar completament sense connexió. L'**única** situació en què l'Aplicació inicia una sol·licitud de xarxa sortint és per consultar els tipus de canvi de divises públics.

- **Sol·licituds Anònimes de Tipus de Canvi:** Quan s'actualitzen les divises, Stalvi consulta una API pública de tipus de canvi de tercers mitjançant HTTPS xifrat.
- **Sense Transmissió d'Identificadors:** Aquestes sol·licituds contenen estrictament els paràmetres HTTP estàndard necessaris per obtenir les taules de tipus de canvi públiques (p. ex., codis de moneda base i destí). **Mai** s'envien credencials d'usuari, identificadors de dispositiu, tokens vinculats a la IP, imports de transaccions o saldos de comptes.
- **Sense Publicitat ni Corredors de Dades:** No mantenim aliances amb anunciants, xarxes d'afiliats, proveïdors de seguiment ni corredors de dades (*data brokers*).

---

## 6. Propietat de Dades, Control i Compliment de Drets

### 6.1. Drets a la UE / Espanya (RGPD i LOPDGDD 3/2018)
Sota el RGPD i la LOPDGDD, els interessats tenen drets d'accés, rectificació, supressió, limitació del tractament, oposició i portabilitat de dades:
- **Exercici Directe de Drets:** Atès que tot el tractament es realitza localment sota el teu control físic, tu exerceixes tots els drets de l'interessat directament en la interfície de l'Aplicació (p. ex., modificant transaccions, exportant fitxers o esborrant bases de dades).
- **Sense Accés pel Desenvolupador:** Atès que no conservem, transmetem ni emmagatzemem les teves dades en cap servidor, no podem accedir, generar, modificar ni eliminar les teves dades personals en nom teu.

### 6.2. Residents de Califòrnia (CCPA / CPRA)
- **No Venda ni Intercanvi:** Stalvi **no ven, lloga ni comparteix** la teva informació personal amb tercers a canvi de contraprestació monetària o d'altre valor.
- **Dret a Conèixer i Eliminar:** Tu exerceixes el teu dret a conèixer i eliminar totes les dades financeres personals emmagatzemades directament a través de la interfície local de l'Aplicació.

---

## 7. Retenció i Eliminació Permanent de Dades
- **Exportació de Dades:** Pots exportar les teves dades en qualsevol moment en formats estàndard (fitxers de còpia de seguretat xifrats o fulls de càlcul CSV) per al teu suport personal o migració.
- **Esborrat Permanent:** Pots activar l'acció **"Eliminar Totes les Dades"** a la configuració de l'Aplicació. Això elimina de forma permanent tots els fitxers de bases de dades locals xifrades i preferències del dispositiu. La desinstal·lació de l'Aplicació també elimina tots els fitxers de bases de dades locals.

---

## 8. Privadesa de Menors
Stalvi no està dirigit a menors de 16 anys (o 13 anys sota COPPA). No recopilem conscientment dades personals de menors. Atès que totes les dades resideixen localment al dispositiu, els pares i tutors mantenen la supervisió completa de l'ús del dispositiu.

---

## 9. Compliment de Polítiques de l'App Store i Google Play
- **Directrius de Revisió de l'App Store (5.1.1 i 5.1.2):** Stalvi revela tot l'ús de dades, limita la recopilació a zero i proporciona control total de les dades a l'usuari.
- **Polítiques per a Desenvolupadors de Google Play:** Stalvi compleix amb les polítiques de Dades d'Usuari, Serveis Financers i divulgació de tasques WorkManager en segon pla en mantenir el tractament 100% local i zero intercanvi de dades.

---

## 10. Actualitzacions de la Política e Informació de Contacte
Podem actualitzar aquesta Política de Privadesa per reflectir millores del programari o canvis normatius. Les actualitzacions s'inclouran en els llançaments de l'aplicació i al repositori.

Per a consultes sobre privadesa, contacta amb el desenvolupador:
- **Repositori de GitHub i Suport:** [https://github.com/CarlesPV](https://github.com/CarlesPV)''';
    }
    return '''# Privacy Policy

**Effective Date:** August 17, 2026

## 1. Introduction
Welcome to **Stalvi** ("we", "our", or "the Application"). Stalvi is a local-first, privacy-by-design personal financial management application. We are committed to protecting your privacy and ensuring your financial data remains confidential, secure, and under your exclusive control.

This Privacy Policy details our data handling practices, security architecture, and regulatory compliance standards, including:
- **General Data Protection Regulation (GDPR)** of the European Union (Regulation (EU) 2016/679).
- Spanish **Ley Orgánica de Protección de Datos Personales y garantía de los derechos digitales (LOPDGDD 3/2018)**.
- **California Consumer Privacy Act (CCPA)**, as amended by the **California Privacy Rights Act (CPRA)**.
- **Apple App Store Review Guidelines** (Section 5.1 - Privacy, Data Collection & Storage).
- **Google Play Developer Policies** (User Data, Financial Services, and Prominent Disclosure requirements).

By using Stalvi, you acknowledge and accept the privacy practices described herein.

---

## 2. Zero Telemetry & Zero Data Harvesting
Stalvi operates on a strict **Zero Telemetry** model:
- **No Developer Data Harvesting:** We do not collect, store, track, harvest, process, or sell any of your personal, financial, or behavioral data.
- **No User Registration:** Stalvi requires no account creation, email registration, phone number verification, or cloud service sign-in.
- **No Third-Party Analytics or Tracking SDKs:** The Application contains zero third-party telemetry, crash reporting aggregators (e.g., Firebase Analytics, Sentry, Mixpanel), advertising frameworks, or behavioral profiling tools.

---

## 3. Local-First Architecture & SQLCipher Encryption (AES-256)
All data entered or generated within Stalvi—including financial transactions, account balances, budgets, recurring rules, categories, tags, and preferences—is stored exclusively on your physical device.

- **SQLCipher AES-256 Database Encryption:** The underlying SQLite database is encrypted at rest using **SQLCipher with AES-256 bit encryption**. Your financial data is unreadable without the cryptographic key.
- **Hardware Security Key Management:** Cryptographic keys and access credentials are isolated and managed securely using the device's native KeyStore (Android) or Keychain (iOS) via secure system storage interfaces (`flutter_secure_storage`).
- **Biometric & PIN Authentication:** Access to the Application is protected on-device by biometric mechanisms (Face ID, Touch ID, Fingerprint) or a user-defined Personal Identification Number (PIN).
- **Absolute Data Isolation:** Because no data is transmitted to external servers, your information is protected against remote data breaches, server hacks, network sniffing, and corporate data mining.

---

## 4. On-Device Background Task Execution
Stalvi utilizes native system background schedulers (**WorkManager** on Android, **BGTaskScheduler** on iOS) to maintain financial records without user intervention.

- **Purpose of Background Tasks:** Background execution is limited strictly to:
  1. Evaluating scheduled recurring transactions idempotently to prevent duplicate entries.
  2. Refreshing offline currency exchange rate fallbacks when network connectivity is available.
  3. Firing local push notifications for upcoming bill reminders or scheduled payments.
- **Local-Only Operation:** All background operations execute **100% locally on your device**. Background tasks do not collect, log, or exfiltrate any telemetry, device identifiers, or financial data to remote servers.

---

## 5. Internet Connectivity & Anonymous Open APIs
Stalvi is engineered to function entirely offline. The **only** scenario where the Application initiates an outbound network request is to retrieve public currency exchange rates.

- **Anonymous Exchange Rate Requests:** When currency rates are updated, Stalvi queries a public third-party exchange rate API over encrypted HTTPS.
- **No Identifiers Transmitted:** These requests contain strictly standard HTTP parameters required to retrieve public rate tables (e.g., base and target currency codes). **No** user credentials, device IDs, IP-linked tokens, transaction amounts, or account balances are ever sent.
- **No Advertising or Data Brokers:** We do not partner with advertisers, affiliate networks, tracking providers, or data brokers.

---

## 6. Data Ownership, Control & Rights Compliance

### 6.1. EU / UK & Spanish Rights (GDPR & LOPDGDD 3/2018)
Under GDPR and LOPDGDD, data subjects have rights regarding access, rectification, erasure, restriction, objection, and data portability:
- **Direct Rights Execution:** Because all processing occurs locally under your physical control, you exercise all data subject rights directly within the Application UI (e.g., modifying transactions, exporting files, or purging databases).
- **No Developer Data Access:** Because we do not hold, transmit, or store your data on any server, we cannot access, produce, alter, or delete your personal data on your behalf.

### 6.2. California Residents (CCPA / CPRA)
- **Do Not Sell or Share:** Stalvi **does not sell, rent, or share** your personal information with any third party for monetary or other valuable consideration.
- **Right to Know and Delete:** You exercise your right to know and delete all stored personal financial data directly through the local Application interface.

---

## 7. Data Retention & Permanent Deletion
- **Data Export:** You can export your data at any time into standard formats (encrypted backup files or CSV spreadsheets) for personal backup or migration.
- **Permanent Purge:** You can trigger a **"Delete All Data"** action in the Application settings. This permanently wipes all encrypted local database files and cached preferences from your device. Uninstallation of the Application also removes all local database files.

---

## 8. Children's Privacy
Stalvi is not directed to children under 16 (or 13 under COPPA). We do not knowingly collect personal data from minors. Since all data resides locally on the device, parents and guardians maintain full oversight of device usage.

---

## 9. App Store & Google Play Developer Policy Compliance
- **Apple App Store Review Guidelines (5.1.1 & 5.1.2):** Stalvi discloses all data usage, limits collection to zero, and provides full data control to the user.
- **Google Play Developer Policies:** Stalvi complies with Google Play User Data policies, Financial Services policies, and background WorkManager disclosures by maintaining strict local processing and zero data sharing.

---

## 10. Policy Updates & Contact Information
We may update this Privacy Policy to reflect software updates or regulatory changes. Updates will be incorporated in app releases and published in the repository.

For privacy inquiries, contact the developer:
- **GitHub Repository & Support:** [https://github.com/CarlesPV](https://github.com/CarlesPV)''';
  }
}

class _LegalDocumentView extends StatefulWidget {
  final String assetPath;
  final String fallbackContent;

  const _LegalDocumentView({
    super.key,
    required this.assetPath,
    required this.fallbackContent,
  });

  @override
  State<_LegalDocumentView> createState() => _LegalDocumentViewState();
}

class _LegalDocumentViewState extends State<_LegalDocumentView> {
  final ScrollController _scrollController = ScrollController();
  late final Future<String> _contentFuture;

  @override
  void initState() {
    super.initState();
    _contentFuture = rootBundle
        .loadString(widget.assetPath)
        .then((value) => value.isNotEmpty ? value : widget.fallbackContent)
        .catchError((_) => widget.fallbackContent);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<String>(
      future: _contentFuture,
      initialData: widget.fallbackContent,
      builder: (context, snapshot) {
        final content = (snapshot.data != null && snapshot.data!.isNotEmpty)
            ? snapshot.data!
            : widget.fallbackContent;

        return Scrollbar(
          controller: _scrollController,
          interactive: true,
          child: Markdown(
            controller: _scrollController,
            data: content,
            selectable: true,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            onTapLink: (text, href, title) {
              if (href != null) {
                final uri = Uri.tryParse(href);
                if (uri != null) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              h1: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
              h2: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: -0.2,
              ),
              h3: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              p: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.55,
              ),
              listBullet: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              strong: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              em: TextStyle(
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
              a: TextStyle(
                color: colorScheme.primary,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
              horizontalRuleDecoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
              ),
              blockquoteDecoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: colorScheme.primary,
                    width: 4,
                  ),
                ),
              ),
              blockquotePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}

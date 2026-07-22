# Active Task: Phase 50 - Store-Ready Legal Overhaul & Final App Store Validation

## 🎯 Objective
Redactar y desplegar documentos legales (Términos y Condiciones, y Política de Privacidad) exhaustivos, de nivel profesional y jurídicamente blindados en Inglés, Español y Catalán. Garantizar el cumplimiento de GDPR, LOPDGDD y CCPA, preparando la app para su publicación inmediata en las tiendas.

## 🏗️ Architecture & Core Components
*   **Static Assets:** Sobrescritura de `assets/legal/privacy_*.md` y `assets/legal/terms_*.md`.
*   **Presentation Layer:** Verificación del renderizado del Markdown para textos largos (scroll, rendimiento).
*   **Compliance:** Exención explícita de responsabilidad financiera, aclaración sobre el uso de la API de divisas de terceros y confirmación de la naturaleza 100% local y encriptada (SQLCipher) de los datos.

## ✅ Task Checklist
- [ ] **Privacy Policy Overhaul:** Generar políticas de privacidad detalladas (EN, ES, CA) declarando la nula recolección de datos personales, almacenamiento local seguro y el uso anónimo de APIs externas.
- [ ] **Terms & Conditions Overhaul:** Generar T&C detallados (EN, ES, CA) estableciendo que la app es una herramienta informativa, sin responsabilidad sobre decisiones o pérdidas financieras del usuario.
- [ ] **UI/UX Validation:** Asegurar que las pantallas `TermsScreen` y `PrivacyScreen` renderizan correctamente los nuevos documentos extensos sin desbordamientos de UI en dispositivos pequeños.
- [ ] **Quality Assurance:** Ejecutar `flutter analyze` y los tests unitarios/widgets para asegurar 100% de cobertura y ningún error (0 warnings, 0 info) tras la actualización de los assets. Actualizar `roadmap.md` a Fase 50 completada.
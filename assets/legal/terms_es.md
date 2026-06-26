# Términos y Condiciones

Bienvenido a Stalvi. Estos Términos y Condiciones rigen el uso de la aplicación móvil sin conexión Stalvi. Al crear un perfil y usar esta aplicación, aceptas estos términos.

## 1. Almacenamiento Local First
* **Datos Locales**: Stalvi almacena todos tus datos financieros, cuentas, transacciones y categorías localmente en tu dispositivo.
* **Seguridad y Cifrado**: Tus datos están protegidos en el dispositivo mediante el cifrado de base de datos SQLCipher y Flutter Secure Storage. La clave de cifrado de la base de datos se almacena en el almacenamiento seguro a nivel de sistema operativo (iOS Keychain / Android Keystore) y nunca se transmite ni es accesible para Stalvi ni para terceros.

## 2. Autenticación Biométrica
* **Propósito**: Stalvi ofrece autenticación biométrica (huella dactilar, FaceID) como una forma cómoda y segura de acceder a tus datos. Al habilitar esta función, se almacena una preferencia en el almacenamiento seguro; la verificación biométrica real es realizada íntegramente por el sistema operativo del dispositivo.
* **Opt-In**: La autenticación biométrica es estrictamente opcional. Puedes usar tu PIN como alternativa en cualquier momento.
* **Alternativa**: Si la autenticación biométrica falla o no está disponible, siempre puedes autenticarte con tu PIN.

## 3. Exportación e Importación de Datos
* **Formatos de Exportación**: Stalvi permite exportar tus datos como archivo de copia de seguridad cifrada, hoja de cálculo CSV o informe mensual en PDF.
* **Copias de Seguridad Cifradas**: Los archivos de copia de seguridad están cifrados con AES-256 usando una contraseña que tú creas. Eres el único responsable de mantener esta contraseña segura. Las contraseñas perdidas no se pueden recuperar y harán que las copias de seguridad sean permanentemente inaccesibles.
* **Importación / Restauración**: Importar una copia de seguridad sobrescribirá permanentemente todos los datos existentes en el dispositivo. Esta acción no se puede deshacer. Verifica las copias de seguridad antes de restaurarlas.
* **Sin Implicación de Servidores**: Todas las operaciones de exportación e importación ocurren localmente. Stalvi nunca sube archivos a ningún servidor.

## 4. Responsabilidad del Usuario
* **Copia de Seguridad**: Dado que Stalvi es una aplicación local-first y no sube tus datos a ningún servidor remoto, eres el único responsable de realizar copias de seguridad de tu dispositivo y archivos de base de datos.
* **Pérdida de Datos**: Si pierdes tu dispositivo o lo reinicias sin una copia de seguridad, tus registros financieros no se podrán recuperar.

## 5. Privacidad
No recopilamos, transmitimos ni vendemos tus datos personales o financieros. Tus datos te pertenecen por completo.

## 6. Actualizaciones de los Términos
Nos reservamos el derecho de actualizar estos términos en cualquier momento. El uso continuado de la aplicación constituye la aceptación de los términos actualizados.

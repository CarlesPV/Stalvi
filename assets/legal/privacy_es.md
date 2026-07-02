# Política de Privacidad

Tu privacidad es extremadamente importante para nosotros. Esta Política de Privacidad explica cómo Stalvi maneja tu información.

## 1. Cero Recopilación de Datos
* **Datos Personales**: No recopilamos ningún dato personal como nombre, nombre de usuario o información de contacto.
* **Datos Financieros**: Todos los registros de transacciones, transacciones recurrentes, saldos de cuentas y presupuestos se guardan estrictamente en tu dispositivo. No tenemos un servidor central y no tenemos acceso a tus datos financieros.

## 2. Seguridad
* **Autenticación Biométrica**: Stalvi utiliza la autenticación biométrica del dispositivo (huella dactilar o FaceID) como método de acceso principal, junto con un PIN seguro. Las credenciales biométricas son gestionadas exclusivamente por el sistema operativo del dispositivo (Android Keystore / iOS Secure Enclave) y jamás son leídas ni transmitidas por la aplicación.
* **Almacenamiento Local Cifrado**: La base de datos local está cifrada con SQLCipher. La clave criptográfica se genera en el primer inicio y se almacena de forma segura en el llavero del dispositivo (iOS) o Keystore (Android). Ningún dato abandona el dispositivo de forma no cifrada.
* **PIN del Dispositivo**: Un PIN definido por el usuario (4–8 dígitos) actúa como capa de seguridad adicional y alternativa, almacenado mediante Flutter Secure Storage respaldado por el cifrado a nivel de plataforma.

## 3. Exportación e Importación de Datos
* **Exportación**: Stalvi te permite exportar tus datos financieros en varios formatos (copia de seguridad cifrada, CSV, PDF). Las copias de seguridad cifradas están protegidas con una contraseña AES-256 que tú eliges. Eres el único responsable de la seguridad y confidencialidad de los archivos exportados y las contraseñas.
* **Importación / Restauración**: Puedes importar una copia de seguridad cifrada previamente exportada para restaurar tus datos. La importación sobrescribirá todos los datos actuales del dispositivo. Stalvi nunca sube, sincroniza ni comparte los archivos exportados con ningún servidor.
* **Tu Propiedad**: Todos los datos exportados te pertenecen íntegramente. Stalvi no conserva ninguna copia.

## 4. Servicios de Terceros
No utilizamos herramientas de seguimiento, análisis ni SDK de publicidad de terceros que recopilen o compartan tus datos.

## 5. Exención de Responsabilidad
Todos los cálculos financieros, estadísticas y conversiones de tipos de cambio proporcionados por la aplicación tienen fines únicamente informativos. Son aproximados y pueden variar con el tiempo debido a las fluctuaciones de las divisas. El desarrollador no asume ninguna responsabilidad por las decisiones financieras tomadas en base a estos datos.

## 6. Contacto
Si tienes alguna pregunta o comentario sobre nuestras prácticas de privacidad, puedes contactarnos en privacy@stalvi.app.

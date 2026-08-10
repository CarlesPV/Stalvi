# Términos y Condiciones de Uso

**Fecha de entrada en vigor:** 25 de julio de 2026

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
- PROBLEMA FISCAL, ESTIMACIÓN INCORRECTA DE DEDUCCIONES FISCALES, OMISIÓN O DECLARACIÓN INEXACTA ANTE CUALQUIER AUTORITAT TRIBUTARIA;
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

## 8. Exención de Garantías ("TAL CUAL" y "SEGÓN DISPONIBILIDAD")
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
  [https://github.com/CarlesPV](https://github.com/CarlesPV)

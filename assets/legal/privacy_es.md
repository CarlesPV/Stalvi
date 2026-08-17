# Política de Privacidad

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
- **Repositorio de GitHub y Soporte:** [https://github.com/CarlesPV](https://github.com/CarlesPV)

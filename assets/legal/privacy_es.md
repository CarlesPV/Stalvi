# Política de Privacidad

**Fecha de entrada en vigor:** 22 de julio de 2026

## 1. Introducción
Bienvenido a **Stalvi** ("nosotros", "nuestro" o "la Aplicación"). Stalvi es una aplicación de gestión de finanzas personales diseñada con arquitectura "local-first" y bajo la filosofía de privacidad por diseño (*privacy-by-design*). Estamos firmemente comprometidos a proteger su privacidad y garantizar que sus datos financieros permanezcan confidenciales, seguros y bajo su control exclusivo.

Esta Política de Privacidad explica nuestras prácticas con respecto a la privacidad de datos, seguridad y cumplimiento de los estándares normativos globales, incluyendo:
- El **Reglamento General de Protección de Datos (RGPD)** de la Unión Europea (Reglamento (UE) 2016/679).
- La **Ley Orgánica de Protección de Datos Personales y garantía de los derechos digitales de España (LOPDGDD 3/2018)**.
- La **California Consumer Privacy Act (CCPA)**, modificada por la **California Privacy Rights Act (CPRA)**.

Al utilizar Stalvi, usted acepta las prácticas de privacidad descritas en este documento.

---

## 2. Cero Telemetría y Cero Recopilación de Datos Personales
Stalvi opera bajo un modelo estricto de **Cero Telemetría**.
- **Sin Recopilación por el Desarrollador:** Nosotros, como desarrolladores de la Aplicación, **no** recopilamos, almacenamos, transmitimos, procesamos ni vendemos ninguno de sus datos personales o financieros.
- **Sin Registro de Usuario:** Stalvi no requiere la creación de cuentas de usuario, registro por correo electrónico, número de teléfono ni inicios de sesión en la nube.
- **Sin Análisis ni Seguimiento:** La Aplicación contiene **cero** SDKs de seguimiento de terceros, telemetría, agregadores de informes de fallos (p. ej., Firebase Analytics, Google Analytics, Sentry), software publicitario o herramientas de elaboración de perfiles de comportamiento.

---

## 3. Almacenamiento Local de Datos y Cifrado Avanzado (AES-256)
Todos los datos creados o gestionados dentro de Stalvi (incluidas transacciones financieras, saldos de cuentas, presupuestos, categorías personalizadas, etiquetas y preferencias de usuario) se almacenan exclusivamente en su dispositivo físico.

- **Cifrado SQLCipher AES-256:** La base de datos SQLite subyacente se cifra en reposo mediante **SQLCipher con cifrado AES de 256 bits**. Esto garantiza que, incluso si se obtiene acceso físico al sistema de archivos de su dispositivo, sus datos financieros seguirán siendo ilegibles sin su clave de cifrado.
- **Protección Biométrica y PIN:** El acceso a la Aplicación está protegido por los mecanismos nativos de autenticación biométrica de su dispositivo (huella dactilar, Touch ID o Face ID) y un Número de Identificación Personal (PIN) personalizado.
- **Aislamiento de Datos:** Debido a que los datos nunca salen de su dispositivo para alojarse en nuestros servidores, su información está inherentemente protegida contra brechas en servidores remotos, filtraciones de datos, intercepciones de red y minería de datos corporativa.

---

## 4. Conectividad a Internet y APIs Abiertas de Terceros
Stalvi está diseñado para funcionar completamente sin conexión. La **única** instancia en la que la Aplicación inicia una conexión a Internet es para obtener los tipos de cambio de divisas actualizados.

- **Solicitudes Anónimas de Tipos de Cambio:** Cuando actualiza los tipos de conversión de moneda, Stalvi consulta una API pública de tipos de cambio de terceros a través de HTTPS seguro.
- **Garantías de Privacidad:** Estas solicitudes API son estrictamente anónimas. La solicitud contiene **únicamente** los parámetros de solicitud HTTP estándar necesarios para obtener las tablas de tipos de cambio públicas (p. ej., símbolos de moneda base y destino). **Nunca** se transmiten identificadores de usuario, tokens personales vinculados a IP, identificadores de dispositivo, detalles de cuentas ni importes de transacciones.
- **Sin Publicidad ni Corredores de Datos:** No mantenemos alianzas con anunciantes, redes de afiliados ni corredores de datos (*data brokers*).

---

## 5. Control Absoluto del Usuario y Portabilidad de Datos
Usted mantiene el 100% de la propiedad y el control sobre sus registros financieros y copias de seguridad de datos.

- **Exportación y Portabilidad de Datos:** Puede exportar sus registros financieros en cualquier momento en formatos estándar (como archivos de copia de seguridad cifrados o hojas de cálculo CSV sin cifrar) para transferir sus datos o realizar copias de seguridad manuales.
- **Importación y Restauración de Datos:** Usted decide cuándo y dónde restaurar sus copias de seguridad de la base de datos cifrada.
- **Eliminación de Datos:** Puede eliminar de forma permanente transacciones individuales, restablecer categorías o ejecutar una operación completa de **"Eliminar Todos los Datos"** desde la configuración de la Aplicación. Realizar esta acción purga de forma permanente todas las bases de datos locales cifradas y la configuración almacenada en caché de su dispositivo.

---

## 6. Derechos Normativos (RGPD, LOPDGDD y CCPA/CPRA)

### 6.1. Derechos en la UE / España (RGPD / LOPDGDD)
Bajo el RGPD y la LOPDGDD, los interesados tienen derechos de acceso, rectificación, supresión, limitación del tratamiento, oposición y portabilidad de datos:
- Puesto que todo el procesamiento se realiza localmente en su dispositivo bajo su control físico directo, usted ejerce todos los derechos del interesado directamente desde la interfaz de usuario de la Aplicación (p. ej., editando registros, exportando datos o borrando bases de datos locales).
- Dado que no poseemos ni alojamos sus datos, no podemos acceder, generar, modificar ni eliminar sus datos personales en su nombre.

### 6.2. Residentes de California (CCPA / CPRA)
- **No Venta ni Intercambio de Información Personal:** Stalvi **no** vende, alquila, cede, divulga, difunde, transfiere ni comunica información personal a terceros a cambio de contraprestación monetaria o de otro valor.
- **Derecho a Conocer y Eliminar:** Los usuarios de California pueden ejercer su derecho a conocer qué datos existen y eliminar todos sus datos financieros personales almacenados directamente a través de la interfaz local de la aplicación.

---

## 7. Privacidad de Menores
Stalvi no está dirigido a menores de 14 años (o 13 años en jurisdicciones reguladas por COPPA). No recopilamos a sabiendas datos personales de menores. Dado que todos los datos son creados localmente por el operador del dispositivo, los padres y tutores mantienen la supervisión física completa del uso del dispositivo.

---

## 8. Cambios en esta Política de Privacidad
Podemos actualizar esta Política de Privacidad periódicamente para reflejar actualizaciones de la aplicación o estándares de cumplimiento legal. Las versiones actualizadas se incluirán en los lanzamientos de la Aplicación y se publicarán en nuestro repositorio de código fuente. El uso continuado de Stalvi después de una actualización constituye la aceptación de los términos actualizados.

---

## 9. Información de Contacto
Si tiene preguntas, comentarios o consultas legales con respecto a esta Política de Privacidad, puede ponerse en contacto con el mantenedor del proyecto a través de GitHub:
- **Repositorio / Soporte:** [https://github.com/CarlesPV](https://github.com/CarlesPV)

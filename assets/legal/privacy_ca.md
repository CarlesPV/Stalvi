# Política de Privadesa

**Data d'entrada en vigor:** 25 de juliol de 2026

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

## 10. Actualitzacions de la Política i Informació de Contacte
Podem actualitzar aquesta Política de Privadesa per reflectir millores del programari o canvis normatius. Les actualitzacions s'inclouran en els llançaments de l'aplicació i al repositori.

Per a consultes sobre privadesa, contacta amb el desenvolupador:
- **Repositori de GitHub i Suport:** [https://github.com/CarlesPV](https://github.com/CarlesPV)

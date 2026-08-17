# Termes i Condicions d'Ús

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
  [https://github.com/CarlesPV](https://github.com/CarlesPV)

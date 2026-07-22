# Política de Privadesa

**Data d'entrada en vigor:** 22 de juliol de 2026

## 1. Introducció
Benvingut a **Stalvi** ("nosaltres", "nostre" o "l'Aplicació"). Stalvi és una aplicació de gestió de finances personals dissenyada amb arquitectura "local-first" i sota la filosofia de privadesa des del disseny (*privacy-by-design*). Estem fermament compromesos a protegir la teva privadesa i a garantir que les teves dades financeres romanguin confidencials, segures i sota el teu control exclusiu.

Aquesta Política de Privadesa explica les nostres pràctiques pel que fa a la privadesa de dades, la seguretat i el compliment dels estàndards normatius globals, incloent:
- El **Reglament General de Protecció de Dades (RGPD)** de la Unió Europea (Reglament (UE) 2016/679).
- La **Llei Orgànica de Protecció de Dades Personals i garantia dels drets digitals d'Espanya (LOPDGDD 3/2018)**.
- La **California Consumer Privacy Act (CCPA)**, esmenada per la **California Privacy Rights Act (CPRA)**.

En utilitzar Stalvi, acceptes les pràctiques de privadesa descrites en aquest document.

---

## 2. Zero Telemetria i Zero Recopilació de Dades Personals
Stalvi opera sota un model estricte de **Zero Telemetria**.
- **Sense Recopilació pel Desenvolupador:** Nosaltres, com a desenvolupadors de l'Aplicació, **no** recopilem, emmagatzemem, transmetem, processem ni venem cap de les teves dades personals o financeres.
- **Sense Registre d'Usuari:** Stalvi no requereix la creació de comptes d'usuari, registre per correu electrònic, número de telèfon ni inicis de sessió al núvol.
- **Sense Anàlisi ni Seguiment:** L'Aplicació conté **zero** SDKs de seguiment de tercers, telemetria, agregadors d'informes de fallades (per exemple, Firebase Analytics, Google Analytics, Sentry), programari publicitari o eines d'elaboració de perfils de comportament.

---

## 3. Emmagatzematge Local de Dades i Xifratge Avançat (AES-256)
Totes les dades creades o gestionades dins de Stalvi (incloses transaccions financeres, saldos de comptes, pressupostos, categories personalitzades, etiquetes i preferències d'usuari) s'emmagatzemen exclusivament al teu dispositiu físic.

- **Xifratge SQLCipher AES-256:** La base de dades SQLite subadjacent es xifra en repòs mitjançant **SQLCipher amb xifratge AES de 256 bits**. Això garanteix que, encara que s'obtingui accés físic al sistema de fitxers del teu dispositiu, les teves dades financeres continuaran sent il·legibles sense la teva clau de xifratge.
- **Protecció Biomètrica i PIN:** L'accés a l'Aplicació està protegit pels mecanismes natius d'autenticació biomètrica del teu dispositiu (empremta dactilar, Touch ID o Face ID) i un Número d'Identificació Personal (PIN) personalitzat.
- **Aïllament de Dades:** Atès que les dades mai surten del teu dispositiu per allotjar-se en els nostres servidors, la teva informació està inherentment protegida contra escletxes en servidors remots, filtracions de dades, intercepcions de xarxa i mineria de dades corporativa.

---

## 4. Connectivitat a Internet i APIs Obertes de Tercers
Stalvi està dissenyat per funcionar completament sense connexió. L'**única** instància en què l'Aplicació inicia una connexió a Internet és per obtenir els tipus de canvi de divises actualitzats.

- **Sol·licituds Anònimes de Tipus de Canvi:** Quan actualitzes els tipus de conversió de moneda, Stalvi consulta una API pública de tipus de canvi de tercers a través d'HTTPS segur.
- **Garanties de Privadesa:** Aquestes sol·licituds API són estrictament anònimes. La sol·licitud conté **únicament** els paràmetres de sol·licitud HTTP estàndard necessaris per obtenir les taules de tipus de canvi públiques (per exemple, símbols de moneda base i destí). **Mai** es transmeten identificadors d'usuari, tokens personals vinculats a IP, identificadors de dispositiu, detalls de comptes ni meitats o imports de transaccions.
- **Sense Publicitat ni Corredors de Dades:** No mantenim aliances amb anunciants, xarxes d'afiliats ni corredors de dades (*data brokers*).

---

## 5. Control Absolut de l'Usuari i Portabilitat de Dades
Mantens el 100% de la propietat i el control sobre els teus registres financers i còpies de seguretat de dades.

- **Exportació i Portabilitat de Dades:** Pots exportar els teus registres financers en qualsevol moment en formats estàndard (com fitxers de còpia de seguretat xifrats o fulls de càlcul CSV sense xifrar) per transferir les teves dades o realitzar còpies de seguretat meves o manuals.
- **Importació i Restauració de Dades:** Tu decideixes quan i on restaurar les teves còpies de seguretat de la base de dades xifrada.
- **Eliminació de Dades:** Pots eliminar de forma permanent transaccions individuals, restablir categories o executar una operació completa d'**"Eliminar Totes les Dades"** des de la configuració de l'Aplicació. Realitzar aquesta acció purga de forma permanent totes les bases de dades locals xifrades i la configuració emmagatzemada en memòria cau del teu dispositiu.

---

## 6. Drets Normatius (RGPD, LOPDGDD i CCPA/CPRA)

### 6.1. Drets a la UE / Espanya (RGPD / LOPDGDD)
Sota el RGPD i la LOPDGDD, els interessats tenen drets d'accés, rectificació, supressió, limitació del tractament, oposició i portabilitat de dades:
- Atès que tot el processament es realitza localment al teu dispositiu sota el teu control físic directe, tu exerceixes tots els drets de l'interessat directament des de la interfície d'usuari de l'Aplicació (per exemple, editant registres, exportant dades o esborrant bases de dades locals).
- Atès que no posseïm ni allotgem les teves dades, no podem accedir, generar, modificar ni eliminar les teves dades personals en nom teu.

### 6.2. Residents de Califòrnia (CCPA / CPRA)
- **No Venda ni Intercanvi d'Informació Personal:** Stalvi **no** ven, lloga, cedeix, divulga, difon, transfereix ni comunica informació personal a tercers a canvi de contraprestació monetària o d'altre valor.
- **Dret a Conèixer i Eliminar:** Els usuaris de Califòrnia poden exercir el seu dret a conèixer quines dades existeixen i eliminar totes les seves dades financeres personals emmagatzemades directament a través de la interfície local de l'aplicació.

---

## 7. Privadesa de Menors
Stalvi no està dirigit a menors de 14 anys (o 13 anys en jurisdiccions regulades per COPPA). No recopilem conscientment dades personals de menors. Atès que totes les dades són creades localment per l'operador del dispositiu, els pares i tutors mantenen la supervisió física completa de l'ús del dispositiu.

---

## 8. Canvis en aquesta Política de Privadesa
Podem actualitzar aquesta Política de Privadesa periòdicament per reflectir actualitzacions de l'aplicació o estàndards de compliment legal. Les versions actualitzades s'inclouran en els llançaments de l'Aplicació i es publicaran al nostre repositori de codi font. L'ús continuat de Stalvi després d'una actualització constitueix l'acceptació dels termes actualitzats.

---

## 9. Informació de Contacte
Si tens preguntes, comentaris o consultes legals pel que fa a aquesta Política de Privadesa, pots posar-te en contacte amb el mantenidor del projecte a través de GitHub:
- **Repositori / Suport:** [https://github.com/CarlesPV](https://github.com/CarlesPV)

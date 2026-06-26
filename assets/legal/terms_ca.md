# Termes i Condicions

Benvingut a Stalvi. Aquests Termes i Condicions regeixen l'ús de l'aplicació mòbil sense connexió Stalvi. Al crear un perfil i utilitzar aquesta aplicació, acceptes aquests termes.

## 1. Emmagatzematge Local First
* **Dades Locals**: Stalvi emmagatzema totes les teves dades financeres, comptes, transaccions i categories localment al teu dispositiu.
* **Seguretat i Xifratge**: Les teves dades estan protegides al dispositiu mitjançant el xifratge de base de dades SQLCipher i Flutter Secure Storage. La clau de xifratge de la base de dades s'emmagatzema a l'emmagatzematge segur a nivell de sistema operatiu (iOS Keychain / Android Keystore) i mai no es transmet ni és accessible per Stalvi ni per tercers.

## 2. Autenticació Biomètrica
* **Propòsit**: Stalvi ofereix autenticació biomètrica (petjada digital, Face ID) com una forma còmoda i segura d'accedir a les teves dades. En habilitar aquesta funció, s'emmagatzema una preferència a l'emmagatzematge segur; la verificació biomètrica real és realitzada íntegrament pel sistema operatiu del dispositiu.
* **Opt-In**: L'autenticació biomètrica és estrictament opcional. Pots fer servir el teu PIN com a alternativa en qualsevol moment.
* **Alternativa**: Si l'autenticació biomètrica falla o no està disponible, sempre pots autenticar-te amb el teu PIN.

## 3. Exportació i Importació de Dades
* **Formats d'Exportació**: Stalvi permet exportar les teves dades com a fitxer de còpia de seguretat xifrada, full de càlcul CSV o informe mensual en PDF.
* **Còpies de Seguretat Xifrades**: Els fitxers de còpia de seguretat estan xifrats amb AES-256 usant una contrasenya que tu crees. Ets l'únic responsable de mantenir aquesta contrasenya segura. Les contrasenyes perdudes no es poden recuperar i faran que les còpies de seguretat siguin permanentment inaccessibles.
* **Importació / Restauració**: Importar una còpia de seguretat sobreescriurà permanentment totes les dades existents al dispositiu. Aquesta acció no es pot desfer. Verifica les còpies de seguretat abans de restaurar-les.
* **Sense Implicació de Servidors**: Totes les operacions d'exportació i importació ocorren localment. Stalvi mai no puja fitxers a cap servidor.

## 4. Responsabilitat de l'Usuari
* **Còpia de Seguretat**: Com que Stalvi és una aplicació local-first i no puja les teves dades a cap servidor remot, ets l'únic responsable de fer còpies de seguretat del teu dispositiu i fitxers de base de dades.
* **Pèrdua de Dades**: Si perds el dispositiu o el reinicies sense una còpia de seguretat, els teus registres financers no es podran recuperar.

## 5. Privacitat
No recopilem, transmetem ni venem les teves dades personals o financeres. Les teves dades et pertanyen per complet.

## 6. Actualitzacions dels Termes
Ens reservem el dret d'actualitzar aquests termes en qualsevol moment. L'ús continuat de l'aplicació constitueix l'acceptació dels termes actualitzats.

# Política de Privacitat

La teva privacitat és extremadament important per a nosaltres. Aquesta Política de Privacitat explica com Stalvi gestiona la teva informació.

## 1. Zero Recopilació de Dades
* **Dades Personals**: No recopilem cap dada personal com el nom, nom d'usuari o informació de contacte.
* **Dades Financeres**: Tots els registres de transaccions, saldos de comptes i pressupostos es guarden estrictament al teu dispositiu. No tenim cap servidor central i no tenim accés a les teves dades financeres.

## 2. Seguretat
* **Autenticació Biomètrica**: Stalvi utilitza l'autenticació biomètrica del dispositiu (petjada digital o Face ID) com a mètode d'accés principal, juntament amb un PIN segur. Les credencials biomètriques són gestionades exclusivament pel sistema operatiu del dispositiu (Android Keystore / iOS Secure Enclave) i mai no són llegides ni transmeses per l'aplicació.
* **Emmagatzematge Local Xifrat**: La base de dades local està xifrada amb SQLCipher. La clau criptogràfica es genera en el primer inici i s'emmagatzema de forma segura al clauer del dispositiu (iOS) o Keystore (Android). Cap dada surt del dispositiu de forma no xifrada.
* **PIN del Dispositiu**: Un PIN definit per l'usuari (4–8 dígits) actua com a capa de seguretat addicional i alternativa, emmagatzemat mitjançant Flutter Secure Storage recolzat pel xifratge a nivell de plataforma.

## 3. Exportació i Importació de Dades
* **Exportació**: Stalvi et permet exportar les teves dades financeres en diversos formats (còpia de seguretat xifrada, CSV, PDF). Les còpies de seguretat xifrades estan protegides amb una contrasenya AES-256 que tu tries. Ets l'únic responsable de la seguretat i confidencialitat dels fitxers exportats i les contrasenyes.
* **Importació / Restauració**: Pots importar una còpia de seguretat xifrada exportada prèviament per restaurar les teves dades. La importació sobreescriurà totes les dades actuals del dispositiu. Stalvi mai no puja, sincronitza ni comparteix els fitxers exportats amb cap servidor.
* **La Teva Propietat**: Totes les dades exportades et pertanyen completament. Stalvi no conserva cap còpia.

## 4. Serveis de Tercers
No utilitzem eines de seguiment, anàlisi ni SDK de publicitat de tercers que recopilin o comparteixin les teves dades.

## 5. Contacte
Si tens algun dubte o comentari sobre les nostres pràctiques de privacitat, pots contactar amb nosaltres a privacy@stalvi.app.

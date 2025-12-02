# Partie 1 : Automatisation Bash

Ce répertoire contient le script permettant d'automatiser la création massive d'utilisateurs sur le serveur VPS Linux, conformément aux exigences du TP INF 361.

## Fichiers

* `create_users.sh` : Le script principal d'automatisation.
* `users.txt` : Le fichier source contenant les données des étudiants.

## Prérequis

* Le script doit être exécuté avec les privilèges **root**.
* Le paquet `openssl` doit être installé (présent par défaut sur la plupart des distributions) pour le hachage des mots de passe.

## Utilisation

1.  **Préparation du fichier source**
    Assurez-vous que le fichier `users.txt` est présent dans le même répertoire et formaté ainsi :
    `username;password;fullname;phone;email;shell`

2.  **Rendre le script exécutable**
    ```bash
    chmod +x create_users.sh
    ```

3.  **Exécution**
    Lancez le script en passant le nom du groupe étudiant en paramètre :
    ```bash
    sudo ./create_users.sh students-inf-361
    ```

## Détails Techniques de l'Implémentation

Le script a été conçu de manière modulaire pour garantir robustesse et traçabilité. Voici le détail des blocs logiques :

### 1. Vérifications de Sécurité et Initialisation
Dès le lancement, le script effectue des "Sanity Checks" :
* **Vérification Root :** Utilisation de `$EUID` pour s'assurer que l'utilisateur a les droits d'administration nécessaires pour `useradd` et `apt`.
* **Arguments :** Vérifie la présence du nom de groupe en argument `$1`.
* **Fichier Source :** Teste l'existence du fichier `users.txt` avant de tenter toute lecture.

### 2. Calcul Dynamique des Ressources (Consigne 9)
Plutôt que de fixer une valeur arbitraire pour la mémoire, le script calcule la limite dynamiquement :
* **Extraction :** `grep MemTotal /proc/meminfo` récupère la RAM totale du serveur.
* **Calcul :** Une opération arithmétique Bash `((...))` calcule 20% de cette valeur.
* **Application :** Cette valeur est stockée pour être plus tard injectée dans `/etc/security/limits.conf` avec la directive `as` (Address Space).

### 3. Gestion Intelligente des Shells (Consigne 2c)
Le script ne se contente pas d'assigner le shell demandé. Il suit une logique de résilience :
1.  **Vérification :** Il regarde si le shell existe dans la liste des shells valides (`/etc/shells`).
2.  **Installation Automatique :** Si le shell manque (ex: `zsh`), il tente de l'installer via `apt-get install -y`.
3.  **Fallback (Secours) :** Si l'installation échoue (ex: nom de paquet incorrect ou pas d'internet), il force l'attribution de `/bin/bash` pour garantir que l'utilisateur soit tout de même créé.

### 4. Création Sécurisée des Utilisateurs
La commande `useradd` est le cœur du script, configurée avec des options spécifiques :
* **Hachage SHA-512 :** Les mots de passe ne sont jamais traités en clair. Nous utilisons `openssl passwd -6` pour générer un hash SHA-512 robuste avant la création.
* **Groupes :** L'utilisateur est ajouté à son groupe principal (`students-inf-361`) et au groupe `sudo`.
* **Expiration :** La commande `chage -d 0` force l'expiration immédiate du mot de passe. Au premier login SSH, le système obligera l'étudiant à définir son propre mot de passe.

### 5. Personnalisation de l'Environnement
Pour améliorer l'expérience utilisateur (User Experience) :
* Un fichier `WELCOME.txt` est généré dans le répertoire personnel.
* Le fichier `.bashrc` est modifié pour afficher ce message (`cat WELCOME.txt`) à chaque ouverture de terminal.
* *Note technique :* Une attention particulière a été portée aux permissions (`chown`) pour que l'utilisateur soit bien propriétaire de ces fichiers générés par root.

### 6. Durcissement (Hardening) - Commande `su`
Pour répondre à la contrainte de restriction de la commande `su` (Switch User) :
* Nous avons opté pour une restriction via les permissions du système de fichiers (File System Permissions).
* La commande `chmod o-x /bin/su` retire le droit d'exécution aux utilisateurs "Others" (tous ceux qui ne sont ni root, ni dans le groupe root).
* Cela empêche un utilisateur standard d'invoquer le binaire `su` pour tenter d'escalader ses privilèges ou de changer d'identité latéralement.

### 7. Journalisation (Logging)
Chaque étape critique (succès ou échec) est horodatée et enregistrée dans `/var/log/user_creation.log`. Cela permet à l'administrateur de déboguer le processus a posteriori (ex: savoir pourquoi l'installation de `zsh` a échoué pour un utilisateur précis).

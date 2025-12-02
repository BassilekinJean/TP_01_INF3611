# Partie 0 : Procédure de modification du serveur SSH

Ce document détaille les bonnes pratiques pour sécuriser et modifier la configuration du service SSH sur le serveur VPS.

## 1. Procédure correcte de modification

Pour modifier la configuration du service SSH sans risquer de perdre l'accès au serveur, il est impératif de suivre cet ordre rigoureux :

1.  **Sauvegarde du fichier de configuration actuel :**
    ```bash
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    ```
2.  **Édition du fichier de configuration :**
    ```bash
    sudo nano /etc/ssh/sshd_config
    ```
3.  **Vérification de la syntaxe (ÉTAPE CRUCIALE) :**
    Avant de redémarrer le service, il faut toujours valider que le fichier ne contient pas d'erreurs de syntaxe.
    ```bash
    sudo sshd -t
    ```
    *Si cette commande ne retourne rien, la configuration est valide.*
4.  **Redémarrage du service :**
    Une fois la validation réussie, on applique les changements.
    ```bash
    sudo systemctl restart ssh
    # Ou selon la distribution : sudo systemctl restart sshd
    ```
5.  **Vérification de l'accès :**
    Garder la session actuelle ouverte et tenter une nouvelle connexion SSH dans un autre terminal pour s'assurer que l'accès fonctionne toujours.

## 2. Principal risque encouru

Le risque principal si la procédure ci-dessus n'est pas respectée (notamment l'oubli du `sshd -t`) est le **"Lockout" (l'auto-exclusion)**.

Si le fichier de configuration contient une erreur de syntaxe et que l'on tente de redémarrer le service, le démon SSH (sshd) refusera de démarrer ou plantera. La connexion distante sera coupée et toute nouvelle connexion sera impossible. Sur un serveur VPS distant, cela signifie une perte totale de contrôle, nécessitant souvent un accès via une console de secours (VNC/KVM) fournie par l'hébergeur pour réparer.

## 3. Paramètres de sécurité SSH (Durcissement)

Voici cinq paramètres clés modifiés dans `/etc/ssh/sshd_config` pour renforcer la sécurité, accompagnés de leur justification.

| Paramètre | Configuration | Justification |
| :--- | :--- | :--- |
| **PermitRootLogin** | `PermitRootLogin no` | **Interdit la connexion directe en root.** Le compte `root` existe sur tous les systèmes Linux et est la cible privilégiée des attaques par force brute. Se connecter avec un utilisateur standard puis utiliser `sudo` permet une meilleure traçabilité et sécurité. |
| **PasswordAuthentication** | `PasswordAuthentication no` | **Désactive l'authentification par mot de passe.** Force l'utilisation de clés SSH (publiques/privées). Les clés sont cryptographiquement beaucoup plus robustes que les mots de passe et insensibles aux attaques par dictionnaire basiques. |
| **Port** | `Port 2222` (Exemple) | **Change le port d'écoute par défaut (22).** Bien que ce soit de la "sécurité par l'obscurité", cela réduit drastiquement la taille des fichiers logs et la charge du serveur en évitant les milliers de scans automatisés (bots) qui ciblent spécifiquement le port 22. |
| **AllowUsers** | `AllowUsers etudiant1` | **Liste blanche (Whitelist) des utilisateurs.** Seuls les utilisateurs explicitement listés peuvent se connecter. Même si un attaquant devine le mot de passe d'un autre utilisateur du système (ex: un compte de service), il ne pourra pas se connecter en SSH. |
| **MaxAuthTries** | `MaxAuthTries 3` | **Limite les tentatives d'authentification.** Déconnecte l'utilisateur après 3 essais ratés. Cela ralentit les attaques par force brute et peut être couplé à des outils comme Fail2Ban pour bannir l'IP attaquante. |

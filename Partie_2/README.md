# Partie 2 : Playbook Ansible pour l'automatisation de la création des utilisateurs


Ce répertoire contient le Playbook Ansible permettant d'automatiser la configuration du serveur et la gestion des utilisateurs de manière déclarative et idempotente.

1. Lecture des Données (Module read_csv)
	* Contrairement au Bash où le parsing est manuel, Ansible charge le fichier users.txt dans une variable structurée (users_list). Cela évite les erreurs de lecture liées aux espaces ou aux séparateurs.

	* Détail : La tâche est déléguée à localhost (la machine qui lance Ansible) pour ne pas avoir à copier le fichier texte sur le serveur distant.

2. Gestion des Utilisateurs et Sécurité
	* `Le module ansible.builtin.user` gère l'état complet de l'utilisateur :

	`Idempotence :` Si le playbook est relancé, Ansible ne recrée pas l'utilisateur mais met à jour ses propriétés si elles ont changé.

	`Mots de passe :` Utilisation du filtre Jinja2 | password_hash('sha512') pour sécuriser le mot de passe avant l'envoi au système.

	`Forçage du changement :` La commande chage -d 0 assure que le mot de passe par défaut n'est que temporaire.

3. Gestion des Ressources (Facts)
	* Ansible récupère automatiquement les informations du système (les "Facts"). Nous utilisons ansible_memtotal_mb pour calculer dynamiquement la limite de 20% de RAM, ce qui rend le playbook adaptable à n'importe quel serveur, quelle que soit sa puissance.

4. Notification par Email
	* `Le module community.general.mail` automatise l'envoi des identifiants. Le corps du message est généré dynamiquement en injectant les variables :

	* `{{ ansible_default_ipv4.address }} :` L'adresse IP publique détectée du serveur.

	* `{{ ssh_port }} :` Le port SSH sécurisé défini dans nos variables.

## Fichiers
* `create_users.yml` : Le playbook principal.
* `inventory.ini` : L'inventaire définissant le(s) serveur(s) cible(s).
* `users.txt` : Le fichier source (format CSV).

## Prérequis Techniques
L'exécution de ce playbook nécessite :
* Ansible installé sur le nœud de contrôle.
* La collection `community.general` (pour les modules `read_csv` et `mail`).
* La librairie Python `passlib` (pour le hachage des mots de passe).
* Un serveur SMTP configuré sur la machine cible (ex: Postfix) pour l'envoi réel des emails.

## Exécution
Lancer la commande suivante à la racine du dossier :
```bash
ansible-playbook -i inventory.ini create_users.yml

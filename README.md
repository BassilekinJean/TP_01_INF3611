# TP 1 - INF 361 : Administration Systèmes et Réseaux
**Automatisation de la création d'utilisateurs sous Linux**

* **Étudiant :** Bassilekin jean simonet
* **Niveau :** Licence 3 Informatique - Université de Yaoundé I
* **Date :** Décembre 2025

---

## 📝 Description du Projet

Ce projet a pour objectif de mettre en place une architecture complète d'administration système pour la gestion automatisée des comptes utilisateurs sur un serveur VPS. Il explore trois approches complémentaires de l'administration moderne :
1.  **Le Scripting (Bash)** pour la logique impérative bas niveau.
2.  **La Gestion de Configuration (Ansible)** pour l'automatisation déclarative et industrielle.
3.  **L'Infrastructure as Code (Terraform)** pour l'orchestration du déploiement.

## 📂 Structure du Dépôt

Le projet est organisé en modules indépendants. Le fichier source des utilisateurs (`users.txt`) est dupliqué dans chaque partie pour permettre une exécution autonome.

```text
.
├── README.md                  # Ce rapport global
├── Partie_0/
│   └── README.md              # Réponses théoriques (Procédure & Sécurité SSH)
├── Partie_1/
│   ├── create_users.sh        # Script Bash d'automatisation
│   ├── users.txt              # Fichier source des utilisateurs
│   └── README.md              # Documentation technique du script
├── Partie_2/
│   ├── create_users.yml       # Playbook Ansible
│   ├── inventory.ini          # Fichier d'inventaire
│   ├── users.txt              # Fichier source des utilisateurs
│   └── README.md              # Documentation du playbook
└── Partie_3/
    ├── main.tf                # Configuration principale Terraform
    ├── variables.tf           # Définitions des variables
    ├── terraform.tfvars       # Valeurs des variables (IP, clés...)
    ├── users.txt              # Fichier source des utilisateurs
    └── README.md              # Documentation du déploiement Terraform
    ## 🚀 Fonctionnalités Implémentées

### Sécurité et Durcissement (Partie 0)
* Analyse des procédures de modification sécurisée du service SSH.
* Application des bonnes pratiques : Désactivation du login Root, authentification par clé uniquement, whitelisting, changement de port.

### Automatisation Bash (Partie 1)
* Lecture et parsing robuste d'un fichier CSV.
* Création sécurisée des utilisateurs (Hachage SHA-512).
* Gestion dynamique des ressources :
    * **RAM :** Calcul automatique de 20% de la mémoire totale via `/etc/security/limits.conf`.
    * **Disque :** Limitation de la taille des fichiers.
* Restriction binaire de la commande `su`.

### Industrialisation Ansible (Partie 2)
* Traduction de la logique impérative en modèle déclaratif (Idempotence).
* Utilisation des collections `community.general` pour la gestion CSV et l'envoi d'emails.
* Envoi automatisé des identifiants (IP, Port, User, Pass) par email aux étudiants.

### Déploiement Terraform (Partie 3)
* Utilisation du provider `null_resource` pour interagir avec un serveur existant.
* Injection automatique des scripts et fichiers sources via provisionneurs SSH.
* Exécution distante et gestion des déclencheurs (triggers) de mise à jour.

## 🛠️ Prérequis Techniques

Pour tester l'ensemble du projet, l'environnement de contrôle doit disposer de :
* **OS :** Linux (Ubuntu/Debian recommandé) ou MacOS.
* **Outils :** `git`, `ansible`, `terraform`, `openssl`.
* **Accès :** Une clé SSH publique configurée sur le VPS cible.

## 🔗 Compétences Acquises

Ce TP a permis de valider les compétences suivantes :
* Développement de scripts défensifs (gestion d'erreurs).
* Compréhension fine des droits Unix (UID/GID, Chmod, Chown).
* Sécurisation d'un service critique (SSHD).
* Passage du scripting artisanal à l'IaC (Infrastructure as Code).

---
*Projet réalisé dans le cadre de l'UE INF 361.*


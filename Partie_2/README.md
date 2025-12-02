# Partie 2 : Playbook Ansible pour l'automatisation de la création des utilisateurs

Cette section présente l'automatisation des tâches d'administration via Ansible. Le playbook `create_users.yml` reproduit les fonctionnalités du script Bash (création de comptes, sécurisation, quotas) et ajoute l'envoi automatique d'emails aux utilisateurs.

## 1. Prérequis et Configuration

Avant d'exécuter le playbook, s'assurer que :
* **Ansible est installé** sur la machine de contrôle.
* **La collection community.general** est installée (nécessaire pour le module `mail` et `csv`) :
    ```bash
    ansible-galaxy collection install community.general
    ```
* **Un serveur SMTP** est configuré sur la machine locale (ex: Postfix) ou les paramètres d'un SMTP externe (Gmail, Sendgrid) sont prêts pour le module mail.

### Fichier d'inventaire (`inventory.ini`)
```ini
[webservers]
# Remplacez par la vrai @IP du VPS
192.168.1.10 ansible_user=root

# Partie 3 : Déploiement avec Terraform

Ce module utilise Terraform pour orchestrer l'exécution du script Bash sur le VPS distant. Bien que Terraform soit conçu pour le provisionnement d'infrastructure (IaC), nous l'utilisons ici pour la configuration logicielle via des provisionneurs.

## Fichiers
* `main.tf` : Définit la ressource `null_resource` et les provisionneurs de fichiers et d'exécution.
* `variables.tf` : Déclaration des variables (IP, chemins, utilisateur).
* `terraform.tfvars` : Valeurs concrètes pour l'environnement cible.

## Prérequis
* Terraform installé sur la machine locale.
* Accès SSH configuré vers le serveur cible (clé publique déployée).
* Les fichiers `create_users.sh` et `users.txt` doivent être accessibles (par défaut dans `../Partie_1`).

## Utilisation

1.  **Initialisation :** Télécharge le plugin `hashicorp/null`.
    ```bash
    terraform init
    ```

2.  **Planification :** Vérifie les actions à effectuer.
    ```bash
    terraform plan
    ```

3.  **Application :** Lance le transfert des fichiers et l'exécution du script.
    ```bash
    terraform apply -auto-approve
    ```

## Analyse Technique

### Pourquoi `null_resource` ?
Le serveur VPS étant déjà "acheté" (existant), nous n'avons pas besoin d'utiliser un provider Cloud (AWS, Azure) pour créer une instance. La ressource `null_resource` agit comme un conteneur vide qui nous permet d'utiliser le bloc `connection` SSH et les `provisioners`.

### Les Provisionneurs (`provisioner`)
Nous utilisons deux types de provisionneurs :
1.  **`file`** : Pour transférer le script `create_users.sh` et la source de données `users.txt` de la machine locale vers le dossier `/tmp` du serveur distant.
2.  **`remote-exec`** : Pour rendre le script exécutable (`chmod +x`) et le lancer avec le nom du groupe en argument.

### Gestion des changements (`triggers`)
Nous avons ajouté un bloc `triggers` basé sur le hash MD5 des fichiers sources.
* **Intérêt :** Par défaut, une `null_resource` ne s'exécute qu'une seule fois. Grâce aux triggers, si nous modifions le script Bash ou le fichier users.txt localement, Terraform détectera le changement et relancera l'exécution lors du prochain `apply`.

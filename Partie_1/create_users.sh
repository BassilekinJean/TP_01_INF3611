#!/bin/bash

# ==============================================================================
# Fichier : create_users.sh
# Auteur  : Bassilekin jean simonet
# Date    : 02/12/2025
# Description : Automatisation de la création d'utilisateurs à partir d'un fichier.
# ==============================================================================

# --- Variables Globales ---
LOG_FILE="/var/log/user_creation.log"
INPUT_FILE="users.txt"
GROUP_NAME="$1" # Le nom du groupe est passé en premier argument

# --- Fonction de journalisation ---
log_action() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# --- Vérifications Préliminaires ---
# 1. Vérifier si l'utilisateur est root
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté en tant que root." 
   exit 1
fi

# 2. Vérifier si le nom du groupe est fourni
if [ -z "$GROUP_NAME" ]; then
    echo "Usage: $0 <nom_du_groupe>"
    echo "Exemple: $0 students-inf-361"
    exit 1
fi

# 3. Vérifier si le fichier users.txt existe
if [ ! -f "$INPUT_FILE" ]; then
    log_action "ERREUR: Le fichier $INPUT_FILE est introuvable."
    exit 1
fi

log_action "DÉBUT DU SCRIPT DE CRÉATION D'UTILISATEURS"

# --- Création du groupe principal ---
if ! getent group "$GROUP_NAME" > /dev/null; then
    groupadd "$GROUP_NAME"
    log_action "Groupe '$GROUP_NAME' créé avec succès."
else
    log_action "Le groupe '$GROUP_NAME' existe déjà."
fi

# --- Calcul de la limite RAM (20% de la RAM totale) ---
# On récupère la RAM totale en Ko et on calcule 20%
TOTAL_MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM_LIMIT_KB=$((TOTAL_MEM_KB * 20 / 100))
log_action "Limite RAM calculée (20%): ${RAM_LIMIT_KB} KB"

# --- Traitement du fichier users.txt ligne par ligne ---
while IFS=';' read -r username password fullname phone email preferred_shell; do

    # Ignorer les lignes vides ou mal formées
    [ -z "$username" ] && continue

    log_action "Traitement de l'utilisateur : $username"

    # 1. Gestion du Shell (Consigne 2.c)
    FINAL_SHELL="$preferred_shell"

    # Si le shell n'est pas dans /etc/shells (n'est pas valide/installé)
    if ! grep -q "^$preferred_shell$" /etc/shells; then
        log_action "Le shell $preferred_shell n'est pas installé. Tentative d'installation..."

        # Tentative d'installation (extraction du nom, ex: /bin/zsh -> zsh)
        PKG_NAME=$(basename "$preferred_shell")
        apt-get update -qq && apt-get install -y -qq "$PKG_NAME" >> "$LOG_FILE" 2>&1

        # Vérification post-installation
        if [ $? -eq 0 ] && grep -q "^$preferred_shell$" /etc/shells; then
            log_action "Installation de $PKG_NAME réussie."
        else
            log_action "Échec de l'installation de $PKG_NAME. Attribution de /bin/bash par défaut."
            FINAL_SHELL="/bin/bash"
        fi
    fi

    # 2. Création de l'utilisateur (Consigne 2.a, 2.b, 2.d, 3, 6)
    # -m : Home directory
    # -s : Shell
    # -G : Groupes secondaires (le groupe étudiant et sudo)
    # -c : Commentaire (Nom complet, Tel, Email)
    if id "$username" &>/dev/null; then
        log_action "L'utilisateur $username existe déjà. Ignoré."
    else
        # Hachage du mot de passe (SHA-512) (Consigne 4)
        HASHED_PASS=$(openssl passwd -6 "$password")

        useradd -m -s "$FINAL_SHELL" \
                -G "$GROUP_NAME,sudo" \
                -c "$fullname,$phone,$email" \
                -p "$HASHED_PASS" \
                "$username"

        if [ $? -eq 0 ]; then
            log_action "Compte utilisateur $username créé."

            # 3. Forcer le changement de mot de passe (Consigne 5)
            chage -d 0 "$username"
            log_action "Changement de mot de passe forcé pour $username."

            # 4. Message de bienvenue (Consigne 7)
            echo -e "Bienvenue sur le serveur VPS !\nBon travail pratique." > "/home/$username/WELCOME.txt"
            echo "cat ~/WELCOME.txt" >> "/home/$username/.bashrc"
            chown "$username:$username" "/home/$username/WELCOME.txt" # Correction droits

            # 5. Limites de ressources (Consignes 8 & 9)
            # Ajout dans /etc/security/limits.conf
            # Limite Espace Disque (approx via taille fichier max, car quota nécessite partitionnement)
            # 15 Go = 15728640 Ko
            echo "$username hard fsize 15728640" >> /etc/security/limits.conf

            # Limite RAM (address space)
            echo "$username hard as $RAM_LIMIT_KB" >> /etc/security/limits.conf

            log_action "Limites (Disk: 15Go, RAM: 20%) appliquées pour $username."

        else
            log_action "ERREUR: Échec de la création de l'utilisateur $username."
        fi
    fi

done < "$INPUT_FILE"

# --- Restriction de la commande SU (Consigne 6/30) ---
# On modifie les droits de /bin/su pour qu'il ne soit exécutable que par root
# Retrait des droits d'exécution pour 'others' (o-x)
chmod o-x /bin/su
log_action "Restriction de la commande 'su' appliquée (chmod o-x /bin/su)."

log_action "FIN DU SCRIPT."

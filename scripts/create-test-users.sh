#!/bin/bash

# Script de création des utilisateurs de test
# Auteur: Projet Sécurité Systèmes d'Exploitation

set -e

echo "=========================================="
echo "Création des Utilisateurs de Test"
echo "=========================================="

# Vérifier les droits root
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté en tant que root"
   exit 1
fi

# Fonction pour créer un utilisateur
create_user() {
    local username=$1
    local group=$2
    local password=$3
    
    # Créer l'utilisateur s'il n'existe pas
    if ! id "$username" &>/dev/null; then
        useradd -m -s /bin/bash "$username"
        echo "[✓] Utilisateur créé: $username"
    else
        echo "[!] Utilisateur existe déjà: $username"
    fi
    
    # Ajouter au groupe
    usermod -a -G "$group" "$username"
    echo "[✓] $username ajouté au groupe: $group"
    
    # Définir le mot de passe
    echo "$username:$password" | chpasswd
    echo "[✓] Mot de passe défini pour: $username"
}

# Créer les utilisateurs de test
echo "[*] Création des utilisateurs de test..."
echo ""

# Utilisateur du groupe "allowed"
create_user "user_allowed" "allowed" "password123"
echo ""

# Utilisateur du groupe "denied"
create_user "user_denied" "denied" "password456"
echo ""

# Utilisateur du groupe "admin"
create_user "user_admin" "admin" "password789"
echo ""

# Afficher le résumé
echo "=========================================="
echo "Utilisateurs Créés"
echo "=========================================="
echo "Groupe 'allowed':"
echo "  - Utilisateur: user_allowed"
echo "  - Mot de passe: password123"
echo ""
echo "Groupe 'denied':"
echo "  - Utilisateur: user_denied"
echo "  - Mot de passe: password456"
echo ""
echo "Groupe 'admin':"
echo "  - Utilisateur: user_admin"
echo "  - Mot de passe: password789"
echo "=========================================="

# Afficher les groupes
echo ""
echo "Vérification des groupes:"
echo ""
echo "Groupe 'allowed':"
getent group allowed | cut -d: -f4
echo ""
echo "Groupe 'denied':"
getent group denied | cut -d: -f4
echo ""
echo "Groupe 'admin':"
getent group admin | cut -d: -f4

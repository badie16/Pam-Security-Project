#!/bin/bash

# Script de nettoyage
# Auteur: Projet Sécurité Systèmes d'Exploitation

echo "=========================================="
echo "Nettoyage de la Configuration PAM"
echo "=========================================="

# Vérifier les droits root
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté en tant que root"
   exit 1
fi

# Supprimer les utilisateurs de test
echo "[*] Suppression des utilisateurs de test..."
for user in user_allowed user_denied user_admin; do
    if id "$user" &>/dev/null; then
        userdel -r "$user" 2>/dev/null || true
        echo "[✓] Utilisateur supprimé: $user"
    fi
done

# Supprimer les groupes
echo "[*] Suppression des groupes..."
for group in allowed denied admin; do
    if getent group "$group" > /dev/null; then
        groupdel "$group" 2>/dev/null || true
        echo "[✓] Groupe supprimé: $group"
    fi
done

echo ""
echo "=========================================="
echo "Nettoyage Terminé"
echo "=========================================="

#!/bin/bash

# Script de validation de la configuration PAM
# Auteur: Projet Sécurité Systèmes d'Exploitation

echo "=========================================="
echo "Validation de la Configuration PAM"
echo "=========================================="

# Vérifier les groupes
echo "[*] Vérification des groupes..."
echo ""
for group in allowed denied admin; do
    if getent group "$group" > /dev/null; then
        echo "[✓] Groupe '$group' existe"
        echo "    Membres: $(getent group $group | cut -d: -f4)"
    else
        echo "[✗] Groupe '$group' n'existe pas"
    fi
done

echo ""
echo "[*] Vérification des fichiers de configuration..."
echo ""

# Vérifier access.conf
if [ -f /etc/security/access.conf ]; then
    echo "[✓] /etc/security/access.conf existe"
    echo "    Contenu pertinent:"
    grep -E "^[+-]:" /etc/security/access.conf | head -5
else
    echo "[✗] /etc/security/access.conf n'existe pas"
fi

echo ""

# Vérifier limits.conf
if [ -f /etc/security/limits.conf ]; then
    echo "[✓] /etc/security/limits.conf existe"
    echo "    Limites configurées:"
    grep "@" /etc/security/limits.conf | grep -E "(allowed|denied|admin)" | head -5
else
    echo "[✗] /etc/security/limits.conf n'existe pas"
fi

echo ""

# Vérifier les utilisateurs
echo "[*] Vérification des utilisateurs de test..."
echo ""
for user in user_allowed user_denied user_admin; do
    if id "$user" &>/dev/null; then
        groups=$(id -Gn "$user" | tr ' ' ',')
        echo "[✓] Utilisateur '$user' existe"
        echo "    Groupes: $groups"
    else
        echo "[!] Utilisateur '$user' n'existe pas"
    fi
done

echo ""
echo "=========================================="
echo "Validation Terminée"
echo "=========================================="

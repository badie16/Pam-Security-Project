#!/bin/bash

# Script de nettoyage complet - Restaure l'état initial du système
# Auteur: 0xBadie

set -euo pipefail

echo "=========================================="
echo "Nettoyage Complet de la Configuration PAM"
echo "=========================================="
echo ""

# Vérifier les droits root
if [[ $EUID -ne 0 ]]; then
   echo "[✗] ERREUR: Ce script doit être exécuté en tant que root"
   exit 1
fi

BACKUP_DIR=$(find /root -maxdepth 1 -name "pam-backup-*" -type d | sort -r | head -1)

# ============================================
# 1. SUPPRIMER LES UTILISATEURS DE TEST
# ============================================
echo "[*] Étape 1: Suppression des utilisateurs de test..."
for user in user_allowed user_denied user_admin; do
    if id "$user" &>/dev/null; then
        echo "  [→] Suppression de l'utilisateur: $user"
        userdel -r "$user" 2>/dev/null || {
            echo "  [!] Impossible de supprimer $user (peut-être en cours d'utilisation)"
            pkill -9 -u "$user" 2>/dev/null || true
            userdel -r -f "$user" 2>/dev/null || true
        }
        echo "  [✓] Utilisateur supprimé: $user"
    else
        echo "  [✓] Utilisateur n'existe pas: $user"
    fi
done
echo ""

# ============================================
# 2. SUPPRIMER LES GROUPES
# ============================================
echo "[*] Étape 2: Suppression des groupes..."
for group in allowed denied admin; do
    if getent group "$group" > /dev/null; then
        echo "  [→] Suppression du groupe: $group"
        groupdel "$group" 2>/dev/null || {
            echo "  [!] Impossible de supprimer le groupe $group"
            groupdel -f "$group" 2>/dev/null || true
        }
        echo "  [✓] Groupe supprimé: $group"
    else
        echo "  [✓] Groupe n'existe pas: $group"
    fi
done
echo ""

# ============================================
# 3. RESTAURER LES FICHIERS DE CONFIGURATION
# ============================================
echo "[*] Étape 3: Restauration des fichiers de configuration..."

if [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
    echo "  [→] Sauvegarde trouvée: $BACKUP_DIR"
    
    # Restaurer /etc/pam.d
    if [[ -d "$BACKUP_DIR/pam.d" ]]; then
        echo "  [→] Restauration de /etc/pam.d..."
        cp -r "$BACKUP_DIR/pam.d"/* /etc/pam.d/ 2>/dev/null || true
        echo "  [✓] /etc/pam.d restauré"
    fi
    
    # Restaurer /etc/security/access.conf
    if [[ -f "$BACKUP_DIR/access.conf" ]]; then
        echo "  [→] Restauration de /etc/security/access.conf..."
        cp "$BACKUP_DIR/access.conf" /etc/security/access.conf 2>/dev/null || true
        echo "  [✓] /etc/security/access.conf restauré"
    fi
    
    # Restaurer /etc/security/limits.conf
    if [[ -f "$BACKUP_DIR/limits.conf" ]]; then
        echo "  [→] Restauration de /etc/security/limits.conf..."
        cp "$BACKUP_DIR/limits.conf" /etc/security/limits.conf 2>/dev/null || true
        echo "  [✓] /etc/security/limits.conf restauré"
    fi
else
    echo "  [!] Aucune sauvegarde trouvée. Suppression manuelle des configurations..."
    
    # Supprimer les configurations personnalisées
    if [[ -f /etc/pam.d/sshd-custom ]]; then
        echo "  [→] Suppression de /etc/pam.d/sshd-custom..."
        rm -f /etc/pam.d/sshd-custom
        echo "  [✓] /etc/pam.d/sshd-custom supprimé"
    fi
    
    # Nettoyer access.conf (supprimer les lignes ajoutées)
    if [[ -f /etc/security/access.conf ]]; then
        echo "  [→] Nettoyage de /etc/security/access.conf..."
        sed -i '/^# Groupe denied:/,/^-:ALL:ALL$/d' /etc/security/access.conf 2>/dev/null || true
        echo "  [✓] /etc/security/access.conf nettoyé"
    fi
    
    # Nettoyer limits.conf (supprimer les lignes ajoutées)
    if [[ -f /etc/security/limits.conf ]]; then
        echo "  [→] Nettoyage de /etc/security/limits.conf..."
        sed -i '/^# Limites pour le groupe/,/^@admin hard nofile 65536$/d' /etc/security/limits.conf 2>/dev/null || true
        echo "  [✓] /etc/security/limits.conf nettoyé"
    fi
fi
echo ""

# ============================================
# 4. SUPPRIMER LES FICHIERS TEMPORAIRES
# ============================================
echo "[*] Étape 4: Suppression des fichiers temporaires..."
TEMP_FILES=(
    "/tmp/pam-test-*"
    "/tmp/auth-test-*"
    "/var/log/pam-audit.log"
)

for pattern in "${TEMP_FILES[@]}"; do
    if ls $pattern 1> /dev/null 2>&1; then
        echo "  [→] Suppression de: $pattern"
        rm -f $pattern 2>/dev/null || true
        echo "  [✓] Fichiers temporaires supprimés"
    fi
done
echo ""

# ============================================
# 5. VÉRIFIER L'ÉTAT FINAL
# ============================================
echo "[*] Étape 5: Vérification de l'état final..."
echo ""

echo "  Utilisateurs restants:"
if id user_allowed &>/dev/null; then
    echo "    [✗] user_allowed existe encore"
else
    echo "    [✓] user_allowed supprimé"
fi

if id user_denied &>/dev/null; then
    echo "    [✗] user_denied existe encore"
else
    echo "    [✓] user_denied supprimé"
fi

if id user_admin &>/dev/null; then
    echo "    [✗] user_admin existe encore"
else
    echo "    [✓] user_admin supprimé"
fi

echo ""
echo "  Groupes restants:"
if getent group allowed > /dev/null; then
    echo "    [✗] Groupe 'allowed' existe encore"
else
    echo "    [✓] Groupe 'allowed' supprimé"
fi

if getent group denied > /dev/null; then
    echo "    [✗] Groupe 'denied' existe encore"
else
    echo "    [✓] Groupe 'denied' supprimé"
fi

if getent group admin > /dev/null; then
    echo "    [✗] Groupe 'admin' existe encore"
else
    echo "    [✓] Groupe 'admin' supprimé"
fi

echo ""

# ============================================
# 6. RÉSUMÉ FINAL
# ============================================
echo "=========================================="
echo "Nettoyage Terminé avec Succès"
echo "=========================================="
echo ""
echo "Actions effectuées:"
echo "  ✓ Utilisateurs de test supprimés"
echo "  ✓ Groupes supprimés"
echo "  ✓ Configurations restaurées"
echo "  ✓ Fichiers temporaires nettoyés"
echo ""
echo "État du système: RESTAURÉ"
echo "=========================================="

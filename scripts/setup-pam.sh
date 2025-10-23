#!/bin/bash

# Script de configuration PAM pour la gestion des groupes d'utilisateurs
# Auteur: 0xBadie
# Date: 2025

set -e

echo "=========================================="
echo "Configuration PAM - Gestion des Groupes"
echo "=========================================="

# Vérifier les droits root
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté en tant que root"
   exit 1
fi

# Créer les répertoires de sauvegarde
BACKUP_DIR="/root/pam-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "[✓] Répertoire de sauvegarde créé: $BACKUP_DIR"

# Sauvegarder les fichiers originaux
echo "[*] Sauvegarde des fichiers de configuration..."
cp -r /etc/pam.d "$BACKUP_DIR/" 2>/dev/null || true
cp /etc/security/access.conf "$BACKUP_DIR/" 2>/dev/null || true
cp /etc/security/limits.conf "$BACKUP_DIR/" 2>/dev/null || true
echo "[✓] Fichiers sauvegardés"

# Créer les groupes d'utilisateurs
echo "[*] Création des groupes d'utilisateurs..."
groupadd -f allowed
groupadd -f denied
groupadd -f admin
echo "[✓] Groupes créés: allowed, denied, admin"

# Configurer les règles d'accès
echo "[*] Configuration des règles d'accès..."
cat > /etc/security/access.conf << 'EOF'
# /etc/security/access.conf
# Format: permission : users : origins
# permission: + (autoriser) ou - (refuser)
# users: username, @groupname, ou ALL
# origins: tty, hostname, ou ALL

# Groupe denied: refuser l'accès SSH
-:@denied:ALL

# Groupe allowed: autoriser l'accès SSH
+:@allowed:ALL
+:@admin:ALL

# Refuser par défaut
-:ALL:ALL
EOF
echo "[✓] Règles d'accès configurées"

# Configurer les limites de ressources
echo "[*] Configuration des limites de ressources..."
cat >> /etc/security/limits.conf << 'EOF'

# Limites pour le groupe "denied"
@denied soft nproc 10
@denied hard nproc 20
@denied soft nofile 100
@denied hard nofile 200

# Limites pour le groupe "allowed"
@allowed soft nproc 1024
@allowed hard nproc 2048
@allowed soft nofile 4096
@allowed hard nofile 8192

# Limites pour le groupe "admin"
@admin soft nproc 4096
@admin hard nproc 8192
@admin soft nofile 65536
@admin hard nofile 65536
EOF
echo "[✓] Limites de ressources configurées"

# Configurer PAM pour SSH
echo "[*] Configuration de PAM pour SSH..."
cat > /etc/pam.d/sshd-custom << 'EOF'
# /etc/pam.d/sshd-custom
# Configuration PAM personnalisée pour SSH

# Authentification standard
auth       required     pam_unix.so nullok try_first_pass
# Contrôle d'accès basé sur les groupes (via access.conf)
auth       required     pam_access.so
# Gestion des sessions
session    required     pam_limits.so
session    required     pam_unix.so
# Mots de passe
password   required     pam_unix.so obscure sha512 rounds=5000000
EOF
echo "[✓] Configuration PAM pour SSH créée"

# Afficher le résumé
echo ""
echo "=========================================="
echo "Configuration Terminée"
echo "=========================================="
echo "Groupes créés:"
echo "  - allowed   (utilisateurs autorisés)"
echo "  - denied    (utilisateurs refusés)"
echo "  - admin     (administrateurs)"
echo ""
echo "Fichiers configurés:"
echo "  - /etc/security/access.conf"
echo "  - /etc/security/limits.conf"
echo "  - /etc/pam.d/sshd-custom"
echo ""
echo "Sauvegarde disponible à: $BACKUP_DIR"
echo "=========================================="

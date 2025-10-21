#!/bin/bash

# Script d'audit de sécurité PAM
# Auteur: Projet Sécurité Systèmes d'Exploitation

AUDIT_FILE="results/security-audit.log"
mkdir -p results
> "$AUDIT_FILE"

echo "=========================================="
echo "Audit de Sécurité PAM"
echo "=========================================="
echo ""

# Fonction pour enregistrer les résultats
audit_log() {
    local check=$1
    local status=$2
    local details=$3
    
    echo "[$status] $check" >> "$AUDIT_FILE"
    if [ -n "$details" ]; then
        echo "    $details" >> "$AUDIT_FILE"
    fi
}

# Audit 1: Vérifier les permissions des fichiers
echo "[Audit 1] Vérification des permissions des fichiers"
echo "=================================================="
files_to_check=(
    "/etc/shadow:600"
    "/etc/passwd:644"
    "/etc/group:644"
    "/etc/security/access.conf:644"
    "/etc/security/limits.conf:644"
)

for file_perm in "${files_to_check[@]}"; do
    file="${file_perm%:*}"
    expected_perm="${file_perm#*:}"
    
    if [ -f "$file" ]; then
        actual_perm=$(stat -c %a "$file" 2>/dev/null || stat -f %A "$file" 2>/dev/null)
        if [ "$actual_perm" = "$expected_perm" ]; then
            echo "[✓] $file: $actual_perm (correct)"
            audit_log "Permissions $file" "PASS" "Permissions: $actual_perm"
        else
            echo "[!] $file: $actual_perm (attendu: $expected_perm)"
            audit_log "Permissions $file" "WARN" "Permissions: $actual_perm (attendu: $expected_perm)"
        fi
    else
        echo "[!] $file: fichier non trouvé"
        audit_log "Permissions $file" "FAIL" "Fichier non trouvé"
    fi
done
echo ""

# Audit 2: Vérifier les utilisateurs sans mot de passe
echo "[Audit 2] Vérification des utilisateurs sans mot de passe"
echo "========================================================"
echo "[*] Utilisateurs avec mot de passe vide:"
awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow | while read user; do
    echo "    [!] $user"
    audit_log "Utilisateur sans mot de passe: $user" "WARN"
done
echo ""

# Audit 3: Vérifier les utilisateurs avec UID 0
echo "[Audit 3] Vérification des utilisateurs avec UID 0"
echo "=================================================="
echo "[*] Utilisateurs avec UID 0 (root):"
awk -F: '($3 == 0) {print $1}' /etc/passwd | while read user; do
    echo "    $user"
    audit_log "Utilisateur UID 0: $user" "INFO"
done
echo ""

# Audit 4: Vérifier les groupes vides
echo "[Audit 4] Vérification des groupes vides"
echo "======================================"
for group in allowed denied admin; do
    members=$(getent group "$group" | cut -d: -f4)
    if [ -z "$members" ]; then
        echo "[!] Groupe '$group' est vide"
        audit_log "Groupe vide: $group" "WARN"
    else
        echo "[✓] Groupe '$group' contient: $members"
        audit_log "Groupe $group" "PASS" "Membres: $members"
    fi
done
echo ""

# Audit 5: Vérifier les règles d'accès
echo "[Audit 5] Vérification des règles d'accès"
echo "======================================"
if [ -f /etc/security/access.conf ]; then
    echo "[*] Règles d'accès configurées:"
    grep -E "^[+-]:" /etc/security/access.conf | while read rule; do
        echo "    $rule"
        audit_log "Règle d'accès" "INFO" "$rule"
    done
else
    echo "[!] Fichier access.conf non trouvé"
    audit_log "Fichier access.conf" "FAIL"
fi
echo ""

# Audit 6: Vérifier les limites de ressources
echo "[Audit 6] Vérification des limites de ressources"
echo "=============================================="
if [ -f /etc/security/limits.conf ]; then
    echo "[*] Limites configurées pour les groupes:"
    grep "@" /etc/security/limits.conf | grep -E "(allowed|denied|admin)" | while read limit; do
        echo "    $limit"
        audit_log "Limite de ressource" "INFO" "$limit"
    done
else
    echo "[!] Fichier limits.conf non trouvé"
    audit_log "Fichier limits.conf" "FAIL"
fi
echo ""

# Audit 7: Vérifier les modules PAM
echo "[Audit 7] Vérification des modules PAM"
echo "===================================="
if [ -f /etc/pam.d/sshd ]; then
    echo "[*] Modules PAM configurés:"
    grep -E "^(auth|session|password)" /etc/pam.d/sshd | while read module; do
        echo "    $module"
        audit_log "Module PAM" "INFO" "$module"
    done
else
    echo "[!] Fichier /etc/pam.d/sshd non trouvé"
    audit_log "Fichier /etc/pam.d/sshd" "FAIL"
fi
echo ""

# Résumé
echo "=========================================="
echo "Audit de Sécurité Terminé"
echo "=========================================="
echo "Résultats sauvegardés dans: $AUDIT_FILE"
echo ""
echo "Résumé:"
echo "======="
cat "$AUDIT_FILE"

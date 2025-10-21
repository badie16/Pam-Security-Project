#!/bin/bash

# Script de tests avancés d'authentification PAM
# Auteur: Projet Sécurité Systèmes d'Exploitation

set -e

RESULTS_FILE="results/advanced-test-results.log"
mkdir -p results
> "$RESULTS_FILE"

echo "=========================================="
echo "Tests Avancés d'Authentification PAM"
echo "=========================================="
echo ""

# Fonction pour enregistrer les résultats
log_result() {
    local test_name=$1
    local status=$2
    local details=$3
    
    echo "[$status] $test_name" >> "$RESULTS_FILE"
    if [ -n "$details" ]; then
        echo "    Détails: $details" >> "$RESULTS_FILE"
    fi
}

# Test 1: Vérifier les groupes
echo "[Test 1] Vérification des groupes"
echo "=================================="
for group in allowed denied admin; do
    if getent group "$group" > /dev/null 2>&1; then
        members=$(getent group "$group" | cut -d: -f4)
        echo "[✓] Groupe '$group' existe"
        echo "    Membres: $members"
        log_result "Groupe $group existe" "PASS" "$members"
    else
        echo "[✗] Groupe '$group' n'existe pas"
        log_result "Groupe $group existe" "FAIL" "Groupe non trouvé"
    fi
done
echo ""

# Test 2: Vérifier les utilisateurs
echo "[Test 2] Vérification des utilisateurs"
echo "======================================"
for user in user_allowed user_denied user_admin; do
    if id "$user" &>/dev/null; then
        user_groups=$(id -Gn "$user")
        echo "[✓] Utilisateur '$user' existe"
        echo "    Groupes: $user_groups"
        log_result "Utilisateur $user existe" "PASS" "$user_groups"
    else
        echo "[!] Utilisateur '$user' n'existe pas"
        log_result "Utilisateur $user existe" "FAIL" "Utilisateur non trouvé"
    fi
done
echo ""

# Test 3: Vérifier les fichiers de configuration
echo "[Test 3] Vérification des fichiers de configuration"
echo "=================================================="
config_files=(
    "/etc/security/access.conf"
    "/etc/security/limits.conf"
    "/etc/pam.d/sshd"
)

for file in "${config_files[@]}"; do
    if [ -f "$file" ]; then
        echo "[✓] Fichier '$file' existe"
        log_result "Fichier $file existe" "PASS"
    else
        echo "[✗] Fichier '$file' n'existe pas"
        log_result "Fichier $file existe" "FAIL"
    fi
done
echo ""

# Test 4: Vérifier les limites de ressources
echo "[Test 4] Vérification des limites de ressources"
echo "=============================================="
for user in user_allowed user_denied user_admin; do
    if id "$user" &>/dev/null; then
        # Obtenir les limites
        nproc_limit=$(su - "$user" -c "ulimit -u" 2>/dev/null || echo "N/A")
        nofile_limit=$(su - "$user" -c "ulimit -n" 2>/dev/null || echo "N/A")
        
        echo "[✓] Limites pour '$user':"
        echo "    Processus (nproc): $nproc_limit"
        echo "    Fichiers ouverts (nofile): $nofile_limit"
        log_result "Limites pour $user" "PASS" "nproc=$nproc_limit, nofile=$nofile_limit"
    fi
done
echo ""

# Test 5: Vérifier les permissions d'accès
echo "[Test 5] Vérification des permissions d'accès"
echo "==========================================="
echo "[*] Vérification du fichier access.conf..."
if [ -f /etc/security/access.conf ]; then
    echo "[✓] Règles d'accès configurées:"
    grep -E "^[+-]:" /etc/security/access.conf | while read line; do
        echo "    $line"
    done
    log_result "Règles d'accès" "PASS"
else
    echo "[✗] Fichier access.conf non trouvé"
    log_result "Règles d'accès" "FAIL"
fi
echo ""

# Test 6: Vérifier la configuration PAM
echo "[Test 6] Vérification de la configuration PAM"
echo "=========================================="
echo "[*] Modules PAM configurés pour SSH:"
if [ -f /etc/pam.d/sshd ]; then
    grep -E "^(auth|session|password)" /etc/pam.d/sshd | while read line; do
        echo "    $line"
    done
    log_result "Configuration PAM" "PASS"
else
    echo "[✗] Fichier /etc/pam.d/sshd non trouvé"
    log_result "Configuration PAM" "FAIL"
fi
echo ""

# Test 7: Vérifier les logs d'authentification
echo "[Test 7] Vérification des logs d'authentification"
echo "=============================================="
if [ -f /var/log/auth.log ]; then
    echo "[✓] Logs d'authentification disponibles"
    echo "[*] Dernières tentatives d'authentification:"
    tail -5 /var/log/auth.log | grep -E "(user_allowed|user_denied|user_admin)" || echo "    Aucune tentative trouvée"
    log_result "Logs d'authentification" "PASS"
elif [ -f /var/log/secure ]; then
    echo "[✓] Logs d'authentification disponibles"
    echo "[*] Dernières tentatives d'authentification:"
    tail -5 /var/log/secure | grep -E "(user_allowed|user_denied|user_admin)" || echo "    Aucune tentative trouvée"
    log_result "Logs d'authentification" "PASS"
else
    echo "[!] Fichier de logs d'authentification non trouvé"
    log_result "Logs d'authentification" "FAIL"
fi
echo ""

# Résumé
echo "=========================================="
echo "Tests Avancés Terminés"
echo "=========================================="
echo "Résultats sauvegardés dans: $RESULTS_FILE"
echo ""
echo "Résumé:"
echo "======="
cat "$RESULTS_FILE"

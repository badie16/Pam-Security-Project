#!/bin/bash

# Script de test d'authentification PAM
# Auteur: 0xBadie

set -euo pipefail

echo "=========================================="
echo "Tests d'Authentification PAM"
echo "=========================================="

# Créer le fichier de résultats
RESULTS_FILE="results/test-results.log"
mkdir -p results
> "$RESULTS_FILE"

check_prerequisites() {
    echo "[*] Vérification des prérequis..."
    
    local missing_prereqs=0
    
    # Vérifier que les fichiers de configuration PAM existent
    if [[ ! -f /etc/pam.d/sshd ]]; then
        echo "[ERROR] /etc/pam.d/sshd n'existe pas"
        missing_prereqs=1
    fi
    
    # Vérifier que les utilisateurs de test existent
    for user in user_allowed user_denied user_admin; do
        if ! id "$user" &>/dev/null; then
            echo "[ERROR] L'utilisateur '$user' n'existe pas"
            missing_prereqs=1
        fi
    done
    
    # Vérifier que les groupes existent
    for group in allowed denied admin; do
        if ! getent group "$group" &>/dev/null; then
            echo "[ERROR] Le groupe '$group' n'existe pas"
            missing_prereqs=1
        fi
    done
    
    if [[ $missing_prereqs -eq 1 ]]; then
        echo "[!] Certains prérequis sont manquants. Veuillez exécuter setup-pam.sh d'abord."
        return 1
    fi
    
    echo "[OK] Tous les prérequis sont présents"
    return 0
}

test_pam_group_access() {
    local username=$1
    local expected_result=$2
    local test_name=$3
    
    echo ""
    echo "Test: $test_name"
    echo "Utilisateur: $username"
    echo "Résultat attendu: $expected_result"
    
    # Vérifier si l'utilisateur appartient aux groupes autorisés
    local user_groups=$(id -Gn "$username" 2>/dev/null || echo "")
    local is_allowed=0
    
    # Vérifier si l'utilisateur est dans le groupe 'allowed' ou 'admin'
    if echo "$user_groups" | grep -qE '\b(allowed|admin)\b'; then
        is_allowed=1
    fi
    
    local result="ÉCHOUÉ"
    local status="FAILED"
    
    if [[ $is_allowed -eq 1 ]]; then
        result="RÉUSSI"
        status="SUCCESS"
    fi
    
    echo "Résultat: $result"
    echo "Groupes: $user_groups"
    echo ""
    
    # Enregistrer dans le fichier de résultats
    echo "[$status] $test_name - $username" >> "$RESULTS_FILE"
}

test_resource_limits() {
    local username=$1
    local test_name=$2
    
    echo ""
    echo "Test: $test_name"
    echo "Utilisateur: $username"
    
    # Vérifier les limites directement depuis /etc/security/limits.conf
    local limits_output=$(grep "^$username" /etc/security/limits.conf 2>/dev/null || echo "Aucune limite définie")
    
    echo "Limites configurées: $limits_output"
    echo ""
    
    echo "Limites de ressources - $username: $limits_output" >> "$RESULTS_FILE"
}

verify_pam_config() {
    echo ""
    echo "Test: Vérification de la configuration PAM"
    echo ""
    
    # Vérifier que pam_access.so est configuré
    if grep -q "pam_access.so" /etc/pam.d/sshd 2>/dev/null; then
        echo "[OK] pam_access.so est configuré dans /etc/pam.d/sshd"
        echo "[OK] pam_access.so configuré" >> "$RESULTS_FILE"
    else
        echo "[ERROR] pam_access.so n'est pas configuré dans /etc/pam.d/sshd"
        echo "[FAILED] pam_access.so non configuré" >> "$RESULTS_FILE"
    fi
    
    # Vérifier que /etc/security/access.conf existe
    if [[ -f /etc/security/access.conf ]]; then
        echo "[OK] /etc/security/access.conf existe"
        echo "[OK] access.conf existe" >> "$RESULTS_FILE"
    else
        echo "[ERROR] /etc/security/access.conf n'existe pas"
        echo "[FAILED] access.conf manquant" >> "$RESULTS_FILE"
    fi
}

# Programme principal
main() {
    if ! check_prerequisites; then
        echo "[!] Impossible de continuer sans les prérequis"
        exit 1
    fi
    
    echo ""
    echo "[*] Exécution des tests d'authentification..."
    echo ""
    
    verify_pam_config
    
    echo ""
    echo "[*] Tests d'accès aux groupes PAM..."
    echo ""
    
    # Test 1: Utilisateur du groupe "allowed"
    test_pam_group_access "user_allowed" "RÉUSSI" "Accès PAM - Groupe allowed"
    
    # Test 2: Utilisateur du groupe "denied"
    test_pam_group_access "user_denied" "ÉCHOUÉ" "Accès PAM - Groupe denied"
    
    # Test 3: Utilisateur du groupe "admin"
    test_pam_group_access "user_admin" "RÉUSSI" "Accès PAM - Groupe admin"
    
    echo ""
    echo "[*] Vérification détaillée des groupes..."
    echo ""
    for user in user_allowed user_denied user_admin; do
        if id "$user" &>/dev/null; then
            local groups=$(id -Gn "$user")
            echo "$user appartient aux groupes: $groups"
            echo "Vérification des groupes - $user: $groups" >> "$RESULTS_FILE"
        else
            echo "[ERROR] L'utilisateur $user n'existe pas"
            echo "[FAILED] Utilisateur $user inexistant" >> "$RESULTS_FILE"
        fi
    done
    
    echo ""
    echo "[*] Vérification des limites de ressources..."
    echo ""
    for user in user_allowed user_denied user_admin; do
        if id "$user" &>/dev/null; then
            test_resource_limits "$user" "Limites de ressources - $user"
        fi
    done
    
    echo ""
    echo "=========================================="
    echo "Tests Terminés"
    echo "=========================================="
    echo "Résultats sauvegardés dans: $RESULTS_FILE"
    echo ""
    echo "Résumé des résultats:"
    cat "$RESULTS_FILE"
}

# Exécuter le programme principal
main "$@"

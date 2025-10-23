#!/bin/bash

# Script de test d'authentification
# Auteur: 0xBadie

echo "=========================================="
echo "Tests d'Authentification PAM"
echo "=========================================="

# Créer le fichier de résultats
RESULTS_FILE="results/test-results.log"
mkdir -p results
> "$RESULTS_FILE"

# Fonction pour tester l'authentification SSH
test_ssh_auth() {
    local username=$1
    local password=$2
    local expected=$3
    local test_name=$4
    
    echo ""
    echo "Test: $test_name"
    echo "Utilisateur: $username"
    echo "Résultat attendu: $expected"
    
    # Tester avec SSH (utilise /etc/pam.d/sshd-custom)
    if sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$username@localhost" "echo 'Authentification réussie'" 2>/dev/null | grep -q "Authentification réussie"; then
        result="RÉUSSI"
        status="SUCCESS"
    else
        result="ÉCHOUÉ"
        status="FAILED"
    fi
    
    echo "Résultat: $result"
    echo ""
    # Enregistrer dans le fichier de résultats
    echo "[$status] $test_name - $username" >> "$RESULTS_FILE"
}

# Tests d'authentification
echo "[*] Exécution des tests d'authentification..."
echo ""

# Vérifier si sshpass est installé
if ! command -v sshpass &> /dev/null; then
    echo "[!] sshpass n'est pas installé. Installation..."
    apt-get update && apt-get install -y sshpass 2>/dev/null || yum install -y sshpass 2>/dev/null
fi

# Test 1: Utilisateur du groupe "allowed"
test_ssh_auth "user_allowed" "password123" "RÉUSSI" "Authentification SSH - Groupe allowed"

# Test 2: Utilisateur du groupe "denied"
test_ssh_auth "user_denied" "password456" "ÉCHOUÉ" "Authentification SSH - Groupe denied"

# Test 3: Utilisateur du groupe "admin"
test_ssh_auth "user_admin" "password789" "RÉUSSI" "Authentification SSH - Groupe admin"

# Test 4: Vérifier les groupes
echo "Test: Vérification des groupes"
echo ""
for user in user_allowed user_denied user_admin; do
    if id "$user" &>/dev/null; then
        groups=$(id -Gn "$user")
        echo "$user appartient aux groupes: $groups"
        echo "Vérification des groupes - $user" >> "$RESULTS_FILE"
    fi
done

echo ""

# Test 5: Vérifier les limites de ressources
echo "Test: Limites de ressources"
echo ""
for user in user_allowed user_denied user_admin; do
    if id "$user" &>/dev/null; then
        limits=$(su - "$user" -c "ulimit -n" 2>/dev/null || echo "N/A")
        echo "$user - Limite de fichiers ouverts: $limits"
        echo "Limites de ressources - $user" >> "$RESULTS_FILE"
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

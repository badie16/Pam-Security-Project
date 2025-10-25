# Guide d'Utilisation - Projet PAM

## Table des Matières

1. [Démarrage Rapide](#démarrage-rapide)
2. [Cas d'Usage](#cas-dusage)
   - [Cas 1 : Ajouter un Nouvel Utilisateur](#cas-1--ajouter-un-nouvel-utilisateur-au-groupe-allowed)
   - [Cas 2 : Modifier les Limites de Ressources](#cas-2--modifier-les-limites-de-ressources)
   - [Cas 3 : Ajouter une Nouvelle Règle d'Accès](#cas-3--ajouter-une-nouvelle-règle-daccès)
   - [Cas 4 : Monitorer les Tentatives d'Authentification](#cas-4--monitorer-les-tentatives-dauthentification)
3. [Dépannage](#dépannage)
4. [Commandes Utiles](#commandes-utiles)
5. [Nettoyage](#nettoyage)
6. [Support](#support)

---

## Démarrage Rapide

### 1. Installation Complète

```bash
# Cloner ou télécharger le projet
cd pam-security-project

# Exécuter le setup
sudo bash scripts/setup-pam.sh

# Créer les utilisateurs de test
sudo bash scripts/create-test-users.sh

# Valider la configuration
bash scripts/validate-config.sh
```

### 2. Tests d'Authentification

```bash
# Tester l'authentification
bash scripts/test-authentication.sh

# Tester les cas avancés
bash scripts/advanced-tests.sh

# Audit de sécurité
bash scripts/security-audit.sh
```

### 3. Vérification Manuelle

```bash
# Vérifier les groupes
getent group allowed
getent group denied
getent group admin

# Vérifier les utilisateurs
id user_allowed
id user_denied
id user_admin

# Tester la connexion
su - user_allowed
# Entrer le mot de passe: password123
```

## Cas d'Usage

### Cas 1 : Ajouter un Nouvel Utilisateur au Groupe "allowed"

```bash
# Créer l'utilisateur
sudo useradd -m -s /bin/bash newuser

# Ajouter au groupe allowed
sudo usermod -a -G allowed newuser

# Définir le mot de passe
sudo passwd newuser

# Vérifier
id newuser
```

### Cas 2 : Modifier les Limites de Ressources

```bash
# Éditer /etc/security/limits.conf
sudo nano /etc/security/limits.conf

# Modifier les limites pour le groupe allowed
@allowed soft nproc 2048
@allowed hard nproc 4096

# Appliquer les changements
# Les limites s'appliquent à la prochaine connexion
```

### Cas 3 : Ajouter une Nouvelle Règle d'Accès

```bash
# Éditer /etc/security/access.conf
sudo nano /etc/security/access.conf

# Ajouter une nouvelle règle
# Exemple: Refuser l'accès à un utilisateur spécifique
-:baduser:ALL

# Appliquer les changements
# Les règles s'appliquent à la prochaine tentative de connexion
```

### Cas 4 : Monitorer les Tentatives d'Authentification

```bash
# Afficher les logs en temps réel
tail -f /var/log/auth.log

# Filtrer par utilisateur
grep user_allowed /var/log/auth.log

# Compter les tentatives échouées
grep "Failed password" /var/log/auth.log | wc -l
```

## Dépannage

### Problème : "Permission denied" pour tous les utilisateurs

**Cause** : Fichier access.conf mal configuré

**Solution** :

```bash
# Vérifier la syntaxe
cat /etc/security/access.conf

# Vérifier les règles
grep -E "^[+-]:" /etc/security/access.conf

# Réinitialiser à la configuration par défaut
sudo bash scripts/setup-pam.sh
```

### Problème : Limites de ressources non appliquées

**Cause** : pam_limits.so non configuré dans PAM

**Solution** :

```bash
# Vérifier la configuration PAM
grep pam_limits /etc/pam.d/sshd-custom

# Si absent, ajouter la ligne
echo "session    required     pam_limits.so" | sudo tee -a /etc/pam.d/sshd-custom
```

### Problème : Utilisateur ne peut pas se connecter

**Cause** : Utilisateur non dans le groupe allowed

**Solution** :

```bash
# Vérifier l'appartenance aux groupes
id username

# Ajouter au groupe allowed
sudo usermod -a -G allowed username

# Vérifier
id username
```

## Commandes Utiles

```bash
# Afficher les groupes
getent group

# Afficher les utilisateurs
getent passwd

# Afficher les limites d'un utilisateur
su - username -c "ulimit -a"

# Afficher les logs d'authentification
tail -f /var/log/auth.log

# Vérifier la configuration PAM
cat /etc/pam.d/sshd-custom

# Vérifier les règles d'accès
cat /etc/security/access.conf

# Vérifier les limites de ressources
cat /etc/security/limits.conf
```


###  Nettoyage

Pour supprimer la configuration et les utilisateurs de test :

```bash
sudo bash scripts/cleanup.sh
```

## Support

Pour plus d'informations, consultez :

- **[INDEX.md](INDEX.md)** - Navigation et guide de lecture
- **[README.md](README.md)** - Guide d'utilisation général
- **[DOCUMENTATION.md](DOCUMENTATION.md)** - Documentation technique détaillée
- **[RAPPORT_RESULTATS.md](RAPPORT_RESULTATS.md)** - Résultats des tests et audit

---

**Dernière mise à jour** : 2025-01-21  
**Version** : 1.0  
**Auteur** : Badie BAHIDA

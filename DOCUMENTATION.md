# Documentation Technique - Projet PAM

## Table des Matières

1. [Introduction à PAM](#1-introduction-à-pam)
2. [Modules PAM Utilisés](#2-modules-pam-utilisés)
3. [Configuration des Groupes](#3-configuration-des-groupes)
4. [Configuration des Règles d'Accès](#4-configuration-des-règles-daccès)
5. [Configuration des Limites de Ressources](#5-configuration-des-limites-de-ressources)
6. [Flux d'Authentification Détaillé](#6-flux-dauthentification-détaillé)
7. [Tests d'Authentification](#7-tests-dauthentification)
8. [Sécurité et Bonnes Pratiques](#8-sécurité-et-bonnes-pratiques)
9. [Dépannage](#9-dépannage)
10. [Conclusion](#10-conclusion)

---

## 1. Introduction à PAM

### Qu'est-ce que PAM ?

PAM (Pluggable Authentication Modules) est un framework d'authentification modulaire qui permet de configurer les méthodes d'authentification sans modifier les applications.

### Architecture PAM

```
Application (SSH, login, sudo)
    ↓
PAM Framework
    ↓
Modules PAM (pam_unix, pam_access, pam_limits, etc.)
    ↓
Système d'authentification (passwd, shadow, groupes)
```

## 2. Modules PAM Utilisés

### pam_unix.so

- **Fonction** : Authentification standard Unix/Linux
- **Configuration** : `auth required pam_unix.so nullok try_first_pass`
- **Paramètres** :
  - `nullok` : Autoriser les mots de passe vides
  - `try_first_pass` : Utiliser le mot de passe précédent


### pam_access.so

- **Fonction** : Contrôle d'accès basé sur les règles
- **Configuration** : `auth required pam_access.so`
- **Fichier de configuration** : `/etc/security/access.conf`

### pam_limits.so

- **Fonction** : Limitation des ressources par utilisateur/groupe
- **Configuration** : `session required pam_limits.so`
- **Fichier de configuration** : `/etc/security/limits.conf`

## 3. Configuration des Groupes

### Création des Groupes

```bash
groupadd allowed    # Utilisateurs autorisés
groupadd denied     # Utilisateurs refusés
groupadd admin      # Administrateurs
```

### Ajout d'Utilisateurs aux Groupes

```bash
usermod -a -G allowed username    # Ajouter au groupe allowed
usermod -a -G denied username     # Ajouter au groupe denied
usermod -a -G admin username      # Ajouter au groupe admin
```

### Vérification des Groupes

```bash
getent group allowed    # Afficher les membres du groupe allowed
id username             # Afficher les groupes d'un utilisateur
```

## 4. Configuration des Règles d'Accès

### Fichier `/etc/security/access.conf`

#### Format

```
permission : users : origins
```

#### Paramètres

- **permission** : `+` (autoriser) ou `-` (refuser)
- **users** : `username`, `@groupname`, ou `ALL`
- **origins** : `tty`, `hostname`, ou `ALL`

#### Exemple

```
# Refuser l'accès au groupe denied
-:@denied:ALL

# Autoriser l'accès au groupe allowed
+:@allowed:ALL
+:@admin:ALL

# Refuser par défaut
-:ALL:ALL
```

## 5. Configuration des Limites de Ressources

### Fichier `/etc/security/limits.conf`

#### Format

```
domain type item value
```

#### Paramètres

- **domain** : `username`, `@groupname`, ou `*`
- **type** : `soft` (limite douce) ou `hard` (limite dure)
- **item** : `nproc` (processus), `nofile` (fichiers ouverts), etc.
- **value** : Valeur numérique

#### Exemple

```
# Limites pour le groupe denied
@denied soft nproc 10
@denied hard nproc 20

# Limites pour le groupe allowed
@allowed soft nproc 1024
@allowed hard nproc 2048

# Limites pour le groupe admin
@admin soft nproc 4096
@admin hard nproc 8192
```

## 6. Flux d'Authentification Détaillé

### Étape 1 : Authentification Unix

```
Utilisateur entre ses identifiants
    ↓
pam_unix.so vérifie le mot de passe dans /etc/shadow
    ↓
Mot de passe correct ? → Continuer
Mot de passe incorrect ? → Échouer
```

### Étape 2 : Contrôle d'Accès

```
pam_access.so consulte /etc/security/access.conf
    ↓
Règle d'accès autorise ? → Continuer
Règle d'accès refuse ? → Échouer
```

### Étape 3 : Application des Limites

```
pam_limits.so applique les limites de ressources
    ↓
Limites appliquées avec succès
    ↓
Authentification réussie
```

## 7. Tests d'Authentification

### Test 1 : Authentification Réussie (Groupe allowed)

```bash
su - user_allowed
# Entrer le mot de passe: password123
# Résultat attendu: Connexion réussie
```

### Test 2 : Authentification Échouée (Groupe denied)

```bash
su - user_denied
# Entrer le mot de passe: password456
# Résultat attendu: Connexion refusée
```

### Test 3 : Vérification des Limites

```bash
su - user_allowed -c "ulimit -n"
# Résultat attendu: 4096 (limite pour le groupe allowed)
```

## 8. Sécurité et Bonnes Pratiques

### Mesures de Sécurité Implémentées

1. **Authentification multi-couches** : Unix + groupe + accès
2. **Contrôle d'accès granulaire** : Par groupe d'utilisateurs
3. **Limitation des ressources** : Prévention des attaques DoS
4. **Audit** : Logging de toutes les tentatives

### Recommandations

1. **Mots de passe forts** : Utiliser des mots de passe complexes
2. **Authentification à deux facteurs** : Ajouter 2FA si possible
3. **Monitoring** : Surveiller les logs d'authentification
4. **Mises à jour** : Mettre à jour régulièrement les règles PAM

### Fichiers de Log

```bash
# Logs d'authentification
tail -f /var/log/auth.log          # Debian/Ubuntu
tail -f /var/log/secure            # CentOS/RHEL

# Logs PAM
grep PAM /var/log/auth.log
```

## 9. Dépannage

### Problème : Authentification échouée pour tous les utilisateurs

**Solution** : Vérifier la syntaxe de `/etc/security/access.conf`

```bash
cat /etc/security/access.conf
```

### Problème : Limites de ressources non appliquées

**Solution** : Vérifier que `pam_limits.so` est configuré dans `/etc/pam.d/sshd-custom`

```bash
grep pam_limits /etc/pam.d/sshd-custom
```

### Problème : Utilisateur ne peut pas se connecter

**Solution** : Vérifier l'appartenance aux groupes

```bash
id username
getent group allowed
```

## 10. Conclusion

Ce projet démontre comment mettre en place un système de sécurité robuste basé sur PAM avec gestion des groupes d'utilisateurs. La configuration est simple, flexible et facilement extensible pour des besoins plus complexes.

---

##  Navigation

- **[INDEX.md](INDEX.md)** - Navigation et guide de lecture
- **[README.md](README.md)** - Vue d'ensemble du projet
- **[GUIDE_UTILISATION.md](GUIDE_UTILISATION.md)** - Guide pratique pour les utilisateurs
- **[RAPPORT_RESULTATS.md](RAPPORT_RESULTATS.md)** - Résultats des tests et audit

---

**Dernière mise à jour** : 2025-01-21  
**Version** : 1.0  
**Auteur** : Badie BAHIDA

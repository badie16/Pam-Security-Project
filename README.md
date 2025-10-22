# Projet de Sécurité PAM - Vérification des Utilisateurs Locaux

## Table des Matières

1. [Objectif](#objectif)
2. [Architecture du Projet](#architecture-du-projet)
   - [Composants Principaux](#1-composants-principaux)
   - [Choix Techniques](#2-choix-techniques)
   - [Structure des Groupes](#3-structure-des-groupes)
   - [Fichiers de Configuration PAM](#4-fichiers-de-configuration-pam)
   - [Flux d'Authentification](#5-flux-dauthentification)
3. [Installation et Configuration](#installation-et-configuration)
4. [Résultats Attendus](#résultats-attendus)
5. [Fichiers du Projet](#fichiers-du-projet)
6. [Sécurité](#sécurité)
7. [Conclusion](#conclusion)

---

## Objectif

Mettre en place un système de contrôle d'accès basé sur PAM (Pluggable Authentication Modules) avec gestion des groupes d'utilisateurs et des permissions d'authentification.

## Architecture du Projet

### 1. Composants Principaux

- **PAM (Pluggable Authentication Modules)** : Framework d'authentification modulaire
- **Groupes d'utilisateurs** : Classification des utilisateurs (autorisé, refusé, admin)
- **Fichiers de configuration** : `/etc/pam.d/` pour les règles d'authentification
- **Scripts de gestion** : Automatisation de la configuration et des tests

### 2. Choix Techniques

#### PAM vs Alternatives

| Critère                 | PAM               | LDAP     | Kerberos      |
| ----------------------- | ----------------- | -------- | ------------- |
| Complexité              | Faible            | Moyenne  | Élevée        |
| Authentification locale | ✓                 | ✗        | ✗             |
| Groupes d'utilisateurs  | ✓                 | ✓        | ✓             |
| Configuration           | Simple            | Complexe | Très complexe |
| **Choix**               | **✓ Sélectionné** | -        | -             |

**Justification** : PAM est idéal pour un projet académique car il offre un bon équilibre entre fonctionnalité et complexité, avec une configuration locale simple.

#### Modules PAM Utilisés

1. **pam_unix.so** : Authentification standard Unix/Linux
2. **pam_group.so** : Gestion des groupes et permissions
3. **pam_access.so** : Contrôle d'accès basé sur les règles
4. **pam_limits.so** : Limitation des ressources par utilisateur

### 3. Structure des Groupes

```c
Utilisateurs
├── Groupe "allowed" (autorisé)
│   ├── Accès SSH autorisé
│   ├── Accès sudo autorisé
│   └── Limite de ressources : standard
├── Groupe "denied" (refusé)
│   ├── Accès SSH refusé
│   ├── Accès sudo refusé
│   └── Limite de ressources : restrictive
└── Groupe "admin" (administrateur)
    ├── Accès SSH autorisé
    ├── Accès sudo autorisé
    └── Limite de ressources : élevée
```

### 4. Fichiers de Configuration PAM

#### `/etc/pam.d/sshd` (SSH)

```bash
# Authentification standard
auth       required     pam_unix.so nullok try_first_pass
# Vérification du groupe
auth       required     pam_group.so use_first_pass
# Contrôle d'accès
auth       required     pam_access.so
# Gestion des sessions
session    required     pam_limits.so
```

#### `/etc/security/access.conf` (Règles d'accès)

```bash
# Format: permission : users : origins
# Groupe denied : refuser l'accès
-:@denied:ALL
# Groupe allowed : autoriser l'accès
+:@allowed:ALL
+:@admin:ALL
# Refuser par défaut
-:ALL:ALL
```

### 5. Flux d'Authentification

```
Tentative de connexion
    ↓
[1] Vérification des identifiants (pam_unix.so)
    ↓
[2] Vérification du groupe (pam_group.so)
    ↓
[3] Vérification des règles d'accès (pam_access.so)
    ↓
[4] Application des limites (pam_limits.so)
    ↓
Authentification réussie/échouée
```

## Installation et Configuration

### Prérequis

- Système Linux (Ubuntu/Debian ou CentOS/RHEL)
- Accès root

### Étapes d'Installation

1. **Exécuter le script de setup**

```bash
sudo bash scripts/setup-pam.sh
```

2. **Créer les utilisateurs de test**

```bash
sudo bash scripts/create-test-users.sh
```

3. **Valider la configuration**

```bash
bash scripts/validate-config.sh
```

4. **Exécuter les tests d'authentification**
```bash
bash scripts/test-authentication.sh
```

## Résultats Attendus

### Cas de Test 1 : Utilisateur du groupe "allowed"

- ✓ Authentification réussie
- ✓ Accès SSH autorisé
- ✓ Accès sudo autorisé

### Cas de Test 2 : Utilisateur du groupe "denied"

- ✗ Authentification échouée
- ✗ Accès SSH refusé
- ✗ Accès sudo refusé

### Cas de Test 3 : Utilisateur du groupe "admin"

- ✓ Authentification réussie
- ✓ Accès SSH autorisé
- ✓ Accès sudo autorisé
- ✓ Limites de ressources élevées

## Fichiers du Projet

```bash
pam-security-project/
├── README.md                          # Ce fichier
├── DOCUMENTATION.md                   # Documentation détaillée
├── scripts/
│   ├── setup-pam.sh                  # Configuration PAM
│   ├── create-test-users.sh          # Création des utilisateurs
│   ├── validate-config.sh            # Validation de la configuration
│   ├── test-authentication.sh        # Tests d'authentification
│   └── cleanup.sh                    # Nettoyage
├── config/
│   ├── access.conf                   # Règles d'accès
│   ├── limits.conf                   # Limites de ressources
│   └── pam-sshd.conf                 # Configuration PAM pour SSH
└── results/
    ├── test-results.log              # Résultats des tests
    └── configuration-report.txt      # Rapport de configuration
```

## Sécurité

### Mesures Implémentées

1. **Authentification multi-couches** : Unix + groupe + accès
2. **Contrôle d'accès granulaire** : Par groupe d'utilisateurs
3. **Limitation des ressources** : Prévention des attaques DoS
4. **Audit** : Logging de toutes les tentatives

### Recommandations

- Utiliser des mots de passe forts
- Activer l'authentification à deux facteurs (2FA)
- Monitorer les logs d'authentification
- Mettre à jour régulièrement les règles PAM

## Conclusion

Ce projet démontre comment mettre en place un système de sécurité robuste basé sur PAM avec gestion des groupes d'utilisateurs. La configuration est simple, flexible et facilement extensible.

---

##  Documentation Complète

- **[INDEX.md](INDEX.md)** - Navigation et guide de lecture
- **[DOCUMENTATION.md](DOCUMENTATION.md)** - Documentation technique détaillée
- **[GUIDE_UTILISATION.md](GUIDE_UTILISATION.md)** - Guide pratique pour les utilisateurs
- **[RAPPORT_RESULTATS.md](RAPPORT_RESULTATS.md)** - Résultats des tests et audit

---

**Dernière mise à jour** : 2025-01-21  
**Version** : 1.0  
**Auteur** : Badie BAHIDA

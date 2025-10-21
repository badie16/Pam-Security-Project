# Index de Documentation - Projet PAM

##  Navigation Rapide

###  Démarrage
- **[README.md](README.md)** - Vue d'ensemble du projet et installation
- **[GUIDE_UTILISATION.md](GUIDE_UTILISATION.md)** - Guide pratique pour les utilisateurs

###  Documentation Technique
- **[DOCUMENTATION.md](DOCUMENTATION.md)** - Documentation technique détaillée
- **[RAPPORT_RESULTATS.md](RAPPORT_RESULTATS.md)** - Résultats des tests et audit

###  Structure du Projet
```bash
pam-security-project/
├── INDEX.md                    # Ce fichier - Navigation
├── README.md                   # Vue d'ensemble
├── DOCUMENTATION.md           # Documentation technique
├── GUIDE_UTILISATION.md       # Guide utilisateur
├── RAPPORT_RESULTATS.md       # Résultats et audit
├── LICENSE                    # Licence du projet
├── config/                    # Fichiers de configuration
│   ├── access.conf
│   ├── limits.conf
│   └── pam-sshd.conf
└── scripts/                   # Scripts d'automatisation
    ├── setup-pam.sh
    ├── create-test-users.sh
    ├── validate-config.sh
    ├── test-authentication.sh
    ├── advanced-tests.sh
    ├── security-audit.sh
    └── cleanup.sh
```

##  Guide de Lecture

### Pour les Débutants
1. Commencez par **[README.md](README.md)** pour comprendre le projet
2. Suivez **[GUIDE_UTILISATION.md](GUIDE_UTILISATION.md)** pour l'installation
3. Consultez **[DOCUMENTATION.md](DOCUMENTATION.md)** pour les détails techniques

### Pour les Administrateurs
1. **[README.md](README.md)** - Architecture et choix techniques
2. **[DOCUMENTATION.md](DOCUMENTATION.md)** - Configuration détaillée
3. **[RAPPORT_RESULTATS.md](RAPPORT_RESULTATS.md)** - Tests et audit

### Pour les Développeurs
1. **[DOCUMENTATION.md](DOCUMENTATION.md)** - Architecture PAM
2. **[RAPPORT_RESULTATS.md](RAPPORT_RESULTATS.md)** - Résultats des tests
3. **[README.md](README.md)** - Structure du projet

##  Objectifs de Chaque Document

| Document | Objectif Principal | Public Cible |
|----------|-------------------|--------------|
| **README.md** | Vue d'ensemble, architecture, installation | Tous |
| **DOCUMENTATION.md** | Détails techniques, configuration PAM | Administrateurs, Développeurs |
| **GUIDE_UTILISATION.md** | Procédures pratiques, dépannage | Utilisateurs, Administrateurs |
| **RAPPORT_RESULTATS.md** | Tests, audit, résultats | Administrateurs, Auditeurs |

##  Liens Utiles

### Installation et Configuration
- [Installation complète](README.md#installation-et-configuration)
- [Scripts d'automatisation](README.md#fichiers-du-projet)
- [Validation de la configuration](GUIDE_UTILISATION.md#2-tests-dauthentification)

### Tests et Audit
- [Tests d'authentification](GUIDE_UTILISATION.md#2-tests-dauthentification)
- [Audit de sécurité](GUIDE_UTILISATION.md#2-tests-dauthentification)
- [Résultats des tests](RAPPORT_RESULTATS.md#4-résultats-des-tests)

### Dépannage
- [Problèmes courants](GUIDE_UTILISATION.md#dépannage)
- [Vérifications de sécurité](RAPPORT_RESULTATS.md#5-audit-de-sécurité)
- [Logs et monitoring](GUIDE_UTILISATION.md#cas-4--monitorer-les-tentatives-dauthentification)

##  Checklist de Déploiement

### Phase 1 : Préparation
- [ ] Système Linux compatible
- [ ] Accès root disponible
- [ ] Connaissance de base de Linux

### Phase 2 : Installation
- [ ] Exécuter `scripts/setup-pam.sh`
- [ ] Créer les utilisateurs de test
- [ ] Valider la configuration

### Phase 3 : Tests
- [ ] Tests d'authentification
- [ ] Tests avancés
- [ ] Audit de sécurité

### Phase 4 : Production
- [ ] Configuration des utilisateurs réels
- [ ] Monitoring des logs
- [ ] Sauvegarde de la configuration

##  Support et Aide

### En cas de problème
1. Consultez la section [Dépannage](GUIDE_UTILISATION.md#dépannage)
2. Vérifiez les [logs d'authentification](GUIDE_UTILISATION.md#cas-4--monitorer-les-tentatives-dauthentification)
3. Exécutez l'[audit de sécurité](GUIDE_UTILISATION.md#2-tests-dauthentification)

### Commandes utiles
```bash
# Vérifier la configuration
bash scripts/validate-config.sh

# Tester l'authentification
bash scripts/test-authentication.sh

# Audit de sécurité
bash scripts/security-audit.sh

# Nettoyage
sudo bash scripts/cleanup.sh
```

---

**Dernière mise à jour** : 2025-01-21  
**Version** : 1.0  
**Auteur** : Badie BAHIDA

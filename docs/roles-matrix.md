# Matrice des Rôles et Habilitations - Pépites Academy

Ce document présente la matrice complète des rôles et leurs permissions dans l'application Pépites Academy.

## Liste des Rôles

| Rôle | Niveau | Description |
|------|--------|-------------|
| **SupAdmin** | 1 | Super Administrateur - Tous les droits |
| **Admin** | 2 | Administrateur - Gestion complète de l'application |
| **EncadreurChef** | 3 | Chef des encadreurs - Structuration et validation |
| **MedecinChef** | 4 | Chef médical - Suivi sanitaire |
| **Encadreur** | 5 | Coach terrain - Application et suivi |
| **SurveillantGeneral** | 6 | Gestionnaire matériel et discipline |
| **Visiteur** | 7 | Lecture seule - Consultation résultats |

## Matrice des Permissions

### Gestion des Utilisateurs

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Créer un utilisateur | ✓ | ✓ | - | - | - | - | - |
| Modifier un utilisateur | ✓ | ✓ | - | - | - | - | - |
| Supprimer un utilisateur | ✓ | ✓ | - | - | - | - | - |
| Attribuer un rôle | ✓ | ✓ | - | - | - | - | - |
| Voir les utilisateurs | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

### Gestion des Saisons

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Ouvrir une saison | ✓ | ✓ | - | - | - | - | - |
| Fermer une saison | ✓ | ✓ | - | - | - | - | - |
| Voir les saisons | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

### Gestion des Académiciens

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Créer un académicien | ✓ | ✓ | ✓ | - | ✓ | - | - |
| Modifier un académicien | ✓ | ✓ | ✓ | - | ✓ | - | - |
| Supprimer un académicien | ✓ | ✓ | - | - | - | - | - |
| Voir les académiciens | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

### Gestion des Encadreurs

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Créer un encadreur | ✓ | ✓ | ✓ | - | - | - | - |
| Modifier un encadreur | ✓ | ✓ | ✓ | - | - | - | - |
| Supprimer un encadreur | ✓ | ✓ | - | - | - | - | - |
| Voir les encadreurs | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

### Gestion des Séances

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Ouvrir une séance | ✓ | ✓ | ✓ | - | ✓ | - | - |
| Fermer une séance | ✓ | ✓ | ✓ | - | ✓ | - | - |
| Voir les séances | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

### Gestion des Entraînements

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Créer un entraînement | ✓ | ✓ | ✓ | - | - | - | - |
| Modifier un entraînement | ✓ | ✓ | ✓ | - | - | - | - |
| Supprimer un entraînement | ✓ | ✓ | ✓ | - | - | - | - |
| Appliquer un entraînement | ✓ | ✓ | ✓ | - | ✓ | - | - |
| Voir les entraînements | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

### Gestion des Ateliers et Exercices

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Créer un atelier | ✓ | ✓ | ✓ | - | - | - | - |
| Modifier un atelier | ✓ | ✓ | ✓ | - | - | - | - |
| Supprimer un atelier | ✓ | ✓ | ✓ | - | - | - | - |
| Créer un exercice | ✓ | ✓ | ✓ | - | - | - | - |
| Voir les ateliers | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

### Évaluations et Annotations

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Créer une annotation | ✓ | ✓ | ✓ | - | ✓ | - | - |
| Modifier une annotation | ✓ | ✓ | ✓ | - | ✓ | - | - |
| Faire une évaluation | ✓ | ✓ | ✓ | - | ✓ | - | - |
| Valider une évaluation | ✓ | ✓ | ✓ | - | - | - | - |
| Voir les annotations | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Voir les évaluations | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

### Bulletins de Formation

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Générer un bulletin | ✓ | ✓ | ✓ | - | ✓ | - | - |
| Valider un bulletin | ✓ | ✓ | ✓ | - | - | - | - |
| Voir les bulletins | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

### Suivi Médical

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Créer une fiche médicale | ✓ | ✓ | - | ✓ | - | - | - |
| Modifier une fiche médicale | ✓ | ✓ | - | ✓ | - | - | - |
| Voir les fiches médicales | ✓ | ✓ | ✓ | ✓ | - | - | - |
| Conseiller les encadreurs | ✓ | ✓ | - | ✓ | - | - | - |

### Gestion du Matériel

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Ajouter du matériel | ✓ | ✓ | - | - | - | ✓ | - |
| Modifier le matériel | ✓ | ✓ | - | - | - | ✓ | - |
| Supprimer du matériel | ✓ | ✓ | - | - | - | - | - |
| Affecter du matériel | ✓ | ✓ | - | - | - | ✓ | - |
| Voir le matériel | ✓ | ✓ | ✓ | - | ✓ | ✓ | ✓ |

### Discipline et Suivi Comportemental

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Enregistrer un incident | ✓ | ✓ | ✓ | - | ✓ | ✓ | - |
| Modifier un incident | ✓ | ✓ | ✓ | - | - | ✓ | - |
| Voir les incidents | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Suivi discipline encadreurs | ✓ | ✓ | ✓ | - | - | ✓ | - |
| Suivi discipline académiciens | ✓ | ✓ | ✓ | - | ✓ | ✓ | - |

### Scanner QR et Présences

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Scanner un QR | ✓ | ✓ | ✓ | - | ✓ | ✓ | - |
| Enregistrer une présence | ✓ | ✓ | ✓ | - | ✓ | ✓ | - |
| Voir les présences | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

### Communication (SMS)

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Envoyer un SMS | ✓ | ✓ | ✓ | - | ✓ | - | - |
| Voir l'historique SMS | ✓ | ✓ | ✓ | - | ✓ | - | - |

### Référentiels

| Action | SupAdmin | Admin | EncadreurChef | MedecinChef | Encadreur | SurveillantGeneral | Visiteur |
|--------|:--------:|:-----:|:-------------:|:-----------:|:---------:|:------------------:|:--------:|
| Ajouter un poste | ✓ | ✓ | - | - | - | - | - |
| Modifier un poste | ✓ | ✓ | - | - | - | - | - |
| Supprimer un poste | ✓ | ✓ | - | - | - | - | - |
| Ajouter un niveau scolaire | ✓ | ✓ | - | - | - | - | - |
| Modifier un niveau scolaire | ✓ | ✓ | - | - | - | - | - |
| Supprimer un niveau scolaire | ✓ | ✓ | - | - | - | - | - |
| Voir les référentiels | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

## Légende

- **✓** : Autorisé
- **-** : Non autorisé

## Hiérarchie des Rôles

```
SupAdmin (Niveau 1)
    └── Admin (Niveau 2)
            └── EncadreurChef (Niveau 3)
                    ├── MedecinChef (Niveau 4)
                    ├── Encadreur (Niveau 5)
                    └── SurveillantGeneral (Niveau 6)
                                    └── Visiteur (Niveau 7)
```

## Dashboards par Rôle

Chaque rôle accède à un dashboard spécifique après connexion :

| Rôle | Dashboard |
|------|-----------|
| SupAdmin | Dashboard complet avec toutes les fonctionnalités |
| Admin | Dashboard administratif avec gestion complète de l'application |
| EncadreurChef | Dashboard structuration (entraînements, ateliers, validations) |
| MedecinChef | Dashboard médical (fiches, suivis, conseils) |
| Encadreur | Dashboard terrain (séances, annotations, suivi académiciens) |
| SurveillantGeneral | Dashboard logistique (matériel, discipline) |
| Visiteur | Dashboard consultation (résultats en lecture seule) |

## Notes d'Implémentation

1. **Héritage des permissions** : Les rôles de niveau supérieur héritent automatiquement des permissions des rôles inférieurs.
2. **Validation côté backend** : Toutes les permissions doivent être validées côté serveur, pas uniquement côté client.
3. **Journalisation** : Les actions sensibles (création, modification, suppression) doivent être journalisées avec l'identité de l'utilisateur.
4. **Granularité** : Le système RBAC permet d'affiner les permissions au niveau de chaque action si nécessaire.

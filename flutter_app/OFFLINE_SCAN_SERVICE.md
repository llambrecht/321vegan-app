# Offline Scan Service - Documentation

## Vue d'ensemble

Le service `OfflineScanService` permet de gérer les confirmations de produits Vegandex même en cas de connexion internet instable ou absente. Les données sont sauvegardées localement et automatiquement synchronisées lorsque la connexion est rétablie.

## Fonctionnalités

### 1. **Sauvegarde locale automatique**

- Chaque scan de produit Vegandex est d'abord sauvegardé en local
- Les données incluent : EAN, latitude, longitude, user_id, timestamp
- Utilise `SharedPreferences` pour la persistance

### 2. **Tentative de synchronisation immédiate**

- Si la connexion internet est disponible, le scan est envoyé immédiatement à l'API
- Si l'envoi réussit, les données locales sont supprimées
- Si l'envoi échoue, les données sont marquées comme "à réessayer"

### 3. **Synchronisation automatique**

- Au démarrage de l'application
- Lorsque l'application revient au premier plan (app resume)
- Tentatives automatiques de réenvoi des scans en attente

### 4. **Indicateur visuel**

- Affichage du nombre de scans en attente en haut de l'écran de scan
- Badge orange avec icône de synchronisation
- Mise à jour automatique après chaque synchronisation réussie

### 5. **Gestion des erreurs**

- Maximum 3 tentatives de réenvoi par scan
- Les scans qui échouent 3 fois restent sauvegardés mais ne sont plus réessayés automatiquement
- Messages utilisateur clairs selon le statut

## Implémentation technique

### Fichiers modifiés

1. **`lib/services/offline_scan_service.dart`** (nouveau)
   - Service principal pour la gestion offline
   - Méthodes de sauvegarde et récupération
   - Logique de retry automatique

2. **`lib/pages/app_pages/Scan/scan.dart`**
   - Intégration du service offline
   - Affichage de l'indicateur de scans en attente
   - Appels automatiques de synchronisation

### Utilisation

```dart
// Poster un scan avec support offline
final (success, response, shouldShowDialog) =
    await OfflineScanService.postScanEventWithOfflineSupport(
  ean: ean,
  latitude: latitude,
  longitude: longitude,
  userId: userId,
);

// Réessayer les scans en attente
final successCount = await OfflineScanService.retryPendingScans();

// Obtenir le nombre de scans en attente
final pendingCount = await OfflineScanService.getPendingCount();
```

## Comportement utilisateur

### Scénario 1 : Connexion internet disponible

1. L'utilisateur scanne un produit Vegandex
2. Les données sont sauvegardées localement
3. L'envoi à l'API se fait immédiatement
4. Si un magasin est détecté, la modal de confirmation s'affiche
5. Les données locales sont supprimées

### Scénario 2 : Pas de connexion internet

1. L'utilisateur scanne un produit Vegandex
2. Les données sont sauvegardées localement
3. Un message orange informe : "Données sauvegardées localement. Elles seront synchronisées automatiquement."
4. L'indicateur "X scan(s) en attente" apparaît en haut de l'écran
5. Pas de modal de confirmation de magasin

### Scénario 3 : Retour de la connexion

1. L'application détecte le retour de la connexion (au démarrage ou resume)
2. Les scans en attente sont automatiquement réessayés
3. Un message vert s'affiche : "✅ X scan(s) Vegandex synchronisé(s) !"
4. L'indicateur de scans en attente disparaît ou est mis à jour

## Stockage des données

### Structure des données sauvegardées

```json
{
  "ean": "3017620422003",
  "latitude": 48.8566,
  "longitude": 2.3522,
  "user_id": 123,
  "timestamp": "2026-01-26T10:30:00.000Z",
  "retry_count": 0
}
```

### Clés SharedPreferences

- `pending_scan_events` : Scans en cours d'envoi
- `failed_scan_events` : Scans ayant échoué (avec compteur de retry)

## Améliorations futures possibles

1. **Détection réseau proactive**
   - Utiliser `connectivity_plus` pour détecter le retour de connexion
   - Réessayer automatiquement dès que le réseau revient

2. **Notification push**
   - Notifier l'utilisateur quand des scans sont synchronisés en arrière-plan

3. **Compression des données**
   - Grouper plusieurs scans dans une seule requête API

4. **Interface de gestion**
   - Permettre à l'utilisateur de voir les scans en attente
   - Option pour forcer la synchronisation
   - Suppression manuelle des scans échoués

5. **Statistiques**
   - Suivre le taux de succès/échec des synchronisations
   - Analyser les patterns de déconnexion

## Avantages

✅ **Aucune perte de données** : Même en cas de fermeture brutale de l'app  
✅ **Expérience utilisateur améliorée** : L'utilisateur peut continuer à utiliser l'app offline  
✅ **Synchronisation transparente** : Pas d'action manuelle requise  
✅ **Feedback visuel clair** : L'utilisateur sait toujours ce qui se passe  
✅ **Robustesse** : Gestion des cas d'échec avec retry automatique

## Dépendances

- `shared_preferences` : Stockage local persistant
- `connectivity_plus` : Vérification de la connexion internet
- Packages existants du projet (déjà présents)

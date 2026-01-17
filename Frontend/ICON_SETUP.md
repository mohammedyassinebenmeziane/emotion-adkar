# 🎨 Guide d'intégration de l'icône personnalisée

## Étapes pour ajouter l'icône DhikrAI

### 1️⃣ **Préparer l'image**
- Téléchargez l'image fournie (icône DhikrAI avec lune et mosquée)
- Redimensionnez-la à **1024x1024 pixels** (format PNG avec transparence)
- Sauvegardez dans: `assets/icon/app_icon.png`

### 2️⃣ **Créer le dossier assets**
```bash
mkdir -p assets/icon
```

### 3️⃣ **Copier l'image**
Placez votre image PNG (1024x1024) dans `assets/icon/app_icon.png`

### 4️⃣ **Installer flutter_launcher_icons**
```bash
flutter pub add dev:flutter_launcher_icons
```

### 5️⃣ **Générer les icônes**
```bash
flutter pub run flutter_launcher_icons:main
```

### 6️⃣ **Vérifier les résultats**

**Android:**
- Les icônes sont dans: `android/app/src/main/res/mipmap-*/launcher_icon.png`
- Vérifiez `AndroidManifest.xml` - l'attribut `android:icon` doit pointer vers `@mipmap/launcher_icon`

**iOS:**
- Les icônes sont dans: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Vérifiez `ios/Runner/Info.plist` pour la configuration

### 7️⃣ **Reconstruire l'app**
```bash
# Nettoyez le cache
flutter clean

# Relancez l'app
flutter run
```

## 📦 Résultats attendus

- ✅ Icône personnalisée sur l'écran d'accueil Android
- ✅ Icône personnalisée sur l'écran d'accueil iOS
- ✅ L'icône respecte les directives de design Material et iOS

## 🎯 Spécifications de l'icône

- **Format**: PNG avec transparence
- **Dimension source**: 1024x1024 pixels
- **Résolutions générées automatiquement**:
  - Android: ldpi (36x36), mdpi (48x48), hdpi (72x72), xhdpi (96x96), xxhdpi (144x144), xxxhdpi (192x192)
  - iOS: Multiples résolutions automatiquement générées

## ⚠️ Notes importantes

1. **Assurez-vous que** `pubspec.yaml` est à jour
2. **L'image doit avoir** un fond avec le logo/texte visible
3. **Format PNG** avec support de la transparence
4. **Respect des proportions**: l'icône sera affichée avec des coins arrondis sur iOS et Android

## 🔄 Si vous changez l'icône plus tard

Remplacez simplement le fichier `assets/icon/app_icon.png` et relancez:
```bash
flutter pub run flutter_launcher_icons:main
flutter clean
flutter run
```

---

**Besoin d'aide?** Les icônes générées apparaîtront une fois que vous relancerez l'app! 🚀

# 🎨 FichesTechniques v3 - ModernUI

## 📋 Vue d'ensemble

**FichesTechniques v3** est une application Windows de gestion des fiches techniques (dashboard, fiches, projets, catalogue, paramètres), entièrement redessinée avec un thème ModernUI (rendu GDI+ + Skia4Delphi) et une interface bilingue arabe/français (support RTL complet).

Technologies : **Delphi 12 / VCL**, **FireDAC (SQL Server)**, **TMS VCL UI Pack**, **Skia4Delphi**.

---

## ✨ Fonctionnalités principales

- 🔐 Connexion sécurisée (hachage SHA-256 + Salt, migration automatique des mots de passe en clair)
- 🖥️ Fenêtre principale MDI avec sidebar de navigation stylisée
- 📊 Tableau de bord avec cartes statistiques colorées
- 📝 Éditeur de fiches techniques avec validation visuelle des champs
- 📁 Gestion des projets et du catalogue d'articles
- ⚙️ Paramètres de l'application + thème clair/sombre (config.ini)
- 🔄 Support RTL arabe complet (`BiDiMode = bdRightToLeft`, champs numériques LTR)
- ⌨️ Raccourcis clavier : Ctrl+S, Ctrl+Q, F5, Escape

---

## 🏗️ Structure du projet

```
Fiche Technique_ModernUI/
├── FichesTechniques.dpr / .dproj   # Programme principal (Delphi 12)
├── uModernTheme.pas                # 🎨 Système de thème centralisé
├── uSkiaTheme.pas                  # Thème Skia4Delphi (requiert sk4d.dll)
├── uGraphicsGDIP.pas               # Dessin personnalisé GDI+
├── uIconsSVG.pas                   # Icônes SVG
├── uUtils_v3.pas                   # Utilitaires + messages centralisés
├── uDataModule_v3.pas              # Module de données FireDAC (connexion SQL Server)
├── uLogin_v3.pas / .dfm            # Formulaire de connexion
├── uMain_v3.pas / .dfm             # Fenêtre principale MDI
├── uDashboard_v3.pas / .dfm        # Tableau de bord
├── uListeFiches_v3.pas / .dfm      # Liste des fiches (grille stylisée + filtres)
├── uFicheTechnique_v3.pas / .dfm   # Éditeur de fiche technique
├── uProjets_v3.pas / .dfm          # Gestion des projets
├── uCatalogue_v3.pas / .dfm        # Catalogue des articles
├── uParametres_v3.pas / .dfm       # Paramètres de l'application
├── uBaseForm.pas                   # Classe de base des formulaires
├── sk4d.dll                        # Runtime Skia4Delphi (requis à l'exécution)
├── compile.bat                     # Compilation en ligne de commande (dcc32)
├── database/
│   └── migration_password_hash.sql # Migration SQL : colonnes PasswordHash / Salt
├── GUIDE_DESIGN_DELPHI.md          # Guide de design Delphi
├── CHANGEMENTS_PANEL_CONTENT.md    # Notes de conception du panel
├── config.ini.example              # 📋 Modèle de configuration non sensible
└── README.md                       # Ce fichier
```

---

## 🔧 Prérequis

1. **Delphi 12** (Embarcadero Studio 23.0) avec licence FireDAC
2. **TMS VCL UI Pack** (composants `TAdvPanel`, `TAdvSmoothButton`, `TAdvEdit`, etc.)
3. **Skia4Delphi** — le fichier `sk4d.dll` fourni doit être déployé à côté de l'exécutable
4. **SQL Server** avec la base de données `GestionFichesTechniques` configurée
5. Compiler en **Win32**

---

## 📦 Installation

1. Cloner le dépôt :
   ```bash
   git clone <URL_DU_DEPOT>
   ```
2. Ouvrir `FichesTechniques.dproj` dans Delphi 12 (ou compiler avec `compile.bat`)
3. Vérifier que les chemins des bibliothèques (TMS VCL UI Pack) sont configurés dans l'IDE
4. Copier `config.ini.example` en `config.ini` **à côté de l'exécutable généré** et l'adapter

### Compilation en ligne de commande

```bat
compile.bat
```

Ce script appelle `dcc32.exe` (Delphi 12, Studio 23.0). Adapter les chemins (`BDS`, `TMS`) à votre installation si nécessaire.

---

## ⚙️ Configuration

Le fichier `config.ini` (créé à partir de `config.ini.example`, **non versionné**) est lu à côté de l'exécutable :

```ini
[Database]
Server=localhost
Database=GestionFichesTechniques
User=sa
Password=MotDePasseASaisir
WindowsAuth=1

[Login]
RememberMe=0
LastUser=

[UI]
ThemeMode=0
```

> ⚠️ **Sécurité** : `config.ini` peut contenir des identifiants SQL Server. Il est exclu du dépôt via `.gitignore` — ne le committez jamais. Sans `config.ini`, l'application utilise les valeurs par défaut (localhost, authentification Windows).

---

## 🗄️ Base de données

- Base : **SQL Server** — `GestionFichesTechniques`
- Connexion : FireDAC (`FDConnection`), paramètres lus dans `config.ini`
- Migration de sécurité (à exécuter **une fois**, idempotente) :
  ```sql
  -- database/migration_password_hash.sql
  ```
  Elle ajoute les colonnes `PasswordHash` / `Salt` à la table `Utilisateurs` et active le hachage SHA-256 + Salt des mots de passe au prochain login.

---

## 🚀 Lancement

- Depuis Delphi : **Run (F9)**
- Depuis l'explorateur : lancer `FichesTechniques.exe` (avec `sk4d.dll` et `config.ini` dans le même dossier)
- Ou : `test.bat`

---

## 📝 Informations de développement

- **Thème** : `uModernTheme.pas` centralise les couleurs et le style. Les procédures `AppliquerTheme*` sont appelées dans `FormCreate` de chaque formulaire.
- **Grilles** : dessin personnalisé `OnDrawColumnCell` (lignes alternées, coloration conditionnelle du statut).
- **Messages** : `ShowSucces()`, `ShowErreur()`, `ShowAvertissement()`, `Confirmer()` centralisés dans `uUtils_v3.pas`.
- **RTL** : formulaires en `bdRightToLeft` ; champs numériques en `bdLeftToRight`.
- **Fichiers versionnés** : uniquement le code source (`.pas`, `.dfm`, `.dpr`, `.dproj`), la migration SQL, la documentation et `config.ini.example`. Les artifacts (`.dcu`, `.exe`, `.res`, `.identcache`, `__history/`, `__recovery/`, logs) sont exclus via `.gitignore`.

---

## 🌐 Compatibilité

- Windows (VCL), compilé **Win32** (dcc32)
- Base : Microsoft SQL Server via FireDAC

---

## 📄 Licence

Aucune licence définie pour l'instant — usage privé. Toute distribution nécessite de disposer des licences Delphi/TMS/Skia4Delphi appropriées.

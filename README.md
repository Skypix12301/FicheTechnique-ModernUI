# 🎨 Fiches Techniques ModernUI - إدارة البطاقات التقنية

## 📋 Vue d'ensemble / نظرة عامة

**Fiches Techniques ModernUI** est une application web moderne de gestion des fiches techniques, devis estimatifs, projets de travaux publics et catalogue de matériaux pour les directions et services techniques des collectivités locales et administrations.

L'application offre une interface bilingue (arabe / français) avec support complet du RTL (Right-to-Left) et conservation de l'orientation LTR pour les valeurs monétaires et numériques.

---

## ✨ Fonctionnalités principales

- 🔐 **Authentification & Session utilisateur** : Connexion sécurisée avec profil administrateur et mémorisation.
- 🖥️ **Navigation & Shell ModernUI** : Barre latérale rétractable, horloge en temps réel, fil d'Ariane et bascule thématique (Clair / Sombre).
- 📊 **Tableau de bord (Dashboard)** : 4 cartes statistiques (Total des fiches, En attente, Validées, Projets actifs), bannière d'estimation globale TTC, et tableau des dernières opérations.
- 📝 **Éditeur complet de Fiches Techniques** :
  - Métadonnées complètes (Projet, Numéro de fiche, Date, Taux TVA, Statut, Intitulé d'opération).
  - Gestion des **Lots** (Terrassements, Gros Œuvres, VRD, etc.) par onglets dynamiques.
  - Lignes de travaux avec désignation, unités réglementaires (m³, m², ml, U, kg, etc.), quantités et prix unitaires.
  - Insertion rapide d'articles depuis le **Catalogue de référence**.
  - **Calcul automatique des totaux** : Sous-totaux par lots, Total HT, Montant TVA, et Total TTC.
  - **Conversion du montant en toutes lettres en arabe** (*Dinars Algériens et centimes*).
- 📁 **Gestion des Projets** : Suivi des opérations avec codes, wilayas, daïras, communes, et maîtres d'ouvrage.
- 📖 **Catalogue d'Articles & Matériaux** : Base de données des prix et travaux unitaires de référence.
- ⚙️ **Paramètres de l'Organisme** : Configuration de l'entête officiel (Ministère, Direction, Commune), taux de TVA par défaut et devise.
- 🖨️ **Impression & Export officiel A4** : Modèle d'impression conforme aux normes administratives avec cadres d'émargement et signatures.
- ⌨️ **Raccourcis clavier** : `Ctrl + S` pour enregistrer, `F5` pour actualiser, `Esc` pour fermer.

---

## 🛠️ Stack Technique

- **Frontend** : React 19, TypeScript, Vite
- **Styling** : Tailwind CSS v4 avec polices arabes Cairo & IBM Plex Sans Arabic
- **Icons** : Lucide React
- **Port** : 3000 (host: 0.0.0.0)

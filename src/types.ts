export type StatutFiche = 'مسودة' | 'قيد الدراسة' | 'مصادق عليه' | 'ملغى';

export interface User {
  id: number;
  username: string;
  fullName: string;
  role: string;
  active: boolean;
  lastLogin?: string;
}

export interface TypeProjet {
  id: number;
  nom: string;
  code: string;
}

export interface Projet {
  id: number;
  typeProjetId: number;
  typeProjetNom: string;
  code: string;
  nom: string;
  wilaya: string;
  daira: string;
  commune: string;
  maitreOuvrage: string;
  dateCreation: string;
}

export interface CatalogueArticle {
  id: number;
  code: string;
  designation: string;
  typeProjetId?: number;
  typeProjetNom?: string;
  unite: string;
  prixUnitaireRef: number;
  actif: boolean;
}

export interface LigneFiche {
  id: string; // unique string id for frontend robustness
  numeroLigne: number;
  designation: string;
  unite: string;
  quantite: number;
  prixUnitaire: number;
  montant: number; // quantite * prixUnitaire
}

export interface LotFiche {
  id: string;
  codeLot: string;
  nomLot: string;
  ordre: number;
  lignes: LigneFiche[];
}

export interface FicheTechnique {
  id: number;
  numeroFiche: string;
  projetId: number;
  operation: string;
  dateCreation: string;
  dateFiche: string;
  tauxTVA: number; // e.g. 9.00 or 19.00
  statut: StatutFiche;
  utilisateurCreation?: string;
  lots: LotFiche[];
  // Calculated summaries
  montantHT: number;
  montantTVA: number;
  montantTTC: number;
}

export interface AppSettings {
  organisme: string;
  direction: string;
  wilaya: string;
  daira: string;
  commune: string;
  tauxTVADefaut: number;
  devise: string;
  themeMode: 'light' | 'dark';
  lang: 'ar' | 'fr';
}

export type NavigationPage =
  | 'dashboard'
  | 'fiches'
  | 'nouvelle_fiche'
  | 'fiche_detail'
  | 'projets'
  | 'catalogue'
  | 'parametres';

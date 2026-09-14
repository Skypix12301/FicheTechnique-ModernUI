import React, { createContext, useContext, useState, useEffect } from 'react';
import {
  User,
  Projet,
  CatalogueArticle,
  FicheTechnique,
  AppSettings,
  NavigationPage,
  TypeProjet,
} from '../types';
import {
  INITIAL_USER,
  INITIAL_PROJETS,
  INITIAL_CATALOGUE,
  INITIAL_FICHES,
  INITIAL_SETTINGS,
  INITIAL_TYPES_PROJETS,
} from '../data/initialData';

interface AppContextType {
  user: User | null;
  login: (u: string, p: string) => boolean;
  logout: () => void;

  currentPage: NavigationPage;
  setCurrentPage: (page: NavigationPage) => void;
  selectedFicheId: number | null;
  openFiche: (id: number) => void;
  openNouvelleFiche: () => void;

  // Data
  typesProjets: TypeProjet[];
  projets: Projet[];
  catalogue: CatalogueArticle[];
  fiches: FicheTechnique[];
  settings: AppSettings;

  // CRUD Projets
  addProjet: (p: Omit<Projet, 'id' | 'dateCreation'>) => Projet;
  updateProjet: (id: number, p: Partial<Projet>) => void;
  deleteProjet: (id: number) => void;

  // CRUD Catalogue
  addArticle: (a: Omit<CatalogueArticle, 'id'>) => void;
  deleteArticle: (id: number) => void;

  // CRUD Fiches
  getFiche: (id: number) => FicheTechnique | undefined;
  saveFiche: (f: FicheTechnique) => FicheTechnique;
  deleteFiche: (id: number) => void;
  validerFiche: (id: number) => void;
  dupliquerFiche: (id: number) => FicheTechnique;
  genererNumeroFiche: (projetId?: number) => string;

  // Settings
  updateSettings: (s: Partial<AppSettings>) => void;
  resetToDefaults: () => void;

  // Theme & Lang
  isDark: boolean;
  toggleTheme: () => void;
  lang: 'ar' | 'fr';
  setLang: (l: 'ar' | 'fr') => void;

  // Print Preview
  printFiche: FicheTechnique | null;
  setPrintFiche: (f: FicheTechnique | null) => void;

  // Notifications
  notification: { type: 'success' | 'error' | 'warning' | 'info'; message: string } | null;
  showNotification: (message: string, type?: 'success' | 'error' | 'warning' | 'info') => void;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // Auth state
  const [user, setUser] = useState<User | null>(() => {
    const saved = localStorage.getItem('ft_user');
    return saved ? JSON.parse(saved) : INITIAL_USER;
  });

  // Navigation
  const [currentPage, setCurrentPage] = useState<NavigationPage>('dashboard');
  const [selectedFicheId, setSelectedFicheId] = useState<number | null>(null);
  const [printFiche, setPrintFiche] = useState<FicheTechnique | null>(null);

  // Entities
  const [typesProjets] = useState<TypeProjet[]>(INITIAL_TYPES_PROJETS);

  const [projets, setProjets] = useState<Projet[]>(() => {
    const saved = localStorage.getItem('ft_projets');
    return saved ? JSON.parse(saved) : INITIAL_PROJETS;
  });

  const [catalogue, setCatalogue] = useState<CatalogueArticle[]>(() => {
    const saved = localStorage.getItem('ft_catalogue');
    return saved ? JSON.parse(saved) : INITIAL_CATALOGUE;
  });

  const [fiches, setFiches] = useState<FicheTechnique[]>(() => {
    const saved = localStorage.getItem('ft_fiches');
    return saved ? JSON.parse(saved) : INITIAL_FICHES;
  });

  const [settings, setSettings] = useState<AppSettings>(() => {
    const saved = localStorage.getItem('ft_settings');
    return saved ? JSON.parse(saved) : INITIAL_SETTINGS;
  });

  const [notification, setNotification] = useState<{
    type: 'success' | 'error' | 'warning' | 'info';
    message: string;
  } | null>(null);

  const showNotification = (
    message: string,
    type: 'success' | 'error' | 'warning' | 'info' = 'success'
  ) => {
    setNotification({ message, type });
    setTimeout(() => {
      setNotification(null);
    }, 4000);
  };

  // Persist changes
  useEffect(() => {
    localStorage.setItem('ft_projets', JSON.stringify(projets));
  }, [projets]);

  useEffect(() => {
    localStorage.setItem('ft_catalogue', JSON.stringify(catalogue));
  }, [catalogue]);

  useEffect(() => {
    localStorage.setItem('ft_fiches', JSON.stringify(fiches));
  }, [fiches]);

  useEffect(() => {
    localStorage.setItem('ft_settings', JSON.stringify(settings));
    if (settings.themeMode === 'dark') {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [settings]);

  useEffect(() => {
    if (user) {
      localStorage.setItem('ft_user', JSON.stringify(user));
    } else {
      localStorage.removeItem('ft_user');
    }
  }, [user]);

  const login = (u: string, _p: string): boolean => {
    // Standard mock authentication supporting any password or admin
    const loggedUser: User = {
      ...INITIAL_USER,
      username: u || 'admin',
      lastLogin: new Date().toLocaleDateString('fr-FR'),
    };
    setUser(loggedUser);
    showNotification('تم تسجيل الدخول بنجاح / Connexion réussie', 'success');
    return true;
  };

  const logout = () => {
    setUser(null);
    setCurrentPage('dashboard');
    showNotification('تم تسجيل الخروج / Déconnexion', 'info');
  };

  const openFiche = (id: number) => {
    setSelectedFicheId(id);
    setCurrentPage('fiche_detail');
  };

  const openNouvelleFiche = () => {
    setSelectedFicheId(null);
    setCurrentPage('nouvelle_fiche');
  };

  // Projects CRUD
  const addProjet = (p: Omit<Projet, 'id' | 'dateCreation'>): Projet => {
    const newId = projets.length > 0 ? Math.max(...projets.map((x) => x.id)) + 1 : 1;
    const newP: Projet = {
      ...p,
      id: newId,
      dateCreation: new Date().toISOString().split('T')[0],
    };
    setProjets((prev) => [newP, ...prev]);
    showNotification(`تمت إضافة المشروع "${newP.nom}" بنجاح`, 'success');
    return newP;
  };

  const updateProjet = (id: number, p: Partial<Projet>) => {
    setProjets((prev) => prev.map((item) => (item.id === id ? { ...item, ...p } : item)));
    showNotification('تم تحديث بيانات المشروع بنجاح', 'success');
  };

  const deleteProjet = (id: number) => {
    // Check if any fiches are attached
    const attachedCount = fiches.filter((f) => f.projetId === id).length;
    if (attachedCount > 0) {
      showNotification(`لا يمكن حذف المشروع لوجود ${attachedCount} بطاقة تقنية مرتبطة به`, 'warning');
      return;
    }
    setProjets((prev) => prev.filter((item) => item.id !== id));
    showNotification('تم حذف المشروع بنجاح', 'success');
  };

  // Catalogue CRUD
  const addArticle = (a: Omit<CatalogueArticle, 'id'>) => {
    const newId = catalogue.length > 0 ? Math.max(...catalogue.map((x) => x.id)) + 1 : 1;
    const newArt: CatalogueArticle = { ...a, id: newId };
    setCatalogue((prev) => [newArt, ...prev]);
    showNotification('تمت إضافة المادة إلى الكتالوج بنجاح', 'success');
  };

  const deleteArticle = (id: number) => {
    setCatalogue((prev) => prev.filter((x) => x.id !== id));
    showNotification('تم حذف المادة من الكتالوج', 'info');
  };

  // Fiches CRUD
  const getFiche = (id: number) => {
    return fiches.find((f) => f.id === id);
  };

  const genererNumeroFiche = (_projetId?: number): string => {
    const year = new Date().getFullYear();
    const count = fiches.length + 1;
    const pad = count < 10 ? `00${count}` : count < 100 ? `0${count}` : `${count}`;
    return `FT-${year}-${pad}`;
  };

  const saveFiche = (ficheData: FicheTechnique): FicheTechnique => {
    // Calculate total HT, TVA, TTC
    let ht = 0;
    const lotsWithCalculations = ficheData.lots.map((lot) => {
      const lignesWithCalculations = lot.lignes.map((ligne) => {
        const montant = (ligne.quantite || 0) * (ligne.prixUnitaire || 0);
        return { ...ligne, montant };
      });
      lignesWithCalculations.forEach((l) => {
        ht += l.montant;
      });
      return { ...lot, lignes: lignesWithCalculations };
    });

    const tva = (ht * (ficheData.tauxTVA || 0)) / 100;
    const ttc = ht + tva;

    const isNew = !ficheData.id || ficheData.id === 0;
    const newId = isNew
      ? fiches.length > 0
        ? Math.max(...fiches.map((x) => x.id)) + 1
        : 1
      : ficheData.id;

    const completeFiche: FicheTechnique = {
      ...ficheData,
      id: newId,
      lots: lotsWithCalculations,
      montantHT: ht,
      montantTVA: tva,
      montantTTC: ttc,
      dateCreation: ficheData.dateCreation || new Date().toISOString().split('T')[0],
      dateFiche: ficheData.dateFiche || new Date().toISOString().split('T')[0],
      utilisateurCreation: ficheData.utilisateurCreation || user?.username || 'admin',
    };

    if (isNew) {
      setFiches((prev) => [completeFiche, ...prev]);
      showNotification(`تم إنشاء البطاقة التقنية ${completeFiche.numeroFiche} بنجاح`, 'success');
    } else {
      setFiches((prev) => prev.map((f) => (f.id === completeFiche.id ? completeFiche : f)));
      showNotification(`تم حفظ التعديلات على البطاقة ${completeFiche.numeroFiche}`, 'success');
    }

    setSelectedFicheId(completeFiche.id);
    return completeFiche;
  };

  const deleteFiche = (id: number) => {
    setFiches((prev) => prev.filter((f) => f.id !== id));
    showNotification('تم حذف البطاقة التقنية بنجاح', 'success');
    if (selectedFicheId === id) {
      setSelectedFicheId(null);
      setCurrentPage('fiches');
    }
  };

  const validerFiche = (id: number) => {
    setFiches((prev) =>
      prev.map((f) => (f.id === id ? { ...f, statut: 'مصادق عليه' as const } : f))
    );
    showNotification('تمت المصادقة على البطاقة التقنية بنجاح', 'success');
  };

  const dupliquerFiche = (id: number): FicheTechnique => {
    const src = fiches.find((f) => f.id === id);
    if (!src) throw new Error('Source non trouvée');

    const newNum = genererNumeroFiche(src.projetId) + '-COPIE';
    const newId = fiches.length > 0 ? Math.max(...fiches.map((x) => x.id)) + 1 : 1;

    const duplicatedLots = src.lots.map((lot, idx) => ({
      ...lot,
      id: `lot-dup-${Date.now()}-${idx}`,
      lignes: lot.lignes.map((ligne, lidx) => ({
        ...ligne,
        id: `l-dup-${Date.now()}-${idx}-${lidx}`,
      })),
    }));

    const copy: FicheTechnique = {
      ...src,
      id: newId,
      numeroFiche: newNum,
      statut: 'مسودة',
      dateCreation: new Date().toISOString().split('T')[0],
      dateFiche: new Date().toISOString().split('T')[0],
      lots: duplicatedLots,
    };

    setFiches((prev) => [copy, ...prev]);
    showNotification(`تم نسخ البطاقة بنجاح برقم جديد: ${newNum}`, 'success');
    openFiche(newId);
    return copy;
  };

  // Settings
  const updateSettings = (newSettings: Partial<AppSettings>) => {
    setSettings((prev) => ({ ...prev, ...newSettings }));
    showNotification('تم حفظ الإعدادات بنجاح', 'success');
  };

  const resetToDefaults = () => {
    setProjets(INITIAL_PROJETS);
    setCatalogue(INITIAL_CATALOGUE);
    setFiches(INITIAL_FICHES);
    setSettings(INITIAL_SETTINGS);
    localStorage.removeItem('ft_projets');
    localStorage.removeItem('ft_catalogue');
    localStorage.removeItem('ft_fiches');
    localStorage.removeItem('ft_settings');
    showNotification('تمت استعادة البيانات النموذجية الأولية بنجاح', 'info');
  };

  const toggleTheme = () => {
    setSettings((prev) => ({
      ...prev,
      themeMode: prev.themeMode === 'dark' ? 'light' : 'dark',
    }));
  };

  const setLang = (l: 'ar' | 'fr') => {
    setSettings((prev) => ({ ...prev, lang: l }));
    document.documentElement.lang = l;
    document.documentElement.dir = l === 'ar' ? 'rtl' : 'ltr';
  };

  return (
    <AppContext.Provider
      value={{
        user,
        login,
        logout,
        currentPage,
        setCurrentPage,
        selectedFicheId,
        openFiche,
        openNouvelleFiche,
        typesProjets,
        projets,
        catalogue,
        fiches,
        settings,
        addProjet,
        updateProjet,
        deleteProjet,
        addArticle,
        deleteArticle,
        getFiche,
        saveFiche,
        deleteFiche,
        validerFiche,
        dupliquerFiche,
        genererNumeroFiche,
        updateSettings,
        resetToDefaults,
        isDark: settings.themeMode === 'dark',
        toggleTheme,
        lang: settings.lang,
        setLang,
        printFiche,
        setPrintFiche,
        notification,
        showNotification,
      }}
    >
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};

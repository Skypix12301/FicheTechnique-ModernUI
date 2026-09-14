import React from 'react';
import {
  LayoutDashboard,
  FileSpreadsheet,
  FilePlus2,
  FolderGit2,
  BookOpen,
  Settings,
  LogOut,
  Building2,
  Moon,
  Sun,
  Languages,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { NavigationPage } from '../types';

export const Sidebar: React.FC = () => {
  const {
    currentPage,
    setCurrentPage,
    openNouvelleFiche,
    logout,
    user,
    isDark,
    toggleTheme,
    lang,
    setLang,
  } = useApp();

  const navItems: {
    id: NavigationPage;
    labelAr: string;
    labelFr: string;
    icon: React.ReactNode;
    action?: () => void;
  }[] = [
    {
      id: 'dashboard',
      labelAr: 'لوحة التحكم',
      labelFr: 'Tableau de bord',
      icon: <LayoutDashboard className="w-5 h-5" />,
    },
    {
      id: 'fiches',
      labelAr: 'قائمة البطاقات',
      labelFr: 'Liste des fiches',
      icon: <FileSpreadsheet className="w-5 h-5" />,
    },
    {
      id: 'nouvelle_fiche',
      labelAr: 'بطاقة تقنية جديدة',
      labelFr: 'Nouvelle fiche',
      icon: <FilePlus2 className="w-5 h-5" />,
      action: openNouvelleFiche,
    },
    {
      id: 'projets',
      labelAr: 'المشاريع',
      labelFr: 'Projets',
      icon: <FolderGit2 className="w-5 h-5" />,
    },
    {
      id: 'catalogue',
      labelAr: 'كتالوج المواد والأشغال',
      labelFr: 'Catalogue d\'articles',
      icon: <BookOpen className="w-5 h-5" />,
    },
    {
      id: 'parametres',
      labelAr: 'الإعدادات',
      labelFr: 'Paramètres',
      icon: <Settings className="w-5 h-5" />,
    },
  ];

  return (
    <aside className="w-64 bg-slate-900 text-slate-200 flex flex-col shrink-0 border-r border-slate-800 shadow-xl no-print select-none">
      {/* Brand Header */}
      <div className="p-4 border-b border-slate-800/80 bg-slate-950/40">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-blue-600 to-indigo-500 flex items-center justify-center text-white shadow-lg shadow-blue-500/20">
            <Building2 className="w-6 h-6" />
          </div>
          <div className="overflow-hidden">
            <h1 className="font-bold text-base text-white truncate">
              {lang === 'ar' ? 'إدارة البطاقات التقنية' : 'Fiches Techniques v4'}
            </h1>
            <p className="text-xs text-blue-400 truncate">
              {lang === 'ar' ? 'مديرية المصالح التقنية' : 'Services Techniques'}
            </p>
          </div>
        </div>
      </div>

      {/* Navigation Links */}
      <nav className="flex-1 p-3 space-y-1.5 overflow-y-auto">
        <div className="text-[11px] font-semibold tracking-wider text-slate-500 uppercase px-3 pt-2 pb-1">
          {lang === 'ar' ? 'القائمة الرئيسية' : 'Navigation Principale'}
        </div>

        {navItems.map((item) => {
          const isActive =
            currentPage === item.id ||
            (item.id === 'nouvelle_fiche' && currentPage === 'nouvelle_fiche');

          return (
            <button
              key={item.id}
              onClick={() => {
                if (item.action) {
                  item.action();
                } else {
                  setCurrentPage(item.id);
                }
              }}
              className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-lg text-sm font-medium transition-all duration-150 cursor-pointer ${
                isActive
                  ? 'bg-blue-600 text-white shadow-md shadow-blue-600/30'
                  : 'text-slate-300 hover:bg-slate-800/80 hover:text-white'
              }`}
            >
              <span className={isActive ? 'text-white' : 'text-slate-400'}>
                {item.icon}
              </span>
              <span className="truncate">
                {lang === 'ar' ? item.labelAr : item.labelFr}
              </span>
            </button>
          );
        })}
      </nav>

      {/* Footer Controls & User */}
      <div className="p-3 border-t border-slate-800 bg-slate-950/50 space-y-2">
        {/* Theme & Language Quick Toggle */}
        <div className="flex items-center justify-between px-2 py-1 bg-slate-800/40 rounded-lg text-xs text-slate-400">
          <button
            onClick={toggleTheme}
            className="flex items-center gap-1.5 hover:text-white transition-colors cursor-pointer py-1 px-1.5 rounded"
            title={isDark ? 'Passer au mode clair' : 'Passer au mode sombre'}
          >
            {isDark ? <Sun className="w-3.5 h-3.5 text-amber-400" /> : <Moon className="w-3.5 h-3.5 text-blue-400" />}
            <span>{isDark ? (lang === 'ar' ? 'نهاري' : 'Clair') : (lang === 'ar' ? 'ليلي' : 'Sombre')}</span>
          </button>

          <button
            onClick={() => setLang(lang === 'ar' ? 'fr' : 'ar')}
            className="flex items-center gap-1.5 hover:text-white transition-colors cursor-pointer py-1 px-1.5 rounded"
            title="Changer de langue / تغيير اللغة"
          >
            <Languages className="w-3.5 h-3.5 text-emerald-400" />
            <span className="font-semibold">{lang === 'ar' ? 'Français' : 'العربية'}</span>
          </button>
        </div>

        {/* User Card */}
        <div className="flex items-center justify-between px-2.5 py-2 bg-slate-800/60 rounded-lg">
          <div className="overflow-hidden">
            <div className="text-xs font-semibold text-white truncate">
              {user?.fullName || 'Utilisateur'}
            </div>
            <div className="text-[10px] text-slate-400 truncate">
              {user?.role || 'Admin'} • {user?.username}
            </div>
          </div>
          <button
            onClick={logout}
            className="p-1.5 text-slate-400 hover:text-red-400 hover:bg-red-500/10 rounded-md transition-colors cursor-pointer"
            title={lang === 'ar' ? 'تسجيل الخروج' : 'Déconnexion'}
          >
            <LogOut className="w-4 h-4" />
          </button>
        </div>
      </div>
    </aside>
  );
};

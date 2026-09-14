import React, { useState, useEffect } from 'react';
import { Clock, Calendar, PlusCircle, HelpCircle } from 'lucide-react';
import { useApp } from '../context/AppContext';

export const Topbar: React.FC = () => {
  const { currentPage, openNouvelleFiche, settings, lang } = useApp();
  const [time, setTime] = useState<string>('');
  const [date, setDate] = useState<string>('');
  const [showShortcuts, setShowShortcuts] = useState(false);

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setTime(
        now.toLocaleTimeString(lang === 'ar' ? 'ar-DZ' : 'fr-FR', {
          hour: '2-digit',
          minute: '2-digit',
          second: '2-digit',
        })
      );
      setDate(
        now.toLocaleDateString(lang === 'ar' ? 'ar-DZ' : 'fr-FR', {
          weekday: 'long',
          year: 'numeric',
          month: 'long',
          day: 'numeric',
        })
      );
    };

    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, [lang]);

  const getPageTitle = () => {
    switch (currentPage) {
      case 'dashboard':
        return lang === 'ar' ? 'لوحة التحكم والإحصائيات' : 'Tableau de bord & Statistiques';
      case 'fiches':
        return lang === 'ar' ? 'قائمة البطاقات التقنية' : 'Liste des Fiches Techniques';
      case 'nouvelle_fiche':
        return lang === 'ar' ? 'إنشاء بطاقة تقنية جديدة' : 'Création d\'une Nouvelle Fiche';
      case 'fiche_detail':
        return lang === 'ar' ? 'تعديل وتفاصيل البطاقة التقنية' : 'Éditeur de Fiche Technique';
      case 'projets':
        return lang === 'ar' ? 'إدارة المشاريع العامة' : 'Gestion des Projets';
      case 'catalogue':
        return lang === 'ar' ? 'كتالوج المواد والأشغال المرجعي' : 'Catalogue des Articles & Matériaux';
      case 'parametres':
        return lang === 'ar' ? 'إعدادات النظام والمؤسسة' : 'Paramètres du Système';
      default:
        return '';
    }
  };

  return (
    <header className="h-16 bg-white dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800 px-6 flex items-center justify-between shrink-0 shadow-xs select-none no-print">
      {/* Title & Context */}
      <div className="flex items-center gap-3">
        <div>
          <h2 className="text-lg font-bold text-slate-900 dark:text-white leading-tight">
            {getPageTitle()}
          </h2>
          <p className="text-xs text-slate-500 dark:text-slate-400 flex items-center gap-1.5">
            <span className="inline-block w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
            <span>{settings.direction || 'مديرية المصالح التقنية'}</span>
            <span>•</span>
            <span>{settings.commune || 'بلدية باب الزوار'}</span>
          </p>
        </div>
      </div>

      {/* Right Tools (Time, Date, Actions) */}
      <div className="flex items-center gap-3">
        {/* Clock & Date Widget */}
        <div className="hidden md:flex items-center gap-3 px-3 py-1.5 rounded-lg bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 text-xs font-medium">
          <div className="flex items-center gap-1.5">
            <Calendar className="w-3.5 h-3.5 text-blue-500" />
            <span>{date}</span>
          </div>
          <div className="h-3 w-px bg-slate-300 dark:bg-slate-700"></div>
          <div className="flex items-center gap-1.5 font-mono text-slate-800 dark:text-slate-200">
            <Clock className="w-3.5 h-3.5 text-amber-500" />
            <span className="font-semibold">{time}</span>
          </div>
        </div>

        {/* Shortcuts button */}
        <div className="relative">
          <button
            onClick={() => setShowShortcuts(!showShortcuts)}
            className="p-2 text-slate-500 hover:text-blue-600 dark:text-slate-400 dark:hover:text-blue-400 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors cursor-pointer"
            title="Raccourcis clavier"
          >
            <HelpCircle className="w-5 h-5" />
          </button>

          {showShortcuts && (
            <div className="absolute top-12 ltr:right-0 rtl:left-0 w-64 p-3 bg-white dark:bg-slate-800 rounded-xl shadow-xl border border-slate-200 dark:border-slate-700 z-50 text-xs space-y-2">
              <div className="font-bold text-slate-900 dark:text-white pb-1 border-b border-slate-200 dark:border-slate-700">
                {lang === 'ar' ? 'اختصارات لوحة المفاتيح' : 'Raccourcis Clavier'}
              </div>
              <div className="flex justify-between items-center text-slate-600 dark:text-slate-300">
                <span>{lang === 'ar' ? 'حفظ البطاقة' : 'Enregistrer'}</span>
                <kbd className="px-1.5 py-0.5 bg-slate-100 dark:bg-slate-700 rounded border border-slate-300 dark:border-slate-600 font-mono">
                  Ctrl + S
                </kbd>
              </div>
              <div className="flex justify-between items-center text-slate-600 dark:text-slate-300">
                <span>{lang === 'ar' ? 'تحديث الشاشة' : 'Actualiser'}</span>
                <kbd className="px-1.5 py-0.5 bg-slate-100 dark:bg-slate-700 rounded border border-slate-300 dark:border-slate-600 font-mono">
                  F5
                </kbd>
              </div>
              <div className="flex justify-between items-center text-slate-600 dark:text-slate-300">
                <span>{lang === 'ar' ? 'إغلاق / خروج' : 'Fermer'}</span>
                <kbd className="px-1.5 py-0.5 bg-slate-100 dark:bg-slate-700 rounded border border-slate-300 dark:border-slate-600 font-mono">
                  Esc
                </kbd>
              </div>
            </div>
          )}
        </div>

        {/* Quick New Fiche Button */}
        {currentPage !== 'nouvelle_fiche' && currentPage !== 'fiche_detail' && (
          <button
            onClick={openNouvelleFiche}
            className="flex items-center gap-2 px-3.5 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-semibold shadow-sm hover:shadow transition-all cursor-pointer"
          >
            <PlusCircle className="w-4 h-4" />
            <span className="hidden sm:inline">
              {lang === 'ar' ? 'بطاقة جديدة' : 'Nouvelle Fiche'}
            </span>
          </button>
        )}
      </div>
    </header>
  );
};

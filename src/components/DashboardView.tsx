import React, { useState, useMemo } from 'react';
import {
  FileText,
  Clock3,
  CheckCircle2,
  FolderKanban,
  TrendingUp,
  Eye,
  Plus,
  Printer,
  Copy,
  Search,
  Download,
  Layers,
  Sparkles,
  ArrowUpRight,
  ShieldAlert,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { formaterMontantDZD } from '../utils/numberToWordsArabic';
import { StatutFiche, FicheTechnique } from '../types';

export const DashboardView: React.FC = () => {
  const {
    fiches,
    projets,
    typesProjets,
    openFiche,
    openNouvelleFiche,
    dupliquerFiche,
    setPrintFiche,
    setCurrentPage,
    settings,
    lang,
    showNotification,
  } = useApp();

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedStatut, setSelectedStatut] = useState<string>('all');
  const [selectedProjetFilter, setSelectedProjetFilter] = useState<string>('all');
  const [sortBy, setSortBy] = useState<'date' | 'montant' | 'numero'>('date');
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('desc');

  // KPI Calculations
  const totalFiches = fiches.length;
  const validees = fiches.filter((f) => f.statut === 'مصادق عليه').length;
  const enEtude = fiches.filter((f) => f.statut === 'قيد الدراسة').length;
  const brouillons = fiches.filter((f) => f.statut === 'مسودة').length;
  const totalProjets = projets.length;

  const totalMontantHT = useMemo(
    () => fiches.reduce((acc, curr) => acc + (curr.montantHT || 0), 0),
    [fiches]
  );
  const totalMontantTTC = useMemo(
    () => fiches.reduce((acc, curr) => acc + (curr.montantTTC || 0), 0),
    [fiches]
  );
  const totalMontantTVA = useMemo(
    () => fiches.reduce((acc, curr) => acc + (curr.montantTVA || 0), 0),
    [fiches]
  );

  const tauxValidation = totalFiches > 0 ? Math.round((validees / totalFiches) * 100) : 0;
  const montantMoyen = totalFiches > 0 ? Math.round(totalMontantTTC / totalFiches) : 0;

  // Budget distribution by project category
  const categoryStats = useMemo(() => {
    const stats: Record<string, { count: number; montant: number; label: string }> = {};
    typesProjets.forEach((tp) => {
      stats[tp.id] = { count: 0, montant: 0, label: tp.nom };
    });

    fiches.forEach((f) => {
      const proj = projets.find((p) => p.id === f.projetId);
      const typeId = proj?.typeProjetId || typesProjets[0]?.id || 1;
      if (stats[typeId]) {
        stats[typeId].count += 1;
        stats[typeId].montant += f.montantTTC;
      }
    });

    return Object.values(stats);
  }, [fiches, projets, typesProjets]);

  // Filtered and sorted fiches list
  const filteredFiches = useMemo(() => {
    return fiches
      .filter((f) => {
        // Status filter
        if (selectedStatut !== 'all' && f.statut !== selectedStatut) return false;

        // Project filter
        if (selectedProjetFilter !== 'all' && f.projetId !== Number(selectedProjetFilter)) {
          return false;
        }

        // Search query
        if (!searchQuery.trim()) return true;
        const q = searchQuery.toLowerCase().trim();
        const proj = projets.find((p) => p.id === f.projetId);
        return (
          f.numeroFiche.toLowerCase().includes(q) ||
          f.operation.toLowerCase().includes(q) ||
          (proj && proj.nom.toLowerCase().includes(q)) ||
          f.dateFiche.includes(q)
        );
      })
      .sort((a, b) => {
        if (sortBy === 'montant') {
          return sortOrder === 'desc'
            ? b.montantTTC - a.montantTTC
            : a.montantTTC - b.montantTTC;
        }
        if (sortBy === 'numero') {
          return sortOrder === 'desc'
            ? b.numeroFiche.localeCompare(a.numeroFiche)
            : a.numeroFiche.localeCompare(b.numeroFiche);
        }
        // Date sort
        return sortOrder === 'desc'
          ? b.dateFiche.localeCompare(a.dateFiche)
          : a.dateFiche.localeCompare(b.dateFiche);
      });
  }, [fiches, projets, selectedStatut, selectedProjetFilter, searchQuery, sortBy, sortOrder]);

  const handleDuplicate = (fiche: FicheTechnique) => {
    const duplicated = dupliquerFiche(fiche.id);
    showNotification(
      lang === 'ar'
        ? `تم استنساخ البطاقة التقنية بنجاح برقم: ${duplicated.numeroFiche}`
        : `Fiche dupliquée avec succès : ${duplicated.numeroFiche}`,
      'success'
    );
  };

  const exportCSV = () => {
    const headers =
      lang === 'ar'
        ? ['رقم البطاقة', 'المشروع', 'العملية', 'التاريخ', 'المبلغ HT', 'المبلغ TVA', 'المبلغ TTC', 'الحالة']
        : ['Numero', 'Projet', 'Operation', 'Date', 'Montant_HT', 'TVA', 'Montant_TTC', 'Statut'];

    const rows = filteredFiches.map((f) => {
      const proj = projets.find((p) => p.id === f.projetId);
      return [
        `"${f.numeroFiche}"`,
        `"${proj?.nom || ''}"`,
        `"${f.operation.replace(/"/g, '""')}"`,
        `"${f.dateFiche}"`,
        f.montantHT,
        f.montantTVA,
        f.montantTTC,
        `"${f.statut}"`,
      ].join(',');
    });

    const csvContent = '\uFEFF' + [headers.join(','), ...rows].join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', `Fiches_Techniques_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    showNotification(
      lang === 'ar' ? 'تم تصدير الجدول إلى ملف CSV بنجاح' : 'Exportation CSV effectuée avec succès',
      'info'
    );
  };

  const renderBadge = (statut: StatutFiche) => {
    switch (statut) {
      case 'مصادق عليه':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 dark:bg-emerald-950/60 dark:text-emerald-300 border border-emerald-200 dark:border-emerald-800">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
            <span>{statut}</span>
          </span>
        );
      case 'قيد الدراسة':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-blue-50 text-blue-700 dark:bg-blue-950/60 dark:text-blue-300 border border-blue-200 dark:border-blue-800">
            <span className="w-1.5 h-1.5 rounded-full bg-blue-500"></span>
            <span>{statut}</span>
          </span>
        );
      case 'مسودة':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 dark:bg-amber-950/60 dark:text-amber-300 border border-amber-200 dark:border-amber-800">
            <span className="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
            <span>{statut}</span>
          </span>
        );
      case 'ملغى':
      default:
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-rose-50 text-rose-700 dark:bg-rose-950/60 dark:text-rose-300 border border-rose-200 dark:border-rose-800">
            <span className="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
            <span>{statut}</span>
          </span>
        );
    }
  };

  return (
    <div className="space-y-6">
      {/* 1. Executive Modern Header Banner */}
      <div className="bg-gradient-to-r from-slate-900 via-blue-950 to-slate-900 text-white rounded-3xl p-6 md:p-8 shadow-xl border border-slate-800 relative overflow-hidden">
        {/* Background decorative glows */}
        <div className="absolute -top-12 -right-12 w-64 h-64 bg-blue-500/15 rounded-full blur-3xl pointer-events-none"></div>
        <div className="absolute -bottom-12 -left-12 w-64 h-64 bg-indigo-500/15 rounded-full blur-3xl pointer-events-none"></div>

        <div className="relative z-10 flex flex-col lg:flex-row items-start lg:items-center justify-between gap-6">
          <div className="space-y-2 max-w-2xl">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/20 border border-blue-400/30 text-blue-300 text-xs font-semibold">
              <Sparkles className="w-3.5 h-3.5 text-blue-400" />
              <span>
                {settings.wilaya} • {settings.commune}
              </span>
            </div>
            <h1 className="text-2xl md:text-3xl font-extrabold tracking-tight text-white">
              {lang === 'ar'
                ? 'منظومة إعداد ومتابعة البطاقات التقنية للأشغال'
                : 'Système de Gestion des Fiches Techniques et Devis'}
            </h1>
            <p className="text-xs md:text-sm text-slate-300 leading-relaxed">
              {lang === 'ar'
                ? 'لوحة القيادة المركزية للمصالح التقنية • تقييم المخصصات المالية، جدول الأسعار والمصادقة على العمليات'
                : 'Supervision technique et financière des opérations communales et des devis estimatifs'}
            </p>
          </div>

          {/* Quick Actions in Banner */}
          <div className="flex flex-wrap items-center gap-3 w-full lg:w-auto">
            <button
              onClick={() => setCurrentPage('projets')}
              className="flex-1 sm:flex-initial flex items-center justify-center gap-2 px-4 py-3 bg-white/10 hover:bg-white/15 text-white border border-white/15 rounded-2xl text-xs font-bold backdrop-blur-sm transition-all cursor-pointer"
            >
              <FolderKanban className="w-4 h-4 text-blue-300" />
              <span>{lang === 'ar' ? 'دليل المشاريع' : 'Projets'}</span>
            </button>
            <button
              onClick={openNouvelleFiche}
              className="flex-1 sm:flex-initial flex items-center justify-center gap-2 px-6 py-3 bg-blue-600 hover:bg-blue-500 text-white rounded-2xl text-xs font-extrabold shadow-lg shadow-blue-600/30 transition-all cursor-pointer hover:scale-[1.02]"
            >
              <Plus className="w-4 h-4 stroke-[3]" />
              <span>{lang === 'ar' ? 'بطاقة تقنية جديدة (F1)' : 'Nouvelle Fiche'}</span>
            </button>
          </div>
        </div>

        {/* Global Financial Indicator sub-row */}
        <div className="mt-8 pt-6 border-t border-slate-800/80 grid grid-cols-1 sm:grid-cols-3 gap-6 text-xs">
          <div>
            <span className="text-slate-400 block mb-1">
              {lang === 'ar' ? 'المبلغ الإجمالي الملتزم به (TTC)' : 'Montant Global Estimatif (TTC)'}
            </span>
            <span className="text-xl md:text-2xl font-black font-num text-emerald-400">
              {formaterMontantDZD(totalMontantTTC)}
            </span>
          </div>

          <div>
            <span className="text-slate-400 block mb-1">
              {lang === 'ar' ? 'المبلغ الصافي الخام (HT)' : 'Total Hors Taxes (HT)'}
            </span>
            <span className="text-xl md:text-2xl font-black font-num text-slate-200">
              {formaterMontantDZD(totalMontantHT)}
            </span>
          </div>

          <div>
            <span className="text-slate-400 block mb-1">
              {lang === 'ar' ? 'الرسم على القيمة المضافة (TVA)' : 'Total TVA Facturée'}
            </span>
            <span className="text-xl md:text-2xl font-black font-num text-amber-400">
              {formaterMontantDZD(totalMontantTVA)}
            </span>
          </div>
        </div>
      </div>

      {/* 2. Four KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        {/* Card 1 - Total Fiches */}
        <div className="bg-white dark:bg-slate-900 rounded-3xl p-5 border border-slate-200 dark:border-slate-800 shadow-xs relative overflow-hidden transition-all hover:shadow-md hover:border-blue-500/40">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-bold text-slate-500 dark:text-slate-400">
              {lang === 'ar' ? 'إجمالي البطاقات' : 'Total Fiches'}
            </span>
            <div className="w-11 h-11 rounded-2xl bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 flex items-center justify-center">
              <FileText className="w-5 h-5" />
            </div>
          </div>
          <div className="text-3xl font-black text-slate-900 dark:text-white mb-2 font-mono">
            {totalFiches}
          </div>
          <div className="flex items-center justify-between text-xs text-slate-500 dark:text-slate-400">
            <span className="flex items-center gap-1 font-semibold text-blue-600 dark:text-blue-400">
              <TrendingUp className="w-3.5 h-3.5" />
              <span>{lang === 'ar' ? 'معدل البطاقة' : 'Moyenne'}</span>
            </span>
            <span className="font-mono font-num text-[11px]">
              {formaterMontantDZD(montantMoyen)}
            </span>
          </div>
        </div>

        {/* Card 2 - Validated Fiches */}
        <div className="bg-white dark:bg-slate-900 rounded-3xl p-5 border border-slate-200 dark:border-slate-800 shadow-xs relative overflow-hidden transition-all hover:shadow-md hover:border-emerald-500/40">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-bold text-slate-500 dark:text-slate-400">
              {lang === 'ar' ? 'البطاقات المصادق عليها' : 'Fiches Validées'}
            </span>
            <div className="w-11 h-11 rounded-2xl bg-emerald-50 dark:bg-emerald-900/30 text-emerald-600 dark:text-emerald-400 flex items-center justify-center">
              <CheckCircle2 className="w-5 h-5" />
            </div>
          </div>
          <div className="text-3xl font-black text-emerald-600 dark:text-emerald-400 mb-2 font-mono">
            {validees}
          </div>
          <div className="flex items-center justify-between text-xs">
            <span className="text-slate-500 dark:text-slate-400">
              {lang === 'ar' ? 'نسبة الإنجاز والمصادقة' : 'Taux d\'approbation'}
            </span>
            <span className="px-2 py-0.5 rounded-md bg-emerald-100 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 font-bold font-mono">
              {tauxValidation}%
            </span>
          </div>
        </div>

        {/* Card 3 - Pending & Drafts */}
        <div className="bg-white dark:bg-slate-900 rounded-3xl p-5 border border-slate-200 dark:border-slate-800 shadow-xs relative overflow-hidden transition-all hover:shadow-md hover:border-amber-500/40">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-bold text-slate-500 dark:text-slate-400">
              {lang === 'ar' ? 'قيد الدراسة والمراجعة' : 'En Attente / Étude'}
            </span>
            <div className="w-11 h-11 rounded-2xl bg-amber-50 dark:bg-amber-900/30 text-amber-600 dark:text-amber-400 flex items-center justify-center">
              <Clock3 className="w-5 h-5" />
            </div>
          </div>
          <div className="text-3xl font-black text-amber-600 dark:text-amber-400 mb-2 font-mono">
            {enEtude + brouillons}
          </div>
          <div className="flex items-center justify-between text-xs text-slate-500 dark:text-slate-400">
            <span>{lang === 'ar' ? 'مسودة' : 'Brouillon'}: <strong className="font-mono">{brouillons}</strong></span>
            <span>•</span>
            <span>{lang === 'ar' ? 'قيد الدراسة' : 'En étude'}: <strong className="font-mono">{enEtude}</strong></span>
          </div>
        </div>

        {/* Card 4 - Projects */}
        <div className="bg-white dark:bg-slate-900 rounded-3xl p-5 border border-slate-200 dark:border-slate-800 shadow-xs relative overflow-hidden transition-all hover:shadow-md hover:border-indigo-500/40">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-bold text-slate-500 dark:text-slate-400">
              {lang === 'ar' ? 'المشاريع المسجلة' : 'Projets Enregistrés'}
            </span>
            <div className="w-11 h-11 rounded-2xl bg-indigo-50 dark:bg-indigo-900/30 text-indigo-600 dark:text-indigo-400 flex items-center justify-center">
              <FolderKanban className="w-5 h-5" />
            </div>
          </div>
          <div className="text-3xl font-black text-indigo-600 dark:text-indigo-400 mb-2 font-mono">
            {totalProjets}
          </div>
          <div className="flex items-center justify-between text-xs text-slate-500 dark:text-slate-400">
            <span>{settings.commune}</span>
            <span className="text-indigo-600 dark:text-indigo-400 font-bold flex items-center gap-1 cursor-pointer" onClick={() => setCurrentPage('projets')}>
              <span>{lang === 'ar' ? 'عرض الكل' : 'Voir tout'}</span>
              <ArrowUpRight className="w-3 h-3" />
            </span>
          </div>
        </div>
      </div>

      {/* 3. Budget Distribution by Category */}
      <div className="bg-white dark:bg-slate-900 rounded-3xl p-6 border border-slate-200 dark:border-slate-800 shadow-xs">
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 mb-4">
          <div className="flex items-center gap-2">
            <Layers className="w-5 h-5 text-blue-600" />
            <h3 className="font-bold text-sm text-slate-900 dark:text-white">
              {lang === 'ar'
                ? 'توزيع التكلفة التقديرية حسب أصناف الأشغال'
                : 'Répartition Budgétaire par Type de Travaux'}
            </h3>
          </div>
          <span className="text-xs text-slate-400">
            {lang === 'ar' ? 'إجمالي البرامج الجارية' : 'Programmes en cours'}
          </span>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4">
          {categoryStats.map((cat, idx) => {
            const pct = totalMontantTTC > 0 ? Math.round((cat.montant / totalMontantTTC) * 100) : 0;
            return (
              <div
                key={idx}
                className="p-4 rounded-2xl bg-slate-50 dark:bg-slate-800/60 border border-slate-200/80 dark:border-slate-700/60 space-y-2"
              >
                <div className="flex items-center justify-between text-xs font-semibold text-slate-700 dark:text-slate-300">
                  <span className="truncate">{cat.label}</span>
                  <span className="font-mono text-blue-600 dark:text-blue-400">{pct}%</span>
                </div>
                <div className="w-full bg-slate-200 dark:bg-slate-700 h-2 rounded-full overflow-hidden">
                  <div
                    className="bg-blue-600 h-full rounded-full transition-all duration-500"
                    style={{ width: `${pct}%` }}
                  ></div>
                </div>
                <div className="flex items-center justify-between text-[11px] text-slate-500 dark:text-slate-400 font-num">
                  <span>{cat.count} {lang === 'ar' ? 'بطاقة' : 'fiches'}</span>
                  <span className="font-bold text-slate-800 dark:text-slate-200">
                    {formaterMontantDZD(cat.montant)}
                  </span>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* 4. Modern VCL-Style Interactive Fiches Table */}
      <div className="bg-white dark:bg-slate-900 rounded-3xl border border-slate-200 dark:border-slate-800 shadow-xs overflow-hidden">
        {/* Table Toolbar / Filters */}
        <div className="p-5 border-b border-slate-200 dark:border-slate-800 flex flex-col lg:flex-row gap-4 items-stretch lg:items-center justify-between">
          <div>
            <h3 className="text-base font-bold text-slate-900 dark:text-white flex items-center gap-2">
              <span>{lang === 'ar' ? 'جدول متابعة البطاقات التقنية' : 'Suivi des Fiches Techniques'}</span>
              <span className="px-2.5 py-0.5 rounded-full bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400 text-xs font-mono font-bold">
                {filteredFiches.length}
              </span>
            </h3>
            <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
              {lang === 'ar'
                ? 'البحث، الفرز، التعديل السريع، الاستنساخ والطباعة الرسمية الفورية'
                : 'Recherche multicritère, filtrage par statut, duplication et impression immédiate'}
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            {/* Search Input */}
            <div className="relative min-w-[220px] flex-1 sm:flex-initial">
              <Search className="w-4 h-4 text-slate-400 absolute top-3 ltr:left-3 rtl:right-3 pointer-events-none" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder={lang === 'ar' ? 'بحث برقم البطاقة أو العملية...' : 'Rechercher fiches...'}
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl py-2 ltr:pl-9 ltr:pr-3 rtl:pr-9 rtl:pl-3 text-xs text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
              />
            </div>

            {/* Status Filter Pills */}
            <div className="flex items-center gap-1 bg-slate-100 dark:bg-slate-800 p-1 rounded-xl text-xs font-semibold">
              <button
                onClick={() => setSelectedStatut('all')}
                className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer ${
                  selectedStatut === 'all'
                    ? 'bg-white dark:bg-slate-700 text-slate-900 dark:text-white shadow-xs'
                    : 'text-slate-500 hover:text-slate-900 dark:hover:text-white'
                }`}
              >
                {lang === 'ar' ? 'الكل' : 'Tous'}
              </button>
              <button
                onClick={() => setSelectedStatut('مصادق عليه')}
                className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer ${
                  selectedStatut === 'مصادق عليه'
                    ? 'bg-white dark:bg-slate-700 text-emerald-700 dark:text-emerald-400 shadow-xs'
                    : 'text-slate-500 hover:text-slate-900 dark:hover:text-white'
                }`}
              >
                {lang === 'ar' ? 'مصادق عليه' : 'Validées'}
              </button>
              <button
                onClick={() => setSelectedStatut('قيد الدراسة')}
                className={`px-3 py-1.5 rounded-lg transition-all cursor-pointer ${
                  selectedStatut === 'قيد الدراسة'
                    ? 'bg-white dark:bg-slate-700 text-blue-700 dark:text-blue-400 shadow-xs'
                    : 'text-slate-500 hover:text-slate-900 dark:hover:text-white'
                }`}
              >
                {lang === 'ar' ? 'قيد الدراسة' : 'En étude'}
              </button>
            </div>

            {/* Project Filter Select */}
            <select
              value={selectedProjetFilter}
              onChange={(e) => setSelectedProjetFilter(e.target.value)}
              className="bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-700 dark:text-slate-300 focus:ring-2 focus:ring-blue-500 outline-hidden cursor-pointer"
            >
              <option value="all">{lang === 'ar' ? 'جميع المشاريع' : 'Tous les projets'}</option>
              {projets.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.nom}
                </option>
              ))}
            </select>

            {/* Export CSV Button */}
            <button
              onClick={exportCSV}
              className="flex items-center gap-1.5 px-3 py-2 bg-slate-100 hover:bg-slate-200 dark:bg-slate-800 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-200 rounded-xl text-xs font-semibold transition-all cursor-pointer"
              title={lang === 'ar' ? 'تصدير كملف CSV' : 'Exporter en CSV'}
            >
              <Download className="w-3.5 h-3.5" />
              <span>CSV</span>
            </button>
          </div>
        </div>

        {/* Table Content */}
        <div className="overflow-x-auto">
          <table className="w-full text-xs text-start">
            <thead className="bg-slate-50 dark:bg-slate-800/80 text-slate-600 dark:text-slate-300 font-bold uppercase tracking-wider border-b border-slate-200 dark:border-slate-800">
              <tr>
                <th
                  onClick={() => {
                    setSortBy('numero');
                    setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
                  }}
                  className="px-5 py-3.5 text-center cursor-pointer hover:bg-slate-100 dark:hover:bg-slate-700/50 transition-colors w-32"
                >
                  <div className="flex items-center justify-center gap-1">
                    <span>{lang === 'ar' ? 'رقم البطاقة' : 'N° Fiche'}</span>
                    {sortBy === 'numero' && <span className="text-blue-600">{sortOrder === 'asc' ? '↑' : '↓'}</span>}
                  </div>
                </th>
                <th className="px-5 py-3.5 text-start">
                  {lang === 'ar' ? 'المشروع والموقع' : 'Projet & Localisation'}
                </th>
                <th className="px-5 py-3.5 text-start">
                  {lang === 'ar' ? 'موضوع العملية والأشغال' : 'Désignation de l\'Opération'}
                </th>
                <th
                  onClick={() => {
                    setSortBy('date');
                    setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
                  }}
                  className="px-5 py-3.5 text-center cursor-pointer hover:bg-slate-100 dark:hover:bg-slate-700/50 transition-colors w-28"
                >
                  <div className="flex items-center justify-center gap-1">
                    <span>{lang === 'ar' ? 'التاريخ' : 'Date'}</span>
                    {sortBy === 'date' && <span className="text-blue-600">{sortOrder === 'asc' ? '↑' : '↓'}</span>}
                  </div>
                </th>
                <th
                  onClick={() => {
                    setSortBy('montant');
                    setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
                  }}
                  className="px-5 py-3.5 text-end cursor-pointer hover:bg-slate-100 dark:hover:bg-slate-700/50 transition-colors w-40"
                >
                  <div className="flex items-center justify-end gap-1">
                    <span>{lang === 'ar' ? 'المبلغ TTC (دج)' : 'Montant TTC'}</span>
                    {sortBy === 'montant' && <span className="text-blue-600">{sortOrder === 'asc' ? '↑' : '↓'}</span>}
                  </div>
                </th>
                <th className="px-5 py-3.5 text-center w-32">
                  {lang === 'ar' ? 'الحالة' : 'Statut'}
                </th>
                <th className="px-5 py-3.5 text-center w-36">
                  {lang === 'ar' ? 'الإجراءات' : 'Actions'}
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-800/60">
              {filteredFiches.length === 0 ? (
                <tr>
                  <td colSpan={7} className="text-center py-12 text-slate-400">
                    <ShieldAlert className="w-8 h-8 mx-auto mb-2 text-slate-300 dark:text-slate-600" />
                    <span>{lang === 'ar' ? 'لا توجد بطاقات تقنية تطابق معايير البحث' : 'Aucune fiche ne correspond à votre recherche'}</span>
                  </td>
                </tr>
              ) : (
                filteredFiches.map((f, idx) => {
                  const proj = projets.find((p) => p.id === f.projetId);
                  return (
                    <tr
                      key={f.id}
                      className={`hover:bg-blue-50/40 dark:hover:bg-slate-800/40 transition-colors group ${
                        idx % 2 === 1 ? 'bg-slate-50/40 dark:bg-slate-900/30' : ''
                      }`}
                    >
                      {/* Fiche Number */}
                      <td className="px-5 py-3.5 text-center font-mono font-bold text-blue-600 dark:text-blue-400 whitespace-nowrap">
                        {f.numeroFiche}
                      </td>

                      {/* Project Name & Location */}
                      <td className="px-5 py-3.5">
                        <div className="font-semibold text-slate-900 dark:text-slate-100 max-w-xs truncate">
                          {proj?.nom || '—'}
                        </div>
                        <div className="text-[11px] text-slate-500 dark:text-slate-400 truncate">
                          {proj ? `${proj.wilaya} • ${proj.commune}` : '—'}
                        </div>
                      </td>

                      {/* Operation */}
                      <td className="px-5 py-3.5 text-slate-700 dark:text-slate-300 max-w-sm truncate font-medium">
                        {f.operation}
                      </td>

                      {/* Date */}
                      <td className="px-5 py-3.5 text-center font-mono text-slate-500 whitespace-nowrap">
                        {f.dateFiche}
                      </td>

                      {/* Montant TTC */}
                      <td className="px-5 py-3.5 text-end font-bold font-num text-slate-900 dark:text-slate-100 whitespace-nowrap text-sm">
                        {formaterMontantDZD(f.montantTTC)}
                      </td>

                      {/* Status Badge */}
                      <td className="px-5 py-3.5 text-center whitespace-nowrap">
                        {renderBadge(f.statut)}
                      </td>

                      {/* Action Buttons */}
                      <td className="px-5 py-3.5 text-center whitespace-nowrap">
                        <div className="flex items-center justify-center gap-1">
                          {/* Consult / Edit */}
                          <button
                            onClick={() => openFiche(f.id)}
                            className="p-1.5 text-blue-600 hover:text-blue-700 hover:bg-blue-50 dark:hover:bg-blue-900/40 rounded-lg transition-colors cursor-pointer"
                            title={lang === 'ar' ? 'فتح وتعديل' : 'Ouvrir'}
                          >
                            <Eye className="w-4 h-4" />
                          </button>

                          {/* Quick Print Official A4 */}
                          <button
                            onClick={() => setPrintFiche(f)}
                            className="p-1.5 text-slate-600 hover:text-slate-900 hover:bg-slate-100 dark:text-slate-400 dark:hover:text-white dark:hover:bg-slate-800 rounded-lg transition-colors cursor-pointer"
                            title={lang === 'ar' ? 'طباعة رسمية A4' : 'Imprimer'}
                          >
                            <Printer className="w-4 h-4" />
                          </button>

                          {/* Duplicate */}
                          <button
                            onClick={() => handleDuplicate(f)}
                            className="p-1.5 text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 dark:hover:bg-indigo-900/40 rounded-lg transition-colors cursor-pointer"
                            title={lang === 'ar' ? 'استنساخ البطاقة' : 'Dupliquer'}
                          >
                            <Copy className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

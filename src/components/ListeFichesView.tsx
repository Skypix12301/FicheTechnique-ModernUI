import React, { useState } from 'react';
import {
  Search,
  Filter,
  Plus,
  Edit,
  Trash2,
  Copy,
  Printer,
  FileSpreadsheet,
  CheckCircle2,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { formaterMontantDZD } from '../utils/numberToWordsArabic';
import { StatutFiche, FicheTechnique } from '../types';

export const ListeFichesView: React.FC = () => {
  const {
    fiches,
    projets,
    openFiche,
    openNouvelleFiche,
    deleteFiche,
    dupliquerFiche,
    setPrintFiche,
    validerFiche,
    lang,
  } = useApp();

  const [selectedProjetId, setSelectedProjetId] = useState<number>(0);
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [selectedFiche, setSelectedFiche] = useState<FicheTechnique | null>(null);

  // Filter fiches
  const filteredFiches = fiches.filter((f) => {
    const matchesProjet = selectedProjetId === 0 || f.projetId === selectedProjetId;
    const proj = projets.find((p) => p.id === f.projetId);
    const q = searchQuery.trim().toLowerCase();
    const matchesSearch =
      !q ||
      f.numeroFiche.toLowerCase().includes(q) ||
      f.operation.toLowerCase().includes(q) ||
      (proj && proj.nom.toLowerCase().includes(q));

    return matchesProjet && matchesSearch;
  });

  const handleDelete = (fiche: FicheTechnique) => {
    const msg =
      lang === 'ar'
        ? `هل أنت متأكد من حذف البطاقة التقنية رقم "${fiche.numeroFiche}"؟`
        : `Êtes-vous sûr de vouloir supprimer la fiche ${fiche.numeroFiche} ?`;
    if (window.confirm(msg)) {
      deleteFiche(fiche.id);
      if (selectedFiche?.id === fiche.id) setSelectedFiche(null);
    }
  };

  const renderBadge = (statut: StatutFiche) => {
    switch (statut) {
      case 'مصادق عليه':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-100 text-emerald-800 dark:bg-emerald-950/60 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-800">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
            {statut}
          </span>
        );
      case 'قيد الدراسة':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-800 dark:bg-blue-950/60 dark:text-blue-300 border border-blue-300 dark:border-blue-800">
            <span className="w-1.5 h-1.5 rounded-full bg-blue-500"></span>
            {statut}
          </span>
        );
      case 'مسودة':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-amber-100 text-amber-800 dark:bg-amber-950/60 dark:text-amber-300 border border-amber-300 dark:border-amber-800">
            <span className="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
            {statut}
          </span>
        );
      case 'ملغى':
      default:
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-rose-100 text-rose-800 dark:bg-rose-950/60 dark:text-rose-300 border border-rose-300 dark:border-rose-800">
            <span className="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
            {statut}
          </span>
        );
    }
  };

  return (
    <div className="space-y-4">
      {/* Top Filter & Search Bar */}
      <div className="bg-white dark:bg-slate-900 p-4 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs flex flex-col md:flex-row gap-4 items-center justify-between">
        <div className="flex flex-1 flex-col sm:flex-row gap-3 w-full">
          {/* Project Filter */}
          <div className="flex items-center gap-2 sm:w-72">
            <Filter className="w-4 h-4 text-slate-400 shrink-0" />
            <select
              value={selectedProjetId}
              onChange={(e) => setSelectedProjetId(Number(e.target.value))}
              className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm font-medium text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
            >
              <option value={0}>
                {lang === 'ar' ? 'جميع المشاريع' : 'Tous les projets'}
              </option>
              {projets.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.nom}
                </option>
              ))}
            </select>
          </div>

          {/* Search Input */}
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-slate-400 absolute top-3 ltr:left-3 rtl:right-3 pointer-events-none" />
            <input
              type="text"
              placeholder={
                lang === 'ar'
                  ? 'بحث برقم البطاقة، العملية، أو اسم المشروع...'
                  : 'Rechercher par numéro, opération, projet...'
              }
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl py-2 ltr:pl-9 ltr:pr-3 rtl:pr-9 rtl:pl-3 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
            />
          </div>
        </div>

        {/* Count badge */}
        <div className="text-xs font-semibold px-3 py-1.5 rounded-full bg-blue-50 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 whitespace-nowrap">
          {filteredFiches.length} {lang === 'ar' ? 'بطاقة مسجلة' : 'fiches'}
        </div>
      </div>

      {/* Main Table */}
      <div className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm text-start">
            <thead className="bg-slate-50 dark:bg-slate-800/70 text-slate-600 dark:text-slate-300 text-xs font-semibold uppercase tracking-wider border-b border-slate-200 dark:border-slate-800">
              <tr>
                <th className="px-4 py-3.5 text-center w-12">#</th>
                <th className="px-4 py-3.5 text-center">
                  {lang === 'ar' ? 'رقم البطاقة' : 'N° Fiche'}
                </th>
                <th className="px-4 py-3.5 text-start">
                  {lang === 'ar' ? 'المشروع' : 'Projet'}
                </th>
                <th className="px-4 py-3.5 text-start">
                  {lang === 'ar' ? 'العملية / الأشغال' : 'Opération'}
                </th>
                <th className="px-4 py-3.5 text-center">
                  {lang === 'ar' ? 'التاريخ' : 'Date'}
                </th>
                <th className="px-4 py-3.5 text-end">
                  {lang === 'ar' ? 'المبلغ TTC' : 'Montant TTC'}
                </th>
                <th className="px-4 py-3.5 text-center">
                  {lang === 'ar' ? 'الحالة' : 'Statut'}
                </th>
                <th className="px-4 py-3.5 text-center">
                  {lang === 'ar' ? 'إجراءات' : 'Actions'}
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-800/60">
              {filteredFiches.length === 0 ? (
                <tr>
                  <td colSpan={8} className="text-center py-12 text-slate-400">
                    <FileSpreadsheet className="w-12 h-12 mx-auto mb-2 opacity-30" />
                    <p>{lang === 'ar' ? 'لا توجد بطاقات تقنية مطابقة' : 'Aucune fiche trouvée'}</p>
                  </td>
                </tr>
              ) : (
                filteredFiches.map((f, idx) => {
                  const proj = projets.find((p) => p.id === f.projetId);
                  const isSelected = selectedFiche?.id === f.id;

                  return (
                    <tr
                      key={f.id}
                      onClick={() => setSelectedFiche(f)}
                      onDoubleClick={() => openFiche(f.id)}
                      className={`cursor-pointer transition-colors ${
                        isSelected
                          ? 'bg-blue-50 dark:bg-blue-900/30'
                          : idx % 2 === 1
                          ? 'bg-slate-50/50 dark:bg-slate-900/40 hover:bg-blue-50/30 dark:hover:bg-slate-800/30'
                          : 'hover:bg-blue-50/30 dark:hover:bg-slate-800/30'
                      }`}
                    >
                      <td className="px-4 py-3.5 text-center text-xs text-slate-400 font-mono">
                        {idx + 1}
                      </td>
                      <td className="px-4 py-3.5 text-center font-mono font-bold text-blue-600 dark:text-blue-400 whitespace-nowrap">
                        {f.numeroFiche}
                      </td>
                      <td className="px-4 py-3.5 text-slate-800 dark:text-slate-200 font-medium max-w-xs truncate">
                        {proj?.nom || '—'}
                      </td>
                      <td className="px-4 py-3.5 text-slate-600 dark:text-slate-400 max-w-sm truncate">
                        {f.operation}
                      </td>
                      <td className="px-4 py-3.5 text-center font-mono text-xs text-slate-500 whitespace-nowrap">
                        {f.dateFiche}
                      </td>
                      <td className="px-4 py-3.5 text-end font-bold font-num text-slate-900 dark:text-slate-100 whitespace-nowrap">
                        {formaterMontantDZD(f.montantTTC)}
                      </td>
                      <td className="px-4 py-3.5 text-center whitespace-nowrap">
                        {renderBadge(f.statut)}
                      </td>
                      <td className="px-4 py-3.5 text-center whitespace-nowrap">
                        <div className="flex items-center justify-center gap-1">
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              openFiche(f.id);
                            }}
                            className="p-1.5 text-blue-600 hover:text-blue-800 hover:bg-blue-100 dark:hover:bg-blue-900/40 rounded-lg transition-colors cursor-pointer"
                            title={lang === 'ar' ? 'تعديل' : 'Modifier'}
                          >
                            <Edit className="w-4 h-4" />
                          </button>
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              dupliquerFiche(f.id);
                            }}
                            className="p-1.5 text-slate-600 hover:text-slate-800 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors cursor-pointer"
                            title={lang === 'ar' ? 'نسخ البطاقة' : 'Dupliquer'}
                          >
                            <Copy className="w-4 h-4" />
                          </button>
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              setPrintFiche(f);
                            }}
                            className="p-1.5 text-slate-600 hover:text-slate-800 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors cursor-pointer"
                            title={lang === 'ar' ? 'طباعة / معاينة' : 'Imprimer'}
                          >
                            <Printer className="w-4 h-4" />
                          </button>
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleDelete(f);
                            }}
                            className="p-1.5 text-rose-500 hover:text-rose-700 hover:bg-rose-50 dark:hover:bg-rose-900/30 rounded-lg transition-colors cursor-pointer"
                            title={lang === 'ar' ? 'حذف' : 'Supprimer'}
                          >
                            <Trash2 className="w-4 h-4" />
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

        {/* Bottom Actions Bar (similar to Delphi uListeFiches_v3) */}
        <div className="p-4 bg-slate-50 dark:bg-slate-800/60 border-t border-slate-200 dark:border-slate-800 flex flex-wrap items-center justify-between gap-3">
          <div className="flex items-center gap-2">
            <button
              onClick={openNouvelleFiche}
              className="flex items-center gap-1.5 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-semibold shadow-xs transition-all cursor-pointer"
            >
              <Plus className="w-4 h-4" />
              <span>{lang === 'ar' ? 'بطاقة جديدة' : 'Nouvelle Fiche'}</span>
            </button>

            {selectedFiche && (
              <>
                <button
                  onClick={() => openFiche(selectedFiche.id)}
                  className="flex items-center gap-1.5 px-3.5 py-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 hover:bg-slate-50 text-slate-700 dark:text-slate-200 rounded-xl text-sm font-medium transition-all cursor-pointer"
                >
                  <Edit className="w-4 h-4 text-blue-500" />
                  <span>{lang === 'ar' ? 'تعديل المحددة' : 'Modifier'}</span>
                </button>

                <button
                  onClick={() => dupliquerFiche(selectedFiche.id)}
                  className="flex items-center gap-1.5 px-3.5 py-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 hover:bg-slate-50 text-slate-700 dark:text-slate-200 rounded-xl text-sm font-medium transition-all cursor-pointer"
                >
                  <Copy className="w-4 h-4 text-amber-500" />
                  <span>{lang === 'ar' ? 'نسخ' : 'Dupliquer'}</span>
                </button>

                <button
                  onClick={() => setPrintFiche(selectedFiche)}
                  className="flex items-center gap-1.5 px-3.5 py-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 hover:bg-slate-50 text-slate-700 dark:text-slate-200 rounded-xl text-sm font-medium transition-all cursor-pointer"
                >
                  <Printer className="w-4 h-4 text-slate-500" />
                  <span>{lang === 'ar' ? 'طباعة' : 'Imprimer'}</span>
                </button>

                {selectedFiche.statut !== 'مصادق عليه' && (
                  <button
                    onClick={() => validerFiche(selectedFiche.id)}
                    className="flex items-center gap-1.5 px-3.5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-sm font-medium transition-all cursor-pointer"
                  >
                    <CheckCircle2 className="w-4 h-4" />
                    <span>{lang === 'ar' ? 'مصادقة' : 'Valider'}</span>
                  </button>
                )}

                <button
                  onClick={() => handleDelete(selectedFiche)}
                  className="flex items-center gap-1.5 px-3.5 py-2 bg-rose-50 dark:bg-rose-950/40 border border-rose-200 dark:border-rose-900 text-rose-600 dark:text-rose-400 hover:bg-rose-100 rounded-xl text-sm font-medium transition-all cursor-pointer"
                >
                  <Trash2 className="w-4 h-4" />
                  <span>{lang === 'ar' ? 'حذف' : 'Supprimer'}</span>
                </button>
              </>
            )}
          </div>

          <div className="text-xs text-slate-500 dark:text-slate-400 font-medium">
            {lang === 'ar'
              ? 'انقر نقراً مزدوجاً على أي سطر لفتح محرر البطاقة'
              : 'Double-cliquez sur une ligne pour ouvrir l\'éditeur'}
          </div>
        </div>
      </div>
    </div>
  );
};

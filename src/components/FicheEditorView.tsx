import React, { useState, useEffect } from 'react';
import {
  Save,
  CheckCircle2,
  Printer,
  X,
  Plus,
  Trash2,
  Edit2,
  BookOpen,
  Layers,
  Calculator,
  Percent,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { FicheTechnique, LotFiche, LigneFiche, StatutFiche } from '../types';
import {
  convertirNombreEnLettresAR,
  formaterMontantDZD,
} from '../utils/numberToWordsArabic';

interface FicheEditorViewProps {
  ficheId?: number | null;
}

export const FicheEditorView: React.FC<FicheEditorViewProps> = ({ ficheId }) => {
  const {
    getFiche,
    saveFiche,
    validerFiche,
    genererNumeroFiche,
    projets,
    catalogue,
    settings,
    setCurrentPage,
    setPrintFiche,
    showNotification,
    lang,
  } = useApp();

  const isNew = !ficheId || ficheId === 0;

  // Initial state setup
  const [currentFiche, setCurrentFiche] = useState<FicheTechnique>(() => {
    if (!isNew) {
      const existing = getFiche(ficheId);
      if (existing) return JSON.parse(JSON.stringify(existing));
    }

    const defaultProjetId = projets.length > 0 ? projets[0].id : 1;
    return {
      id: 0,
      numeroFiche: genererNumeroFiche(defaultProjetId),
      projetId: defaultProjetId,
      operation: '',
      dateCreation: new Date().toISOString().split('T')[0],
      dateFiche: new Date().toISOString().split('T')[0],
      tauxTVA: settings.tauxTVADefaut || 9.0,
      statut: 'مسودة' as StatutFiche,
      montantHT: 0,
      montantTVA: 0,
      montantTTC: 0,
      lots: [
        {
          id: `lot-init-1`,
          codeLot: 'LOT-01',
          nomLot: 'أشغال الحفر وتهيئة الأرضية (Terrassements)',
          ordre: 1,
          lignes: [],
        },
      ],
    };
  });

  const [activeLotIndex, setActiveLotIndex] = useState<number>(0);
  const [isCatalogModalOpen, setIsCatalogModalOpen] = useState<boolean>(false);
  const [isAddLotModalOpen, setIsAddLotModalOpen] = useState<boolean>(false);
  const [newLotName, setNewLotName] = useState<string>('');
  const [editingLotName, setEditingLotName] = useState<string | null>(null);

  // Recalculate totals
  const calculateTotals = (lots: LotFiche[], tvaRate: number) => {
    let ht = 0;
    lots.forEach((lot) => {
      lot.lignes.forEach((l) => {
        ht += (l.quantite || 0) * (l.prixUnitaire || 0);
      });
    });
    const tva = (ht * tvaRate) / 100;
    const ttc = ht + tva;
    return { ht, tva, ttc };
  };

  const { ht, tva, ttc } = calculateTotals(currentFiche.lots, currentFiche.tauxTVA);

  // Handle keyboard shortcut Ctrl+S
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 's') {
        e.preventDefault();
        handleSave();
      }
      if (e.key === 'Escape') {
        handleClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [currentFiche]);

  const handleSave = () => {
    if (!currentFiche.operation.trim()) {
      showNotification(
        lang === 'ar' ? 'يرجى إدخال موضوع العملية / الأشغال' : 'Veuillez saisir l\'intitulé de l\'opération',
        'warning'
      );
      return;
    }

    const saved = saveFiche(currentFiche);
    setCurrentFiche(saved);
  };

  const handleValidate = () => {
    if (!currentFiche.id) {
      const saved = saveFiche({ ...currentFiche, statut: 'مصادق عليه' });
      setCurrentFiche(saved);
    } else {
      validerFiche(currentFiche.id);
      setCurrentFiche((prev) => ({ ...prev, statut: 'مصادق عليه' }));
    }
  };

  const handleClose = () => {
    setCurrentPage('fiches');
  };

  // Lot manipulations
  const handleAddLot = () => {
    if (!newLotName.trim()) return;
    const lotCount = currentFiche.lots.length + 1;
    const pad = lotCount < 10 ? `0${lotCount}` : `${lotCount}`;
    const newLot: LotFiche = {
      id: `lot-${Date.now()}`,
      codeLot: `LOT-${pad}`,
      nomLot: newLotName.trim(),
      ordre: lotCount,
      lignes: [],
    };
    setCurrentFiche((prev) => ({
      ...prev,
      lots: [...prev.lots, newLot],
    }));
    setActiveLotIndex(currentFiche.lots.length);
    setNewLotName('');
    setIsAddLotModalOpen(false);
  };

  const handleDeleteLot = (lotIndex: number) => {
    if (currentFiche.lots.length <= 1) {
      showNotification(
        lang === 'ar' ? 'يجب الإبقاء على حصة واحدة على الأقل' : 'Il faut au moins un lot',
        'warning'
      );
      return;
    }
    const msg =
      lang === 'ar'
        ? `هل تريد حذف الحصة "${currentFiche.lots[lotIndex].nomLot}" وجميع أسطرها؟`
        : `Supprimer le lot ${currentFiche.lots[lotIndex].nomLot} ?`;
    if (window.confirm(msg)) {
      const updated = currentFiche.lots.filter((_, idx) => idx !== lotIndex);
      setCurrentFiche((prev) => ({ ...prev, lots: updated }));
      setActiveLotIndex(Math.max(0, lotIndex - 1));
    }
  };

  const handleRenameLot = (lotIndex: number, name: string) => {
    const updatedLots = [...currentFiche.lots];
    updatedLots[lotIndex].nomLot = name;
    setCurrentFiche((prev) => ({ ...prev, lots: updatedLots }));
    setEditingLotName(null);
  };

  // Line manipulations
  const activeLot = currentFiche.lots[activeLotIndex] || currentFiche.lots[0];

  const handleAddEmptyLine = () => {
    if (!activeLot) return;
    const newLineNum = activeLot.lignes.length + 1;
    const newLine: LigneFiche = {
      id: `line-${Date.now()}`,
      numeroLigne: newLineNum,
      designation: '',
      unite: 'm²',
      quantite: 1,
      prixUnitaire: 0,
      montant: 0,
    };

    const updatedLots = [...currentFiche.lots];
    updatedLots[activeLotIndex].lignes.push(newLine);
    setCurrentFiche((prev) => ({ ...prev, lots: updatedLots }));
  };

  const handleImportFromCatalog = (article: (typeof catalogue)[0]) => {
    if (!activeLot) return;
    const newLineNum = activeLot.lignes.length + 1;
    const newLine: LigneFiche = {
      id: `line-${Date.now()}`,
      numeroLigne: newLineNum,
      designation: article.designation,
      unite: article.unite,
      quantite: 1,
      prixUnitaire: article.prixUnitaireRef,
      montant: article.prixUnitaireRef,
    };

    const updatedLots = [...currentFiche.lots];
    updatedLots[activeLotIndex].lignes.push(newLine);
    setCurrentFiche((prev) => ({ ...prev, lots: updatedLots }));
    setIsCatalogModalOpen(false);
    showNotification(lang === 'ar' ? 'تمت إضافة المادة من الكتالوج' : 'Article inséré', 'success');
  };

  const handleUpdateLine = (
    lineIndex: number,
    field: keyof LigneFiche,
    value: string | number
  ) => {
    const updatedLots = [...currentFiche.lots];
    const targetLine = updatedLots[activeLotIndex].lignes[lineIndex];

    if (field === 'quantite' || field === 'prixUnitaire') {
      const numVal = typeof value === 'string' ? parseFloat(value) || 0 : value;
      (targetLine as any)[field] = numVal;
      targetLine.montant = (targetLine.quantite || 0) * (targetLine.prixUnitaire || 0);
    } else {
      (targetLine as any)[field] = value;
    }

    setCurrentFiche((prev) => ({ ...prev, lots: updatedLots }));
  };

  const handleDeleteLine = (lineIndex: number) => {
    const updatedLots = [...currentFiche.lots];
    updatedLots[activeLotIndex].lignes = updatedLots[activeLotIndex].lignes.filter(
      (_, idx) => idx !== lineIndex
    );
    // re-number lines
    updatedLots[activeLotIndex].lignes.forEach((l, i) => {
      l.numeroLigne = i + 1;
    });
    setCurrentFiche((prev) => ({ ...prev, lots: updatedLots }));
  };

  return (
    <div className="space-y-5 pb-12">
      {/* Top Action Toolbar */}
      <div className="bg-white dark:bg-slate-900 p-4 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <button
            onClick={handleClose}
            className="p-2 text-slate-500 hover:text-slate-800 dark:text-slate-400 dark:hover:text-white rounded-xl hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors cursor-pointer"
            title="Fermer / إغلاق"
          >
            <X className="w-5 h-5" />
          </button>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-base font-bold text-slate-900 dark:text-white">
                {isNew
                  ? lang === 'ar'
                    ? 'بطاقة تقنية جديدة'
                    : 'Nouvelle Fiche Technique'
                  : currentFiche.numeroFiche}
              </h2>
              <span className="px-2 py-0.5 rounded-full text-xs font-semibold bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-300 font-mono">
                {currentFiche.statut}
              </span>
            </div>
            <p className="text-xs text-slate-500">
              {lang === 'ar' ? 'نموذج الفاتورة التقديرية والمصالح التقنية' : 'Bordereau des prix unitaires et devis estimatif'}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={handleSave}
            className="flex items-center gap-1.5 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-xl text-sm shadow-xs transition-all cursor-pointer"
          >
            <Save className="w-4 h-4" />
            <span>{lang === 'ar' ? 'حفظ (Ctrl+S)' : 'Enregistrer'}</span>
          </button>

          {currentFiche.statut !== 'مصادق عليه' && (
            <button
              onClick={handleValidate}
              className="flex items-center gap-1.5 px-3.5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-semibold rounded-xl text-sm shadow-xs transition-all cursor-pointer"
            >
              <CheckCircle2 className="w-4 h-4" />
              <span>{lang === 'ar' ? 'مصادقة' : 'Valider'}</span>
            </button>
          )}

          <button
            onClick={() => setPrintFiche(currentFiche)}
            className="flex items-center gap-1.5 px-3.5 py-2 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-700 hover:bg-slate-50 text-slate-700 dark:text-slate-200 font-medium rounded-xl text-sm transition-all cursor-pointer"
          >
            <Printer className="w-4 h-4 text-slate-500" />
            <span>{lang === 'ar' ? 'طباعة / تصدير' : 'Imprimer'}</span>
          </button>
        </div>
      </div>

      {/* Header Form Card */}
      <div className="bg-white dark:bg-slate-900 p-5 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs space-y-4">
        <div className="text-xs font-bold uppercase tracking-wider text-blue-600 dark:text-blue-400">
          {lang === 'ar' ? 'المعلومات الأساسية للبطاقة التقنية' : 'Informations Générales'}
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {/* Projet */}
          <div>
            <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
              {lang === 'ar' ? 'المشروع المعني *' : 'Projet *'}
            </label>
            <select
              value={currentFiche.projetId}
              onChange={(e) =>
                setCurrentFiche({ ...currentFiche, projetId: Number(e.target.value) })
              }
              className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
            >
              {projets.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.code} - {p.nom}
                </option>
              ))}
            </select>
          </div>

          {/* Numéro de Fiche */}
          <div>
            <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
              {lang === 'ar' ? 'رقم البطاقة التقنية *' : 'Numéro de Fiche *'}
            </label>
            <input
              type="text"
              value={currentFiche.numeroFiche}
              onChange={(e) =>
                setCurrentFiche({ ...currentFiche, numeroFiche: e.target.value })
              }
              className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm font-mono font-bold text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
            />
          </div>

          {/* Date de création */}
          <div>
            <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
              {lang === 'ar' ? 'تاريخ التحرير' : 'Date d\'établissement'}
            </label>
            <input
              type="date"
              value={currentFiche.dateFiche}
              onChange={(e) =>
                setCurrentFiche({ ...currentFiche, dateFiche: e.target.value })
              }
              className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm font-mono text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
            />
          </div>

          {/* Intitulé de l'Opération */}
          <div className="md:col-span-2">
            <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
              {lang === 'ar' ? 'تعيين العملية / موضوع الأشغال *' : 'Intitulé de l\'Opération *'}
            </label>
            <textarea
              rows={2}
              value={currentFiche.operation}
              onChange={(e) =>
                setCurrentFiche({ ...currentFiche, operation: e.target.value })
              }
              placeholder={
                lang === 'ar'
                  ? 'مثال: أشغال تهيئة وتعبيد المسالك الحضرية والشوارع الرئيسية...'
                  : 'Ex: Travaux d\'aménagement et de réhabilitation...'
              }
              className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl p-3 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
            />
          </div>

          {/* TVA Rate & Status */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                {lang === 'ar' ? 'نسبة الرسم TVA %' : 'Taux TVA %'}
              </label>
              <div className="relative">
                <input
                  type="number"
                  step="0.5"
                  value={currentFiche.tauxTVA}
                  onChange={(e) =>
                    setCurrentFiche({
                      ...currentFiche,
                      tauxTVA: parseFloat(e.target.value) || 0,
                    })
                  }
                  className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl py-2 px-3 text-sm font-num text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
                />
                <Percent className="w-3.5 h-3.5 text-slate-400 absolute top-3 ltr:right-3 rtl:left-3 pointer-events-none" />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                {lang === 'ar' ? 'حالة البطاقة' : 'Statut'}
              </label>
              <select
                value={currentFiche.statut}
                onChange={(e) =>
                  setCurrentFiche({
                    ...currentFiche,
                    statut: e.target.value as StatutFiche,
                  })
                }
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm font-semibold text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
              >
                <option value="مسودة">مسودة (Brouillon)</option>
                <option value="قيد الدراسة">قيد الدراسة (En étude)</option>
                <option value="مصادق عليه">مصادق عليه (Validé)</option>
                <option value="ملغى">ملغى (Annulé)</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      {/* Lots Tabs Card (Matching PageControlLots from Delphi uFicheTechnique_v3) */}
      <div className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs overflow-hidden">
        {/* Tabs Bar */}
        <div className="bg-slate-100 dark:bg-slate-800/80 px-4 pt-3 flex items-center gap-2 overflow-x-auto border-b border-slate-200 dark:border-slate-800">
          {currentFiche.lots.map((lot, idx) => {
            const isActive = activeLotIndex === idx;
            return (
              <div
                key={lot.id}
                onClick={() => setActiveLotIndex(idx)}
                className={`flex items-center gap-2 px-4 py-2.5 rounded-t-xl text-xs font-bold cursor-pointer transition-all border-t-2 ${
                  isActive
                    ? 'bg-white dark:bg-slate-900 text-blue-600 dark:text-blue-400 border-blue-600 shadow-xs'
                    : 'bg-transparent text-slate-600 dark:text-slate-400 border-transparent hover:text-slate-900 dark:hover:text-slate-200'
                }`}
              >
                <Layers className="w-3.5 h-3.5" />
                <span>{lot.nomLot}</span>
                <span className="px-1.5 py-0.2 rounded-full bg-slate-200 dark:bg-slate-700 text-[10px] font-mono">
                  {lot.lignes.length}
                </span>
              </div>
            );
          })}

          <button
            onClick={() => setIsAddLotModalOpen(true)}
            className="flex items-center gap-1.5 px-3 py-1.5 my-1 text-xs font-semibold text-blue-600 dark:text-blue-400 hover:bg-blue-50 dark:hover:bg-blue-900/30 rounded-lg transition-colors cursor-pointer whitespace-nowrap"
          >
            <Plus className="w-3.5 h-3.5" />
            <span>{lang === 'ar' ? '+ حصة جديدة' : '+ Ajouter un lot'}</span>
          </button>
        </div>

        {/* Active Lot Header & Controls */}
        {activeLot && (
          <div className="p-4 bg-slate-50/70 dark:bg-slate-900/50 border-b border-slate-200 dark:border-slate-800 flex flex-wrap items-center justify-between gap-3">
            <div className="flex items-center gap-2">
              <span className="text-xs font-mono font-bold text-slate-500 uppercase">
                {activeLot.codeLot}:
              </span>
              {editingLotName !== null ? (
                <input
                  type="text"
                  autoFocus
                  defaultValue={activeLot.nomLot}
                  onBlur={(e) => handleRenameLot(activeLotIndex, e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      handleRenameLot(activeLotIndex, (e.target as HTMLInputElement).value);
                    }
                  }}
                  className="bg-white dark:bg-slate-800 px-2 py-1 rounded text-sm border border-blue-500 outline-hidden font-bold"
                />
              ) : (
                <span className="text-sm font-bold text-slate-900 dark:text-white">
                  {activeLot.nomLot}
                </span>
              )}
              <button
                onClick={() => setEditingLotName(activeLot.nomLot)}
                className="p-1 text-slate-400 hover:text-blue-600 rounded transition-colors cursor-pointer"
                title="Renommer le lot"
              >
                <Edit2 className="w-3.5 h-3.5" />
              </button>
            </div>

            <div className="flex items-center gap-2">
              <button
                onClick={handleAddEmptyLine}
                className="flex items-center gap-1.5 px-3 py-1.5 bg-blue-50 dark:bg-blue-900/40 text-blue-600 dark:text-blue-300 hover:bg-blue-100 rounded-lg text-xs font-semibold transition-colors cursor-pointer"
              >
                <Plus className="w-3.5 h-3.5" />
                <span>{lang === 'ar' ? 'سطر جديد' : 'Ajouter ligne'}</span>
              </button>

              <button
                onClick={() => setIsCatalogModalOpen(true)}
                className="flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 dark:bg-emerald-900/40 text-emerald-700 dark:text-emerald-300 hover:bg-emerald-100 rounded-lg text-xs font-semibold transition-colors cursor-pointer"
              >
                <BookOpen className="w-3.5 h-3.5" />
                <span>{lang === 'ar' ? 'من الكتالوج' : 'Du catalogue'}</span>
              </button>

              {currentFiche.lots.length > 1 && (
                <button
                  onClick={() => handleDeleteLot(activeLotIndex)}
                  className="p-1.5 text-rose-500 hover:bg-rose-50 dark:hover:bg-rose-900/30 rounded-lg transition-colors cursor-pointer"
                  title="Supprimer ce lot"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              )}
            </div>
          </div>
        )}

        {/* Lines Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-sm text-start">
            <thead className="bg-slate-50 dark:bg-slate-800/70 text-slate-600 dark:text-slate-300 text-xs font-semibold uppercase tracking-wider border-b border-slate-200 dark:border-slate-800">
              <tr>
                <th className="px-3 py-3 text-center w-12">
                  {lang === 'ar' ? 'الرقم' : 'N°'}
                </th>
                <th className="px-4 py-3 text-start">
                  {lang === 'ar' ? 'تعيين الأشغال والمواد' : 'Désignation des Travaux'}
                </th>
                <th className="px-3 py-3 text-center w-24">
                  {lang === 'ar' ? 'الوحدة' : 'Unité'}
                </th>
                <th className="px-3 py-3 text-center w-28">
                  {lang === 'ar' ? 'الكمية' : 'Quantité'}
                </th>
                <th className="px-3 py-3 text-end w-36">
                  {lang === 'ar' ? 'السعر الوحدوي (دج)' : 'Prix Unitaire (DZD)'}
                </th>
                <th className="px-4 py-3 text-end w-40">
                  {lang === 'ar' ? 'المبلغ الإجمالي (دج)' : 'Montant HT (DZD)'}
                </th>
                <th className="px-3 py-3 text-center w-12"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-800/60">
              {activeLot?.lignes.length === 0 ? (
                <tr>
                  <td colSpan={7} className="text-center py-10 text-slate-400">
                    <p className="mb-2">
                      {lang === 'ar'
                        ? 'لا توجد أسطر أشغال في هذه الحصة'
                        : 'Aucune ligne dans ce lot'}
                    </p>
                    <div className="flex items-center justify-center gap-2">
                      <button
                        onClick={handleAddEmptyLine}
                        className="px-3 py-1.5 bg-blue-600 text-white rounded-lg text-xs font-semibold cursor-pointer"
                      >
                        {lang === 'ar' ? 'إضافة سطر فارغ' : 'Ajouter une ligne'}
                      </button>
                      <button
                        onClick={() => setIsCatalogModalOpen(true)}
                        className="px-3 py-1.5 bg-slate-200 dark:bg-slate-700 text-slate-700 dark:text-slate-200 rounded-lg text-xs font-semibold cursor-pointer"
                      >
                        {lang === 'ar' ? 'اختيار من الكتالوج' : 'Choisir dans le catalogue'}
                      </button>
                    </div>
                  </td>
                </tr>
              ) : (
                activeLot?.lignes.map((ligne, lIdx) => (
                  <tr
                    key={ligne.id}
                    className="hover:bg-blue-50/20 dark:hover:bg-slate-800/30 transition-colors"
                  >
                    <td className="px-3 py-2 text-center font-mono text-xs font-bold text-slate-500">
                      {ligne.numeroLigne}
                    </td>
                    <td className="px-4 py-2">
                      <input
                        type="text"
                        value={ligne.designation}
                        onChange={(e) =>
                          handleUpdateLine(lIdx, 'designation', e.target.value)
                        }
                        placeholder={lang === 'ar' ? 'تعيين الأشغال...' : 'Désignation...'}
                        className="w-full bg-transparent border-b border-transparent focus:border-blue-500 px-1 py-1 text-sm text-slate-800 dark:text-slate-200 outline-hidden font-medium"
                      />
                    </td>
                    <td className="px-3 py-2 text-center">
                      <select
                        value={ligne.unite}
                        onChange={(e) =>
                          handleUpdateLine(lIdx, 'unite', e.target.value)
                        }
                        className="bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg px-2 py-1 text-xs text-center font-medium outline-hidden"
                      >
                        <option value="m³">m³ (م³)</option>
                        <option value="m²">m² (م²)</option>
                        <option value="ml">ml (م.ط)</option>
                        <option value="U">U (وحدة)</option>
                        <option value="kg">kg (كغ)</option>
                        <option value="ens">ens (مجموعة)</option>
                        <option value="ft">ft (جزافي)</option>
                        <option value="j">j (يوم)</option>
                      </select>
                    </td>
                    <td className="px-3 py-2">
                      <input
                        type="number"
                        step="0.01"
                        value={ligne.quantite}
                        onChange={(e) =>
                          handleUpdateLine(lIdx, 'quantite', e.target.value)
                        }
                        className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg py-1 px-2 text-xs font-num font-semibold text-slate-800 dark:text-slate-200 focus:ring-1 focus:ring-blue-500 outline-hidden"
                      />
                    </td>
                    <td className="px-3 py-2">
                      <input
                        type="number"
                        step="1"
                        value={ligne.prixUnitaire}
                        onChange={(e) =>
                          handleUpdateLine(lIdx, 'prixUnitaire', e.target.value)
                        }
                        className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg py-1 px-2 text-xs font-num font-semibold text-slate-800 dark:text-slate-200 focus:ring-1 focus:ring-blue-500 outline-hidden"
                      />
                    </td>
                    <td className="px-4 py-2 text-end font-bold font-num text-blue-600 dark:text-blue-400 whitespace-nowrap">
                      {formaterMontantDZD(ligne.montant)}
                    </td>
                    <td className="px-3 py-2 text-center">
                      <button
                        onClick={() => handleDeleteLine(lIdx)}
                        className="p-1 text-slate-400 hover:text-rose-500 rounded transition-colors cursor-pointer"
                        title="Supprimer"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Recapitulation & Financial Totals (Matching Delphi uFicheTechnique_v3 pnlRecap) */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        {/* Lots Breakdown Table */}
        <div className="lg:col-span-2 bg-white dark:bg-slate-900 p-5 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs space-y-3">
          <div className="flex items-center justify-between border-b border-slate-200 dark:border-slate-800 pb-3">
            <h3 className="text-sm font-bold text-slate-900 dark:text-white flex items-center gap-2">
              <Calculator className="w-4 h-4 text-blue-600" />
              <span>{lang === 'ar' ? 'جدول الحصص والمبالغ الإجمالية' : 'Récapitulatif par Lots'}</span>
            </h3>
            <span className="text-xs text-slate-500">{currentFiche.lots.length} حصص</span>
          </div>

          <div className="space-y-2">
            {currentFiche.lots.map((lot) => {
              const lotTotal = lot.lignes.reduce(
                (acc, curr) => acc + (curr.quantite || 0) * (curr.prixUnitaire || 0),
                0
              );
              return (
                <div
                  key={lot.id}
                  className="flex items-center justify-between p-3 rounded-xl bg-slate-50 dark:bg-slate-800/50 border border-slate-100 dark:border-slate-800"
                >
                  <div className="flex items-center gap-2">
                    <span className="font-mono text-xs font-bold text-blue-600 dark:text-blue-400">
                      {lot.codeLot}
                    </span>
                    <span className="text-xs font-medium text-slate-800 dark:text-slate-200">
                      {lot.nomLot}
                    </span>
                  </div>
                  <div className="font-bold font-num text-sm text-slate-900 dark:text-white">
                    {formaterMontantDZD(lotTotal)}
                  </div>
                </div>
              );
            })}
          </div>

          {/* Amount in Arabic Words Display Box */}
          <div className="p-4 rounded-xl bg-blue-50/60 dark:bg-blue-950/40 border border-blue-200 dark:border-blue-900 text-slate-800 dark:text-blue-200">
            <div className="text-xs font-bold text-blue-900 dark:text-blue-300 mb-1">
              {lang === 'ar' ? 'المبلغ الإجمالي بالأحرف (دينار جزائري):' : 'Montant TTC en toutes lettres :'}
            </div>
            <p className="text-sm font-semibold leading-relaxed">
              {convertirNombreEnLettresAR(ttc)}
            </p>
          </div>
        </div>

        {/* Totals Summary Card */}
        <div className="bg-white dark:bg-slate-900 p-5 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs flex flex-col justify-between">
          <div className="space-y-4">
            <div className="text-xs font-bold uppercase tracking-wider text-slate-500 border-b border-slate-200 dark:border-slate-800 pb-2">
              {lang === 'ar' ? 'البيان المالي الإجمالي' : 'Totaux Financiers'}
            </div>

            <div className="space-y-3">
              <div className="flex justify-between items-center text-sm">
                <span className="text-slate-600 dark:text-slate-400">
                  {lang === 'ar' ? 'المبلغ الصافي بدون رسوم (HT):' : 'Montant Total HT :'}
                </span>
                <span className="font-bold font-num text-slate-900 dark:text-white text-base">
                  {formaterMontantDZD(ht)}
                </span>
              </div>

              <div className="flex justify-between items-center text-sm">
                <span className="text-slate-600 dark:text-slate-400">
                  {lang === 'ar' ? `رسم القيمة المضافة (${currentFiche.tauxTVA}%):` : `Montant TVA (${currentFiche.tauxTVA}%) :`}
                </span>
                <span className="font-bold font-num text-amber-600 dark:text-amber-400">
                  {formaterMontantDZD(tva)}
                </span>
              </div>

              <div className="pt-3 border-t border-slate-200 dark:border-slate-800 flex justify-between items-center">
                <div>
                  <span className="block text-xs font-bold text-slate-500 uppercase">
                    {lang === 'ar' ? 'المبلغ الإجمالي مع الرسوم' : 'Total Général'}
                  </span>
                  <span className="text-lg font-black text-blue-600 dark:text-blue-400">
                    TTC
                  </span>
                </div>
                <div className="text-xl font-black font-num text-blue-700 dark:text-blue-300">
                  {formaterMontantDZD(ttc)}
                </div>
              </div>
            </div>
          </div>

          <div className="pt-6 space-y-2">
            <button
              onClick={handleSave}
              className="w-full py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl text-sm shadow-xs transition-all cursor-pointer flex items-center justify-center gap-2"
            >
              <Save className="w-4 h-4" />
              <span>{lang === 'ar' ? 'حفظ البطاقة التقنية' : 'Enregistrer la fiche'}</span>
            </button>
            <button
              onClick={() => setPrintFiche(currentFiche)}
              className="w-full py-2.5 bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 text-slate-800 dark:text-slate-200 font-semibold rounded-xl text-sm transition-all cursor-pointer flex items-center justify-center gap-2"
            >
              <Printer className="w-4 h-4" />
              <span>{lang === 'ar' ? 'معاينة الطباعة الرسمية' : 'Aperçu & Impression'}</span>
            </button>
          </div>
        </div>
      </div>

      {/* Catalog Selector Modal */}
      {isCatalogModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white dark:bg-slate-900 w-full max-w-2xl rounded-2xl shadow-2xl border border-slate-200 dark:border-slate-800 overflow-hidden flex flex-col max-h-[85vh]">
            <div className="p-4 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between">
              <h3 className="font-bold text-base text-slate-900 dark:text-white flex items-center gap-2">
                <BookOpen className="w-5 h-5 text-blue-600" />
                <span>{lang === 'ar' ? 'اختيار مادة من كتالوج الأسعار المرجعية' : 'Sélectionner depuis le Catalogue'}</span>
              </h3>
              <button
                onClick={() => setIsCatalogModalOpen(false)}
                className="p-1 text-slate-400 hover:text-slate-600 dark:hover:text-white rounded-lg"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-4 overflow-y-auto space-y-2 flex-1">
              {catalogue.map((art) => (
                <div
                  key={art.id}
                  onClick={() => handleImportFromCatalog(art)}
                  className="p-3 rounded-xl border border-slate-200 dark:border-slate-800 hover:border-blue-500 hover:bg-blue-50/40 dark:hover:bg-slate-800/50 cursor-pointer transition-all flex items-center justify-between gap-4"
                >
                  <div>
                    <div className="flex items-center gap-2 mb-1">
                      <span className="font-mono text-xs font-bold text-blue-600 dark:text-blue-400">
                        {art.code}
                      </span>
                      <span className="text-[10px] px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-800 text-slate-500">
                        {art.unite}
                      </span>
                    </div>
                    <p className="text-xs font-medium text-slate-800 dark:text-slate-200">
                      {art.designation}
                    </p>
                  </div>
                  <div className="text-end shrink-0">
                    <div className="font-bold font-num text-sm text-slate-900 dark:text-white">
                      {formaterMontantDZD(art.prixUnitaireRef)}
                    </div>
                    <span className="text-[10px] text-slate-400">سعر مرجعي</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Add Lot Modal */}
      {isAddLotModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white dark:bg-slate-900 w-full max-w-md rounded-2xl shadow-2xl border border-slate-200 dark:border-slate-800 p-5 space-y-4">
            <h3 className="font-bold text-base text-slate-900 dark:text-white">
              {lang === 'ar' ? 'إضافة حصة أشغال جديدة' : 'Nouveau Lot de Travaux'}
            </h3>
            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                {lang === 'ar' ? 'اسم الحصة (مثال: الهيكل والخرسانة، التطهير...)' : 'Nom du Lot'}
              </label>
              <input
                type="text"
                autoFocus
                value={newLotName}
                onChange={(e) => setNewLotName(e.target.value)}
                placeholder="Ex: Lot 02 - Gros Œuvres"
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
              />
            </div>
            <div className="flex items-center justify-end gap-2 pt-2">
              <button
                onClick={() => setIsAddLotModalOpen(false)}
                className="px-3.5 py-2 text-xs font-medium text-slate-600 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-xl"
              >
                {lang === 'ar' ? 'إلغاء' : 'Annuler'}
              </button>
              <button
                onClick={handleAddLot}
                className="px-4 py-2 bg-blue-600 text-white rounded-xl text-xs font-bold hover:bg-blue-700"
              >
                {lang === 'ar' ? 'إضافة الحصة' : 'Ajouter'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

import React, { useState } from 'react';
import {
  BookOpen,
  Plus,
  Trash2,
  Search,
  Check,
  RotateCcw,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { formaterMontantDZD } from '../utils/numberToWordsArabic';

export const CatalogueView: React.FC = () => {
  const { catalogue, addArticle, deleteArticle, typesProjets, lang } = useApp();

  const [searchQuery, setSearchQuery] = useState<string>('');
  const [showAddForm, setShowAddForm] = useState<boolean>(false);

  const [formCode, setFormCode] = useState<string>('ART-' + (catalogue.length + 1));
  const [formDesignation, setFormDesignation] = useState<string>('');
  const [formTypeId, setFormTypeId] = useState<number>(typesProjets[0]?.id || 1);
  const [formUnite, setFormUnite] = useState<string>('m²');
  const [formPrixRef, setFormPrixRef] = useState<number>(1000);

  const handleResetForm = () => {
    setFormCode('ART-' + (catalogue.length + 1));
    setFormDesignation('');
    setFormUnite('m²');
    setFormPrixRef(1000);
    setShowAddForm(false);
  };

  const handleCreate = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formDesignation.trim()) return;

    const selectedType = typesProjets.find((t) => t.id === formTypeId);

    addArticle({
      code: formCode.trim(),
      designation: formDesignation.trim(),
      typeProjetId: formTypeId,
      typeProjetNom: selectedType ? selectedType.nom : 'Général',
      unite: formUnite,
      prixUnitaireRef: Number(formPrixRef) || 0,
      actif: true,
    });

    handleResetForm();
  };

  const filteredCatalogue = catalogue.filter((item) => {
    const q = searchQuery.toLowerCase().trim();
    if (!q) return true;
    return (
      item.code.toLowerCase().includes(q) ||
      item.designation.toLowerCase().includes(q) ||
      item.unite.toLowerCase().includes(q)
    );
  });

  return (
    <div className="space-y-6">
      {/* Top Header Controls */}
      <div className="bg-white dark:bg-slate-900 p-4 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs flex flex-col sm:flex-row gap-3 items-center justify-between">
        <div className="relative w-full sm:w-96">
          <Search className="w-4 h-4 text-slate-400 absolute top-3 ltr:left-3 rtl:right-3 pointer-events-none" />
          <input
            type="text"
            placeholder={lang === 'ar' ? 'بحث في كتالوج المواد والأسعار...' : 'Recherche article...'}
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl py-2 ltr:pl-9 ltr:pr-3 rtl:pr-9 rtl:pl-3 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
          />
        </div>

        <button
          onClick={() => setShowAddForm(!showAddForm)}
          className="w-full sm:w-auto flex items-center justify-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-semibold shadow-xs transition-all cursor-pointer whitespace-nowrap"
        >
          <Plus className="w-4 h-4" />
          <span>{lang === 'ar' ? 'إضافة مادة جديدة' : 'Nouvel Article'}</span>
        </button>
      </div>

      {/* Add Article Form */}
      {showAddForm && (
        <div className="bg-white dark:bg-slate-900 p-5 rounded-2xl border border-blue-200 dark:border-blue-900/60 shadow-md">
          <div className="flex items-center justify-between border-b border-slate-200 dark:border-slate-800 pb-3 mb-4">
            <h3 className="font-bold text-sm text-slate-900 dark:text-white flex items-center gap-2">
              <BookOpen className="w-4 h-4 text-blue-600" />
              <span>{lang === 'ar' ? 'إضافة مادة / عمل جديد للكتالوج المرجعي' : 'Ajouter un article au catalogue'}</span>
            </h3>
            <button
              onClick={handleResetForm}
              className="text-xs text-slate-400 hover:text-slate-600 dark:hover:text-slate-200"
            >
              <RotateCcw className="w-4 h-4" />
            </button>
          </div>

          <form onSubmit={handleCreate} className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4">
              <div>
                <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                  {lang === 'ar' ? 'رمز المادة *' : 'Code Article *'}
                </label>
                <input
                  type="text"
                  required
                  value={formCode}
                  onChange={(e) => setFormCode(e.target.value)}
                  className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm font-mono text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                  {lang === 'ar' ? 'الوحدة' : 'Unité'}
                </label>
                <select
                  value={formUnite}
                  onChange={(e) => setFormUnite(e.target.value)}
                  className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
                >
                  <option value="m³">m³ (متر مكعب)</option>
                  <option value="m²">m² (متر مربع)</option>
                  <option value="ml">ml (متر طولي)</option>
                  <option value="U">U (وحدة)</option>
                  <option value="kg">kg (كيلوغرام)</option>
                  <option value="ens">ens (مجموعة)</option>
                  <option value="ft">ft (جزافي)</option>
                  <option value="j">j (يوم)</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                  {lang === 'ar' ? 'السعر المرجعي التقديري (دج) *' : 'Prix Réf. DZD *'}
                </label>
                <input
                  type="number"
                  step="1"
                  required
                  value={formPrixRef}
                  onChange={(e) => setFormPrixRef(parseFloat(e.target.value) || 0)}
                  className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm font-num font-semibold text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                  {lang === 'ar' ? 'التصنيف / التخصص' : 'Catégorie'}
                </label>
                <select
                  value={formTypeId}
                  onChange={(e) => setFormTypeId(Number(e.target.value))}
                  className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
                >
                  {typesProjets.map((t) => (
                    <option key={t.id} value={t.id}>
                      {t.nom}
                    </option>
                  ))}
                </select>
              </div>

              <div className="sm:col-span-4">
                <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                  {lang === 'ar' ? 'تعيين الأشغال والتوصيف الدقيق *' : 'Désignation complète *'}
                </label>
                <textarea
                  rows={2}
                  required
                  value={formDesignation}
                  onChange={(e) => setFormDesignation(e.target.value)}
                  placeholder="Ex: خرسانة مسلحة للأساسات عيار 350 كغ/م³..."
                  className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl p-3 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
                />
              </div>
            </div>

            <div className="flex justify-end gap-2">
              <button
                type="button"
                onClick={handleResetForm}
                className="px-4 py-2 bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 rounded-xl text-xs font-semibold"
              >
                {lang === 'ar' ? 'إلغاء' : 'Annuler'}
              </button>
              <button
                type="submit"
                className="flex items-center gap-1.5 px-5 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold shadow-xs cursor-pointer"
              >
                <Check className="w-4 h-4" />
                <span>{lang === 'ar' ? 'إضافة إلى الكتالوج' : 'Enregistrer'}</span>
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Catalog Table */}
      <div className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm text-start">
            <thead className="bg-slate-50 dark:bg-slate-800/70 text-slate-600 dark:text-slate-300 text-xs font-semibold uppercase tracking-wider border-b border-slate-200 dark:border-slate-800">
              <tr>
                <th className="px-4 py-3 text-center w-16">#</th>
                <th className="px-4 py-3 text-center">
                  {lang === 'ar' ? 'الرمز' : 'Code'}
                </th>
                <th className="px-5 py-3 text-start">
                  {lang === 'ar' ? 'تعيين الأشغال والمواد' : 'Désignation'}
                </th>
                <th className="px-4 py-3 text-center w-24">
                  {lang === 'ar' ? 'الوحدة' : 'Unité'}
                </th>
                <th className="px-5 py-3 text-end w-40">
                  {lang === 'ar' ? 'السعر المرجعي (دج)' : 'Prix Unitaire Réf.'}
                </th>
                <th className="px-4 py-3 text-center w-20">
                  {lang === 'ar' ? 'إجراءات' : 'Actions'}
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-800/60">
              {filteredCatalogue.map((art, idx) => (
                <tr
                  key={art.id}
                  className={`hover:bg-blue-50/20 dark:hover:bg-slate-800/30 transition-colors ${
                    idx % 2 === 1 ? 'bg-slate-50/40 dark:bg-slate-900/30' : ''
                  }`}
                >
                  <td className="px-4 py-3 text-center font-mono text-xs text-slate-400">
                    {idx + 1}
                  </td>
                  <td className="px-4 py-3 text-center font-mono font-bold text-blue-600 dark:text-blue-400 whitespace-nowrap">
                    {art.code}
                  </td>
                  <td className="px-5 py-3 font-medium text-slate-800 dark:text-slate-200">
                    {art.designation}
                  </td>
                  <td className="px-4 py-3 text-center font-mono text-xs font-bold text-slate-600 dark:text-slate-400">
                    {art.unite}
                  </td>
                  <td className="px-5 py-3 text-end font-bold font-num text-slate-900 dark:text-white whitespace-nowrap">
                    {formaterMontantDZD(art.prixUnitaireRef)}
                  </td>
                  <td className="px-4 py-3 text-center">
                    <button
                      onClick={() => deleteArticle(art.id)}
                      className="p-1.5 text-rose-500 hover:bg-rose-50 dark:hover:bg-rose-900/30 rounded-lg transition-colors cursor-pointer"
                      title="Supprimer"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

import React, { useState } from 'react';
import {
  FolderPlus,
  Edit2,
  Trash2,
  RotateCcw,
  Check,
  Search,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { Projet } from '../types';

export const ProjetsView: React.FC = () => {
  const {
    projets,
    typesProjets,
    addProjet,
    updateProjet,
    deleteProjet,
    fiches,
    lang,
  } = useApp();

  const [editingId, setEditingId] = useState<number | null>(null);
  const [searchQuery, setSearchQuery] = useState<string>('');

  const [formCode, setFormCode] = useState<string>('PRJ-2026-0' + (projets.length + 1));
  const [formTypeId, setFormTypeId] = useState<number>(typesProjets[0]?.id || 1);
  const [formNom, setFormNom] = useState<string>('');
  const [formWilaya, setFormWilaya] = useState<string>('الجزائر');
  const [formDaira, setFormDaira] = useState<string>('الدار البيضاء');
  const [formCommune, setFormCommune] = useState<string>('باب الزوار');
  const [formMaitreOuvrage, setFormMaitreOuvrage] = useState<string>(
    'مديرية التجهيزات العمومية'
  );

  const handleEditClick = (p: Projet) => {
    setEditingId(p.id);
    setFormCode(p.code);
    setFormTypeId(p.typeProjetId);
    setFormNom(p.nom);
    setFormWilaya(p.wilaya);
    setFormDaira(p.daira);
    setFormCommune(p.commune);
    setFormMaitreOuvrage(p.maitreOuvrage);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleResetForm = () => {
    setEditingId(null);
    setFormCode('PRJ-2026-0' + (projets.length + 1));
    setFormTypeId(typesProjets[0]?.id || 1);
    setFormNom('');
    setFormWilaya('الجزائر');
    setFormDaira('الدار البيضاء');
    setFormCommune('باب الزوار');
    setFormMaitreOuvrage('مديرية التجهيزات العمومية');
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formNom.trim() || !formCode.trim()) return;

    const selectedType = typesProjets.find((t) => t.id === formTypeId);
    const typeNom = selectedType ? selectedType.nom : 'Autre';

    if (editingId) {
      updateProjet(editingId, {
        code: formCode,
        typeProjetId: formTypeId,
        typeProjetNom: typeNom,
        nom: formNom,
        wilaya: formWilaya,
        daira: formDaira,
        commune: formCommune,
        maitreOuvrage: formMaitreOuvrage,
      });
      handleResetForm();
    } else {
      addProjet({
        code: formCode,
        typeProjetId: formTypeId,
        typeProjetNom: typeNom,
        nom: formNom,
        wilaya: formWilaya,
        daira: formDaira,
        commune: formCommune,
        maitreOuvrage: formMaitreOuvrage,
      });
      handleResetForm();
    }
  };

  const filteredProjets = projets.filter((p) => {
    const q = searchQuery.toLowerCase().trim();
    if (!q) return true;
    return (
      p.code.toLowerCase().includes(q) ||
      p.nom.toLowerCase().includes(q) ||
      p.commune.toLowerCase().includes(q) ||
      p.maitreOuvrage.toLowerCase().includes(q)
    );
  });

  return (
    <div className="space-y-6">
      {/* Form Card (Add/Edit) */}
      <div className="bg-white dark:bg-slate-900 p-5 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs">
        <div className="flex items-center justify-between border-b border-slate-200 dark:border-slate-800 pb-3 mb-4">
          <div className="flex items-center gap-2">
            <FolderPlus className="w-5 h-5 text-blue-600" />
            <h3 className="font-bold text-sm text-slate-900 dark:text-white">
              {editingId
                ? lang === 'ar'
                  ? 'تعديل بيانات المشروع'
                  : 'Modifier le projet'
                : lang === 'ar'
                ? 'إضافة مشروع جديد'
                : 'Nouveau projet'}
            </h3>
          </div>
          {editingId && (
            <button
              onClick={handleResetForm}
              className="text-xs text-slate-500 hover:text-slate-800 flex items-center gap-1"
            >
              <RotateCcw className="w-3.5 h-3.5" />
              <span>{lang === 'ar' ? 'إلغاء التعديل' : 'Annuler'}</span>
            </button>
          )}
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                {lang === 'ar' ? 'رمز المشروع *' : 'Code Projet *'}
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
                {lang === 'ar' ? 'نوع المشروع' : 'Type de Projet'}
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

            <div className="sm:col-span-2">
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                {lang === 'ar' ? 'تسمية / اسم المشروع *' : 'Nom du Projet *'}
              </label>
              <input
                type="text"
                required
                value={formNom}
                onChange={(e) => setFormNom(e.target.value)}
                placeholder="Ex: تهيئة وتعبيد المسالك الحضرية"
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                {lang === 'ar' ? 'الولاية' : 'Wilaya'}
              </label>
              <input
                type="text"
                value={formWilaya}
                onChange={(e) => setFormWilaya(e.target.value)}
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                {lang === 'ar' ? 'الدائرة' : 'Daïra'}
              </label>
              <input
                type="text"
                value={formDaira}
                onChange={(e) => setFormDaira(e.target.value)}
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                {lang === 'ar' ? 'البلدية' : 'Commune'}
              </label>
              <input
                type="text"
                value={formCommune}
                onChange={(e) => setFormCommune(e.target.value)}
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                {lang === 'ar' ? 'صاحب المشروع (المصلحة المتعاقدة)' : 'Maître d\'Ouvrage'}
              </label>
              <input
                type="text"
                value={formMaitreOuvrage}
                onChange={(e) => setFormMaitreOuvrage(e.target.value)}
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
              />
            </div>
          </div>

          <div className="flex justify-end gap-2 pt-2">
            {editingId && (
              <button
                type="button"
                onClick={handleResetForm}
                className="px-4 py-2 bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 text-slate-700 dark:text-slate-300 rounded-xl text-xs font-semibold"
              >
                {lang === 'ar' ? 'إلغاء' : 'Annuler'}
              </button>
            )}
            <button
              type="submit"
              className="flex items-center gap-1.5 px-5 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold shadow-xs cursor-pointer"
            >
              <Check className="w-4 h-4" />
              <span>{editingId ? (lang === 'ar' ? 'تحديث المشروع' : 'Mettre à jour') : (lang === 'ar' ? 'تسجيل المشروع' : 'Ajouter le projet')}</span>
            </button>
          </div>
        </form>
      </div>

      {/* Projects List Card */}
      <div className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs overflow-hidden">
        <div className="p-4 border-b border-slate-200 dark:border-slate-800 flex flex-col sm:flex-row gap-3 items-center justify-between">
          <div className="relative w-full sm:w-80">
            <Search className="w-4 h-4 text-slate-400 absolute top-2.5 ltr:left-3 rtl:right-3 pointer-events-none" />
            <input
              type="text"
              placeholder={lang === 'ar' ? 'بحث في المشاريع...' : 'Recherche projet...'}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl py-1.5 ltr:pl-9 ltr:pr-3 rtl:pr-9 rtl:pl-3 text-xs text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
            />
          </div>
          <span className="text-xs font-semibold text-slate-500">
            {filteredProjets.length} {lang === 'ar' ? 'مشاريع مسجلة' : 'projets'}
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-sm text-start">
            <thead className="bg-slate-50 dark:bg-slate-800/70 text-slate-600 dark:text-slate-300 text-xs font-semibold uppercase tracking-wider border-b border-slate-200 dark:border-slate-800">
              <tr>
                <th className="px-4 py-3 text-center w-16">#</th>
                <th className="px-4 py-3 text-center">
                  {lang === 'ar' ? 'الرمز' : 'Code'}
                </th>
                <th className="px-4 py-3 text-start">
                  {lang === 'ar' ? 'اسم المشروع' : 'Nom'}
                </th>
                <th className="px-4 py-3 text-start">
                  {lang === 'ar' ? 'النوع' : 'Type'}
                </th>
                <th className="px-4 py-3 text-start">
                  {lang === 'ar' ? 'الولاية / البلدية' : 'Localisation'}
                </th>
                <th className="px-4 py-3 text-start">
                  {lang === 'ar' ? 'المصلحة المتعاقدة' : 'Maître d\'Ouvrage'}
                </th>
                <th className="px-4 py-3 text-center">
                  {lang === 'ar' ? 'البطاقات المرتبطة' : 'Fiches'}
                </th>
                <th className="px-4 py-3 text-center w-24">
                  {lang === 'ar' ? 'إجراءات' : 'Actions'}
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-800/60">
              {filteredProjets.map((p, idx) => {
                const attachedFiches = fiches.filter((f) => f.projetId === p.id);
                return (
                  <tr
                    key={p.id}
                    className={`hover:bg-blue-50/20 dark:hover:bg-slate-800/30 transition-colors ${
                      idx % 2 === 1 ? 'bg-slate-50/40 dark:bg-slate-900/30' : ''
                    }`}
                  >
                    <td className="px-4 py-3 text-center font-mono text-xs text-slate-400">
                      {idx + 1}
                    </td>
                    <td className="px-4 py-3 text-center font-mono font-bold text-blue-600 dark:text-blue-400 whitespace-nowrap">
                      {p.code}
                    </td>
                    <td className="px-4 py-3 font-semibold text-slate-900 dark:text-white">
                      {p.nom}
                    </td>
                    <td className="px-4 py-3 text-xs text-slate-600 dark:text-slate-400">
                      {p.typeProjetNom}
                    </td>
                    <td className="px-4 py-3 text-xs text-slate-600 dark:text-slate-400 whitespace-nowrap">
                      {p.wilaya} • {p.commune}
                    </td>
                    <td className="px-4 py-3 text-xs text-slate-600 dark:text-slate-400">
                      {p.maitreOuvrage}
                    </td>
                    <td className="px-4 py-3 text-center">
                      <span className="px-2 py-0.5 rounded-full text-xs font-bold font-mono bg-blue-50 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300">
                        {attachedFiches.length}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-center whitespace-nowrap">
                      <div className="flex items-center justify-center gap-1">
                        <button
                          onClick={() => handleEditClick(p)}
                          className="p-1.5 text-blue-600 hover:bg-blue-100 dark:hover:bg-blue-900/30 rounded-lg transition-colors cursor-pointer"
                          title="Modifier"
                        >
                          <Edit2 className="w-3.5 h-3.5" />
                        </button>
                        <button
                          onClick={() => deleteProjet(p.id)}
                          className="p-1.5 text-rose-500 hover:bg-rose-50 dark:hover:bg-rose-900/30 rounded-lg transition-colors cursor-pointer"
                          title="Supprimer"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

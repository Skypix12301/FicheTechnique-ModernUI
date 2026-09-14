import React, { useState } from 'react';
import {
  Save,
  Building,
  Palette,
  Coins,
  AlertTriangle,
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { AppSettings } from '../types';

export const ParametresView: React.FC = () => {
  const { settings, updateSettings, resetToDefaults, lang, isDark, toggleTheme, setLang } =
    useApp();

  const [formData, setFormData] = useState<AppSettings>({ ...settings });

  const handleChange = (field: keyof AppSettings, value: any) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    updateSettings(formData);
  };

  const handleResetData = () => {
    const msg =
      lang === 'ar'
        ? 'تحذير: سيتم إعادة ضبط قاعدة البيانات إلى النماذج الافتراضية. هل تود الاستمرار؟'
        : 'Attention : réinitialiser toutes les données aux valeurs d\'exemple ?';
    if (window.confirm(msg)) {
      resetToDefaults();
    }
  };

  return (
    <div className="max-w-4xl space-y-6 pb-12">
      <form onSubmit={handleSave} className="space-y-6">
        {/* Organisme & Entête Officiel */}
        <div className="bg-white dark:bg-slate-900 p-5 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs space-y-4">
          <div className="flex items-center gap-2 border-b border-slate-200 dark:border-slate-800 pb-3">
            <Building className="w-5 h-5 text-blue-600" />
            <h3 className="font-bold text-sm text-slate-900 dark:text-white">
              {lang === 'ar' ? 'المؤسسة والهيئة الإدارية (ترويسة الوثائق)' : 'Organisme & Entête Administratif'}
            </h3>
          </div>

          <div className="space-y-3">
            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                {lang === 'ar' ? 'الهيئة الرسمية العليا' : 'Organisme Supérieur'}
              </label>
              <input
                type="text"
                value={formData.organisme}
                onChange={(e) => handleChange('organisme', e.target.value)}
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                {lang === 'ar' ? 'المديرية أو المصلحة التقنية' : 'Direction / Service Technique'}
              </label>
              <input
                type="text"
                value={formData.direction}
                onChange={(e) => handleChange('direction', e.target.value)}
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div>
                <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                  {lang === 'ar' ? 'الولاية' : 'Wilaya'}
                </label>
                <input
                  type="text"
                  value={formData.wilaya}
                  onChange={(e) => handleChange('wilaya', e.target.value)}
                  className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                  {lang === 'ar' ? 'الدائرة' : 'Daïra'}
                </label>
                <input
                  type="text"
                  value={formData.daira}
                  onChange={(e) => handleChange('daira', e.target.value)}
                  className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                  {lang === 'ar' ? 'البلدية' : 'Commune'}
                </label>
                <input
                  type="text"
                  value={formData.commune}
                  onChange={(e) => handleChange('commune', e.target.value)}
                  className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Paramètres Financiers */}
        <div className="bg-white dark:bg-slate-900 p-5 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs space-y-4">
          <div className="flex items-center gap-2 border-b border-slate-200 dark:border-slate-800 pb-3">
            <Coins className="w-5 h-5 text-amber-500" />
            <h3 className="font-bold text-sm text-slate-900 dark:text-white">
              {lang === 'ar' ? 'الإعدادات المالية والرسوم' : 'Paramètres Financiers & Taxes'}
            </h3>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                {lang === 'ar' ? 'نسبة الرسم على القيمة المضافة الافتراضية (TVA %)' : 'Taux TVA par Défaut (%)'}
              </label>
              <input
                type="number"
                step="0.5"
                value={formData.tauxTVADefaut}
                onChange={(e) =>
                  handleChange('tauxTVADefaut', parseFloat(e.target.value) || 0)
                }
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm font-num text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                {lang === 'ar' ? 'العملة والرمز' : 'Devise'}
              </label>
              <input
                type="text"
                value={formData.devise}
                onChange={(e) => handleChange('devise', e.target.value)}
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-3 py-2 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden"
              />
            </div>
          </div>
        </div>

        {/* Affichage & Thème */}
        <div className="bg-white dark:bg-slate-900 p-5 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-xs space-y-4">
          <div className="flex items-center gap-2 border-b border-slate-200 dark:border-slate-800 pb-3">
            <Palette className="w-5 h-5 text-indigo-500" />
            <h3 className="font-bold text-sm text-slate-900 dark:text-white">
              {lang === 'ar' ? 'المظهر واللغة' : 'Apparence & Interface'}
            </h3>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                {lang === 'ar' ? 'السمة المرئية' : 'Thème'}
              </label>
              <div className="flex items-center gap-3">
                <button
                  type="button"
                  onClick={toggleTheme}
                  className={`flex-1 py-2 rounded-xl text-xs font-bold border transition-all cursor-pointer ${
                    !isDark
                      ? 'bg-blue-50 border-blue-500 text-blue-700'
                      : 'border-slate-700 text-slate-400'
                  }`}
                >
                  {lang === 'ar' ? 'فاتح / نهاري' : 'Clair'}
                </button>
                <button
                  type="button"
                  onClick={toggleTheme}
                  className={`flex-1 py-2 rounded-xl text-xs font-bold border transition-all cursor-pointer ${
                    isDark
                      ? 'bg-blue-900/40 border-blue-500 text-blue-300'
                      : 'border-slate-200 text-slate-600'
                  }`}
                >
                  {lang === 'ar' ? 'داكن / ليلي' : 'Sombre'}
                </button>
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1">
                {lang === 'ar' ? 'لغة الواجهة' : 'Langue'}
              </label>
              <div className="flex items-center gap-3">
                <button
                  type="button"
                  onClick={() => setLang('ar')}
                  className={`flex-1 py-2 rounded-xl text-xs font-bold border transition-all cursor-pointer ${
                    lang === 'ar'
                      ? 'bg-emerald-50 border-emerald-500 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-300'
                      : 'border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-400'
                  }`}
                >
                  العربية (RTL)
                </button>
                <button
                  type="button"
                  onClick={() => setLang('fr')}
                  className={`flex-1 py-2 rounded-xl text-xs font-bold border transition-all cursor-pointer ${
                    lang === 'fr'
                      ? 'bg-emerald-50 border-emerald-500 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-300'
                      : 'border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-400'
                  }`}
                >
                  Français (LTR)
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Save Bar */}
        <div className="flex items-center justify-between pt-2">
          <button
            type="button"
            onClick={handleResetData}
            className="flex items-center gap-1.5 px-4 py-2.5 text-xs font-medium text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/30 rounded-xl transition-colors cursor-pointer border border-rose-200 dark:border-rose-900"
          >
            <AlertTriangle className="w-4 h-4" />
            <span>{lang === 'ar' ? 'استعادة البيانات النموذجية الأولية' : 'Restaurer les données d\'exemple'}</span>
          </button>

          <button
            type="submit"
            className="flex items-center gap-2 px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-sm font-bold shadow-xs transition-all cursor-pointer"
          >
            <Save className="w-4 h-4" />
            <span>{lang === 'ar' ? 'حفظ التعديلات' : 'Enregistrer les paramètres'}</span>
          </button>
        </div>
      </form>
    </div>
  );
};

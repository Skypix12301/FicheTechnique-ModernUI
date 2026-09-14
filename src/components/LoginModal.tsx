import React, { useState } from 'react';
import { Building2, User, KeyRound, ArrowRight } from 'lucide-react';
import { useApp } from '../context/AppContext';

export const LoginModal: React.FC = () => {
  const { login, lang } = useApp();
  const [username, setUsername] = useState<string>('admin');
  const [password, setPassword] = useState<string>('admin');
  const [rememberMe, setRememberMe] = useState<boolean>(true);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    login(username, password);
  };

  return (
    <div className="fixed inset-0 bg-slate-950/80 backdrop-blur-xs z-50 flex items-center justify-center p-4">
      <div className="bg-white dark:bg-slate-900 w-full max-w-md rounded-3xl shadow-2xl border border-slate-200 dark:border-slate-800 overflow-hidden">
        {/* Banner */}
        <div className="bg-gradient-to-r from-blue-600 via-indigo-600 to-slate-900 text-white p-8 text-center relative overflow-hidden">
          <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full blur-2xl"></div>
          <div className="w-16 h-16 rounded-2xl bg-white/20 backdrop-blur-md flex items-center justify-center mx-auto mb-4 shadow-lg">
            <Building2 className="w-8 h-8 text-white" />
          </div>
          <h2 className="text-xl font-extrabold tracking-wide">
            {lang === 'ar' ? 'إدارة البطاقات التقنية' : 'Fiches Techniques v4'}
          </h2>
          <p className="text-xs text-blue-200 mt-1">
            {lang === 'ar'
              ? 'بوابة الدخول لمنظومة المصالح التقنية والتجهيزات'
              : 'Système de gestion et de suivi des projets'}
          </p>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div>
            <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
              {lang === 'ar' ? 'اسم المستخدم' : 'Nom d\'utilisateur'}
            </label>
            <div className="relative">
              <User className="w-4 h-4 text-slate-400 absolute top-3 ltr:left-3 rtl:right-3 pointer-events-none" />
              <input
                type="text"
                required
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl py-2.5 ltr:pl-9 ltr:pr-3 rtl:pr-9 rtl:pl-3 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden font-medium"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
              {lang === 'ar' ? 'كلمة المرور' : 'Mot de passe'}
            </label>
            <div className="relative">
              <KeyRound className="w-4 h-4 text-slate-400 absolute top-3 ltr:left-3 rtl:right-3 pointer-events-none" />
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl py-2.5 ltr:pl-9 ltr:pr-3 rtl:pr-9 rtl:pl-3 text-sm text-slate-800 dark:text-slate-200 focus:ring-2 focus:ring-blue-500 outline-hidden font-medium"
              />
            </div>
          </div>

          <div className="flex items-center justify-between text-xs pt-1">
            <label className="flex items-center gap-2 cursor-pointer text-slate-600 dark:text-slate-400">
              <input
                type="checkbox"
                checked={rememberMe}
                onChange={(e) => setRememberMe(e.target.checked)}
                className="rounded border-slate-300 text-blue-600 focus:ring-blue-500"
              />
              <span>{lang === 'ar' ? 'تذكر بيانات الدخول' : 'Se souvenir de moi'}</span>
            </label>
            <span className="text-[11px] text-blue-600 dark:text-blue-400">
              (افتراضي: admin / admin)
            </span>
          </div>

          <button
            type="submit"
            className="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl text-sm shadow-md shadow-blue-600/20 transition-all cursor-pointer flex items-center justify-center gap-2 mt-4"
          >
            <span>{lang === 'ar' ? 'تسجيل الدخول' : 'Connexion'}</span>
            <ArrowRight className="w-4 h-4 rtl:rotate-180" />
          </button>
        </form>
      </div>
    </div>
  );
};

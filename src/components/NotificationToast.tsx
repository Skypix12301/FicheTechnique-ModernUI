import React from 'react';
import { CheckCircle2, AlertCircle, AlertTriangle, Info } from 'lucide-react';
import { useApp } from '../context/AppContext';

export const NotificationToast: React.FC = () => {
  const { notification } = useApp();

  if (!notification) return null;

  const getIcon = () => {
    switch (notification.type) {
      case 'success':
        return <CheckCircle2 className="w-5 h-5 text-emerald-500 shrink-0" />;
      case 'error':
        return <AlertCircle className="w-5 h-5 text-rose-500 shrink-0" />;
      case 'warning':
        return <AlertTriangle className="w-5 h-5 text-amber-500 shrink-0" />;
      case 'info':
      default:
        return <Info className="w-5 h-5 text-blue-500 shrink-0" />;
    }
  };

  return (
    <div className="fixed bottom-6 ltr:right-6 rtl:left-6 z-50 flex items-center gap-3 px-4 py-3 bg-slate-900 text-white dark:bg-white dark:text-slate-900 rounded-2xl shadow-2xl border border-slate-700 dark:border-slate-200 animate-in fade-in slide-in-from-bottom-5 duration-200 max-w-md">
      {getIcon()}
      <span className="text-xs font-semibold">{notification.message}</span>
    </div>
  );
};

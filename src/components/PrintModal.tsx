import React from 'react';
import { Printer, X } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { FicheTechnique } from '../types';
import {
  convertirNombreEnLettresAR,
  formaterMontantDZD,
} from '../utils/numberToWordsArabic';

interface PrintModalProps {
  fiche: FicheTechnique;
  onClose: () => void;
}

export const PrintModal: React.FC<PrintModalProps> = ({ fiche, onClose }) => {
  const { settings, projets, lang } = useApp();
  const projet = projets.find((p) => p.id === fiche.projetId);

  const handlePrint = () => {
    window.print();
  };

  return (
    <div className="fixed inset-0 bg-black/60 z-50 overflow-y-auto flex justify-center p-4 print:p-0 print:bg-white print:static">
      {/* Container */}
      <div className="bg-white text-slate-900 w-full max-w-4xl my-8 rounded-2xl shadow-2xl border border-slate-200 overflow-hidden flex flex-col print:m-0 print:border-none print:shadow-none print:w-full print:max-w-none">
        {/* Modal Controls (Hidden in Print) */}
        <div className="no-print bg-slate-900 text-white p-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Printer className="w-5 h-5 text-blue-400" />
            <span className="font-bold text-sm">
              {lang === 'ar'
                ? `معاينة طباعة البطاقة التقنية رقم: ${fiche.numeroFiche}`
                : `Aperçu avant impression - ${fiche.numeroFiche}`}
            </span>
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={handlePrint}
              className="flex items-center gap-1.5 px-4 py-2 bg-blue-600 hover:bg-blue-500 text-white rounded-xl text-xs font-bold shadow transition-all cursor-pointer"
            >
              <Printer className="w-4 h-4" />
              <span>{lang === 'ar' ? 'طباعة الوثيقة (A4)' : 'Imprimer'}</span>
            </button>
            <button
              onClick={onClose}
              className="p-1.5 text-slate-400 hover:text-white rounded-lg"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Printable Official Document Body */}
        <div className="p-8 space-y-6 text-sm leading-normal font-sans">
          {/* Official Republic Header */}
          <div className="text-center space-y-1 border-b-2 border-slate-900 pb-4">
            <div className="font-bold text-base tracking-wide">
              {settings.organisme ||
                'الجمهورية الجزائرية الديمقراطية الشعبية - وزارة الداخلية والجماعات المحلية'}
            </div>
            <div className="text-xs font-medium text-slate-700 flex justify-center gap-6">
              <span>{settings.wilaya || 'ولاية الجزائر'}</span>
              <span>•</span>
              <span>{settings.daira || 'دائرة الدار البيضاء'}</span>
              <span>•</span>
              <span>{settings.commune || 'بلدية باب الزوار'}</span>
            </div>
            <div className="text-xs font-bold text-blue-900">
              {settings.direction || 'مديرية المصالح التقنية والتجهيزات العمومية'}
            </div>
          </div>

          {/* Document Title Banner */}
          <div className="text-center py-2 bg-slate-100 border border-slate-300 rounded-lg">
            <h1 className="text-lg font-black text-slate-900 tracking-wide">
              بطاقة تقنية تقديرية للأشغال
            </h1>
            <h2 className="text-xs font-bold uppercase tracking-widest text-slate-600">
              FICHE TECHNIQUE ESTIMATIVE DES TRAVAUX
            </h2>
          </div>

          {/* Project & Fiche Identifiers */}
          <div className="grid grid-cols-2 gap-4 text-xs bg-slate-50 p-4 rounded-xl border border-slate-200">
            <div className="space-y-1.5">
              <div>
                <span className="font-bold text-slate-700">المشروع : </span>
                <span className="font-semibold text-slate-900">{projet?.nom || '—'}</span>
              </div>
              <div>
                <span className="font-bold text-slate-700">المصلحة المتعاقدة : </span>
                <span>{projet?.maitreOuvrage || '—'}</span>
              </div>
              <div>
                <span className="font-bold text-slate-700">الموقع : </span>
                <span>
                  {projet?.wilaya} - {projet?.commune}
                </span>
              </div>
            </div>

            <div className="space-y-1.5 ltr:text-right rtl:text-left font-mono">
              <div>
                <span className="font-bold font-sans text-slate-700">رقم البطاقة : </span>
                <span className="font-bold text-blue-700">{fiche.numeroFiche}</span>
              </div>
              <div>
                <span className="font-bold font-sans text-slate-700">تاريخ التحرير : </span>
                <span>{fiche.dateFiche}</span>
              </div>
              <div>
                <span className="font-bold font-sans text-slate-700">حالة الاعتماد : </span>
                <span className="font-bold text-emerald-700">{fiche.statut}</span>
              </div>
            </div>

            <div className="col-span-2 pt-2 border-t border-slate-200">
              <span className="font-bold text-slate-700">موضوع العملية : </span>
              <span className="font-medium text-slate-900">{fiche.operation}</span>
            </div>
          </div>

          {/* Lots & Lines Breakdown Table */}
          <div className="space-y-4">
            {fiche.lots.map((lot) => (
              <div key={lot.id} className="space-y-1">
                <div className="bg-slate-800 text-white px-3 py-1.5 rounded-t font-bold text-xs flex justify-between">
                  <span>
                    {lot.codeLot} : {lot.nomLot}
                  </span>
                </div>

                <table className="w-full text-xs border-collapse border border-slate-300">
                  <thead className="bg-slate-100 text-slate-700">
                    <tr>
                      <th className="border border-slate-300 px-2 py-1.5 text-center w-8">الرقم</th>
                      <th className="border border-slate-300 px-3 py-1.5 text-start">تعيين الأشغال والمواد</th>
                      <th className="border border-slate-300 px-2 py-1.5 text-center w-14">الوحدة</th>
                      <th className="border border-slate-300 px-2 py-1.5 text-center w-16">الكمية</th>
                      <th className="border border-slate-300 px-2 py-1.5 text-end w-24">السعر الوحدوي</th>
                      <th className="border border-slate-300 px-3 py-1.5 text-end w-28">المبلغ (دج)</th>
                    </tr>
                  </thead>
                  <tbody>
                    {lot.lignes.map((l) => (
                      <tr key={l.id} className="border-b border-slate-200">
                        <td className="border border-slate-300 px-2 py-1 text-center font-mono">
                          {l.numeroLigne}
                        </td>
                        <td className="border border-slate-300 px-3 py-1 font-medium">
                          {l.designation}
                        </td>
                        <td className="border border-slate-300 px-2 py-1 text-center font-mono">
                          {l.unite}
                        </td>
                        <td className="border border-slate-300 px-2 py-1 text-center font-mono font-num">
                          {l.quantite}
                        </td>
                        <td className="border border-slate-300 px-2 py-1 text-end font-mono font-num">
                          {formaterMontantDZD(l.prixUnitaire)}
                        </td>
                        <td className="border border-slate-300 px-3 py-1 text-end font-mono font-num font-bold">
                          {formaterMontantDZD(l.montant)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ))}
          </div>

          {/* Financial Totals Block */}
          <div className="flex justify-end pt-2">
            <div className="w-80 border border-slate-300 rounded-lg overflow-hidden text-xs">
              <div className="flex justify-between p-2 border-b border-slate-200 bg-slate-50">
                <span className="font-semibold text-slate-700">المبلغ الصافي بدون رسوم (HT) :</span>
                <span className="font-bold font-num">{formaterMontantDZD(fiche.montantHT)}</span>
              </div>
              <div className="flex justify-between p-2 border-b border-slate-200 bg-slate-50">
                <span className="font-semibold text-slate-700">
                  رسم القيمة المضافة TVA ({fiche.tauxTVA}%) :
                </span>
                <span className="font-bold font-num text-amber-700">
                  {formaterMontantDZD(fiche.montantTVA)}
                </span>
              </div>
              <div className="flex justify-between p-2.5 bg-slate-200 text-slate-900 font-bold text-sm">
                <span>المبلغ الإجمالي مع كافة الرسوم (TTC) :</span>
                <span className="font-black font-num text-blue-900">
                  {formaterMontantDZD(fiche.montantTTC)}
                </span>
              </div>
            </div>
          </div>

          {/* Amount In Written Words in Arabic */}
          <div className="p-3 bg-slate-50 rounded-lg border border-slate-200 text-xs font-semibold leading-relaxed">
            <span className="font-bold text-slate-800">
              أوقفت هذه البطاقة التقنية عند مبلغ إجمالي قدره بجميع الرسوم :{' '}
            </span>
            <span className="text-blue-900 underline decoration-blue-500 underline-offset-4">
              {convertirNombreEnLettresAR(fiche.montantTTC)}
            </span>
          </div>

          {/* Official Signatures and Stamps Block */}
          <div className="grid grid-cols-3 gap-6 pt-8 text-center text-xs">
            <div className="space-y-16">
              <div className="font-bold text-slate-800">المهندس المشرف على الدراسة</div>
              <div className="text-slate-400 text-[10px] italic">(تأشيرة وتوقيع)</div>
            </div>

            <div className="space-y-16">
              <div className="font-bold text-slate-800">رئيس مصلحة الهياكل والأشغال</div>
              <div className="text-slate-400 text-[10px] italic">(خاتم المصلحة)</div>
            </div>

            <div className="space-y-16">
              <div className="font-bold text-slate-800">الآمر بالصرف والمصادقة</div>
              <div className="text-slate-400 text-[10px] italic">(التوقيع والختم الرسمي)</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

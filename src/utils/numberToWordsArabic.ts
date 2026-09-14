/**
 * Conversion d'un montant numérique en toutes lettres en arabe
 * Adapté fidèlement de uUtils_v3.pas (ConvertirNombreEnLettresAR)
 * Ex: 1250400.50 => "فقط مليون ومائتان وخمسون ألف وأربعمائة دينار جزائري وخمسون سنتيم"
 */

function uniteAR(n: number): string {
  switch (n) {
    case 0: return '';
    case 1: return 'واحد';
    case 2: return 'اثنان';
    case 3: return 'ثلاثة';
    case 4: return 'أربعة';
    case 5: return 'خمسة';
    case 6: return 'ستة';
    case 7: return 'سبعة';
    case 8: return 'ثمانية';
    case 9: return 'تسعة';
    case 10: return 'عشرة';
    case 11: return 'أحد عشر';
    case 12: return 'اثنا عشر';
    case 13: return 'ثلاثة عشر';
    case 14: return 'أربعة عشر';
    case 15: return 'خمسة عشر';
    case 16: return 'ستة عشر';
    case 17: return 'سبعة عشر';
    case 18: return 'ثمانية عشر';
    case 19: return 'تسعة عشر';
    default: return '';
  }
}

function dizaineAR(n: number): string {
  switch (n) {
    case 2: return 'عشرون';
    case 3: return 'ثلاثون';
    case 4: return 'أربعون';
    case 5: return 'خمسون';
    case 6: return 'ستون';
    case 7: return 'سبعون';
    case 8: return 'ثمانون';
    case 9: return 'تسعون';
    default: return '';
  }
}

function centaineAR(n: number): string {
  switch (n) {
    case 1: return 'مائة';
    case 2: return 'مائتان';
    case 3: return 'ثلاثمائة';
    case 4: return 'أربعمائة';
    case 5: return 'خمسمائة';
    case 6: return 'ستمائة';
    case 7: return 'سبعمائة';
    case 8: return 'ثمانمائة';
    case 9: return 'تسعمائة';
    default: return '';
  }
}

function convertirTroisChiffresAR(n: number): string {
  if (n === 0) return '';

  const c = Math.floor(n / 100);
  const remainder = n % 100;
  const d = Math.floor(remainder / 10);
  const u = remainder % 10;

  let res = '';
  if (c > 0) {
    res = centaineAR(c);
  }

  if (remainder > 0) {
    if (res !== '') {
      res += ' و ';
    }

    if (remainder < 20) {
      res += uniteAR(remainder);
    } else {
      if (u > 0) {
        res += uniteAR(u) + ' و ';
      }
      res += dizaineAR(d);
    }
  }

  return res;
}

export function convertirNombreEnLettresAR(montant: number): string {
  if (!montant || isNaN(montant)) return 'صفر دينار جزائري';

  const absVal = Math.abs(montant);
  const entier = Math.floor(absVal);
  const decimale = Math.round((absVal - entier) * 100);

  if (entier === 0) {
    let zeroRes = 'صفر';
    if (decimale > 0) {
      zeroRes += ' و ' + convertirTroisChiffresAR(decimale) + ' سنتيم';
    }
    return zeroRes + ' دينار جزائري';
  }

  const milliards = Math.floor(entier / 1000000000);
  let remM = entier % 1000000000;

  const millions = Math.floor(remM / 1000000);
  let remK = remM % 1000000;

  const milliers = Math.floor(remK / 1000);
  const reste = remK % 1000;

  const parts: string[] = [];

  if (milliards > 0) {
    if (milliards === 1) parts.push('مليار');
    else if (milliards === 2) parts.push('ملياران');
    else parts.push(convertirTroisChiffresAR(milliards) + ' مليارات');
  }

  if (millions > 0) {
    if (millions === 1) parts.push('مليون');
    else if (millions === 2) parts.push('مليونان');
    else if (millions >= 3 && millions <= 10) parts.push(convertirTroisChiffresAR(millions) + ' ملايين');
    else parts.push(convertirTroisChiffresAR(millions) + ' مليون');
  }

  if (milliers > 0) {
    if (milliers === 1) parts.push('ألف');
    else if (milliers === 2) parts.push('ألفان');
    else if (milliers >= 3 && milliers <= 10) parts.push(convertirTroisChiffresAR(milliers) + ' آلاف');
    else parts.push(convertirTroisChiffresAR(milliers) + ' ألف');
  }

  if (reste > 0) {
    parts.push(convertirTroisChiffresAR(reste));
  }

  let result = parts.join(' و ') + ' دينار جزائري';

  if (decimale > 0) {
    result += ' و ' + convertirTroisChiffresAR(decimale) + ' سنتيم';
  }

  return 'فقط ' + result + ' لا غير';
}

export function formaterMontantDZD(val: number): string {
  if (isNaN(val)) return '0.00 دج';
  return (
    new Intl.NumberFormat('fr-FR', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(val) + ' دج'
  );
}

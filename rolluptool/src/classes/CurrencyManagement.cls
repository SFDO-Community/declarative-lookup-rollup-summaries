public with sharing class CurrencyManagement {
    private static Map<Id, Sobject> dcrMap;
    private static String corporateCurrency;

    public static Boolean isCorporateCurrency(String currencyIso) {
        if(corporateCurrency == null) {
			Sobject corporateCurrencyType = Database.query('SELECT IsoCode FROM CurrencyType WHERE IsActive = true AND IsCorporate = true');
			corporateCurrency = (String) corporateCurrencyType.get('IsoCode');
        }
        return currencyIso == corporateCurrency;
    }

    public static Decimal getRates(String currencyIso, Date currencyDate) {
        Decimal res;
        if(currencyIso != null) {
            if (dcrMap == null) {
                dcrMap = new Map<Id, Sobject>(Database.query('SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate'));
            }
            for (Sobject dcr: dcrMap.values()) {
                if((String) dcr.get('IsoCode') != currencyIso)                                         continue;   // look for a match in table against input currency
                if(currencyDate < (Date) dcr.get('StartDate') || currencyDate >= (Date) dcr.get('NextStartDate'))  continue;   // not in the range of effective dates
                res =  (Decimal) dcr.get('ConversionRate');
                break;
            }
        }
        return res;
    }

    public static Decimal convertToCorporateCurrency(String currencyIso, Decimal currencyVal, Date currencyDate) {
        Decimal res;
        if(currencyIso != null && currencyVal != null && !CurrencyManagement.isCorporateCurrency(currencyIso)) {
            if(dcrMap == null) {
                dcrMap = new Map<Id, Sobject>(Database.query('SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate'));
            }
            for(Sobject dcr: dcrMap.values()) {
                if((String) dcr.get('IsoCode') != currencyIso) continue;   // look for a match in table against input currency
                if(currencyDate < (Date) dcr.get('StartDate') || currencyDate >= (Date) dcr.get('NextStartDate')) continue;   // not in the range of effective dates
                res =  currencyVal / (Decimal) dcr.get('ConversionRate');
                break;
            }
        }
        else if(currencyIso != null && CurrencyManagement.isCorporateCurrency(currencyIso)) {
            return currencyVal;
        }
        return res;
    }

    public static Decimal convertFromCorporateCurrency(String currencyIso, Decimal currencyVal, Date currencyDate) {
        Decimal res;
        if(currencyIso != null && currencyVal != null) {
            if (dcrMap == null) {
                dcrMap = new Map<Id, Sobject>(Database.query('SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate'));
            }
            for(Sobject dcr: dcrMap.values()) {
                if((String) dcr.get('IsoCode') != currencyIso) continue;   // look for a match in table against input currency
                if(currencyDate < (Date) dcr.get('StartDate') || currencyDate >= (Date) dcr.get('NextStartDate')) continue;   // not in the range of effective dates
                res =  currencyVal * (Decimal) dcr.get('ConversionRate');
                break;
            }
        }
        return res;
    }
}
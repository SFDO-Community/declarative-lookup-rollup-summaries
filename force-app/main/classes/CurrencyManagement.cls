/**
 * Copyright (c), Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

// Contribution by https://github.com/Kilay via https://github.com/afawcett/declarative-lookup-rollup-summaries/pull/591

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
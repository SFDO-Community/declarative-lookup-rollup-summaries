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

public with sharing class CurrencyManagement {
    private static Map<ID, DatedConversionRate> dcrMap;
    private static String corporateCurrency;

    public static Boolean isCorporateCurrency(String currencyIso) {
        if(corporateCurrency == null) {
            corporateCurrency = [SELECT IsoCode FROM CurrencyType WHERE IsActive = true AND IsCorporate = true].IsoCode;
        }
        return currencyIso == corporateCurrency;
    }

    public static Decimal convertToCorporateCurrency(String currencyIso, Decimal currencyVal, Date currencyDate) {
        Decimal res;
        if(currencyIso != null && currencyVal != null && !CurrencyManagement.isCorporateCurrency(currencyIso)) {
            if(dcrMap == null) {
                dcrMap = new Map<ID,DatedConversionRate> ([SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate]);
            }
            for(DatedConversionRate dcr: dcrMap.values()) {
                if(dcr.isoCode != currencyIso)                                         continue;   // look for a match in table against input currency
                if(currencyDate < dcr.startDate || currencyDate >= dcr.nextStartDate)  continue;   // not in the range of effective dates
                res =  currencyVal / dcr.conversionRate;
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
                dcrMap = new Map<ID,DatedConversionRate> ([SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate]);
            }
            for(DatedConversionRate dcr: dcrMap.values()) {
                if(dcr.isoCode != currencyIso)                                         continue;   // look for a match in table against input currency
                if(currencyDate < dcr.startDate || currencyDate >= dcr.nextStartDate)  continue;   // not in the range of effective dates
                res =  currencyVal * dcr.conversionRate;
                break;
            }
        }
        return res;
    }
}
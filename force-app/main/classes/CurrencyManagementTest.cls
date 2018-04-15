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

@isTest(isParallel=true)
private class CurrencyManagementTest {
    // common master records for the test case
    static Account acc1;
    // common bunch of detail records for the test case
    static Opportunity[] detailRecords;
    static Schema.SObjectField ANNUALIZED_RECCURING_REVENUE;
    static
    {
        // dynamically resolve these fields, if they are not present when the test runs, the test will return as passed to avoid failures in subscriber org when packaged
        Map<String, Schema.SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();
        Map<String, Schema.SObjectField> opportunityFields = Schema.SObjectType.Opportunity.fields.getMap();
        ANNUALIZED_RECCURING_REVENUE = opportunityFields.get('Annualized_Recurring_Revenue__c');
    }
    
    @testSetup static void prepareData() {
        String notCorporateIsoCode = [SELECT IsoCode FROM CurrencyType WHERE IsActive = true AND IsCorporate = false LIMIT 1].IsoCode;
        String corporateIsoCode = [SELECT IsoCode FROM CurrencyType WHERE IsActive = true AND IsCorporate = true LIMIT 1].IsoCode;
        acc1 =  new Account(Name = 'Acc1');
        insert new Account[] {acc1};

        Opportunity o1Acc1 = new Opportunity(
                Name = 'o1Acc1',
                AccountId = acc1.Id,
                Amount = 100.00,
                CloseDate = System.today(),
                StageName = 'test',
                CurrencyIsoCode = corporateIsoCode
        );
        
        Opportunity o2Acc1 = new Opportunity(
                Name = 'o1Acc1',
                AccountId = acc1.Id,
                Amount = 100.00,
                CloseDate = System.today(),
                StageName = 'test',
                CurrencyIsoCode = notCorporateIsoCode
        );

        detailRecords = new Opportunity[] {o1Acc1,o2Acc1};
        if(ANNUALIZED_RECCURING_REVENUE!=null)
            for(Opportunity detailRecord : detailRecords)
                detailRecord.put(ANNUALIZED_RECCURING_REVENUE, 1000);
        insert detailRecords;
    }

    @isTest
    static void testCurrencyManagementFromCorporate() {
        String notCorporateIsoCode = [SELECT IsoCode FROM CurrencyType WHERE IsActive = true AND IsCorporate = false LIMIT 1].IsoCode;
        String corporateIsoCode = [SELECT IsoCode FROM CurrencyType WHERE IsActive = true AND IsCorporate = true LIMIT 1].IsoCode;
        Opportunity o = [SELECT Id, Amount, CloseDate, CurrencyIsoCode FROM Opportunity WHERE CurrencyIsoCode = :corporateIsoCode];
        Test.startTest();

        Decimal notCorporateAmount = CurrencyManagement.convertFromCorporateCurrency(notCorporateIsoCode, o.Amount, o.CloseDate);
        Decimal corporateAmount = CurrencyManagement.convertToCorporateCurrency(notCorporateIsoCode, notCorporateAmount, o.CloseDate);
        System.assertEquals(notCorporateAmount, CurrencyManagement.convertFromCorporateCurrency(notCorporateIsoCode, corporateAmount, o.CloseDate));
        System.assertEquals(corporateAmount, o.Amount);

        Test.StopTest();
    }

    @isTest
    static void testCurrencyManagementToCorporate() {
        String notCorporateIsoCode = [SELECT IsoCode FROM CurrencyType WHERE IsActive = true AND IsCorporate = false LIMIT 1].IsoCode;
        String corporateIsoCode = [SELECT IsoCode FROM CurrencyType WHERE IsActive = true AND IsCorporate = true LIMIT 1].IsoCode;
        Opportunity o = [SELECT Id, Amount, CloseDate, CurrencyIsoCode FROM Opportunity WHERE CurrencyIsoCode = :notCorporateIsoCode];
        Opportunity o2 = [SELECT Id, Amount, CloseDate, CurrencyIsoCode FROM Opportunity WHERE CurrencyIsoCode = :corporateIsoCode];
        Test.startTest();

        Decimal corporateAmount = CurrencyManagement.convertToCorporateCurrency(o2.CurrencyIsoCode, o2.Amount, o2.CloseDate);
        corporateAmount = CurrencyManagement.convertToCorporateCurrency(o.CurrencyIsoCode, o.Amount, o.CloseDate);
        Decimal notCorporateAmount = CurrencyManagement.convertFromCorporateCurrency(notCorporateIsoCode, corporateAmount, o.CloseDate);
        System.assertEquals(corporateAmount.round(), (CurrencyManagement.convertToCorporateCurrency(notCorporateIsoCode, notCorporateAmount, o.CloseDate)).round());
        System.assertEquals(notCorporateAmount.round(), o.Amount);

        Test.StopTest();
    }
}
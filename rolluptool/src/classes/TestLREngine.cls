/*
Copyright (c) tgerm.com
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/**
	This test case uses standard objects Opportunity and Account for the purpose of testing. This is done to avoid
	any dependency on custom objects and keep the code base simple and easy to deploy in new orgs.
	
*/
/**
    Modification by Andrew Fawcett to use dynamic references to custom Account fields, to avoid packaging them
*/
@isTest
private class TestLREngine {
		// common master records for the test case
		static Account acc1, acc2;
		// common bunch of detail records for the test case
		static Opportunity[] detailRecords;
		// dynamic reference to this field to avoid it being included in the package
		static Schema.SObjectField ACCOUNT_SLA_EXPIRATION_DATE;
		static Schema.SObjectField ACCOUNT_NUMBER_OF_LOCATIONS;		
		static
		{
			// dynamically resolve these fields, if they are not present when the test runs, the test will return as passed to avoid failures in subscriber org when packaged
			Map<String, Schema.SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();
			ACCOUNT_SLA_EXPIRATION_DATE = accountFields.get('SLAExpirationDate__c');
			ACCOUNT_NUMBER_OF_LOCATIONS = accountFields.get('NumberOfLocations__c');
		}
		
		/*
		 creates the common seed data using Opportunity and Account objects. 
		 */
		static void prepareData() {
			 acc1 =  new Account(Name = 'Acc1');
	         acc2 =  new Account(Name = 'Acc2');
	         insert new Account[] {acc1, acc2};
	           
	         Opportunity o1Acc1 = new Opportunity( 
	 												Name = 'o1Acc1', 
	                                                AccountId = acc1.Id,
	                                                Amount = 100.00,
	                                                CloseDate = System.today(),
	                                                StageName = 'test'
	         									);
	         Opportunity o2Acc1 = new Opportunity(
	 												Name = 'o2Acc1',
	                                                AccountId = acc1.Id,
	                                                Amount = 300.00,
	                                                CloseDate = System.today().addMonths(1),
	                                                StageName = 'test'
	         									);
	
	         Opportunity o3Acc1 = new Opportunity(
	 												Name = 'o3Acc1',
	                                                AccountId = acc1.Id,
	                                                Amount = 50.00,
	                                                CloseDate = System.today().addMonths(-1),
	                                                StageName = 'test'
	         									);
	
	         Opportunity o1Acc2 = new Opportunity(
	 												Name = 'o1Acc2',
	                                                AccountId = acc2.Id,
	                                                Amount = 200.00,
	                                                CloseDate = System.today().addMonths(2),
	                                                StageName = 'test'
	         									);
	         
	         Opportunity o2Acc2 = new Opportunity(
	 												Name = 'o2Acc2',
	                                                AccountId = acc2.Id,
	                                                Amount = 400.00,
	                                                CloseDate = System.today().addMonths(3),
	                                                StageName = 'test'
	         									);
	
	         Opportunity o3Acc2 = new Opportunity(
	 												Name = 'o3Acc2',
	                                                AccountId = acc2.Id,
	                                                Amount = 300.00,
	                                                CloseDate = System.today().addMonths(4),
	                                                StageName = 'test'
	         									);
	         detailRecords = new Opportunity[] {o1Acc1, o2Acc1, o3Acc1, o1Acc2, o2Acc2, o3Acc2};
	         insert detailRecords;			
		}		

	
	/*
		Tests sum and max operations on currency and date fields
	*/
    static testMethod void testSumAndMaxOperations() {
    	    	
		// Test supported?
		if(!TestContext.isSupported())
			return;
    	
    	// create seed data 
         prepareData();
         
         LREngine.Context ctx = new LREngine.Context(Account.SobjectType,  
                                                Opportunity.SobjectType, 
                                                Schema.SObjectType.Opportunity.fields.AccountId);
         
         //Select o.TotalOpportunityQuantity, o.ExpectedRevenue, o.CloseDate, o.Account.rollups__SLAExpirationDate__c, 
         // o.Account.rollups__NumberofLocations__c, o.AccountId From Opportunity o
         ctx.add(
                new LREngine.RollupSummaryField(
	                                            Schema.SObjectType.Account.fields.AnnualRevenue,
	                                            Schema.SObjectType.Opportunity.fields.Amount,
	                                            LREngine.RollupOperation.Sum
                                             )); 
         ctx.add(
         		new LREngine.RollupSummaryField(
	                                            ACCOUNT_SLA_EXPIRATION_DATE.getDescribe(),
	                                            Schema.SObjectType.Opportunity.fields.CloseDate,
	                                            LREngine.RollupOperation.Max
                                             ));                                       
                
         Sobject[] masters = LREngine.rollUp(ctx, detailRecords);                 
         // 2 masters should be back  
         System.assertEquals(2, masters.size());
         
         System.debug(masters + ' '  + acc1 + ' '  + acc2);
         Account reloadedAcc1, reloadedAcc2;         
         for (Sobject so : masters) { 
            if (so.Id == acc1.id) reloadedAcc1 = (Account)so;
            if (so.Id == acc2.id) reloadedAcc2 = (Account)so;
         }
         System.assertEquals(450.00, reloadedAcc1.AnnualRevenue);
         System.assertEquals(900.00, reloadedAcc2.AnnualRevenue);
         
         System.assertEquals(System.today().addMonths(1), reloadedAcc1.get(ACCOUNT_SLA_EXPIRATION_DATE));
         System.assertEquals(System.today().addMonths(4), reloadedAcc2.get(ACCOUNT_SLA_EXPIRATION_DATE));
         
    }
    
    
    /*
		Tests sum and max operations on currency and date fields
	*/
    static testMethod void testAvgAndCountOperations() {
    	
		// Test supported?
		if(!TestContext.isSupported())
			return;
    	
    	// create seed data 
         prepareData();
         
         LREngine.Context ctx = new LREngine.Context(Account.SobjectType, 
                                                Opportunity.SobjectType, 
                                                Schema.SObjectType.Opportunity.fields.AccountId);
         
         //Select o.TotalOpportunityQuantity, o.ExpectedRevenue, o.CloseDate, o.Account.rollups__SLAExpirationDate__c, 
         // o.Account.rollups__NumberofLocations__c, o.AccountId From Opportunity o
         ctx.add(
                new LREngine.RollupSummaryField(
	                                            Schema.SObjectType.Account.fields.AnnualRevenue,
	                                            Schema.SObjectType.Opportunity.fields.Amount,
	                                            LREngine.RollupOperation.Avg
                                             )); 
         ctx.add(
         		new LREngine.RollupSummaryField(
	                                            ACCOUNT_NUMBER_OF_LOCATIONS.getDescribe(),
	                                            Schema.SObjectType.Opportunity.fields.CloseDate,
	                                            LREngine.RollupOperation.Count
                                             ));                                       
                
         Sobject[] masters = LREngine.rollUp(ctx, detailRecords);                 
         // 2 masters should be back  
         System.assertEquals(2, masters.size());
         
         System.debug(masters + ' '  + acc1 + ' '  + acc2);
         Account reloadedAcc1, reloadedAcc2;         
         for (Sobject so : masters) { 
            if (so.Id == acc1.id) reloadedAcc1 = (Account)so;
            if (so.Id == acc2.id) reloadedAcc2 = (Account)so;
         }
         // avg would be (50 + 100 + 300) / 3 = 150
         System.assertEquals(150.00, reloadedAcc1.AnnualRevenue);
         System.assertEquals(300.00, reloadedAcc2.AnnualRevenue);
         
         System.assertEquals(3, reloadedAcc1.get(ACCOUNT_NUMBER_OF_LOCATIONS));
         System.assertEquals(3, reloadedAcc2.get(ACCOUNT_NUMBER_OF_LOCATIONS));
    }
    
    
    
    /*
		Tests sum and max operations on currency and date fields
		Here we will pass our custom criteria to filter certain records in detail, just like master detail rollup fields
	*/
    static testMethod void testAvgAndCountOperationsWithFilter() {
    	
		// Test supported?
		if(!TestContext.isSupported())
			return;
    		
    	// create seed data 
         prepareData();
         
         LREngine.Context ctx = new LREngine.Context(Account.SobjectType, 
                                                Opportunity.SobjectType, 
                                                Schema.SObjectType.Opportunity.fields.AccountId,
                                                'Amount > 200' // filter out any opps with amount less than 200
                                                );
         
         //Select o.TotalOpportunityQuantity, o.ExpectedRevenue, o.CloseDate, o.Account.rollups__SLAExpirationDate__c, 
         // o.Account.rollups__NumberofLocations__c, o.AccountId From Opportunity o
         ctx.add(
                new LREngine.RollupSummaryField(
	                                            Schema.SObjectType.Account.fields.AnnualRevenue,
	                                            Schema.SObjectType.Opportunity.fields.Amount,
	                                            LREngine.RollupOperation.Avg
                                             )); 
         ctx.add(
         		new LREngine.RollupSummaryField(
	                                            ACCOUNT_NUMBER_OF_LOCATIONS.getDescribe(),
	                                            Schema.SObjectType.Opportunity.fields.CloseDate,
	                                            LREngine.RollupOperation.Count
                                             ));                                       
                
         Sobject[] masters = LREngine.rollUp(ctx, detailRecords);                 
         // 2 masters should be back  
         System.assertEquals(2, masters.size());
         
         System.debug(masters + ' '  + acc1 + ' '  + acc2);
         Account reloadedAcc1, reloadedAcc2;         
         for (Sobject so : masters) { 
            if (so.Id == acc1.id) reloadedAcc1 = (Account)so;
            if (so.Id == acc2.id) reloadedAcc2 = (Account)so;
         }
         // avg would be 300 as other two records of amount 50 and 100 should be skipped
         System.assertEquals(300, reloadedAcc1.AnnualRevenue);
         System.assertEquals(350.00, reloadedAcc2.AnnualRevenue);
         
         System.assertEquals(1, reloadedAcc1.get(ACCOUNT_NUMBER_OF_LOCATIONS));
         System.assertEquals(2, reloadedAcc2.get(ACCOUNT_NUMBER_OF_LOCATIONS));
    }
}
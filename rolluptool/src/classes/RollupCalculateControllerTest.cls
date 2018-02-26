/**
 * Copyright (c) 2018, Andrew Fawcett
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

@IsTest
private class RollupCalculateControllerTest {

	static Schema.SObjectField ACCOUNT_SLA_EXPIRATION_DATE;
	static Schema.SObjectField ACCOUNT_NUMBER_OF_LOCATIONS;		
	static
	{
		// Dynamically resolve these fields, if they are not present when the test runs, the test will return as passed to avoid failures in subscriber org when packaged
		fflib_SObjectDescribe describe = fflib_SObjectDescribe.getDescribe(Account.SObjectType);
		ACCOUNT_SLA_EXPIRATION_DATE = describe.getField('SLAExpirationDate__c');
		ACCOUNT_NUMBER_OF_LOCATIONS = describe.getField('NumberOfLocations__c');
	}
	
	@IsTest
	private static void testMasterUpdatesSkipped() {
		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 250, 250, 50, 50 };
					
		// Test data for rollup A
		Decimal expectedResultA = 600;
		RollupSummaries.AggregateOperation operationA = RollupSummaries.AggregateOperation.Sum; 
		
		// Configure rollup A
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryA.ParentObject__c = 'Account';
		rollupSummaryA.ChildObject__c = 'Opportunity';
		rollupSummaryA.RelationShipField__c = 'AccountId';
		rollupSummaryA.FieldToAggregate__c = 'Amount';
		rollupSummaryA.AggregateOperation__c = operationA.name();
		rollupSummaryA.AggregateResultField__c = 'AnnualRevenue';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = 'Process Builder';

		// Insert rollup definitions
		insert new List<LookupRollupSummary__c> { rollupSummaryA };
		
		// Test data
		Account account1 = new Account();
		account1.Name = 'Test Account 1';
		Account account2 = new Account();
		account2.Name = 'Test Account 2';
		List<Account> accounts = new List<Account> { account1, account2 };
		insert accounts;
		List<Opportunity> opps = new List<Opportunity>(); 
		for(Decimal rollupValue : rollups)
		{
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account1.Id;
			opp.Amount = rollupValue;
			opps.add(opp);			
		}
		insert opps;
		
		// Assert rollups are null
		Id accountId = account1.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(null, accountResult.AnnualRevenue);

		// Run a full calculate for the given master records (used by the Full Recalc mode)
		RollupService.updateMasterRollups(new Set<String> { rollupSummaryA.Id }, new Set<Id> { account1.Id, account2.Id });
		
		// Assert rollups are calculated
		accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);
		
		// Capture query and dml rows used up so far
		Integer queryRows = Limits.getQueryRows();
		Integer dmlRows = Limits.getDmlRows();

		// Run a full calculate for the given master records (used by the Full Recalc mode)
		RollupService.updateMasterRollups(new Set<String> { rollupSummaryA.Id }, new Set<Id> { account1.Id, account2.Id });
		
		// Assert what has been done DML and Query rows wise
		System.assertEquals(
			/* Expected no further DML rows to be updated*/ 0,
			Limits.getDmlRows() - dmlRows);
		System.assertEquals(  
			/* Expected following additional query rows */
			/* Lookup row **/ + 1 
			/* Rollup query rows (children) **/ + rollups.size() 
			/* Master query rows (parents) */ + accounts.size(),
			Limits.getQueryRows() - queryRows);					
		
		// Assert rollups are still ok
		accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);
		
		// Modify child record and thus expected rollup value (which will now be different from the one on the db)
		expectedResultA = 550;
		opps[0].Amount = 200;
		update opps[0];		

		// Capture query and dml rows used up so far
		queryRows = Limits.getQueryRows();
		dmlRows = Limits.getDmlRows();

		// Run the Calculate job (inlined as Limits stats are not available for Apex jobs run in tests)
		RollupService.updateMasterRollups(new Set<String> { rollupSummaryA.Id }, new Set<Id> { account1.Id, account2.Id });
		
		// Assert what has been done DML and Query rows wise
		System.assertEquals(
			/* Expected one DML row to be updated*/ 1,
			Limits.getDmlRows() - dmlRows);
		System.assertEquals(  
			/* Expected following additional query rows */
			/* Lookup row **/ + 1 
			/* Rollup query rows (children) **/ + rollups.size() 
			/* Master query rows (parents) */ + accounts.size(),
			Limits.getQueryRows() - queryRows);					
		
		// Assert rollups are still ok
		accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);
	}
	
	@IsTest
	private static void testJobRecordCleanedUp() {

        // Test supported?
        if(!TestContext.isSupported())
            return;

		// Between Task and Account
		LookupRollupSummary__c rollupSummaryAccount = new LookupRollupSummary__c();
		rollupSummaryAccount.Name = 'Test Rollup';
		rollupSummaryAccount.ParentObject__c = 'Account';
		rollupSummaryAccount.ChildObject__c = 'Task';
		rollupSummaryAccount.RelationShipField__c = 'WhatId';
		rollupSummaryAccount.FieldToAggregate__c = 'Id';
		rollupSummaryAccount.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
		rollupSummaryAccount.AggregateResultField__c = 'AnnualRevenue';
		rollupSummaryAccount.Active__c = false;
		rollupSummaryAccount.CalculationMode__c = 'Realtime';
		insert rollupSummaryAccount;

		// Test default behaviour
		Test.startTest();
		ApexPages.StandardController standardController = 
			new ApexPages.StandardController(rollupSummaryAccount);
		RollupCalculateController controller = 
			new RollupCalculateController(standardController);
		controller.runCalculateJob();
		Test.stopTest();
		
		// Tried to run 
		System.assertEquals(0, Database.countQuery('select Count() from LookupRollupCalculateJob__c'));
	}
	
	/**
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/619
	 **/
	@IsTest
	private static void testUserRollup() {

        // Test supported?
        if(!TestContext.isSupported())
            return;

		// Between Task and Account
		LookupRollupSummary__c rollupSummaryAccount = new LookupRollupSummary__c();
		rollupSummaryAccount.Name = 'Test Rollup';
		rollupSummaryAccount.ParentObject__c = 'User';
		rollupSummaryAccount.ChildObject__c = 'Account';
		rollupSummaryAccount.RelationShipField__c = 'OwnerId';
		rollupSummaryAccount.FieldToAggregate__c = 'Name';
		rollupSummaryAccount.AggregateOperation__c = RollupSummaries.AggregateOperation.Last.name();
		rollupSummaryAccount.AggregateResultField__c = 'EmployeeNumber';
		rollupSummaryAccount.Active__c = true;
		rollupSummaryAccount.CalculationMode__c = 'Process Builder';
		insert rollupSummaryAccount;

		// Test default behaviour
		Test.startTest();
		ApexPages.StandardController standardController = 
			new ApexPages.StandardController(rollupSummaryAccount);
		RollupCalculateController controller = 
			new RollupCalculateController(standardController);
		controller.runCalculateJob();
		Test.stopTest();
		
		// Tried to run 
		System.assertEquals(0, Database.countQuery('select Count() from LookupRollupCalculateJob__c'));
	}	    
}
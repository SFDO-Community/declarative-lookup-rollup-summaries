/**
 * Copyright (c) 2013, Andrew Fawcett
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

/**
 * Tests the RollupService methods, note the LREngine is test independently via TestLREngine
 **/
@IsTest
private with sharing class RollupServiceTest2 
{		
	static Schema.SObjectField ACCOUNT_SLA_EXPIRATION_DATE;
	static Schema.SObjectField ACCOUNT_NUMBER_OF_LOCATIONS;		
    static
    {
        // Dynamically resolve these fields, if they are not present when the test runs, the test will return as passed to avoid failures in subscriber org when packaged
        fflib_SObjectDescribe describe = fflib_SObjectDescribe.getDescribe(Account.SObjectType);
        ACCOUNT_SLA_EXPIRATION_DATE = describe.getField('SLAExpirationDate__c');
        ACCOUNT_NUMBER_OF_LOCATIONS = describe.getField('NumberOfLocations__c');
    }
	
	private testmethod static void testMultiRollupBothScheduledWithConditions()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 250, 250, 50, 50 };
					
		// Test data for rollup A
		Decimal expectedResultA = 500;
		RollupSummaries.AggregateOperation operationA = RollupSummaries.AggregateOperation.Sum; 
		String conditionA = 'Amount > 200';

		// Test data for rollup B
		Decimal expectedResultB = 2;
		RollupSummaries.AggregateOperation operationB = RollupSummaries.AggregateOperation.Count; 
		String conditionB = 'Amount < 200';
		
		// Configure rollup A
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryA.ParentObject__c = 'Account';
		rollupSummaryA.ChildObject__c = 'Opportunity';
		rollupSummaryA.RelationShipField__c = 'AccountId';
		rollupSummaryA.RelationShipCriteria__c = conditionA;
		rollupSummaryA.FieldToAggregate__c = 'Amount';
		rollupSummaryA.AggregateOperation__c = operationA.name();
		rollupSummaryA.AggregateResultField__c = 'AnnualRevenue';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = 'Scheduled';

		// Configure rollup B
		LookupRollupSummary__c rollupSummaryB = new LookupRollupSummary__c();
		rollupSummaryB.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryB.ParentObject__c = 'Account';
		rollupSummaryB.ChildObject__c = 'Opportunity';
		rollupSummaryB.RelationShipField__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria__c = conditionB;
		rollupSummaryB.FieldToAggregate__c = 'CloseDate';
		rollupSummaryB.AggregateOperation__c = operationB.name();
		rollupSummaryB.AggregateResultField__c = 'NumberOfLocations__c';
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = 'Scheduled';

		// Insert rollup definitions
		insert new List<LookupRollupSummary__c> { rollupSummaryA, rollupSummaryB };
				
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		insert account;
		List<Opportunity> opps = new List<Opportunity>(); 
		for(Decimal rollupValue : rollups)
		{
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = rollupValue;
			opps.add(opp);			
		}
		insert opps;
		
		// Assert rollup
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(null, accountResult.AnnualRevenue);	// This is a scheduled rollup so no realtime update
		System.assertEquals(null, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS)); // This is a scheduled rollup so no realtime update
		System.assertEquals(2, [select Id from LookupRollupSummaryScheduleItems__c where ParentId__c = :account.Id].size()); // Assert a scheduled item has been created
		
		// Run rollup job
		Test.startTest();		
		RollupService.runJobToProcessScheduledItems(); 
		Test.stopTest();
		
		// Assert schedule items gone and rollup updated
		accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);			
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS));			
		System.assertEquals(0, [select Id from LookupRollupSummaryScheduleItems__c where ParentId__c = :account.Id].size());
	}

	private testmethod static void testMultiRollupOneScheduled()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 250, 250, 50, 50 };
					
		// Test data for rollup A
		Decimal expectedResultA = 500;
		RollupSummaries.AggregateOperation operationA = RollupSummaries.AggregateOperation.Sum; 
		String conditionA = 'Amount > 200';

		// Test data for rollup B
		Decimal expectedResultB = 4;
		RollupSummaries.AggregateOperation operationB = RollupSummaries.AggregateOperation.Count; 
		String conditionB = null;
		
		// Configure rollup A
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryA.ParentObject__c = 'Account';
		rollupSummaryA.ChildObject__c = 'Opportunity';
		rollupSummaryA.RelationShipField__c = 'AccountId';
		rollupSummaryA.RelationShipCriteria__c = conditionA;
		rollupSummaryA.FieldToAggregate__c = 'Amount';
		rollupSummaryA.AggregateOperation__c = operationA.name();
		rollupSummaryA.AggregateResultField__c = 'AnnualRevenue';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = 'Realtime';

		// Configure rollup B
		LookupRollupSummary__c rollupSummaryB = new LookupRollupSummary__c();
		rollupSummaryB.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryB.ParentObject__c = 'Account';
		rollupSummaryB.ChildObject__c = 'Opportunity';
		rollupSummaryB.RelationShipField__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria__c = conditionB;
		rollupSummaryB.FieldToAggregate__c = 'CloseDate';
		rollupSummaryB.AggregateOperation__c = operationB.name();
		rollupSummaryB.AggregateResultField__c = 'NumberOfLocations__c';
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = 'Scheduled';

		// Insert rollup definitions
		insert new List<LookupRollupSummary__c> { rollupSummaryA, rollupSummaryB };
				
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		List<Opportunity> opps = new List<Opportunity>(); 
		for(Decimal rollupValue : rollups)
		{
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = rollupValue;
			opps.add(opp);			
		}
		insert opps;
		
		// Assert rollup
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);			
		System.assertEquals(null, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS)); // This is a scheduled rollup so no realtime update
		System.assertEquals(1, [select Id from LookupRollupSummaryScheduleItems__c where ParentId__c = :account.Id].size()); // Assert a scheduled item has been created
		
		// Run rollup job
		Test.startTest();		
		RollupService.runJobToProcessScheduledItems(); 
		Test.stopTest();
		
		// Assert schedule items gone and rollup updated
		System.assertEquals(0, [select Id from LookupRollupSummaryScheduleItems__c where ParentId__c = :account.Id].size());
		accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS));			
	}

	private testmethod static void testScheduleItemsAndLogs()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField = LookupChild__c.Amount__c.getDescribe().getName();
		String aggregateResultField = LookupParent__c.Total__c.getDescribe().getName();

		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject__c = parentObjectName;
		rollupSummary.ChildObject__c = childObjectName;
		rollupSummary.RelationShipField__c = relationshipField;
		rollupSummary.FieldToAggregate__c = aggregateField;
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
		rollupSummary.AggregateResultField__c = aggregateResultField;
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Scheduled';
		insert rollupSummary;

		// Insert parents
		SObject parentA = parentType.newSObject();
		parentA.put('Name', 'ParentA');
		SObject parentB = parentType.newSObject();
		parentB.put('Name', 'ParentB');
		SObject parentC = parentType.newSObject();
		parentC.put('Name', 'ParentC');
		List<SObject> parents = new List<SObject> { parentA, parentB, parentC };
		insert parents;

		// Insert children
		List<SObject> children = new List<SObject>();
		for(SObject parent : parents)
		{
			String name = (String) parent.get('Name');
			SObject child1 = childType.newSObject();
			child1.put(relationshipField, parent.Id);
			child1.put(aggregateField, 20);
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField, 20);
			children.add(child2);
			if(name.equals('ParentA') || name.equals('ParentB'))
			{
				SObject child3 = childType.newSObject();
				child3.put(relationshipField, parent.Id);
				child3.put(aggregateField, 2);
				children.add(child3);
			}
		}
		insert children;

		// Assert scheduled items and log records
		System.assertEquals(3, [select id from LookupRollupSummaryScheduleItems__c].size());
		System.assertEquals(0, [select id from LookupRollupSummaryLog__c].size());

		// Run rollup job
		Test.startTest();
		RollupService.runJobToProcessScheduledItems();
		try {
			// Assert not able to run more than one scheduled job at a time
			RollupService.runJobToProcessScheduledItems();
			System.assert(false, 'Expected exception');
		} catch(Exception e) {
			System.assertEquals('A previous Declarative Rollup Summary scheduled job \'RollupJob\' is still running, this scheduled execution will not occur.', e.getMessage());
		}
		Test.stopTest();
		// Assert the selector now reports the job is no longer running
		System.assertEquals(false, new AsyncApexJobsSelector().jobsExecuting(new Set<String> { 'RollupJob' }));

		// Assert scheduled items and log records
		List<LookupRollupSummaryLog__c> logs = [select id, ParentId__c, ParentObject__c, ErrorMessage__c from LookupRollupSummaryLog__c];
		System.assertEquals(parentC.Id, logs[0].ParentId__c);
		System.assertEquals(parentObjectName, logs[0].ParentObject__c);
		System.assertEquals(1, logs.size());
		System.assertEquals('The answer is not 42! : FIELD_CUSTOM_VALIDATION_EXCEPTION (' + aggregateResultField + ')', logs[0].ErrorMessage__c);
		System.assertEquals(1, [select id from LookupRollupSummaryScheduleItems__c].size());
	}

	private testmethod static void testScheduleItemsAndLogsCleanup()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField = LookupChild__c.Amount__c.getDescribe().getName();
		String aggregateResultField = LookupParent__c.Total__c.getDescribe().getName();
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject__c = parentObjectName;
		rollupSummary.ChildObject__c = childObjectName;
		rollupSummary.RelationShipField__c = relationshipField;
		rollupSummary.FieldToAggregate__c = aggregateField;
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
		rollupSummary.AggregateResultField__c = aggregateResultField;
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Scheduled';	
		insert rollupSummary;
		
		// Insert parents
		SObject parentA = parentType.newSObject();
		parentA.put('Name', 'ParentA');
		SObject parentB = parentType.newSObject();
		parentB.put('Name', 'ParentB');
		SObject parentC = parentType.newSObject();
		parentC.put('Name', 'ParentC');
		List<SObject> parents = new List<SObject> { parentA, parentB, parentC };
		insert parents;
		
		// Insert children
		List<SObject> children = new List<SObject>();
		for(SObject parent : parents)		
		{
			String name = (String) parent.get('Name');
			SObject child1 = childType.newSObject();
			child1.put(relationshipField, parent.Id);
			child1.put(aggregateField, 20);
			children.add(child1);				
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField, 20);
			children.add(child2);				
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put(aggregateField, 2);
			children.add(child3);				
		}
		insert children;
		
		// Assert scheduled items and log records
		System.assertEquals(3, [select id from LookupRollupSummaryScheduleItems__c].size());
		System.assertEquals(0, [select id from LookupRollupSummaryLog__c].size());
		
		// Insert dummy log record for Parent C (emulate position left from above test)
		insert new LookupRollupSummaryLog__c(
				ParentId__c = parentC.id,
				ParentObject__c = parentObjectName,
				ErrorMessage__c = 'The answer is not 42! : FIELD_CUSTOM_VALIDATION_EXCEPTION (' + aggregateResultField + ')'
			);
		
		// Run rollup job
		Test.startTest();		
		RollupService.runJobToProcessScheduledItems(); 
		Test.stopTest();
		
		// Assert scheduled items and log records are all gone!
		System.assertEquals(0, [select id, ParentId__c, ErrorMessage__c from LookupRollupSummaryLog__c].size());		
		System.assertEquals(0, [select id from LookupRollupSummaryScheduleItems__c].size());
	}

	private testmethod static void testScheduleItemsAndLogsCleanupDeletedParent()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField = LookupChild__c.Amount__c.getDescribe().getName();
		String aggregateResultField = LookupParent__c.Total__c.getDescribe().getName();
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject__c = parentObjectName;
		rollupSummary.ChildObject__c = childObjectName;
		rollupSummary.RelationShipField__c = relationshipField;
		rollupSummary.FieldToAggregate__c = aggregateField;
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
		rollupSummary.AggregateResultField__c = aggregateResultField;
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Scheduled';	
		insert rollupSummary;
		
		// Insert parents
		SObject parentA = parentType.newSObject();
		parentA.put('Name', 'ParentA');
		SObject parentB = parentType.newSObject();
		parentB.put('Name', 'ParentB');
		SObject parentC = parentType.newSObject();
		parentC.put('Name', 'ParentC');
		List<SObject> parents = new List<SObject> { parentA, parentB, parentC };
		insert parents;
		
		// Insert children
		List<SObject> children = new List<SObject>();
		for(SObject parent : parents)		
		{
			String name = (String) parent.get('Name');
			SObject child1 = childType.newSObject();
			child1.put(relationshipField, parent.Id);
			child1.put(aggregateField, 20);
			children.add(child1);				
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField, 20);
			children.add(child2);				
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put(aggregateField, 2);
			children.add(child3);				
		}
		insert children;
		
		// Assert scheduled items and log records
		System.assertEquals(3, [select id from LookupRollupSummaryScheduleItems__c].size());
		System.assertEquals(0, [select id from LookupRollupSummaryLog__c].size());

		// Delete a parent record (leaving log entries still to be processed)
		delete parentA;
		
		// Run rollup job (schedule item row should be cleaned up for deleted parent record)
		Test.startTest();		
		RollupService.runJobToProcessScheduledItems(); 
		Test.stopTest();
		
		// Assert scheduled items and log records are all gone!
		System.assertEquals(0, [select id, ParentId__c, ErrorMessage__c from LookupRollupSummaryLog__c].size());		
		System.assertEquals(0, [select id from LookupRollupSummaryScheduleItems__c].size());
	}	

	/**
	 * Test to reproduce issue raised here, https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/11 
	 **/
	private testmethod static void testChangeInCriteriaReferencedField()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 250, 250, 50, 50 };
					
		// Test data for rollup A
		RollupSummaries.AggregateOperation operationA = RollupSummaries.AggregateOperation.Sum; 
		String conditionA = 'StageName = \'Won\'';
		
		// Configure rollup A
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryA.ParentObject__c = 'Account';
		rollupSummaryA.ChildObject__c = 'Opportunity';
		rollupSummaryA.RelationShipField__c = 'AccountId';
		rollupSummaryA.RelationShipCriteria__c = conditionA;
		rollupSummaryA.RelationShipCriteriaFields__c = 'StageName';
		rollupSummaryA.FieldToAggregate__c = 'Amount';
		rollupSummaryA.AggregateOperation__c = operationA.name();
		rollupSummaryA.AggregateResultField__c = 'AnnualRevenue';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = 'Realtime';

		// Insert rollup definitions
		insert new List<LookupRollupSummary__c> { rollupSummaryA };
		
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		List<Opportunity> opps = new List<Opportunity>();
		for(Integer oppIdx = 0; oppIdx<4; oppIdx++) 
		{
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = oppIdx < 2 ? 'Won' : 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = rollups[oppIdx];
			opps.add(opp);			
		}
		insert opps;
		
		// Assert rollup
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(500, accountResult.AnnualRevenue);
		
		// Update the last Opportunity Amount greater than 200 and check rollup amount
		opps[3].StageName = 'Won';
		update opps[3];
		
		// Assert rollup
		accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(550, accountResult.AnnualRevenue);		
	}
	
	// TODO: Do another test like above but with multiple criteria fields
	// ...		
	
	/**
	 * Test to reproduce issue raised here, https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/10 
	 **/
	private testmethod static void testChangeInRelationship()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		List<Integer> rollups = new List<Integer> { 250, 250, 50, 50 };
		
		// Configure rollup A
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryA.ParentObject__c = 'Account';
		rollupSummaryA.ChildObject__c = 'Account';
		rollupSummaryA.RelationShipField__c = 'ParentId';
		rollupSummaryA.RelationShipCriteria__c = null;
		rollupSummaryA.FieldToAggregate__c = 'NumberOfEmployees';
		rollupSummaryA.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
		rollupSummaryA.AggregateResultField__c = 'NumberofLocations__c';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = 'Realtime';

		// Insert rollup definitions
		insert new List<LookupRollupSummary__c> { rollupSummaryA };
		
		// Test data
		Account parentAccount1 = new Account();
		parentAccount1.Name = 'Parent Account 1';
		Account parentAccount2 = new Account();
		parentAccount2.Name = 'Parent Account 2';
		List<Account> parentAccounts = new List<Account> { parentAccount1, parentAccount2 };
		insert parentAccounts;		
		List<Account> childAccounts = new List<Account>();
		for(Integer accIdx = 0; accIdx<4; accIdx++) 
		{
			Account childAccount = new Account();
			childAccount.Name = 'Child Account';
			childAccount.NumberOfEmployees = rollups[accIdx];
			childAccount.ParentId = accIdx < 2 ? parentAccount1.Id : parentAccount2.Id; 
			childAccounts.add(childAccount);			
		}
		insert childAccounts;
		
		// Assert rollups
		Set<Id> parentIds = new Set<Id> { parentAccount1.Id, parentAccount2.Id };
		Map<Id, Account> accountResults = new Map<Id, Account>((List<Account>)Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id in :parentIds'));
		System.assertEquals(500, (Decimal) accountResults.get(parentAccount1.Id).get(ACCOUNT_NUMBER_OF_LOCATIONS));
		System.assertEquals(100, (Decimal) accountResults.get(parentAccount2.Id).get(ACCOUNT_NUMBER_OF_LOCATIONS));
		
		// Reparent a child and check the rollup
		childAccounts[0].ParentId = parentAccount2.Id;
		update childAccounts[0];
		
		// Assert rollups
		accountResults = new Map<Id, Account>((List<Account>)Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id in :parentIds'));
		System.assertEquals(250, (Decimal) accountResults.get(parentAccount1.Id).get(ACCOUNT_NUMBER_OF_LOCATIONS));
		System.assertEquals(350, (Decimal) accountResults.get(parentAccount2.Id).get(ACCOUNT_NUMBER_OF_LOCATIONS));
	}
		
	private testmethod static void testUnDeleteRealtime()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 250, 250, 50, 50 };
					
		// Test data for rollup A
		RollupSummaries.AggregateOperation operationA = RollupSummaries.AggregateOperation.Sum; 
		String conditionA = 'Amount > 200';
		
		// Configure rollup A
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryA.ParentObject__c = 'Account';
		rollupSummaryA.ChildObject__c = 'Opportunity';
		rollupSummaryA.RelationShipField__c = 'AccountId';
		rollupSummaryA.RelationShipCriteria__c = conditionA;
		rollupSummaryA.FieldToAggregate__c = 'Amount';
		rollupSummaryA.AggregateOperation__c = operationA.name();
		rollupSummaryA.AggregateResultField__c = 'AnnualRevenue';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = 'Realtime';

		// Insert rollup definitions
		insert new List<LookupRollupSummary__c> { rollupSummaryA };
		
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		List<Opportunity> opps = new List<Opportunity>(); 
		for(Decimal rollupValue : rollups)
		{
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = rollupValue;
			opps.add(opp);			
		}
		insert opps;
		
		// Assert rollup
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(500, accountResult.AnnualRevenue);
		
		// Delete a child
		delete opps[0];
		accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(250, accountResult.AnnualRevenue);
		
		// Undelete a child
		Database.undelete(opps[0].Id);			
		accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(500, accountResult.AnnualRevenue);
	}			
}
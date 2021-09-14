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

@IsTest
private class RollupServiceTest6 {

    /**
     * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/326
     **/
    @IsTest  
    private static void testAccountHierarchySumNumberOfEmployees() {

        // Test supported?
        if(!TestContext.isSupported())
            return;

        LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
        rollupSummaryA.Name = 'Test Rollup';
        rollupSummaryA.ParentObject__c = 'Account';
        rollupSummaryA.ChildObject__c = 'Account';
        rollupSummaryA.RelationShipField__c = 'ParentId';
        rollupSummaryA.FieldToAggregate__c = 'NumberOfEmployees';
        rollupSummaryA.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
        rollupSummaryA.AggregateResultField__c = 'NumberOfEmployees';
        rollupSummaryA.Active__c = true;
        rollupSummaryA.CalculationMode__c = 'Realtime';
        insert rollupSummaryA;

        // Setup parent test records
        Account accountParent = new Account();
        accountParent.Name = 'Test Opportunity';
        insert accountParent;
        Account accountChild = new Account();
        accountChild.Name = 'Test Opportunity';
        accountChild.NumberOfEmployees = 1;
        accountChild.ParentId = accountParent.Id;
        insert accountChild;

        // Assert
        System.assertEquals(1, [select NumberOfEmployees from Account where id = :accountParent.Id][0].NumberOfEmployees);
    }

    /**
     * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/39
     **/
    @IsTest     
    private static void testParentDeletedByChildTriggerToleranceParentsDeleted() {
        
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

        // Create rollup
        LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
        rollupSummary.Name = 'Test Rollup';
        rollupSummary.ParentObject__c = parentObjectName;
        rollupSummary.ChildObject__c = childObjectName;
        rollupSummary.RelationShipField__c = relationshipField;
        rollupSummary.FieldToAggregate__c = aggregateField;
        rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
        rollupSummary.AggregateResultField__c = aggregateResultField;
        rollupSummary.Active__c = true;
        rollupSummary.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
        insert rollupSummary;

        // Insert parents
        SObject parentA = parentType.newSObject();
        parentA.put('Name', 'ParentA');
        SObject parentB = parentType.newSObject();
        parentB.put('Name', 'ParentA');
        List<SObject> parents = new List<SObject> { parentA, parentB };
        insert parents;

        // Insert children
        SObject child1 = childType.newSObject();
        child1.put(relationshipField, parentA.Id);
        child1.put(aggregateField, 42);
        SObject child2 = childType.newSObject();
        child2.put(relationshipField, parentB.Id);
        child2.put(aggregateField, 42);
        insert new List<SObject> { child1, child2 };
        
        // Attempt to delete and ask child trigger to delete its parents also BEFORE calling rollup
        TestContext.DeleteParentRecord = true;
        delete new List<SObject> { child1, child2 };
        
        // Assert no parent records
        System.assertEquals(0, [select Id from LookupParent__c].size());
    }
    
    /**
     * See issue comments for more information https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/375
     **/
    @IsTest
    private static void testParentIdsVaryOnlyByCaseTolerated() {

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
        rollupSummaryAccount.Active__c = true;
        rollupSummaryAccount.CalculationMode__c = 'Scheduled';
        insert rollupSummaryAccount;
        
        // Tasks
        Id accountAId = '001b0000008RmID'; // Safe since the key prefix for Account is the same accross all orgs
        Id taskAId = fflib_IDGenerator.generate(Task.SObjectType);
        Task taskA = new Task(WhatId = accountAId);
        Id accountBId = '001b0000008rmID'; // Safe since the key prefix for Account is the same accross all orgs
        Id taskBId = fflib_IDGenerator.generate(Task.SObjectType);
        Task taskB = new Task(WhatId = accountBId);
        
        // Given               
        Map<Id, SObject> existingRecords = new Map<Id, SObject>(); // Insert only test is fine for this test
        Map<Id, SObject> newRecords = new Map<Id, SObject> { taskAId => taskA, taskBId => taskB };
        Schema.SObjectType sObjectType = Task.SObjectType;
        List<RollupSummaries.CalculationMode> calculationModes = 
            new List<RollupSummaries.CalculationMode> { RollupSummaries.CalculationMode.Scheduled }; 
        
        // When 
        RollupService.handleRollups(existingRecords, newRecords, sObjectType, calculationModes);        
        
        // Then
        // System.assertEquals(2, [select Id, ParentId__c from LookupRollupSummaryScheduleItems__c].size());
        System.debug([select Id, ParentId__c from LookupRollupSummaryScheduleItems__c]); 
    }
    

	/**
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/39
	 **/
	@IsTest	 
	private static void selfRollupInsert() {

        // Test supported?
        if(!TestContext.isSupported())
            return;

		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup';
		rollupSummaryA.ParentObject__c = 'Opportunity';
		rollupSummaryA.ChildObject__c = 'Opportunity';
		rollupSummaryA.RelationShipField__c = 'Id';
		rollupSummaryA.FieldToAggregate__c = 'CreatedDate';
		rollupSummaryA.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
		rollupSummaryA.AggregateResultField__c = 'Amount';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = 'Realtime';
		insert rollupSummaryA;

		// Setup parent test records
		Opportunity opp = new Opportunity();
		opp.Name = 'Test Opportunity';
		opp.StageName = 'Open';
		opp.CloseDate = System.today();
		opp.Amount = 100;		
		insert opp;

		// Assert
		System.assertEquals(1, [select Amount from Opportunity where id = :opp.Id][0].Amount);
	}

	/**
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/39
	 **/
	@IsTest	 
	private static void selfRollupDelete() {

        // Test supported?
        if(!TestContext.isSupported())
            return;

		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup';
		rollupSummaryA.ParentObject__c = 'Opportunity';
		rollupSummaryA.ChildObject__c = 'Opportunity';
		rollupSummaryA.RelationShipField__c = 'Id';
		rollupSummaryA.FieldToAggregate__c = 'CreatedDate';
		rollupSummaryA.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
		rollupSummaryA.AggregateResultField__c = 'Amount';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = 'Realtime';
		insert rollupSummaryA;

		// Setup parent test records
		Opportunity opp = new Opportunity();
		opp.Name = 'Test Opportunity';
		opp.StageName = 'Open';
		opp.CloseDate = System.today();
		opp.Amount = 100;		
		insert opp;
		delete opp;

		// Assert this doesn't result in an exception, as it once did
		// ENTITY_IS_DELETED, entity is deleted: []: Class.dlrs.RollupService.Updater.updateRecords: line 1159, column 1
	}

	private testmethod static void testSingleRollupWithInsertThenDelete()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		// Configure rollup
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'Amount';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.AggregateAllRows__c = true;
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		insert new List<LookupRollupSummary__c> { rollupSummary };
		
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		Opportunity opp = new Opportunity(); 
		opp.Name = 'Test Opportunity';
		opp.StageName = 'Open';
		opp.CloseDate = System.today();
		opp.AccountId = account.Id;
		opp.Amount = 100;
		insert opp;
		
		// Assert rollup
		System.assertEquals(100, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);
		
		// Delete Opportunity
		delete opp;
		
		// Assert rollup
		System.assertEquals(100, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);							
	}


	private testmethod static void testSingleRollupWithInsertThenDeleteThenUnDelete()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		// Configure rollup
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'Amount';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.AggregateAllRows__c = false;
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		insert new List<LookupRollupSummary__c> { rollupSummary };
		
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		Opportunity opp = new Opportunity(); 
		opp.Name = 'Test Opportunity';
		opp.StageName = 'Open';
		opp.CloseDate = System.today();
		opp.AccountId = account.Id;
		opp.Amount = 100;
		insert opp;
		
		// Assert rollup
		System.assertEquals(100, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);
		
		// Delete Opportunity
		delete opp;
		
		// Assert rollup
		System.assertEquals(0, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);

		// Undelete Opportunity
		undelete opp;
		
		// Assert rollup
		System.assertEquals(100, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);		
	}

	/** 
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/303
	 **/
	@IsTest
	private static void testAccountMergeAsParent() {

        // Test supported?
        if(!TestContext.isSupported())
            return;

		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup';
		rollupSummaryA.ParentObject__c = 'Account';
		rollupSummaryA.ChildObject__c = 'Task';
		rollupSummaryA.RelationShipField__c = 'WhatId';
		rollupSummaryA.FieldToAggregate__c = 'Id';
		rollupSummaryA.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
		rollupSummaryA.AggregateResultField__c = 'AnnualRevenue';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = 'Realtime';
		insert rollupSummaryA;

		// Setup parent test records
		Account accountParentA = new Account(Name = 'Test Account A');
		insert accountParentA;
		// Setup parent test records
		Account accountParentB = new Account(Name = 'Test Account B');
		insert accountParentB;

		// Insert a Task for Account and assert
		Task task1 = new Task();
		task1.Subject = 'Task A';
		task1.WhatId = accountParentA.Id;
		insert task1;

		// Insert a Task for Account and assert
		Task task2 = new Task();
		task2.Subject = 'Task B';
		task2.WhatId = accountParentB.Id;
		insert task2;

		// Real time working?
		System.assertEquals(1, [select AnnualRevenue from Account where id = :accountParentA.Id][0].AnnualRevenue);
		System.assertEquals(1, [select AnnualRevenue from Account where id = :accountParentB.Id][0].AnnualRevenue);

		// Enable the Account (Parent) Trigger
		TestContext.AccountTestTriggerEnabled = true;

		// Merge?
		Database.merge(accountParentA, accountParentB.Id);

		// Assert Schedule items are added
		System.assertEquals(accountParentA.Id, [select Id, ParentId__c from LookupRollupSummaryScheduleItems__c][0].ParentId__c); 

		// Run rollup job
		Test.startTest();		
		RollupService.runJobToProcessScheduledItems(); 
		Test.stopTest();		

		// Schedule items triggered refresh of rollups?
		System.assertEquals(2, [select AnnualRevenue from Account where id = :accountParentA.Id][0].AnnualRevenue);
	}

	/** 
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/303
	 **/
	@IsTest
	private static void testAccountMergeAsParentWithoutParentTriggerDeployed() {

        // Test supported?
        if(!TestContext.isSupported())
            return;

		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup';
		rollupSummaryA.ParentObject__c = 'Account';
		rollupSummaryA.ChildObject__c = 'Task';
		rollupSummaryA.RelationShipField__c = 'WhatId';
		rollupSummaryA.FieldToAggregate__c = 'Id';
		rollupSummaryA.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
		rollupSummaryA.AggregateResultField__c = 'AnnualRevenue';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = 'Realtime';
		insert rollupSummaryA;

		// Setup parent test records
		Account accountParentA = new Account(Name = 'Test Account A');
		insert accountParentA;
		// Setup parent test records
		Account accountParentB = new Account(Name = 'Test Account B');
		insert accountParentB;

		// Insert a Task for Account and assert
		Task task1 = new Task();
		task1.Subject = 'Task A';
		task1.WhatId = accountParentA.Id;
		insert task1;

		// Insert a Task for Account and assert
		Task task2 = new Task();
		task2.Subject = 'Task B';
		task2.WhatId = accountParentB.Id;
		insert task2;

		// Real time working?
		System.assertEquals(1, [select AnnualRevenue from Account where id = :accountParentA.Id][0].AnnualRevenue);
		System.assertEquals(1, [select AnnualRevenue from Account where id = :accountParentB.Id][0].AnnualRevenue);

		// Disable the Account (Parent) Trigger, this prevents the rollups from being recalculated
		TestContext.AccountTestTriggerEnabled = false;

		// Merge?
		Database.merge(accountParentA, accountParentB.Id);

		// Assert no Schedule items are added
		System.assertEquals(0, [select Id, ParentId__c from LookupRollupSummaryScheduleItems__c].size()); 

		// Schedule items triggered refresh of rollups? No
		System.assertEquals(1, [select AnnualRevenue from Account where id = :accountParentA.Id][0].AnnualRevenue);

	}

	/** 
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/303
	 **/
	@IsTest
	private static void testContactMergeAsChild() {

        // Test supported?
        if(!TestContext.isSupported())
            return;

		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryA.ParentObject__c = 'Account';
		rollupSummaryA.ChildObject__c = 'Contact';
		rollupSummaryA.RelationShipField__c = 'AccountId';
		rollupSummaryA.RelationShipCriteria__c = null;
		rollupSummaryA.FieldToAggregate__c = 'FirstName';
		rollupSummaryA.ConcatenateDelimiter__c = ',';
		rollupSummaryA.AggregateOperation__c = 'Concatenate';
		rollupSummaryA.AggregateResultField__c = 'Description';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = 'Realtime';
		insert rollupSummaryA;

		// Test data
		Account accountA = new Account();
		accountA.Name = 'Test Account';
		accountA.AnnualRevenue = 0;
		insert accountA;
		Contact contactA = new Contact();
		contactA.FirstName = 'Fred';
		contactA.LastName = 'Smith';
		contactA.AccountId = accountA.Id;
		insert contactA;
		Contact contactB = new Contact();
		contactB.FirstName = 'Bob';
		contactB.LastName = 'Smith';
		contactB.AccountId = accountA.Id;
		insert contactB;

		// Assert realtime rollup
		System.assertEquals('Fred,Bob', [select Description from Account where Id = :accountA.Id][0].Description);

		// Disable the Account (Parent) Trigger (just to prove we don't need it as its a child merge)
		TestContext.AccountTestTriggerEnabled = false;

		// Merge contacts
		Database.merge(contactA, contactB.Id);

		// Assert Schedule items are added
		System.assertEquals(accountA.Id, [select Id, ParentId__c from LookupRollupSummaryScheduleItems__c][0].ParentId__c); 

		// Run rollup job
		Test.startTest();		
		RollupService.runJobToProcessScheduledItems(); 
		Test.stopTest();		

		System.assertEquals('Fred', [select Description from Account where Id = :accountA.Id][0].Description);
	}	
}
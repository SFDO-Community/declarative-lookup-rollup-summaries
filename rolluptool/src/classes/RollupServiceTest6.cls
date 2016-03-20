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
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/318
	 **/
	@IsTest
	private static void testHistoricBeforeV2ScheduleItemsAreTolerated() {

		// Setup parent test records
		Account accountParent = new Account(Name = 'Test Account');
		insert accountParent;
		Opportunity oppParent = new Opportunity();
		oppParent.Name = 'Test Opportunity';
		oppParent.StageName = 'Open';
		oppParent.CloseDate = System.today();
		oppParent.AccountId = accountParent.Id;
		insert oppParent;

		// Insert Tasks to generated scheduled job work items
		Task task1 = new Task();
		task1.Subject = 'Task A';
		task1.WhatId = accountParent.Id;
		Task task2 = new Task();
		task2.Subject = 'Task A';
		task2.WhatId = oppParent.Id;
		insert new List<Task> { task1, task2 };

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

		// Inject a valid schedule item record
		LookupRollupSummaryScheduleItems__c lrssiAccount = new LookupRollupSummaryScheduleItems__c();
		lrssiAccount.LookupRollupSummary__c = rollupSummaryAccount.Id;
		lrssiAccount.LookupRollupSummary2__c = rollupSummaryAccount.Id;
		lrssiAccount.ParentId__c = accountParent.Id;
		lrssiAccount.QualifiedParentID__c = lrssiAccount.ParentId__c + '#' + LookupRollupSummary__c.Id; 
		insert lrssiAccount;

		// Inject a valid schedule item record created before v2.0
		LookupRollupSummaryScheduleItems__c lrssiOpp = new LookupRollupSummaryScheduleItems__c();
		lrssiOpp.LookupRollupSummary__c = rollupSummaryAccount.Id; // Emulate invalid entry
		lrssiOpp.LookupRollupSummary2__c = null;
		lrssiOpp.ParentId__c = oppParent.Id;
		lrssiOpp.QualifiedParentID__c = lrssiOpp.ParentId__c + '#' + LookupRollupSummary__c.Id; 
		insert lrssiOpp;
		
		// Run rollup job
		Test.startTest();		
		RollupService.runJobToProcessScheduledItems(); 
		Test.stopTest();

		// Assert scheduled rollup for account worked, but the invalided schedule item was silently swallowed and deleted
		System.assertEquals(0, [select Id from LookupRollupSummaryScheduleItems__c].size()); 
		System.assertEquals(1, [select AnnualRevenue from Account where id = :accountParent.Id][0].AnnualRevenue);
	}	

	/**
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/39
	 **/
	@IsTest	 
	private static void selfRollupInsert() {

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

	/** 
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/303
	 **/
	/*
	@IsTest
	private static void testAccountMergeAsParent() {

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

		Database.merge(accountParentA, accountParentB.Id);

		System.assertEquals(2, [select AnnualRevenue from Account where id = :accountParentA.Id][0].AnnualRevenue);

	}
	*/

	/** 
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/303
	 **/
	/*
	@IsTest
	private static void testAccountMergeAsChild() {

		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
		rollupSummaryA.ParentObject__c = 'Account';
		rollupSummaryA.ChildObject__c = 'Opportunity';
		rollupSummaryA.RelationShipField__c = 'AccountId';
		rollupSummaryA.RelationShipCriteria__c = null;
		rollupSummaryA.FieldToAggregate__c = 'Amount';
		rollupSummaryA.AggregateOperation__c = 'Sum';
		rollupSummaryA.AggregateResultField__c = 'AnnualRevenue';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = 'Realtime';
		insert rollupSummaryA;

		// Test data
		Account accountA = new Account();
		accountA.Name = 'Test Account';
		accountA.AnnualRevenue = 0;
		insert accountA;
		Opportunity oppA = new Opportunity();
		oppA.Name = 'Test Opportunity';
		oppA.StageName = 'Open';
		oppA.CloseDate = System.today();
		oppA.AccountId = accountA.Id;
		oppA.Amount = 100;
		insert oppA;
		Account accountB = new Account();
		accountB.Name = 'Test Account';
		accountB.AnnualRevenue = 0;
		insert accountB;
		Opportunity oppB = new Opportunity();
		oppB.Name = 'Test Opportunity';
		oppB.StageName = 'Open';
		oppB.CloseDate = System.today();
		oppB.AccountId = accountB.Id;
		oppB.Amount = 100;
		insert oppB;

		System.assertEquals(100, [select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountA.Id][0].AnnualRevenue);

		Database.merge(accountA, accountB.Id);

		System.assertEquals(200, [select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountA.Id][0].AnnualRevenue);
	}	
	*/
}
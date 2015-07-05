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
private class RollupServiceTest5 {

	@IsTest
	private static void testPolymorphicRelationshipsRealtime() {

		// Polymorphic lookup between Task and Account
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

		// Polymorphic lookup between Task and Opportunity
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject__c = 'Opportunity';
		rollupSummary.ChildObject__c = 'Task';
		rollupSummary.RelationShipField__c = 'WhatId';
		rollupSummary.FieldToAggregate__c = 'Id';
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
		rollupSummary.AggregateResultField__c = 'TotalOpportunityQuantity';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		insert rollupSummary;

		// Setup parent test records
		Account accountParent = new Account(Name = 'Test Account');
		insert accountParent;
		Opportunity opp = new Opportunity();
		opp.Name = 'Test Opportunity';
		opp.StageName = 'Open';
		opp.CloseDate = System.today();
		opp.AccountId = accountParent.Id;
		insert opp;

		// Insert a Task for Account and assert
		Task task1 = new Task();
		task1.Subject = 'Task A';
		task1.WhatId = accountParent.Id;
		insert task1;
		System.assertEquals(1, [select AnnualRevenue from Account where id = :accountParent.Id][0].AnnualRevenue);
		System.assertEquals(null, [select TotalOpportunityQuantity from Opportunity where id = :opp.Id][0].TotalOpportunityQuantity);

		// Insert a Task for Oppoortunity and assert
		Task task2 = new Task();
		task2.Subject = 'Task A';
		task2.WhatId = opp.Id;
		insert task2;
		System.assertEquals(1, [select AnnualRevenue from Account where id = :accountParent.Id][0].AnnualRevenue);
		System.assertEquals(1, [select TotalOpportunityQuantity from Opportunity where id = :opp.Id][0].TotalOpportunityQuantity);
	}

	@IsTest
	private static void testPolymorphicRelationshipsScheduled() {

		// Polymorphic lookup between Task and Account
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

		// Polymorphic lookup between Task and Opportunity
		LookupRollupSummary__c rollupSummaryOpp = new LookupRollupSummary__c();
		rollupSummaryOpp.Name = 'Test Rollup';
		rollupSummaryOpp.ParentObject__c = 'Opportunity';
		rollupSummaryOpp.ChildObject__c = 'Task';
		rollupSummaryOpp.RelationShipField__c = 'WhatId';
		rollupSummaryOpp.FieldToAggregate__c = 'Id';
		rollupSummaryOpp.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
		rollupSummaryOpp.AggregateResultField__c = 'TotalOpportunityQuantity';
		rollupSummaryOpp.Active__c = true;
		rollupSummaryOpp.CalculationMode__c = 'Scheduled';
		insert rollupSummaryOpp;

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

		// Should have two scheduled job work items
		System.assertEquals(2, [select Id from LookupRollupSummaryScheduleItems__c].size()); // Assert a scheduled item has been created
		System.assertEquals(rollupSummaryAccount.Id, [select LookupRollupSummary__c from LookupRollupSummaryScheduleItems__c where ParentId__c = :accountParent.Id][0].LookupRollupSummary__c);
		System.assertEquals(rollupSummaryOpp.Id, [select LookupRollupSummary__c from LookupRollupSummaryScheduleItems__c where ParentId__c = :oppParent.Id][0].LookupRollupSummary__c);
		
		// Run rollup job
		Test.startTest();		
		RollupService.runJobToProcessScheduledItems(); 
		Test.stopTest();

		// Assert scheduled rollup job did its thing!
		System.assertEquals(1, [select AnnualRevenue from Account where id = :accountParent.Id][0].AnnualRevenue);
		System.assertEquals(1, [select TotalOpportunityQuantity from Opportunity where id = :oppParent.Id][0].TotalOpportunityQuantity);		
	}

	@IsTest
	private static void testPolymorphicRelationshipsScheduledIgnoreBadScheduleItems() {

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

		// Polymorphic lookup between Task and Account
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

		// Polymorphic lookup between Task and Opportunity
		LookupRollupSummary__c rollupSummaryOpp = new LookupRollupSummary__c();
		rollupSummaryOpp.Name = 'Test Rollup';
		rollupSummaryOpp.ParentObject__c = 'Opportunity';
		rollupSummaryOpp.ChildObject__c = 'Task';
		rollupSummaryOpp.RelationShipField__c = 'WhatId';
		rollupSummaryOpp.FieldToAggregate__c = 'Id';
		rollupSummaryOpp.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
		rollupSummaryOpp.AggregateResultField__c = 'TotalOpportunityQuantity';
		rollupSummaryOpp.Active__c = true;
		rollupSummaryOpp.CalculationMode__c = 'Scheduled';
		insert rollupSummaryOpp;

		// Inject a valid schedule item record
		LookupRollupSummaryScheduleItems__c lrssiAccount = new LookupRollupSummaryScheduleItems__c();
		lrssiAccount.LookupRollupSummary__c = rollupSummaryAccount.Id;
		lrssiAccount.ParentId__c = accountParent.Id;
		lrssiAccount.QualifiedParentID__c = lrssiAccount.ParentId__c + '#' + LookupRollupSummary__c.Id; 
		insert lrssiAccount;

		// Inject invalid schedule item reocrd, past bug would allow this to be written against 
		//   the wrong lookup rule or user changing the lookup after schedule item written woudl cause an error
		LookupRollupSummaryScheduleItems__c lrssiOpp = new LookupRollupSummaryScheduleItems__c();
		lrssiOpp.LookupRollupSummary__c = rollupSummaryAccount.Id; // Emulate invalid entry
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
		System.assertEquals(null, [select TotalOpportunityQuantity from Opportunity where id = :oppParent.Id][0].TotalOpportunityQuantity);		
	}	
}
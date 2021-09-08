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

        // Test supported?
        if(!TestContext.isSupported())
            return;

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

        // Test supported?
        if(!TestContext.isSupported())
            return;

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
		System.assertEquals(rollupSummaryAccount.Id, [select LookupRollupSummary2__c from LookupRollupSummaryScheduleItems__c where ParentId__c = :accountParent.Id][0].LookupRollupSummary2__c);
		System.assertEquals(rollupSummaryOpp.Id, [select LookupRollupSummary2__c from LookupRollupSummaryScheduleItems__c where ParentId__c = :oppParent.Id][0].LookupRollupSummary2__c);
		
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

        // Test supported?
        if(!TestContext.isSupported())
            return;

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
		lrssiAccount.LookupRollupSummary2__c = rollupSummaryAccount.Id;
		lrssiAccount.ParentId__c = accountParent.Id;
		lrssiAccount.QualifiedParentID__c = lrssiAccount.ParentId__c + '#' + LookupRollupSummary__c.Id; 
		insert lrssiAccount;

		// Inject invalid schedule item reocrd, past bug would allow this to be written against 
		//   the wrong lookup rule or user changing the lookup after schedule item written woudl cause an error
		LookupRollupSummaryScheduleItems__c lrssiOpp = new LookupRollupSummaryScheduleItems__c();
		lrssiOpp.LookupRollupSummary2__c = rollupSummaryAccount.Id; // Emulate invalid entry
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

	private static void assertOrdering(List<Utilities.Ordering> order, Integer numFields, List<String> fields, List<Utilities.SortOrder> directions, List<Boolean> nullsLast)
	{
		System.assertNotEquals(null, order);
		System.assertEquals(numFields, order.size());
		for (Integer i = 0; i < numFields; i++)
		{
			assertOrdering(order[i], fields[i], directions[i], nullsLast[i]);
		}
	}

    private static void assertOrdering(Utilities.Ordering o, String field, Utilities.SortOrder direction, Boolean nullsLast)
    {
        System.assertEquals(field, o.getField());
        System.assertEquals(direction, o.getDirection());
        System.assertEquals(nullsLast, o.getNullsLast());
    }

	@IsTest
	private static void testParseOrderByFieldOnly() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c');
		assertOrdering(	order, 
						1, 
						new List<String> { 'Amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING },
						new List<Boolean> { false });
	}

	@IsTest
	private static void testParseOrderByFieldOnlyLowered() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('amount__c');
		assertOrdering(	order, 
						1, 
						new List<String> { 'amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING },
						new List<Boolean> { false });
	}	

	@IsTest
	private static void testParseOrderByFieldOnlyMixedCase() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('aMoUnT__c');
		assertOrdering(	order, 
						1, 
						new List<String> { 'aMoUnT__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING },
						new List<Boolean> { false });
	}	

	@IsTest
	private static void testParseOrderByFieldAndASCDirection() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c ASC');
		assertOrdering(	order, 
						1, 
						new List<String> { 'Amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING },
						new List<Boolean> { false });
	}	

	@IsTest
	private static void testParseOrderByFieldAndASCDirectionLowered() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c asc');
		assertOrdering(	order, 
						1, 
						new List<String> { 'Amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING },
						new List<Boolean> { false });
	}	

	@IsTest
	private static void testParseOrderByFieldAndDESCDirection() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c DESC');
		assertOrdering(	order, 
						1, 
						new List<String> { 'Amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.DESCENDING },
						new List<Boolean> { false });
	}

	@IsTest
	private static void testParseOrderByFieldAndDESCDirectionLowered() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c desc');
		assertOrdering(	order, 
						1, 
						new List<String> { 'Amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.DESCENDING },
						new List<Boolean> { false });
	}	

	@IsTest
	private static void testParseOrderByFieldAndNullsFirst() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c NULLS FIRST');
		assertOrdering(	order, 
						1, 
						new List<String> { 'Amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING },
						new List<Boolean> { false });
	}	

	@IsTest
	private static void testParseOrderByFieldAndNullsFirstLowered() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c nulls first');
		assertOrdering(	order, 
						1, 
						new List<String> { 'Amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING },
						new List<Boolean> { false });
	}	

	@IsTest
	private static void testParseOrderByFieldAndNullsLast() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c NULLS LAST');
		assertOrdering(	order, 
						1, 
						new List<String> { 'Amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING },
						new List<Boolean> { true });
	}	

	@IsTest
	private static void testParseOrderByFieldAndNullsLastLowered() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c nulls last');
		assertOrdering(	order, 
						1, 
						new List<String> { 'Amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING },
						new List<Boolean> { true });
	}		

	@IsTest
	private static void testParseOrderByFieldAndASCDirectionAndNullsFirst() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c ASC NULLS FIRST');
		assertOrdering(	order, 
						1, 
						new List<String> { 'Amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING },
						new List<Boolean> { false });
	}	

	@IsTest
	private static void testParseOrderByFieldAndASCDirectionAndNullsLast() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c ASC NULLS LAST');
		assertOrdering(	order, 
						1, 
						new List<String> { 'Amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING },
						new List<Boolean> { true });
	}	

	@IsTest
	private static void testParseOrderByFieldAndDESCDirectionAndNullsFirst() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c DESC NULLS FIRST');
		assertOrdering(	order, 
						1, 
						new List<String> { 'Amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.DESCENDING },
						new List<Boolean> { false });
	}	

	@IsTest
	private static void testParseOrderByFieldAndDESCDirectionAndNullsLast() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c DESC NULLS LAST');
		assertOrdering(	order, 
						1, 
						new List<String> { 'Amount__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.DESCENDING },
						new List<Boolean> { true });
	}		

	@IsTest
	private static void testParseOrderByMultipleFieldOnly() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c, Color__c, Name');
		assertOrdering(	order, 
						3, 
						new List<String> { 'Amount__c', 'Color__c', 'Name' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING, Utilities.SortOrder.ASCENDING, Utilities.SortOrder.ASCENDING },
						new List<Boolean> { false, false, false });
	}

	@IsTest
	private static void testParseOrderByMultipleFieldAndMixedDirection() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c ASC, Color__c DESC, Name ASC');
		assertOrdering(	order, 
						3, 
						new List<String> { 'Amount__c', 'Color__c', 'Name' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING, Utilities.SortOrder.DESCENDING, Utilities.SortOrder.ASCENDING },
						new List<Boolean> { false, false, false });
	}	

	@IsTest
	private static void testParseOrderByMultipleFieldAndMixedDirectionAndNulls() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c ASC NULLS LAST, Color__c DESC NULLS FIRST, Name ASC NULLS LAST');
		assertOrdering(	order, 
						3, 
						new List<String> { 'Amount__c', 'Color__c', 'Name' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING, Utilities.SortOrder.DESCENDING, Utilities.SortOrder.ASCENDING },
						new List<Boolean> { true, false, true });
	}

	@IsTest
	private static void testParseOrderByBadField() {
		// parsing will succeed - validation of field name is done in RollupSummaries
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('BadField__c');
		assertOrdering(	order, 
						1, 
						new List<String> { 'BadField__c' },
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING },
						new List<Boolean> { false });
	}

	@IsTest
	private static void testParseOrderByBadDirection() {
		try {
			List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c BAD');
			System.assert(false, 'Expected exception');
		} catch(Utilities.OrderByInvalidException e) {
			System.assertEquals('Invalid order by clause.', e.getMessage());
		}
	}

	@IsTest
	private static void testParseOrderByBadNulls() {
		try {
			List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c ASC BAD');
			System.assert(false, 'Expected exception');
		} catch(Utilities.OrderByInvalidException e) {
			System.assertEquals('Invalid order by clause.', e.getMessage());
		}
	}

	@IsTest
	private static void testParseOrderByMissingNulls() {
		try {
			List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c ASC LAST');
			System.assert(false, 'Expected exception');
		} catch(Utilities.OrderByInvalidException e) {
			System.assertEquals('Invalid order by clause.', e.getMessage());
		}
	}	

	@IsTest
	private static void testParseOrderByBadNullsType() {
		try {
			List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c ASC NULLS BAD');
			System.assert(false, 'Expected exception');
		} catch(Utilities.OrderByInvalidException e) {
			System.assertEquals('Invalid order by clause.', e.getMessage());
		}
	}

	@IsTest
	private static void testParseOrderByMissingNullsType() {
		try {
			List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c ASC NULLS');
			System.assert(false, 'Expected exception');
		} catch(Utilities.OrderByInvalidException e) {
			System.assertEquals('Invalid order by clause.', e.getMessage());
		}
	}	

	@IsTest
	private static void testParseOrderByInvalidStart() {
		try {
			List<Utilities.Ordering> order = Utilities.parseOrderByClause('BAD Amount__c ASC NULLS FIRST');
			System.assert(false, 'Expected exception');
		} catch(Utilities.OrderByInvalidException e) {
			System.assertEquals('Invalid order by clause.', e.getMessage());
		}
	}

	@IsTest
	private static void testParseOrderByInvalidMiddle() {
		try {
			List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c ASC BAD NULLS FIRST');
			System.assert(false, 'Expected exception');
		} catch(Utilities.OrderByInvalidException e) {
			System.assertEquals('Invalid order by clause.', e.getMessage());
		}
	}	

	@IsTest
	private static void testParseOrderByInvalidEnd() {
		try {
			List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c ASC NULLS FIRST BAD');
			System.assert(false, 'Expected exception');
		} catch(Utilities.OrderByInvalidException e) {
			System.assertEquals('Invalid order by clause.', e.getMessage());
		}
	}

	@IsTest
	private static void testParseOrderByMultipleSecondFieldInvalid() {
		try {
			List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c ASC NULLS FIRST, Color__c ASC NULLS BAD, Name ASC NULLS FIRST');
			System.assert(false, 'Expected exception');
		} catch(Utilities.OrderByInvalidException e) {
			System.assertEquals('Invalid order by clause.', e.getMessage());
		}
	}

	@IsTest
	private static void testParseOrderByMultipleThirdFieldInvalid() {
		try {
			List<Utilities.Ordering> order = Utilities.parseOrderByClause('Amount__c ASC NULLS FIRST, Color__c ASC NULLS LAST, Name ASC FIRST');
			System.assert(false, 'Expected exception');
		} catch(Utilities.OrderByInvalidException e) {
			System.assertEquals('Invalid order by clause.', e.getMessage());
		}
	}	

	@IsTest
	private static void testParseOrderByMultipleFieldWhitespaceEverywhere() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause('  	           Amount__c      		ASC        	 NULLS       	 LAST      ,   	Color__c	  DESC    NULLS      FIRST        	');
		assertOrdering(	order, 
						2, 
						new List<String> { 'Amount__c', 'Color__c'},
						new List<Utilities.SortOrder> { Utilities.SortOrder.ASCENDING, Utilities.SortOrder.DESCENDING },
						new List<Boolean> { true, false});
	}
	
	/**
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/379
	 **/
    @IsTest
    private static void testCheckboxRollupWithNoChildren() {

        // Test supported?
        if(!TestContext.isSupported())
            return;

        // Lookup between Task and Opportunity
        LookupRollupSummary__c rollupSummaryOpp = new LookupRollupSummary__c();
        rollupSummaryOpp.Name = 'Test Rollup';
        rollupSummaryOpp.ParentObject__c = 'Lead';
        rollupSummaryOpp.ChildObject__c = 'Task';
        rollupSummaryOpp.RelationShipField__c = 'WhoId';
        rollupSummaryOpp.RelationShipCriteriaFields__c = 'Priority';
        rollupSummaryOpp.FieldToAggregate__c = 'IsHighPriority';
        rollupSummaryOpp.AggregateOperation__c = RollupSummaries.AggregateOperation.Last.name();
        rollupSummaryOpp.AggregateResultField__c = 'HasOptedOutOfEmail';
        rollupSummaryOpp.Active__c = true;
        rollupSummaryOpp.CalculationMode__c = 'Realtime';
        insert rollupSummaryOpp;
        
        // Setup parent test records
        Lead lead = new Lead();
        lead.LastName = 'Bob';
        lead.Company = 'Lego';
        insert lead;

        // Insert Tasks to generated scheduled job work items
        Task task = new Task();
        task.Subject = 'Task A';
        task.Priority = 'High';
        task.WhoId = lead.Id;
        insert task;
        
        // Assert HasOptedOutOfEmail is True
        System.assertEquals(true, [select HasOptedOutOfEmail from Lead where Id = :lead.Id].HasOptedOutOfEmail);
        
        // Update Task
        task.Priority = 'Low';
        update task;
         
        // Assert HasOptedOutOfEmail is False
        System.assertEquals(false, [select HasOptedOutOfEmail from Lead where Id = :lead.Id].HasOptedOutOfEmail);
        
        // Now delete the Task (so there is no children)
        delete task;
         
        // Assert HasOptedOutOfEmail is False
        System.assertEquals(false, [select HasOptedOutOfEmail from Lead where Id = :lead.Id].HasOptedOutOfEmail);
    }   	

	@IsTest
	private static void testParseOrderByBlankClause() {
		List<Utilities.Ordering> order = Utilities.parseOrderByClause(null);
		System.assertEquals(null, order);

		order = Utilities.parseOrderByClause('');
		System.assertEquals(null, order);	

		order = Utilities.parseOrderByClause('		 	   ');
		System.assertEquals(null, order);
	}					
}
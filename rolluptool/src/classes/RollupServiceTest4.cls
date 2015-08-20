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
private class RollupServiceTest4 {

	private testmethod static void testDefaultUserSharingRollup() {
		testSharingMode(10, 10, null);
	}

	private testmethod static void testUserUserSharingRollup() {
		testSharingMode(10, 10, 'User');
	}

	private testmethod static void testSystemUserSharingRollup() {
		testSharingMode(10, 20, 'System');
	}

	private static void testSharingMode(Decimal expectedValue1, Decimal expectedValue2, String sharingMode) {

		// Create test user A
		User testUserA = null;
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			testUserA = createUser(1);
		}

		// Create test user B
		User testUserB = null;
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			testUserB = createUser(2);
		}

		// Rollup from child LookupChildAReallyReallyReallyBigBigName__c (set to private sharing)
		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField = LookupChild__c.Amount__c.getDescribe().getName();
		String aggregateResultField = LookupParent__c.Total2__c.getDescribe().getName();

		// Configure rollup
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject__c = parentObjectName;
		rollupSummary.ChildObject__c = childObjectName;
		rollupSummary.RelationShipField__c = relationshipField;
		rollupSummary.FieldToAggregate__c = aggregateField;
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
		rollupSummary.AggregateResultField__c = aggregateResultField;
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		rollupSummary.CalculationSharingMode__c = sharingMode;
		insert rollupSummary;

		// User A inserts parent and some children
		Id parentId = null;
		System.runAs(testUserA)
		{
			// Insert parents
			SObject parentA = parentType.newSObject();
			parentA.put('Name', 'ParentA');
			parentA.put(LookupParent__c.Total__c.getDescribe().getName(), 42);
			insert parentA;
			parentId = parentA.Id;		
			// Insert children
			SObject child1 = childType.newSObject();
			child1.put(relationshipField, parentId);
			child1.put(aggregateField, 10);
			insert child1;
			// Assert rollup
			Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
			System.assertEquals(expectedValue1, (Decimal) assertParents.get(parentId).get(aggregateResultField));			
		}

		// User B inserts some children of its own
		System.runAs(testUserB)
		{
			// Insert children
			SObject child1 = childType.newSObject();
			child1.put(relationshipField, parentId);
			child1.put(aggregateField, 10);
			insert child1;
			// Assert rollup
			Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
			System.assertEquals(expectedValue2, (Decimal) assertParents.get(parentId).get(aggregateResultField));
		}
	}

	/**
	 * Create test user
	 **/
	private static User createUser(Integer seed)
	{
		// Can only proceed with test if we have a suitable profile
		List<Profile> testProfiles = [Select Id From Profile where Name='Standard User' limit 1];
		if(testProfiles.size()!=1)
			return null; 		

		// Can only proceed with test if we can successfully insert a test user 
		String testUsername = seed + '@testorg.com';
		User testUser = new User(Alias = 'test1', Email='testuser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = testProfiles[0].Id, TimeZoneSidKey='America/Los_Angeles', UserName=testUsername);
		try {
			insert testUser;
			
			// Assign permission sets
			Set<String> psNames = new Set<String> { 'LookupRollupSummariesReadOnly' };
			List<PermissionSet> ps = [select Id from PermissionSet where Name in :psNames];
			insert new List<PermissionSetAssignment> {
				new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps[0].Id)
			};
		} catch (Exception e) {
			return null;
		}		
		return testUser;
	}	

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/229
	 *	Two identical Aggregate (Sum) rollups (except for AggregateResultField) differing only by case used for rollups summary field values
	 *	Should result in a single context used, a single SOQL for the rollup itself and 3 DML rows (1 for each parent)
	 **/
	private testmethod static void testLimitsAndContextsUsedMultipleAggregateRollupsDifferByCaseOnly()
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
		String aggregateResultField1 = LookupParent__c.Total__c.getDescribe().getName();
		String aggregateResultField2 = LookupParent__c.Total2__c.getDescribe().getName();
		String condition = 'Amount__c > 1';
		String relationshipCriteriaFields = 'Amount__c';
		String sharingMode = LREngine.SharingMode.User.name();
		String fieldToOrderBy = LookupChild__c.Amount__c.getDescribe().getName();

		// Configure rollups
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup A';
		rollupSummaryA.ParentObject__c = parentObjectName.toLowerCase();
		rollupSummaryA.ChildObject__c = childObjectName.toLowerCase();
		rollupSummaryA.RelationShipField__c = relationshipField.toLowerCase();
		rollupSummaryA.RelationShipCriteria__c = condition.toLowerCase();		
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields.toLowerCase();
		rollupSummaryA.FieldToAggregate__c = aggregateField.toLowerCase();
		rollupSummaryA.FieldToOrderBy__c = fieldToOrderBy.toLowerCase();
		rollupSummaryA.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
		rollupSummaryA.AggregateResultField__c = aggregateResultField1.toLowerCase();
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
		rollupSummaryA.CalculationSharingMode__c = sharingMode.toLowerCase();		

		LookupRollupSummary__c rollupSummaryB = new LookupRollupSummary__c();
		rollupSummaryB.Name = 'Test Rollup B';
		rollupSummaryB.ParentObject__c = parentObjectName;
		rollupSummaryB.ChildObject__c = childObjectName;
		rollupSummaryB.RelationShipField__c = relationshipField;
		rollupSummaryB.RelationShipCriteria__c = condition;
		rollupSummaryB.RelationShipCriteriaFields__c = relationshipCriteriaFields;
		rollupSummaryB.FieldToAggregate__c = aggregateField;
		rollupSummaryB.FieldToOrderBy__c = fieldToOrderBy;
		rollupSummaryB.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
		rollupSummaryB.AggregateResultField__c = aggregateResultField2;
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
		rollupSummaryB.CalculationSharingMode__c = sharingMode;

		List<LookupRollupSummary__c> rollups = new List<LookupRollupSummary__c> { rollupSummaryA, rollupSummaryB };
		insert rollups;
		
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

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		insert children;

		// Assert limits
		// TODO: Remove debug statements - in-place to get full picture when test fails
		System.debug(LoggingLevel.ERROR, String.format('%%LIMITS%% Queries - before:{0} after:{1}', new List<String> { String.valueOf(beforeQueries), String.valueOf(Limits.getQueries()) }));
		System.debug(LoggingLevel.ERROR, String.format('%%LIMITS%% QueryRows - before:{0} after:{1}', new List<String> { String.valueOf(beforeRows), String.valueOf(Limits.getQueryRows()) }));
		System.debug(LoggingLevel.ERROR, String.format('%%LIMITS%% DMLRows - before:{0} after:{1}', new List<String> { String.valueOf(beforeDMLRows), String.valueOf(Limits.getDMLRows()) }));		

		// + One query on Rollup object
		// + One query on LookupChild__c for rollup
		System.assertEquals(beforeQueries + 2, Limits.getQueries());	
		
		// + Two rows for Rollup object
		// + Nine rows for LookupChild__c
		System.assertEquals(beforeRows + 11, Limits.getQueryRows());

		// + Nine rows for LookupChild__c (from the update statement itself)
		// + Three rows for LookupParent__c (from rollup processing)
		System.assertEquals(beforeDMLRows + 12, Limits.getDMLRows());		

		// Assert rollups
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0}, {1} from {2}', new List<String>{ aggregateResultField1, aggregateResultField2, parentObjectName })));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField2));

		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField2));

		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField2));
	}

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/229
	 *	Two identical Query (Last) rollups (except for AggregateResultField) differing only by case used for rollups summary field values
	 *	Should result in a single context used, a single SOQL for the rollup itself and 3 DML rows (1 for each parent)
	 **/
	private testmethod static void testLimitsAndContextsUsedMultipleQueryRollupsDifferByCaseOnly()
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
		String aggregateResultField1 = LookupParent__c.Total__c.getDescribe().getName();
		String aggregateResultField2 = LookupParent__c.Total2__c.getDescribe().getName();
		String condition = 'Amount__c > 1';
		String relationshipCriteriaFields = 'Amount__c';
		String sharingMode = LREngine.SharingMode.User.name();
		String fieldToOrderBy = LookupChild__c.Amount__c.getDescribe().getName();

		// Configure rollups
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup A';
		rollupSummaryA.ParentObject__c = parentObjectName.toLowerCase();
		rollupSummaryA.ChildObject__c = childObjectName.toLowerCase();
		rollupSummaryA.RelationShipField__c = relationshipField.toLowerCase();
		rollupSummaryA.RelationShipCriteria__c = condition.toLowerCase();		
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields.toLowerCase();
		rollupSummaryA.FieldToAggregate__c = aggregateField.toLowerCase();
		rollupSummaryA.FieldToOrderBy__c = fieldToOrderBy.toLowerCase();
		rollupSummaryA.AggregateOperation__c = RollupSummaries.AggregateOperation.Last.name();
		rollupSummaryA.AggregateResultField__c = aggregateResultField1.toLowerCase();
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
		rollupSummaryA.CalculationSharingMode__c = sharingMode.toLowerCase();		

		LookupRollupSummary__c rollupSummaryB = new LookupRollupSummary__c();
		rollupSummaryB.Name = 'Test Rollup B';
		rollupSummaryB.ParentObject__c = parentObjectName;
		rollupSummaryB.ChildObject__c = childObjectName;
		rollupSummaryB.RelationShipField__c = relationshipField;
		rollupSummaryB.RelationShipCriteria__c = condition;
		rollupSummaryB.RelationShipCriteriaFields__c = relationshipCriteriaFields;
		rollupSummaryB.FieldToAggregate__c = aggregateField;
		rollupSummaryB.FieldToOrderBy__c = fieldToOrderBy;
		rollupSummaryB.AggregateOperation__c = RollupSummaries.AggregateOperation.Last.name();
		rollupSummaryB.AggregateResultField__c = aggregateResultField2;
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
		rollupSummaryB.CalculationSharingMode__c = sharingMode;

		List<LookupRollupSummary__c> rollups = new List<LookupRollupSummary__c> { rollupSummaryA, rollupSummaryB };
		insert rollups;
		
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
			SObject child1 = childType.newSObject();
			child1.put(relationshipField, parent.Id);
			child1.put(aggregateField, 42);
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField, 10);
			children.add(child2);
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put(aggregateField, 10);
			children.add(child3);
		}

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		insert children;

		// Assert limits
		// TODO: Remove debug statements - in-place to get full picture when test fails
		System.debug(LoggingLevel.ERROR, String.format('%%LIMITS%% Queries - before:{0} after:{1}', new List<String> { String.valueOf(beforeQueries), String.valueOf(Limits.getQueries()) }));
		System.debug(LoggingLevel.ERROR, String.format('%%LIMITS%% QueryRows - before:{0} after:{1}', new List<String> { String.valueOf(beforeRows), String.valueOf(Limits.getQueryRows()) }));
		System.debug(LoggingLevel.ERROR, String.format('%%LIMITS%% DMLRows - before:{0} after:{1}', new List<String> { String.valueOf(beforeDMLRows), String.valueOf(Limits.getDMLRows()) }));		

		// + One query on Rollup object
		// + One query on LookupChild__c for rollup
		System.assertEquals(beforeQueries + 2, Limits.getQueries());	
		
		// + Two rows for Rollup object
		// + Nine rows for LookupChild__c
		System.assertEquals(beforeRows + 11, Limits.getQueryRows());

		// + Nine rows for LookupChild__c (from the update statement itself)
		// + Three rows for LookupParent__c (from rollup processing)
		System.assertEquals(beforeDMLRows + 12, Limits.getDMLRows());		

		// Assert rollups
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0}, {1} from {2}', new List<String>{ aggregateResultField1, aggregateResultField2, parentObjectName })));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField2));

		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField2));

		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField2));
	}

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/229
	 *	Two similar rollups differing by:
	 *		- AggregateFieldResult
	 *		- Operation (both use Query base rollup First/Last)
	 *		- AggregateField
	 *		- All other properties same differing only by case used for rollups summary field values
	 *	Should result in a single context used, a single SOQL for the rollup itself and 3 DML rows (1 for each parent)
	 **/
	private testmethod static void testLimitsAndContextsUsedMultipleQueryRollupsDifferByOperationFieldAndCase()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField1 = LookupChild__c.Color__c.getDescribe().getName();
		String aggregateField2 = LookupChild__c.Amount__c.getDescribe().getName();
		String aggregateResultField1 = LookupParent__c.Colours__c.getDescribe().getName();
		String aggregateResultField2 = LookupParent__c.Total2__c.getDescribe().getName();
		String condition = 'Amount__c > 1';
		String relationshipCriteriaFields = 'Amount__c';
		String sharingMode = LREngine.SharingMode.User.name();
		String fieldToOrderBy = LookupChild__c.Amount__c.getDescribe().getName();

		// Configure rollups
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup A';
		rollupSummaryA.ParentObject__c = parentObjectName.toLowerCase();
		rollupSummaryA.ChildObject__c = childObjectName.toLowerCase();
		rollupSummaryA.RelationShipField__c = relationshipField.toLowerCase();
		rollupSummaryA.RelationShipCriteria__c = condition.toLowerCase();		
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields.toLowerCase();
		rollupSummaryA.FieldToAggregate__c = aggregateField1.toLowerCase();
		rollupSummaryA.FieldToOrderBy__c = fieldToOrderBy.toLowerCase();
		rollupSummaryA.AggregateOperation__c = RollupSummaries.AggregateOperation.First.name();
		rollupSummaryA.AggregateResultField__c = aggregateResultField1.toLowerCase();
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
		rollupSummaryA.CalculationSharingMode__c = sharingMode.toLowerCase();		

		LookupRollupSummary__c rollupSummaryB = new LookupRollupSummary__c();
		rollupSummaryB.Name = 'Test Rollup B';
		rollupSummaryB.ParentObject__c = parentObjectName;
		rollupSummaryB.ChildObject__c = childObjectName;
		rollupSummaryB.RelationShipField__c = relationshipField;
		rollupSummaryB.RelationShipCriteria__c = condition;
		rollupSummaryB.RelationShipCriteriaFields__c = relationshipCriteriaFields;
		rollupSummaryB.FieldToAggregate__c = aggregateField2;
		rollupSummaryB.FieldToOrderBy__c = fieldToOrderBy;
		rollupSummaryB.AggregateOperation__c = RollupSummaries.AggregateOperation.Last.name();
		rollupSummaryB.AggregateResultField__c = aggregateResultField2;
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
		rollupSummaryB.CalculationSharingMode__c = sharingMode;

		List<LookupRollupSummary__c> rollups = new List<LookupRollupSummary__c> { rollupSummaryA, rollupSummaryB };
		insert rollups;
		
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
			SObject child1 = childType.newSObject();
			child1.put(relationshipField, parent.Id);
			child1.put(aggregateField1, 'Red');			
			child1.put(aggregateField2, 42);
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField1, 'Yellow');
			child2.put(aggregateField2, 15);
			children.add(child2);
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put(aggregateField1, 'Blue');			
			child3.put(aggregateField2, 10);
			children.add(child3);
		}

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		insert children;

		// Assert limits
		// TODO: Remove debug statements - in-place to get full picture when test fails
		System.debug(LoggingLevel.ERROR, String.format('%%LIMITS%% Queries - before:{0} after:{1}', new List<String> { String.valueOf(beforeQueries), String.valueOf(Limits.getQueries()) }));
		System.debug(LoggingLevel.ERROR, String.format('%%LIMITS%% QueryRows - before:{0} after:{1}', new List<String> { String.valueOf(beforeRows), String.valueOf(Limits.getQueryRows()) }));
		System.debug(LoggingLevel.ERROR, String.format('%%LIMITS%% DMLRows - before:{0} after:{1}', new List<String> { String.valueOf(beforeDMLRows), String.valueOf(Limits.getDMLRows()) }));		

		// + One query on Rollup object
		// + One query on LookupChild__c for rollup
		System.assertEquals(beforeQueries + 2, Limits.getQueries());	
		
		// + Two rows for Rollup object
		// + Nine rows for LookupChild__c
		System.assertEquals(beforeRows + 11, Limits.getQueryRows());

		// + Nine rows for LookupChild__c (from the update statement itself)
		// + Three rows for LookupParent__c (from rollup processing)
		System.assertEquals(beforeDMLRows + 12, Limits.getDMLRows());		

		// Assert rollups
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0}, {1} from {2}', new List<String>{ aggregateResultField1, aggregateResultField2, parentObjectName })));
		System.assertEquals('Blue', (String) assertParents.get(parentA.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField2));

		System.assertEquals('Blue', (String) assertParents.get(parentB.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField2));

		System.assertEquals('Blue', (String) assertParents.get(parentC.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField2));
	}

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/229
	 *	Two similar rollups differing by:
	 *		- AggregateFieldResult
	 *		- Operation (both use Query base rollup First/Last)
	 *		- AggregateField
	 *		- Order By
	 *		- All other properties same differing only by case used for rollups summary field values
	 *	Should result in Two (2) contexts used, two SOQL for the rollup itself and 3 DML rows (1 for each 
	 *		parent - DLRS combines updates to identical master record ids)
	 **/
	private testmethod static void testLimitsAndContextsUsedMultipleQueryRollupsDifferByOperationFieldCaseOrderBy()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField1 = LookupChild__c.Color__c.getDescribe().getName();
		String aggregateField2 = LookupChild__c.Amount__c.getDescribe().getName();
		String aggregateResultField1 = LookupParent__c.Colours__c.getDescribe().getName();
		String aggregateResultField2 = LookupParent__c.Total2__c.getDescribe().getName();
		String condition = 'Amount__c > 1';
		String relationshipCriteriaFields = 'Amount__c';
		String sharingMode = LREngine.SharingMode.User.name();
		String fieldToOrderBy = LookupChild__c.Amount__c.getDescribe().getName();

		// Configure rollups
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup A';
		rollupSummaryA.ParentObject__c = parentObjectName.toLowerCase();
		rollupSummaryA.ChildObject__c = childObjectName.toLowerCase();
		rollupSummaryA.RelationShipField__c = relationshipField.toLowerCase();
		rollupSummaryA.RelationShipCriteria__c = condition.toLowerCase();		
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields.toLowerCase();
		rollupSummaryA.FieldToAggregate__c = aggregateField1.toLowerCase();
		rollupSummaryA.FieldToOrderBy__c = fieldToOrderBy.toLowerCase();
		rollupSummaryA.AggregateOperation__c = RollupSummaries.AggregateOperation.First.name();
		rollupSummaryA.AggregateResultField__c = aggregateResultField1.toLowerCase();
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
		rollupSummaryA.CalculationSharingMode__c = sharingMode.toLowerCase();		

		LookupRollupSummary__c rollupSummaryB = new LookupRollupSummary__c();
		rollupSummaryB.Name = 'Test Rollup B';
		rollupSummaryB.ParentObject__c = parentObjectName;
		rollupSummaryB.ChildObject__c = childObjectName;
		rollupSummaryB.RelationShipField__c = relationshipField;
		rollupSummaryB.RelationShipCriteria__c = condition;
		rollupSummaryB.RelationShipCriteriaFields__c = relationshipCriteriaFields;
		rollupSummaryB.FieldToAggregate__c = aggregateField2;
		rollupSummaryB.FieldToOrderBy__c = null;
		rollupSummaryB.AggregateOperation__c = RollupSummaries.AggregateOperation.Last.name();
		rollupSummaryB.AggregateResultField__c = aggregateResultField2;
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
		rollupSummaryB.CalculationSharingMode__c = sharingMode;

		List<LookupRollupSummary__c> rollups = new List<LookupRollupSummary__c> { rollupSummaryA, rollupSummaryB };
		insert rollups;
		
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
			SObject child1 = childType.newSObject();
			child1.put(relationshipField, parent.Id);
			child1.put(aggregateField1, 'Red');			
			child1.put(aggregateField2, 42);
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField1, 'Yellow');
			child2.put(aggregateField2, 15);
			children.add(child2);
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put(aggregateField1, 'Blue');			
			child3.put(aggregateField2, 10);
			children.add(child3);
		}

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		insert children;

		// Assert limits
		// TODO: Remove debug statements - in-place to get full picture when test fails
		System.debug(LoggingLevel.ERROR, String.format('%%LIMITS%% Queries - before:{0} after:{1}', new List<String> { String.valueOf(beforeQueries), String.valueOf(Limits.getQueries()) }));
		System.debug(LoggingLevel.ERROR, String.format('%%LIMITS%% QueryRows - before:{0} after:{1}', new List<String> { String.valueOf(beforeRows), String.valueOf(Limits.getQueryRows()) }));
		System.debug(LoggingLevel.ERROR, String.format('%%LIMITS%% DMLRows - before:{0} after:{1}', new List<String> { String.valueOf(beforeDMLRows), String.valueOf(Limits.getDMLRows()) }));		

		// + One query on Rollup object
		// + One query on LookupChild__c for rollup A
		// + One query on LookupChild__c for rollup B
		System.assertEquals(beforeQueries + 3, Limits.getQueries());	
		
		// + Two rows for Rollup object
		// + Nine rows for LookupChild__c for rollup A
		// + Nine rows for LookupChild__c for rollup B
		System.assertEquals(beforeRows + 20, Limits.getQueryRows());

		// + Nine rows for LookupChild__c (from the update statement itself)
		// + Three rows for LookupParent__c for rollup A & B (DLRS combined updates to identical master ids)
		System.assertEquals(beforeDMLRows + 12, Limits.getDMLRows());		

		// Assert rollups
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0}, {1} from {2}', new List<String>{ aggregateResultField1, aggregateResultField2, parentObjectName })));
		System.assertEquals('Blue', (String) assertParents.get(parentA.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField2));

		System.assertEquals('Blue', (String) assertParents.get(parentB.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField2));

		System.assertEquals('Blue', (String) assertParents.get(parentC.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField2));
	}		
}
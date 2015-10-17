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
	 *	Two identical Aggregate (Sum) rollups 
	 *		- Effective values for all fields except for AggregateResultField__c are same
	 *		- Field values differ by case only
	 *		- Field value of RelationShipCriteria__c is identical including case
	 *		only by case used for rollups summary field values except RelationShipCriteria__c which are identical including case
	 *	Should result in a single context used, a single SOQL for the rollup itself and 3 DML rows (1 for each parent)
	 **/
	private testmethod static void testLimitsAndContextsUsedMultipleAggregateRollupsDifferByCaseOnlySameCriteriaSameCase()
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
		rollupSummaryA.RelationShipCriteria__c = condition;		
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields;
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
	 *	Two identical Aggregate (Sum) rollups
	 *		- Effective values for all fields except AggregateResultField__c are same
	 *		- Field values differ only by case
	 *		- Field value of RelationShipCriteria__c differs by case
	 *	Should result in Two (2) contexts used, two SOQL for the rollup itself and 3 DML rows (1 for each 
	 *		parent - DLRS combines updates to identical master record ids)
	 **/
	private testmethod static void testLimitsAndContextsUsedMultipleAggregateRollupsDifferByCaseOnlySameCriteriaDiffCase()
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
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField2));

		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField2));

		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField2));
	}	

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/229
	 *	Two identical Query (Last) rollups 
	 *		- Effective values for all fields except for AggregateResultField__c are same
	 *		- Field values differ by case only
	 *		- Field value of RelationShipCriteria__c is identical including case
	 *		only by case used for rollups summary field values except RelationShipCriteria__c which are identical including case
	 *	Should result in a single context used, a single SOQL for the rollup itself and 3 DML rows (1 for each parent)
	 **/	 
	private testmethod static void testLimitsAndContextsUsedMultipleQueryRollupsDifferByCaseOnlySameCriteriaSameCase()
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
		rollupSummaryA.RelationShipCriteria__c = condition;
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields;
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
	 *	Two identical Query (Last) rollups
	 *		- Effective values for all fields except AggregateResultField__c are same
	 *		- Field values differ only by case
	 *		- Field value of RelationShipCriteria__c differs by case
	 *	Should result in Two (2) contexts used, two SOQL for the rollup itself and 3 DML rows (1 for each 
	 *		parent - DLRS combines updates to identical master record ids)
	 **/	 
	private testmethod static void testLimitsAndContextsUsedMultipleQueryRollupsDifferByCaseOnlySameCriteriaDiffCase()
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
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField2));

		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField2));

		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField2));
	}	

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/229
	 *	Two similar rollups
	 *		- Different AggregateOperation__c (both use Query rollup - First/Last)
	 *		- Different AggregateResultField__c
	 *		- Different FieldToAggregate__c
	 *		- Field value of RelationShipCriteria__c is identical including case	 
	 *		- Effective values for all other fields same differing only by case used
	 *	Should result in a single context used, a single SOQL for the rollup itself and 3 DML rows (1 for each parent)
	 **/	 
	private testmethod static void testLimitsAndContextsUsedMultipleQueryRollupsDifferByOperationFieldAndCaseSameCriteriaSameCase()
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
		rollupSummaryA.RelationShipCriteria__c = condition;
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields;
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
	 *	Two similar rollups
	 *		- Different AggregateOperation__c (both use Query rollup - First/Last)
	 *		- Different AggregateResultField__c
	 *		- Different FieldToAggregate__c
	 *		- Field value of RelationShipCriteria__c differs by case
	 *		- Effective values for all other fields same differing only by case used	 
	 *	Should result in Two (2) contexts used, two SOQL for the rollup itself and 3 DML rows (1 for each 
	 *		parent - DLRS combines updates to identical master record ids)
	 **/		 
	private testmethod static void testLimitsAndContextsUsedMultipleQueryRollupsDifferByOperationFieldAndCaseSameCriteriaDiffCase()
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

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/229
	 *	Two similar rollups differing by:
	 *		- Different AggregateOperation__c (both use Query rollup - First/Last)
	 *		- Different AggregateResultField__c
	 *		- Different Order By
	 *		- Effective values for all other fields same differing only by case used
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
		String fieldToOrderBy1 = LookupChild__c.Amount__c.getDescribe().getName();
		String fieldToOrderBy2 = LookupChild__c.Name.getDescribe().getName();

		// Configure rollups
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup A';
		rollupSummaryA.ParentObject__c = parentObjectName.toLowerCase();
		rollupSummaryA.ChildObject__c = childObjectName.toLowerCase();
		rollupSummaryA.RelationShipField__c = relationshipField.toLowerCase();
		rollupSummaryA.RelationShipCriteria__c = condition;
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields;
		rollupSummaryA.FieldToAggregate__c = aggregateField1.toLowerCase();
		rollupSummaryA.FieldToOrderBy__c = fieldToOrderBy1.toLowerCase();
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
		rollupSummaryB.FieldToOrderBy__c = fieldToOrderBy2;
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
			child1.put('Name', 'ChildZ');
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField1, 'Yellow');
			child2.put(aggregateField2, 15);
			child1.put('Name', 'ChildY');			
			children.add(child2);
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put(aggregateField1, 'Blue');			
			child3.put(aggregateField2, 10);
			child1.put('Name', 'ChildX');			
			children.add(child3);
		}

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		insert children;

		// Assert limits
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

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/239
	 *	Two similar rollups differing by:
	 *		- Different AggregateOperation__c (both use Query rollup - First/Last)
	 *		- Different AggregateResultField__c
	 *		- Different FieldToAggregate__c
	 *		- Different Order By one that has no order by specified
	 *		- Effective values for all other fields same differing only by case used
	 *	Should result in One (1) context used, one SOQL for the rollup itself and 3 DML rows (1 for each 
	 *		parent - DLRS combines updates to identical master record ids)
	 *
	 * The Context will be shared because the rollup that doesn't have an orderby (Rollup B) matches all other criteria
	 * on the other rollup (Rollup A) and therefore its added to Context for that rollup
	 **/	 
	private testmethod static void testLimitsAndContextsUsedMultipleQueryRollupsDifferByOperationAggResultFieldAggFieldCaseOrderByOneOrderByIsNull()
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
		rollupSummaryA.RelationShipCriteria__c = condition;
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields;
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

		// Sample various limits prior to an insert
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		// insert child records
		insert children;

		// Assert limits
		// + One query on Rollup object
		// + One query on LookupChild__c for rollup A & B (single query because orderby matches even though one is not specified)
		System.assertEquals(beforeQueries + 2, Limits.getQueries());	
		
		// + Two rows for Rollup object
		// + Nine rows for LookupChild__c for rollup A
		System.assertEquals(beforeRows + 11, Limits.getQueryRows());

		// + Nine rows for LookupChild__c (from the insert statement itself)
		// + Three rows for LookupParent__c for rollup A & B (DLRS combined updates to identical master ids)
		System.assertEquals(beforeDMLRows + 12, Limits.getDMLRows());		

		// Assert rollups
		// Note that we are able to reliably assert rollup B even though it does not
		// have orderby specified because it will end up using the same context as Rollup A because Rollup B's FieldToAggregate__c
		// matches the first field in the orderby of Rollup A
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0}, {1} from {2}', new List<String>{ aggregateResultField1, aggregateResultField2, parentObjectName })));
		System.assertEquals('Blue', (String) assertParents.get(parentA.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField2));

		System.assertEquals('Blue', (String) assertParents.get(parentB.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField2));

		System.assertEquals('Blue', (String) assertParents.get(parentC.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField2));
	}

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/239
	 *	Three similar rollups differing by:
	 *		- Different AggregateOperation__c (both use Query rollup - First/Last)
	 *		- Different AggregateResultField__c
	 *		- Different FieldToAggregate__c	 
	 *		- Different Order By two that have no order by specified
	 *		- Effective values for all other fields same differing only by case used
	 *	Should result in One (1) context used, one SOQL for the rollup itself and 3 DML rows (1 for each 
	 *		parent - DLRS combines updates to identical master record ids)
	 *
	 * The Context will be shared because the two rollups that do not have an orderby (Rollup B and C) matches all other criteria
	 * on the other rollup (Rollup A) and therefore are added to Context for that rollup
	 **/	 
	private testmethod static void testLimitsAndContextsUsedMultipleQueryRollupsDifferByOperationAggResultFieldAggFieldCaseOrderByTwoOrderByIsNullSameFieldToAggregate()
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
		String aggregateField2 = LookupChild__c.Description__c.getDescribe().getName();
		String aggregateField3 = LookupChild__c.Description__c.getDescribe().getName();
		String aggregateResultField1 = LookupParent__c.Colours__c.getDescribe().getName();
		String aggregateResultField2 = LookupParent__c.Descriptions__c.getDescribe().getName();
		String aggregateResultField3 = LookupParent__c.Descriptions2__c.getDescribe().getName();
		String condition = 'Description__c != null';
		String relationshipCriteriaFields = 'Description__c';
		String sharingMode = LREngine.SharingMode.User.name();
		String fieldToOrderBy = LookupChild__c.Name.getDescribe().getName();

		// Configure rollups
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup A';
		rollupSummaryA.ParentObject__c = parentObjectName.toLowerCase();
		rollupSummaryA.ChildObject__c = childObjectName.toLowerCase();
		rollupSummaryA.RelationShipField__c = relationshipField.toLowerCase();
		rollupSummaryA.RelationShipCriteria__c = condition;
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields;
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

		LookupRollupSummary__c rollupSummaryC = new LookupRollupSummary__c();
		rollupSummaryC.Name = 'Test Rollup C';
		rollupSummaryC.ParentObject__c = parentObjectName;
		rollupSummaryC.ChildObject__c = childObjectName;
		rollupSummaryC.RelationShipField__c = relationshipField;
		rollupSummaryC.RelationShipCriteria__c = condition;
		rollupSummaryC.RelationShipCriteriaFields__c = relationshipCriteriaFields;
		rollupSummaryC.FieldToAggregate__c = aggregateField3;
		rollupSummaryC.FieldToOrderBy__c = null;
		rollupSummaryC.AggregateOperation__c = RollupSummaries.AggregateOperation.First.name();
		rollupSummaryC.AggregateResultField__c = aggregateResultField3;
		rollupSummaryC.Active__c = true;
		rollupSummaryC.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
		rollupSummaryC.CalculationSharingMode__c = sharingMode;		

		List<LookupRollupSummary__c> rollups = new List<LookupRollupSummary__c> { rollupSummaryA, rollupSummaryB, rollupSummaryC };
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
			child1.put('Name', 'tom');
			child1.put(aggregateField1, 'Red');			
			child1.put(aggregateField2, 'lemon');
			// aggregateField3 is same SObjectField as aggregateField2
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put('Name', 'charlie');			
			child2.put(aggregateField1, 'Yellow');
			child2.put(aggregateField2, 'pear');
			// aggregateField3 is same SObjectField as aggregateField2
			children.add(child2);
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put('Name', 'samantha');			
			child3.put(aggregateField1, 'Blue');
			child3.put(aggregateField2, 'apple');
			// aggregateField3 is same SObjectField as aggregateField2
			children.add(child3);		
		}

		// Sample various limits prior to an insert
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		// insert child records
		insert children;

		// Assert limits
		// + One query on Rollup object
		// + One query on LookupChild__c for rollup A, B & C
		System.assertEquals(beforeQueries + 2, Limits.getQueries());	
		
		// + Three rows for Rollup object
		// + Nine rows for LookupChild__c for rollup A, B & C
		System.assertEquals(beforeRows + 12, Limits.getQueryRows());

		// + Nine rows for LookupChild__c (from the insert statement itself)
		// + Three rows for LookupParent__c for rollup A & B & C (DLRS combined updates to identical master ids)
		System.assertEquals(beforeDMLRows + 12, Limits.getDMLRows());		

		// Assert rollups
		// Note that we are able to reliably assert rollups B & C even though they do not have an order by specified
		// because they same the same criteria as A and therefore will be added to the same context that was created for A
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0}, {1}, {2} from {3}', new List<String>{ aggregateResultField1, aggregateResultField2, aggregateResultField3, parentObjectName })));
		System.assertEquals('Yellow', (String) assertParents.get(parentA.id).get(aggregateResultField1));
		System.assertEquals('lemon', (String) assertParents.get(parentA.id).get(aggregateResultField2));
		System.assertEquals('pear', (String) assertParents.get(parentA.id).get(aggregateResultField3));

		System.assertEquals('Yellow', (String) assertParents.get(parentB.id).get(aggregateResultField1));
		System.assertEquals('lemon', (String) assertParents.get(parentB.id).get(aggregateResultField2));
		System.assertEquals('pear', (String) assertParents.get(parentB.id).get(aggregateResultField3));

		System.assertEquals('Yellow', (String) assertParents.get(parentC.id).get(aggregateResultField1));
		System.assertEquals('lemon', (String) assertParents.get(parentC.id).get(aggregateResultField2));
		System.assertEquals('pear', (String) assertParents.get(parentC.id).get(aggregateResultField3));		
	}

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/239
	 *	Three similar rollups differing by:
	 *		- Different AggregateOperation__c (both use Query rollup - First/Last)
	 *		- Different AggregateResultField__c
	 *		- Different Order By two that have no order by specified
	 *		- Effective values for all other fields same differing only by case used
	 *	Should result in One (1) context used, one SOQL for the rollup itself and 3 DML rows (1 for each 
	 *		parent - DLRS combines updates to identical master record ids)
	 *
	 * The Context will be shared because the two rollups that do not have an orderby (Rollup B and C) matches all other criteria
	 * on the other rollup (Rollup A) and therefore are added to Context for that rollup
	 **/	 
	private testmethod static void testLimitsAndContextsUsedMultipleQueryRollupsDifferByOperationFieldCaseOrderByTwoOrderByIsNullDifferentFieldToAggregate()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField1 = LookupChild__c.Description__c.getDescribe().getName();
		String aggregateField2 = LookupChild__c.Description__c.getDescribe().getName();
		String aggregateField3 = LookupChild__c.Color__c.getDescribe().getName();
		String aggregateResultField1 = LookupParent__c.Descriptions__c.getDescribe().getName();
		String aggregateResultField2 = LookupParent__c.Descriptions2__c.getDescribe().getName();
		String aggregateResultField3 = LookupParent__c.Colours__c.getDescribe().getName();
		String condition = 'Description__c != null';
		String relationshipCriteriaFields = 'Description__c';
		String sharingMode = LREngine.SharingMode.User.name();
		String fieldToOrderBy = LookupChild__c.Description__c.getDescribe().getName();

		// Configure rollups
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup A';
		rollupSummaryA.ParentObject__c = parentObjectName.toLowerCase();
		rollupSummaryA.ChildObject__c = childObjectName.toLowerCase();
		rollupSummaryA.RelationShipField__c = relationshipField.toLowerCase();
		rollupSummaryA.RelationShipCriteria__c = condition;
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields;
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

		LookupRollupSummary__c rollupSummaryC = new LookupRollupSummary__c();
		rollupSummaryC.Name = 'Test Rollup C';
		rollupSummaryC.ParentObject__c = parentObjectName;
		rollupSummaryC.ChildObject__c = childObjectName;
		rollupSummaryC.RelationShipField__c = relationshipField;
		rollupSummaryC.RelationShipCriteria__c = condition;
		rollupSummaryC.RelationShipCriteriaFields__c = relationshipCriteriaFields;
		rollupSummaryC.FieldToAggregate__c = aggregateField3;
		rollupSummaryC.FieldToOrderBy__c = null;
		rollupSummaryC.AggregateOperation__c = RollupSummaries.AggregateOperation.First.name();
		rollupSummaryC.AggregateResultField__c = aggregateResultField3;
		rollupSummaryC.Active__c = true;
		rollupSummaryC.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
		rollupSummaryC.CalculationSharingMode__c = sharingMode;		

		List<LookupRollupSummary__c> rollups = new List<LookupRollupSummary__c> { rollupSummaryA, rollupSummaryB, rollupSummaryC };
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
			child1.put(aggregateField1, 'lemon');
			// aggregateField2 is same SObjectField as aggregateField1
			child1.put(aggregateField3, 'Red');			
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField1, 'pear');
			// aggregateField2 is same SObjectField as aggregateField1
			child2.put(aggregateField3, 'Yellow');			
			children.add(child2);
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put(aggregateField1, 'apple');
			// aggregateField2 is same SObjectField as aggregateField1
			child3.put(aggregateField3, 'Blue');			
			children.add(child3);
		}

		// Sample various limits prior to an insert
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		// insert child records
		insert children;

		// Assert limits
		// + One query on Rollup object
		// + One query on LookupChild__c for rollup A, B & C
		System.assertEquals(beforeQueries + 2, Limits.getQueries());	
		
		// + Three rows for Rollup object
		// + Nine rows for LookupChild__c for rollup A, B & C
		System.assertEquals(beforeRows + 12, Limits.getQueryRows());

		// + Nine rows for LookupChild__c (from the insert statement itself)
		// + Three rows for LookupParent__c for rollup A & B & C (DLRS combined updates to identical master ids)
		System.assertEquals(beforeDMLRows + 12, Limits.getDMLRows());		

		// Assert rollups
		// Note that we are able to reliably assert rollups B & C even though they do not have an order by specified
		// because they same the same criteria as A and therefore will be added to the same context that was created for A
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0}, {1}, {2} from {3}', new List<String>{ aggregateResultField1, aggregateResultField2, aggregateResultField3, parentObjectName })));
		System.assertEquals('apple', (String) assertParents.get(parentA.id).get(aggregateResultField1));
		System.assertEquals('pear', (String) assertParents.get(parentA.id).get(aggregateResultField2));
		System.assertEquals('Blue', (String) assertParents.get(parentA.id).get(aggregateResultField3));

		System.assertEquals('apple', (String) assertParents.get(parentB.id).get(aggregateResultField1));
		System.assertEquals('pear', (String) assertParents.get(parentB.id).get(aggregateResultField2));
		System.assertEquals('Blue', (String) assertParents.get(parentB.id).get(aggregateResultField3));

		System.assertEquals('apple', (String) assertParents.get(parentC.id).get(aggregateResultField1));
		System.assertEquals('pear', (String) assertParents.get(parentC.id).get(aggregateResultField2));
		System.assertEquals('Blue', (String) assertParents.get(parentC.id).get(aggregateResultField3));
	}

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/239
	 *	Three similar rollups differing by:
	 *		- Different AggregateOperation__c (both use Query rollup - First/Last)
	 *		- Different AggregateResultField__c
	 *		- Different Order By two that have no order by specified
	 *		- Effective values for all other fields same differing only by case used
	 *	Should result in a single context used, a single SOQL for all rollups and 3 DML rows (1 for each parent)	 
	 **/	 
	private testmethod static void testLimitsAndContextsUsedMultipleQueryRollupsNoOrderByShareSingleContext()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField1 = LookupChild__c.Description__c.getDescribe().getName();
		String aggregateField2 = LookupChild__c.Description2__c.getDescribe().getName();
		String aggregateField3 = LookupChild__c.Color__c.getDescribe().getName();
		String aggregateField4 = LookupChild__c.Amount__c.getDescribe().getName();
		String aggregateField5 = LookupChild__c.Amount__c.getDescribe().getName();
		String aggregateResultField1 = LookupParent__c.Descriptions__c.getDescribe().getName();
		String aggregateResultField2 = LookupParent__c.Descriptions2__c.getDescribe().getName();
		String aggregateResultField3 = LookupParent__c.Colours__c.getDescribe().getName();
		String aggregateResultField4 = LookupParent__c.Total__c.getDescribe().getName();
		String aggregateResultField5 = LookupParent__c.Total2__c.getDescribe().getName();
		String condition = 'Description__c != null';
		String relationshipCriteriaFields = 'Description__c';
		String sharingMode = LREngine.SharingMode.User.name();
		String fieldToOrderBy = null;

		// Configure rollups
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup A';
		rollupSummaryA.ParentObject__c = parentObjectName.toLowerCase();
		rollupSummaryA.ChildObject__c = childObjectName.toLowerCase();
		rollupSummaryA.RelationShipField__c = relationshipField.toLowerCase();
		rollupSummaryA.RelationShipCriteria__c = condition;
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields;
		rollupSummaryA.FieldToAggregate__c = aggregateField1.toLowerCase();
		rollupSummaryA.FieldToOrderBy__c = fieldToOrderBy;
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

		LookupRollupSummary__c rollupSummaryC = new LookupRollupSummary__c();
		rollupSummaryC.Name = 'Test Rollup C';
		rollupSummaryC.ParentObject__c = parentObjectName;
		rollupSummaryC.ChildObject__c = childObjectName;
		rollupSummaryC.RelationShipField__c = relationshipField;
		rollupSummaryC.RelationShipCriteria__c = condition;
		rollupSummaryC.RelationShipCriteriaFields__c = relationshipCriteriaFields;
		rollupSummaryC.FieldToAggregate__c = aggregateField3;
		rollupSummaryC.FieldToOrderBy__c = fieldToOrderBy;
		rollupSummaryC.AggregateOperation__c = RollupSummaries.AggregateOperation.First.name();
		rollupSummaryC.AggregateResultField__c = aggregateResultField3;
		rollupSummaryC.Active__c = true;
		rollupSummaryC.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
		rollupSummaryC.CalculationSharingMode__c = sharingMode;	

		LookupRollupSummary__c rollupSummaryD = new LookupRollupSummary__c();
		rollupSummaryD.Name = 'Test Rollup D';
		rollupSummaryD.ParentObject__c = parentObjectName;
		rollupSummaryD.ChildObject__c = childObjectName;
		rollupSummaryD.RelationShipField__c = relationshipField;
		rollupSummaryD.RelationShipCriteria__c = condition;
		rollupSummaryD.RelationShipCriteriaFields__c = relationshipCriteriaFields;
		rollupSummaryD.FieldToAggregate__c = aggregateField4;
		rollupSummaryD.FieldToOrderBy__c = fieldToOrderBy;
		rollupSummaryD.AggregateOperation__c = RollupSummaries.AggregateOperation.Last.name();
		rollupSummaryD.AggregateResultField__c = aggregateResultField4;
		rollupSummaryD.Active__c = true;
		rollupSummaryD.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
		rollupSummaryD.CalculationSharingMode__c = sharingMode;	

		LookupRollupSummary__c rollupSummaryE = new LookupRollupSummary__c();
		rollupSummaryE.Name = 'Test Rollup E';
		rollupSummaryE.ParentObject__c = parentObjectName;
		rollupSummaryE.ChildObject__c = childObjectName;
		rollupSummaryE.RelationShipField__c = relationshipField;
		rollupSummaryE.RelationShipCriteria__c = condition;
		rollupSummaryE.RelationShipCriteriaFields__c = relationshipCriteriaFields;
		rollupSummaryE.FieldToAggregate__c = aggregateField5;
		rollupSummaryE.FieldToOrderBy__c = fieldToOrderBy;
		rollupSummaryE.AggregateOperation__c = RollupSummaries.AggregateOperation.First.name();
		rollupSummaryE.AggregateResultField__c = aggregateResultField5;
		rollupSummaryE.Active__c = true;
		rollupSummaryE.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();
		rollupSummaryE.CalculationSharingMode__c = sharingMode;						

		List<LookupRollupSummary__c> rollups = new List<LookupRollupSummary__c> { rollupSummaryA, rollupSummaryB, rollupSummaryC, rollupSummaryD, rollupSummaryE };
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
			child1.put(aggregateField1, 'lemon');
			child1.put(aggregateField2, 'tom');
			child1.put(aggregateField3, 'Red');
			child1.put(aggregateField4, 42);			
			// aggregateField5 is same SObjectField as aggregateField4
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField1, 'pear');
			child2.put(aggregateField2, 'charlie');
			child2.put(aggregateField3, 'Yellow');
			child2.put(aggregateField4, 42);
			// aggregateField5 is same SObjectField as aggregateField4
			children.add(child2);
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put(aggregateField1, 'apple');
			child3.put(aggregateField2, 'samantha');
			child3.put(aggregateField3, 'Blue');
			child3.put(aggregateField4, 42);
			// aggregateField5 is same SObjectField as aggregateField4
			children.add(child3);
		}

		// Sample various limits prior to an insert
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		// insert child records
		insert children;

		// Assert limits
		// + One query on Rollup object
		// + One query on LookupChild__c for rollup A, B, C, D & E
		System.assertEquals(beforeQueries + 2, Limits.getQueries());	
		
		// + Five rows for Rollup object
		// + Nine rows for LookupChild__c for rollup A, B, C, D & E
		System.assertEquals(beforeRows + 14, Limits.getQueryRows());

		// + Nine rows for LookupChild__c (from the insert statement itself)
		// + Three rows for LookupParent__c for rollup A & B & C & D & E (DLRS combined updates to identical master ids)
		System.assertEquals(beforeDMLRows + 12, Limits.getDMLRows());		

		// Assert rollups
		// Note that we are not able to reliably assert rollups A, B, C, D & E because they do not have orderby specified
		// and will share a context.  Contexts generated for "no orderby specified" do not have an orderby
		// and therefore we cannot assert values since order is non-deterministic
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0}, {1} from {2}', new List<String>{ aggregateResultField1, aggregateResultField2, parentObjectName })));
		System.assertEquals(parents.size(), assertParents.size());
	}	

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/216
	 *	Two similar rollups differing by:
	 *		- Different AggregateOperation__c (both use Query rollup - First/Last)
	 *		- Different AggregateResultField__c
	 *		- Different Order By each containing multiple fields
	 *		- Effective values for all other fields same differing only by case used
	 *	Should result in Two (2) contexts used, two SOQL for the rollup itself and 3 DML rows (1 for each 
	 *		parent - DLRS combines updates to identical master record ids)
	 **/
	private testmethod static void testLimitsAndContextsUsedMultipleQueryRollupsDifferByOperationFieldCaseMultipleFieldsOrderBy()
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
		String orderBy1 = 'Amount__c ASC NULLS FIRST, Color__c ASC NULLS FIRST';
		String orderBy2 = 'Amount__c ASC NULLS FIRST, Color__c DESC NULLS FIRST';

		// Configure rollups
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup A';
		rollupSummaryA.ParentObject__c = parentObjectName.toLowerCase();
		rollupSummaryA.ChildObject__c = childObjectName.toLowerCase();
		rollupSummaryA.RelationShipField__c = relationshipField.toLowerCase();
		rollupSummaryA.RelationShipCriteria__c = condition;
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields;
		rollupSummaryA.FieldToAggregate__c = aggregateField1.toLowerCase();
		rollupSummaryA.FieldToOrderBy__c = orderBy1;
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
		rollupSummaryB.FieldToOrderBy__c = orderBy2;
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

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/239
	 *	Two similar rollups differing by:
	 *		- Different AggregateOperation__c (both use Query rollup - First/Last)
	 *		- Different AggregateResultField__c
	 *		- Neither rollup has any Order by specified (this will result in non-deterministic rolled up values)
	 *		- Effective values for all other fields same differing only by case used
	 *	Should result in a single context used, a single SOQL for the rollup itself and 3 DML rows (1 for each parent)
	 **/
	private testmethod static void testLimitsAndContextsUsedMultipleQueryRollupsDifferByOperationFieldAndCaseSameCriteriaSameCaseNoOrderBy()
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
		String fieldToOrderBy = null;

		// Configure rollups
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup A';
		rollupSummaryA.ParentObject__c = parentObjectName.toLowerCase();
		rollupSummaryA.ChildObject__c = childObjectName.toLowerCase();
		rollupSummaryA.RelationShipField__c = relationshipField.toLowerCase();
		rollupSummaryA.RelationShipCriteria__c = condition;
		rollupSummaryA.RelationShipCriteriaFields__c = relationshipCriteriaFields;
		rollupSummaryA.FieldToAggregate__c = aggregateField1.toLowerCase();
		rollupSummaryA.FieldToOrderBy__c = fieldToOrderBy;
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
			child1.put(aggregateField1, 'orange');			
			child1.put(aggregateField2, 42);
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField1, 'purple');
			child2.put(aggregateField2, 15);
			children.add(child2);
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put(aggregateField1, 'cyan');			
			child3.put(aggregateField2, 10);
			children.add(child3);
		}

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		insert children;

		// Assert limits
		// + One query on Rollup object
		// + One query on LookupChild__c for rollup
		System.assertEquals(beforeQueries + 2, Limits.getQueries());	
		
		// + Two rows for Rollup object
		// + Nine rows for LookupChild__c
		System.assertEquals(beforeRows + 11, Limits.getQueryRows());

		// + Nine rows for LookupChild__c (from the update statement itself)
		// + Three rows for LookupParent__c (from rollup processing)
		System.assertEquals(beforeDMLRows + 12, Limits.getDMLRows());		

		// Unable to reliably assert rollups in this test because
		// no order by was specified therefore result is non-deterministic
		// this test is focused on limits and contexts to ensure a single context is used
	}	

	/**
	 *	Test for issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/229
	 *	Ensure that any field on LookupRollupSummary__c that is describable is updated with describe info
	 **/
	private testmethod static void testLookupRollupSummaryFieldsMatchDescribeInfo()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		String rollupName = 'Test Rollup';
		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField = LookupChild__c.Color__c.getDescribe().getName();
		String aggregateResultField = LookupParent__c.Colours__c.getDescribe().getName();
		String condition = LookupChild__c.Amount__c.getDescribe().getName() + ' > 1';
		List<String> relationshipCriteriaFields = new List<String> { LookupChild__c.Amount__c.getDescribe().getName(), 'Name', 'Id', 'IsDeleted' };
		String sharingMode = LREngine.SharingMode.User.name();
		String fieldToOrderBy = LookupChild__c.Amount__c.getDescribe().getName() + ',' + LookupChild__c.Color__c.getDescribe().getName() + ' ASC,Name NULLS LAST,Id DESC NULLS FIRST';

		// Configure rollups
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = rollupName.toLowerCase();
		rollupSummary.ParentObject__c = parentObjectName.toLowerCase();
		rollupSummary.ChildObject__c = childObjectName.toLowerCase();
		rollupSummary.RelationShipField__c = relationshipField.toLowerCase();
		rollupSummary.RelationShipCriteria__c = condition.toLowerCase();
		rollupSummary.RelationShipCriteriaFields__c = String.join(relationshipCriteriaFields, '\r\n').toLowerCase();
		rollupSummary.FieldToAggregate__c = aggregateField.toLowerCase();
		rollupSummary.FieldToOrderBy__c = fieldToOrderBy.toLowerCase();
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.First.name().toLowerCase();
		rollupSummary.AggregateResultField__c = aggregateResultField.toLowerCase();
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name().toLowerCase();
		rollupSummary.CalculationSharingMode__c = sharingMode.toLowerCase();
		insert rollupSummary;

		// Assert field values were updated to describe info
		LookupRollupSummary__c existingSummary = [SELECT Id, Name, ParentObject__c, ChildObject__c, RelationshipField__c, RelationShipCriteria__c, RelationShipCriteriaFields__c,
													FieldToAggregate__c, FieldToOrderBy__c, AggregateOperation__c, AggregateResultField__c, CalculationMode__c, CalculationSharingMode__c FROM LookupRollupSummary__c WHERE Name = :rollupName];


		// name & condition are not updated with describe info													
		System.assertEquals(rollupName.toLowerCase(), existingSummary.Name);													
		System.assertEquals(condition.toLowerCase(), existingSummary.RelationShipCriteria__c);
		// all remaining fields should match describe
		System.assertEquals(parentObjectName, existingSummary.ParentObject__c);
		System.assertEquals(childObjectName, existingSummary.ChildObject__c);
		System.assertEquals(relationshipField, existingSummary.RelationShipField__c);
		System.assertEquals(String.join(relationshipCriteriaFields, '\r\n'), existingSummary.RelationShipCriteriaFields__c);
		System.assertEquals(aggregateField, existingSummary.FieldToAggregate__c);
		System.assertEquals(fieldToOrderBy, existingSummary.FieldToOrderBy__c);
		System.assertEquals(RollupSummaries.AggregateOperation.First.name(), existingSummary.AggregateOperation__c);
		System.assertEquals(aggregateResultField, existingSummary.AggregateResultField__c);
		System.assertEquals(RollupSummaries.CalculationMode.Realtime.name(), existingSummary.CalculationMode__c);
		System.assertEquals(sharingMode, existingSummary.CalculationSharingMode__c);

		// Set summary values to lowered and update
		existingSummary.Name = rollupName.toLowerCase();
		existingSummary.ParentObject__c = parentObjectName.toLowerCase();
		existingSummary.ChildObject__c = childObjectName.toLowerCase();
		existingSummary.RelationShipField__c = relationshipField.toLowerCase();
		existingSummary.RelationShipCriteria__c = condition.toLowerCase();
		existingSummary.RelationShipCriteriaFields__c = String.join(relationshipCriteriaFields, '\r\n').toLowerCase();
		existingSummary.FieldToAggregate__c = aggregateField.toLowerCase();
		existingSummary.FieldToOrderBy__c = fieldToOrderBy.toLowerCase();
		existingSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.First.name().toLowerCase();
		existingSummary.AggregateResultField__c = aggregateResultField.toLowerCase();
		existingSummary.Active__c = true;
		existingSummary.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name().toLowerCase();
		existingSummary.CalculationSharingMode__c = sharingMode.toLowerCase();
		update rollupSummary;

		// Assert field values were updated to describe info
		existingSummary = [SELECT Id, Name, ParentObject__c, ChildObject__c, RelationshipField__c, RelationShipCriteria__c, RelationShipCriteriaFields__c,
													FieldToAggregate__c, FieldToOrderBy__c, AggregateOperation__c, AggregateResultField__c, CalculationMode__c, CalculationSharingMode__c FROM LookupRollupSummary__c WHERE Name = :rollupName];


		// name & condition are not updated with describe info													
		System.assertEquals(rollupName.toLowerCase(), existingSummary.Name);													
		System.assertEquals(condition.toLowerCase(), existingSummary.RelationShipCriteria__c);
		// all remaining fields should match describe
		System.assertEquals(parentObjectName, existingSummary.ParentObject__c);
		System.assertEquals(childObjectName, existingSummary.ChildObject__c);
		System.assertEquals(relationshipField, existingSummary.RelationShipField__c);
		System.assertEquals(String.join(relationshipCriteriaFields, '\r\n'), existingSummary.RelationShipCriteriaFields__c);
		System.assertEquals(aggregateField, existingSummary.FieldToAggregate__c);
		System.assertEquals(fieldToOrderBy, existingSummary.FieldToOrderBy__c);
		System.assertEquals(RollupSummaries.AggregateOperation.First.name(), existingSummary.AggregateOperation__c);
		System.assertEquals(aggregateResultField, existingSummary.AggregateResultField__c);
		System.assertEquals(RollupSummaries.CalculationMode.Realtime.name(), existingSummary.CalculationMode__c);
		System.assertEquals(sharingMode, existingSummary.CalculationSharingMode__c);
	}	
}
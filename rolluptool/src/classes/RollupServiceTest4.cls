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
}
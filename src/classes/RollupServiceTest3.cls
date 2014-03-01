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
private with sharing class RollupServiceTest3 
{		
	static Schema.SObjectField ACCOUNT_SLA_EXPIRATION_DATE;
	static Schema.SObjectField ACCOUNT_NUMBER_OF_LOCATIONS;		
	static
	{
		// Dynamically resolve these fields, if they are not present when the test runs, the test will return as passed to avoid failures in subscriber org when packaged
		Map<String, Schema.SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();
		ACCOUNT_SLA_EXPIRATION_DATE = accountFields.get('SLAExpirationDate__c');
		ACCOUNT_NUMBER_OF_LOCATIONS = accountFields.get('NumberOfLocations__c');
	}
	
	private testmethod static void testCalculateJob()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		// Insert parents
		Schema.SObjectType parentType = Schema.getGlobalDescribe().get('dlrs__LookupParent__c');
		SObject parentA = parentType.newSObject();
		parentA.put('Name', 'ParentA');
		SObject parentB = parentType.newSObject();
		parentB.put('Name', 'ParentB');
		SObject parentC = parentType.newSObject();
		parentC.put('Name', 'ParentC');
		List<SObject> parents = new List<SObject> { parentA, parentB, parentC };
		insert parents;
		
		// Insert children
		Schema.SObjectType childType = Schema.getGlobalDescribe().get('dlrs__LookupChild__c');
		List<SObject> children = new List<SObject>();
		for(SObject parent : parents)		
		{
			String name = (String) parent.get('Name');
			SObject child1 = childType.newSObject();
			child1.put('dlrs__LookupParent__c', parent.Id);
			child1.put('dlrs__Amount__c', 20);
			children.add(child1);				
			SObject child2 = childType.newSObject();
			child2.put('dlrs__LookupParent__c', parent.Id);
			child2.put('dlrs__Amount__c', 20);
			children.add(child2);				
			if(name.equals('ParentA') || name.equals('ParentB'))
			{
				SObject child3 = childType.newSObject();
				child3.put('dlrs__LookupParent__c', parent.Id);
				child3.put('dlrs__Amount__c', 2);
				children.add(child3);				
			}
		}
		insert children;

		// Create rollup AFTER the data exists		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject__c = 'dlrs__LookupParent__c';
		rollupSummary.ChildObject__c = 'dlrs__LookupChild__c';
		rollupSummary.RelationShipField__c = 'dlrs__LookupParent__c';
		rollupSummary.FieldToAggregate__c = 'dlrs__Amount__c';
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
		rollupSummary.AggregateResultField__c = 'dlrs__Total__c';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Scheduled';	
		insert rollupSummary;
		
		// Run rollup calculate job
		Test.startTest();		
		Id jobId = RollupService.runJobToCalculate(rollupSummary.Id);
		rollupSummary = [select Id, CalculateJobId__c from LookupRollupSummary__c where Id  = :rollupSummary.Id];
		System.assertEquals(jobId, rollupSummary.CalculateJobId__c); // Assert job id captured
		try { 
			// Assert not possible to start another
			RollupService.runJobToCalculate(rollupSummary.Id);
			System.assert(false, 'Expected an exception');
		} catch (Exception e) {
			System.assert(e.getMessage().equals('A calculate job for rollup \'Test Rollup\' is already executing. If you suspect it is not aleady running try clearing the Calculate Job Id field and try again.'));
		}			 
		Test.stopTest();
		// Assert job id cleared
		rollupSummary = [select Id, CalculateJobId__c from LookupRollupSummary__c where Id  = :rollupSummary.Id];
		System.assertEquals(null, rollupSummary.CalculateJobId__c);  

		// This should not generate any schedule items		
		System.assertEquals(0, [select id from LookupRollupSummaryScheduleItems__c].size());
		
		// Assert rollups 
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query('select id, dlrs__Total__c from dlrs__LookupParent__c'));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get('dlrs__Total__c'));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get('dlrs__Total__c'));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get('dlrs__Total__c'));		
		
		// Assert scheduled items and log records
		List<LookupRollupSummaryLog__c> logs = [select id, ParentId__c, ParentObject__c, ErrorMessage__c from LookupRollupSummaryLog__c];
		System.assertEquals(parentC.Id, logs[0].ParentId__c);
		System.assertEquals('dlrs__LookupParent__c', logs[0].ParentObject__c);
		System.assertEquals(1, logs.size());
		System.assertEquals('The answer is not 42! : FIELD_CUSTOM_VALIDATION_EXCEPTION (dlrs__Total__c)', logs[0].ErrorMessage__c);		
	}
	
	private testmethod static void testDeveloperAPI()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		// Create rollup		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject__c = 'dlrs__LookupParent__c';
		rollupSummary.ChildObject__c = 'dlrs__LookupChild__c';
		rollupSummary.RelationShipField__c = 'dlrs__LookupParent__c';
		rollupSummary.FieldToAggregate__c = 'dlrs__Amount__c';
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
		rollupSummary.AggregateResultField__c = 'dlrs__Total__c';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = RollupSummaries.CalculationMode.Developer.name();	
		insert rollupSummary;
		
		// Insert parents
		Schema.SObjectType parentType = Schema.getGlobalDescribe().get('dlrs__LookupParent__c');
		SObject parentA = parentType.newSObject();
		parentA.put('Name', 'ParentA');
		SObject parentB = parentType.newSObject();
		parentB.put('Name', 'ParentB');
		SObject parentC = parentType.newSObject();
		parentC.put('Name', 'ParentC');
		List<SObject> parents = new List<SObject> { parentA, parentB, parentC };
		insert parents;
		
		// Insert children
		Schema.SObjectType childType = Schema.getGlobalDescribe().get('dlrs__LookupChild__c');
		List<SObject> children = new List<SObject>();
		for(SObject parent : parents)		
		{
			String name = (String) parent.get('Name');
			SObject child1 = childType.newSObject();
			child1.put('dlrs__LookupParent__c', parent.Id);
			child1.put('dlrs__Amount__c', 20);
			children.add(child1);				
			SObject child2 = childType.newSObject();
			child2.put('dlrs__LookupParent__c', parent.Id);
			child2.put('dlrs__Amount__c', 20);
			children.add(child2);				
			if(name.equals('ParentA') || name.equals('ParentB'))
			{
				SObject child3 = childType.newSObject();
				child3.put('dlrs__LookupParent__c', parent.Id);
				child3.put('dlrs__Amount__c', 2);
				children.add(child3);				
			}
		}
		insert children;
		
		// Assert nothing has changed on db 
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query('select id, dlrs__Total__c from dlrs__LookupParent__c'));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get('dlrs__Total__c'));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get('dlrs__Total__c'));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get('dlrs__Total__c'));		
				
		// Call developer API
		List<SObject> masterRecords = RollupService.rollup(children);

		// Assert nothing has changed on db 
		assertParents = new Map<Id, SObject>(Database.query('select id, dlrs__Total__c from dlrs__LookupParent__c'));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get('dlrs__Total__c'));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get('dlrs__Total__c'));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get('dlrs__Total__c'));		
		
		// Assert rollups produced
		assertParents = new Map<Id, SObject>(masterRecords);
		System.assertEquals(3, masterRecords.size()); 
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get('dlrs__Total__c'));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get('dlrs__Total__c'));
		System.assertEquals(40, (Decimal) assertParents.get(parentC.id).get('dlrs__Total__c'));		
	}	
}
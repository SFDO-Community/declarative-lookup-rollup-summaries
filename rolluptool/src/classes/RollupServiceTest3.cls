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
        fflib_SObjectDescribe describe = fflib_SObjectDescribe.getDescribe(Account.SObjectType);
        ACCOUNT_SLA_EXPIRATION_DATE = describe.getField('SLAExpirationDate__c');
        ACCOUNT_NUMBER_OF_LOCATIONS = describe.getField('NumberOfLocations__c');
    }

    /**
     * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/347
     **/
    private testmethod static void testCalculateJobWithRollupIdsVaryingOnlyByCase()
    {        
        String rollupA = LookupRollupSummary__c.SObjectType.getDescribe().getKeyPrefix() + 'A00000000000';
        String rollupB = LookupRollupSummary__c.SObjectType.getDescribe().getKeyPrefix() + 'a00000000000';
        RollupService.checkJobAlreadyRunning(rollupA, 'Rollup A');
        RollupService.checkJobAlreadyRunning(rollupB, 'Rollup B');
    }
    	
	private testmethod static void testCalculateJob()
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

		// Create rollup AFTER the data exists
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

		// Run rollup calculate job
		Test.startTest();
		Id jobId = RollupService.runJobToCalculate(rollupSummary.Id);
		System.assertEquals(1, [select Id from LookupRollupCalculateJob__c].size()); 
		try {
			// Assert not possible to start another
			RollupService.runJobToCalculate(rollupSummary.Id);
			System.assert(false, 'Expected an exception');
		} catch (Exception e) {
			System.assert(e.getMessage().equals('A calculate job for rollup \'Test Rollup\' is already executing. If you suspect it is not aleady running try clearing the applicable record from the Lookup Rollup Calculate Jobs tab and try again.'));
		}
		Test.stopTest();
		// Assert job id cleared
 		rollupSummary = [select Id, CalculateJobId__c from LookupRollupSummary__c where Id  = :rollupSummary.Id];
 		System.assertEquals(jobId, rollupSummary.CalculateJobId__c); 		
		// Assert job cleared
		System.assertEquals(0, [select Id from LookupRollupCalculateJob__c].size()); 

		// This should not generate any schedule items
		System.assertEquals(0, [select id from LookupRollupSummaryScheduleItems__c].size());

		// Assert rollups
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// Assert scheduled items and log records
		List<LookupRollupSummaryLog__c> logs = [select id, ParentId__c, ParentObject__c, ErrorMessage__c from LookupRollupSummaryLog__c];
		System.assertEquals(parentC.Id, logs[0].ParentId__c);
		System.assertEquals(parentObjectName, logs[0].ParentObject__c);
		System.assertEquals(1, logs.size());
		System.assertEquals('The answer is not 42! : FIELD_CUSTOM_VALIDATION_EXCEPTION (' + aggregateResultField + ')', logs[0].ErrorMessage__c);
	}

	private testmethod static void testFilteredCalculateJob()
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

		// Create rollup AFTER the data exists
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

		// Run rollup calculate job with WHERE clause
		Test.startTest();
		Id jobId = RollupService.runJobToCalculate(rollupSummary.Id, 'Name = \'ParentB\'');
		Test.stopTest();

		// This should not generate any schedule items
		System.assertEquals(0, [select id from LookupRollupSummaryScheduleItems__c].size());

		// Assert rollups
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// Assert scheduled items and log records
		List<LookupRollupSummaryLog__c> logs = [select id, ParentId__c, ParentObject__c, ErrorMessage__c from LookupRollupSummaryLog__c];
		System.assertEquals(0, logs.size());
	}

	private testmethod static void testCalculateJobNotActive()
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

		// Create rollup AFTER the data exists
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject__c = parentObjectName;
		rollupSummary.ChildObject__c = childObjectName;
		rollupSummary.RelationShipField__c = relationshipField;
		rollupSummary.FieldToAggregate__c = aggregateField;
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
		rollupSummary.AggregateResultField__c = aggregateResultField;
		rollupSummary.Active__c = false;
		rollupSummary.CalculationMode__c = 'Realtime';
		insert rollupSummary;

		// Run rollup calculate job
		Test.startTest();
		try {
			// Assert not possible to start another
			RollupService.runJobToCalculate(rollupSummary.Id);
			System.assert(false, 'Expected an exception');
		} catch (Exception e) {
			System.assert(e.getMessage().equals('The rollup must be Active before you can run a Calculate job.'));
		}
		Test.stopTest();
	}

	private testmethod static void testScheduleCalculateJob() {
		if(!TestContext.isSupported())
			return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField = LookupChild__c.Amount__c.getDescribe().getName();
		String aggregateResultField = LookupParent__c.Total__c.getDescribe().getName();

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

		// Create rollup AFTER the data exists
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

		ApexPages.StandardController standardController = new ApexPages.StandardController(rollupSummary);
		RollupScheduledCalculateController controller = new RollupScheduledCalculateController(standardController);
		
		Test.startTest();
		controller.scheduleCalculateJob();
		//attempt to schedule a second job
		Boolean exceptionCaught = false;
		String jobName = 'rollup_' + String.valueOf(rollupSummary.Id).substring(0,15);
		try{
			System.schedule('rollup_'+standardController.getId(), '0 0 2 * * ?', new RollupCalculateJobSchedulable(standardController.getId(), controller.masterObjectWhere));
		} catch (AsyncException ex) {
			exceptionCaught = true;
			System.assertEquals(ex.getMessage(), 'The Apex job named "'+jobName+'" is already scheduled for execution.');
		}
		
		System.assert(exceptionCaught);

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
		//assert our job is scheduled for 2am
		System.assertEquals('0 0 2 * * ?', ct.CronExpression);
		DateTime nextFiretime = ct.NextFireTime;
		System.assertEquals(2, nextFiretime.hour());
		//assert our job has never fired
		System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();

		//RollupCalculateJob does not execute until after Test.stopTest();
		//we cannot assert anything about the rollup job itself, only that we queued it.
		//see http://salesforce.stackexchange.com/a/36884/11152
		System.assert([SELECT Count() FROM AsyncApexJob WHERE ApexClass.Name = 'RollupCalculateJobSchedulable'] > 0);
	}

	private testmethod static void testDeveloperAPI()
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
		rollupSummary.CalculationMode__c = RollupSummaries.CalculationMode.Developer.name();
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

		// Assert nothing has changed on db
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// Call developer API
		List<SObject> masterRecords = RollupService.rollup(children);

		// Assert nothing has changed on db
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// Assert rollups produced
		assertParents = new Map<Id, SObject>(masterRecords);
		System.assertEquals(3, masterRecords.size());
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(40, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));
	}

	/**
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/23
	 */
	private testmethod static void testDateRollupDeleteChild()
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
		rollupSummary.FieldToAggregate__c = 'CloseDate';
		rollupSummary.AggregateOperation__c = 'Max';
		rollupSummary.AggregateResultField__c = 'SLAExpirationDate__c';
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
		Id accountId = account.Id;
		System.assertEquals(System.today(), Database.query('select SLAExpirationDate__c from Account where Id = :accountId')[0].get(ACCOUNT_SLA_EXPIRATION_DATE));
		
		// Delete Opportunity
		delete opp;
		
		// Assert rollup
		System.assertEquals(null, Database.query('select SLAExpirationDate__c from Account where Id = :accountId')[0].get(ACCOUNT_SLA_EXPIRATION_DATE));								 	
	}
	
	/**
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/23
	 */

	private testmethod static void testDateRollupInsertConditionalChild()
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
		rollupSummary.RelationShipCriteria__c = 'CloseDate < TODAY';
		rollupSummary.FieldToAggregate__c = 'CloseDate';
		rollupSummary.AggregateOperation__c = 'Max';
		rollupSummary.AggregateResultField__c = 'SLAExpirationDate__c';
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
		Id accountId = account.Id;
		System.assertEquals(null, Database.query('select SLAExpirationDate__c from Account where Id = :accountId')[0].get(ACCOUNT_SLA_EXPIRATION_DATE));
		
		// Delete Opportunity
		delete opp;
		
		// Assert rollup
		System.assertEquals(null, Database.query('select SLAExpirationDate__c from Account where Id = :accountId')[0].get(ACCOUNT_SLA_EXPIRATION_DATE));								 	
	}
	
	private testmethod static void testRollupWithInAccessibleParent()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
            
        // Abort if the sharing model does not support this test (some older orgs who have upgraded won't have this)
        SObjectType sharingType = Schema.getGlobalDescribe().get(Utilities.objectPrefix()+'LookupChild__Share');
        if(sharingType==null)
            return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField = LookupChild__c.Amount__c.getDescribe().getName();
		String aggregateResultField = LookupParent__c.Total__c.getDescribe().getName();

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
		insert rollupSummary;

		// Insert parents
		SObject parentA = parentType.newSObject();
		parentA.put('Name', 'ParentA');
		insert parentA;

		// Insert children
		SObject child1 = childType.newSObject();
		child1.put(relationshipField, parentA.Id);
		insert child1;

		// Assert rollup
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));

		// Create test user
		User testUser = null;
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			testUser = createUser();
		}

        // Grant access to the child record since it is using private sharing model
        SObject childSharing = sharingType.newSObject();
        childSharing.put('AccessLevel', 'Edit');
        childSharing.put('ParentId', child1.Id);
        childSharing.put('UserOrGroupId', testUser.Id);
        insert childSharing;

		// Test data insert children as new user (who cannot see the parent)
		System.runAs(testUser)
		{
			// Ensure this user can read it (the Sharing setting for LookupParent__c is Public Read Only)
			assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
			System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));

			// Attempt to indirectly via rollup trigger to update parent record
			child1.put(aggregateField, 42);
			update child1;
		}

		// Assert rollup
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
	}

	/**
	 * Test simulation of isInsert
	 */
	private testmethod static void testDeveloperTriggerLikeAPI_SingleSumInserted()
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
		rollupSummary.CalculationMode__c = RollupSummaries.CalculationMode.Developer.name();
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

		// Assert nothing has changed on db
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeQueryRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		// Call developer 'trigger like' API
		RollupService.rollup(null, new Map<Id, SObject>(children), childType);

		// Assert no further limits have been used since the field to aggregate on the detail has not changed
		// + One query on Rollup object
		// + One query on LookupChild__c for rollup
		System.assertEquals(beforeQueries + 2, Limits.getQueries());
		// + One row for Rollup object
		// + Nine rows for LookupChild__c for rollup
		System.assertEquals(beforeQueryRows + 10, Limits.getQueryRows());
		// + Three rows for LookupParent__c for rollup target
		System.assertEquals(beforeDMLRows + 3, Limits.getDMLRows());

		// Assert parents are updated
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(3, assertParents.size());
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));
	}

	/**
	 * Test simulation of isUpdate with no field changes
	 */
	private testmethod static void testDeveloperTriggerLikeAPI_SingleSumUpdatedFieldDoesNotChange()
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
		rollupSummary.CalculationMode__c = RollupSummaries.CalculationMode.Developer.name();
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

		// Assert nothing has changed on db
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeQueryRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();
		
		// Call developer 'trigger like' API
		// No changes to the field being aggregted, thus no rollup processing should occur
		RollupService.rollup(new Map<Id, SObject>(children), new Map<Id, SObject>(children), childType);

		// Assert no further limits have been used since the field to aggregate on the detail has not changed
		System.assertEquals(beforeQueries + 1, Limits.getQueries()); // Only tolerate a query for the Lookup definition
		System.assertEquals(beforeQueryRows + 1, Limits.getQueryRows()); // Only tolerate a row for the Lookup definition
		System.assertEquals(beforeDMLRows, Limits.getDMLRows()); // No changes so no record should be operated against

		// Assert parents are updated
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(3, assertParents.size());
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));
	}	

	/**
	 * Test simulation of isUpdate with field changes
	 */
	private testmethod static void testDeveloperTriggerLikeAPI_SingleSumUpdatedFieldDoesChange()
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
		rollupSummary.CalculationMode__c = RollupSummaries.CalculationMode.Developer.name();
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
			SObject child1 = childType.newSObject();
			child1.put(relationshipField, parent.Id);
			child1.put(aggregateField, 0);
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField, 0);
			children.add(child2);
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put(aggregateField, 0);
			children.add(child3);
		}
		insert children;

		// Assert nothing has changed on db
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// update the children
		List<SObject> modifiedChildren = Database.query(String.format('select id, {0}, {1} from {2}', new List<String>{ aggregateField, relationshipField, childObjectName }));
		System.assertEquals(9, modifiedChildren.size());
		for (SObject child :modifiedChildren)
		{
			// do not update ParentC children so we can simulate
			// only updated records being processed, non-changed records being ignored
			// and assert governor limits to confirm			
			if (child.get(relationshipField) != parentC.Id)
			{
				child.put(aggregateField, 14);
			}
		}
		update modifiedChildren;

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeQueryRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		// Call developer 'trigger like' API simulating an update
		RollupService.rollup(new Map<Id, SObject>(children), new Map<Id, SObject>(modifiedChildren), childType);

		// Assert no further limits have been used since the field to aggregate on the detail has not changed
		// + One query on Rollup object
		// + One query on LookupChild__c for rollup
		System.assertEquals(beforeQueries + 2, Limits.getQueries());
		// + One row for Rollup object
		// + Six rows for LookupChild__c for rollup for Parent A & Parent B
		System.assertEquals(beforeQueryRows + 7, Limits.getQueryRows());
		// + Two rows for LookupParent__c for rollup target for Parent A & Parent B
		System.assertEquals(beforeDMLRows + 2, Limits.getDMLRows());

		// Assert parents are updated
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(3, assertParents.size());
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));
	}

	/**
	 * Test simulation of combination of isInsert and isUpdate but updates do not effect rollups
	 */
	private testmethod static void testDeveloperTriggerLikeAPI_SingleSumInsertedWithExistingThatDoNotChange()
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
		rollupSummary.CalculationMode__c = RollupSummaries.CalculationMode.Developer.name();
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
			SObject child1 = childType.newSObject();
			child1.put(relationshipField, parent.Id);
			child1.put(aggregateField, 20);
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField, 20);
			children.add(child2);
		}
		insert children;

		// Assert nothing has changed on db
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// insert a new child
		List<SObject> newChildren = new List<SObject>();
		for(SObject parent : parents)
		{
			// do not create new child for ParentC so we can simulate
			// only inserted records being processed, non-changed records being ignored
			// and assert governor limits to confirm
			String name = (String) parent.get('Name');			
			if(!name.equals('ParentC'))
			{			
				SObject child3 = childType.newSObject();
				child3.put(relationshipField, parent.Id);
				child3.put(aggregateField, 2);
				newChildren.add(child3);
			}
		}
		insert newChildren;

		// Assert nothing has changed on db
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// combine the new and old
		List<SObject> newAndOldChildren = children.clone();
		newAndOldChildren.addAll(newChildren);

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeQueryRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		// Call developer 'trigger like' API simulating an update
		RollupService.rollup(new Map<Id, SObject>(children), new Map<Id, SObject>(newAndOldChildren), childType);

		// Assert no further limits have been used since the field to aggregate on the detail has not changed
		// + One query on Rollup object
		// + One query on LookupChild__c for rollup
		System.assertEquals(beforeQueries + 2, Limits.getQueries());
		// + One row for Rollup object
		// + Six rows for LookupChild__c for rollup for Parent A & Parent B
		System.assertEquals(beforeQueryRows + 7, Limits.getQueryRows());
		// + Two rows for LookupParent__c for rollup target for Parent A & Parent B
		System.assertEquals(beforeDMLRows + 2, Limits.getDMLRows());

		// Assert parents are updated
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(3, assertParents.size());
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));
	}

	/**
	 * Test simulation of isDelete
	 */
	private testmethod static void testDeveloperTriggerLikeAPI_SingleSumDeleted()
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
		Integer child1Amount = 42;
		Integer child2Amount = 1;

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
		rollupSummary.CalculationMode__c = RollupSummaries.CalculationMode.Developer.name();
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
			child1.put(aggregateField, child1Amount);
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField, child2Amount);
			children.add(child2);
		}
		insert children;

		// Assert nothing has changed on db
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// delete existing child that have specified aggregateField value leaving a total to rollup of expected
		List<SObject> deletedChildren = Database.query(String.format('select id, {0}, {1} from {2} WHERE {0} = {3}', new List<String>{ aggregateField, relationshipField, childObjectName, String.valueOf(child2Amount) }));
		System.assertEquals(3, deletedChildren.size());
		delete deletedChildren;

		// Assert nothing has changed on db
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeQueryRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		// Call developer 'trigger like' API simulating a delete
		RollupService.rollup(new Map<Id, SObject>(deletedChildren), null, childType);

		// Assert no further limits have been used since the field to aggregate on the detail has not changed
		// + One query on Rollup object
		// + One query on LookupChild__c for rollup
		System.assertEquals(beforeQueries + 2, Limits.getQueries());
		// + One row for Rollup object
		// + Three rows for LookupChild__c
		System.assertEquals(beforeQueryRows + 4, Limits.getQueryRows());
		// + Three rows for LookupParent__c
		System.assertEquals(beforeDMLRows + 3, Limits.getDMLRows());

		// Assert parents are updated
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(3, assertParents.size());
		System.assertEquals(child1Amount, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(child1Amount, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(child1Amount, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));
	}

	/**
	 * Test simulation of isUndelete
	 */
	private testmethod static void testDeveloperTriggerLikeAPI_SingleSumUndeleted()
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
		Integer child1Amount = 40;
		Integer child2Amount = 2;
		Integer expectedAmount = 42;

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
		rollupSummary.CalculationMode__c = RollupSummaries.CalculationMode.Developer.name();
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
			child1.put(aggregateField, child1Amount);
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField, child2Amount);
			children.add(child2);
		}
		insert children;

		// Assert nothing has changed on db
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// delete existing children that have specified aggregateField value
		List<SObject> childrenToDelete = Database.query(String.format('select id, {0}, {1} from {2} WHERE {0} = {3}', new List<String>{ aggregateField, relationshipField, childObjectName, String.valueOf(child2Amount) }));
		System.assertEquals(3, childrenToDelete.size());
		delete childrenToDelete;

		// Assert nothing has changed on db
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// assert remaining children
		List<SObject> remainingChildren = Database.query(String.format('select id, {0}, {1} from {2}', new List<String>{ aggregateField, relationshipField, childObjectName }));
		System.assertEquals(3, remainingChildren.size());

		// retrieve children to undelete
		List<SObject> childrenToUndelete = Database.query(String.format('select id, {0}, {1} from {2} WHERE IsDeleted = true ALL ROWS', new List<String>{ aggregateField, relationshipField, childObjectName }));	
		System.assertEquals(3, childrenToUndelete.size());
		undelete childrenToUndelete;

		// Assert nothing has changed on db
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(null, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeQueryRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		// Call developer 'trigger like' API simulating a undelete
		RollupService.rollup(null, new Map<Id, SObject>(childrenToUndelete), childType);

		// Assert no further limits have been used since the field to aggregate on the detail has not changed
		// + One query on Rollup object
		// + One query on LookupChild__c for rollup
		System.assertEquals(beforeQueries + 2, Limits.getQueries());
		// + One row for Rollup object
		// + Six rows for LookupChild__c
		System.assertEquals(beforeQueryRows + 7, Limits.getQueryRows());
		// + Three rows for LookupParent__c
		System.assertEquals(beforeDMLRows + 3, Limits.getDMLRows());

		// Assert parents are updated
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(3, assertParents.size());
		System.assertEquals(expectedAmount, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(expectedAmount, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(expectedAmount, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));
	}

	/**
	 * https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/631
	 **/
	private testmethod static void testOrInCriteria()
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
		rollupSummary.RelationShipCriteria__c = 'CloseDate < TODAY OR Amount > 100';
		rollupSummary.FieldToAggregate__c = 'CloseDate';
		rollupSummary.AggregateOperation__c = 'Max';
		rollupSummary.AggregateResultField__c = 'SLAExpirationDate__c';
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
		Id accountId = account.Id;
		System.assertEquals(null, Database.query('select SLAExpirationDate__c from Account where Id = :accountId')[0].get(ACCOUNT_SLA_EXPIRATION_DATE));
		
		// Delete Opportunity
		delete opp;
		
		// Assert rollup
		System.assertEquals(null, Database.query('select SLAExpirationDate__c from Account where Id = :accountId')[0].get(ACCOUNT_SLA_EXPIRATION_DATE));								 	
	}

	/**
	 * Create test user
	 **/
	private static User createUser()
	{
		// Can only proceed with test if we have a suitable profile
		List<Profile> testProfiles = [Select Id From Profile where Name='Standard User' limit 1];
		if(testProfiles.size()!=1)
			return null; 		

		// Can only proceed with test if we can successfully insert a test user 
		String testUsername = System.now().format('yyyyMMddhhmmss') + '@testorg.com';
		User testUser = new User(Alias = 'test1', Email='testuser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = testProfiles[0].Id, TimeZoneSidKey='America/Los_Angeles', UserName=testUsername);
		try {
			insert testUser;
			
			// Assign permission sets
			Set<String> psNames = new Set<String> { 'LookupRollupSummariesFull' };
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
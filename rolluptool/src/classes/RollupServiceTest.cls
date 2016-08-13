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
private with sharing class RollupServiceTest 
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

	private testmethod static void testSingleSumRollup()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 600, RollupSummaries.AggregateOperation.Sum, null);	
	}

	private testmethod static void testSingleMaxRollup()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 250, RollupSummaries.AggregateOperation.Max, null);	
	}

	private testmethod static void testSingleMinRollup()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 50, RollupSummaries.AggregateOperation.Min, null);	
	}

	private testmethod static void testSingleAvgRollup()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 150, RollupSummaries.AggregateOperation.Avg, null);	
	}

	private testmethod static void testSingleCountRollup()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 4, RollupSummaries.AggregateOperation.Count, null);	
	}

	private testmethod static void testSingleCountDistinctRollup()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 2, RollupSummaries.AggregateOperation.Count_Distinct, null);
	}

	private testmethod static void testSingleSumRollupConditional()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 500, RollupSummaries.AggregateOperation.Sum, 'Amount > 200');	
	}
	
	private testmethod static void testMultiRollup()
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
		rollupSummaryB.CalculationMode__c = 'Realtime';

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
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS));			
	}
	
	private testmethod static void testMultiRollupSumAndAvg()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 250, 250, 50, 50 };
					
		// Test data for rollup A
		Decimal expectedResultA = 600;
		RollupSummaries.AggregateOperation operationA = RollupSummaries.AggregateOperation.Sum; 
		String conditionA = null;

		// Test data for rollup B
		Decimal expectedResultB = 150;
		RollupSummaries.AggregateOperation operationB = RollupSummaries.AggregateOperation.Avg; 
		String conditionB = null;
		
		// Configure rollup A
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Total Opportunities into Annual Revenue on Account';
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
		rollupSummaryB.Name = 'Avg Opportunities into Annual Revenue on Account';
		rollupSummaryB.ParentObject__c = 'Account';
		rollupSummaryB.ChildObject__c = 'Opportunity';
		rollupSummaryB.RelationShipField__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria__c = conditionB;
		rollupSummaryB.FieldToAggregate__c = 'Amount';
		rollupSummaryB.AggregateOperation__c = operationB.name();
		rollupSummaryB.AggregateResultField__c = 'NumberOfLocations__c';
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = 'Realtime';

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
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS));			
	}

	private testmethod static void testMultiRollupNoConditions()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 10, 20, 30, 40 };
					
		// Test data for rollup A
		Decimal expectedResultA = 160;
		RollupSummaries.AggregateOperation operationA = RollupSummaries.AggregateOperation.Max; 
		String conditionA = null;

		// Test data for rollup B
		Decimal expectedResultB = 4;
		RollupSummaries.AggregateOperation operationB = RollupSummaries.AggregateOperation.Count; 
		String conditionB = null;
		
		// Configure rollup A
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Max Opportunities Amount';
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
		rollupSummaryB.Name = 'Count Opportunities';
		rollupSummaryB.ParentObject__c = 'Account';
		rollupSummaryB.ChildObject__c = 'Opportunity';
		rollupSummaryB.RelationShipField__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria__c = conditionB;
		rollupSummaryB.FieldToAggregate__c = 'Amount';
		rollupSummaryB.AggregateOperation__c = operationB.name();
		rollupSummaryB.AggregateResultField__c = 'NumberOfLocations__c';
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = 'Realtime';

		// Insert rollup definitions
		insert new List<LookupRollupSummary__c> { rollupSummaryB, rollupSummaryA };
		
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		List<Opportunity> opps = new List<Opportunity>(); 
		Integer rollupIdx = 0;
		for(Decimal rollupValue : rollups)
		{
			rollupIdx++;
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = rollupValue * rollupIdx;
			opps.add(opp);			
		}
		insert opps;
		
		// Assert rollup
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);			
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS));			
	}

	private testmethod static void testCountByType()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 10, 20, 30, 40 };

		// Test data for rollup B
		Decimal expectedResultB = 2;
		RollupSummaries.AggregateOperation operationB = RollupSummaries.AggregateOperation.Count; 
		String conditionB = null;

		// Configure rollup B
		LookupRollupSummary__c rollupSummaryB = new LookupRollupSummary__c();
		rollupSummaryB.Name = 'Count Opportunities';
		rollupSummaryB.ParentObject__c = 'Account';
		rollupSummaryB.ChildObject__c = 'Opportunity';
		rollupSummaryB.RelationShipField__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria__c = conditionB;
		rollupSummaryB.FieldToAggregate__c = 'Type';
		rollupSummaryB.AggregateOperation__c = operationB.name();
		rollupSummaryB.AggregateResultField__c = 'NumberOfLocations__c';
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = 'Realtime';

		// Insert rollup definitions
		insert new List<LookupRollupSummary__c> { rollupSummaryB };
		
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		List<Opportunity> opps = new List<Opportunity>(); 
		Integer rollupIdx = 0;
		for(Decimal rollupValue : rollups)
		{
			rollupIdx++;
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.Type = rollupIdx > 2 ? 'New Customer' : null;
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = rollupValue * rollupIdx;
			opps.add(opp);			
		}
		insert opps;
		
		// Assert rollup
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS));			
	}


	private testmethod static void testCountById()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 10, 20, 30, 40 };

		// Test data for rollup B
		Decimal expectedResultB = 4;
		RollupSummaries.AggregateOperation operationB = RollupSummaries.AggregateOperation.Count; 
		String conditionB = null;

		// Configure rollup B
		LookupRollupSummary__c rollupSummaryB = new LookupRollupSummary__c();
		rollupSummaryB.Name = 'Count Opportunities';
		rollupSummaryB.ParentObject__c = 'Account';
		rollupSummaryB.ChildObject__c = 'Opportunity';
		rollupSummaryB.RelationShipField__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria__c = conditionB;
		rollupSummaryB.FieldToAggregate__c = 'Id';
		rollupSummaryB.AggregateOperation__c = operationB.name();
		rollupSummaryB.AggregateResultField__c = 'NumberOfLocations__c';
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = 'Realtime';

		// Insert rollup definitions
		insert new List<LookupRollupSummary__c> { rollupSummaryB };
		
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		List<Opportunity> opps = new List<Opportunity>(); 
		Integer rollupIdx = 0;
		for(Decimal rollupValue : rollups)
		{
			rollupIdx++;
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = rollupValue * rollupIdx;
			opps.add(opp);			
		}
		insert opps;
		
		// Assert rollup
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS));			
	}
	
	
	private testmethod static void testMultiRollupWithTwoParents()
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

		// Test data for rollup C
		Decimal expectedResultC = 600;
		RollupSummaries.AggregateOperation operationC = RollupSummaries.AggregateOperation.Sum; 
		String conditionC = null;
		
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
		rollupSummaryB.Name = 'Total Opportunities into Number Of Locations on Accountt';
		rollupSummaryB.ParentObject__c = 'Account';
		rollupSummaryB.ChildObject__c = 'Opportunity';
		rollupSummaryB.RelationShipField__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria__c = conditionB;
		rollupSummaryB.FieldToAggregate__c = 'CloseDate';
		rollupSummaryB.AggregateOperation__c = operationB.name();
		rollupSummaryB.AggregateResultField__c = 'NumberOfLocations__c';
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = 'Realtime';

		// Configure rollup C
		LookupRollupSummary__c rollupSummaryC = new LookupRollupSummary__c();
		rollupSummaryC.Name = 'Total Opportunities into Num Sent on Campaign';
		rollupSummaryC.ParentObject__c = 'Campaign';
		rollupSummaryC.ChildObject__c = 'Opportunity';
		rollupSummaryC.RelationShipField__c = 'CampaignId';
		rollupSummaryC.RelationShipCriteria__c = conditionC;
		rollupSummaryC.FieldToAggregate__c = 'TotalOpportunityQuantity';
		rollupSummaryC.AggregateOperation__c = operationC.name();
		rollupSummaryC.AggregateResultField__c = 'NumberSent';
		rollupSummaryC.Active__c = true;
		rollupSummaryC.CalculationMode__c = 'Realtime';

		// Insert rollup definitions
		insert new List<LookupRollupSummary__c> { rollupSummaryA, rollupSummaryB, rollupSummaryC };
		
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		SObject camp = Schema.getGlobalDescribe().get('Campaign').newSObject();
		camp.put('Name', 'Test Campaign');
		insert camp; 
		List<Opportunity> opps = new List<Opportunity>(); 
		for(Decimal rollupValue : rollups)
		{
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = rollupValue;
			opp.TotalOpportunityQuantity = rollupValue;
			opp.put('CampaignId', camp.Id);
			opps.add(opp);			
		}
		insert opps;
		
		// Assert rollups
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);			
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS));	
		Id campId = camp.Id;		
		SObject campResult = Database.query('select NumberSent from Campaign where Id = :campId');
		System.assertEquals(expectedResultC, campResult.get('NumberSent'));			
	}
	
	private testmethod static void testMultiRollupWithTwoParentsTenChunks()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 
			1, 2, 3, 4, 5
			,6, 7, 8, 9, 10
			,11, 12, 13, 14, 15
		};
					
		// Test data for rollup A
		RollupSummaries.AggregateOperation operationA = RollupSummaries.AggregateOperation.Sum; 
		String conditionA = null;

		// Test data for rollup B
		RollupSummaries.AggregateOperation operationC = RollupSummaries.AggregateOperation.Sum; 
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
		rollupSummaryB.Name = 'Total Opportunities into Num Sent on Campaign';
		rollupSummaryB.ParentObject__c = 'Campaign';
		rollupSummaryB.ChildObject__c = 'Opportunity';
		rollupSummaryB.RelationShipField__c = 'CampaignId';
		rollupSummaryB.RelationShipCriteria__c = conditionB;
		rollupSummaryB.FieldToAggregate__c = 'TotalOpportunityQuantity';
		rollupSummaryB.AggregateOperation__c = operationC.name();
		rollupSummaryB.AggregateResultField__c = 'NumberSent';
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = 'Realtime';

		// Insert rollup definitions
		insert new List<LookupRollupSummary__c> { rollupSummaryA, rollupSummaryB };
		
		// Test data
		List<SObject> accountList = new List<SObject>();
		List<SObject> campaignList = new List<SObject>();

		List<Opportunity> opps = new List<Opportunity>(); 
		Integer index = 0;
		for(Decimal rollupValue : rollups) {
			// add each Opportunity to a new Account/Campaign to produce chunking
			accountList.add(new Account());
			accountList[index].put('Name', 'Test Account');
			accountList[index].put('AnnualRevenue', 0);
			insert accountList[index];

			campaignList.add( Schema.getGlobalDescribe().get('Campaign').newSObject() );
			campaignList[index].put('Name', 'Test Campaign');
			insert campaignList[index];

			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = accountList[index].Id;
			opp.Amount = rollupValue;
			opp.TotalOpportunityQuantity = rollupValue;
			opp.put('CampaignId', campaignList[index].Id);
			opps.add(opp);

			index++;			
		}
		insert opps;

		// Assert rollups for each Account/Campaign
		index = 0;
		for(Decimal rollupValue : rollups) {
			Id accountId = accountList[index].Id;
			Account accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
			System.assertEquals(rollupValue, accountResult.AnnualRevenue);			
			
			Id campId = campaignList[index].Id;		
			SObject campResult = Database.query('select NumberSent from Campaign where Id = :campId');
			System.assertEquals(rollupValue, campResult.get('NumberSent'));
			
			index++;			
		}
	}
	
	private testmethod static void testSingleRollupWithoutRelation()
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
		opp.AccountId = null; // Note no relationship with an Account
		opp.Amount = 100;
		insert opp;
		
		// Assert rollup
		System.assertEquals(0, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);
		
		// Do an update
		opp.Amount = 101;
		update opp;		
		
		// Assert rollup
		System.assertEquals(0, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);					
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
	}

	private testmethod static void testSingleRollupWithInsertsThenDelete()
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
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		insert new List<LookupRollupSummary__c> { rollupSummary };
		
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;
		{
			Opportunity opp = new Opportunity(); 
			opp.Name = 'Test Opportunity';
			opp.StageName = 'Open';
			opp.CloseDate = System.today();
			opp.AccountId = account.Id;
			opp.Amount = 100;
			insert opp;
		}
		Opportunity opp = new Opportunity(); 
		opp.Name = 'Test Opportunity';
		opp.StageName = 'Open';
		opp.CloseDate = System.today();
		opp.AccountId = account.Id;
		opp.Amount = 100;
		insert opp;
		
		// Assert rollup
		System.assertEquals(200, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);
		
		// Delete Opportunity
		delete opp;
		
		// Assert rollup
		System.assertEquals(100, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);							
	}
	
	private testmethod static void testRollupWithoutChanges()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		// Perform standard test
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 600, RollupSummaries.AggregateOperation.Sum, null);
		List<Opportunity> opps = [select Id from Opportunity];
		
		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		
		// Update opportunities (no changes to the field being aggregted, thus no rollup processng)
		update opps;
		
		// Assert no further limits have been used since the field to aggregate on the detail has not changed
		System.assertEquals(beforeQueries + 1, Limits.getQueries()); // Only tolerate a query for the Lookup definition
		System.assertEquals(beforeRows + 1, Limits.getQueryRows()); // Only tolerate a row for the Lookup definition
	}
	
	private testmethod static void testLimitsConsumedWithConditions()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Disable the Account trigger for this test, its carefully caluculated test actuals are thrown when this is enabled as well
		TestContext.AccountTestTriggerEnabled = false;	

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
		rollupSummaryB.CalculationMode__c = 'Realtime';

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

		// One query on ApexTrigger (in the TestContext.isSupported method)
		// One query on ApexTrigger (validation when inserting rollups)
		// One query on Database.newQueryLocator (validation when insert rollup a)
		// One query on Rollup object
		// One query on Opportunity for rollup a
		// One query on Opportunity for rollup b				
		System.assertEquals(6, Limits.getQueries());	
		
		// One row for ApexTrigger (in the TestContext.isSupported method)		
		// One row for ApexTrigger
		// Two rows for Rollup object
		// Two rows for Opportunity for rollup a
		// Four rows for Opportunity for rollup b
		System.assertEquals(10, Limits.getQueryRows());
				
		// Assert rollup
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);			
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS));
		
		// Modify the opps, but only the Amount, this should result in only the Amount rollup executing
		for(Opportunity opp : opps)
			opp.Amount++;
		update opps;

		// + One query for the Account query above
		// + One query on Rollup object
		// + One query on Opportunity for rollup a
		System.assertEquals(9, Limits.getQueries());	

		// + One query for the Account query above		
		// + Two rows for Rollup object
		// + Two rows for Opportunity for rollup a
		System.assertEquals(15, Limits.getQueryRows());

		// Assert rollup
		accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultA + 2, accountResult.AnnualRevenue);			
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS));								
	}
	
	private testmethod static void testLimitsConsumedWithoutConditions()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
			
		// Disable the Account trigger for this test, its carefully caluculated test actuals are thrown when this is enabled as well
		TestContext.AccountTestTriggerEnabled = false;	

		// Test data
		List<Decimal> rollups = new List<Decimal> { 250, 250, 50, 50 };
					
		// Test data for rollup A
		Decimal expectedResultA = 600;
		RollupSummaries.AggregateOperation operationA = RollupSummaries.AggregateOperation.Sum; 
		String conditionA = null;

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
		rollupSummaryB.CalculationMode__c = 'Realtime';

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

		// One query on ApexTrigger (in the TestContext.isSupported method)
		// One query on ApexTrigger (validation when inserting rollups)
		// One query on Rollup object
		// One query on Opportunity for both rollups
		System.assertEquals(4, Limits.getQueries());	
		
		// One row for ApexTrigger (in the TestContext.isSupported method)
		// One row for ApexTrigger
		// Two rows for Rollup object
		// Four rows for Opportunity for rollup a and b
		System.assertEquals(8, Limits.getQueryRows());
				
		// Assert rollup
		Id accountId = account.Id;
		Account accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);			
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS));
		
		// Modify the opps, but only the Amount, this should result in only the Amount rollup executing
		for(Opportunity opp : opps)
			opp.Amount++;
		update opps;

		// + One query for the Account query above
		// + One query on Rollup object
		// + One query on Opportunity for rollup a
		System.assertEquals(7, Limits.getQueries());	

		// + One query for the Account query above		
		// + Two rows for Rollup object
		// + Four rows for Opportunity for rollup a and 
		System.assertEquals(15, Limits.getQueryRows());

		// Assert rollup
		accountResult = Database.query('select AnnualRevenue, NumberOfLocations__c from Account where Id = :accountId');
		System.assertEquals(expectedResultA + 4, accountResult.AnnualRevenue);			
		System.assertEquals(expectedResultB, accountResult.get(ACCOUNT_NUMBER_OF_LOCATIONS));								
	}
	
	private static void testSingleRollup(List<Decimal> rollups, Decimal expectedResult, RollupSummaries.AggregateOperation operation, String condition)
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
		rollupSummary.RelationShipCriteria__c = condition; // 'Amount > 200';
		rollupSummary.FieldToAggregate__c = 'Amount';
		rollupSummary.AggregateOperation__c = operation.name().replace('_', ' ');
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		insert new List<LookupRollupSummary__c> { rollupSummary };
		
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
		System.assertEquals(expectedResult, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);			
	}	

	private testmethod static void testMultiRollupOfDifferentTypes()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		List<Decimal> rollups = new List<Decimal> { 250, 250, 50, 50 };
					
		// Test data for rollup A
		Decimal expectedResultA = 600;
		RollupSummaries.AggregateOperation operationA = RollupSummaries.AggregateOperation.Sum; 
		String conditionA = null;

		// Test data for rollup B
		String expectedResultB = 'Open,Open,Open,Open';
		RollupSummaries.AggregateOperation operationB = RollupSummaries.AggregateOperation.Concatenate; 
		String conditionB = null;
		
		// Configure rollup A
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Total Opportunities into Annual Revenue on Account';
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
		rollupSummaryB.Name = 'Concatenate Opportunities Stage Name into Description on Account';
		rollupSummaryB.ParentObject__c = 'Account';
		rollupSummaryB.ChildObject__c = 'Opportunity';
		rollupSummaryB.RelationShipField__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria__c = conditionB;
		rollupSummaryB.FieldToAggregate__c = 'StageName';
		rollupSummaryB.AggregateOperation__c = operationB.name();
		rollupSummaryB.AggregateResultField__c = 'Description';
		rollupSummaryB.ConcatenateDelimiter__c = ',';
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = 'Realtime';

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
		Account accountResult = Database.query('select AnnualRevenue, Description from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.AnnualRevenue);			
		System.assertEquals(expectedResultB, accountResult.Description);			
	}

	/**
     * Current default behavior of LREngine is to apply RelationshipField__c in the order by
     * for all contexts.  Beyond that, if no order by is specified, no orderby is applied.
     *
     * This results in all queries having an order by of at least RelationshipField__c even if no orderby
     * is specified in FieldToOrderBy__c.  Ordering by RelationshipField__c does not impact Query based rollup results
     * and is only applied to assist in materializing the results on master records
	 *
	 * Current default behavior of DLRS is to build the context with all rollupsummaries
	 * retrieving them ordered by ParentObject__c (Account) and then by RelationshipField__c (e.g. AccountId)
	 * which results in non-deterministic result when no orderby is specified so a test cannot reliabily be written against
	 * multiple rollups on same parent/child relationship when no orderby is specified.
	 */
	private static Id setupMultiRollupDifferentTypes(Map<String, String> opportunityData, RollupSummaries.AggregateOperation operationA, String orderByFieldA, RollupSummaries.AggregateOperation operationB, String orderByFieldB)
	{
		// Configure rollup A
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'First Opportunity Name into Sic on Account';
		rollupSummaryA.ParentObject__c = 'Account';
		rollupSummaryA.ChildObject__c = 'Opportunity';
		rollupSummaryA.RelationShipField__c = 'AccountId';
		rollupSummaryA.RelationShipCriteria__c = null;
		rollupSummaryA.FieldToAggregate__c = 'StageName';
		rollupSummaryA.FieldToOrderBy__c = orderByFieldA;
		rollupSummaryA.AggregateOperation__c = operationA.name();
		rollupSummaryA.AggregateResultField__c = 'Sic';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = 'Realtime';

		// Configure rollup B
		LookupRollupSummary__c rollupSummaryB = new LookupRollupSummary__c();
		rollupSummaryB.Name = 'Concatenate Opportunities Stage Name into Description on Account';
		rollupSummaryB.ParentObject__c = 'Account';
		rollupSummaryB.ChildObject__c = 'Opportunity';
		rollupSummaryB.RelationShipField__c = 'AccountId';
		rollupSummaryB.RelationShipCriteria__c = null;
		rollupSummaryB.FieldToAggregate__c = 'Name';
		rollupSummaryB.FieldToOrderBy__c = orderByFieldB;
		rollupSummaryB.AggregateOperation__c = operationB.name();
		rollupSummaryB.AggregateResultField__c = 'Description';
		rollupSummaryB.ConcatenateDelimiter__c = ',';
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = 'Realtime';

		// Insert rollup definitions
		insert new List<LookupRollupSummary__c> { rollupSummaryA, rollupSummaryB };
		
		// Test data
		Account account = new Account();
		account.Name = 'Test Account';
		account.AnnualRevenue = 0;
		insert account;

		Date today = System.today();
		List<Opportunity> opps = new List<Opportunity>(); 
		for (String opportunityName :opportunityData.keySet())
		{
			List<String> oppFieldValues = opportunityData.get(opportunityName).split(';');
			Opportunity opp = new Opportunity();
			opp.Name = opportunityName;
			opp.AccountId = account.Id;			
			opp.Amount = Decimal.valueOf(oppFieldValues[0]);
			opp.CloseDate = today.addMonths(Integer.valueOf(oppFieldValues[1]));			
			opp.StageName = oppFieldValues[2];
			opps.add(opp);			
		}
		insert opps;

		return account.Id;		
	}

	/**
	 * Test default behavior with different order by on each rollup
	 */	 
	private testmethod static void testMultiRollupOfDifferentTypesDifferentOrderBy()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		// OpportunityName => Amount;CloseDateAddMonthsToToday;StageName
		Map<String, String> opportunityData = new Map<String, String> {
			'Joe' => '250;0;Open',
			'Steve' => '50;1;Prospecting',
			'Kim' => '100;-2;Closed Won',
			'Charlie' => '225;-1;Needs Analysis'};

		// Test data for rollup A
		String expectedResultA = 'Closed Won';
		RollupSummaries.AggregateOperation operationA = RollupSummaries.AggregateOperation.First;
		String orderByClauseA = Schema.SObjectType.Opportunity.fields.CloseDate.getName();

		// Test data for rollup B
		String expectedResultB = 'Steve,Kim,Charlie,Joe';
		RollupSummaries.AggregateOperation operationB = RollupSummaries.AggregateOperation.Concatenate; 
		String orderByClauseB = Schema.SObjectType.Opportunity.fields.Amount.getName();

		// generate rollups and data
		Id accountId = setupMultiRollupDifferentTypes(opportunityData, operationA, orderByClauseA, operationB, orderByClauseB);

		// Assert rollup
		Account accountResult = Database.query('select Sic, Description from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.Sic);			
		System.assertEquals(expectedResultB, accountResult.Description);			
	}

	/**
	 * Test default behavior with different order by containing multiple fields on each rollup
	 * for Issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/216
	 */	 
	private testmethod static void testMultiRollupOfDifferentTypesDifferentMultipleFieldsOrderBy()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Test data
		// OpportunityName => Amount;CloseDateAddMonthsToToday;StageName
		Map<String, String> opportunityData = new Map<String, String> {
			'Joe' => '100;0;Open',
			'Steve' => '100;-2;Prospecting',
			'Kim' => '100;1;Closed Won',
			'Charlie' => '100;-1;Needs Analysis'};

		// Test data for rollup A
		String expectedResultA = 'Prospecting';
		RollupSummaries.AggregateOperation operationA = RollupSummaries.AggregateOperation.First;
		String orderByClauseA = 'Amount ASC NULLS FIRST, CloseDate ASC NULLS FIRST, Name';

		// Test data for rollup B
		String expectedResultB = 'Kim,Joe,Charlie,Steve';
		RollupSummaries.AggregateOperation operationB = RollupSummaries.AggregateOperation.Concatenate; 
		String orderByClauseB = 'Amount ASC NULLS FIRST, CloseDate DESC NULLS FIRST, Name';

		// generate rollups and data
		Id accountId = setupMultiRollupDifferentTypes(opportunityData, operationA, orderByClauseA, operationB, orderByClauseB);

		// Assert rollup
		Account accountResult = Database.query('select Sic, Description from Account where Id = :accountId');
		System.assertEquals(expectedResultA, accountResult.Sic);			
		System.assertEquals(expectedResultB, accountResult.Description);			
	}	

	private testmethod static void testPicklistRollup()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField = LookupChild__c.Color__c.getDescribe().getName();
		String aggregateResultField = LookupParent__c.Colours__c.getDescribe().getName();

		// Create a picklist rollup
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject__c = parentObjectName;
		rollupSummary.ChildObject__c = childObjectName;
		rollupSummary.RelationShipField__c = relationshipField;
		rollupSummary.FieldToAggregate__c = aggregateField;
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Concatenate.name();
		rollupSummary.AggregateResultField__c = aggregateResultField;
		rollupSummary.ConcatenateDelimiter__c = ';';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
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
			child1.put(aggregateField, 'Red');
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField, 'Yellow');
			children.add(child2);
			if(name.equals('ParentA') || name.equals('ParentB'))
			{
				SObject child3 = childType.newSObject();
				child3.put(relationshipField, parent.Id);
				child3.put(aggregateField, 'Blue');
				children.add(child3);
			}
		}
		insert children;

		// Assert rollups
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals('Red;Yellow;Blue', (String) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals('Red;Yellow;Blue', (String) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals('Red;Yellow', (String) assertParents.get(parentC.id).get(aggregateResultField));
	}


	private testmethod static void testPicklistRollupWithLimits()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField = LookupChild__c.Color__c.getDescribe().getName();
		String aggregateResultField = LookupParent__c.Colours__c.getDescribe().getName();

		// Create a picklist rollup
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject__c = parentObjectName;
		rollupSummary.ChildObject__c = childObjectName;
		rollupSummary.RelationShipField__c = relationshipField;
		rollupSummary.FieldToAggregate__c = aggregateField;
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Concatenate.name();
		rollupSummary.AggregateResultField__c = aggregateResultField;
		rollupSummary.ConcatenateDelimiter__c = ';';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		rollupSummary.RowLimit__c = 2;
		rollupSummary.AggregateAllRows__c = true;
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
			child1.put(aggregateField, 'Red');
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField, 'Yellow');
			children.add(child2);
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put(aggregateField, 'Blue');
			children.add(child3);
		}
		insert children;

		// Assert rollups
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals('Red;Yellow', (String) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals('Red;Yellow', (String) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals('Red;Yellow', (String) assertParents.get(parentC.id).get(aggregateResultField));
	}


	private testmethod static void testLastRollupWithLimits()
	{		
		// Test supported?
		if(!TestContext.isSupported())
			return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField = LookupChild__c.Color__c.getDescribe().getName();
		String aggregateResultField = LookupParent__c.Colours__c.getDescribe().getName();

		// Create a picklist rollup
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject__c = parentObjectName;
		rollupSummary.ChildObject__c = childObjectName;
		rollupSummary.RelationShipField__c = relationshipField;
		rollupSummary.FieldToAggregate__c = aggregateField;
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Last.name();
		rollupSummary.AggregateResultField__c = aggregateResultField;
		rollupSummary.FieldToOrderBy__c	= aggregateField + ' DESC';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		rollupSummary.RowLimit__c = 2;
		rollupSummary.AggregateAllRows__c = true;
		insert rollupSummary;

		// Insert parents
		SObject parent = parentType.newSObject();
		parent.put('Name', 'ParentA');
		List<SObject> parents = new List<SObject> { parent };
		insert parents;

		// Insert children
		List<SObject> children = new List<SObject>();
		String name = (String) parent.get('Name');
		SObject child1 = childType.newSObject();
		child1.put(relationshipField, parent.Id);
		child1.put(aggregateField, '1');
		children.add(child1);
		SObject child2 = childType.newSObject();
		child2.put(relationshipField, parent.Id);
		child2.put(aggregateField, '2');
		children.add(child2);
		SObject child3 = childType.newSObject();
		child3.put(relationshipField, parent.Id);
		child3.put(aggregateField, '3');
		children.add(child3);
		insert children;

		// Assert rollups
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals('2', (String) assertParents.get(parent.id).get(aggregateResultField));
	}

	private testmethod static void testLimitsConsumedWithSingleChildChanged()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		// Disable the Account trigger for this test, its carefully caluculated test actuals are thrown when this is enabled as well
		TestContext.AccountTestTriggerEnabled = false;			

		// Configure rollup
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'Amount';
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		insert rollupSummary;
		
		// Test data
		Integer numAccounts = 3;
		Account parentAccount1 = new Account();
		parentAccount1.Name = 'Parent Account 1';
		parentAccount1.AnnualRevenue = 0;
		Account parentAccount2 = new Account();
		parentAccount2.Name = 'Parent Account 2';
		parentAccount2.AnnualRevenue = 0;
		Account parentAccount3 = new Account();
		parentAccount3.Name = 'Parent Account 3';
		parentAccount3.AnnualRevenue = 0;		
		List<Account> parentAccounts = new List<Account> { parentAccount1, parentAccount2, parentAccount3 };
		insert parentAccounts;

		List<Decimal> oppAmounts = new List<Decimal> { 100, 200, 300, 400 };
		Decimal expectedAnnualRevenue = 1000;
		List<Opportunity> childOpportunities = new List<Opportunity>(); 		
		for (Account acct :parentAccounts)
		{
			for(Decimal oppAmount :oppAmounts)
			{
				Opportunity opp = new Opportunity();
				opp.Name = 'Test Opportunity for ' + acct.Name;
				opp.StageName = 'Open';
				opp.CloseDate = System.today();
				opp.AccountId = acct.Id;
				opp.Amount = oppAmount;
				childOpportunities.add(opp);			
			}			
		}
		insert childOpportunities;

		// assert rollup produced correct values
		System.assertEquals(expectedAnnualRevenue, [select AnnualRevenue from Account where Id = :parentAccount1.Id].AnnualRevenue);
		System.assertEquals(expectedAnnualRevenue, [select AnnualRevenue from Account where Id = :parentAccount2.Id].AnnualRevenue);
		System.assertEquals(expectedAnnualRevenue, [select AnnualRevenue from Account where Id = :parentAccount3.Id].AnnualRevenue);

		// change opportunities on 'Parent Account 1' leaving 'Parent Account 2' opportunities untouched
		List<Opportunity> oppsToModify = [SELECT Id, Name, Amount FROM Opportunity];
		System.assertEquals(oppAmounts.size() * parentAccounts.size(), oppsToModify.size());
		for (Opportunity oppToModify :oppsToModify)
		{
			// modify the CloseDate for all opps
			// this simulates a change to a record on a field that is not involved any rollup
			oppToModify.CloseDate = System.today().addMonths(1);

			// modify Amount on the Opportunity associated to Parent Account 1 and it's current amount is 100
			// this simulates a change to a single record on a field that is involved in a rollup
			if (oppToModify.Name.endsWith(parentAccount1.Name) && oppToModify.Amount == 100)
			{
				oppToModify.Amount++;
			}
		}

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		// Update opportunities (1 record has change to field being aggregated, all others do not have changes to that field)		
		update oppsToModify;

		// Assert limits
		// + One query on Rollup object
		// + One query on Opportunity for rollup	
		System.assertEquals(beforeQueries + 2, Limits.getQueries());	
		
		// + One row for Rollup object
		// + Four rows for Opportunity on Parent 1
		System.assertEquals(beforeRows + 5, Limits.getQueryRows());

		// + Twelve rows for Oppportunities (from the update statement itself)
		// + One row for Parent Account 1 (from lookup processing)
		System.assertEquals(beforeDMLRows + 13, Limits.getDMLRows());

		// assert rollups produced correct result
		System.assertEquals(expectedAnnualRevenue + 1, [select AnnualRevenue from Account where Id = :parentAccount1.Id].AnnualRevenue);
		System.assertEquals(expectedAnnualRevenue, [select AnnualRevenue from Account where Id = :parentAccount2.Id].AnnualRevenue);
		System.assertEquals(expectedAnnualRevenue, [select AnnualRevenue from Account where Id = :parentAccount3.Id].AnnualRevenue);		
	}

	private testmethod static void testLimitsConsumedWithReparentOnly()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField1 = LookupChild__c.LookupParent__c.getDescribe().getName();
		String relationshipField2 = LookupChild__c.LookupParent2__c.getDescribe().getName();
		String aggregateField1 = LookupChild__c.Color__c.getDescribe().getName();
		String aggregateField2 = LookupChild__c.Amount__c.getDescribe().getName();
		String aggregateResultField1 = LookupParent__c.Colours__c.getDescribe().getName();
		String aggregateResultField2 = LookupParent__c.Total2__c.getDescribe().getName();

		// Configure rollups
		LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
		rollupSummaryA.Name = 'Test Rollup';
		rollupSummaryA.ParentObject__c = parentObjectName;
		rollupSummaryA.ChildObject__c = childObjectName;
		rollupSummaryA.RelationShipField__c = relationshipField1;
		rollupSummaryA.FieldToAggregate__c = aggregateField1;
		rollupSummaryA.AggregateOperation__c = RollupSummaries.AggregateOperation.Concatenate.name();
		rollupSummaryA.AggregateResultField__c = aggregateResultField1;
		rollupSummaryA.ConcatenateDelimiter__c = ';';
		rollupSummaryA.Active__c = true;
		rollupSummaryA.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();

		LookupRollupSummary__c rollupSummaryB = new LookupRollupSummary__c();
		rollupSummaryB.Name = 'Test Rollup';
		rollupSummaryB.ParentObject__c = parentObjectName;
		rollupSummaryB.ChildObject__c = childObjectName;
		rollupSummaryB.RelationShipField__c = relationshipField2;
		rollupSummaryB.FieldToAggregate__c = aggregateField2;
		rollupSummaryB.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
		rollupSummaryB.AggregateResultField__c = aggregateResultField2;
		rollupSummaryB.Active__c = true;
		rollupSummaryB.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();		

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
		SObject child1 = childType.newSObject();
		child1.put(relationshipField1, parentA.Id);
		child1.put(relationshipField2, parentB.Id);
		child1.put(aggregateField1, 'Red');
		child1.put(aggregateField2, 20);
		SObject child2 = childType.newSObject();
		child2.put(relationshipField1, parentA.Id);
		child2.put(relationshipField2, parentB.Id);
		child2.put(aggregateField1, 'Yellow');
		child2.put(aggregateField2, 22);		

		List<SObject> children = new List<SObject> { child1, child2 };
		insert children;

		// Assert rollups
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0}, {1} from {2}', new List<String>{ aggregateResultField1, aggregateResultField2, parentObjectName })));
		System.assertEquals('Red;Yellow', (String) assertParents.get(parentA.id).get(aggregateResultField1));
		System.assertEquals(0.0, (Decimal) assertParents.get(parentA.id).get(aggregateResultField2));

		System.assertEquals(null, (String) assertParents.get(parentB.id).get(aggregateResultField1));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField2));

		System.assertEquals(null, (String) assertParents.get(parentC.id).get(aggregateResultField1));
		System.assertEquals(null, (Decimal) assertParents.get(parentC.id).get(aggregateResultField2));

		// change LookupParent2__c from Parent B to Parent C
		child1.put(relationshipField2, parentC.Id);

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		// update including all children but only one child and only one field (LookupParent2__c) on that child has changed
		update children;

		// Assert limits
		// + One query on Rollup object
		// + One query on LookupChild__c for rollup	
		System.assertEquals(beforeQueries + 2, Limits.getQueries());	
		
		// + Two rows for Rollup object
		// + Two rows for LookupChild__c for rollup B (One on Parent B and One on Parent C)
		System.assertEquals(beforeRows + 4, Limits.getQueryRows());

		// + Two rows for LookupChild__c (from the update statement itself)
		// + Two rows for LookupParent__c (One for B and One for C)
		System.assertEquals(beforeDMLRows + 4, Limits.getDMLRows());		

		// Assert rollups
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0}, {1} from {2}', new List<String>{ aggregateResultField1, aggregateResultField2, parentObjectName })));
		System.assertEquals('Red;Yellow', (String) assertParents.get(parentA.id).get(aggregateResultField1));
		System.assertEquals(0.0, (Decimal) assertParents.get(parentA.id).get(aggregateResultField2));

		System.assertEquals(null, (String) assertParents.get(parentB.id).get(aggregateResultField1));
		System.assertEquals(22, (Decimal) assertParents.get(parentB.id).get(aggregateResultField2));

		System.assertEquals(null, (String) assertParents.get(parentC.id).get(aggregateResultField1));
		System.assertEquals(20, (Decimal) assertParents.get(parentC.id).get(aggregateResultField2));
	}	

    private static void assertOrdering(Utilities.Ordering o, String orderBy, Boolean useAsSpecifiedString, String field, Utilities.SortOrder direction, Boolean nullsLast)
    {
        System.assertEquals(orderBy, useAsSpecifiedString ? o.toAsSpecifiedString() : o.toString());
        System.assertEquals(field, o.getField());
        System.assertEquals(direction, o.getDirection());
        System.assertEquals(nullsLast, o.getNullsLast());
    }

    static testMethod void testOrderingStringification()
    {
        Utilities.Ordering o = new Utilities.Ordering('CloseDate');
        assertOrdering(o, 'CloseDate ASC NULLS FIRST', false, 'CloseDate', Utilities.SortOrder.ASCENDING, false);

        o = new Utilities.Ordering('closedate');
        assertOrdering(o, 'closedate ASC NULLS FIRST', false, 'closedate', Utilities.SortOrder.ASCENDING, false);

		o = new Utilities.Ordering('cLoSeDaTe');
        assertOrdering(o, 'cLoSeDaTe ASC NULLS FIRST', false, 'cLoSeDaTe', Utilities.SortOrder.ASCENDING, false);

        o = new Utilities.Ordering('CloseDate', Utilities.SortOrder.ASCENDING);
        assertOrdering(o, 'CloseDate ASC NULLS FIRST', false, 'CloseDate', Utilities.SortOrder.ASCENDING, false);

        o = new Utilities.Ordering('CloseDate', Utilities.SortOrder.DESCENDING);
        assertOrdering(o, 'CloseDate DESC NULLS FIRST', false, 'CloseDate', Utilities.SortOrder.DESCENDING, false);

        o = new Utilities.Ordering('CloseDate', null, false);
        assertOrdering(o, 'CloseDate ASC NULLS FIRST', false, 'CloseDate', Utilities.SortOrder.ASCENDING, false);

        o = new Utilities.Ordering('CloseDate', null, true);
        assertOrdering(o, 'CloseDate ASC NULLS LAST', false,'CloseDate', Utilities.SortOrder.ASCENDING, true);

        o = new Utilities.Ordering('CloseDate', Utilities.SortOrder.ASCENDING, false);
        assertOrdering(o, 'CloseDate ASC NULLS FIRST', false, 'CloseDate', Utilities.SortOrder.ASCENDING, false);        

        o = new Utilities.Ordering('CloseDate', Utilities.SortOrder.ASCENDING, true);
        assertOrdering(o, 'CloseDate ASC NULLS LAST', false, 'CloseDate', Utilities.SortOrder.ASCENDING, true);        

        o = new Utilities.Ordering('CloseDate', Utilities.SortOrder.DESCENDING, false);
        assertOrdering(o, 'CloseDate DESC NULLS FIRST', false, 'CloseDate', Utilities.SortOrder.DESCENDING, false);        

        o = new Utilities.Ordering('CloseDate', Utilities.SortOrder.DESCENDING, true);
        assertOrdering(o, 'CloseDate DESC NULLS LAST', false, 'CloseDate', Utilities.SortOrder.DESCENDING, true);        

         try {
            o = new Utilities.Ordering(null);
            System.assert(false, 'Expecting an exception');
         }
         catch (Utilities.BadOrderingStateException e) {
            System.assertEquals('field cannot be blank.', e.getMessage());
         }        
    }

    static testMethod void testOrderingAsSpecifiedStringification()
    {
        Utilities.Ordering o = new Utilities.Ordering('CloseDate');
        assertOrdering(o, 'CloseDate', true, 'CloseDate', Utilities.SortOrder.ASCENDING, false);

        o = new Utilities.Ordering('closedate');
        assertOrdering(o, 'closedate', true, 'closedate', Utilities.SortOrder.ASCENDING, false);

		o = new Utilities.Ordering('cLoSeDaTe');
        assertOrdering(o, 'cLoSeDaTe', true, 'cLoSeDaTe', Utilities.SortOrder.ASCENDING, false);

        o = new Utilities.Ordering('CloseDate', Utilities.SortOrder.ASCENDING);
        assertOrdering(o, 'CloseDate ASC', true, 'CloseDate', Utilities.SortOrder.ASCENDING, false);

        o = new Utilities.Ordering('CloseDate', Utilities.SortOrder.DESCENDING);
        assertOrdering(o, 'CloseDate DESC', true, 'CloseDate', Utilities.SortOrder.DESCENDING, false);

        o = new Utilities.Ordering('CloseDate', null, false);
        assertOrdering(o, 'CloseDate NULLS FIRST', true, 'CloseDate', Utilities.SortOrder.ASCENDING, false);

        o = new Utilities.Ordering('CloseDate', null, true);
        assertOrdering(o, 'CloseDate NULLS LAST', true, 'CloseDate', Utilities.SortOrder.ASCENDING, true);

        o = new Utilities.Ordering('CloseDate', Utilities.SortOrder.ASCENDING, false);
        assertOrdering(o, 'CloseDate ASC NULLS FIRST', true, 'CloseDate', Utilities.SortOrder.ASCENDING, false);        

        o = new Utilities.Ordering('CloseDate', Utilities.SortOrder.ASCENDING, true);
        assertOrdering(o, 'CloseDate ASC NULLS LAST', true, 'CloseDate', Utilities.SortOrder.ASCENDING, true);        

        o = new Utilities.Ordering('CloseDate', Utilities.SortOrder.DESCENDING, false);
        assertOrdering(o, 'CloseDate DESC NULLS FIRST', true, 'CloseDate', Utilities.SortOrder.DESCENDING, false);        

        o = new Utilities.Ordering('CloseDate', Utilities.SortOrder.DESCENDING, true);
        assertOrdering(o, 'CloseDate DESC NULLS LAST', true, 'CloseDate', Utilities.SortOrder.DESCENDING, true);      
    }  	

	private testmethod static void testSingleQueryBasedRollupUpdateOrderByFieldChanged()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;

		Schema.SObjectType parentType = LookupParent__c.sObjectType;
		Schema.SObjectType childType = LookupChild__c.sObjectType;
		String parentObjectName = parentType.getDescribe().getName();
		String childObjectName = childType.getDescribe().getName();
		String relationshipField = LookupChild__c.LookupParent__c.getDescribe().getName();
		String aggregateField = LookupChild__c.Color__c.getDescribe().getName();
		String aggregateResultField = LookupParent__c.Colours__c.getDescribe().getName();
		String orderByField = LookupChild__c.Amount__c.getDescribe().getName();

		// Configure rollups
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject__c = parentObjectName;
		rollupSummary.ChildObject__c = childObjectName;
		rollupSummary.RelationShipField__c = relationshipField;
		rollupSummary.FieldToAggregate__c = aggregateField;
		rollupSummary.FieldToOrderBy__c = orderByField;
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.First.name();
		rollupSummary.AggregateResultField__c = aggregateResultField;
		rollupSummary.ConcatenateDelimiter__c = ';';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();	

		List<LookupRollupSummary__c> rollups = new List<LookupRollupSummary__c> { rollupSummary };
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
			child1.put(aggregateField, 'Red');
			child1.put(orderByField, 10);
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField, 'Yellow');
			child2.put(orderByField, 20);
			children.add(child2);
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put(aggregateField, 'Blue');
			child3.put(orderByField, 30);
			children.add(child3);
		}
		insert children;		

		// Assert rollups
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals('Red', (String) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals('Red', (String) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals('Red', (String) assertParents.get(parentC.id).get(aggregateResultField));

		// change Amount__c to effect order by result of rollup
		// this change will result in rollup being processed because it is a query based rollup
		// and order by influences rolled up value	
		List<SObject> childrenToUpdate = new List<SObject>();
		for (SObject child :children)
		{
			Decimal orderByFieldValue = (Decimal)child.get(orderByField);
			if (orderByFieldValue == 10) {
				child.put(orderByField, 40);
				childrenToUpdate.add(child);
			}
		}

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		// update children
		update childrenToUpdate;

		// Assert limits
		// + One query on Rollup object
		// + One query on LookupChild__c for rollup	
		System.assertEquals(beforeQueries + 2, Limits.getQueries());	
		
		// + One row for Rollup object
		// + Nine rows for LookupChild__c for rollup
		System.assertEquals(beforeRows + 10, Limits.getQueryRows());

		// + Three rows for LookupChild__c (from the update statement itself)
		// + Three rows for LookupParent__c for the rollup
		System.assertEquals(beforeDMLRows + 6, Limits.getDMLRows());		

		// Assert rollups
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals('Yellow', (String) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals('Yellow', (String) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals('Yellow', (String) assertParents.get(parentC.id).get(aggregateResultField));
	}

	private testmethod static void testSingleAggregateBasedRollupUpdateOrderByFieldChanged()
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
		String orderByField = LookupChild__c.Color__c.getDescribe().getName();

		// Configure rollups
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Test Rollup';
		rollupSummary.ParentObject__c = parentObjectName;
		rollupSummary.ChildObject__c = childObjectName;
		rollupSummary.RelationShipField__c = relationshipField;
		rollupSummary.FieldToAggregate__c = aggregateField;
		rollupSummary.FieldToOrderBy__c = orderByField;
		rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Sum.name();
		rollupSummary.AggregateResultField__c = aggregateResultField;
		rollupSummary.ConcatenateDelimiter__c = ';';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = RollupSummaries.CalculationMode.Realtime.name();	

		List<LookupRollupSummary__c> rollups = new List<LookupRollupSummary__c> { rollupSummary };
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
			child1.put(aggregateField, 10);
			child1.put(orderByField, 'Red');
			children.add(child1);
			SObject child2 = childType.newSObject();
			child2.put(relationshipField, parent.Id);
			child2.put(aggregateField, 20);
			child2.put(orderByField, 'Yellow');
			children.add(child2);
			SObject child3 = childType.newSObject();
			child3.put(relationshipField, parent.Id);
			child3.put(aggregateField, 12);
			child3.put(orderByField, 'Blue');
			children.add(child3);
		}
		insert children;		

		// Assert rollups
		Map<Id, SObject> assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));

		// change Color__c to effect order by result of rollup
		// this change will NOT result in rollup being processed because it is a aggregate based rollup
		// and order by does NOT influence rolled up result
		List<SObject> childrenToUpdate = new List<SObject>();
		for (SObject child :children)
		{
			String orderByFieldValue = (String)child.get(orderByField);
			if (orderByFieldValue == 'Red') {
				child.put(orderByField, 'Green');
				childrenToUpdate.add(child);
			}
		}

		// Sample various limits prior to an update
		Integer beforeQueries = Limits.getQueries();
		Integer beforeRows = Limits.getQueryRows();
		Integer beforeDMLRows = Limits.getDMLRows();

		// update children
		update childrenToUpdate;

		// Assert limits
		// + One query on Rollup object
		// No query on LookupChild__c because the changed Color__c should not be considered a change that would trigger the rollup to be processed
		System.assertEquals(beforeQueries + 1, Limits.getQueries());	
		
		// + One row for Rollup object
		// No rows on LookupChild__c because the changed Color__c should not be considered a change that would trigger the rollup to be processed		
		System.assertEquals(beforeRows + 1, Limits.getQueryRows());

		// + Three rows for LookupChild__c (from the update statement itself)
		// No query on LookupParent__c because the changed Color__c should not be considered a change that would trigger the rollup to be processed		
		System.assertEquals(beforeDMLRows + 3, Limits.getDMLRows());		

		// Assert rollups
		assertParents = new Map<Id, SObject>(Database.query(String.format('select id, {0} from {1}', new List<String>{ aggregateResultField, parentObjectName })));
		System.assertEquals(42, (Decimal) assertParents.get(parentA.id).get(aggregateResultField));
		System.assertEquals(42, (Decimal) assertParents.get(parentB.id).get(aggregateResultField));
		System.assertEquals(42, (Decimal) assertParents.get(parentC.id).get(aggregateResultField));
	}
}
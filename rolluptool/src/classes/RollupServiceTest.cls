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
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
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
	
	private testmethod static void testSingleSumRollupConditional()
	{
		testSingleRollup(new List<Decimal> { 250, 250, 50, 50 }, 500, RollupSummaries.AggregateOperation.Sum, 'Amount > 200');	
	}
	
	private static void testSingleRollup(List<Decimal> rollups, Decimal expectedResult, RollupSummaries.AggregateOperation operation, String condition)
	{			 
		try
		{
			// Configure rollup
			LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
			rollupSummary.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
			rollupSummary.ParentObject__c = 'Account';
			rollupSummary.ChildObject__c = 'Opportunity';
			rollupSummary.RelationShipField__c = 'AccountId';
			rollupSummary.RelationShipCriteria__c = condition; // 'Amount > 200';
			rollupSummary.FieldToAggregate__c = 'Amount';
			rollupSummary.AggregateOperation__c = operation.name();
			rollupSummary.AggregateResultField__c = 'AnnualRevenue';
			rollupSummary.Active__c = true;
			rollupSummary.CalculationMode__c = 'Realtime';
			insert rollupSummary;
		}
		catch (Exception e)
		{
			// Activation errors are tolerated in order to allow tests like this to not fail in subscriber orgs 
			if(((SObjectDomain.FieldError)SObjectDomain.Errors.getAll()[0]).field == LookupRollupSummary__c.Active__c)
				return;	
			throw e;				
		}
		
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
}
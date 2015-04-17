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
private class RollupActionCalculateTest {

	private testmethod static void testCalculateAction()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		// Configure rollup
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.UniqueName__c = 'RollupAnnualRevenue';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'Amount';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Process Builder';
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

		// Call Process Builder action
		RollupActionCalculate.RollupToCalculate rollupToCalc = new RollupActionCalculate.RollupToCalculate();
		rollupToCalc.parentId = account.Id;
		rollupToCalc.rollupSummaryUniqueName = 'RollupAnnualRevenue';
		RollupActionCalculate.calculate(new List<RollupActionCalculate.RollupToCalculate> { rollupToCalc });

		// Assert rollup
		System.assertEquals(100, [select AnnualRevenue from Account where Id = :account.Id].AnnualRevenue);
	}
}
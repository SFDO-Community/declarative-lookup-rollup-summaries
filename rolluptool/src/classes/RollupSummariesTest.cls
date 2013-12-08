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
 * - Neither the name of the Andrew Fawcett, inc nor the names of its contributors 
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
private with sharing class RollupSummariesTest 
{
	private testmethod static void testInsertActiveValidation()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Max Birthday for Contacts related to an Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Contact';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'LastCURequestDate';
		rollupSummary.AggregateOperation__c = 'Count';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Apex Trigger ' + RollupSummaries.makeTriggerName(rollupSummary) + ' has not been deployed. Click Manage Child Trigger and try again.', SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.Active__c, ((SObjectDomain.FieldError)SObjectDomain.Errors.getAll()[0]).field);
	}
	
	private testmethod static void testInsertParentObjectValidation()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'AccountX';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'Amount';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Object does not exist.', SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.ParentObject__c, ((SObjectDomain.FieldError)SObjectDomain.Errors.getAll()[0]).field);
	}
	
	private testmethod static void testInsertChildObjectValidation()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'OpportunityX';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'Amount';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(2, SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Object does not exist.', SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.ChildObject__c, ((SObjectDomain.FieldError)SObjectDomain.Errors.getAll()[0]).field);
		System.assertEquals('Apex Trigger ' + RollupSummaries.makeTriggerName(rollupSummary) + ' has not been deployed. Click Manage Child Trigger and try again.', SObjectDomain.Errors.getAll()[1].message);
		System.assertEquals(LookupRollupSummary__c.Active__c, ((SObjectDomain.FieldError)SObjectDomain.Errors.getAll()[1]).field);
	}
	
	private testmethod static void testInsertRelationshipFieldValidation()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountIdX';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'Amount';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Field does not exist.', SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.RelationShipField__c, ((SObjectDomain.FieldError)SObjectDomain.Errors.getAll()[0]).field);
	}		
	
	private testmethod static void testInsertFieldToAggregateValidation()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'AmountX';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Field does not exist.', SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.FieldToAggregate__c, ((SObjectDomain.FieldError)SObjectDomain.Errors.getAll()[0]).field);
	}		
	
	private testmethod static void testInsertAggregateResultFieldValidation()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'Amount';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenueX';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Field does not exist.', SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.AggregateResultField__c, ((SObjectDomain.FieldError)SObjectDomain.Errors.getAll()[0]).field);
	}	
	
	private testmethod static void testInsertBadFieldTypesStringNotValid()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'Name';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Only Date/DateTime/Time/Numeric fields are allowed', SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(rollupSummary, ((SObjectDomain.ObjectError)SObjectDomain.Errors.getAll()[0]).record);
	}	

	private testmethod static void testInsertBadFieldTypeSumNotValid()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'CloseDate';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'SLAExpirationDate__c';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Sum/Avg doesnt looks like valid for dates ! Still want, then implement the IRollerCoaster yourself and change this class as required.', SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(rollupSummary, ((SObjectDomain.ObjectError)SObjectDomain.Errors.getAll()[0]).record);
	}	
	
	private testmethod static void testTriggerAndTestClassNaming()
	{	
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		System.assertEquals('dlrs_ContactTrigger', RollupSummaries.makeTriggerName(new LookupRollupSummary__c(ChildObject__c = 'Contact')));		
		System.assertEquals('dlrs_ContactTest', RollupSummaries.makeTriggerTestName(new LookupRollupSummary__c(ChildObject__c = 'Contact')));		
		System.assertEquals('dlrs_pse_AssignmentTrigger', RollupSummaries.makeTriggerName(new LookupRollupSummary__c(ChildObject__c = 'pse__Assignment__c')));		
		System.assertEquals('dlrs_pse_AssignmentTest', RollupSummaries.makeTriggerTestName(new LookupRollupSummary__c(ChildObject__c = 'pse__Assignment__c')));		
		System.assertEquals('dlrs_MyCustomObjectTrigger', RollupSummaries.makeTriggerName(new LookupRollupSummary__c(ChildObject__c = 'MyCustomObject__c')));		
		System.assertEquals('dlrs_MyCustomObjectTest', RollupSummaries.makeTriggerTestName(new LookupRollupSummary__c(ChildObject__c = 'MyCustomObject__c')));		
	}
}
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
private class RollupSummariesTest 
{
	// TODO: Write a test to validate the criteria fields validation
	// ...		


	// TODO: Write a test to validate the criteria fields are specified when criteria is specified
	// ...		

	/**
	 * Issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/108
	 **/
	private testmethod static void testBadCriteria()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = 'StageName Equals Won';
		rollupSummary.RelationShipCriteriaFields__c = 'StageName';
		rollupSummary.FieldToAggregate__c = 'Amount';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Relationship Criteria \'StageName Equals Won\' is not valid, see SOQL documentation http://www.salesforce.com/us/developer/docs/soql_sosl/Content/sforce_api_calls_soql_select_conditionexpression.htm, error is \'unexpected token: \'Equals\'\'', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.RelationShipCriteria__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
	}	

	/**
	 * Issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/115
	 **/
	private testmethod static void testInsertBadChildBigName()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Max Birthday for Contacts related to an Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'BadBadBadBadBadBadBadBadBadBad';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'LastCURequestDate';
		rollupSummary.AggregateOperation__c = 'Count';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.RelationshipCriteriaFields__c = 'Bad';
		rollupSummary.Active__c = false;
		rollupSummary.CalculationMode__c = 'Realtime';
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Object does not exist.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.ChildObject__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);		
	}

	/**
	 * Issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/212
	 **/
	private testmethod static void testUpdateBadChildBigName()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		String rsId = fflib_IDGenerator.generate(LookupRollupSummary__c.SObjectType);

		LookupRollupSummary__c oldRollupSummary = new LookupRollupSummary__c(Id=rsId);
		oldRollupSummary.Name = 'Max Birthday for Contacts related to an Account';
		oldRollupSummary.ParentObject__c = 'Account';
		oldRollupSummary.ChildObject__c = 'Contact';
		oldRollupSummary.RelationShipField__c = 'AccountId';
		oldRollupSummary.RelationShipCriteria__c = null;
		oldRollupSummary.FieldToAggregate__c = 'LastCURequestDate';
		oldRollupSummary.AggregateOperation__c = 'Count';
		oldRollupSummary.AggregateResultField__c = 'AnnualRevenue';
		oldRollupSummary.Active__c = false;
		oldRollupSummary.CalculationMode__c = 'Realtime';

		LookupRollupSummary__c newRollupSummary = oldRollupSummary.clone(true, true, true, true);
		newRollupSummary.ChildObject__c = 'BadBadBadBadBadBadBadBadBadBad';
		fflib_SObjectDomain.Test.Database.onUpdate(new LookupRollupSummary__c[] { newRollupSummary }, new Map<Id, SObject> { oldRollupSummary.Id => oldRollupSummary } );

		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Object does not exist.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.ChildObject__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);		
	}

	/**
	 * Issue https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/97
	 **/
	private testmethod static void testInsertBadChildBadCriteria()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Max Birthday for Contacts related to an Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Bad';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'LastCURequestDate';
		rollupSummary.AggregateOperation__c = 'Count';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.RelationshipCriteriaFields__c = 'Bad';
		rollupSummary.Active__c = false;
		rollupSummary.CalculationMode__c = 'Realtime';
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Object does not exist.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.ChildObject__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
	}

	private testmethod static void testInsertActiveValidation()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Last Lead raised for this Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Lead';
		rollupSummary.RelationShipField__c = 'OwnerId';
		rollupSummary.RelationShipCriteria__c = null;
		rollupSummary.FieldToAggregate__c = 'Name';
		rollupSummary.AggregateOperation__c = 'Last';
		rollupSummary.AggregateResultField__c = 'Description';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Apex Trigger ' + RollupSummaries.makeTriggerName(new RollupSummary(rollupSummary)) + ' has not been deployed. Click Manage Child Trigger and try again.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.Active__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
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
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Object does not exist.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.ParentObject__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
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
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Object does not exist.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.ChildObject__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
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
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Field does not exist.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.RelationShipField__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
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
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Field does not exist.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.FieldToAggregate__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
	}		

	private testmethod static void testInsertFieldToOrderByValidation()
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
		rollupSummary.FieldToOrderBy__c = 'AmountX';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Field does not exist.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.FieldToOrderBy__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
	}

	private testmethod static void testInsertFieldToOrderByInvalidClauseValidation()
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
		rollupSummary.FieldToOrderBy__c = 'Amount ASC NULLS BAD';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Invalid order by clause.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.FieldToOrderBy__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
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
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Field does not exist.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.AggregateResultField__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
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
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Only Date/DateTime/Time/Numeric fields are allowed for Sum, Max, Min and Avg', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(rollupSummary, ((fflib_SObjectDomain.ObjectError)fflib_SObjectDomain.Errors.getAll()[0]).record);
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
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Sum/Avg doesnt looks like valid for dates ! Still want, then implement the IRollerCoaster yourself and change this class as required.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(rollupSummary, ((fflib_SObjectDomain.ObjectError)fflib_SObjectDomain.Errors.getAll()[0]).record);
	}	
	
	private testmethod static void testTriggerAndTestClassNaming()
	{	
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		String componentPrefix = Utilities.componentPrefix();
		String objectPrefix = Utilities.objectPrefix();
		System.assertEquals(componentPrefix + 'LeadTrigger', RollupSummaries.makeTriggerName(new RollupSummary(new LookupRollupSummary__c(ChildObject__c = 'Lead'))));
		System.assertEquals(componentPrefix + 'LeadTest', RollupSummaries.makeTriggerTestName(new RollupSummary(new LookupRollupSummary__c(ChildObject__c = 'Lead'))));
		System.assertEquals(componentPrefix + 'pse_AssignmentTrigger', RollupSummaries.makeTriggerName(new RollupSummary(new LookupRollupSummary__c(ChildObject__c = 'pse__Assignment__c'))));
		System.assertEquals(componentPrefix + 'pse_AssignmentTest', RollupSummaries.makeTriggerTestName(new RollupSummary(new LookupRollupSummary__c(ChildObject__c = 'pse__Assignment__c'))));
		System.assertEquals(componentPrefix + 'MyCustomObjectTrigger', RollupSummaries.makeTriggerName(new RollupSummary(new LookupRollupSummary__c(ChildObject__c = 'MyCustomObject__c'))));
		System.assertEquals(componentPrefix + 'MyCustomObjectTest', RollupSummaries.makeTriggerTestName(new RollupSummary(new LookupRollupSummary__c(ChildObject__c = 'MyCustomObject__c'))));

		String dlrsKeyPrefix = DeclarativeLookupRollupSummaries__c.sObjectType.getDescribe().getKeyPrefix();
		// Test RollupSummaries.calculateComponentName directly so we can override the maxComponentNameLength
		System.assertEquals(componentPrefix + componentPrefix + 'DeclarativeLookupRollupSu' + dlrsKeyPrefix + 'Trigger', RollupSummaries.calculateComponentName(objectPrefix + 'DeclarativeLookupRollupSummaries__c', 'Trigger', 35 + 2 * componentPrefix.length()));
		System.assertEquals(componentPrefix + componentPrefix + 'DeclarativeLookupRollupSumma' + dlrsKeyPrefix + 'Test', RollupSummaries.calculateComponentName(objectPrefix + 'DeclarativeLookupRollupSummaries__c', 'Test', 35 + 2 * componentPrefix.length()));
	}
	
	private testmethod static void testRelationshipCriteriaFieldsValidationSingle()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = 'Stage = \'Won\'';
		rollupSummary.RelationShipCriteriaFields__c = 'Stage';
		rollupSummary.FieldToAggregate__c = 'Amount';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(2, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Field Stage does not exist on the child object.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.RelationShipCriteriaFields__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
		System.assertEquals('Relationship Criteria \'Stage = \'Won\'\' is not valid, see SOQL documentation http://www.salesforce.com/us/developer/docs/soql_sosl/Content/sforce_api_calls_soql_select_conditionexpression.htm, error is \'No such column \'Stage\' on entity \'Opportunity\'. If you are attempting to use a custom field, be sure to append the \'__c\' after the custom field name. Please reference your WSDL or the describe call for the appropriate names.\'', fflib_SObjectDomain.Errors.getAll()[1].message);
		System.assertEquals(LookupRollupSummary__c.RelationShipCriteria__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[1]).field);
	}	

	private testmethod static void testRelationshipCriteriaFieldsValidationMulti()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = 'Stage = \'Won\'';
		rollupSummary.RelationShipCriteriaFields__c = 'Stage\r\nAnother';
		rollupSummary.FieldToAggregate__c = 'Amount';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(2, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Fields Stage,Another do not exist on the child object.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.RelationShipCriteriaFields__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
		System.assertEquals('Relationship Criteria \'Stage = \'Won\'\' is not valid, see SOQL documentation http://www.salesforce.com/us/developer/docs/soql_sosl/Content/sforce_api_calls_soql_select_conditionexpression.htm, error is \'No such column \'Stage\' on entity \'Opportunity\'. If you are attempting to use a custom field, be sure to append the \'__c\' after the custom field name. Please reference your WSDL or the describe call for the appropriate names.\'', fflib_SObjectDomain.Errors.getAll()[1].message);
		System.assertEquals(LookupRollupSummary__c.RelationShipCriteria__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[1]).field);		
	}	

	private testmethod static void testRelationshipCriteriaFieldsValidationMultiViaMDT()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
		rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
		rollupSummary.ParentObject__c = 'Account';
		rollupSummary.ChildObject__c = 'Opportunity';
		rollupSummary.RelationShipField__c = 'AccountId';
		rollupSummary.RelationShipCriteria__c = 'Stage = \'Won\'';
		rollupSummary.RelationShipCriteriaFields__c = 'Stage\nAnother';
		rollupSummary.FieldToAggregate__c = 'Amount';
		rollupSummary.AggregateOperation__c = 'Sum';
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(2, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Fields Stage,Another do not exist on the child object.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.RelationShipCriteriaFields__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
		System.assertEquals('Relationship Criteria \'Stage = \'Won\'\' is not valid, see SOQL documentation http://www.salesforce.com/us/developer/docs/soql_sosl/Content/sforce_api_calls_soql_select_conditionexpression.htm, error is \'No such column \'Stage\' on entity \'Opportunity\'. If you are attempting to use a custom field, be sure to append the \'__c\' after the custom field name. Please reference your WSDL or the describe call for the appropriate names.\'', fflib_SObjectDomain.Errors.getAll()[1].message);
		System.assertEquals(LookupRollupSummary__c.RelationShipCriteria__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[1]).field);		
	}	

	private testmethod static void testInsertCountByCloseDateNoErrors()
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
		rollupSummary.AggregateOperation__c = 'Count';
		rollupSummary.AggregateResultField__c = 'SLAExpirationDate__c';
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(0, fflib_SObjectDomain.Errors.getAll().size());	
	}	

	
	private testmethod static void testUseOfRowLimitOnSum()
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
		rollupSummary.AggregateResultField__c = 'AnnualRevenue';
		rollupSummary.RowLimit__c = 10;
		rollupSummary.Active__c = true;
		rollupSummary.CalculationMode__c = 'Realtime';
		fflib_SObjectDomain.Test.Database.onInsert(new LookupRollupSummary__c[] { rollupSummary } );		
		fflib_SObjectDomain.triggerHandler(RollupSummaries.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());	
		System.assertEquals('Row Limit is only supported on Last and Concatentate operators.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(LookupRollupSummary__c.RowLimit__c, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field);
	}	
}
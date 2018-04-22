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
private class RollupScheduledCalculateControllerTest {

	@IsTest
	private static void testCronHelperDefault() {

        // Test supported?
        if(!TestContext.isSupported())
            return;

		// Between Task and Account
		LookupRollupSummary__c rollupSummaryAccount = new LookupRollupSummary__c();
		rollupSummaryAccount.Name = 'Test Rollup';
		rollupSummaryAccount.ParentObject__c = 'Account';
		rollupSummaryAccount.ChildObject__c = 'Task';
		rollupSummaryAccount.RelationShipField__c = 'WhatId';
		rollupSummaryAccount.FieldToAggregate__c = 'Id';
		rollupSummaryAccount.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
		rollupSummaryAccount.AggregateResultField__c = 'AnnualRevenue';
		rollupSummaryAccount.Active__c = true;
		rollupSummaryAccount.CalculationMode__c = 'Scheduled';
		insert rollupSummaryAccount;

		// Test default behaviour
		Test.startTest();
		ApexPages.StandardController standardController = 
			new ApexPages.StandardController(rollupSummaryAccount);
		RollupScheduledCalculateController controller = 
			new RollupScheduledCalculateController(standardController);
		controller.scheduleCalculateJob();
		Test.stopTest();

		// Assert correct Cron job has been inserted
		CronTrigger cronTrigger = [select Id, CronJobDetail.Name, CronExpression from CronTrigger Limit 1][0];
		System.assertEquals('0 0 2 * * ?', cronTrigger.CronExpression);
		System.assertEquals('rollup_'+standardController.getId(), cronTrigger.CronJobDetail.Name);
	}

    @IsTest
    private static void testCronHelperDefaultWithUniqueName() {

        // Test supported?
        if(!TestContext.isSupported())
            return;

        // Between Task and Account
        LookupRollupSummary__c rollupSummaryAccount = new LookupRollupSummary__c();
        rollupSummaryAccount.Name = 'Test Rollup';
        rollupSummaryAccount.UniqueName__c = 'TestRollup';
        rollupSummaryAccount.ParentObject__c = 'Account';
        rollupSummaryAccount.ChildObject__c = 'Task';
        rollupSummaryAccount.RelationShipField__c = 'WhatId';
        rollupSummaryAccount.FieldToAggregate__c = 'Id';
        rollupSummaryAccount.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
        rollupSummaryAccount.AggregateResultField__c = 'AnnualRevenue';
        rollupSummaryAccount.Active__c = true;
        rollupSummaryAccount.CalculationMode__c = 'Scheduled';
        insert rollupSummaryAccount;

        // Test default behaviour
        Test.startTest();
        ApexPages.StandardController standardController = 
            new ApexPages.StandardController(rollupSummaryAccount);
        RollupScheduledCalculateController controller = 
            new RollupScheduledCalculateController(standardController);
        controller.scheduleCalculateJob();
        Test.stopTest();

        // Assert correct Cron job has been inserted
        CronTrigger cronTrigger = [select Id, CronJobDetail.Name, CronExpression from CronTrigger Limit 1][0];
        System.assertEquals('0 0 2 * * ?', cronTrigger.CronExpression);
        System.assertEquals('rollup_TestRollup (' + standardController.getId() + ')', cronTrigger.CronJobDetail.Name);
    }

	@IsTest
	private static void testCronHelperError() {

        // Test supported?
        if(!TestContext.isSupported())
            return;

		// Between Task and Account
		LookupRollupSummary__c rollupSummaryAccount = new LookupRollupSummary__c();
		rollupSummaryAccount.Name = 'Test Rollup';
		rollupSummaryAccount.ParentObject__c = 'Account';
		rollupSummaryAccount.ChildObject__c = 'Task';
		rollupSummaryAccount.RelationShipField__c = 'WhatId';
		rollupSummaryAccount.FieldToAggregate__c = 'Id';
		rollupSummaryAccount.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
		rollupSummaryAccount.AggregateResultField__c = 'AnnualRevenue';
		rollupSummaryAccount.Active__c = true;
		rollupSummaryAccount.CalculationMode__c = 'Scheduled';
		insert rollupSummaryAccount;

		// Test default behaviour
		Test.startTest();
		ApexPages.StandardController standardController = 
			new ApexPages.StandardController(rollupSummaryAccount);
		RollupScheduledCalculateController controller = 
			new RollupScheduledCalculateController(standardController);
		controller.day = new List<String> { '?' };
		controller.scheduleCalculateJob();
		Test.stopTest();

		// Assert nothing has been scheduled and we got an error
		System.assertEquals(0, [select Id, CronJobDetail.Name, CronExpression from CronTrigger].size());
		System.assert(ApexPages.hasMessages(ApexPages.Severity.Error));
		System.assertEquals('\'?\' can only be specified for Day-of-Month -OR- Day-of-Week.', ApexPages.getMessages()[5].getDetail());
	}	


	@IsTest
	private static void testCronHelperCustomised() {

        // Test supported?
        if(!TestContext.isSupported())
            return;

		// Between Task and Account
		LookupRollupSummary__c rollupSummaryAccount = new LookupRollupSummary__c();
		rollupSummaryAccount.Name = 'Test Rollup';
		rollupSummaryAccount.ParentObject__c = 'Account';
		rollupSummaryAccount.ChildObject__c = 'Task';
		rollupSummaryAccount.RelationShipField__c = 'WhatId';
		rollupSummaryAccount.FieldToAggregate__c = 'Id';
		rollupSummaryAccount.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
		rollupSummaryAccount.AggregateResultField__c = 'AnnualRevenue';
		rollupSummaryAccount.Active__c = true;
		rollupSummaryAccount.CalculationMode__c = 'Scheduled';
		insert rollupSummaryAccount;

		// Test default behaviour
		Test.startTest();
		ApexPages.StandardController standardController = 
			new ApexPages.StandardController(rollupSummaryAccount);
		RollupScheduledCalculateController controller = 
			new RollupScheduledCalculateController(standardController);
		controller.hour = new List<String> { '4' };			
		controller.day = new List<String> { '2' };
		controller.scheduleCalculateJob();
		Test.stopTest();

		// Assert correct Cron job has been inserted
		CronTrigger cronTrigger = [select Id, CronJobDetail.Name, CronExpression from CronTrigger Limit 1][0];
		System.assertEquals('0 0 4 2 * ?', cronTrigger.CronExpression);
		System.assertEquals('rollup_'+standardController.getId(), cronTrigger.CronJobDetail.Name);
	}		
}
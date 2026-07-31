@IsTest
private class RollupSchedulingServiceTest {
  @IsTest
  static void buildFullCalculateJobNameWithoutUniqueName() {
    Id rollupId = fflib_IDGenerator.generate(
      LookupRollupSummary__c.SObjectType
    );
    Assert.areEqual(
      'rollup_' + rollupId,
      RollupSchedulingService.buildFullCalculateJobName(rollupId, null)
    );
  }

  @IsTest
  static void buildFullCalculateJobNameWithUniqueName() {
    Id rollupId = fflib_IDGenerator.generate(
      LookupRollupSummary__c.SObjectType
    );
    Assert.areEqual(
      'rollup_MyRollup (' + rollupId + ')',
      RollupSchedulingService.buildFullCalculateJobName(rollupId, 'MyRollup')
    );
  }

  @IsTest
  static void scheduleAndUnscheduleFullCalculate() {
    if (!TestContext.isSupported()) {
      return;
    }

    LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c(
      Name = 'Test Rollup',
      UniqueName__c = 'TestRollup',
      ParentObject__c = 'Account',
      ChildObject__c = 'Task',
      RelationShipField__c = 'WhatId',
      FieldToAggregate__c = 'Id',
      AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name(),
      AggregateResultField__c = 'AnnualRevenue',
      Active__c = true,
      CalculationMode__c = 'Scheduled'
    );
    insert rollupSummary;

    Test.startTest();
    Id jobId = RollupSchedulingService.scheduleFullCalculate(
      rollupSummary.Id,
      '0 0 * * * ? 2100',
      '',
      rollupSummary.UniqueName__c
    );
    Test.stopTest();

    Assert.isNotNull(jobId);
    List<CronTrigger> cronTriggers = RollupSchedulingService.findFullCalculateJobs(
      rollupSummary.Id
    );
    Assert.areEqual(1, cronTriggers.size());
    Assert.areEqual(
      RollupSchedulingService.buildFullCalculateJobName(
        rollupSummary.Id,
        rollupSummary.UniqueName__c
      ),
      cronTriggers[0].CronJobDetail.Name
    );

    RollupSchedulingService.unscheduleFullCalculate(rollupSummary.Id);
    Assert.isTrue(
      RollupSchedulingService.findFullCalculateJobs(rollupSummary.Id).isEmpty()
    );
  }

  @IsTest
  static void scheduleFullCalculateReplacesExistingJob() {
    if (!TestContext.isSupported()) {
      return;
    }

    LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c(
      Name = 'Test Rollup',
      ParentObject__c = 'Account',
      ChildObject__c = 'Task',
      RelationShipField__c = 'WhatId',
      FieldToAggregate__c = 'Id',
      AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name(),
      AggregateResultField__c = 'AnnualRevenue',
      Active__c = true,
      CalculationMode__c = 'Scheduled'
    );
    insert rollupSummary;

    Test.startTest();
    Id firstJobId = RollupSchedulingService.scheduleFullCalculate(
      rollupSummary.Id,
      '0 0 * * * ? 2100',
      '',
      null
    );
    Id secondJobId = RollupSchedulingService.scheduleFullCalculate(
      rollupSummary.Id,
      '0 0 * * * ? 2101',
      '',
      null
    );
    Test.stopTest();

    Assert.areNotEqual(firstJobId, secondJobId);
    Assert.areEqual(
      1,
      RollupSchedulingService.findFullCalculateJobs(rollupSummary.Id).size()
    );

    RollupSchedulingService.unscheduleFullCalculate(rollupSummary.Id);
  }

  @IsTest
  static void unscheduleFullCalculateIsIdempotent() {
    Id rollupId = fflib_IDGenerator.generate(
      LookupRollupSummary__c.SObjectType
    );

    Test.startTest();
    RollupSchedulingService.unscheduleFullCalculate(rollupId);
    Test.stopTest();

    Assert.isTrue(
      RollupSchedulingService.findFullCalculateJobs(rollupId).isEmpty()
    );
  }

  @IsTest
  static void getScheduledFullCalculateJobReturnsNullWhenMissing() {
    Id rollupId = fflib_IDGenerator.generate(
      LookupRollupSummary__c.SObjectType
    );
    Assert.isNull(
      RollupSchedulingService.getScheduledFullCalculateJob(rollupId)
    );
  }

  @IsTest
  static void getNextFullCalculateRunTimeReturnsScheduledValue() {
    List<LookupRollupSummary2__mdt> summaries = [
      SELECT Id, DeveloperName
      FROM LookupRollupSummary2__mdt
      LIMIT 1
    ];
    if (summaries.isEmpty()) {
      return;
    }

    String jobName = RollupSchedulingService.buildFullCalculateJobName(
      summaries[0].Id,
      summaries[0].DeveloperName
    );
    Id jobId;
    try {
      jobId = System.schedule(
        jobName,
        '0 0 * * * ? 2100',
        new RollupCalculateJobSchedulable(summaries[0].Id, '')
      );
    } catch (Exception e) {
      System.debug('Schedule failed: ' + e.getMessage());
    }

    Datetime nextRun = RollupSchedulingService.getNextFullCalculateRunTime(
      summaries[0].Id
    );
    Assert.isNotNull(nextRun);

    if (jobId != null) {
      System.abortJob(jobId);
    }
  }
}

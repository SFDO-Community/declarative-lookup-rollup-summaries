@IsTest
private class RollupCalculateJobSchedulableTest {
  @IsTest
  private static void testScheduleCalculateJobWithFailure() {
    LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
    rollupSummary.ParentObject__c = 'Account';
    rollupSummary.ChildObject__c = 'Contact';
    rollupSummary.RelationShipField__c = 'AccountId';
    rollupSummary.FieldToAggregate__c = 'Id';
    rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
    rollupSummary.AggregateResultField__c = 'Description';
    rollupSummary.Active__c = true;
    rollupSummary.CalculationMode__c = 'Developer';
    insert rollupSummary;

    // mark the job already running so it throws an exception
    RollupService.checkJobAlreadyRunning(rollupSummary.Id, rollupSummary.Name);

    ApexPages.StandardController standardController = new ApexPages.StandardController(
      rollupSummary
    );
    RollupScheduledCalculateController controller = new RollupScheduledCalculateController(
      standardController
    );

    Test.startTest();
    controller.scheduleCalculateJob();
    Test.stopTest();

    List<LookupRollupSummaryLog__c> logs = [
      SELECT Id, ParentId__c, ParentObject__c
      FROM LookupRollupSummaryLog__c
    ];
    Assert.areEqual(1, logs.size());
    Assert.areEqual(
      Schema.LookupRollupSummary__c.getSObjectType().getDescribe().getName(),
      logs[0].ParentObject__c
    );
    Assert.areEqual(rollupSummary.Id, logs[0].ParentId__c);
    Assert.areEqual(1, MessageService.sentEmailList.size());
  }

  private testMethod static void testScheduleCalculateJobPreventEmail() {
    LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
    rollupSummary.ParentObject__c = 'Account';
    rollupSummary.ChildObject__c = 'Contact';
    rollupSummary.RelationShipField__c = 'AccountId';
    rollupSummary.FieldToAggregate__c = 'Id';
    rollupSummary.AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name();
    rollupSummary.AggregateResultField__c = 'Description';
    rollupSummary.Active__c = true;
    rollupSummary.CalculationMode__c = 'Developer';
    insert rollupSummary;

    // mark the job already running so it throws an exception
    RollupService.checkJobAlreadyRunning(rollupSummary.Id, rollupSummary.Name);

    ApexPages.StandardController standardController = new ApexPages.StandardController(
      rollupSummary
    );
    RollupScheduledCalculateController controller = new RollupScheduledCalculateController(
      standardController
    );
    DeclarativeLookupRollupSummaries__c settings = new DeclarativeLookupRollupSummaries__c(
      DisableProblemEmails__c = true
    );
    insert settings;

    Test.startTest();
    controller.scheduleCalculateJob();
    Test.stopTest();

    List<LookupRollupSummaryLog__c> logs = [
      SELECT Id, ParentId__c, ParentObject__c
      FROM LookupRollupSummaryLog__c
    ];
    Assert.areEqual(1, logs.size());
    Assert.areEqual(
      Schema.LookupRollupSummary__c.getSObjectType().getDescribe().getName(),
      logs[0].ParentObject__c
    );
    Assert.areEqual(rollupSummary.Id, logs[0].ParentId__c);
    Assert.areEqual(0, MessageService.sentEmailList.size());
  }
}

@IsTest
private class RollupCalculateJobTest {
  @IsTest
  static void testCrashHandlingWithEmail() {
    String prefix = LookupRollupSummary2__mdt.sObjectType.getDescribe()
      .getKeyPrefix();

    LookupRollupSummary2__mdt rollupCfg = new LookupRollupSummary2__mdt(
      Id = prefix + '00000000000000D',
      Label = 'A Summary',
      DeveloperName = 'A_Summary',
      ParentObject__c = 'A',
      ChildObject__c = 'X',
      RelationshipField__c = '1',
      CalculationMode__c = 'Realtime',
      Active__c = true
    );
    RollupSummariesSelector.setRollupCache(
      false,
      false,
      RollupSummary.toList(new List<LookupRollupSummary2__mdt>{ rollupCfg })
    );

    Account a = new Account(Name = 'Test');
    insert a;

    RollupCalculateJob job = new RollupCalculateJob(rollupCfg.Id);
    Test.startTest();
    job.execute(new MockBatchableContext(), new List<SObject>{ a });
    Test.stopTest();

    List<LookupRollupSummaryLog__c> logs = [
      SELECT Id, ParentId__c, ParentObject__c
      FROM LookupRollupSummaryLog__c
    ];
    Assert.areEqual(1, logs.size());
    Assert.areEqual(
      Schema.LookupRollupSummary2__mdt.getSObjectType().getDescribe().getName(),
      logs[0].ParentObject__c
    );
    Assert.areEqual(rollupCfg.Id, logs[0].ParentId__c);
    Assert.areEqual(1, MessageService.sentEmailList.size());
  }

  @IsTest
  static void testCrashHandlingWithoutEmail() {
    String prefix = LookupRollupSummary2__mdt.sObjectType.getDescribe()
      .getKeyPrefix();

    LookupRollupSummary2__mdt rollupCfg = new LookupRollupSummary2__mdt(
      Id = prefix + '00000000000000D',
      Label = 'A Summary',
      DeveloperName = 'A_Summary',
      ParentObject__c = 'A',
      ChildObject__c = 'X',
      RelationshipField__c = '1',
      CalculationMode__c = 'Realtime',
      Active__c = true
    );
    RollupSummariesSelector.setRollupCache(
      false,
      false,
      RollupSummary.toList(new List<LookupRollupSummary2__mdt>{ rollupCfg })
    );

    Account a = new Account(Name = 'Test');
    insert a;

    DeclarativeLookupRollupSummaries__c settings = new DeclarativeLookupRollupSummaries__c(
      DisableProblemEmails__c = true
    );
    insert settings;

    RollupCalculateJob job = new RollupCalculateJob(rollupCfg.Id);
    Test.startTest();
    job.execute(new MockBatchableContext(), new List<SObject>{ a });
    Test.stopTest();

    List<LookupRollupSummaryLog__c> logs = [
      SELECT Id, ParentId__c, ParentObject__c
      FROM LookupRollupSummaryLog__c
    ];
    Assert.areEqual(1, logs.size());
    Assert.areEqual(
      Schema.LookupRollupSummary2__mdt.getSObjectType().getDescribe().getName(),
      logs[0].ParentObject__c
    );
    Assert.areEqual(rollupCfg.Id, logs[0].ParentId__c);
    Assert.areEqual(0, MessageService.sentEmailList.size());
  }

  @IsTest
  static void testRunBatch() {
    String prefix = LookupRollupSummary2__mdt.sObjectType.getDescribe()
      .getKeyPrefix();

    LookupRollupSummary2__mdt rollupCfg = new LookupRollupSummary2__mdt(
      Id = prefix + '00000000000000D',
      Label = 'A Summary',
      DeveloperName = 'A_Summary',
      ParentObject__c = 'Account',
      ChildObject__c = 'Contact',
      RelationshipField__c = 'AccountId',
      AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name(),
      AggregateResultField__c = 'Description',
      FieldToAggregate__c = 'Id',
      CalculationMode__c = 'Realtime',
      AggregateAllRows__c = false,
      Active__c = true
    );
    RollupSummariesSelector.setRollupCache(
      false,
      false,
      RollupSummary.toList(new List<LookupRollupSummary2__mdt>{ rollupCfg })
    );

    Account a = new Account(Name = 'Test');
    insert a;

    RollupCalculateJob job = new RollupCalculateJob(rollupCfg.Id, 'Id != NULL');
    Test.startTest();
    Database.executeBatch(job);
    Test.stopTest();

    List<LookupRollupSummaryLog__c> logs = [
      SELECT Id, ParentId__c, ParentObject__c, ErrorMessage__c
      FROM LookupRollupSummaryLog__c
    ];
    Assert.areEqual(0, logs.size(), 'Found:' + JSON.serializePretty(logs));
  }

  public class MockBatchableContext implements Database.BatchableContext {
    public Id getJobId() {
      return '100000000000000';
    }

    public Id getChildJobId() {
      return '100000000000000';
    }
  }
}

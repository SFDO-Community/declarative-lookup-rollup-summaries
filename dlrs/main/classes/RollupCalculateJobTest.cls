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

  @IsTest
  static void testRunBatchWithGlobalDisable() {
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

    // globally disable DLRS
    DeclarativeLookupRollupSummaries__c settings = new DeclarativeLookupRollupSummaries__c(
      DisableDLRSGlobally__c = true
    );
    insert settings;

    Account a = new Account(Name = 'Test');
    insert a;

    RollupCalculateJob job = new RollupCalculateJob(rollupCfg.Id, 'Id != NULL');
    Test.startTest();
    String jobId = Database.executeBatch(job);
    Test.stopTest();

    AsyncApexJob asyncJob = [
      SELECT Id, Status, JobItemsProcessed, TotalJobItems
      FROM AsyncApexJob
      WHERE Id = :jobId
    ];

    Assert.areEqual('Completed', asyncJob.Status);
    Assert.areEqual(0, asyncJob.JobItemsProcessed);
    Assert.areEqual(0, asyncJob.TotalJobItems);

    List<LookupRollupSummaryLog__c> logs = [
      SELECT Id, ParentId__c, ParentObject__c, ErrorMessage__c
      FROM LookupRollupSummaryLog__c
    ];
    Assert.areEqual(0, logs.size(), 'Found:' + JSON.serializePretty(logs));
  }

  @IsTest
  static void testRunBatchWithCustPermDisable() {
    // find the profile that has access to the Custom Permission we want to use to check (if it even exists in the system)
    List<SetupEntityAccess> permSetsWithAccess = [
      SELECT ParentId, SetupEntityId
      FROM SetupEntityAccess
      WHERE
        SetupEntityId IN (
          SELECT Id
          FROM CustomPermission
          WHERE DeveloperName = 'DisableDLRS'
        )
        AND Parent.IsOwnedByProfile = FALSE
    ];
    if (permSetsWithAccess.isEmpty()) {
      return; // this org doesn't have the necessary metadata to test this feature
    }

    CustomPermission perm = [
      SELECT DeveloperName, NamespacePrefix
      FROM CustomPermission
      WHERE Id = :permSetsWithAccess[0].SetupEntityId
    ];

    String permName = perm.DeveloperName;
    if (String.isNotBlank(perm.NamespacePrefix)) {
      permName = perm.NamespacePrefix + '__' + perm.DeveloperName;
    }

    // see if the running user already has that permission set
    List<PermissionSetAssignment> assignments = [
      SELECT Id
      FROM PermissionSetAssignment
      WHERE
        AssigneeId = :UserInfo.getUserId()
        AND PermissionSetId = :permSetsWithAccess[0].ParentId
    ];
    if (assignments.isEmpty()) {
      // user doesn't have the necessary perm set to grant it to them.
      System.runAs(new User(Id = UserInfo.getUserId())) {
        insert new PermissionSetAssignment(
          AssigneeId = UserInfo.getUserId(),
          PermissionSetId = permSetsWithAccess[0].ParentId
        );
      }
    }

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
      Active__c = true,
      BypassPermissionApiName__c = permName
    );
    RollupSummariesSelector.setRollupCache(
      false,
      false,
      RollupSummary.toList(new List<LookupRollupSummary2__mdt>{ rollupCfg })
    );

    Account a = new Account(Name = 'Test');
    insert a;

    RollupCalculateJob job = new RollupCalculateJob(rollupCfg.Id, 'Id != NULL');
    String jobId;
    Test.startTest();
    Assert.isTrue(
      Utilities.userHasCustomPermission(permName),
      'Expected user to have ' + permName
    );
    // go into runAs because we need to get the perms recalculated
    jobId = Database.executeBatch(job);
    Test.stopTest();

    AsyncApexJob asyncJob = [
      SELECT Id, Status, JobItemsProcessed, TotalJobItems
      FROM AsyncApexJob
      WHERE Id = :jobId
    ];

    Assert.areEqual('Completed', asyncJob.Status);
    Assert.areEqual(0, asyncJob.JobItemsProcessed);
    Assert.areEqual(0, asyncJob.TotalJobItems);

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

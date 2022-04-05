@IsTest
private class RollupSummaryViewControllerTest {
  @IsTest
  private static void testRollupSummaryEmpty() {
    RollupSummaryViewController controller = new RollupSummaryViewController(
      new List<RollupSummary>(),
      testCronTriggerData()
    );

    Test.startTest();
    List<RollupSummaryViewController.ViewerObject> viewer = controller.getView();
    Test.stopTest();

    System.assertEquals(
      null,
      viewer,
      'Empty RollupSummary should return null value'
    );
  }

  @IsTest
  private static void testRollupSummaryWithData() {
    RollupSummaryViewController controller = new RollupSummaryViewController(
      testRollupData(),
      testCronTriggerData()
    );

    Test.startTest();
    List<RollupSummaryViewController.ViewerObject> viewer = controller.getView();
    Test.stopTest();

    System.assert(
      viewer.size() == 2,
      'Test that viewer list contains two records'
    );
  }
  @IsTest
  private static void testCronTriggerEmpty() {
    RollupSummaryViewController controller = new RollupSummaryViewController(
      testRollupData(),
      new List<CronTrigger>()
    );

    Test.startTest();
    List<RollupSummaryViewController.ViewerObject> viewer = controller.getView();
    Test.stopTest();

    for (RollupSummaryViewController.ViewerObject vo : viewer) {
      System.assertEquals(
        null,
        vo.scheduledTime,
        'scheduledTime should be null'
      );
      System.assertEquals(
        null,
        vo.jobFiredCount,
        'jobFiredCount should be null'
      );
      System.assertEquals(null, vo.apexJobName, 'apexJobName should be null');
    }
  }

  @IsTest
  private static void testCronTriggerWithData() {
    RollupSummaryViewController controller = new RollupSummaryViewController(
      testRollupData(),
      testCronTriggerData()
    );

    Test.startTest();
    List<RollupSummaryViewController.ViewerObject> viewer = controller.getView();
    Test.stopTest();

    for (RollupSummaryViewController.ViewerObject vo : viewer) {
      System.assert(vo.scheduledTime != null, 'scheduledTime should be null');
      System.assert(vo.jobFiredCount != null, 'jobFiredCount should be null');
      System.assert(vo.apexJobName != null, 'apexJobName should be null');
    }
  }

  @IsTest
  private static void testRedirectBadId() {
    RollupSummaryViewController controller = new RollupSummaryViewController();
    Pagereference listView = Page.RollupSummaryView;

    Test.startTest();
    Test.setCurrentPage(listView);
    Pagereference redirectPage = controller.redirect();
    Test.stopTest();

    System.assertEquals(
      redirectPage.getURL(),
      listView.getURL(),
      'If newID is not valid then it reload current page'
    );
  }

  @IsTest
  private static void testRedirectGoodId() {
    RollupSummaryViewController controller = new RollupSummaryViewController();
    String recordID = 'm007A0000000Ua6QAE';

    Pagereference listView = Page.RollupSummaryView;
    listView.getParameters().put('newid', recordID);

    Test.startTest();
    Test.setCurrentPage(listView);
    Pagereference redirectPage = controller.redirect();
    Test.stopTest();

    String namespace = Utilities.namespace();
    String expectedURL =
      '/apex/' +
      (namespace.length() > 0 ? namespace + '__' : '') +
      'managelookuprollupsummaries' +
      '?id=' +
      recordID;
    System.assertEquals(
      expectedURL,
      redirectPage.getURL(),
      'If newID is valid then it puts id in parameters of VF page of managelookuprollupsummaries'
    );
  }

  @IsTest
  private static void testConstructor() {
    RollupSummaryViewController controller = new RollupSummaryViewController();
    controller.getView();

    System.assert(
      Type.forName('RollupSummaryViewController') ==
      RollupSummaryViewController.class,
      'Same class'
    );
  }

  private static List<RollupSummary> testRollupData() {
    LookupRollupSummary2__mdt rollupSummaryA = new LookupRollupSummary2__mdt();
    LookupRollupSummary2__mdt rollupSummaryB = new LookupRollupSummary2__mdt();

    ID id1 = fflib_IDGenerator.generate(LookupRollupSummary2__mdt.SobjectType);
    ID id2 = fflib_IDGenerator.generate(LookupRollupSummary2__mdt.SobjectType);

    rollupSummaryA.id = 'm007A0000000Ua6QAE';
    rollupSummaryA.Label = 'test10';
    rollupSummaryA.DeveloperName = 'test10';
    rollupSummaryA.ParentObject__c = 'Account';
    rollupSummaryA.ChildObject__c = 'Opportunity';
    rollupSummaryA.RelationShipField__c = 'AccountId';
    rollupSummaryA.FieldToAggregate__c = 'Amount';
    rollupSummaryA.AggregateOperation__c = 'Sum';
    rollupSummaryA.AggregateResultField__c = 'AnnualRevenue';
    rollupSummaryA.CalculationMode__c = 'Realtime';
    rollupSummaryA.CalculationSharingMode__c = 'User';
    rollupSummaryA.RowLimit__c = 0;
    rollupSummaryA.AggregateAllRows__c = false;
    rollupSummaryA.Active__c = false;
    rollupSummaryA.TestCodeSeeAllData__c = false;

    rollupSummaryB.id = 'm007A0000000UaBQAU';
    rollupSummaryB.Label = 'test11';
    rollupSummaryB.DeveloperName = 'test11';
    rollupSummaryB.ParentObject__c = 'Account';
    rollupSummaryB.ChildObject__c = 'Opportunity';
    rollupSummaryB.RelationShipField__c = 'AccountId';
    rollupSummaryB.FieldToAggregate__c = 'Amount';
    rollupSummaryB.AggregateOperation__c = 'Sum';
    rollupSummaryB.AggregateResultField__c = 'AnnualRevenue';
    rollupSummaryB.CalculationMode__c = 'Realtime';
    rollupSummaryB.CalculationSharingMode__c = 'User';
    rollupSummaryB.RowLimit__c = 0;
    rollupSummaryB.AggregateAllRows__c = false;
    rollupSummaryB.Active__c = false;
    rollupSummaryB.TestCodeSeeAllData__c = false;

    List<Sobject> sol = new List<Sobject>{ rollupSummaryA, rollupSummaryB };
    List<RollupSummary> rollups = RollupSummary.toList(sol);

    return rollups;
  }

  private static List<CronTrigger> testCronTriggerData() {
    String jsonCronTrigger1 = '{ "CronTrigger" : { "id": "08e7A00000SlgHHQAZ", "TimesTriggered" : 0, "State":"WAITING", "CronJobDetailId": "08a7A00000SlsJYQAZ", "CronExpression": "0 3 2 * * ?", "CronJobDetail" : {"Id":"08a7A00000SlsJYQAZ","Name":"rollup_test10 (m007A0000000Ua6)"} } }';
    String jsonCronTrigger2 = '{ "CronTrigger" : { "id": "08e7A00000SlgBnQAJ", "TimesTriggered" : 0, "State":"WAITING", "CronJobDetailId": "08a7A00000SlsE4QAJ", "CronExpression": "0 3 2 * * ?", "CronJobDetail" : {"Id":"08a7A00000SlsE4QAJ","Name":"rollup_test11 (m007A0000000UaB)"} } }';

    CronTrigger ct1 = (CronTrigger) JSON.deserialize(
      jsonCronTrigger1,
      CronTrigger.class
    );
    CronTrigger ct2 = (CronTrigger) JSON.deserialize(
      jsonCronTrigger2,
      CronTrigger.class
    );

    return new List<CronTrigger>{ ct1, ct2 };
  }
}

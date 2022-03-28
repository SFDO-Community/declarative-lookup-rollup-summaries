@IsTest
private class RollupSummaryViewControllerTest {


  @IsTest
  private static void testRollupSummaryEmpty(){
    RollupSummaryViewController controller = new RollupSummaryViewController(new List<RollupSummary>(), testCronTriggerData());

    Test.startTest();
    List<RollupSummaryViewController.ViewerObject> viewer = controller.getView();
    Test.stopTest();

    System.assertEquals(null, viewer, 'Empty RollupSummary should return null value');
  }

  @IsTest
  private static void testRollupSummaryWithData(){
    RollupSummaryViewController controller = new RollupSummaryViewController(testRollupData(), testCronTriggerData());

    Test.startTest();
    List<RollupSummaryViewController.ViewerObject> viewer = controller.getView();
    Test.stopTest();

    System.assert(viewer.size() == 2, 'Test that viewer list contains two records');

  }
  @IsTest
  private static void testCronTriggerEmpty(){
    RollupSummaryViewController controller = new RollupSummaryViewController(testRollupData(), new List<CronTrigger>());

    Test.startTest();
    List<RollupSummaryViewController.ViewerObject> viewer = controller.getView();
    Test.stopTest();

    for (RollupSummaryViewController.ViewerObject vo : viewer) {
      System.assertEquals(null, vo.scheduledTime, 'scheduledTime should be null');
      System.assertEquals(null, vo.jobFiredCount, 'jobFiredCount should be null');
      System.assertEquals(null, vo.endtime, 'endtime should be null');
      System.assertEquals(null, vo.apexJobName, 'apexJobName should be null');
    }
  }

  @IsTest
  private static void testRedirectBadId(){
    RollupSummaryViewController controller = new RollupSummaryViewController(testRollupData(), new List<CronTrigger>());


    Test.startTest();
    List<RollupSummaryViewController.ViewerObject> viewer = controller.getView();
    Test.stopTest();

    
  }

  private static List<RollupSummary> testRollupData(){

    LookupRollupSummary2__mdt rollupSummaryA = new LookupRollupSummary2__mdt();
    LookupRollupSummary2__mdt rollupSummaryB = new LookupRollupSummary2__mdt();

    ID id1 = fflib_IDGenerator.generate(LookupRollupSummary2__mdt.SobjectType);
    ID id2 = fflib_IDGenerator.generate(LookupRollupSummary2__mdt.SobjectType);

    rollupSummaryA.id = id1;
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

    rollupSummaryB.id = id2;
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

    List<Sobject> sol = new List<Sobject>{rollupSummaryA, rollupSummaryB};
    List<RollupSummary> rollups = RollupSummary.toList(sol);

    return rollups;
  }

  //figure out how to serialize crontrigger for testing
  private static List<CronTrigger> testCronTriggerData(){

    CronTrigger ct1 = new CronTrigger();


    return new List<CronTrigger>();

  }


}

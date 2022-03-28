@IsTest
private class RollupSummaryViewControllerTest {
  @IsTest
  private static void testCoverage() {
    RollupSummaryViewController testController = new RollupSummaryViewController();
    testController.getView();
    //testController.redirect();
  }

  @IsTest
  private static void cronTriggerIsEmptyUnitTest() {

		fflib_ApexMocks mocks = new fflib_ApexMocks();
    CronTriggersSelector mockSelector = (CronTriggersSelector) mocks.mock(CronTriggersSelector.class);

    mocks.startStubbing();
    mocks.when(mockSelector.selectAllScheduledApex()).thenReturn(new List<CronTrigger>{});
    mocks.stopStubbing();

    Test.startTest();
    List<RollupSummaryViewController.ViewerObject> viewer = new RollupSummaryViewController(mockSelector, testRollupData()).getView();
    Test.stopTest();

    for(RollupSummaryViewController.ViewerObject v : viewer){
      System.assertEquals(null , v.scheduledTime, 'If CronTrigger is empty then viewerObject scheduledTime must be null');
      System.assertEquals(null , v.jobFiredCount, 'If CronTrigger is empty then viewerObject jobFiredCount must be null');
      System.assertEquals(null , v.endtime, 'If CronTrigger is empty then viewerObject endtime must be null');
      System.assertEquals(null , v.apexJobName, 'If CronTrigger is empty then viewerObject apexJobName must be null');
      

    }
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

    rollupSummaryA.id = id2;
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

  private List<CronTrigger> testCronTriggerData(){




    return new List<CronTrigger>();

  }


}

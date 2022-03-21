@IsTest
private class RollupSummaryViewControllerTest {
  @IsTest
  private static void testCoverage() {
    RollupSummaryViewController testController = new RollupSummaryViewController();
    testController.getView();
  }



  @IsTest
  private static void redirectWithBadID() {
    //Test if redirect is given bad id value
  }

  @IsTest
  private static void getViewIfRollupSummaryIsEmptyList() {
    //test getview if RollupSummary returns empty list [soql]
  }


  private static void setup() {
    LookupRollupSummary2__mdt rollupSummaryA = new LookupRollupSummary2__mdt();
    LookupRollupSummary2__mdt rollupSummaryB = new LookupRollupSummary2__mdt();
    LookupRollupSummary2__mdt rollupSummaryC = new LookupRollupSummary2__mdt();


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

    rollupSummaryB = rollupSummaryA;
    rollupSummaryB.Label = 'test11';
    rollupSummaryB.developerName = 'test11';

    rollupSummaryc = rollupSummaryA;
    rollupSummaryC.Label = 'test12';
    rollupSummaryC.developerName = 'test12';


    RollupService.create(new List<SObject>{ rollupSummaryA , rollupSummaryB, rollupSummaryC });
  }

  
}

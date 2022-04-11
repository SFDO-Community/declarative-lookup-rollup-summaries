@IsTest
public with sharing class MLRSControllerTest {
  @IsTest
  public static void clone_on_id_parameter() {
    ManageLookupRollupSummariesController controller = new ManageLookupRollupSummariesController();
    Pagereference currentPage = Page.managelookuprollupsummaries;
    currentPage.getParameters().put('id', 'testID');

    Test.startTest();
    Test.setCurrentPage(currentPage);
    Pagereference returnPage = controller.cloneX();
    Test.stopTest();

    String actualID = 'testID';
    String returnID = returnPage.getParameters().get('cloneID');

    System.assertEquals(
      actualID,
      returnID,
      'CloneID parameter should return the testID'
    );
  }

  @IsTest
  public static void clone_on_developerName_parameter() {
    ManageLookupRollupSummariesController controller = new ManageLookupRollupSummariesController();
    Pagereference currentPage = Page.managelookuprollupsummaries;
    currentPage.getParameters().put('developerName', 'testID');

    Test.startTest();
    Test.setCurrentPage(currentPage);
    controller.LookupRollupSummary = testRollupData();
    Pagereference returnPage = controller.cloneX();
    Test.stopTest();

    String actualID = testRollupData().id;
    String expectedID = returnPage.getParameters().get('cloneID');

    System.assertEquals(
      actualID,
      expectedID,
      'CloneID parameter should populate if pagereference parameter is set to DeveloperName="testID"'
    );
  }

  @IsTest
  public static void clone_on_bad_parameter() {
    ManageLookupRollupSummariesController controller = new ManageLookupRollupSummariesController();
    Pagereference currentPage = Page.managelookuprollupsummaries;
    currentPage.getParameters().put('testBadParameter', '1234');

    Test.startTest();
    Test.setCurrentPage(currentPage);
    controller.LookupRollupSummary = testRollupData();
    Pagereference returnPage = controller.cloneX();
    Test.stopTest();

    String actualID = null;
    String expectedID = returnPage.getParameters().get('cloneID');

    System.assertEquals(
      actualID,
      expectedID,
      'Should return Page.managelookuprollupsummaries with null parameters'
    );
  }

  //helper method to generate mdt record
  private static LookupRollupSummary2__mdt testRollupData() {
    LookupRollupSummary2__mdt rollupSummaryA = new LookupRollupSummary2__mdt();

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

    return rollupSummaryA;
  }
}

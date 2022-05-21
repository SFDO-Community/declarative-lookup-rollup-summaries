@IsTest
public with sharing class MLRSControllerTest {
  @IsTest
  public static void get_next_scheduled_time() {
    ManageLookupRollupSummariesController controller = new ManageLookupRollupSummariesController();
    String sch = '20 30 8 10 2 ?';
    String expectedMinuteValue = '30';
    Id scheduleID = 'm007A0000000Ua6QAE';
    System.schedule(scheduleID.to15(), sch, new mockSchedule());
    controller.LookupRollupSummary = testrollupdata();

    Test.startTest();
    String resultDate = controller.getRollupSchedule();
    Test.stopTest();

    system.assertEquals(
      true,
      resultDate.contains(expectedMinuteValue),
      'Should correctly pull schedule from string; string is checked against minute part of configuration to avoid formatting issues and date issue'
    );
  }

  @IsTest
  public static void get_schedule_if_null_id() {
    ManageLookupRollupSummariesController controller = new ManageLookupRollupSummariesController();
    System.assertEquals(
      'No Schedule for Rollup',
      controller.getRollupSchedule(),
      'Null lookupRollupSummary id should return string: No Schedule for Rollup'
    );
  }

  @IsTest
  public static void get_schedule_if_empty_query_return() {
    ManageLookupRollupSummariesController controller = new ManageLookupRollupSummariesController();
    controller.LookupRollupSummary = testRollupData();
    System.assertEquals(
      'No Schedule for Rollup',
      controller.getRollupSchedule(),
      'Empty SOQL query lookupRollupSummary should return string: No Schedule for Rollup'
    );
  }

  @IsTest
  public static void get_schedule_if_caught_error() {
    ManageLookupRollupSummariesController controller = new ManageLookupRollupSummariesController();
    controller.LookupRollupSummary = testRollupData();

    try {
      controller.LookupRollupSummary.id = 'BadRecordID';
      controller.getRollupSchedule();
    } catch (Exception e) {
      System.assertEquals(
        'No Schedule for Rollup',
        controller.getRollupSchedule(),
        'should return string on error: No Schedule for Rollup'
      );
    }
  }

  @IsTest
  public static void has_both_triggers_present() {
    if (!TestContext.isSupported()) {
      return;
    }
    ManageLookupRollupSummariesController controller = new ManageLookupRollupSummariesController();
    controller.LookupRollupSummary = testRollupData();
    controller.hasChildTriggers();
    System.assertEquals(
      'Rollup has child and parent triggers deployed. Can activate',
      Apexpages.getMessages()[0].getSummary(),
      'Should return message indicating parent and child trigger are deployed'
    );
  }

  @IsTest
  public static void has_one_trigger_present() {
    if (!TestContext.isSupported()) {
      return;
    }
    ManageLookupRollupSummariesController controller = new ManageLookupRollupSummariesController();
    LookupRollupSummary2__mdt noParent = testRollupData();
    noParent.ParentObject__c = 'objectNotInDatabase';
    controller.LookupRollupSummary = noParent;
    controller.hasChildTriggers();

    System.assertEquals(
      'Rollup has only one trigger deployed. Cannot activate',
      Apexpages.getMessages()[0].getSummary(),
      'Should return message indicating only one trigger is deployed'
    );
  }

  @IsTest
  public static void has_no_trigger_present() {
    if (!TestContext.isSupported()) {
      return;
    }
    ManageLookupRollupSummariesController controller = new ManageLookupRollupSummariesController();
    LookupRollupSummary2__mdt noTrigger = testRollupData();
    noTrigger.ParentObject__c = 'objectNotInDatabase';
    noTrigger.ChildObject__c = 'ChildObjectNotInDatabase';
    controller.LookupRollupSummary = noTrigger;
    controller.hasChildTriggers();

    System.assertEquals(
      'Rollup does not have any triggers deployed. Cannot activate',
      Apexpages.getMessages()[0].getSummary(),
      'Should return message indicating no triggers are deployed'
    );
  }

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

  public class MockSchedule implements Schedulable {
    public void execute(SchedulableContext sc) {
      String test = 'nothingToExecute';
    }
  }
}

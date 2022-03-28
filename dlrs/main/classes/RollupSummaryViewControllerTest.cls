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
    List<RollupSummaryViewController.ViewerObject> viewer = new RollupSummaryViewController(mockSelector).getView();
    Test.stopTest();

    System.debug(viewer);
    System.assertEquals('' , viewer[0].scheduledTime, 'If CronTrigger is empty then all viewerobject fields associated with CronTrigger should return empty values');




  }
}

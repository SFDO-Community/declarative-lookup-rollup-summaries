@IsTest
private class RollupSummaryViewControllerTest {
  @IsTest
  private static void testCoverage() {
    RollupSummaryViewController testController = new RollupSummaryViewController();
    testController.getView();
  }

  private static void setup(){
    //insert 2 mdt, acct, opp

  }

  @IsTest
  private static void redirectWithBadID(){
      //Test if redirect is given bad id value

  }

  @IsTest
  private static void getViewIfRollupSummaryIsEmptyList(){
      //test getview if RollupSummary returns empty list [soql]

  }

}

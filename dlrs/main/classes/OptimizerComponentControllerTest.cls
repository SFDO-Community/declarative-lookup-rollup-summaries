@IsTest
public class OptimizerComponentControllerTest {
  @IsTest
  static void analyze() {
    LookupRollupSummaryLog__c log1 = new LookupRollupSummaryLog__c(
      ParentId__c = 'abc'
    );
    LookupRollupSummaryLog__c log2 = new LookupRollupSummaryLog__c(
      ParentId__c = 'xyz'
    );
    insert new List<LookupRollupSummaryLog__c>{ log1, log2 };

    OptimizerComponentController.Summary summary = OptimizerComponentController.analyze();
    Assert.areEqual(1, summary.notifications.size());
    Assert.areEqual('info', summary.notifications[0].severity);
  }
}

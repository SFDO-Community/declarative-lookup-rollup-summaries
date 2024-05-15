@IsTest
public with sharing class LookupRollupStatusCheckControllerTest {
  @IsTest
  static void testGetOutstandingScheduledItemsForLookup() {
    List<LookupRollupSummary2__mdt> summaries = [
      SELECT Id
      FROM LookupRollupSummary2__mdt
      LIMIT 1
    ];
    if (summaries.isEmpty()) {
      return;
    }
    Integer val = LookupRollupStatusCheckController.getOutstandingScheduledItemsForLookup(
      summaries[0].Id
    );
    Assert.isTrue(val >= 0, 'Expected a value, even zero');
  }

  @IsTest
  static void testgetScheduledFullCalculates() {
    List<LookupRollupSummary2__mdt> summaries = [
      SELECT Id, DeveloperName
      FROM LookupRollupSummary2__mdt
      LIMIT 1
    ];
    if (summaries.isEmpty()) {
      return;
    }

    // Build the CRON string
    // Kickoff the calculate job for this lookup

    String uniqueNameForJob =
      'rollup_' +
      summaries[0].DeveloperName +
      '(' +
      summaries[0].Id.to15() +
      ')';

    String jobId;
    try {
      jobId = System.schedule(
        uniqueNameForJob,
        '0 0 * * * ? 2100',
        new RollupCalculateJobSchedulable(summaries[0].Id, '')
      );
    } catch (Exception e) {
      System.debug(
        'Failed to schedule, probably because it is already scheduled:' +
        e.getMessage()
      );
    }

    Datetime nextRunDate = LookupRollupStatusCheckController.getScheduledFullCalculates(
      summaries[0].Id
    );
    Assert.isNotNull(nextRunDate);
    if (String.isNotBlank(jobId)) {
      System.abortJob(jobId);
    }
  }

  @IsTest
  static void testHasChildTriggerDeployed() {
    // limited to records in the org, would have to mock things
    LookupRollupStatusCheckController.hasChildTriggerDeployed(null);

    List<LookupRollupSummary2__mdt> rec = [
      SELECT Id
      FROM LookupRollupSummary2__mdt
      WHERE Active__c = TRUE AND CalculationMode__c IN ('Realtime', 'Scheduled')
      LIMIT 1
    ];
    if (rec.size() == 0) {
      return;
    }

    Boolean isDeployed = LookupRollupStatusCheckController.hasChildTriggerDeployed(
      rec[0].Id
    );
    // Assume anything active and needing a trigger should have one
    // this test could fail for silly reasons
    Assert.areEqual(
      true,
      isDeployed,
      'Expected a rollup that requires a trigger to have one, could be false-positive'
    );
  }

  @IsTest
  static void testGetScheduledJobs() {
    Integer startVal = LookupRollupStatusCheckController.getScheduledJobs();
    String jobId = System.schedule(
      'Test Job 2000',
      '0 0 * * * ? 2100',
      new RollupJob()
    );
    Integer endVal = LookupRollupStatusCheckController.getScheduledJobs();
    Assert.areEqual(
      1,
      endVal - startVal,
      'Expected class to report an additional scheduled job'
    );
    System.abortJob(jobId);
  }
}

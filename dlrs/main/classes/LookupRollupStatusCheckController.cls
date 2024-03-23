public with sharing class LookupRollupStatusCheckController {
  /**
   * Get count of scheduled items older than yesterday
   * The assumption is that normal processing should have handled these
   */
  @AuraEnabled(Cacheable=true)
  public static Integer getOutstandingScheduledItemsForLookup(String lookupID) {
    return [
      SELECT COUNT()
      FROM LookupRollupSummaryScheduleItems__c
      WHERE LookupRollupSummary2__c = :lookupID AND LastModifiedDate < YESTERDAY
    ];
  }

  /**
   * Check if the rollup has a Full Calculate schedule
   */
  @AuraEnabled
  public static Datetime getScheduledFullCalculates(String lookupID) {
    try {
      LookupRollupSummary2__mdt LookupRollupSummary = (LookupRollupSummary2__mdt) new RollupSummariesSelector.CustomMetadataSelector(
            false,
            true
          )
          .selectById(new Set<String>{ lookupID })[0]
        .Record;

      if (LookupRollupSummary != null) {
        String id = (LookupRollupSummary.id).to15();
        List<CronTrigger> ct = new CronTriggersSelector()
          .selectScheduledApexById(id);

        if (!ct.isEmpty()) {
          return ct[0].NextFireTime;
        }
      }
    } catch (Exception e) {
    }
    return null;
  }

  /**
   * Check if the rollup has a child/parent trigger
   */
  @AuraEnabled
  public static Boolean hasChildTriggerDeployed(String lookupID) {
    try {
      LookupRollupSummary2__mdt LookupRollupSummary = (LookupRollupSummary2__mdt) new RollupSummariesSelector.CustomMetadataSelector(
            false,
            true
          )
          .selectById(new Set<String>{ lookupID })[0]
        .Record;

      if (LookupRollupSummary != null) {
        RollupSummary rs = new RollupSummary(LookupRollupSummary);
        String childTrigger = RollupSummaries.makeTriggerName(rs);
        ApexTriggersSelector selector = new ApexTriggersSelector();
        Map<String, ApexTrigger> loadTriggers = selector.selectByName(
          new Set<String>{ ChildTrigger }
        );

        return loadTriggers.containsKey(ChildTrigger);
      }
    } catch (Exception e) {
    }
    return false;
  }

  /**
   * Check if cron job is running for DLRS
   */
  @AuraEnabled
  public static Integer getScheduledJobs() {
    return new AsyncApexJobsSelector()
      .getScheduledInstancesOfType(RollupJob.class)
      .size();
  }
}

public with sharing class LookupRollupStatusCheckController {
  // Global variables
  public static LookupRollupSummary2__mdt LookupRollupSummary;
  public static List<RollupSummary> rollups;
  public static Map<id, RollupSummary> mapRollups;

  /**
   * Check if the rollup has any error logs
   */
  @AuraEnabled(Cacheable=true)
  public static Integer getAssociatedErrorLogs(String lookupID) {
    return [
      SELECT COUNT()
      FROM LookupRollupSummaryLog__c
      WHERE ParentId__c = :lookupID
    ];
  }

  /**
   * Check if the rollup has a failed calculate rollup jobs
   */
  @AuraEnabled(Cacheable=true)
  public static Integer getCalculateJobs(String lookupID) {
    return [
      SELECT COUNT()
      FROM LookupRollupCalculateJob__c
      WHERE LookupRollupSummaryId__c = :lookupID
    ];
  }

  /**
   * Check if the rollup has any schedule items
   */
  @AuraEnabled(Cacheable=true)
  public static Integer getSpecificScheduledItems(String lookupID) {
    return [
      SELECT COUNT()
      FROM LookupRollupSummaryScheduleItems__c
      WHERE LookupRollupSummary2__c = :lookupID
    ];
  }

  /**
   * Check if the rollup has a Full Calculate schedule
   */
  @AuraEnabled(Cacheable=true)
  public static Datetime getScheduledFullCalculates(String lookupID) {
    try {
      LookupRollupSummary = (LookupRollupSummary2__mdt) new RollupSummariesSelector.CustomMetadataSelector(
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
  @AuraEnabled(Cacheable=true)
  public static Boolean hasChildTriggerDeployed(String lookupID) {
    try {
      LookupRollupSummary = (LookupRollupSummary2__mdt) new RollupSummariesSelector.CustomMetadataSelector(
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

        if (loadTriggers.size() > 0) {
          return true;
        }
      }
    } catch (Exception e) {
    }
    return false;
  }

  @AuraEnabled(Cacheable=true)
  public static Boolean hasParentTriggerDeployed(String lookupID) {
    try {
      LookupRollupSummary = (LookupRollupSummary2__mdt) new RollupSummariesSelector.CustomMetadataSelector(
            false,
            true
          )
          .selectById(new Set<String>{ lookupID })[0]
        .Record;

      if (LookupRollupSummary != null) {
        RollupSummary rs = new RollupSummary(LookupRollupSummary);
        String parentTrigger = RollupSummaries.makeParentTriggerName(rs);
        ApexTriggersSelector selector = new ApexTriggersSelector();
        Map<String, ApexTrigger> loadTriggers = selector.selectByName(
          new Set<String>{ ParentTrigger }
        );

        if (loadTriggers.size() > 0) {
          return true;
        }
      }
    } catch (Exception e) {
    }
    return false;
  }

  /*
   * Rollup - General Status Information
   *
   */

  /**
   * Check if there are any schedule items in the system
   */
  @AuraEnabled(Cacheable=true)
  public static Integer getAllScheduledItems() {
    return [SELECT COUNT() FROM LookupRollupSummaryScheduleItems__c];
  }

  /**
   * Check if cron job is running for DLRS
   */
  @AuraEnabled(Cacheable=true)
  public static Integer getScheduledJobs() {
    // Check if RollupJob is scheduled
    return [
      SELECT COUNT()
      FROM AsyncApexJob
      WHERE
        JobType = 'ScheduledApex'
        AND status = 'Queued'
        AND ApexClass.name LIKE '%RollupJob%'
    ];
  }
}

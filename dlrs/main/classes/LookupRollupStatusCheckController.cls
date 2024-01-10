public with sharing class LookupRollupStatusCheckController {
  // Global variables
  public static LookupRollupSummary2__mdt LookupRollupSummary;
  public static List<RollupSummary> rollups;
  public static Map<id, RollupSummary> mapRollups;
  public static String test = 'test123';

  /**
   * Check if the rollup has any error logs
   */
  @AuraEnabled(Cacheable=true)
  public static Integer getAssociatedErrorLogs(String lookupID) {
    Integer count = [
      SELECT COUNT()
      FROM LookupRollupSummaryLog__c
      WHERE ParentId__c = :lookupID
    ];

    return count;
  }

  /**
   * Check if the rollup has a failed calculate rollup jobs
   */
  @AuraEnabled(Cacheable=true)
  public static String getCalculateJobs(String lookupID) {
    Integer count = [
      SELECT COUNT()
      FROM LookupRollupCalculateJob__c
      WHERE LookupRollupSummaryId__c = :lookupID
    ];

    if (count == 0) {
      return 'No Calculate Jobs';
    }

    if (count > 0) {
      return 'Calculate Jobs';
    }

    return 'No Calculate Jobs';
  }

  /**
   * Check if the rollup has any schedule items
   */
  @AuraEnabled(Cacheable=true)
  public static Integer getSpecificScheduledItems(String lookupID) {
    Integer count = [
      SELECT COUNT()
      FROM LookupRollupSummaryScheduleItems__c
      WHERE LookupRollupSummary2__c = :lookupID
    ];

    return count;
  }

  /**
   * Check if the rollup has a Full Calculate schedule
   */
  @AuraEnabled(Cacheable=true)
  public static String getScheduledFullCalculates(String lookupID) {
    try {
      LookupRollupSummary = (LookupRollupSummary2__mdt) new RollupSummariesSelector.CustomMetadataSelector(
            false,
            true
          )
          .selectById(new Set<String>{ lookupID })[0]
        .Record;

      if (LookupRollupSummary == null) {
        return 'No Schedule for Rollup';
      }

      String id = (LookupRollupSummary.id).to15();
      List<CronTrigger> ct = new CronTriggersSelector()
        .selectScheduledApexById(id);

      if (ct.isEmpty()) {
        return 'No Schedule for Rollup';
      } else {
        return ct[0].NextFireTime.format();
      }
    } catch (Exception e) {
      return 'No Schedule for Rollup';
    }
  }

  /**
   * Check if the rollup has a child/parent trigger
   */
  @AuraEnabled(Cacheable=true)
  public static String hasChildTriggerDeployed(String lookupID) {
    try {
      LookupRollupSummary = (LookupRollupSummary2__mdt) new RollupSummariesSelector.CustomMetadataSelector(
            false,
            true
          )
          .selectById(new Set<String>{ lookupID })[0]
        .Record;

      if (LookupRollupSummary == null) {
        return 'Not Deployed';
      }

      RollupSummary rs = new RollupSummary(LookupRollupSummary);
      String childTrigger = RollupSummaries.makeTriggerName(rs);
      ApexTriggersSelector selector = new ApexTriggersSelector();
      Map<String, ApexTrigger> loadTriggers = selector.selectByName(
        new Set<String>{ ChildTrigger }
      );

      if (loadTriggers.size() == 0) {
        return 'Not Deployed';
      }

      return 'Deployed';
    } catch (Exception e) {
      return 'Not Deployed';
    }
  }

  @AuraEnabled(Cacheable=true)
  public static String hasParentTriggerDeployed(String lookupID) {
    try {
      LookupRollupSummary = (LookupRollupSummary2__mdt) new RollupSummariesSelector.CustomMetadataSelector(
            false,
            true
          )
          .selectById(new Set<String>{ lookupID })[0]
        .Record;

      if (LookupRollupSummary == null) {
        return 'Not Deployed';
      }

      RollupSummary rs = new RollupSummary(LookupRollupSummary);
      String parentTrigger = RollupSummaries.makeParentTriggerName(rs);
      ApexTriggersSelector selector = new ApexTriggersSelector();
      Map<String, ApexTrigger> loadTriggers = selector.selectByName(
        new Set<String>{ ParentTrigger }
      );

      if (loadTriggers.size() == 0) {
        return 'Not Deployed';
      }

      return 'Deployed';
    } catch (Exception e) {
      return 'Not Deployed';
    }
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
    Integer count = [SELECT COUNT() FROM LookupRollupSummaryScheduleItems__c];

    return count;
  }

  /**
   * Check if cron job is running for DLRS
   */
  @AuraEnabled(Cacheable=true)
  public static String getScheduledJobs() {
    // Check if RollupJob is scheduled
    Integer countScheduled = [
      SELECT COUNT()
      FROM AsyncApexJob
      WHERE
        JobType = 'ScheduledApex'
        AND status = 'Queued'
        AND ApexClass.name LIKE '%RollupJob%'
    ];

    if (countScheduled == 0) {
      return 'RollupJob is not scheduled';
    }

    //No need to warn user if scheduled items are going to be processed
    if (countScheduled > 0) {
      return 'RollupJob is scheduled';
    }

    return 'RollupJob is not scheduled';
  }
}

public with sharing class RollupSchedulingService {
  public class ScheduledJobInfo {
    @AuraEnabled
    public Id cronTriggerId;
    @AuraEnabled
    public String jobName;
    @AuraEnabled
    public Datetime nextFireTime;
  }

  public static String buildFullCalculateJobName(Id rollupId, String uniqueName) {
    String rollupIdString = String.valueOf(rollupId);
    return 'rollup_' +
      (String.isBlank(uniqueName)
        ? rollupIdString
        : uniqueName + ' (' + rollupIdString + ')');
  }

  public static List<CronTrigger> findFullCalculateJobs(Id rollupId) {
    if (rollupId == null) {
      return new List<CronTrigger>();
    }
    return new CronTriggersSelector().selectFullCalculateJobsByRollupId(rollupId);
  }

  public static ScheduledJobInfo getScheduledFullCalculateJob(Id rollupId) {
    List<CronTrigger> cronTriggers = findFullCalculateJobs(rollupId);
    if (cronTriggers.isEmpty()) {
      return null;
    }

    CronTrigger cronTrigger = cronTriggers[0];
    ScheduledJobInfo jobInfo = new ScheduledJobInfo();
    jobInfo.cronTriggerId = cronTrigger.Id;
    jobInfo.jobName = cronTrigger.CronJobDetail.Name;
    jobInfo.nextFireTime = cronTrigger.NextFireTime;
    return jobInfo;
  }

  public static Datetime getNextFullCalculateRunTime(Id rollupId) {
    ScheduledJobInfo jobInfo = getScheduledFullCalculateJob(rollupId);
    return jobInfo == null ? null : jobInfo.nextFireTime;
  }

  public static Id scheduleFullCalculate(
    Id rollupId,
    String cronExpression,
    String masterWhereClause,
    String uniqueName
  ) {
    unscheduleFullCalculate(rollupId);
    return System.schedule(
      buildFullCalculateJobName(rollupId, uniqueName),
      cronExpression,
      new RollupCalculateJobSchedulable(rollupId, masterWhereClause)
    );
  }

  public static void unschedule(Id cronTriggerId) {
    if (cronTriggerId != null) {
      System.abortJob(cronTriggerId);
    }
  }

  public static void unscheduleFullCalculate(Id rollupId) {
    for (CronTrigger cronTrigger : findFullCalculateJobs(rollupId)) {
      System.abortJob(cronTrigger.Id);
    }
  }
}

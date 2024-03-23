public with sharing class SchedulerController {
  @AuraEnabled
  public static List<AsyncApexJob> getCurrentJobs(String className) {
    return new AsyncApexJobsSelector()
      .getScheduledInstancesOfType(
        Type.forName(Utilities.namespace(), className)
      );
  }

  @AuraEnabled
  public static List<AsyncApexJob> getAllScheduledJobs() {
    return new AsyncApexJobsSelector().getAllScheduledJobs();
  }

  @AuraEnabled
  public static void scheduleJobs(String className, List<String> newSchedules) {
    Integer counter = 1;
    Schedulable clsInstance = (Schedulable) Type.forName(className)
      .newInstance();
    List<AsyncApexJob> currentJobs = new AsyncApexJobsSelector()
      .getAllScheduledJobs();
    List<String> existingNames = new List<String>();
    for (AsyncApexJob job : currentJobs) {
      existingNames.add(job.CronTrigger.CronJobDetail.Name);
    }
    for (String cron : newSchedules) {
      String scheduledName = className + ' ' + counter++;
      while (existingNames.contains(scheduledName)) {
        // if this name is taken, get the next
        scheduledName = className + ' ' + counter++;
      }
      System.schedule(scheduledName, cron, clsInstance);
    }
  }

  @AuraEnabled
  public static void cancelScheduledJob(Id jobId) {
    System.abortJob(jobId);
  }
}

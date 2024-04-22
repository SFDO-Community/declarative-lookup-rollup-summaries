@IsTest
public with sharing class SchedulerControllerTest {
  @IsTest
  static void testGetCurrentJobsAndCancelSched() {
    List<AsyncApexJob> jobsStart = SchedulerController.getCurrentJobs(
      'RollupJob'
    );

    String jobId = System.schedule(
      'TestJob112233',
      '0 0 * * * ? 2100',
      new RollupJob()
    );

    List<AsyncApexJob> jobs = SchedulerController.getCurrentJobs('RollupJob');
    Assert.isFalse(
      jobs.isEmpty(),
      'Expected jobs to return at least one result'
    );
    Assert.areEqual(1, jobs.size() - jobsStart.size());

    Boolean includesJob = false;
    for (AsyncApexJob j : jobs) {
      if (j.CronTriggerId == jobId) {
        includesJob = true;
      }
    }
    Assert.isTrue(
      includesJob,
      'Expected jobs list to include temp scheduled job'
    );

    SchedulerController.cancelScheduledJob(jobId);

    jobs = SchedulerController.getCurrentJobs('RollupJob');

    includesJob = false;
    for (AsyncApexJob j : jobs) {
      if (j.CronTriggerId == jobId) {
        includesJob = true;
      }
    }
    Assert.isFalse(includesJob, 'Expected job to be cancelled');

    System.abortJob(jobId);
  }

  @IsTest
  static void testGetAllScheduledJobs() {
    List<AsyncApexJob> jobsStart = SchedulerController.getAllScheduledJobs();
    String jobId = System.schedule(
      'TestJob112233',
      '0 0 * * * ? 2100',
      new RollupJob()
    );

    List<AsyncApexJob> jobsAfter = SchedulerController.getAllScheduledJobs();
    Assert.areEqual(1, jobsAfter.size() - jobsStart.size());
    System.abortJob(jobId);
  }

  @IsTest
  static void testScheduleJobs() {
    List<AsyncApexJob> jobsStart = SchedulerController.getAllScheduledJobs();
    List<Id> jobIds = SchedulerController.scheduleJobs(
      'RollupJob',
      new List<String>{ '0 0 * * * ? 2100', '0 0 * * * ? 2101' }
    );
    jobIds.addAll(
      SchedulerController.scheduleJobs(
        'RollupJob',
        new List<String>{ '0 0 * * * ? 2100', '0 0 * * * ? 2101' }
      )
    );
    List<AsyncApexJob> jobsAfter = SchedulerController.getAllScheduledJobs();

    Assert.areEqual(4, jobsAfter.size() - jobsStart.size());

    for (Id jId : jobIds) {
      System.abortJob(jId);
    }
  }
}

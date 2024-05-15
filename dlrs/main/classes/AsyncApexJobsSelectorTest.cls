@isTest
private class AsyncApexJobsSelectorTest {
  @isTest
  static void testGetScheduledInstancesOfType() {
    List<AsyncApexJob> jobs = new AsyncApexJobsSelector().getAllScheduledJobs();
    Integer jobCountStart = jobs.size();
    if (jobCountStart > 98) {
      System.debug('not enough capacity to schedule new, exiting early');
      return;
    }

    // we don't get database isolation here
    // ensure tests here don't break if extra jobs are scheduled
    String jobId1 = System.schedule(
      'TestJob112233',
      '0 0 * * * ? 2100',
      new RollupJob()
    );
    String jobId2 = System.schedule(
      'TestJob998877',
      '0 0 * * * ? 2101',
      new RollupJob()
    );

    jobs = new AsyncApexJobsSelector().getAllScheduledJobs();
    Assert.areEqual(
      2,
      jobs.size() - jobCountStart,
      'Expected total scheduled jobs to have increased by two'
    );

    jobs = new List<AsyncApexJob>(
      new AsyncApexJobsSelector().getScheduledInstancesOfType(RollupJob.class)
    );

    Assert.isTrue(
      jobs.size() >= 2,
      'Exepcted at least 2 jobs, found ' + jobs.size()
    );

    Boolean hasJob1 = false;
    Boolean hasJob2 = false;

    for (AsyncApexJob job : jobs) {
      if (job.CronTriggerId == (Id) jobId1) {
        hasJob1 = true;
      }
      if (job.CronTriggerId == (Id) jobId2) {
        hasJob2 = true;
      }
    }

    Assert.isTrue(
      hasJob1,
      'Expected ' + jobId1 + ' to be included in jobs list:' + jobs
    );
    Assert.isTrue(
      hasJob2,
      'Expected ' + jobId2 + ' to be included in jobs list:' + jobs
    );

    // clear jobs
    System.abortJob(jobId1);
    System.abortJob(jobId2);

    Assert.isTrue(jobs.size() >= 2, 'Expected at least two jobs scheduled');
  }
}

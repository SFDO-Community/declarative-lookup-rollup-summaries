public with sharing class RollupCalculateJobSchedulable implements Schedulable {
  private String rollupRecordId;
  private String masterWhereClause;

  public RollupCalculateJobSchedulable(
    String rollupRecordId,
    String masterWhereClause
  ) {
    this.rollupRecordId = rollupRecordId;
    this.masterWhereClause = masterWhereClause;
  }

  public void execute(SchedulableContext sc) {
    try {
      // Enqueue the job to recalcualte the given rollup parent records
      RollupService.runJobToCalculate(rollupRecordId, masterWhereClause);
    } catch (Exception e) {
      LookupRollupSummaryLog__c logEntry = new LookupRollupSummaryLog__c();
      List<RollupSummary> rollup = new RollupSummariesSelector()
        .selectById(new Set<String>{ rollupRecordId });
      logEntry.ParentId__c = rollupRecordId;
      if (!rollup.isEmpty()) {
        // Log the failure updating the master record for review
        logEntry.ParentObject__c = rollup[0]
          .Record.getSObjectType()
          .getDescribe()
          .getName();
      }

      logEntry.ErrorMessage__c =
        e.getMessage() +
        ' : ' +
        e.getStackTraceString();

      upsert logEntry ParentId__c;

      if (
        DeclarativeLookupRollupSummaries__c.getInstance()
          .DisableProblemEmails__c
      ) {
        // if emails are disabled then bail out
        return;
      }

      // Resolve the name of this job
      Id triggerId = sc.getTriggerId();
      Map<Id, String> jobNameByTriggerId = new CronJobDetailsSelector()
        .selectJobNameByCronTriggerId(new Set<Id>{ triggerId });
      String jobRef = jobNameByTriggerId.size() == 0
        ? 'id ' + triggerId
        : 'named ' + jobNameByTriggerId.get(triggerId) + ' (' + triggerId + ')';

      // Retrieve organization info to put in the email
      Organization org = [SELECT Id, Name FROM Organization];

      //Getting rollup name
      String rollupName = rollup.isEmpty() ? '' : rollup[0].Name;

      // Errors are emailed to the user that scheduled this job
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setTargetObjectId(UserInfo.getUserId());
      mail.setSaveAsActivity(false); // required when sending to user
      mail.setSubject(
        String.format(
          'Apex scheduled job "{0}" failed to run rolllup',
          new List<String>{ jobRef }
        )
      );
      mail.setPlainTextBody(
        String.format(
          'Failed Job Information\n' +
            '--------------------------------------------------------------------------------\n' +
            'Lookup ID: {0}\n' +
            'Lookup Name: {1}\n' +
            'Apex Scheduled Job Name: {2}\n' +
            'Trigger ID: \n\n' +
            'Error Message: {3}\n\n' +
            'Organization Name: {4}\n' +
            'Organization ID: {5}\n\n' +
            'Review the error, rollup definition and/or delete the Apex Scheduled job under Setup.\n' +
            'Check if the rollup still exists via the Manage Rollup Summaries and/or Lookup Rollup Summaries tabs.\n' +
            '--------------------------------------------------------------------------------',
          new List<String>{
            rollupRecordId,
            rollupName,
            jobRef,
            e.getMessage(),
            org.Name,
            org.Id
          }
        )
      );
      MessageService.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
  }
}

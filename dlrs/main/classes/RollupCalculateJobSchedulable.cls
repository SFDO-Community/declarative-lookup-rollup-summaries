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

      //Getting rollup name and unique name
      String rollupName = rollup.isEmpty() ? '' : rollup[0].Name;
      String rollupuniqueName = rollup.isEmpty() ? '' : rollup[0].UniqueName;

      // Errors are emailed to the user that scheduled this job
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setTargetObjectId(UserInfo.getUserId());
      mail.setSaveAsActivity(false); // required when sending to user
      mail.setSubject(
        String.format(
          'Apex scheduled job "{0}" failed to update rollups in "{1} (ID: {2})"',
          new List<String>{ jobRef, org.Name, org.Id }
        )
      );
      mail.setPlainTextBody(
        String.format(
          'Failed Job Information\n\n' +
            'Review the error, rollup definition and/or delete the Apex Scheduled job under Setup.\n' +
            'Check if the rollup still exists via the Manage Rollup Summaries and/or Lookup Rollup Summaries tabs.\n\n' +
            '--------------------------------------------------------------------------------\n' +
            'Organization Name: {0}\n' +
            'Organization ID: {1}\n\n' +
            'Lookup: {2} (Unique Name: {3}, ID: {4})\n' +
            'Apex Scheduled Job Name: {5}\n' +
            'Trigger ID: {6} \n\n' +
            'Error Message: {7}\n' +
            '--------------------------------------------------------------------------------',
          new List<String>{
            org.Name,
            org.Id,
            rollupName,
            rollupuniqueName,
            rollupRecordId,
            jobRef,
            triggerId,
            e.getMessage()
          }
        )
      );
      MessageService.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
  }
}

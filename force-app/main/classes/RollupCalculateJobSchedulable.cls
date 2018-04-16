public with sharing class RollupCalculateJobSchedulable implements Schedulable {
    private String rollupRecordId;
    private String masterWhereClause;

    public RollupCalculateJobSchedulable(String rollupRecordId, String masterWhereClause) {
    	this.rollupRecordId = rollupRecordId;
    	this.masterWhereClause = masterWhereClause;
    }

    public void execute(SchedulableContext sc) {
        try {
            // Enqueue the job to recalcualte the given rollup parent records
            RollupService.runJobToCalculate(rollupRecordId, masterWhereClause);
        } catch (Exception e) {
            // Resolve the name of this job
            Id triggerId = sc.getTriggerId();
            Map<Id, String> jobNameByTriggerId = new CronJobDetailsSelector().selectJobNameByCronTriggerId(new Set<Id> { triggerId });
            String jobRef = 
                jobNameByTriggerId.size()==0 ? 
                    'id ' + triggerId : 'named ' + jobNameByTriggerId.get(triggerId) + ' (' + triggerId + ')';
            // Errors are emailed to the user that scheduled this job
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { UserInfo.getUserId() });
            mail.setSubject(
                String.format('Apex scheduled job {0} failed to run rolllup', 
                    new String[] { jobRef }));
            mail.setPlainTextBody
                (String.format(
                    'Error: {0} ' + 
                    'Review the error, rollup definition and/or delete the Apex Scheduled job under Setup. ' +
                    'Check if the rollup still exists via the Manage Rollup Summaries and/or Lookup Rollup Summaries tabs. ',
                    new String[] { e.getMessage() } ));
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}
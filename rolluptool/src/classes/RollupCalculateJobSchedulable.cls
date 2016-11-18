public with sharing class RollupCalculateJobSchedulable implements Schedulable {
    private String rollupRecordId;
    private String masterWhereClause;

    public RollupCalculateJobSchedulable(String rollupRecordId, String masterWhereClause) {
    	this.rollupRecordId = rollupRecordId;
    	this.masterWhereClause = masterWhereClause;
    }

    public void execute(SchedulableContext sc) {
        RollupService.runJobToCalculate(rollupRecordId, masterWhereClause);
    }
}
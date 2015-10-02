public with sharing class RollupCalculateJobSchedulable implements Schedulable {
    private String rollupRecordId;

    public RollupCalculateJobSchedulable(String rollupRecordId) {
    	this.rollupRecordId = rollupRecordId;
    }

    public void execute(SchedulableContext sc) {
        RollupService.runJobToCalculate(rollupRecordId, null);
    }
}
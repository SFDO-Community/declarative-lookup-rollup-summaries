public with sharing class LookupRollupStatusCheckController {

    // Global variables
    public static LookupRollupSummary2__mdt LookupRollupSummary;
    public static List<RollupSummary> rollups;
    public static Map<id, RollupSummary> mapRollups;

    /*
    * Rollup - Specific Status Information
    *
    */

    // Check if Parent and child triggers have been deployed
    @AuraEnabled(Cacheable=true)
    public static void getTriggerStatus(){

    }

    // Query for all full calculate rollups
    @AuraEnabled(Cacheable=true)
    public static void getScheduledFullCalculates(){

    }

    // Check if any DLRS error logs have the rollup id
    @AuraEnabled(Cacheable=true)
    public static void getAssociatedErrorLogs(){

    }

    // Check if any schedule items have the rollup ID 
    @AuraEnabled(Cacheable=true)
    public static Integer getSpecificScheduledItems(){
        String x = '123';
        Integer count =  [SELECT COUNT() FROM LookupRollupSummaryScheduleItems__c WHERE LookupRollupSummary2__c = :x];
        
        return count;
    }

    /*
    * Rollup - General Status Information
    *
    */

    // Grab a rollup 
    @AuraEnabled(Cacheable=true)
    public static Integer getAllScheduledItems(){
        Integer count =  [SELECT COUNT() FROM LookupRollupSummaryScheduleItems__c];

        return count;
    }


    /**
     * Old methods from original rollup page
     * 
     */

    @AuraEnabled(Cacheable=true)
    public static String getRollupSchedule() {
        if (LookupRollupSummary.id == null) { return 'No Schedule for Rollup';}

        String id = (LookupRollupSummary.id).to15();
        List<CronTrigger> ct = new CronTriggersSelector().selectScheduledApexById(id);
    
        if (ct.isEmpty()) { return 'No Schedule for Rollup';} 
        else {
        return ct[0].NextFireTime.format();
        }
      }

      @AuraEnabled(Cacheable=true)
      public static Integer hasChildTriggers() {
        if (LookupRollupSummary == null) {
          return -1;
        }

        RollupSummary rs = new RollupSummary(LookupRollupSummary);
        String childTrigger = RollupSummaries.makeTriggerName(rs);
        String parentTrigger = RollupSummaries.makeParentTriggerName(rs);
        ApexTriggersSelector selector = new ApexTriggersSelector();
        Map<String, ApexTrigger> loadTriggers = selector.selectByName(
        new Set<String>{ ChildTrigger, ParentTrigger }
        );

          return loadTriggers.size();
    }
      
}
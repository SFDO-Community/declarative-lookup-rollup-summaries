@IsTest
private class RefControllerTest {
    
    private testMethod static void testMDT() {
        
        //multiple generate rollups
        genRollups('test1');
        genRollups('test2');
        genRollups('test3');
        
        RefController rf = new RefController();
        rf.getRollupRecords();
        rf.getScheduledApex();
        rf.getMerge();
        rf.redirect();
        
    }
    
    //Utility class to generate Rollups
    private static void genRollups(String uniqueName){
        
        
        // Configure rollup
        LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
        rollupSummary.Name = 'Total Opportunities into Annual Revenue on Account';
        rollupSummary.UniqueName__c = uniqueName;
        rollupSummary.ParentObject__c = 'Account';
        rollupSummary.ChildObject__c = 'Opportunity';
        rollupSummary.RelationShipField__c = 'AccountId';
        rollupSummary.RelationShipCriteria__c = null;
        rollupSummary.FieldToAggregate__c = 'Amount';
        rollupSummary.AggregateOperation__c = 'Sum';
        rollupSummary.AggregateResultField__c = 'AnnualRevenue';
        rollupSummary.Active__c = true;
        rollupSummary.CalculationMode__c = 'Scheduled';
        insert new List<LookupRollupSummary__c>{ rollupSummary };
            
            
            
            }
    
    //Utility class to generate Scheduled jobs. reference rollupscheduledcalculatecontrollertest.cls for test
    private static void genJobs(String uniqueName){
        //no clue yet
        
        
    }
    
    
    
}
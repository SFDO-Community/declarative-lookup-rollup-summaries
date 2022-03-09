public with sharing class  RefController {
    
    
    //inner class to store joined object - MDT and Apex schulded job
    //Can add more fields if users want more options for default view
    class ScheduleObject {
        
        public string label {get; set;}
        public string calcMode {get; set;}
        public string apexJobName {get; set;}
        public string scheduledTime {get; set;}
        public Integer jobFiredCount {get; set;}
        public string recordId {get; set;}
        
    }
    
    //Todo: Send user to new wizard when they click record ID
    public pagereference redirect(){      
        return null;
    }
    
    //soql query to return schedukled apex job.
    //governor limit of 100
    //ToDo: use selector class to get
    public List<CronTrigger> getScheduledApex(){
        
        List<CronTrigger> ct = [SELECT CronJobDetail.Name, CronExpression, OwnerId , NextFireTime , TimesTriggered
                                FROM CronTrigger 
                                WHERE CronJobDetail.JobType = '7' AND CronJobDetail.Name LIKE '%rollup%'
                                LIMIT 100];
        return ct;
    }
    
    //SOQL query to return metadata rollup records.
    //limit to 500 until properly tested
    //ToDo: Use selector class to get
    public List<LookupRollupSummary2__mdt> getRollupRecords(){
        
        List<LookupRollupSummary2__mdt> mdt = [select CalculationMode__c, DeveloperName
                                               from LookupRollupSummary2__mdt 
                                               LIMIT 500];
        
        return mdt;      
    }
    
    public List<ScheduleObject> getMerge(){
        
        List<LookupRollupSummary2__mdt> mdt = getRollupRecords();
        List<CronTrigger> ct = getScheduledApex();
        List<ScheduleObject> so = new List<ScheduleObject>{};
            
        //return empty object if there are more scheduled jobs than rollups    
        if(mdt.size() < ct.size()){
             return so;
         }    
        
        //mdt will always be larger or equal to scheduled apex job list?
        //initialize fields with null and override in next loop    
        for(integer i = 0; i < mdt.size(); i++){
            ScheduleObject tempSO = new ScheduleObject();
            tempSO.label = mdt[i].DeveloperName;
            tempSO.calcMode = mdt[i].CalculationMode__c;
            tempSO.apexJobName = null;
            tempSO.ScheduledTime = null;
            tempSO.JobFiredCount = null;
            tempSO.RecordId = mdt[i].id;
            so.add(tempSO);            
        }
        
        //Inefficient loop.
        //Apex job name contains 15 character record id, Record returns 18 char record id
        for(ScheduleObject soTemp : so){  
            for(integer i = 0; i < ct.size(); i++){
                String shortID = soTemp.RecordId.substring(0,15);
                if(ct[i].CronJobDetail.Name.contains(shortID)){
                    soTemp.apexJobName = ct[i].CronJobDetail.Name;
                    soTemp.ScheduledTime = ct[i].CronExpression;
                    soTemp.JobFiredCount = ct[i].TimesTriggered;
                }
            }
        }
        
        return so;    
    }
    
}
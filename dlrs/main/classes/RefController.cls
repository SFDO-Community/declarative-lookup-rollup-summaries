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
    public List<CronTrigger> getScheduledApex(){
        
        List<CronTrigger> ct = [SELECT CronJobDetail.Name, CronExpression, OwnerId , NextFireTime , TimesTriggered
                         FROM CronTrigger 
                         WHERE CronJobDetail.JobType = '7' AND CronJobDetail.Name LIKE '%rollup%'
                         LIMIT 100];
        return ct;
    }
    
    //SOQL query to return metadata rollup records.
    //limit to 500 until properly tested
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
        //Substring match might not work on all.
        //Is there a common id between the apex scheduled job and 
        //the Custom metadata record?
        for(ScheduleObject soTemp : so){  
            for(integer i = 0; i < ct.size(); i++){
                String str1 = ct[i].CronJobDetail.Name;
                String str2 = str1.substringBetween('_', ' ' );
                System.debug('Comparison String: ' + str2);
                if(soTemp.Label == str2){
                    soTemp.apexJobName = ct[i].CronJobDetail.Name;
                    soTemp.ScheduledTime = ct[i].CronExpression;
                    soTemp.JobFiredCount = ct[i].TimesTriggered;

                }
                System.debug('New object record id: ' +soTemp.RecordId);
            }
        }
        
        for(integer i = 0; i < so.size(); i++){
            System.debug(so[i]);
        }   
        return so;
            
            
    }

}
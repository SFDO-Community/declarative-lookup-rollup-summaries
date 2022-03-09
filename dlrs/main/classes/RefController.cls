public with sharing class  RefController {
    

    //Todo: Send user to wizard when they click record ID
    public pagereference redirect(){      
        return null;
    }

    public List<ViewerObject> getView(){
        
        list<RollupSummary> rs = new RollupSummariesSelector.CustomMetadataSelector(false,false).selectAll();
        List<CronTrigger> ct = [SELECT CronJobDetail.Name, CronExpression, OwnerId , NextFireTime , TimesTriggered
         FROM CronTrigger  
         WHERE CronJobDetail.JobType = '7' 
         WITH SECURITY_ENFORCED];
        Map<String, ViewerObject> viewerMap = new Map<String, ViewerObject>();
        
        //If org has no rollups return empty list, avoids null pointer exception
        if(rs.isEmpty()){
            return null;
        }
        
        viewerMap = setRollupSummaryToMap (rs) ;
        viewerMap = setCronTriggerToMap (ct , viewerMap) ;

        return viewerMap.values();    
    }
    

 
    //ToDo: Add support for all fields
    class ViewerObject {
        
        public string label {get; set;}
        public string calcMode {get; set;}
        public string apexJobName {get; set;}
        public string scheduledTime {get; set;}
        public Integer jobFiredCount {get; set;}
        public string recordId {get; set;}
        public Datetime endtime {get; set;}
    } 

    //toDo: Add all fields from Rollup Summary metadata object
    public Map<String, ViewerObject> setRollupSummaryToMap( list<RollupSummary> rs ) {

        Map<String, ViewerObject> viewerMap = new Map<String, ViewerObject>();

        //can add support for more fields
        for(integer i = 0; i < rs.size(); i++){
            ViewerObject viewObj = new ViewerObject();
            viewObj.label = rs[i].UniqueName;
            viewObj.calcMode = rs[i].CalculationMode;
            viewObj.RecordId = rs[i].id;

            //id reference between both queries needs to be 15 characters.
            viewerMap.put(rs[i].id.substring(0,15) , viewObj);

        }
        return viewerMap;     
    }


     public Map<String, ViewerObject> setCronTriggerToMap( list<CronTrigger> ct , Map<String, ViewerObject> viewerMap) {

        for( CronTrigger c : ct){
            //isolate 15 character id from cronjob name. 
            String id = c.CronJobDetail.Name.substringBetween( '(' , ')' );
            if (viewerMap.containsKey(id)){
                viewerMap.get(id).apexJobName = c.CronJobDetail.Name;
                viewerMap.get(id).scheduledTime = c.CronExpression;
                viewerMap.get(id).jobFiredCount = c.TimesTriggered;
            }
        }

        return viewerMap;

     }


    

}
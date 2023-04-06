public with sharing class ObjectSelectorController {
    public ObjectSelectorController() {


    }

    @AuraEnabled(cacheable=true)
    public static List<String> getParentObjList() {
        System.debug('getParentObjList entry');
        Map<String, Schema.SObjectType>  objectDescription = Schema.getGlobalDescribe();
        List<Schema.SObjectType> parentObjList = objectDescription.values();
        List<String> lstObjects= new List<String>();
        Set<String> res=queryRollupableSObjectsNames();
        for (Schema.SObjectType obj : parentObjList) {
          Schema.DescribeSObjectResult description = obj.getDescribe(
            SObjectDescribeOptions.DEFERRED
          );
    
          //Filter out sObjects that can't be rolled up to avoid >1000 collection limit
          
       /*  if(!res.contains(description.getName())) {
            continue;
        }*/
    
          String prefix = description.getKeyPrefix();
    
          if (!String.isEmpty(prefix)) {
              lstObjects.add(obj.getDescribe().getLabel()+'('+obj.getDescribe().getName()+')');
           // mapLabelToValues.put(obj.getDescribe().getName(), obj.getDescribe().getLabel());

           
          }

        }
        System.debug('lstObjects'+lstObjects);
        System.debug('lstObjects size'+lstObjects.size());
     return  lstObjects;
      }

      
      public static Set<String> queryRollupableSObjectsNames() {
        Set<String> rollupableSObjectsNames = new Set<String>();
        List<EntityDefinition> entityDefinitions = [
              SELECT QualifiedApiName FROM EntityDefinition
              WHERE IsCustomSetting = false
              AND IsCustomizable = true
              AND isApexTriggerable = true
              WITH SECURITY_ENFORCED
            ];
    
            for(EntityDefinition entDef : entityDefinitions) {
              rollupableSObjectsNames.add(entDef.QualifiedApiName);
            }
          System.debug('rollupableSObjectsNames->'+rollupableSObjectsNames);
    
          return rollupableSObjectsNames;
      }

}
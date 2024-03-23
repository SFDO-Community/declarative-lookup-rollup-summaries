public with sharing class ObjectSelectorController {
  @AuraEnabled(cacheable=true)
  public static List<SObjectInfo> getParentObjList() {
    Map<String, Schema.SObjectType> objectDescription = Schema.getGlobalDescribe();
    List<SObjectInfo> objects = new List<SObjectInfo>();
    for (Schema.SObjectType obj : objectDescription.values()) {
      objects.add(new SObjectInfo(obj));
    }
    return objects;
  }

  class SObjectInfo {
    @AuraEnabled
    public String fullName;
    @AuraEnabled
    public String label;

    public SObjectInfo(Schema.SObjectType obj) {
      Schema.DescribeSObjectResult description = obj.getDescribe(
        SObjectDescribeOptions.DEFERRED
      );
      this.fullName = description.getName();
      this.label = description.getLabel();
    }
  }
}

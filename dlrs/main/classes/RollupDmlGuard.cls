public with sharing class RollupDmlGuard {
  /**
   * Take a set of contexts and proposed changes
   * Filter down the records to only those that differ from the database
   */
  public List<SObject> getOnlyRecordsNeedingDml(
    List<LREngine.Context> contexts,
    Map<Id, SObject> records
  ) {
    DeclarativeLookupRollupSummaries__c configSettings = DeclarativeLookupRollupSummaries__c.getInstance();
    if (configSettings.DisableParentDMLCheck__c) {
      // config disables additional checks to validate DML is necessary,
      // return the list and behave as though they all need DML
      // this setting is to allow the org to avoid the SOQL cost of querying records
      // and the CPU time of performing the compare
      return records.values();
    }
    Map<Schema.SObjectType, Set<Schema.DescribeFieldResult>> parentTypeListOfFields = new Map<Schema.SObjectType, Set<Schema.DescribeFieldResult>>();
    // Collect parent objects and fields to query them from database
    Map<Schema.SObjectType, List<SObject>> masterRecordsByType = new Map<Schema.SObjectType, List<SObject>>();
    for (LREngine.Context ctx : contexts) {
      // stage object to be filled later
      masterRecordsByType.put(ctx.master, new List<SObject>());
      // build up list of parent objects and their fields
      if (!parentTypeListOfFields.containsKey(ctx.master)) {
        parentTypeListOfFields.put(
          ctx.master,
          new Set<Schema.DescribeFieldResult>()
        );
      }
      for (LREngine.RollupSummaryField f : ctx.fieldsToRoll) {
        parentTypeListOfFields.get(ctx.master).add(f.master);
      }
    }
    for (SObject obj : records.values()) {
      Schema.SObjectType t = obj.getSObjectType();
      masterRecordsByType.get(t).add(obj);
    }

    // take all parent records of a given type, pull their current state from the database and store it in a map
    Map<Schema.SObjectType, Map<Id, SObject>> parentsByType = new Map<Schema.SObjectType, Map<Id, SObject>>();
    for (Schema.SObjectType type : parentTypeListOfFields.keySet()) {
      parentsByType.put(
        type,
        getParentRecords(
          type,
          parentTypeListOfFields.get(type),
          masterRecordsByType.get(type)
        )
      );
    }

    // for each object type, compare the database values and the proposed values
    // if all values are equal, discard that proposed DML as unecessary
    List<SObject> masterRecordsToUpdate = new List<SObject>();
    for (Schema.SObjectType t : masterRecordsByType.keySet()) {
      masterRecordsToUpdate.addAll(
        filterParentRecords(masterRecordsByType.get(t), parentsByType.get(t))
      );
    }
    // return a list of all needed changes, might be empty
    return masterRecordsToUpdate;
  }

  /**
   * Retrieve a set of fields for a given SObject whose IDs are present in parents
   */
  private Map<Id, SObject> getParentRecords(
    Schema.SObjectType sobjectType,
    Set<Schema.DescribeFieldResult> fields,
    List<SObject> parents
  ) {
    // build a SOQL query and retrieve the parent records
    // return the parent records
    fflib_QueryFactory queryFactory = new fflib_QueryFactory(sobjectType)
      .selectField('Id');
    for (Schema.DescribeFieldResult f : fields) {
      queryFactory.selectField(f.getName());
    }
    queryFactory.setCondition('Id IN :parents');
    // Opting not to LOCK the parent records for this action
    // don't lock them normally in these scenarios and concerned about
    // what adding a lock would do
    // at some future point we can add a setting to enable locking here if needed
    String query = queryFactory.toSOQL();
    return new Map<Id, SObject>(Database.query(query));
  }

  /**
   * compare two sets of SObjects, return records that are not identical
   * Favoring expectedParents for non-mutual items
   */
  private List<SObject> filterParentRecords(
    List<SObject> expectedParents,
    Map<Id, SObject> currentParents
  ) {
    List<SObject> parentsNeedingUpdate = new List<SObject>();

    for (SObject expP : expectedParents) {
      if (!currentParents.containsKey(expP.Id)) {
        // don't know why this parent wasn't pulled from the database, but assume it needs to be committed
        parentsNeedingUpdate.add(expP);
        continue;
      }
      // get all fields on the proposed change record
      Map<String, Object> fieldsMap = expP.getPopulatedFieldsAsMap();
      // pull the current database snapshot
      SObject curP = currentParents.get(expP.Id);
      // for each field on the proposed changes, see if that matches the DB value
      for (String key : fieldsMap.keySet()) {
        // if any of the values don't match between objects
        // enqueue for DML
        if (expP.get(key) != curP.get(key)) {
          parentsNeedingUpdate.add(expP);
          break;
        }
      }
    }
    return parentsNeedingUpdate;
  }
}

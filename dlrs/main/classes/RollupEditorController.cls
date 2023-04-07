public with sharing class RollupEditorController {
  @AuraEnabled
  public static Map<String, LookupRollupSummary2__mdt> getAllRollupConfigs() {
    return LookupRollupSummary2__mdt.getAll();
  }

  @AuraEnabled
  public static LookupRollupSummary2__mdt getRollupConfig(String rollupName) {
    return (LookupRollupSummary2__mdt) new RollupSummariesSelector.CustomMetadataSelector(
          false,
          true // retrieve for Edit
        )
        .selectByDeveloperName(new Set<String>{ rollupName })[0]
      .Record;
  }

  @AuraEnabled
  public static Map<String, List<String>> validateRollupConfig(String rollup) {
    // do things like validate that the Rollup Criteria can be used in a SOQL query
    LookupRollupSummary2__mdt lookupConfig = (LookupRollupSummary2__mdt) JSON.deserialize(
      rollup,
      LookupRollupSummary2__mdt.class
    );
    // map of errors by "location" such as "record" or "[fieldname]" to enable displaying the error against a specific field/aread of
    Map<String, List<String>> errorMap = new Map<String, List<String>>{};
    // 'record' => new List<String>()

    // TODO: execute validations and check configs
    return errorMap;
  }

  @AuraEnabled
  public static Id saveRollupConfig(String rollup) {
    LookupRollupSummary2__mdt lookupConfig = (LookupRollupSummary2__mdt) JSON.deserialize(
      rollup,
      LookupRollupSummary2__mdt.class
    );
    return CustomMetadataService.initiateMetadataSave(
      new List<SObject>{ lookupConfig }
    );
  }

  @AuraEnabled
  public static Id deleteRollupConfig(String rollupName) {
    try {
      return CustomMetadataService.deleteMetadataAsync(
        LookupRollupSummary2__mdt.getSObjectType(),
        new List<String>{ rollupName }
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}

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
    return saveRollup(lookupConfig);
  }

  // TODO: move somewhere else
  public static Id saveRollup(LookupRollupSummary2__mdt rollup) {
    // Setup custom metadata to be created in the subscriber org.
    Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
    // TODO: does this get weird if we're in a namespaced context??
    // Developer name and Label are applied here
    customMetadata.fullName =
      'LookupRollupSummary2__mdt.' + rollup.DeveloperName;
    customMetadata.label = rollup.Label;
    Metadata.CustomMetadata mdt = new Metadata.CustomMetadata();
    Map<String, Object> populatedFields = rollup.getPopulatedFieldsAsMap();
    // We don't want these in values
    List<String> ignoredKeys = new List<String>{
      'Id',
      'DeveloperName',
      'Label'
    };
    for (String key : populatedFields.keySet()) {
      if (ignoredKeys.contains(key)) {
        continue;
      }
      Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
      customField.field = key;
      customField.value = populatedFields.get(key);
      customMetadata.values.add(customField);
    }

    Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
    mdContainer.addMetadata(customMetadata);

    DeployCallback cb = new DeployCallback();
    // Enqueue custom metadata deployment
    Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, cb);
    return jobId;
  }

  // TODO: move somewhere else
  class DeployCallback implements Metadata.DeployCallback {
    public void handleResult(
      Metadata.DeployResult result,
      Metadata.DeployCallbackContext context
    ) {
      UserNotification__e updateEvent = new UserNotification__e(
        Type__c = 'DeploymentResult',
        Payload__c = JSON.serialize(result)
      );
      EventBus.publish(updateEvent);
    }
  }
}

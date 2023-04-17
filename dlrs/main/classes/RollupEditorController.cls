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


  public class SelectOption {

    @AuraEnabled
    public String value;

    @AuraEnabled
    public String label;

    @AuraEnabled
    public String icon;

    @AuraEnabled
    public String type;

    public SelectOption(String value, String label){
      this.value = value;
      this.label = label;
    }

  }

  @AuraEnabled
  public static List<SelectOption> getFieldOptions(String objectName){
    Map<String, Schema.SobjectField> mapOfFields =  Schema.getGlobalDescribe()
                                                      .get(objectName)
                                                      .getDescribe()
                                                      .fields.getMap();

    SelectOption emptyOption = new SelectOption('', '-- Select --');

    List<SelectOption> options = new List<SelectOption>();
    options.add(emptyOption);

    for (Schema.SObjectField field : mapOfFields.values()) {
      Schema.DescribeFieldResult fr = field.getDescribe();
      String fieldName = fr.getName();
      String label = fr.getLabel();

      SelectOption option = new SelectOption(fieldName, label);
      option.type = String.valueof(fr.getType());
      options.add(option);
    }

    return options;
  }

  
  /**
   * returns a map of fieldname => list<errorstring> to use in displaying error in the UI
   * general errors are applied to the 'record' field name
   */
  @AuraEnabled
  public static Map<String, List<String>> validateRollupConfig(String rollup) {
    // do things like validate that the Rollup Criteria can be used in a SOQL query
    LookupRollupSummary2__mdt lookupConfig = (LookupRollupSummary2__mdt) JSON.deserialize(
      rollup,
      LookupRollupSummary2__mdt.class
    );

    // Process only Custom Metadata records here
    List<LookupRollupSummary2__mdt> mdtRecords = new List<LookupRollupSummary2__mdt>();
    mdtRecords.add(lookupConfig);

    // Validate via Domain class and throw appropirte exception
    RollupSummaries rollupSummaries = new RollupSummaries(mdtRecords);
    rollupSummaries.onValidate();
    Map<String, List<String>> errorMap;
    for (RollupSummary rollupSummaryRecord : rollupSummaries.Records) {
      errorMap = collectErrors(rollupSummaryRecord);
    }

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

  private static Map<String, List<String>> collectErrors(RollupSummary rollup) {
    Map<String, List<String>> errorMap = new Map<String, List<String>>();
    if (rollup.Error != null) {
      buildErrorIfNeeded(errorMap, 'record', new List<String>{ rollup.Error });
    }
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.Active__c.getDescribe().getName(),
      rollup.Fields.Active.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.AggregateOperation__c.getDescribe()
        .getName(),
      rollup.Fields.AggregateOperation.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.AggregateResultField__c.getDescribe()
        .getName(),
      rollup.Fields.AggregateResultField.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.CalculationMode__c.getDescribe()
        .getName(),
      rollup.Fields.CalculationMode.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.CalculationSharingMode__c.getDescribe()
        .getName(),
      rollup.Fields.CalculationSharingMode.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.ChildObject__c.getDescribe().getName(),
      rollup.Fields.ChildObject.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.Description__c.getDescribe().getName(),
      rollup.Fields.Description.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.FieldToAggregate__c.getDescribe()
        .getName(),
      rollup.Fields.FieldToAggregate.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.DeveloperName.getDescribe().getName(),
      rollup.Fields.UniqueName.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.ParentObject__c.getDescribe().getName(),
      rollup.Fields.ParentObject.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.RelationshipCriteria__c.getDescribe()
        .getName(),
      rollup.Fields.RelationshipCriteria.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.RelationshipCriteriaFields__c.getDescribe()
        .getName(),
      rollup.Fields.RelationshipCriteriaFields.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.RelationshipField__c.getDescribe()
        .getName(),
      rollup.Fields.RelationshipField.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.TestCode2__c.getDescribe().getName(),
      rollup.Fields.TestCode.errors
    );
    buildErrorIfNeeded(
      errorMap,
      LookupRollupSummary2__mdt.fields.RowLimit__c.getDescribe().getName(),
      rollup.Fields.RowLimit.errors
    );
    return errorMap;
  }

  private static void buildErrorIfNeeded(
    Map<String, List<String>> errorMap,
    String fieldName,
    List<String> errors
  ) {
    if (errors.isEmpty()) {
      return;
    }
    errorMap.put(fieldName, errors);
  }
}

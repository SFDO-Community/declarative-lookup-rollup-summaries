public with sharing class RollupEditorController {
  @AuraEnabled
  public static List<RollupConfig> getAllRollupConfigs() {
    List<RollupConfig> rollups = new List<RollupConfig>();
    for (
      RollupSummary summary : new RollupSummariesSelector.CustomMetadataSelector(
          true,
          true // retrieve for Edit
        )
        .selectAll()
    ) {
      rollups.add(new RollupConfig((LookupRollupSummary2__mdt) summary.Record));
    }
    return rollups;
  }

  @AuraEnabled
  public static RollupConfig getRollupConfig(String rollupName) {
    return new RollupConfig(
      (LookupRollupSummary2__mdt) new RollupSummariesSelector.CustomMetadataSelector(
            true,
            true // retrieve for Edit
          )
          .selectByDeveloperName(new Set<String>{ rollupName })[0]
        .Record
    );
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

    @AuraEnabled
    public List<String> referencesTo;

    public SelectOption(String value, String label) {
      this.value = value;
      this.label = label;
      this.referencesTo = new List<String>();
    }
  }

  @AuraEnabled
  public static List<SelectOption> getFieldOptions(String objectName) {
    Map<String, Schema.SobjectField> mapOfFields = Schema.getGlobalDescribe()
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

      SelectOption option = new SelectOption(
        fieldName,
        String.format('{0} ({1})', new List<String>{ label, fieldName })
      );
      option.type = String.valueof(fr.getType());
      List<Schema.sObjectType> types = fr.getReferenceTo();
      // if this fields points to a single SObject, pass that up
      for (Schema.sObjectType t : types) {
        option.referencesTo.add(types[0].getDescribe().getName());
      }
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
    RollupConfig cfg = (RollupConfig) JSON.deserialize(
      rollup,
      RollupConfig.class
    );
    // do things like validate that the Rollup Criteria can be used in a SOQL query
    LookupRollupSummary2__mdt lookupConfig = cfg.getRecord();

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

    LookupRollupSummary2__mdt existing = LookupRollupSummary2__mdt.getInstance(
      lookupConfig.DeveloperName
    );
    if (existing != null && existing.Id != lookupConfig.Id) {
      if (errorMap == null) {
        errorMap = new Map<String, List<String>>();
      }

      if (!errorMap.containsKey('developerName')) {
        errorMap.put('developerName', new List<String>());
      }

      errorMap.get('developerName')
        .add('API name already in use by ' + existing.Id);
    }

    return errorMap;
  }

  @AuraEnabled
  public static Id saveRollupConfig(String rollup) {
    RollupConfig cfg = (RollupConfig) JSON.deserialize(
      rollup,
      RollupConfig.class
    );
    LookupRollupSummary2__mdt lookupConfig = cfg.getRecord();
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

  @AuraEnabled(cacheable=true)
  public static String getManageTriggerPageUrl(Id rollupId) {
    PageReference pageRef = Page.managetriggermdt;
    pageRef.getParameters().put('id', rollupId);
    return pageRef.getUrl();
  }

  @AuraEnabled(cacheable=true)
  public static String getFullCalculatePageUrl(Id rollupId) {
    PageReference pageRef = Page.rollupcalculatemdt;
    pageRef.getParameters().put('id', rollupId);
    return pageRef.getUrl();
  }

  @AuraEnabled(cacheable=true)
  public static String getScheduleCalculatePageUrl(Id rollupId) {
    PageReference pageRef = Page.rollupscheduledcalculatemdt;
    pageRef.getParameters().put('id', rollupId);
    return pageRef.getUrl();
  }

  private static Map<String, List<String>> collectErrors(RollupSummary rollup) {
    Map<String, List<String>> errorMap = new Map<String, List<String>>();
    if (rollup.Error != null) {
      buildErrorIfNeeded(errorMap, 'record', new List<String>{ rollup.Error });
    }
    buildErrorIfNeeded(errorMap, 'active', rollup.Fields.Active.errors);
    buildErrorIfNeeded(
      errorMap,
      'aggregateOperation',
      rollup.Fields.AggregateOperation.errors
    );
    buildErrorIfNeeded(
      errorMap,
      'aggregateResultField',
      rollup.Fields.AggregateResultField.errors
    );
    buildErrorIfNeeded(
      errorMap,
      'calculationMode',
      rollup.Fields.CalculationMode.errors
    );
    buildErrorIfNeeded(
      errorMap,
      'calculationSharingMode',
      rollup.Fields.CalculationSharingMode.errors
    );
    buildErrorIfNeeded(
      errorMap,
      'childObject',
      rollup.Fields.ChildObject.errors
    );
    buildErrorIfNeeded(
      errorMap,
      'description',
      rollup.Fields.Description.errors
    );
    buildErrorIfNeeded(
      errorMap,
      'fieldToAggregate',
      rollup.Fields.FieldToAggregate.errors
    );
    buildErrorIfNeeded(
      errorMap,
      'developerName',
      rollup.Fields.UniqueName.errors
    );
    buildErrorIfNeeded(
      errorMap,
      'parentObject',
      rollup.Fields.ParentObject.errors
    );
    buildErrorIfNeeded(
      errorMap,
      'relationshipCriteria',
      rollup.Fields.RelationshipCriteria.errors
    );
    buildErrorIfNeeded(
      errorMap,
      'relationshipCriteriaFields',
      rollup.Fields.RelationshipCriteriaFields.errors
    );
    buildErrorIfNeeded(
      errorMap,
      'relationshipField',
      rollup.Fields.RelationshipField.errors
    );
    buildErrorIfNeeded(errorMap, 'testCode', rollup.Fields.TestCode.errors);
    buildErrorIfNeeded(errorMap, 'rowLimit', rollup.Fields.RowLimit.errors);
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

  @SuppressWarnings('PMD.TooManyFields')
  public class RollupConfig {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String developerName;
    @AuraEnabled
    public Boolean active;
    @AuraEnabled
    public Boolean aggregateAllRows;
    @AuraEnabled
    public String aggregateOperation;
    @AuraEnabled
    public String aggregateResultField;
    @AuraEnabled
    public String bypassPermissionApiName;
    @AuraEnabled
    public String calculationMode;
    @AuraEnabled
    public String calculationSharingMode;
    @AuraEnabled
    public String childObject;
    @AuraEnabled
    public String concatenateDelimiter;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public String fieldToAggregate;
    @AuraEnabled
    public String fieldToOrderBy;
    @AuraEnabled
    public String parentObject;
    @AuraEnabled
    public String relationshipCriteria;
    @AuraEnabled
    public String relationshipCriteriaFields;
    @AuraEnabled
    public String relationshipField;
    @AuraEnabled
    public Decimal rowLimit;
    @AuraEnabled
    public String testCode;
    @AuraEnabled
    public String testCodeParent;
    @AuraEnabled
    public Boolean testCodeSeeAllData;

    public RollupConfig(LookupRollupSummary2__mdt record) {
      this.id = record.Id;
      this.label = record.Label;
      this.developerName = record.DeveloperName;
      this.active = record.Active__c;
      this.aggregateAllRows = record.AggregateAllRows__c;
      this.aggregateOperation = record.AggregateOperation__c;
      this.aggregateResultField = record.AggregateResultField__c;
      this.bypassPermissionApiName = record.BypassPermissionApiName__c;
      this.calculationMode = record.CalculationMode__c;
      this.calculationSharingMode = record.CalculationSharingMode__c;
      this.childObject = record.ChildObject__c;
      this.concatenateDelimiter = record.ConcatenateDelimiter__c;
      this.description = record.Description__c;
      this.fieldToAggregate = record.FieldToAggregate__c;
      this.fieldToOrderBy = record.FieldToOrderBy__c;
      this.parentObject = record.ParentObject__c;
      this.relationshipCriteria = record.RelationshipCriteria__c;
      this.relationshipCriteriaFields = record.RelationshipCriteriaFields__c;
      this.relationshipField = record.RelationshipField__c;
      this.rowLimit = record.RowLimit__c;
      this.testCode = record.TestCode2__c;
      this.testCodeParent = record.TestCodeParent__c;
      this.testCodeSeeAllData = record.TestCodeSeeAllData__c;
    }

    public LookupRollupSummary2__mdt getRecord() {
      LookupRollupSummary2__mdt record = new LookupRollupSummary2__mdt();
      record.Id = this.id;
      record.Label = this.label;
      record.DeveloperName = this.developerName;
      record.Active__c = this.active;
      record.AggregateAllRows__c = this.aggregateAllRows;
      record.AggregateOperation__c = this.aggregateOperation;
      record.AggregateResultField__c = this.aggregateResultField;
      record.BypassPermissionApiName__c = this.bypassPermissionApiName;
      record.CalculationMode__c = this.calculationMode;
      record.CalculationSharingMode__c = this.calculationSharingMode;
      record.ChildObject__c = this.childObject;
      record.ConcatenateDelimiter__c = this.concatenateDelimiter;
      record.Description__c = this.description;
      record.FieldToAggregate__c = this.fieldToAggregate;
      record.FieldToOrderBy__c = this.fieldToOrderBy;
      record.ParentObject__c = this.parentObject;
      record.RelationshipCriteria__c = this.relationshipCriteria;
      record.RelationshipCriteriaFields__c = this.relationshipCriteriaFields;
      record.RelationshipField__c = this.relationshipField;
      record.RowLimit__c = this.rowLimit;
      record.TestCode2__c = this.testCode;
      record.TestCodeParent__c = this.testCodeParent;
      record.TestCodeSeeAllData__c = this.testCodeSeeAllData;
      return record;
    }
  }
}

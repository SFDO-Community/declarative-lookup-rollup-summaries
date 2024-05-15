@IsTest
public with sharing class RollupEditorControllerTest {
  static LookupRollupSummary2__mdt lup = new LookupRollupSummary2__mdt(
    Id = Schema.LookupRollupSummary2__mdt.getSObjectType()
        .getDescribe()
        .getKeyPrefix() + '000000000aaa',
    Label = 'TestLabel',
    DeveloperName = 'TestDevName',
    Active__c = true,
    AggregateAllRows__c = true,
    AggregateOperation__c = 'Count',
    AggregateResultField__c = 'ResultField',
    CalculationMode__c = 'CalcMode',
    CalculationSharingMode__c = 'SharingMode',
    ChildObject__c = 'ChildObject',
    ConcatenateDelimiter__c = 'Delim',
    Description__c = 'Desc',
    FieldToAggregate__c = 'FieldToAgg',
    FieldToOrderBy__c = 'FieldToOrder',
    ParentObject__c = 'ParentObject',
    RelationshipCriteria__c = 'RelCriteria',
    RelationshipCriteriaFields__c = 'Field1\nField2',
    RelationshipField__c = 'RelField',
    RowLimit__c = 100,
    TestCode2__c = 'TestCode',
    TestCodeParent__c = 'ParentTestCode',
    TestCodeSeeAllData__c = true
  );

  @IsTest
  static void testGetAllRollupConfigs() {
    List<LookupRollupSummary2__mdt> lookups = [
      SELECT Id
      FROM LookupRollupSummary2__mdt
    ];
    List<RollupEditorController.RollupConfig> configs = RollupEditorController.getAllRollupConfigs();
    Assert.areEqual(lookups.size(), configs.size());
  }

  @IsTest
  static void testGetRollupConfig() {
    List<LookupRollupSummary2__mdt> lookups = [
      SELECT
        Id,
        Label,
        DeveloperName,
        Active__c,
        AggregateAllRows__c,
        AggregateOperation__c,
        AggregateResultField__c,
        CalculationMode__c,
        CalculationSharingMode__c,
        ChildObject__c,
        ConcatenateDelimiter__c,
        Description__c,
        FieldToAggregate__c,
        FieldToOrderBy__c,
        ParentObject__c,
        RelationshipCriteria__c,
        RelationshipCriteriaFields__c,
        RelationshipField__c,
        RowLimit__c,
        TestCode__c,
        TestCodeParent__c,
        TestCodeSeeAllData__c
      FROM LookupRollupSummary2__mdt
    ];
    if (lookups.isEmpty()) {
      return;
    }
    LookupRollupSummary2__mdt lup = lookups[0];
    RollupEditorController.RollupConfig cfg = RollupEditorController.getRollupConfig(
      lup.DeveloperName
    );
    Assert.areEqual(lup.Id, cfg.id);
    Assert.areEqual(lup.Label, cfg.label);
    Assert.areEqual(lup.DeveloperName, cfg.developerName);
  }

  @IsTest
  static void testGetFieldOptions() {
    List<RollupEditorController.SelectOption> fields = RollupEditorController.getFieldOptions(
      'User'
    );
    Assert.isFalse(fields.isEmpty());
  }

  @IsTest
  static void testValidateRollupConfig() {
    RollupEditorController.RollupConfig cfg = new RollupEditorController.RollupConfig(
      lup
    );
    Map<String, List<String>> errors = RollupEditorController.validateRollupConfig(
      JSON.serialize(cfg)
    );
    Assert.areEqual(
      '{"rowLimit":["Row Limit is only supported on Last and Concatenate operators."],"parentObject":["Object does not exist."],"childObject":["Object does not exist."]}',
      JSON.serialize(errors)
    );
  }

  @IsTest
  static void testSaveRollupConfig() {
    RollupEditorController.RollupConfig cfg = new RollupEditorController.RollupConfig(
      lup
    );
    try {
      Id depId = RollupEditorController.saveRollupConfig(JSON.serialize(cfg));
      Assert.fail('Should throw an exception');
    } catch (System.AsyncException e) {
      Assert.areEqual(
        'Metadata cannot be deployed from within a test',
        e.getMessage()
      );
    }
  }

  @IsTest
  static void testDeleteRollupConfig() {
    Id queueableId = RollupEditorController.deleteRollupConfig('Hello');
    AsyncApexJob queueJob = [
      SELECT Id
      FROM AsyncApexJob
      WHERE Id = :queueableId
    ];
    Assert.areEqual(queueableId, queueJob.Id);
    System.abortJob(queueJob.Id);
  }

  @IsTest
  static void testGetManageTriggerPageUrl() {
    String url = RollupEditorController.getManageTriggerPageUrl(lup.Id);
    PageReference pageRef = Page.managetriggermdt;
    Assert.areEqual(pageRef.getUrl() + '?id=' + lup.Id, url);
  }

  @IsTest
  static void testGetFullCalculatePageUrl() {
    String url = RollupEditorController.getFullCalculatePageUrl(lup.Id);
    PageReference pageRef = Page.rollupcalculatemdt;
    Assert.areEqual(pageRef.getUrl() + '?id=' + lup.Id, url);
  }

  @IsTest
  static void testGetScheduleCalculatePageUrl() {
    String url = RollupEditorController.getScheduleCalculatePageUrl(lup.Id);
    PageReference pageRef = Page.rollupscheduledcalculatemdt;
    Assert.areEqual(pageRef.getUrl() + '?id=' + lup.Id, url);
  }

  @IsTest
  static void testRollupConfig() {
    RollupEditorController.RollupConfig cfg = new RollupEditorController.RollupConfig(
      lup
    );
    Assert.areEqual(lup.Id, cfg.id);
    Assert.areEqual(lup.Label, cfg.label);
    Assert.areEqual(lup.DeveloperName, cfg.developerName);
    Assert.areEqual(lup.Active__c, cfg.active);
    Assert.areEqual(lup.AggregateAllRows__c, cfg.aggregateAllRows);
    Assert.areEqual(lup.AggregateOperation__c, cfg.aggregateOperation);
    Assert.areEqual(lup.AggregateResultField__c, cfg.aggregateResultField);
    Assert.areEqual(lup.CalculationMode__c, cfg.calculationMode);
    Assert.areEqual(lup.CalculationSharingMode__c, cfg.calculationSharingMode);
    Assert.areEqual(lup.ChildObject__c, cfg.childObject);
    Assert.areEqual(lup.ConcatenateDelimiter__c, cfg.concatenateDelimiter);
    Assert.areEqual(lup.Description__c, cfg.description);
    Assert.areEqual(lup.FieldToAggregate__c, cfg.fieldToAggregate);
    Assert.areEqual(lup.FieldToOrderBy__c, cfg.fieldToOrderBy);
    Assert.areEqual(lup.ParentObject__c, cfg.parentObject);
    Assert.areEqual(lup.RelationshipCriteria__c, cfg.relationshipCriteria);
    Assert.areEqual(
      lup.RelationshipCriteriaFields__c,
      cfg.relationshipCriteriaFields
    );
    Assert.areEqual(lup.RelationshipField__c, cfg.relationshipField);
    Assert.areEqual(lup.RowLimit__c, cfg.rowLimit);
    Assert.areEqual(lup.TestCode2__c, cfg.testCode);
    Assert.areEqual(lup.TestCodeParent__c, cfg.testCodeParent);
    Assert.areEqual(lup.TestCodeSeeAllData__c, cfg.testCodeSeeAllData);
    LookupRollupSummary2__mdt newLup = cfg.getRecord();

    Assert.areEqual(cfg.id, newLup.Id);
    Assert.areEqual(cfg.label, newLup.Label);
    Assert.areEqual(cfg.developerName, newLup.DeveloperName);
    Assert.areEqual(cfg.active, newLup.Active__c);
    Assert.areEqual(cfg.aggregateAllRows, newLup.AggregateAllRows__c);
    Assert.areEqual(cfg.aggregateOperation, newLup.AggregateOperation__c);
    Assert.areEqual(cfg.aggregateResultField, newLup.AggregateResultField__c);
    Assert.areEqual(cfg.calculationMode, newLup.CalculationMode__c);
    Assert.areEqual(
      cfg.calculationSharingMode,
      newLup.CalculationSharingMode__c
    );
    Assert.areEqual(cfg.childObject, newLup.ChildObject__c);
    Assert.areEqual(cfg.concatenateDelimiter, newLup.ConcatenateDelimiter__c);
    Assert.areEqual(cfg.description, newLup.Description__c);
    Assert.areEqual(cfg.fieldToAggregate, newLup.FieldToAggregate__c);
    Assert.areEqual(cfg.fieldToOrderBy, newLup.FieldToOrderBy__c);
    Assert.areEqual(cfg.parentObject, newLup.ParentObject__c);
    Assert.areEqual(cfg.relationshipCriteria, newLup.RelationshipCriteria__c);
    Assert.areEqual(
      cfg.relationshipCriteriaFields,
      newLup.RelationshipCriteriaFields__c
    );
    Assert.areEqual(cfg.relationshipField, newLup.RelationshipField__c);
    Assert.areEqual(cfg.rowLimit, newLup.RowLimit__c);
    Assert.areEqual(cfg.testCode, newLup.TestCode2__c);
    Assert.areEqual(cfg.testCodeParent, newLup.TestCodeParent__c);
    Assert.areEqual(cfg.testCodeSeeAllData, newLup.TestCodeSeeAllData__c);
  }
}

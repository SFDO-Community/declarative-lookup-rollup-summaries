@isTest
private with sharing class RollupSummariesSelectorTest {
  @isTest
  private static void selectAll_notForEdit_MDT() {
    MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false);
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

    Test.startTest();

    List<RollupSummary> summaries = metadataSelector.selectAll();

    Test.stopTest();

    //No query rows exist in org and query invocations not called. Just check that correct method is used
    System.assert(
      mock.getLookupRollupSummariesNotForEditCalled,
      'No SOQL queries should have been used'
    );
  }

  @isTest
  private static void selectAll_ForEdit_MDT() {
    MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(
      false,
      true
    );
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

    Test.startTest();

    List<RollupSummary> summaries = metadataSelector.selectAll();

    Test.stopTest();

    //No query rows exist in org and query invocations not called. Just check that correct method is used
    System.assert(
      mock.getLookupRollupSummariesForEditCalled,
      'SOQL queries should have been used'
    );
  }

  @isTest
  private static void selectAll_ForEdit_queryValidation_MDT() {
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = new RollupSummariesSelector.CustomMetadataSelector(
      false,
      true
    );

    System.QueryException unexpectedEx;
    Test.startTest();

    try {
      metadataSelector.selectAll();
    } catch(System.QueryException ex) {
      unexpectedEx = ex;
    }

    Test.stopTest();

    System.assertEquals(
      null,
      unexpectedEx,
      'SOQL query should not throw an exception'
    );
  }

  @isTest
  private static void selectAll_NotForEdit_SortOrder_MDT() {
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = new MockedCustomMetadataSelector(
      false
    );

    Test.startTest();
    List<RollupSummary> summaries = metadataSelector.selectAll();
    Test.stopTest();

    System.assertEquals(
      5,
      summaries.size(),
      'All of the records should have been returned'
    );

    System.assertEquals(
      'A Summary',
      String.valueOf(summaries[0].record.get('Label')),
      'The summaries should be returned in ASC order by Label'
    );
    System.assertEquals(
      'B Summary',
      String.valueOf(summaries[1].record.get('Label')),
      'The summaries should be returned in ASC order by Label'
    );
    System.assertEquals(
      'C Summary',
      String.valueOf(summaries[2].record.get('Label')),
      'The summaries should be returned in ASC order by Label'
    );
    System.assertEquals(
      'D Summary',
      String.valueOf(summaries[3].record.get('Label')),
      'The summaries should be returned in ASC order by Label'
    );
    System.assertEquals(
      'E Summary',
      String.valueOf(summaries[4].record.get('Label')),
      'The summaries should be returned in ASC order by Label'
    );
  }

  @isTest
  private static void selectActiveByUniqueName_notForEdit_MDT() {
    MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false);
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

    RollupSummariesSelector rollupSelector = new RollupSummariesSelector(false, false);
    rollupSelector.m_customMetadataSelector = mock;

    Test.startTest();

    List<RollupSummary> summaries = rollupSelector.selectActiveByUniqueName(
      new Set<String>{ 'A_Summary' }
    );

    Test.stopTest();

    //No query rows exist in org and query invocations not called. Just check that correct method is used
    System.assert(
      mock.getLookupRollupSummaryByDeveloperNameOrIdCalled,
      'no SOQL queries should have been used'
    );
  }

  @isTest
  private static void selectActiveByUniqueName_ForEdit_MDT() {
    MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false, true);
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

    RollupSummariesSelector rollupSelector = new RollupSummariesSelector(false, true);
    rollupSelector.m_customMetadataSelector = mock;

    Test.startTest();

    //There are no records in the database, just use an empty Set to check against query limits
    List<RollupSummary> summaries = rollupSelector.selectActiveByUniqueName(
      new Set<String>()
    );

    Test.stopTest();

    //No query rows exist in org and query invocations not called. Just check that correct method is used
    System.assert(
      mock.getLookupRollupSummariesForEditCalled,
      'SOQL queries should have been used'
    );
  }

  @isTest
  private static void selectActiveByUniqueName_NotForEdit_SortOrder() {
    MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false);
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

    RollupSummariesSelector rollupSelector = new RollupSummariesSelector(false, false);
    rollupSelector.m_customMetadataSelector = mock;

    Set<String> uniqueNames = new Set<String>{
      'A_Summary',
      'B_Summary',
      'C_Summary',
      'D_Summary',
      'E_Summary'
    };

    Test.startTest();
    List<RollupSummary> summaries = rollupSelector.selectActiveByUniqueName(
      uniqueNames
    );
    Test.stopTest();

    System.assertEquals(
      4,
      summaries.size(),
      'Only the active summaries should be returned'
    );

    System.assertEquals(
      'D_Summary',
      String.valueOf(summaries[0].record.get('DeveloperName')),
      'The summaries should be returned in ASC order by ParentObject__c, and then RelationshipField__c'
    );
    System.assertEquals(
      'A_Summary',
      String.valueOf(summaries[1].record.get('DeveloperName')),
      'The summaries should be returned in ASC order by ParentObject__c, and then RelationshipField__c'
    );
    System.assertEquals(
      'B_Summary',
      String.valueOf(summaries[2].record.get('DeveloperName')),
      'The summaries should be returned in ASC order by ParentObject__c, and then RelationshipField__c'
    );
    System.assertEquals(
      'E_Summary',
      String.valueOf(summaries[3].record.get('DeveloperName')),
      'The summaries should be returned in ASC order by ParentObject__c, and then RelationshipField__c'
    );
  }

  @isTest
  private static void selectActiveByChildObject_notForEdit_MDT() {
    MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false);
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

    RollupSummariesSelector rollupSelector = new RollupSummariesSelector(false, false);
    rollupSelector.m_customMetadataSelector = mock;

    Test.startTest();

    List<RollupSummary> summaries = rollupSelector.selectActiveByChildObject(
      RollupSummaries.CalculationMode.Realtime,
      new Set<String>()
    );

    Test.stopTest();

    //No query rows exist in org and query invocations not called. Just check that correct method is used
    System.assert(
      mock.getLookupRollupSummariesNotForEditCalled,
      'no SOQL queries should have been used'
    );
  }

  @isTest
  private static void selectActiveByChildObject_ForEdit_MDT() {
    MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false, true);
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

    RollupSummariesSelector rollupSelector = new RollupSummariesSelector(false, true);
    rollupSelector.m_customMetadataSelector = mock;

    Test.startTest();

    //There are no records in the database, just use an empty Set to check against query limits
    List<RollupSummary> summaries = rollupSelector.selectActiveByChildObject(
      RollupSummaries.CalculationMode.Realtime,
      new Set<String>()
    );

    Test.stopTest();

    //No query rows exist in org and query invocations not called. Just check that correct method is used
    System.assert(
      mock.getLookupRollupSummariesForEditCalled,
      'SOQL queries should have been used'
    );
  }

  @isTest
  private static void selectActiveByChildObject_ForEdit_queryValidation_MDT() {
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = new RollupSummariesSelector.CustomMetadataSelector(
      false,
      true
    );

    System.QueryException unexpectedEx;
    Test.startTest();

    try {
      metadataSelector.selectActiveByChildObject(
        RollupSummaries.CalculationMode.Realtime,
        new Set<String>()
      );
    } catch(System.QueryException ex) {
      unexpectedEx = ex;
    }

    Test.stopTest();

    System.assertEquals(
      null,
      unexpectedEx,
      'SOQL query should not throw an exception'
    );
  }

  @isTest
  private static void selectActiveByChildObject_NotForEdit_SortOrder_MDT() {
    MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false);
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

    RollupSummariesSelector rollupSelector = new RollupSummariesSelector(false, false);
    rollupSelector.m_customMetadataSelector = mock;

    Set<String> uniqueNames = new Set<String>{
      'A_Summary',
      'B_Summary',
      'C_Summary',
      'D_Summary',
      'E_Summary'
    };

    Test.startTest();
    List<RollupSummary> summaries = metadataSelector.selectActiveByChildObject(
      RollupSummaries.CalculationMode.Realtime,
      new Set<String>{ 'X', 'Y' }
    );
    Test.stopTest();

    System.assertEquals(
      2,
      summaries.size(),
      'Only the active summaries should be returned'
    );

    System.assertEquals(
      'D_Summary',
      String.valueOf(summaries[0].record.get('DeveloperName')),
      'The summaries should be returned in ASC order by ParentObject__c, and then RelationshipField__c'
    );
    System.assertEquals(
      'Realtime',
      String.valueOf(summaries[0].record.get('CalculationMode__c')),
      'Only the Realtime calculation modes should be returned'
    );

    System.assertEquals(
      'A_Summary',
      String.valueOf(summaries[1].record.get('DeveloperName')),
      'The summaries should be returned in ASC order by ParentObject__c, and then RelationshipField__c'
    );
    System.assertEquals(
      'Realtime',
      String.valueOf(summaries[1].record.get('CalculationMode__c')),
      'Only the Realtime calculation modes should be returned'
    );
  }

  @isTest
  private static void selectByDeveloperName_notForEdit_MDT() {
    MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false);
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

    Test.startTest();

    List<RollupSummary> summaries = metadataSelector.selectByDeveloperName(
      new Set<String>{ 'A_Summary' }
    );

    Test.stopTest();

    //No query rows exist in org and query invocations not called. Just check that correct method is used
    System.assert(
      mock.getLookupRollupSummaryByDeveloperNameOrIdCalled,
      'no SOQL queries should have been used'
    );
    System.assertEquals(
      'A_Summary',
      String.valueOf(summaries[0].record.get('DeveloperName')),
      'The summary with the specified developer name should be returned'
    );
  }

  @isTest
  private static void selectByDeveloperName_ForEdit_MDT() {
    MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(
      false,
      true
    );
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

    Test.startTest();

    //There are no records in the database, just use an empty Set to check against query limits
    List<RollupSummary> summaries = metadataSelector.selectByDeveloperName(
      new Set<String>{ 'A_Summary' }
    );

    Test.stopTest();

    //No query rows exist in org and query invocations not called. Just check that correct method is used
    System.assert(
      mock.getLookupRollupSummariesForEditCalled,
      'SOQL queries should have been used'
    );
  }

  @isTest
  private static void selectByDeveloperName_ForEdit_queryValidation_MDT() {
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = new RollupSummariesSelector.CustomMetadataSelector(
      false,
      true
    );

    System.QueryException unexpectedEx;
    Test.startTest();

    try {
      metadataSelector.selectByDeveloperName(
        new Set<String>{ 'A_Summary' }
      );
    } catch(System.QueryException ex) {
      unexpectedEx = ex;
    }

    Test.stopTest();

    System.assertEquals(
      null,
      unexpectedEx,
      'SOQL query should not throw an exception'
    );
  }

  @isTest
  private static void selectById_notForEdit_MDT() {
    MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false);
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

    RollupSummariesSelector rollupSelector = new RollupSummariesSelector(false, false);
    rollupSelector.m_customMetadataSelector = mock;
    String idVal = mock.summariesByDeveloperName.get('D_Summary').Id;

    Test.startTest();

    List<RollupSummary> summaries = rollupSelector.selectById(
      new Set<String>{ idVal }
    );

    Test.stopTest();

    //No query rows exist in org and query invocations not called. Just check that correct method is used
    System.assert(
      mock.getLookupRollupSummaryByDeveloperNameOrIdCalled,
      'no SOQL queries should have been used'
    );
    System.assertEquals(
      'D_Summary',
      String.valueOf(summaries[0].record.get('DeveloperName')),
      'The summary with the specified developer name should be returned'
    );
  }

  @isTest
  private static void selectById_ForEdit_MDT() {
    MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false, true);
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

    RollupSummariesSelector rollupSelector = new RollupSummariesSelector(false, true);
    rollupSelector.m_customMetadataSelector = mock;

    Test.startTest();

    //There are no records in the database, just use an empty Set to check against query limits
    List<RollupSummary> summaries = rollupSelector.selectById(
      new Set<String>{ '00X00000000000000D' }
    );

    Test.stopTest();

    //No query rows exist in org and query invocations not called. Just check that correct method is used
    System.assert(
      mock.getLookupRollupSummariesForEditCalled,
      'SOQL queries should have been used'
    );
  }

  @isTest
  private static void selectById_ForEdit_queryValidation_MDT() {
    RollupSummariesSelector.CustomMetadataSelector metadataSelector = new RollupSummariesSelector.CustomMetadataSelector(
      false,
      true
    );

    System.QueryException unexpectedEx;
    Test.startTest();

    try {
      metadataSelector.selectById(
        new Set<String>{ '00X00000000000000D' }
      );
    } catch(System.QueryException ex) {
      unexpectedEx = ex;
    }

    Test.stopTest();

    System.assertEquals(
      null,
      unexpectedEx,
      'SOQL query should not throw an exception'
    );
  }


  private class MockedCustomMetadataSelector extends RollupSummariesSelector.CustomMetadataSelector {
    Boolean getLookupRollupSummariesForEditCalled = false;
    Boolean getLookupRollupSummariesNotForEditCalled = false;
    Boolean getLookupRollupSummaryByDeveloperNameOrIdCalled = false;
    String prefix = LookupRollupSummary2__mdt.sObjectType.getDescribe()
      .getKeyPrefix();
    Map<String, LookupRollupSummary2__mdt> summariesByDeveloperName = new Map<String, LookupRollupSummary2__mdt>{
      'D_Summary' => new LookupRollupSummary2__mdt(
        Id = prefix + '00000000000000D',
        Label = 'D Summary',
        DeveloperName = 'D_Summary',
        ParentObject__c = 'A',
        ChildObject__c = 'X',
        RelationshipField__c = '1',
        CalculationMode__c = 'Realtime',
        Active__c = true
      ),
      'A_Summary' => new LookupRollupSummary2__mdt(
        Id = prefix + '00000000000000A',
        Label = 'A Summary',
        DeveloperName = 'A_Summary',
        ParentObject__c = 'B',
        ChildObject__c = 'X',
        RelationshipField__c = '1',
        CalculationMode__c = 'Realtime',
        Active__c = true
      ),
      'C_Summary' => new LookupRollupSummary2__mdt(
        Id = prefix + '00000000000000C',
        Label = 'C Summary',
        DeveloperName = 'C_Summary',
        ParentObject__c = 'A',
        ChildObject__c = 'Y',
        RelationshipField__c = '2',
        CalculationMode__c = 'Realtime',
        Active__c = false
      ),
      'B_Summary' => new LookupRollupSummary2__mdt(
        Id = prefix + '00000000000000B',
        Label = 'B Summary',
        DeveloperName = 'B_Summary',
        ParentObject__c = 'B',
        ChildObject__c = 'Y',
        RelationshipField__c = '2',
        CalculationMode__c = 'Developer',
        Active__c = true
      ),
      'E_Summary' => new LookupRollupSummary2__mdt(
        Id = prefix + '00000000000000E',
        Label = 'E Summary',
        DeveloperName = 'E_Summary',
        ParentObject__c = 'B',
        ChildObject__c = 'Z',
        RelationshipField__c = '3',
        CalculationMode__c = 'Process_Builder',
        Active__c = true
      )
    };

    Map<String, LookupRollupSummary2__mdt> summariesById = new Map<String, LookupRollupSummary2__mdt>{
      summariesByDeveloperName.get('D_Summary')
        .Id => summariesByDeveloperName.get('D_Summary'),
      summariesByDeveloperName.get('A_Summary')
        .Id => summariesByDeveloperName.get('A_Summary'),
      summariesByDeveloperName.get('C_Summary')
        .Id => summariesByDeveloperName.get('C_Summary'),
      summariesByDeveloperName.get('B_Summary')
        .Id => summariesByDeveloperName.get('B_Summary'),
      summariesByDeveloperName.get('E_Summary')
        .Id => summariesByDeveloperName.get('E_Summary')
    };

    public MockedCustomMetadataSelector(boolean enforceSecurity) {
      super(enforceSecurity);
    }

    private MockedCustomMetadataSelector(
      boolean enforceSecurity,
      boolean forEdit
    ) {
      super(enforceSecurity, forEdit);
    }

    protected override List<SObject> getLookupRollupSummariesWithParameters(
      String query,
      List<Object> tmpVars
    ) {
      this.getLookupRollupSummariesForEditCalled = true;
      return this.summariesByDeveloperName.values();
    }

    protected override List<SObject> getLookupRollupSummaries() {
      this.getLookupRollupSummariesNotForEditCalled = true;
      return this.summariesByDeveloperName.values();
    }

    protected override SObject getLookupRollupSummaryByDeveloperNameOrId(
      String developerNameOrId
    ) {
      this.getLookupRollupSummaryByDeveloperNameOrIdCalled = true;
      if (this.summariesByDeveloperName.get(developerNameOrId) != null) {
        return this.summariesByDeveloperName.get(developerNameOrId);
      } else if (this.summariesById.get(developerNameOrId) != null) {
        return this.summariesById.get(developerNameOrId);
      } else {
        return null;
      }
    }
  }
}

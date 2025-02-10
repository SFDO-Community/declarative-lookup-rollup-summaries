@IsTest
private class RollupServiceMergeTest {
  // standard merge logic - https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_merge_statements.htm

  /*
  used to validate that a standard merge path is functional
  the expectation is that when DLRS sees a merge it will add a
  scheduled item record so the surving record can get recalculated
  */
  @IsTest
  static void testMergeWithMergedObjectBothParentAndChild() {
    mockContactRollupCache();
    // create a few contacts, merge them together
    Contact c1 = new Contact(LastName = 'Test1');
    Contact c2 = new Contact(LastName = 'Test2');
    insert new List<Contact>{ c1, c2 };
    Test.startTest();
    merge c1 c2;
    Test.stopTest();

    // make sure a scheduled item record was added as a result of the merge
    List<LookupRollupSummaryScheduleItems__c> items = [
      SELECT Id, ParentId__c, QualifiedParentID__c
      FROM LookupRollupSummaryScheduleItems__c
    ];
    Assert.areEqual(1, items.size(), 'Unexpected Rollup Items:' + items);
    LookupRollupSummaryScheduleItems__c i = items[0];
    Assert.areEqual(c1.Id + '#m0000000000000000E', i.QualifiedParentID__c);
  }

  /*
  this doesn't depend on the triggers, it allows us to prove that we understand
  the setup for the same scenario as above and helps to concicely test this one area of code
  it is also validation for proving we can use this pattern for additional scenarios
  */
  @IsTest
  static void testDirectMergeWithDelete() {
    mockContactRollupCache();

    // simulate a record with a merged record id
    Contact c1 = (Contact) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'Id' => '00300000000000000B',
          'MasterRecordId' => '00300000000000000A'
        }
      ),
      Schema.Contact.class
    );

    // simulate AFTER_DELETE trigger where record has a 'MasterRecordId' but Trigger.new is null
    RollupService.handleRollups(
      new Map<Id, SObject>{ c1.Id => c1 },
      null,
      Schema.Contact.getSObjectType(),
      new List<RollupSummaries.CalculationMode>{
        RollupSummaries.CalculationMode.Realtime
      }
    );

    // make sure a scheduled item record was added as a result of the merge code
    List<LookupRollupSummaryScheduleItems__c> items = [
      SELECT Id, ParentId__c, QualifiedParentID__c
      FROM LookupRollupSummaryScheduleItems__c
    ];
    Assert.areEqual(1, items.size(), 'Unexpected Rollup Items:' + items);
    LookupRollupSummaryScheduleItems__c i = items[0];
    Assert.areEqual(
      c1.MasterRecordId + '#m0000000000000000E',
      i.QualifiedParentID__c
    );
  }

  /*
    simulate merge scenarios on cases
    orgs can be configured for two different merge models on cases
    delete merged case or keep it and set it to a specific status
    because the test class can't change this setting for the org we will
    simulate each of these scenarios
  */

  /**
   * if the case is setup to match other merge behavior, deleting the merged record
   */
  @IsTest
  static void testMergeCaseWithDelete() {
    mockCaseRollupCache();

    // simulate a record with a merged record id
    Case c1 = (Case) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'Id' => '50000000000000000B',
          'MasterRecordId' => '50000000000000000A'
        }
      ),
      Schema.Case.class
    );

    // simulate AFTER_DELETE trigger where record has a 'MasterRecordId' but Trigger.new is null
    RollupService.handleRollups(
      new Map<Id, SObject>{ c1.Id => c1 },
      null,
      Schema.Case.getSObjectType(),
      new List<RollupSummaries.CalculationMode>{
        RollupSummaries.CalculationMode.Realtime
      }
    );

    // make sure a scheduled item record was added as a result of the merge code
    List<LookupRollupSummaryScheduleItems__c> items = [
      SELECT Id, ParentId__c, QualifiedParentID__c
      FROM LookupRollupSummaryScheduleItems__c
    ];
    Assert.areEqual(1, items.size(), 'Unexpected Rollup Items:' + items);
    LookupRollupSummaryScheduleItems__c i = items[0];
    Assert.areEqual(
      c1.MasterRecordId + '#m0000000000000000E',
      i.QualifiedParentID__c
    );
  }

  // case w/ keep
  @IsTest
  static void testMergeCaseWithKeep() {
    mockCaseRollupCache();

    // simulate a record with a merged record id
    Case cOld = (Case) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'Id' => '50000000000000000B',
          'MasterRecordId' => null
        }
      ),
      Schema.Case.class
    );
    Case cNew = (Case) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'Id' => '50000000000000000B',
          'MasterRecordId' => '50000000000000000A'
        }
      ),
      Schema.Case.class
    );

    // simulate AFTER_UPDATE trigger where record has a 'MasterRecordId' but Trigger.new is null
    RollupService.handleRollups(
      new Map<Id, SObject>{ cOld.Id => cOld },
      new Map<Id, SObject>{ cNew.Id => cNew },
      Schema.Case.getSObjectType(),
      new List<RollupSummaries.CalculationMode>{
        RollupSummaries.CalculationMode.Realtime
      }
    );

    // make sure a scheduled item record was added as a result of the merge code
    List<LookupRollupSummaryScheduleItems__c> items = [
      SELECT Id, ParentId__c, QualifiedParentID__c
      FROM LookupRollupSummaryScheduleItems__c
    ];
    Assert.areEqual(1, items.size(), 'Unexpected Rollup Items:' + items);
    LookupRollupSummaryScheduleItems__c i = items[0];
    Assert.areEqual(
      cNew.MasterRecordId + '#m0000000000000000E',
      i.QualifiedParentID__c
    );
  }

  // case w/ edit on keep
  @IsTest
  static void testEditMergedCase() {
    mockCaseRollupCache();

    // simulate a record with a merged record id
    Case cOld = (Case) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'Id' => '50000000000000000B',
          'MasterRecordId' => '50000000000000000A',
          'Subject' => 'Subject 123'
        }
      ),
      Schema.Case.class
    );
    Case cNew = (Case) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'Id' => '50000000000000000B',
          'MasterRecordId' => '50000000000000000A',
          'Subject' => 'Subject 456'
        }
      ),
      Schema.Case.class
    );

    // simulate AFTER_DELETE trigger where record has a 'MasterRecordId' but Trigger.new is null
    RollupService.handleRollups(
      new Map<Id, SObject>{ cOld.Id => cOld },
      new Map<Id, SObject>{ cNew.Id => cNew },
      Schema.Case.getSObjectType(),
      new List<RollupSummaries.CalculationMode>{
        RollupSummaries.CalculationMode.Realtime
      }
    );

    // make sure a scheduled item record was added as a result of the merge code
    List<LookupRollupSummaryScheduleItems__c> items = [
      SELECT Id, ParentId__c, QualifiedParentID__c
      FROM LookupRollupSummaryScheduleItems__c
    ];
    Assert.areEqual(0, items.size(), 'Unexpected Rollup Items:' + items);
  }

  static void mockContactRollupCache() {
    String prefix = LookupRollupSummary2__mdt.sObjectType.getDescribe()
      .getKeyPrefix();
    List<LookupRollupSummary2__mdt> rollups = new List<LookupRollupSummary2__mdt>{
      new LookupRollupSummary2__mdt(
        Id = prefix + '00000000000000D',
        Label = 'Contact to Account',
        DeveloperName = 'Contact_to_Account',
        ParentObject__c = 'Account',
        ChildObject__c = 'Contact',
        RelationshipField__c = 'AccountId',
        FieldToAggregate__c = 'Id',
        AggregateOperation__c = 'Count',
        AggregateResultField__c = 'NumberOfEmployees',
        CalculationMode__c = 'Realtime',
        AggregateAllRows__c = false,
        Active__c = true
      ),
      new LookupRollupSummary2__mdt(
        Id = prefix + '00000000000000E',
        Label = 'Asset to Contact',
        DeveloperName = 'Asset_To_Contact',
        ParentObject__c = 'Contact',
        ChildObject__c = 'Asset',
        RelationshipField__c = 'ContactId',
        RelationshipCriteriaFields__c = 'ProductCode',
        FieldToAggregate__c = 'SerialNumber',
        AggregateOperation__c = 'First',
        AggregateResultField__c = 'FirstName',
        CalculationMode__c = 'Realtime',
        AggregateAllRows__c = false,
        Active__c = true
      )
    };
    RollupSummariesSelector.setRollupCache(
      false,
      false,
      RollupSummary.toList(rollups)
    );
  }

  static void mockCaseRollupCache() {
    String prefix = LookupRollupSummary2__mdt.sObjectType.getDescribe()
      .getKeyPrefix();
    List<LookupRollupSummary2__mdt> rollups = new List<LookupRollupSummary2__mdt>{
      new LookupRollupSummary2__mdt(
        Id = prefix + '00000000000000D',
        Label = 'Case to Contact',
        DeveloperName = 'Case_to_Contact',
        ParentObject__c = 'Contact',
        ChildObject__c = 'Case',
        RelationshipField__c = 'ContactId',
        RelationshipCriteriaFields__c = 'Subject',
        FieldToAggregate__c = 'Id',
        AggregateOperation__c = 'First',
        AggregateResultField__c = 'FirstName',
        CalculationMode__c = 'Realtime',
        AggregateAllRows__c = false,
        Active__c = true
      ),
      new LookupRollupSummary2__mdt(
        Id = prefix + '00000000000000E',
        Label = 'Comment to Case',
        DeveloperName = 'Comment_to_Case',
        ParentObject__c = 'Case',
        ChildObject__c = 'CaseComment',
        RelationshipField__c = 'ParentId',
        RelationshipCriteriaFields__c = 'CommentBody',
        FieldToAggregate__c = 'CommentBody',
        AggregateOperation__c = 'First',
        AggregateResultField__c = 'Description',
        CalculationMode__c = 'Realtime',
        AggregateAllRows__c = false,
        Active__c = true
      )
    };
    RollupSummariesSelector.setRollupCache(
      false,
      false,
      RollupSummary.toList(rollups)
    );
  }
}

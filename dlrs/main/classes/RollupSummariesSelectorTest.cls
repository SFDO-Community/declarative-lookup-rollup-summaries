@isTest
private with sharing class RollupSummariesSelectorTest {
    @isTest
    private static void selectAll_notForEdit() {
        MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false);
        RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;
        
        Test.startTest();

        List<RollupSummary> summaries =  metadataSelector.selectAll();

        Test.stopTest();

        //No query rows exist in org and query invocations not called. Just check that correct method is used
        System.assert(mock.getLookupRollupSummariesNotForEditCalled, 'No SOQL queries should have been used');
    }

    @isTest
    private static void selectAll_ForEdit() {
        MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false, true);
        RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;
    
        Test.startTest();

        List<RollupSummary> summaries =  metadataSelector.selectAll();

        Test.stopTest();

        //No query rows exist in org and query invocations not called. Just check that correct method is used
        System.assert(mock.getLookupRollupSummariesForEditCalled, 'SOQL queries should have been used');
    }

    @isTest
    private static void selectAll_NotForEdit_SortOrder() {
        RollupSummariesSelector.CustomMetadataSelector metadataSelector 
            = new MockedCustomMetadataSelector(false);

        Test.startTest();
        List<RollupSummary> summaries =  metadataSelector.selectAll();
        Test.stopTest();

        System.assertEquals(5, summaries.size(), 'All of the records should have been returned');

        System.assertEquals('A Summary', String.valueOf(summaries[0].record.get('Label')), 'The summaries should be returned in ASC order by Label');
        System.assertEquals('B Summary', String.valueOf(summaries[1].record.get('Label')), 'The summaries should be returned in ASC order by Label');
        System.assertEquals('C Summary', String.valueOf(summaries[2].record.get('Label')), 'The summaries should be returned in ASC order by Label');
        System.assertEquals('D Summary', String.valueOf(summaries[3].record.get('Label')), 'The summaries should be returned in ASC order by Label');
        System.assertEquals('E Summary', String.valueOf(summaries[4].record.get('Label')), 'The summaries should be returned in ASC order by Label');
    }

    @isTest
    private static void selectActiveByUniqueName_notForEdit() {
        MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false);
        RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

        Test.startTest();

        List<RollupSummary> summaries =  metadataSelector.selectActiveByUniqueName(new Set<String>{'A_Summary'});

        Test.stopTest();

        //No query rows exist in org and query invocations not called. Just check that correct method is used
        System.assert(mock.getLookupRollupSummaryByDeveloperNameCalled, 'no SOQL queries should have been used');
    }

    @isTest
    private static void selectActiveByUniqueName_ForEdit() {
        MockedCustomMetadataSelector mock = new MockedCustomMetadataSelector(false, true);
        RollupSummariesSelector.CustomMetadataSelector metadataSelector = mock;

        Test.startTest();

        //There are no records in the database, just use an empty Set to check against query limits
        List<RollupSummary> summaries =  metadataSelector.selectActiveByUniqueName(new Set<String>());

        Test.stopTest();

        //No query rows exist in org and query invocations not called. Just check that correct method is used
        System.assert(mock.getLookupRollupSummariesForEditCalled, 'SOQL queries should have been used');
    }

    @isTest
    private static void selectActiveByUniqueName_NotForEdit_SortOrder() {
        RollupSummariesSelector.CustomMetadataSelector metadataSelector 
            = new MockedCustomMetadataSelector(false);

        Set<String> uniqueNames = new Set<String>{
            'A_Summary',
            'B_Summary',
            'C_Summary',
            'D_Summary',
            'E_Summary'
        };

        Test.startTest();
        List<RollupSummary> summaries =  metadataSelector.selectActiveByUniqueName(uniqueNames);
        Test.stopTest();

        System.assertEquals(4, summaries.size(), 'Only the active summaries should be returned');

        System.assertEquals('D_Summary', String.valueOf(summaries[0].record.get('DeveloperName')), 'The summaries should be returned in ASC order by ParentObject__c, and then RelationshipField__c');
        System.assertEquals('A_Summary', String.valueOf(summaries[1].record.get('DeveloperName')), 'The summaries should be returned in ASC order by ParentObject__c, and then RelationshipField__c');
        System.assertEquals('B_Summary', String.valueOf(summaries[2].record.get('DeveloperName')), 'The summaries should be returned in ASC order by ParentObject__c, and then RelationshipField__c');
        System.assertEquals('E_Summary', String.valueOf(summaries[3].record.get('DeveloperName')), 'The summaries should be returned in ASC order by ParentObject__c, and then RelationshipField__c');
    }

    private class MockedCustomMetadataSelector extends RollupSummariesSelector.CustomMetadataSelector {
        Boolean getLookupRollupSummariesForEditCalled = false;
        Boolean getLookupRollupSummariesNotForEditCalled = false;
        Boolean getLookupRollupSummaryByDeveloperNameCalled = false;

        Map<String, LookupRollupSummary2__mdt> summariesByDeveloperName = new Map<String, LookupRollupSummary2__mdt> {
            'D_Summary' => new LookupRollupSummary2__mdt(Label = 'D Summary', DeveloperName = 'D_Summary', ParentObject__c = 'A', RelationshipField__c = '1', Active__c = true),
            'A_Summary' => new LookupRollupSummary2__mdt(Label = 'A Summary', DeveloperName = 'A_Summary', ParentObject__c = 'B', RelationshipField__c = '1', Active__c = true),
            'C_Summary' => new LookupRollupSummary2__mdt(Label = 'C Summary', DeveloperName = 'C_Summary', ParentObject__c = 'A', RelationshipField__c = '2', Active__c = false),
            'B_Summary' => new LookupRollupSummary2__mdt(Label = 'B Summary', DeveloperName = 'B_Summary', ParentObject__c = 'B', RelationshipField__c = '2', Active__c = true),
            'E_Summary' => new LookupRollupSummary2__mdt(Label = 'E Summary', DeveloperName = 'E_Summary', ParentObject__c = 'B', RelationshipField__c = '3', Active__c = true)
        };

        public MockedCustomMetadataSelector(boolean enforceSecurity) {
            super(enforceSecurity);
        }

        private MockedCustomMetadataSelector(boolean enforceSecurity, boolean forEdit) {
            super(enforceSecurity, forEdit);
        }

        protected override List<SObject> getLookupRollupSummaries(String query, List<Object> tmpVars) {
            this.getLookupRollupSummariesForEditCalled = true;
            return this.summariesByDeveloperName.values();
        }

        protected override List<SObject> getLookupRollupSummaries() {
            this.getLookupRollupSummariesNotForEditCalled = true;
            return this.summariesByDeveloperName.values();
        }

        protected override SObject getLookupRollupSummaryByDeveloperName(String developerName) {
            this.getLookupRollupSummaryByDeveloperNameCalled = true;
            return this.summariesByDeveloperName.get(developerName);
        }
    }
}

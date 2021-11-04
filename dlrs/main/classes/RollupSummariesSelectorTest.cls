@isTest
private with sharing class RollupSummariesSelectorTest {
    //Tests for CustomMetadataSelector
    //new RollupSummariesSelector.CustomMetadataSelector()

    // public List<Schema.SObjectField> getSObjectFieldList() {
    // public Schema.SObjectType getSObjectType() {
    // public List<RollupSummary> selectById(Set<String> idSet) {
    // public List<RollupSummary> selectByDeveloperName(Set<String> idSet) {
    // public List<RollupSummary> selectActiveByChildObject(
    // public List<RollupSummary> selectActiveByChildObject(
    // public List<RollupSummary> selectActiveByUniqueName(
    // public List<RollupSummary> selectAll() 

    @isTest
    private static void selectAll_notForEdit() {
        RollupSummariesSelector.CustomMetadataSelector metadataSelector 
            = new RollupSummariesSelector.CustomMetadataSelector(false);
    
        
        Test.startTest();

        List<RollupSummary> summaries =  metadataSelector.selectAll();
        Integer queryRows = Limits.getQueryRows();

        Test.stopTest();

        System.assertEquals(0, queryRows, 'No SOQL query rows should have been consumed');
    }

    @isTest
    private static void selectAll_ForEdit() {
        RollupSummariesSelector.CustomMetadataSelector metadataSelector 
            = new RollupSummariesSelector.CustomMetadataSelector(false, true);
    
        
        Test.startTest();

        List<RollupSummary> summaries =  metadataSelector.selectAll();
        Integer queryRows = Limits.getQueryRows();

        Test.stopTest();

        System.assertEquals(1, queryRows, 'SOQL query rows should have been consumed when using forEdit');
    }
}

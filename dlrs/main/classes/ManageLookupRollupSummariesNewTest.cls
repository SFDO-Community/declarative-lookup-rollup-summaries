@isTest
public class ManageLookupRollupSummariesNewTest {
    static testMethod void myUnitTest1() {
        ManageLookupRollupSummariesNewController mrl = new ManageLookupRollupSummariesNewController();
        //mrl.getLookups();
        mrl.init();
        mrl.load();

        LookupRollupSummary2__mdt rollupSummary = new LookupRollupSummary2__mdt();
        Map<String, Object> fields = (Map<String, Object>) JSON.deserializeUntyped(JSON.serializePretty(rollupSummary));
        fields.put(LookupRollupSummary2__mdt.Label.getDescribe().getName(), 'Total Opportunities greater than 200 into Annual Revenue on Account');
        fields.put(LookupRollupSummary2__mdt.DeveloperName.getDescribe().getName(), 'AccountRollup');			
        fields.put(LookupRollupSummary2__mdt.ParentObject__c.getDescribe().getName(),'Account');
        fields.put(LookupRollupSummary2__mdt.ChildObject__c.getDescribe().getName(),'Contact');
        fields.put(LookupRollupSummary2__mdt.RelationShipField__c.getDescribe().getName(),'AccountId');
        fields.put(LookupRollupSummary2__mdt.RelationShipCriteria__c.getDescribe().getName(), null);
        fields.put(LookupRollupSummary2__mdt.FieldToAggregate__c.getDescribe().getName(), 'LastCURequestDate');
        fields.put(LookupRollupSummary2__mdt.AggregateOperation__c.getDescribe().getName(), 'Count');
        fields.put(LookupRollupSummary2__mdt.AggregateResultField__c.getDescribe().getName(), 'AnnualRevenue');
        fields.put(LookupRollupSummary2__mdt.Active__c.getDescribe().getName(), false);
        fields.put(LookupRollupSummary2__mdt.CalculationMode__c.getDescribe().getName(),'Realtime');
        fields.put(LookupRollupSummary2__mdt.TestCodeParent__c.getDescribe().getName(), 'System.assertEquals(1,1);');
        fields.put(LookupRollupSummary2__mdt.TestCodeSeeAllData__c.getDescribe().getName(), true);
        rollupSummary = (LookupRollupSummary2__mdt) JSON.deserialize(JSON.serialize(fields), LookupRollupSummary2__mdt.class);

        mrl.LookupRollupSummary = rollupSummary;
        mrl.selectedParentField = 'AnnualRevenue';
        mrl.selectedChildField = 'Birthdate';
        mrl.save();
        mrl.LookupRollupSummary = mrl.LookupRollupSummary;
        mrl.save();
        mrl.deleteX();
        mrl.hideMessage();
        mrl.getCalculationModes();
        mrl.getAggregateOperations();
        mrl.getCalculationSharingModes();
        mrl.getParentObjList();
        mrl.selectedParentObject = 'Account';
        mrl.confirmParentObject();
        mrl.selectedChildObject = 'Contact';
        mrl.confirmChildObject();
        mrl.updateChildField();
        mrl.updateParentField();
        mrl.updateRField();
    }
    static testMethod void myUnitTest2(){
        ManageLookupRollupSummariesNewController mrl = new ManageLookupRollupSummariesNewController();
        mrl.selectedParentObject = null;
        mrl.confirmParentObject();
    }

    @isTest
    private static void controller_saves_and_reloads_with_correct_parameters() {
        PageReference wizard = Page.managelookuprollupsummaries_New;
        Test.setCurrentPage(wizard);
        Test.setMock(WebServiceMock.class, new MetadataServiceCalloutMock());

        LookupRollupSummary2__mdt rollupSummary = new LookupRollupSummary2__mdt();
        Map<String, Object> fields = (Map<String, Object>) JSON.deserializeUntyped(JSON.serializePretty(rollupSummary));
        fields.put(LookupRollupSummary2__mdt.Label.getDescribe().getName(), 'Total Opportunities greater than 200 into Annual Revenue on Account');
        fields.put(LookupRollupSummary2__mdt.DeveloperName.getDescribe().getName(), 'AccountRollup');			
        fields.put(LookupRollupSummary2__mdt.ParentObject__c.getDescribe().getName(),'Account');
        fields.put(LookupRollupSummary2__mdt.ChildObject__c.getDescribe().getName(),'Contact');
        fields.put(LookupRollupSummary2__mdt.RelationShipField__c.getDescribe().getName(),'AccountId');
        fields.put(LookupRollupSummary2__mdt.RelationShipCriteria__c.getDescribe().getName(), null);
        fields.put(LookupRollupSummary2__mdt.FieldToAggregate__c.getDescribe().getName(), 'LastCURequestDate');
        fields.put(LookupRollupSummary2__mdt.AggregateOperation__c.getDescribe().getName(), 'Count');
        fields.put(LookupRollupSummary2__mdt.AggregateResultField__c.getDescribe().getName(), 'AnnualRevenue');
        fields.put(LookupRollupSummary2__mdt.Active__c.getDescribe().getName(), false);
        fields.put(LookupRollupSummary2__mdt.CalculationMode__c.getDescribe().getName(),'Realtime');
        fields.put(LookupRollupSummary2__mdt.TestCodeParent__c.getDescribe().getName(), 'System.assertEquals(1,1);');
        fields.put(LookupRollupSummary2__mdt.TestCodeSeeAllData__c.getDescribe().getName(), true);
        rollupSummary = (LookupRollupSummary2__mdt) JSON.deserialize(JSON.serialize(fields), LookupRollupSummary2__mdt.class);

        ManageLookupRollupSummariesNewController controller = new ManageLookupRollupSummariesNewController();

        controller.LookupRollupSummary = rollupSummary;

        Test.startTest();
        PageReference nextPage = controller.save();
        Test.stopTest();

        String namespace = Utilities.namespace();
        String expectedUrl = '/apex/'+ (namespace.length() > 0 ? namespace + '__' : '') + 'managelookuprollupsummaries';
        System.assertEquals(true, nextPage.getUrl().startsWith(expectedUrl), 'The redirect went to the wrong place');
        System.assertEquals('AccountRollup', nextPage.getParameters().get('developerName'), 'The parameter was not set correctly');
    }

    @isTest
    private static void rollup_without_parent_object_causes_field_exception() {
        PageReference wizard = Page.managelookuprollupsummaries_New;
        Test.setCurrentPage(wizard);
        Test.setMock(WebServiceMock.class, new MetadataServiceCalloutMock());

        LookupRollupSummary2__mdt rollupSummary = new LookupRollupSummary2__mdt();
        Map<String, Object> fields = (Map<String, Object>) JSON.deserializeUntyped(JSON.serializePretty(rollupSummary));
        fields.put(LookupRollupSummary2__mdt.Label.getDescribe().getName(), 'Total Opportunities greater than 200 into Annual Revenue on Account');
        fields.put(LookupRollupSummary2__mdt.DeveloperName.getDescribe().getName(), 'AccountRollup');			
        //fields.put(LookupRollupSummary2__mdt.ParentObject__c.getDescribe().getName(),'Account');
        fields.put(LookupRollupSummary2__mdt.ChildObject__c.getDescribe().getName(),'Contact');
        fields.put(LookupRollupSummary2__mdt.RelationShipField__c.getDescribe().getName(),'AccountId');
        fields.put(LookupRollupSummary2__mdt.RelationShipCriteria__c.getDescribe().getName(), null);
        fields.put(LookupRollupSummary2__mdt.FieldToAggregate__c.getDescribe().getName(), 'LastCURequestDate');
        fields.put(LookupRollupSummary2__mdt.AggregateOperation__c.getDescribe().getName(), 'Count');
        fields.put(LookupRollupSummary2__mdt.AggregateResultField__c.getDescribe().getName(), 'AnnualRevenue');
        fields.put(LookupRollupSummary2__mdt.Active__c.getDescribe().getName(), false);
        fields.put(LookupRollupSummary2__mdt.CalculationMode__c.getDescribe().getName(),'Realtime');
        fields.put(LookupRollupSummary2__mdt.TestCodeParent__c.getDescribe().getName(), 'System.assertEquals(1,1);');
        fields.put(LookupRollupSummary2__mdt.TestCodeSeeAllData__c.getDescribe().getName(), true);
        rollupSummary = (LookupRollupSummary2__mdt) JSON.deserialize(JSON.serialize(fields), LookupRollupSummary2__mdt.class);

        ManageLookupRollupSummariesNewController controller = new ManageLookupRollupSummariesNewController();

        controller.LookupRollupSummary = rollupSummary;

        Test.startTest();
        PageReference nextPage = controller.save();
        Test.stopTest();

        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size(), 'There should only be one error message');
        System.assertEquals('Parent Object: Object does not exist.', messages[0].getSummary(), 'Unexpected error message received');
    }

    @isTest
    private static void rollup_summing_dates_causes_record_level_error_to_be_added() {
        PageReference wizard = Page.managelookuprollupsummaries_New;
        Test.setCurrentPage(wizard);
        Test.setMock(WebServiceMock.class, new MetadataServiceCalloutMock());

        LookupRollupSummary2__mdt rollupSummary = new LookupRollupSummary2__mdt();
        Map<String, Object> fields = (Map<String, Object>) JSON.deserializeUntyped(JSON.serializePretty(rollupSummary));
        fields.put(LookupRollupSummary2__mdt.Label.getDescribe().getName(), 'Total Opportunities greater than 200 into Annual Revenue on Account');
        fields.put(LookupRollupSummary2__mdt.DeveloperName.getDescribe().getName(), 'AccountRollup');			
        fields.put(LookupRollupSummary2__mdt.ParentObject__c.getDescribe().getName(),'Account');
        fields.put(LookupRollupSummary2__mdt.ChildObject__c.getDescribe().getName(),'Contact');
        fields.put(LookupRollupSummary2__mdt.RelationShipField__c.getDescribe().getName(),'AccountId');
        fields.put(LookupRollupSummary2__mdt.RelationShipCriteria__c.getDescribe().getName(), null);
        fields.put(LookupRollupSummary2__mdt.FieldToAggregate__c.getDescribe().getName(), 'LastModifiedDate');
        fields.put(LookupRollupSummary2__mdt.AggregateOperation__c.getDescribe().getName(), 'Sum');
        fields.put(LookupRollupSummary2__mdt.AggregateResultField__c.getDescribe().getName(), 'CreatedDate');
        fields.put(LookupRollupSummary2__mdt.Active__c.getDescribe().getName(), false);
        fields.put(LookupRollupSummary2__mdt.CalculationMode__c.getDescribe().getName(),'Realtime');
        fields.put(LookupRollupSummary2__mdt.TestCodeParent__c.getDescribe().getName(), 'System.assertEquals(1,1);');
        fields.put(LookupRollupSummary2__mdt.TestCodeSeeAllData__c.getDescribe().getName(), true);
        rollupSummary = (LookupRollupSummary2__mdt) JSON.deserialize(JSON.serialize(fields), LookupRollupSummary2__mdt.class);

        ManageLookupRollupSummariesNewController controller = new ManageLookupRollupSummariesNewController();

        controller.LookupRollupSummary = rollupSummary;

        Test.startTest();
        PageReference nextPage = controller.save();
        Test.stopTest();

        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size(), 'There should only be one error message');
        System.assertEquals('Sum/Avg doesnt looks like valid for dates ! Still want, then implement the IRollerCoaster yourself and change this class as required.', messages[0].getSummary(), 'Unexpected error message received');
    }

    @isTest
    private static void calling_confirm_child_object_with_no_child_object_throws_exception() {
        PageReference wizard = Page.managelookuprollupsummaries_New;
        Test.setCurrentPage(wizard);
        Test.setMock(WebServiceMock.class, new MetadataServiceCalloutMock());   
        
        ManageLookupRollupSummariesNewController controller = new ManageLookupRollupSummariesNewController();
        controller.selectedChildObject = null;

        Test.startTest();
        controller.confirmChildObject();
        Test.stopTest();

        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size(), 'There should only be one error message');
        System.assertEquals('Please Select the Child Object', messages[0].getDetail(), 'Unexpected error message received');
    }

    @isTest
    private static void relationship_fields_populated_successfully_when_there_are_multiple_fields() {
        PageReference wizard = Page.managelookuprollupsummaries_New;
        Test.setCurrentPage(wizard);
        Test.setMock(WebServiceMock.class, new MetadataServiceCalloutMock());

        LookupRollupSummary2__mdt rollupSummary = new LookupRollupSummary2__mdt();
        Map<String, Object> fields = (Map<String, Object>) JSON.deserializeUntyped(JSON.serializePretty(rollupSummary));
        fields.put(LookupRollupSummary2__mdt.Label.getDescribe().getName(), 'Total Opportunities greater than 200 into Annual Revenue on Account');
        fields.put(LookupRollupSummary2__mdt.DeveloperName.getDescribe().getName(), 'AccountRollup');			
        fields.put(LookupRollupSummary2__mdt.ParentObject__c.getDescribe().getName(),'Account');
        fields.put(LookupRollupSummary2__mdt.ChildObject__c.getDescribe().getName(),'Task');
        fields.put(LookupRollupSummary2__mdt.RelationShipField__c.getDescribe().getName(),'AccountId');
        fields.put(LookupRollupSummary2__mdt.RelationShipCriteria__c.getDescribe().getName(), null);
        fields.put(LookupRollupSummary2__mdt.FieldToAggregate__c.getDescribe().getName(), 'LastModifiedDate');
        fields.put(LookupRollupSummary2__mdt.AggregateOperation__c.getDescribe().getName(), 'Max');
        fields.put(LookupRollupSummary2__mdt.AggregateResultField__c.getDescribe().getName(), 'CreatedDate');
        fields.put(LookupRollupSummary2__mdt.Active__c.getDescribe().getName(), false);
        fields.put(LookupRollupSummary2__mdt.CalculationMode__c.getDescribe().getName(),'Realtime');
        fields.put(LookupRollupSummary2__mdt.TestCodeParent__c.getDescribe().getName(), 'System.assertEquals(1,1);');
        fields.put(LookupRollupSummary2__mdt.TestCodeSeeAllData__c.getDescribe().getName(), true);
        rollupSummary = (LookupRollupSummary2__mdt) JSON.deserialize(JSON.serialize(fields), LookupRollupSummary2__mdt.class);

        ManageLookupRollupSummariesNewController controller = new ManageLookupRollupSummariesNewController();
        controller.LookupRollupSummary = rollupSummary;
        controller.selectedParentObject = 'Account';
        controller.getParentObjList();
        controller.confirmParentObject();
        controller.selectedChildObject = 'Task';

        Test.startTest();
        controller.confirmChildObject();
        Test.stopTest();

        System.assertEquals(true, controller.isMultiSelectRField, 'The Multiple relationship flag should be set');
        // can't really be more specific than >1, in case Salesforce ever add another relationship between Account & Task
        System.assertEquals(true, controller.relationshipFields.size() > 1, 'Multiple relationship fields should exist');
    }
}
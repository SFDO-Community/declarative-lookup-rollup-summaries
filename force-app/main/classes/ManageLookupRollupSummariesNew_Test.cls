@isTest
public class ManageLookupRollupSummariesNew_Test {
    static testMethod void myUnitTest1() {
        ManageLookupRollupSummariesNewController mrl = new ManageLookupRollupSummariesNewController();
        mrl.getLookups();
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
}
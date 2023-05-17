public with sharing class WhereSiwygController {
    @AuraEnabled
    public static List<FieldData> getFieldsForObject(String objectName){
        try {
            List<Schema.DescribeSObjectResult> objDescRes = Schema.describeSObjects(new List<String>{objectName});
            List<FieldData> fields = new List<FieldData>();
            for(Schema.SObjectField f : objDescRes[0].fields.getMap().values()){
                fields.add(new FieldData(f));
            }
            return fields;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class FieldData{
        @AuraEnabled
        public String calculatedFormula;
        @AuraEnabled
        public String inlineHelpText;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Map<String, String> picklistValues;
        @AuraEnabled
        public List<String> referencesTo;
        @AuraEnabled
        public String relationshipName;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Boolean isFilterable;
        @AuraEnabled
        public Boolean isGroupable;
        @AuraEnabled
        public Boolean isSortable;

        public FieldData(Schema.SObjectField field){
            Schema.DescribeFieldResult r = field.getDescribe();
            this.calculatedFormula = r.getCalculatedFormula();
            this.inlineHelpText = r.getInlineHelpText();
            this.label =  r.getLabel();
            this.name = r.getName();
            
            this.relationshipName = r.getRelationshipName();
            this.type = r.getType().name();
            switch on r.getType() {
                when MultiPicklist, Picklist {
                    this.picklistValues = new Map<String, String>();
                    for(Schema.PicklistEntry pe : r.getPicklistValues()){
                        if(pe.active){
                            this.picklistValues.put(pe.value, pe.label);
                        }
                    }
                }
                when Reference {
                    this.referencesTo =  new List<String>();
                    for(Schema.SObjectType t : r.getReferenceTo()){
                        this.referencesTo.add(t.getDescribe().getName());
                    }
                }
            }
            this.isFilterable = r.isFilterable();
            this.isGroupable = r.isGroupable();
            this.isSortable = r.isSortable();
        }
    }
}
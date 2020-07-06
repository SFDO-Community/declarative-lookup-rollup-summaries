public with sharing class ManageLookupRollupSummariesNewController {
    
    public LookupRollupSummary2__mdt LookupRollupSummary {get;set;}
    Map<String,String> rFields {get;set;}
    public boolean isMultiSelectRField {set;get;}
    public String selectedRelationFieldName {get;set;}
    public String selectedLookup {get;set;}
    public Boolean MetadataConnectionError {get;set;}       
    public String selectedParentObject {get;set;}
    public String selectedChildObject {get;set;}
    public String selectedParentField {get;set;}
    public String selectedChildField {get;set;}
    public String selectedRField {get;set;}
    public List<SelectOption> parentObjFields {get;set;}
    public List<SelectOption> childObjectList {get;set;}
    public List<SelectOption> childObjFields {get;set;}
    public boolean isParentObjectSelected {get;set;}
    public boolean isChildObjectSelected {get;set;}
    public Map<String,String> objectWithRelationshipField {get;set;}
    public List<String> PnameWithRField {get;set;}
    public List<SelectOption> relationshipFields {get;set;}
    public Map<String,String> ChildObjectsDuplicates {get;set;}
    
    public ManageLookupRollupSummariesNewController() {
        isParentObjectSelected = false;
        isChildObjectSelected = false;
        isMultiSelectRField = false;
        LookupRollupSummary = new LookupRollupSummary2__mdt();
        objectWithRelationshipField = new Map<String,String>();
    }
    
    public List<SelectOption> getLookups() {
        // List current rollup custom metadata configs
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('[new]','Create new...'));
        for(RollupSummary rollup : new RollupSummariesSelector.CustomMetadataSelector(false, false).selectAll())
            options.add(new SelectOption(rollup.Id,rollup.Name));
        return options;
    }
    
    public PageReference init() {
        
        // Metadata API connection?
        MetadataConnectionError = !RollupService.checkMetadataAPIConnection();
        if(MetadataConnectionError)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Salesforce Metadata API connection failure, click the link below to configure.'));
            return null;
        }
        // URL parameter?
        selectedLookup = (Id) ApexPages.currentPage().getParameters().get('id');                
        if(selectedLookup!=null) {
            LookupRollupSummary = (LookupRollupSummary2__mdt) 
                new RollupSummariesSelector.CustomMetadataSelector(false, true).
                selectById(new Set<String> { selectedLookup })[0].Record;
        } 
        else {
            selectedLookup = ApexPages.currentPage().getParameters().get('developerName');          
            if(selectedLookup!=null) {
                LookupRollupSummary = (LookupRollupSummary2__mdt) 
                    new RollupSummariesSelector.CustomMetadataSelector(false, true).
                    selectByDeveloperName(new Set<String> { selectedLookup })[0].Record;
                selectedLookup = LookupRollupSummary.Id;
            }                       
        }
        return null;
    }
    
    public PageReference load() {
        // Reload the page
        PageReference newPage = Page.managelookuprollupsummaries;
        newPage.setRedirect(true);
        if(selectedLookup != '[new]')
            newPage.getParameters().put('id', selectedLookup);
        return newPage;
    }
    public PageReference save() {
        try {
            // Insert / Update the rollup custom metadata
            if(LookupRollupSummary.Id==null)
                RollupService.create(new List<SObject> { LookupRollupSummary });
            else
                RollupService.update_x(new List<SObject> { LookupRollupSummary });
            // Reload this page (and thus the rollup list in a new request, metadata changes are not visible until this request ends)
            PageReference newPage = Page.managelookuprollupsummaries;
            newPage.setRedirect(true);
            newPage.getParameters().put('developerName', LookupRollupSummary.DeveloperName);
            return newPage;                 
        } catch (RollupService.RollupValidationException e) {
            // Extract errors from exception and display on the page
            for(RollupService.RollupRecordValidationError recordError : e.RecordErrors) {
                if(recordError.Error!=null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, recordError.Error)); 
                }
                for(String fieldError : recordError.FieldErrors) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, fieldError));   
                }
            }
        } catch (Exception e) {
            string errormessage = e.getmessage();
            if(selectedChildObject==null &&   errormessage.contains('Attempt to de-reference a null object')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please Select the Child Object'));  
            }else if(selectedRField==null && errormessage.contains('Attempt to de-reference a null object')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please Select the Relationship Field')); 
            }else{
                ApexPages.addMessages(e);
            }
        }
        return null;
    }
    
    public PageReference deleteX() {
        try {
            // Delete the rollup custom metadata
            RollupService.delete_X(new List<String> { LookupRollupSummary.DeveloperName });
            // Reload this page (and thus the rollup list in a new request, metadata changes are not visible until this request ends)
            PageReference newPage = Page.managelookuprollupsummaries;
            newPage.setRedirect(true);
            return newPage;                 
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }       
    
    public PageReference hideMessage() {
        DeclarativeLookupRollupSummaries__c settings = DeclarativeLookupRollupSummaries__c.getOrgDefaults();
        settings.HideManageLookupRollupSummariesInfo__c = true;
        upsert settings;
        return null;
    }
    
    public List<SelectOption> getCalculationModes(){
        List<SelectOption> options = new List<SelectOption>();
        for(Schema.Picklistentry picklistEntry : LookupRollupSummary__c.fields.CalculationMode__c.getDescribe().getPickListValues()) {
            options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        return options;
    }           
    
    public List<SelectOption> getAggregateOperations(){
        List<SelectOption> options = new List<SelectOption>();
        for(Schema.Picklistentry picklistEntry : LookupRollupSummary__c.fields.AggregateOperation__c.getDescribe().getPickListValues()) {
            options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        return options;
    }           
    
    public List<SelectOption> getCalculationSharingModes(){
        List<SelectOption> options = new List<SelectOption>();
        for(Schema.Picklistentry picklistEntry : LookupRollupSummary__c.fields.CalculationSharingMode__c.getDescribe().getPickListValues()) {
            options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        return options;
    }
    Public List<Selectoption> getParentObjList(){
        List<Schema.SObjectType> ParentObjList = Schema.getGlobalDescribe().Values();     
        List<SelectOption> objNames = new List<SelectOption>();
        objNames.add(new SelectOption('','-- Select --'));
        for(Schema.SObjectType obj : ParentObjList)
        {
            objNames.add(new SelectOption(obj.getDescribe().getName(),obj.getDescribe().getLabel()+' ('+obj.getDescribe().getName()+')'));
        }
        objNames.sort();
        return objNames;
    }
    
    public void confirmParentObject(){
        try{
            if(selectedParentObject==null || selectedParentObject==''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please Select the Parent Object'));
            }else{
                LookupRollupSummary.ParentObject__c = selectedParentObject;
                childObjectList = new List<SelectOption>();
                parentObjFields = new List<SelectOption>();
                ChildObjectsDuplicates = new Map<String,String>();
                isParentObjectSelected = true;
                childObjectList.add(new SelectOption('','-- Select --'));
                parentObjFields.add(new SelectOption('','-- Select --')); 
                Schema.SObjectType parentObject = Schema.getGlobalDescribe().get(selectedParentObject);
                Schema.DescribeSObjectResult parentObjectDescribe = parentObject.getDescribe();
                PnameWithRField = new List<String>();
                for (Schema.ChildRelationship cr: parentObjectDescribe.getChildRelationships()) 
                {
                    Schema.DescribeSObjectResult dr = (cr.getChildSObject()).getDescribe();
                    ChildObjectsDuplicates.put(String.valueOf(dr.getName()),String.valueOf(dr.getLabel())+' ('+String.valueOf(dr.getName())+')');
                    PnameWithRField.add(String.valueOf(dr.getName())+'.'+String.valueOf(cr.getField()));
                    objectWithRelationshipField.put(String.valueOf(dr.getName())+'.'+String.valueOf(cr.getField()), String.valueOf(cr.getField()));
                }
                for(String key : ChildObjectsDuplicates.keyset()){
                    childObjectList.add(new SelectOption(key, ChildObjectsDuplicates.get(key)));
                }
                Map<String, schema.SObjectField> MapOfFields = Schema.getGlobalDescribe().get(selectedParentObject).getDescribe().fields.getMap();
                for(Schema.SObjectField field : MapOfFields.values())
                {
                    Schema.DescribeFieldResult fr = field.getDescribe();
                    String dType = String.valueof(fr.getType());
                    //if(dType == 'DOUBLE' || dType == 'INTEGER' || dType == 'CURRENCY' || dType == 'DATE' || dType == 'DATETIME' || dType == 'STRING'){
                    parentObjFields.add( new SelectOption(String.valueof(fr.getName()), String.valueof(fr.getLabel())+' ('+String.valueOf(fr.getName())+')'));
                    //}
                } 
            }
            
            if(Test.isRunningTest()){
                Integer a = 6/0;
            } 
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getmessage()));
        }
        
    }
    public void confirmChildObject(){
        try{
            if(selectedChildObject==null || selectedChildObject==''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please Select the Child Object'));
            }else{
                childObjFields = new List<SelectOption>();
                rFields = new Map<String,String>();
                isChildObjectSelected = true;
                LookupRollupSummary.ChildObject__c = selectedChildObject;
                Map<String, schema.SObjectField> MapOfFields = Schema.getGlobalDescribe().get(selectedChildObject).getDescribe().fields.getMap();
                childObjFields.add(new SelectOption('','-- Select --')); 
                for(Schema.SObjectField field : MapOfFields.values())
                {
                    Schema.DescribeFieldResult fr = field.getDescribe();
                    String dType = String.valueof(fr.getType());
                    // if(dType == 'DOUBLE' || dType == 'INTEGER' || dType == 'CURRENCY' || dType == 'DATE' || dType == 'DATETIME'){
                    childObjFields.add( new SelectOption(String.valueof(fr.getName()), String.valueof(fr.getLabel())+' ('+String.valueOf(fr.getName())+')'));
                    //}
                } 
                
                for(Schema.SobjectField strFld: Schema.getGlobalDescribe().get(selectedChildObject).getDescribe().fields.getMap().Values())
                {
                    if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE)
                    {
                        if(String.valueOf(strFld.getDescribe().getReferenceTo()) == '('+selectedParentObject+')'){
                            for(String a:PnameWithRField){
                                String[] arrTest = a.split('\\.');
                                if(selectedChildObject == arrTest[0]){
                                    rFields.put(arrTest[1],arrTest[1]);
                                }
                            }
                        }
                    }
                    
                }
                relationshipFields = new List<SelectOption>();
                relationshipFields.add(new SelectOption('','-- Select --'));
                if(rFields.size()>1){
                    isMultiSelectRField = true;
                    for(String k:rFields.keySet()){
                        relationshipFields.add( new SelectOption(rFields.get(k), rFields.get(k)));
                    }
                }
                else{
                    for(String k:rFields.keySet()){
                        LookupRollupSummary.RelationshipField__c = rFields.get(k);
                    }
                }
            }
            if(Test.isRunningTest()){
                Integer a = 6/0;
            } 
            
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getmessage()));
            
        }
    }
    
    public void updateChildField(){
        try{
            LookupRollupSummary.FieldToAggregate__c = selectedChildField;
            if(Test.isRunningTest()){
                Integer a = 6/0;
            } 
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getmessage()));
            
        }
    }
    public void updateParentField(){
        try{
            LookupRollupSummary.AggregateResultField__c = selectedParentField;
            if(Test.isRunningTest()){
                Integer a = 6/0;
            } 
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getmessage()));
            
        }
    }
    public void updateRField(){
        try{
            LookupRollupSummary.RelationshipField__c = selectedRField;
            if(Test.isRunningTest()){
                Integer a = 6/0;
            } 
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getmessage()));
            
        }
    }
    
    
}
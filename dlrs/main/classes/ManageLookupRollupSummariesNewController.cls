public with sharing class ManageLookupRollupSummariesNewController {
  public LookupRollupSummary2__mdt LookupRollupSummary { get; set; }
  Set<String> rFields { get; set; }
  public Boolean isMultiSelectRField { get; set; }
  public String selectedRelationFieldName { get; set; }
  public String selectedLookup { get; set; }
  public Boolean MetadataConnectionError { get; set; }
  public String selectedParentObject { get; set; }
  public String selectedChildObject { get; set; }
  public String selectedParentField { get; set; }
  public String selectedChildField { get; set; }
  public String selectedRField { get; set; }
  public List<SelectOption> parentObjFields { get; set; }
  public List<SelectOption> childObjectList { get; set; }
  public List<SelectOption> childObjFields { get; set; }
  public Boolean isParentObjectSelected { get; set; }
  public Boolean isChildObjectSelected { get; set; }
  //public Map<String,String> objectWithRelationshipField {get;set;}
  public Map<String, List<String>> PnameWithRField { get; set; }
  public List<SelectOption> relationshipFields { get; set; }
  public Map<String, String> ChildObjectsDuplicates { get; set; }
  public Boolean fieldToOrderByNeeded { get; private set; }
  public Boolean realtimeSelected { get; private set; }

  private Map<String, Schema.SObjectType> objectDescription;

  public ManageLookupRollupSummariesNewController() {
    isParentObjectSelected = false;
    isChildObjectSelected = false;
    isMultiSelectRField = false;
    LookupRollupSummary = new LookupRollupSummary2__mdt(
      CalculationSharingMode__c = 'System',
      CalculationMode__c = 'Scheduled'
    );
    //objectWithRelationshipField = new Map<String,String>();

    objectDescription = new Map<String, Schema.SObjectType>();
  }

  // AJB 16/11/21: no current functionality for editing, so this is just code that's not called and decreases coverage %age for now
  /*public List<SelectOption> getLookups() {
        // List current rollup custom metadata configs
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('[new]','Create new...'));
        for(RollupSummary rollup : new RollupSummariesSelector.CustomMetadataSelector(false, false).selectAll())
            options.add(new SelectOption(rollup.Id,rollup.Name));
        return options;
    }*/

  public PageReference init() {
    // Metadata API connection?
    MetadataConnectionError = !RollupService.checkMetadataAPIConnection();
    if (MetadataConnectionError) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Salesforce Metadata API connection failure, click the link below to configure.'
        )
      );
      return null;
    }
    // URL parameter? - AJB 16/11/21: as above, this can be commented out for now as there's no functionality for handling editing records
    /*selectedLookup = (Id) ApexPages.currentPage().getParameters().get('id');                
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
        //}*/
    return null;
  }

  public PageReference load() {
    // Reload the page
    PageReference newPage = Page.managelookuprollupsummaries;
    newPage.setRedirect(true);
    if (selectedLookup != '[new]') {
      newPage.getParameters().put('id', selectedLookup);
    }
    return newPage;
  }
  public PageReference save() {
    try {
      // Insert / Update the rollup custom metadata
      if (LookupRollupSummary.Id == null) {
        RollupService.create(new List<SObject>{ LookupRollupSummary });
      }
      /* AJB 18/11/21: no update functionality so this just reduces code coverage at the moment
            else        
                RollupService.update_x(new List<SObject> { LookupRollupSummary }); */
      // Reload this page (and thus the rollup list in a new request, metadata changes are not visible until this request ends)
      PageReference newPage = Page.managelookuprollupsummaries;
      newPage.setRedirect(true);
      newPage.getParameters()
        .put('developerName', LookupRollupSummary.DeveloperName);
      return newPage;
    } catch (RollupService.RollupValidationException e) {
      // Extract errors from exception and display on the page
      for (
        RollupService.RollupRecordValidationError recordError : e.RecordErrors
      ) {
        if (recordError.Error != null) {
          ApexPages.addMessage(
            new ApexPages.Message(ApexPages.Severity.ERROR, recordError.Error)
          );
        }
        for (String fieldError : recordError.FieldErrors) {
          ApexPages.addMessage(
            new ApexPages.Message(ApexPages.Severity.ERROR, fieldError)
          );
        }
      }
    } catch (Exception e) {
      String errormessage = e.getMessage();
      if (
        selectedChildObject == null &&
        errormessage.contains('Attempt to de-reference a null object')
      ) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please Select the Child Object'
          )
        );
      } else if (
        selectedRField == null &&
        errormessage.contains('Attempt to de-reference a null object')
      ) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please Select the Relationship Field'
          )
        );
      } else {
        ApexPages.addMessages(e);
      }
    }
    return null;
  }

  public PageReference deleteX() {
    /* AJB 16/11/21: whilst this is referenced from the page, the button's only visible if there's a QSP with an Id, i.e. edit mode, which isn't supported in this version
        try {
            // Delete the rollup custom metadata
            RollupService.delete_X(new List<String> { LookupRollupSummary.DeveloperName });
            // Reload this page (and thus the rollup list in a new request, metadata changes are not visible until this request ends)
            PageReference newPage = Page.managelookuprollupsummaries;
            newPage.setRedirect(true);
            return newPage;                 
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }*/
    return null;
  }

  public PageReference hideMessage() {
    DeclarativeLookupRollupSummaries__c settings = DeclarativeLookupRollupSummaries__c.getOrgDefaults();
    settings.HideManageLookupRollupSummariesInfo__c = true;
    upsert settings;
    return null;
  }

  public List<SelectOption> getCalculationModes() {
    List<SelectOption> options = new List<SelectOption>();
    for (
      Schema.PicklistEntry picklistEntry : LookupRollupSummary__c.fields.CalculationMode__c.getDescribe()
        .getPicklistValues()
    ) {
      options.add(
        new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel())
      );
    }
    return sortSelectOptionsByLabel(options);
  }

  public List<SelectOption> getAggregateOperations() {
    List<SelectOption> options = new List<SelectOption>();
    for (
      Schema.PicklistEntry picklistEntry : LookupRollupSummary__c.fields.AggregateOperation__c.getDescribe()
        .getPicklistValues()
    ) {
      options.add(
        new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel())
      );
    }
    return sortSelectOptionsByLabel(options);
  }

  public List<SelectOption> getCalculationSharingModes() {
    List<SelectOption> options = new List<SelectOption>();
    for (
      Schema.PicklistEntry picklistEntry : LookupRollupSummary__c.fields.CalculationSharingMode__c.getDescribe()
        .getPicklistValues()
    ) {
      options.add(
        new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel())
      );
    }
    return sortSelectOptionsByLabel(options);
  }

  private List<SelectOption> sortSelectOptionsByLabel(
    List<SelectOption> selectOptions
  ) {
    if (selectOptions == null || selectOptions.size() <= 1) {
      return selectOptions;
    }
    List<SelectOption> lessSelectOption = new List<SelectOption>();
    List<SelectOption> greaterSelectOption = new List<SelectOption>();
    Integer pivot = selectOptions.size() / 2;

    SelectOption pivotValue = selectOptions[pivot];
    selectOptions.remove(pivot);
    for (SelectOption so : selectOptions) {
      if (so.getLabel() <= pivotValue.getLabel()) {
        lessSelectOption.add(so);
      } else if (so.getLabel() > pivotValue.getLabel()) {
        greaterSelectOption.add(so);
      }
    }
    List<SelectOption> sortedSelectOptions = new List<SelectOption>();
    sortedSelectOptions.addAll(sortSelectOptionsByLabel(lessSelectOption));
    sortedSelectOptions.add(pivotValue);
    sortedSelectOptions.addAll(sortSelectOptionsByLabel(greaterSelectOption));
    return sortedSelectOptions;
  }

  private List<SelectOption> addEmptyValueSelectOption(
    List<SelectOption> selectOptions,
    String emptyValueSelectOptionLabel,
    Integer position
  ) {
    if (selectOptions == null || selectOptions.size() <= 1 || position < 0) {
      return selectOptions;
    }

    selectOptions.add(
      position,
      new SelectOption('', emptyValueSelectOptionLabel)
    );

    return selectOptions;
  }

  public List<SelectOption> getParentObjList() {
    objectDescription = Schema.getGlobalDescribe();
    List<Schema.SObjectType> parentObjList = objectDescription.values();
    List<SelectOption> objNames = new List<SelectOption>();
    for (Schema.SObjectType obj : parentObjList) {
      Schema.DescribeSObjectResult description = obj.getDescribe(
        SObjectDescribeOptions.DEFERRED
      );
      String prefix = description.getKeyPrefix();

      if (!String.isEmpty(prefix)) {
        String objName = description.getName();
        objNames.add(
          new SelectOption(
            objName,
            obj.getDescribe().getLabel() +
            ' (' +
            objName +
            ')'
          )
        );
      }
    }
    return addEmptyValueSelectOption(
      sortSelectOptionsByLabel(objNames),
      '-- Select --',
      0
    );
  }

  public void confirmParentObject() {
    try {
      if (selectedParentObject == null || selectedParentObject == '') {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please Select the Parent Object'
          )
        );
      } else {
        LookupRollupSummary.ParentObject__c = selectedParentObject;
        childObjectList = new List<SelectOption>();
        parentObjFields = new List<SelectOption>();
        ChildObjectsDuplicates = new Map<String, String>();
        isParentObjectSelected = true;
        Schema.SObjectType parentObject = objectDescription.get(
          selectedParentObject
        );
        Schema.DescribeSObjectResult parentObjectDescribe = parentObject.getDescribe();
        //AJB 18/11/21: changed to use a map to avoid string splitting and comparison later on
        PnameWithRField = new Map<String, List<String>>();
        for (
          Schema.ChildRelationship cr : parentObjectDescribe.getChildRelationships()
        ) {
          Schema.DescribeSObjectResult dr = (cr.getChildSObject())
            .getDescribe(SObjectDescribeOptions.DEFERRED);
          String childObjectName = dr.getName();
          String relFieldName = String.valueOf(cr.getField());

          // AJB 16/11/21 it's actually slightly quicker to check if the map contains the key first rather than just overwriting
          if (
            !ChildObjectsDuplicates.containsKey(childObjectName) &&
            !String.isBlank(dr.getKeyPrefix())
          ) {
            ChildObjectsDuplicates.put(
              childObjectName,
              String.valueOf(dr.getLabel()) +
              ' (' +
              childObjectName +
              ')'
            );
          }

          List<String> childRelationshipFields;
          if (!PnameWithRField.containsKey(childObjectName)) {
            childRelationshipFields = new List<String>();
          } else {
            childRelationshipFields = PnameWithRField.get(childObjectName);
            if (childRelationshipFields == null) {
              childRelationshipFields = new List<String>();
            }
          }
          childRelationshipFields.add(relFieldName);
          PnameWithRField.put(childObjectName, childRelationshipFields);
          //objectWithRelationshipField.put(childObjectName + '.'+ relFieldName, relFieldName);
        }
        for (String key : ChildObjectsDuplicates.keySet()) {
          childObjectList.add(
            new SelectOption(key, ChildObjectsDuplicates.get(key))
          );
        }
        childObjectList = addEmptyValueSelectOption(
          sortSelectOptionsByLabel(childObjectList),
          '-- Select --',
          0
        );
        Map<String, Schema.SObjectField> MapOfFields = parentObjectDescribe.fields.getMap();
        for (Schema.SObjectField field : MapOfFields.values()) {
          Schema.DescribeFieldResult fr = field.getDescribe();
          //String dType = String.valueof(fr.getType());
          //if(dType == 'DOUBLE' || dType == 'INTEGER' || dType == 'CURRENCY' || dType == 'DATE' || dType == 'DATETIME' || dType == 'STRING'){

          String fieldName = fr.getName();
          parentObjFields.add(
            new SelectOption(
              fieldName,
              String.valueOf(fr.getLabel()) +
              ' (' +
              fieldName +
              ')'
            )
          );
          //}
        }
        parentObjFields = addEmptyValueSelectOption(
          sortSelectOptionsByLabel(parentObjFields),
          '-- Select --',
          0
        );
      }
    } catch (Exception ex) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())
      );
    }
  }
  public void confirmChildObject() {
    try {
      if (selectedChildObject == null || selectedChildObject == '') {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please Select the Child Object'
          )
        );
      } else {
        childObjFields = new List<SelectOption>();
        // AJB 18/11/21: it was setting the same string as key and value, so we don't need a map, just a set
        rFields = new Set<String>();
        isChildObjectSelected = true;
        LookupRollupSummary.ChildObject__c = selectedChildObject;
        Map<String, Schema.SObjectField> mapOfFields = objectDescription.get(
            selectedChildObject
          )
          .getDescribe()
          .fields.getMap();
        for (Schema.SObjectField field : mapOfFields.values()) {
          Schema.DescribeFieldResult fr = field.getDescribe();
          String fieldName = fr.getName();
          //String dType = String.valueof(fr.getType());
          // if(dType == 'DOUBLE' || dType == 'INTEGER' || dType == 'CURRENCY' || dType == 'DATE' || dType == 'DATETIME'){
          childObjFields.add(
            new SelectOption(
              fieldName,
              String.valueOf(fr.getLabel()) +
              ' (' +
              fieldName +
              ')'
            )
          );
          //}
          // AJB 16/11/21: don't think we really need to loop over the map values twice
          /*
                    }

                    for(Schema.SobjectField strFld: mapOfFields.values())
                    {*/
          if (fr.getType() == Schema.DisplayType.REFERENCE) {
            if (
              String.valueOf(fr.getReferenceTo()) ==
              '(' + selectedParentObject + ')'
            ) {
              List<String> childRelationshipFields = PnameWithRField.get(
                selectedChildObject
              );
              for (String thisField : childRelationshipFields) {
                rFields.add(thisField);
              }
            }
          }
        }
        childObjFields = addEmptyValueSelectOption(
          sortSelectOptionsByLabel(childObjFields),
          '-- Select --',
          0
        );
        relationshipFields = new List<SelectOption>();
        if (rFields.size() > 1) {
          isMultiSelectRField = true;
          for (String fieldName : rFields) {
            relationshipFields.add(new SelectOption(fieldName, fieldName));
          }
          relationshipFields = addEmptyValueSelectOption(
            sortSelectOptionsByLabel(relationshipFields),
            '-- Select --',
            0
          );
        } else if (rFields.size() == 1) {
          for (String fieldName : rFields) {
            LookupRollupSummary.RelationshipField__c = fieldName;
          }
        } else {
          isParentObjectSelected = false;
          isChildObjectSelected = false;
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.WARNING,
              'No appropriate relationship found between these objects'
            )
          );
        }
      }
    } catch (Exception ex) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())
      );
    }
  }

  public void updateChildField() {
    try {
      LookupRollupSummary.FieldToAggregate__c = selectedChildField;
    } catch (Exception ex) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())
      );
    }
  }
  public void updateParentField() {
    try {
      LookupRollupSummary.AggregateResultField__c = selectedParentField;
    } catch (Exception ex) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())
      );
    }
  }
  public void updateRField() {
    try {
      LookupRollupSummary.RelationshipField__c = selectedRField;
    } catch (Exception ex) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())
      );
    }
  }
  public void updateAggregateField() {
    try {
      if (
        LookupRollupSummary.AggregateOperation__c == 'Concatenate' ||
        LookupRollupSummary.AggregateOperation__c == 'Concatenate Distinct'
      ) {
        fieldToOrderByNeeded = true;
      } else if (
        LookupRollupSummary.AggregateOperation__c == 'First' ||
        LookupRollupSummary.AggregateOperation__c == 'Last'
      ) {
        fieldToOrderByNeeded = true;
      } else {
        fieldToOrderByNeeded = false;
      }
    } catch (Exception ex) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())
      );
    }
  }
  public void updateCalcMode() {
    try {
      if (LookupRollupSummary.CalculationMode__c == 'Realtime') {
        realtimeSelected = true;
        LookupRollupSummary.Active__c = false;
      } else {
        realtimeSelected = false;
      }
    } catch (Exception ex) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage())
      );
    }
  }
}

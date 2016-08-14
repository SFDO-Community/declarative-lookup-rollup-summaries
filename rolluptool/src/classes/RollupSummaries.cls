/**
 * Copyright (c) 2013, Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Validation and other behaviour for the Lookup Rollup Summary custom object or custom metadata records
 **/
public class RollupSummaries extends fflib_SObjectDomain
{		
	private static final Integer APEXTRIGGER_NAME_LENGTH = 40; // ApexTrigger.Name.getDescribe().getLength(); gives 255?
	
	private static final Integer APEXCLASS_NAME_LENGTH = 40; // ApexClass.Name.getDescribe().getLength(); gives 255?
	
	/**
	 * Maps LookupRollupSummary__c.AggregateOperation__c picklist values to LREngine.RollupOperation enum
	 **/
	public static Map<String, LREngine.RollupOperation> OPERATION_PICKLIST_TO_ENUMS = new Map<String, LREngine.RollupOperation> 
		{
			AggregateOperation.Sum.name() => LREngine.RollupOperation.Sum,
        	AggregateOperation.Max.name() => LREngine.RollupOperation.Max,
	        AggregateOperation.Min.name() => LREngine.RollupOperation.Min,
	        AggregateOperation.Avg.name() => LREngine.RollupOperation.Avg,
	        AggregateOperation.Count.name() => LREngine.RollupOperation.Count,
	        AggregateOperation.Count_Distinct.name().replace('_', ' ') => LREngine.RollupOperation.Count_Distinct,
	        AggregateOperation.Concatenate.name() => LREngine.RollupOperation.Concatenate,
	        AggregateOperation.Concatenate_Distinct.name().replace('_', ' ') => LREngine.RollupOperation.Concatenate_Distinct,
	        AggregateOperation.First.name() => LREngine.RollupOperation.First,
	        AggregateOperation.Last.name() => LREngine.RollupOperation.Last	        
		};
	
	/**
	 * Enum reflecting CalculationMode__c field picklist values
	 **/
	public enum CalculationMode
	{
		Realtime, 
		Scheduled, 
		Developer,
		Process_Builder
	}
	
	/**
	 * Enum reflecting AggregateOperation__c field picklist values
	 **/
	public enum AggregateOperation 
	{
        Sum,
        Max, 
        Min,
        Avg,
        Count,
        Count_Distinct,
        Concatenate,
        Concatenate_Distinct,
        First,
        Last
    }
		
	/**
	 * Intentially shadow the Records base class property with a list of wrapped records
	 **/
	public List<RollupSummary> Records;

	public RollupSummaries(List<SObject> records)
	{
		super(records);

        // Disable CRUD security enforced in Trigger context
		this.Configuration.disableTriggerCRUDSecurity();
        
		// Wrap the records from the Custom Object or Custom Metadata 
		this.Records = RollupSummary.toList(records);
	}

	/**
	 * Before Insert processing
	 **/
	public override void onBeforeInsert()
	{
		updateDescribableFieldNames();
	}

	/**
	 * Before Update processing
	 **/
	public override void onBeforeUpdate(Map<Id,SObject> existingRecords)
	{
		updateDescribableFieldNames();
	}

	/**
	 * update field names using describe info
	 **/
	private void updateDescribableFieldNames()
	{
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		Map<SObjectType, Map<String, Schema.SObjectField>> gdFields = new Map<SObjectType, Map<String, Schema.SObjectField>>(); 	
		for(RollupSummary lookupRollupSummary : Records)
		{
			SObjectType parentObjectType = gd.get(lookupRollupSummary.ParentObject);
			SObjectType childObjectType = gd.get(lookupRollupSummary.ChildObject);
			if(parentObjectType!=null && !gdFields.containsKey(parentObjectType))
				gdFields.put(parentObjectType, parentObjectType.getDescribe().fields.getMap());
			if(childObjectType!=null && !gdFields.containsKey(childObjectType))
				gdFields.put(childObjectType, childObjectType.getDescribe().fields.getMap());
		}

		for(RollupSummary lookupRollupSummary : Records)
		{
			// Parent Object
			fflib_SObjectDescribe parentObject = fflib_SObjectDescribe.getDescribe(lookupRollupSummary.ParentObject);
			if(parentObject!=null)
				lookupRollupSummary.ParentObject = parentObject.getDescribe().getName();

			// Child Object
			fflib_SObjectDescribe childObject = fflib_SObjectDescribe.getDescribe(lookupRollupSummary.ChildObject);
			if(childObject!=null)
				lookupRollupSummary.ChildObject = childObject.getDescribe().getName();

			// Child Object fields
			SObjectField relationshipField = null;
			SObjectField fieldToAggregate = null;
			if(childObject!=null)
			{
				// Relationship field
				relationshipField = childObject.getField(lookupRollupSummary.RelationshipField);
				if(relationshipField!=null)
					lookupRollupSummary.RelationshipField = relationshipField.getDescribe().getName();
				// Field to Aggregate
				fieldToAggregate = childObject.getField(lookupRollupSummary.FieldToAggregate);
				if(fieldToAggregate!=null)
					lookupRollupSummary.FieldToAggregate = fieldToAggregate.getDescribe().getName();
				// Field to Order By
				if(lookupRollupSummary.FieldToOrderBy!=null) {
					try {
		                lookupRollupSummary.FieldToOrderBy = parseOrderByClause(lookupRollupSummary.FieldToOrderBy, childObject);
					} catch(Utilities.OrderByInvalidException e) {
						// there is a problem with order by so we ignore it intentionally here since we're just trying 
						// to update field names with describe info.  The error will be caught during validation phase.
					}
				}
			}
			// Parent Object fields
			SObjectField aggregateResultField = null;
			if(parentObject!=null)
			{
				// Aggregate Result field
				aggregateResultField = parentObject.getField(lookupRollupSummary.AggregateResultField);
				if(aggregateResultField!=null)
					lookupRollupSummary.AggregateResultField = aggregateResultField.getDescribe().getName();
			}						
			// Check the list of fields expressed in the relationship critiera fields
			if(childObject!=null && lookupRollupSummary.RelationshipCriteriaFields!=null)
			{
				List<String> relationshipCriteriaFields = new List<String>();
				String[] fieldList = lookupRollupSummary.RelationshipCriteriaFields.split('\r\n');
				for(String field : fieldList) {
					SObjectField relationshipCriteriaField = childObject.getField(field);
					relationshipCriteriaFields.add(relationshipCriteriaField !=null ? relationshipCriteriaField.getDescribe().getName() : field);
				}
				lookupRollupSummary.RelationshipCriteriaFields = String.join(relationshipCriteriaFields, '\r\n');
			}
		}
	}
	
	/**
	 * Validations for inserts and updates of records
	 **/ 	
	private void validateCommon()
	{
		// Calculate child object tigger names
		Set<String> rollupTriggerNames = new Set<String>();
		for(RollupSummary lookupRollupSummary : Records)
		{
			// Calculate trigger name child object reqquires in order to check existance
            fflib_SObjectDescribe childObject = fflib_SObjectDescribe.getDescribe(lookupRollupSummary.ChildObject);
			if(childObject!=null)
				rollupTriggerNames.add(makeTriggerName(lookupRollupSummary));				
		}

		// Query for any related Apex triggers
		Map<String, ApexTrigger> apexTriggers = new ApexTriggersSelector().selectByName(rollupTriggerNames);
		
		for(RollupSummary lookupRollupSummary : Records)
		{
			// Custom Metadata shadow record?
			if(lookupRollupSummary.UniqueName!=null) {
				if(lookupRollupSummary.UniqueName.startsWith('mdt:')) {
					// Prevent this record from being activated
					if(lookupRollupSummary.Active) {
						lookupRollupSummary.Fields.Active.addError('This rollup is managed by the system and cannot be activated.');
						break;
					}
					// Skip rest of validation
					break;
				}
			}
			// Parent Object valid?
			fflib_SObjectDescribe parentObject = fflib_SObjectDescribe.getDescribe(lookupRollupSummary.ParentObject);
			if(parentObject==null)
				lookupRollupSummary.Fields.ParentObject.addError(error('Object does not exist.', lookupRollupSummary.Record, LookupRollupSummary__c.ParentObject__c));
			// Child Object valid?
			fflib_SObjectDescribe childObject = fflib_SObjectDescribe.getDescribe(lookupRollupSummary.ChildObject);
			if(childObject==null)
				lookupRollupSummary.Fields.ChildObject.addError(error('Object does not exist.', lookupRollupSummary.Record, LookupRollupSummary__c.ChildObject__c));
			// Child Object fields valid?
			SObjectField relationshipField = null;
			SObjectField fieldToAggregate = null;
			Boolean orderByIsValid = true;
			if(childObject!=null)
			{
				// Relationship field valid?
				relationshipField = childObject.getField(lookupRollupSummary.RelationshipField);
				if(relationshipField==null)
					lookupRollupSummary.Fields.RelationshipField.addError(error('Field does not exist.', lookupRollupSummary.Record, LookupRollupSummary__c.RelationshipField__c));
				// Field to Aggregate valid?
				fieldToAggregate = childObject.getField(lookupRollupSummary.FieldToAggregate);
				if(fieldToAggregate==null)
					lookupRollupSummary.Fields.FieldToAggregate.addError(error('Field does not exist.', lookupRollupSummary.Record, LookupRollupSummary__c.FieldToAggregate__c));
				// Field to Order By valid?
				if(!String.isBlank(lookupRollupSummary.FieldToOrderBy)) {
					try {
						String orderByClause = parseOrderByClause(lookupRollupSummary.FieldToOrderBy, childObject);
					} catch(Utilities.OrderByInvalidException e) {
						orderByIsValid = false;
						lookupRollupSummary.Fields.FieldToOrderBy.addError(error(e.getMessage(), lookupRollupSummary.Record, LookupRollupSummary__c.FieldToOrderBy__c));
					}
				}
				// TODO: Validate relationship field is a lookup to the parent
				// ...
			}
			// Parent Object fields valid?
			SObjectField aggregateResultField = null;
			if(parentObject!=null)
			{
				// Aggregate Result field valid?
				aggregateResultField = parentObject.getField(lookupRollupSummary.AggregateResultField);
				if(aggregateResultField==null)
					lookupRollupSummary.Fields.AggregateResultField.addError(error('Field does not exist.', lookupRollupSummary.Record, LookupRollupSummary__c.AggregateResultField__c));
			}						
			// Cannot activate Realtime or Scheduled rollup without the required trigger deployed
			if(childObject!=null) 
			{
				String triggerName = makeTriggerName(lookupRollupSummary); 
				if(lookupRollupSummary.Active &&
				   (lookupRollupSummary.CalculationMode == CalculationMode.Realtime.name() ||
				    lookupRollupSummary.CalculationMode == CalculationMode.Scheduled.name()) && 
				   !apexTriggers.containsKey(triggerName))
					lookupRollupSummary.Fields.Active.addError(error('Apex Trigger ' + triggerName + ' has not been deployed. Click Manage Child Trigger and try again.', lookupRollupSummary.Record, LookupRollupSummary__c.Active__c));				
			}	
			// Check the list of fields expressed in the relationship critiera fields
			if(childObject!=null && lookupRollupSummary.RelationshipCriteriaFields!=null)
			{
				String[] fieldList = lookupRollupSummary.RelationshipCriteriaFields.split('[\r\n]+');
				String[] fieldsInError = new List<String>();
				for(String field : fieldList)
					if(field.length()>0)
						if(childObject.getField(field)==null)
							fieldsInError.add(field);
				if(fieldsInError.size()==1)
					lookupRollupSummary.Fields.RelationshipCriteriaFields.addError(error('Field ' + fieldsInError[0] + ' does not exist on the child object.', lookupRollupSummary.Record, LookupRollupSummary__c.RelationshipCriteriaFields__c));
				else if(fieldsInError.size()>1)
					lookupRollupSummary.Fields.RelationshipCriteriaFields.addError(error('Fields ' + String.join(fieldsInError, ',') + ' do not exist on the child object.', lookupRollupSummary.Record, LookupRollupSummary__c.RelationshipCriteriaFields__c));
			} 
			// Row limit is only supported for certain operations
			LREngine.RollupOperation operation = 
				OPERATION_PICKLIST_TO_ENUMS.get(lookupRollupSummary.AggregateOperation);
			if(operation!=null && lookupRollupSummary.RowLimit!=null && lookupRollupSummary.RowLimit>0) {
				Set<LREngine.RollupOperation> operationsSupportingRowLimit 
					= new Set<LREngine.RollupOperation>{ 
						LREngine.RollupOperation.Last,
						LREngine.RollupOperation.Concatenate,
						LREngine.RollupOperation.Concatenate_Distinct };
				if(!operationsSupportingRowLimit.contains(operation)) {
					lookupRollupSummary.Fields.RowLimit.addError(error('Row Limit is only supported on Last and Concatentate operators.', lookupRollupSummary.Record, LookupRollupSummary__c.RowLimit__c ));
				}
			}
			try
			{
				// If all objects and fields valid...
				if(parentObject!=null &&
				   childObject!=null &&
				   relationshipField!=null &&
				   aggregateResultField!=null &&
				   fieldToAggregate!=null &&
				   orderByIsValid)
				{
					// Validate via LREngine context
					LREngine.Context lreContext = new LREngine.Context(
						parentObject.getSObjectType(), // parent object
		                childObject.getSObjectType(),  // child object
		                relationshipField.getDescribe(), // relationship field name
		                lookupRollupSummary.RelationShipCriteria,
		                lookupRollupSummary.FieldToOrderBy); 
					lreContext.add(
			            new LREngine.RollupSummaryField(
							aggregateResultField.getDescribe(),
							fieldToAggregate.getDescribe(),
							operation,
							lookupRollupSummary.ConcatenateDelimiter));
					// Validate the SOQL
					if(lookupRollupSummary.RelationShipCriteria!=null && 
					   lookupRollupSummary.RelationShipCriteria.length()>0) 
					{
						try {
							// Validate only mode ensures no query is actually made should it be valid
							LREngine.rollUp(lreContext, new Set<Id>(), true);	
						} catch (QueryException e) {
							lookupRollupSummary.Fields.RelationShipCriteria.addError(
								error(String.format(MSG_INVALID_CRITERIA, new String[] { lookupRollupSummary.RelationShipCriteria, e.getMessage() }), lookupRollupSummary.Record, LookupRollupSummary__c.RelationShipCriteria__c));
						}											
					}
				}
			}
			catch (LREngine.BadRollUpSummaryStateException e)
			{
				// Associate exception message with the lookup rollup summary error
				lookupRollupSummary.addError(error(e.getMessage(), lookupRollupSummary.Record));	
			} 											
		}
	}

	/**
	 * Validations for inserts of records
	 **/ 
	public override void onValidate()
	{
		// invoke validation that should occur for insert & update		
		validateCommon();
	}

	/**
	 * Validations for updates of records
	 **/ 
	public override void onValidate(Map<Id,SObject> existingRecords)
	{
		// invoke validation that should occur for insert & update
		validateCommon();
	}

	private static final String MSG_INVALID_CRITERIA = 'Relationship Criteria \'\'{0}\'\' is not valid, see SOQL documentation http://www.salesforce.com/us/developer/docs/soql_sosl/Content/sforce_api_calls_soql_select_conditionexpression.htm, error is \'\'{1}\'\'';
	
	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new RollupSummaries(sObjectList);
		}
	}	
	
	/**
	 * Trigger name for given lookup rollup summary
	 **/
	public static String makeTriggerName(RollupSummary lookupRollupSummary)
	{
		if(Test.isRunningTest() && lookupRollupSummary.ChildObject == 'Opportunity')
			return 'RollupServiceTestTrigger';
		else if(Test.isRunningTest() && lookupRollupSummary.ChildObject == LookupChild__c.sObjectType.getDescribe().getName())
			return 'RollupServiceTest2Trigger';
		else if(Test.isRunningTest() && lookupRollupSummary.ChildObject == 'Account')
			return 'RollupServiceTest3Trigger';
		else if(Test.isRunningTest() && lookupRollupSummary.ChildObject == 'Task')
			return 'RollupServiceTest4Trigger';
		else if(Test.isRunningTest() && lookupRollupSummary.ChildObject == 'Contact')
			return 'RollupServiceTest5Trigger';
		return calculateComponentName(lookupRollupSummary.ChildObject, 'Trigger', APEXTRIGGER_NAME_LENGTH);
	}

	/**
	 * Apex test name for given lookup rollup summary
	 **/
	public static String makeTriggerTestName(RollupSummary lookupRollupSummary)
	{
		if(Test.isRunningTest() && lookupRollupSummary.ChildObject == 'Opportunity')
			return 'RollupSummariesTest';		
		return calculateComponentName(lookupRollupSummary.ChildObject, 'Test', APEXCLASS_NAME_LENGTH);
	}
	
	/**
	 * Trigger name for Parent object for given lookup rollup summary
	 **/
	public static String makeParentTriggerName(RollupSummary lookupRollupSummary)
	{
		if(Test.isRunningTest() && lookupRollupSummary.ParentObject == 'Opportunity')
			return 'RollupServiceTestTrigger';
		else if(Test.isRunningTest() && lookupRollupSummary.ParentObject == LookupParent__c.sObjectType.getDescribe().getName())
			return 'RollupServiceTest2Trigger';
		else if(Test.isRunningTest() && lookupRollupSummary.ParentObject == 'Account')
			return 'RollupServiceTest3Trigger';
		else if(Test.isRunningTest() && lookupRollupSummary.ParentObject == 'Task')
			return 'RollupServiceTest4Trigger';
		else if(Test.isRunningTest() && lookupRollupSummary.ParentObject == 'Contact')
			return 'RollupServiceTest5Trigger';
		return calculateComponentName(lookupRollupSummary.ParentObject, 'Trigger', APEXTRIGGER_NAME_LENGTH);
	}

	/**
	 * Apex test name for Parent object for given lookup rollup summary
	 **/
	public static String makeParentTriggerTestName(RollupSummary lookupRollupSummary)
	{
		if(Test.isRunningTest() && lookupRollupSummary.ParentObject == 'Opportunity')
			return 'RollupSummariesTest';		
		return calculateComponentName(lookupRollupSummary.ParentObject, 'Test', APEXCLASS_NAME_LENGTH);
	}

	/**
	 * Ensures the component name never exceeds the given maximum length but yet still remains unique
	 **/
	@TestVisible
	private static String calculateComponentName(String childObjectName, String suffix, Integer maxComponentNameLength)
	{
		String trimmedObjectName = childObjectName.replace('__c', '').replace('__', '_');
		String prefix = Utilities.componentPrefix();
		String componentName = prefix + trimmedObjectName + suffix;
		Integer componentNameLength = componentName.length();
		if(componentNameLength > maxComponentNameLength) // Do we need to trim the trigger name?
		{
			Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
			SObjectType childObjectType = gd.get(childObjectName);
			String childObjectPrefix = childObjectType.getDescribe().getKeyPrefix(); // Key prefix will be used to make the trimmed name unique again
			Integer overflowChars = componentNameLength - maxComponentNameLength; // How much do we need to trim the name by?
			trimmedObjectName = trimmedObjectName.substring(0, trimmedObjectName.length() - overflowChars); // Trim the overflow characters from the name
			trimmedObjectName = trimmedObjectName.substring(0, trimmedObjectName.length() - childObjectPrefix.length()); // Trim space for the prefix on the end
			trimmedObjectName+= childObjectPrefix; // Add on the end the unique object prefix (to ensure the trimmed name is still unique)
			componentName = prefix + trimmedObjectName + suffix;
		}
		return componentName;
	}

	private static String parseOrderByClause(String orderByClause, fflib_SObjectDescribe fields)
	{
		List<Utilities.Ordering> fieldsToOrderBy = Utilities.parseOrderByClause(orderByClause);
		if (fieldsToOrderBy == null || fieldsToOrderBy.isEmpty()) {
			return null;
		}

		String parsedOrderByClause = '';
        for (Utilities.Ordering orderByField :fieldsToOrderBy) {
        	SObjectField sObjectField = fields.getField(orderByField.getField());
        	if (sObjectField == null) {
        		throw new Utilities.OrderByInvalidException('Field does not exist.');
        	}
        	// update name with describe info
        	orderByField.setField(sObjectField.getDescribe().getName());

        	// using toAsSpecifiedString so that we update the field name to proper describe info
        	// but leave the rest of what was input unchanged.  If we called toString() we would 
        	// add fully qualified Order By Clause and we don't want to add in portions of the clause
        	// that the user didn't provide in the first place.
        	parsedOrderByClause += (String.isBlank(parsedOrderByClause) ? '' : ',') + orderByField.toAsSpecifiedString();
        }

        return parsedOrderByClause;
	}
}
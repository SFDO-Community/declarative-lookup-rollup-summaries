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
 * Validation and other behaviour for the Lookup Rollup Summary custom object
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
		
	public RollupSummaries(List<LookupRollupSummary__c> records)
	{
		super(records);
	}
	
	/**
	 * Validations for inserts and updates of records
	 **/ 	
	private void validateCommon()
	{
		// Cache Apex Describes and calculate child object tigger names
		Set<String> rollupTriggerNames = new Set<String>();
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		Map<SObjectType, Map<String, Schema.SObjectField>> gdFields = new Map<SObjectType, Map<String, Schema.SObjectField>>(); 	
		for(LookupRollupSummary__c lookupRollupSummary : (List<LookupRollupSummary__c>) Records)
		{
			SObjectType parentObjectType = gd.get(lookupRollupSummary.ParentObject__c);
			SObjectType childObjectType = gd.get(lookupRollupSummary.ChildObject__c);
			if(parentObjectType!=null && !gdFields.containsKey(parentObjectType))
				gdFields.put(parentObjectType, parentObjectType.getDescribe().fields.getMap());
			if(childObjectType!=null && !gdFields.containsKey(childObjectType))
				gdFields.put(childObjectType, childObjectType.getDescribe().fields.getMap());
			// Calculate trigger name child object reqquires in order to check existance
			if(childObjectType!=null)
				rollupTriggerNames.add(makeTriggerName(lookupRollupSummary));				
		}

		// Query for any related Apex triggers
		Map<String, ApexTrigger> apexTriggers = new ApexTriggersSelector().selectByName(rollupTriggerNames);
		
		for(LookupRollupSummary__c lookupRollupSummary : (List<LookupRollupSummary__c>) Records)
		{
			// Parent Object valid?
			SObjectType parentObjectType = gd.get(lookupRollupSummary.ParentObject__c);
			if(parentObjectType==null)
				lookupRollupSummary.ParentObject__c.addError(error('Object does not exist.', lookupRollupSummary, LookupRollupSummary__c.ParentObject__c));				
			// Child Object valid?
			SObjectType childObjectType = gd.get(lookupRollupSummary.ChildObject__c);
			if(childObjectType==null)
				lookupRollupSummary.ChildObject__c.addError(error('Object does not exist.', lookupRollupSummary, LookupRollupSummary__c.ChildObject__c));
			// Child Object fields valid?
			SObjectField relationshipField = null;
			SObjectField fieldToAggregate = null;
			SObjectField fieldToOrderBy = null;
			Map<String, Schema.SObjectField> childObjectFields = gdFields.get(childObjectType);
			if(childObjectFields!=null)
			{
				// Relationship field valid?
				relationshipField = childObjectFields.get(lookupRollupSummary.RelationshipField__c);
				if(relationshipField==null)
					lookupRollupSummary.RelationshipField__c.addError(error('Field does not exist.', lookupRollupSummary, LookupRollupSummary__c.RelationshipField__c));
				// Field to Aggregate valid?
				fieldToAggregate = childObjectFields.get(lookupRollupSummary.FieldToAggregate__c);
				if(fieldToAggregate==null)
					lookupRollupSummary.FieldToAggregate__c.addError(error('Field does not exist.', lookupRollupSummary, LookupRollupSummary__c.FieldToAggregate__c));
				// Field to Order By valid?
				if(lookupRollupSummary.FieldToOrderBy__c!=null) {
					fieldToOrderBy = childObjectFields.get(lookupRollupSummary.FieldToOrderBy__c);
					if(fieldToOrderBy==null)
						lookupRollupSummary.FieldToOrderBy__c.addError(error('Field does not exist.', lookupRollupSummary, LookupRollupSummary__c.FieldToOrderBy__c));					
				}
				// TODO: Validate relationship field is a lookup to the parent
				// ...
			}
			// Parent Object fields valid?
			SObjectField aggregateResultField = null;
			Map<String, Schema.SObjectField> parentObjectFields = gdFields.get(parentObjectType);
			if(parentObjectFields!=null)
			{
				// Aggregate Result field valid?
				aggregateResultField = parentObjectFields.get(lookupRollupSummary.AggregateResultField__c);
				if(aggregateResultField==null)
					lookupRollupSummary.AggregateResultField__c.addError(error('Field does not exist.', lookupRollupSummary, LookupRollupSummary__c.AggregateResultField__c));
			}						
			// Cannot activate Realtime or Scheduled rollup without the required trigger deployed
			if(childObjectType!=null) 
			{
				String triggerName = makeTriggerName(lookupRollupSummary); 
				if(lookupRollupSummary.Active__c &&
				   (lookupRollupSummary.CalculationMode__c == CalculationMode.Realtime.name() ||
				    lookupRollupSummary.CalculationMode__c == CalculationMode.Scheduled.name()) && 
				   !apexTriggers.containsKey(triggerName))
					lookupRollupSummary.Active__c.addError(error('Apex Trigger ' + triggerName + ' has not been deployed. Click Manage Child Trigger and try again.', lookupRollupSummary, LookupRollupSummary__c.Active__c));				
			}
			// Check the list of fields expressed in the relationship critiera fields
			if(childObjectFields!=null && lookupRollupSummary.RelationshipCriteriaFields__c!=null)
			{
				String[] fieldList = lookupRollupSummary.RelationshipCriteriaFields__c.split('\r\n');
				String[] fieldsInError = new List<String>();
				for(String field : fieldList)
					if(childObjectFields.get(field)==null)
						fieldsInError.add(field);
				if(fieldsInError.size()==1)
					lookupRollupSummary.RelationshipCriteriaFields__c.addError(error('Field ' + fieldsInError[0] + ' does not exist on the child object.', lookupRollupSummary, LookupRollupSummary__c.RelationshipCriteriaFields__c));
				else if(fieldsInError.size()>1)
					lookupRollupSummary.RelationshipCriteriaFields__c.addError(error('Fields ' + String.join(fieldsInError, ',') + ' do not exist on the child object.', lookupRollupSummary, LookupRollupSummary__c.RelationshipCriteriaFields__c));
			} 	
			try
			{
				// If all objects and fields valid...
				if(parentObjectType!=null &&
				   childObjectType!=null &&
				   relationshipField!=null &&
				   aggregateResultField!=null &&
				   fieldToAggregate!=null)
				{
					// Validate via LREngine context
					LREngine.Context lreContext = new LREngine.Context(
						parentObjectType, // parent object
		                childObjectType,  // child object
		                relationshipField.getDescribe(), // relationship field name
		                lookupRollupSummary.RelationShipCriteria__c); 
					lreContext.add(
			            new LREngine.RollupSummaryField(
							aggregateResultField.getDescribe(),
							fieldToAggregate.getDescribe(),
							fieldToOrderBy!=null ? fieldToOrderBy.getDescribe() : null, // optional field to order by
							OPERATION_PICKLIST_TO_ENUMS.get(lookupRollupSummary.AggregateOperation__c),
							lookupRollupSummary.ConcatenateDelimiter__c));
					// Validate the SOQL
					if(lookupRollupSummary.RelationShipCriteria__c!=null && 
					   lookupRollupSummary.RelationShipCriteria__c.length()>0) 
					{
						try {
							// Validate only mode ensures no query is actually made should it be valid
							LREngine.rollUp(lreContext, new Set<Id>(), true);	
						} catch (QueryException e) {
							lookupRollupSummary.RelationShipCriteria__c.addError(
								error(String.format(MSG_INVALID_CRITERIA, new String[] { lookupRollupSummary.RelationShipCriteria__c, e.getMessage() }), lookupRollupSummary, LookupRollupSummary__c.RelationShipCriteria__c));
						}											
					}
				}
			}
			catch (LREngine.BadRollUpSummaryStateException e)
			{
				// Associate exception message with the lookup rollup summary error
				lookupRollupSummary.addError(error(e.getMessage(), lookupRollupSummary));	
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
	public static String makeTriggerName(LookupRollupSummary__c lookupRollupSummary)
	{
		if(Test.isRunningTest() && lookupRollupSummary.ChildObject__c == 'Opportunity')
			return 'RollupServiceTestTrigger';
		else if(Test.isRunningTest() && lookupRollupSummary.ChildObject__c == LookupChild__c.sObjectType.getDescribe().getName())
			return 'RollupServiceTest2Trigger';
		else if(Test.isRunningTest() && lookupRollupSummary.ChildObject__c == 'Account')
			return 'RollupServiceTest3Trigger';
		else if(Test.isRunningTest() && lookupRollupSummary.ChildObject__c == 'Task')
			return 'RollupServiceTest4Trigger';
		return calculateComponentName(lookupRollupSummary.ChildObject__c, 'Trigger', APEXTRIGGER_NAME_LENGTH);
	}

	/**
	 * Apex test name for given lookup rollup summary
	 **/
	public static String makeTriggerTestName(LookupRollupSummary__c lookupRollupSummary)
	{
		if(Test.isRunningTest() && lookupRollupSummary.ChildObject__c == 'Opportunity')
			return 'RollupSummariesTest';		
		return calculateComponentName(lookupRollupSummary.ChildObject__c, 'Test', APEXCLASS_NAME_LENGTH);
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
}
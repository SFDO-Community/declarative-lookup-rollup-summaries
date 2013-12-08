/**
 * Copyright (c), Andrew Fawcett
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
 * - Neither the name of the Andrew Fawcett, inc nor the names of its contributors 
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
 * Service class implements rollup functionality using LREngine library and based on lookups described in LookupRollupSummary__c
 **/
global with sharing class RollupService 
{		
	/**
	 * Apex Trigger helper, automatically resolves child records to process via LREngine and lookups described in LookupRollupSummary__c
	 *    also determines if based on the old trigger records if the rollup processing needs to occur
	 **/
	global static void triggerHandler()
	{
		// Currently no processing in the before phase
		if(Trigger.isBefore)
			return;		
			
		// Anything to rollup?
		List<SObject> childRecords = Trigger.isDelete ? Trigger.old : Trigger.new;
		SObjectType childObjectType = childRecords[0].Id.getSObjectType();		
		List<LookupRollupSummary__c> lookups = describeRollups(childRecords[0].Id.getSObjectType());
		if(lookups.size()==0)
			return; // Nothing to see here! :)
			
		// Has anything changed on the child records in respect to the fields being aggregated?
		if(Trigger.isUpdate)
		{
			// Set of field names to aggregate 
			Set<String> searchFieldsToAggregate = new Set<String>();  
			for(LookupRollupSummary__c lookup : lookups)
				searchFieldsToAggregate.add(lookup.FieldToAggregate__c);
				
			// Determine if a specific aggregate field has changed and thus if the lookup itself needs recalculating
			Set<String> fieldsToAggregate = new Set<String>();  
			for(SObject childRecord : childRecords)
			{
				// Process each aggregate field for this record and determine if it has changed
				for(String fieldToAggregate : searchFieldsToAggregate)
				{
					SObject oldChildRecord = Trigger.oldMap.get(childRecord.Id);
					Object newAggregateValue = childRecord.get(fieldToAggregate);
					Object oldAggregateValue = oldChildRecord.get(fieldToAggregate);
					if(newAggregateValue != oldAggregateValue)
					{
						fieldsToAggregate.add(fieldToAggregate);
						searchFieldsToAggregate.remove(fieldToAggregate);
					}
				}
				// Break the search if all fields to aggregate have been processed 
				if(searchFieldsToAggregate.size()==0)
					break;
			}
			// Build a list of lookups where the field to aggregate value h
			List<LookupRollupSummary__c> lookupsToProcess = new List<LookupRollupSummary__c>(); 
			for(LookupRollupSummary__c lookup : lookups)
				if(fieldsToAggregate.contains(lookup.FieldToAggregate__c))
					lookupsToProcess.add(lookup);
			lookups = lookupsToProcess;
		}
			
		// Rollup child records and update master records
		if(lookups.size() > 0)
			update rollup(lookups, childRecords);
	}
	
	/**
	 * Method wraps the LREngine.rollup method, provides context via the lookups described in the LookupRollupSummary__c
	 *
	 * @param masterRecordIds ID's for master records to refresh rollups on
	 * @returns Array of master records containing the updated rollups, calling code must perform update DML operation
	 **/
	public static List<SObject> rollup(Set<Id> masterRecordIds)
	{
		return null;	
	}

	/**
	 * Method wraps the LREngine.rolup method, provides context via the lookups described in LookupRollupSummary__c
	 *
	 * @param childRecords Child records being modified
	 * @returns Array of master records containing the updated rollups, calling code must perform update DML operation
	 **/ 
	public static List<SObject> rollup(List<SObject> childRecords)
	{
		// Anything to process?
		if(childRecords==null || childRecords.size()==0)
			return new List<SObject>();
			
		// Describe rollups for these child records
		SObjectType childObjectType = childRecords[0].Id.getSObjectType();		
		List<LookupRollupSummary__c> lookups = describeRollups(childRecords[0].Id.getSObjectType());
		if(lookups.size()==0)
			return new List<SObject>(); // Nothing to see here! :)
			
		// Rollup child records and update master records
		return rollup(lookups, childRecords);									
	}
	
	/**
	 * Queries for the defined rollups for the given child object type
	 *
	 * @returns List of rollup summary definitions
	 **/
	private static List<LookupRollupSummary__c> describeRollups(SObjectType childObjectType)
	{	
		// Query applicable lookup definitions
		Schema.DescribeSObjectResult childRecordDescribe = childObjectType.getDescribe();
		List<LookupRollupSummary__c> lookups =
			new RollupSummariesSelector().selectActiveByChildObject(
				RollupSummaries.CalculationMode.Realtime, 
				new Set<String> { childRecordDescribe.getName() });
		return lookups;		
	}
	
	/**
	 * Method wraps the LREngine.rolup method, provides context via the lookups described in LookupRollupSummary__c
	 *
	 * @param lookups Lookup to calculate perform
	 * @param childRecords Child records being modified
	 * @returns Array of master records containing the updated rollups, calling code must perform update DML operation
	 **/ 
	private static List<SObject> rollup(List<LookupRollupSummary__c> lookups, List<SObject> childRecords)
	{							
		// Group lookups by parent and relationship into LREngine ctx's
		SObjectType childObjectType = childRecords[0].Id.getSObjectType();				
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		Map<SObjectType, Map<String, Schema.SObjectField>> gdFields = new Map<SObjectType, Map<String, Schema.SObjectField>>(); 	
		Map<String, LREngine.Context> engineCtxByParentRelationship = 
			new Map<String, LREngine.Context>();
		for(LookupRollupSummary__c lookup : lookups)
		{
			// Resolve (and cache) SObjectType's and fields for Parent and Child objects
			SObjectType parentObjectType = gd.get(lookup.ParentObject__c);
			if(parentObjectType==null)
				throw RollupServiceException.invalidRollup(lookup);
			Map<String, Schema.SObjectField> parentFields = gdFields.get(parentObjectType);
			if(parentFields==null)
				gdFields.put(parentObjectType, ((parentFields = parentObjectType.getDescribe().fields.getMap())));
			Map<String, Schema.SObjectField> childFields = gdFields.get(childObjectType);
			if(childFields==null)
				gdFields.put(childObjectType, ((childFields = childObjectType.getDescribe().fields.getMap())));
			SObjectField fieldToAggregate = childFields.get(lookup.FieldToAggregate__c);
			SObjectField relationshipField = childFields.get(lookup.RelationshipField__c);
			SObjectField aggregateResultField = parentFields.get(lookup.AggregateResultField__c);
			if(fieldToAggregate==null || relationshipField==null || aggregateResultField==null)
				throw RollupServiceException.invalidRollup(lookup);
								 
			// Determine if an LREngine Context has been created for this parent child relationship and filter combination?
			String contextKey = lookup.ParentObject__c + '#' + lookup.RelationshipField__c + '#' + lookup.RelationShipCriteria__c;
			LREngine.Context lreContext = engineCtxByParentRelationship.get(contextKey);
			if(lreContext==null)
			{								
				// Construct LREngine.Context
				lreContext = new LREngine.Context(
					parentObjectType, // parent object
                    childObjectType,  // child object
                    relationshipField.getDescribe(), // relationship field name
                    lookup.RelationShipCriteria__c); 
				engineCtxByParentRelationship.put(contextKey, lreContext);
			}
			
			// Add the lookup
			lreContext.add(
	            new LREngine.RollupSummaryField(
					aggregateResultField.getDescribe(),
					fieldToAggregate.getDescribe(),
					RollupSummaries.OPERATION_PICKLIST_TO_ENUMS.get(lookup.AggregateOperation__c)));		
		}

		// Process each context (parent child relationship) and its associated rollups
		Map<Id, SObject> masterRecords = new Map<Id, SObject>();		
		for(LREngine.Context ctx : engineCtxByParentRelationship.values())
		{
			for(SObject masterRecord : LREngine.rollup(ctx, childRecords))
			{
				// Skip master records without Id's (LREngine can return these where there was 
				//	no related master records to children, for examlpe where a relationship is optional)
				if(masterRecord.Id==null)
					break;
				// Merge this master record result into a previous one from another rollup ctx?
				SObject existingRecord = masterRecords.get(masterRecord.Id);
				if(existingRecord==null)
					masterRecords.put(masterRecord.Id, masterRecord);
				else
					for(LREngine.RollupSummaryField fieldToRoll : ctx.fieldsToRoll)
						existingRecord.put(fieldToRoll.master.getSObjectField(), 
							masterRecord.get(fieldToRoll.master.getSObjectField()));
			}			
		}
			
		// Return distinct set of master records will all rollups from all contexts present
		return masterRecords.values();					
	}
}
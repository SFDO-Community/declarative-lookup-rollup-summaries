/**
 * Copyright (c) 2012, Andrew Fawcett
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
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
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
	 * Maps LookupRollupSummary__c.AggregateOperation__c picklist values to LREngine.RollupOperation enum
	 **/
	private static Map<String, LREngine.RollupOperation> MAP_ENUMS = new Map<String, LREngine.RollupOperation> 
		{
			RollupSummaries.AggregateOperation.Sum.name() => LREngine.RollupOperation.Sum,
        	RollupSummaries.AggregateOperation.Max.name() => LREngine.RollupOperation.Max,
	        RollupSummaries.AggregateOperation.Min.name() => LREngine.RollupOperation.Min,
	        RollupSummaries.AggregateOperation.Avg.name() => LREngine.RollupOperation.Avg,
	        RollupSummaries.AggregateOperation.Count.name() => LREngine.RollupOperation.Count			
		};
		
	/**
	 * Apex Trigger helper, automatically resolves child records to process via LREngine and lookups described in LookupRollupSummary__c
	 **/
	global static void triggerHandler()
	{
		// Currently no processing in the before phase
		if(Trigger.isBefore)
			return;		
		// Rollup child records and update master records
		update rollup(Trigger.isDelete ? Trigger.old : Trigger.new);
	}
	
	/**
	 * Method wraps the LREngine.rollup method, provides context via the lookups described in the LookupRollupSummary__c
	 *
	 * @param masterRecordIds ID's for master records to refresh rollups on
	 * @returns Array of master records containing the updated rollups, calling code must perform update DML operation
	 **/
	global static List<SObject> rollup(Set<Id> masterRecordIds)
	{
		return null;	
	}
	
	/**
	 * Method wraps the LREngine.rolup method, provides context via the lookups described in LookupRollupSummary__c
	 *
	 * @param childRecords Child records being modified
	 * @returns Array of master records containing the updated rollups, calling code must perform update DML operation
	 **/ 
	global static List<SObject> rollup(List<SObject> childRecords)
	{
		// Anything to rollup?
		SObjectType childObjectType = childRecords[0].Id.getSObjectType();
		Schema.DescribeSObjectResult childRecordDescribe = childObjectType.getDescribe();
		List<LookupRollupSummary__c> lookups = 
			new RollupSummariesSelector().selectActiveByChildObject(
				RollupSummaries.CalculationMode.Realtime, 
				new Set<String> { childRecordDescribe.getName() });
		if(lookups.size()==0)
			return new List<SObject>(); // Nothing to see here! :)
		
		// Group lookups by parent and relationship into LREngine ctx's
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		Map<SObjectType, Map<String, Schema.SObjectField>> gdFields = new Map<SObjectType, Map<String, Schema.SObjectField>>(); 	
		Map<String, LREngine.Context> engineCtxByParentRelationship = 
			new Map<String, LREngine.Context>();
		for(LookupRollupSummary__c lookup : lookups)
		{
			// Resolve (and cache) SObjectType's and fields for Parent and Child objects
			SObjectType parentObjectType = gd.get(lookup.ParentObject__c);
			Map<String, Schema.SObjectField> parentFields = gdFields.get(parentObjectType);
			if(parentFields==null)
				gdFields.put(parentObjectType, ((parentFields = parentObjectType.getDescribe().fields.getMap())));
			Map<String, Schema.SObjectField> childFields = gdFields.get(childObjectType);
			if(childFields==null)
				gdFields.put(childObjectType, ((childFields = childObjectType.getDescribe().fields.getMap())));
				 
			// Determine if an LREngine Context has been created for this parent child relationship and filter combination?
			String contextKey = lookup.ParentObject__c + '#' + lookup.RelationshipField__c + '#' + lookup.RelationShipCriteria__c;
			LREngine.Context lreContext = engineCtxByParentRelationship.get(contextKey);
			if(lreContext==null)
			{								
				// Construct LREngine.Context
				Schema.DescribeFieldResult relationShipFieldResult = 
					childFields.get(lookup.RelationshipField__c).getDescribe();
				lreContext = new LREngine.Context(
					parentObjectType, // parent object
                    childObjectType,  // child object
                    relationShipFieldResult, // relationship field name
                    lookup.RelationShipCriteria__c); 
				engineCtxByParentRelationship.put(contextKey, lreContext);
			}
			
			// Add the lookup
			lreContext.add(
	            new LREngine.RollupSummaryField(
					parentFields.get(lookup.AggregateResultField__c).getDescribe(),
					childFields.get(lookup.FieldToAggregate__c).getDescribe(),
					MAP_ENUMS.get(lookup.AggregateOperation__c))); 			
		}

		// Process each context (parent child relationship) and its associated rollups
		List<SObject> masterRecords = new List<SObject>();		
		for(LREngine.Context ctx : engineCtxByParentRelationship.values())
			masterRecords.addAll(LREngine.rollup(ctx, childRecords));
		return masterRecords;					
	}
}
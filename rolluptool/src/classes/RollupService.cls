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
 * Service class implements rollup functionality using LREngine library and based on lookups described in LookupRollupSummary__c
 *
 *   TODO: This class could do with using the fflib_Describe util class, it would cut down on describe cahcing logic and make things cleaner
 *
 *   TODO: As this class has developed to support schedule and develoepr API entry points some further refactoring for reuse can be done
 **/
global with sharing class RollupService 
{	
	/**
	 * Starts the Job to recalculate the given rollup 
	 **/
	global static Id runJobToCalculate(Id lookupId)
	{
		// Is another calculate job running for this lookup?
		List<LookupRollupSummary__c> lookups = new RollupSummariesSelector().selectById(new Set<Id> { lookupId });		
		if(lookups.size()==0)
			throw RollupServiceException.rollupNotFound(lookupId);
		LookupRollupSummary__c lookup = lookups[0];
		if(lookup.CalculateJobId__c!=null)
			throw RollupServiceException.jobAlreadyRunning(lookup.Name);

		// Start the job and record the Job Id
		Integer scopeSize = (Integer) DeclarativeLookupRollupSummaries__c.getInstance().CalculateJobScopeSize__c;
		Id jobId = Database.executeBatch(new RollupCalculateJob(lookupId), scopeSize == null ? 100 : scopeSize);
		lookup.CalculateJobId__c = jobId;
		update lookup;
		
		return jobId;
	}
	
	/**
	 * Starts the Job to process the scheduled items for rollup 
	 **/
	global static Id runJobToProcessScheduledItems()
	{
		// Check if the Job is already running before starting a new one
		if(new AsyncApexJobsSelector().jobsExecuting(new Set<String> { 'RollupJob' }))
			throw RollupServiceException.jobsExecuting('RollupJob');
			
		// Start the job to processed the scheduled items	
		Integer scopeSize = (Integer) DeclarativeLookupRollupSummaries__c.getInstance().ScheduledJobScopeSize__c;
		return Database.executeBatch(new RollupJob(), scopeSize == null ? 100 : scopeSize);
	}	

	/**
	 * Developer API for the tool, only executes Rollup Summmaries with Calculation Mode set to Developer 
	 *
	 * @param childRecords Child records being modified
	 * @returns Array of master records containing the updated rollups, calling code must perform update DML operation
	 **/ 
	global static List<SObject> rollup(List<SObject> childRecords)
	{
		// Anything to process?
		if(childRecords==null || childRecords.size()==0)
			return new List<SObject>();
			
		// Describe Developer rollups for these child records
		SObjectType childObjectType = childRecords[0].Id.getSObjectType();
		Schema.DescribeSObjectResult childRecordDescribe = childObjectType.getDescribe();		
		List<LookupRollupSummary__c> lookups =
			new RollupSummariesSelector().selectActiveByChildObject(
				new List<RollupSummaries.CalculationMode> { RollupSummaries.CalculationMode.Developer }, 
				new Set<String> { childRecordDescribe.getName() });
		if(lookups.size()==0)
			return new List<SObject>(); // Nothing to see here! :)
			
		// Rollup child records and update master records
		Set<Id> masterRecordIds = new Set<Id>();
		for(SObject childRecord : childRecords)
			for(LookupRollupSummary__c lookup : lookups)
				if(childRecord.get(lookup.RelationShipField__c)!=null)
					masterRecordIds.add((Id)childRecord.get(lookup.RelationShipField__c));

		// Process each context (parent child relationship) and its associated rollups
		Map<Id, SObject> masterRecords = new Map<Id, SObject>();		
		for(LREngine.Context ctx : createLREngineContexts(lookups).values())
		{
			// Produce a set of master Id's applicable to this context (parent only)			
			Set<Id> ctxMasterIds = new Set<Id>();
			for(Id masterId : masterRecordIds)
				if(masterId.getSObjectType() == ctx.master)
					ctxMasterIds.add(masterId);
			// Execute the rollup and process the resulting updated master records
			for(SObject masterRecord : LREngine.rollup(ctx, ctxMasterIds)) 
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
		return masterRecords.values();
	}
	
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
			
		// Has anything changed on the child records in respect to the fields referenced on the lookup definition?
		if(Trigger.isUpdate)
		{
			// Master records to update
			Set<Id> masterRecordIds = new Set<Id>();
			 
			// Set of field names from the child used in the rollup to search for changes on
			Set<String> fieldsToSearchForChanges = new Set<String>(); 
			Set<String> relationshipFields = new Set<String>(); 
			for(LookupRollupSummary__c lookup : lookups)
			{
				fieldsToSearchForChanges.add(lookup.FieldToAggregate__c);
				fieldsToSearchForChanges.add(lookup.RelationShipField__c);
				if(lookup.RelationshipCriteriaFields__c!=null)
					for(String criteriaField : lookup.RelationshipCriteriaFields__c.split('\r\n'))
						fieldsToSearchForChanges.add(criteriaField);
				relationshipFields.add(lookup.RelationShipField__c);
			}
				
			// Determine if a a field referenced on the lookup has changed and thus if the lookup itself needs recalculating
			Set<String> fieldsChanged = new Set<String>();  
			for(SObject childRecord : childRecords)
			{
				// Determine if any of the fields referenced on our selected rollups have changed on this record
				for(String fieldToSearch : fieldsToSearchForChanges)
				{
					SObject oldChildRecord = Trigger.oldMap.get(childRecord.Id);
					Object newValue = childRecord.get(fieldToSearch);
					Object oldValue = oldChildRecord.get(fieldToSearch);
					// Register this field as having changed?
					if(newValue != oldValue)
						fieldsChanged.add(fieldToSearch);
					// Add both old and new value to master record Id list for relationship fields to ensure old and new parent master records are updated (re-parenting)
					if(relationshipFields.contains(fieldToSearch))
					{
						if(newValue!=null)
							masterRecordIds.add((Id) newValue);
						if(oldValue!=null)
							masterRecordIds.add((Id) oldValue);		
					}
				}
			}
			
			// Build a revised list of lookups to process that includes only where fields used in the rollup have changed
			List<LookupRollupSummary__c> lookupsToProcess = new List<LookupRollupSummary__c>(); 
			for(LookupRollupSummary__c lookup : lookups)
			{
				// Are any of the changed fields used by this lookup?
				Boolean processLookup = false; 
				if(fieldsChanged.contains(lookup.FieldToAggregate__c) ||
				   fieldsChanged.contains(lookup.RelationShipField__c))
				   	processLookup = true;
				if(lookup.RelationshipCriteriaFields__c!=null)
					for(String criteriaField : lookup.RelationshipCriteriaFields__c.split('\r\n'))
						if(fieldsChanged.contains(criteriaField))
							processLookup = true;
				if(processLookup)
					lookupsToProcess.add(lookup);
			}
			lookups = lookupsToProcess;
			
			// Rollup child records and update master records 
			if(lookupsToProcess.size()>0)
				update updateMasterRollupsTrigger(lookups, masterRecordIds);
			return;
		}
			
		// Rollup child records and update master records
		Set<Id> masterRecordIds = new Set<Id>();
		for(SObject childRecord : childRecords)
			for(LookupRollupSummary__c lookup : lookups)
				if(childRecord.get(lookup.RelationShipField__c)!=null)
					masterRecordIds.add((Id)childRecord.get(lookup.RelationShipField__c));
		update updateMasterRollupsTrigger(lookups, masterRecordIds);
	}
	
	/**
	 * Method returns a QueryLocator that returns master records (as per the lookup definition) meeting the criteria expressed (if defined)
	 **/
	public static Database.QueryLocator masterRecordsAsQueryLocator(Id lookupId)
	{ 
		List<LookupRollupSummary__c> lookups = new RollupSummariesSelector().selectById(new Set<Id> { lookupId });
		if(lookups.size()==0)
			throw RollupServiceException.rollupNotFound(lookupId); 
		LookupRollupSummary__c lookup = lookups[0];				
		return Database.getQueryLocator('Select Id From ' + lookup.ParentObject__c);
	}

	/**
	 * Clears the Calcualte Job Id's on the given lookups preventng concurrent Calculate jobs
	 **/ 	
	public static void clearCalculateJobId(Set<Id> lookupIds)
	{
		List<LookupRollupSummary__c> lookups = new RollupSummariesSelector().selectById(lookupIds);
		for(LookupRollupSummary__c lookup : lookups)
			lookup.CalculateJobId__c = null;
		update lookups;
	}
	
	/**
	 * Method called from the RollupJob to handle summary schedule items that have been generated
	 **/
	public static void processScheduleItems(List<LookupRollupSummaryScheduleItems__c> rollupSummaryScheduleItems)
	{
		// Load related Lookup summaries for the scheduled items
		Set<Id> lookupIds = new Set<Id>();
		for(LookupRollupSummaryScheduleItems__c scheduleItem : rollupSummaryScheduleItems)
			lookupIds.add(scheduleItem.LookupRollupSummary__c);
		Map<Id, LookupRollupSummary__c> lookups = 
			new Map<Id, LookupRollupSummary__c>(new RollupSummariesSelector().selectById(lookupIds));
			
		// Group the parent Id's by parent type
		Map<String, Set<Id>> parentIdsByParentType = new Map<String, Set<Id>>();  
		for(LookupRollupSummaryScheduleItems__c scheduleItem : rollupSummaryScheduleItems)
		{
			Id parentId = scheduleItem.ParentId__c;
			LookupRollupSummary__c lookup = lookups.get(scheduleItem.LookupRollupSummary__c);
			Set<Id> parentIds = parentIdsByParentType.get(lookup.ParentObject__c);
			if(parentIds==null)
				parentIdsByParentType.put(lookup.ParentObject__c, (parentIds = new Set<Id>()));
			parentIds.add(parentId);
		}
			
		// Group lookups by parent and relationship into LREngine ctx's
		Map<String, LREngine.Context> engineCtxByParentRelationship = createLREngineContexts(lookups.values());

		// Process each context (parent child relationship) and its associated rollups
		Map<Id, SObject> masterRecords = new Map<Id, SObject>();		
		for(LREngine.Context ctx : engineCtxByParentRelationship.values())
		{
			Set<Id> masterIds = parentIdsByParentType.get(ctx.master.getDescribe().getName());
			for(SObject masterRecord : LREngine.rollup(ctx, masterIds))
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

		// Map rollup summary schedule items by parent id, in order to remove only those whos parent/master record actually gets updated below
		Map<Id, LookupRollupSummaryScheduleItems__c> rollupSummaryScheduleItemsByParentId = 
			new Map<Id, LookupRollupSummaryScheduleItems__c>();
		for(LookupRollupSummaryScheduleItems__c rollupSummaryScheduleItem : rollupSummaryScheduleItems)
			rollupSummaryScheduleItemsByParentId.put(rollupSummaryScheduleItem.ParentId__c, rollupSummaryScheduleItem);
			
		// Update master records
		List<LookupRollupSummaryLog__c> rollupSummaryLogs = new List<LookupRollupSummaryLog__c>();
		List<SObject> masterRecordList = masterRecords.values();
		List<Database.Saveresult> saveResults = Database.update(masterRecordList, false);
		
		// Log errors to the summary log
		Integer masterRecordIdx = 0;
		for(Database.Saveresult saveResult : saveResults)
		{
			// Errors?
			if(!saveResult.isSuccess())
			{
				// Log the failure updating the master record for review
				LookupRollupSummaryLog__c logEntry = new LookupRollupSummaryLog__c();
				logEntry.ErrorMessage__c = '';
				logEntry.ParentId__c = masterRecordList[masterRecordIdx].Id;
				logEntry.ParentObject__c = masterRecordList[masterRecordIdx].Id.getSObjectType().getDescribe().getName();
				List<Database.Error> databaseErrors = saveResult.getErrors();
				for(Database.Error databaseError : databaseErrors)
					logEntry.ErrorMessage__c+= databaseError.getMessage() + ' : ' + databaseError.getStatusCode() + ' ' + databaseError.getFields() + '\n';
				rollupSummaryLogs.add(logEntry);
				// Remove from scheduled items to be deleted to allow a retry
				rollupSummaryScheduleItemsByParentId.remove(masterRecordList[masterRecordIdx].Id);
			}
			masterRecordIdx++;
		}
			
		// Insert any logs for master records that failed to update (upsert to only show last message per parent)
		upsert rollupSummaryLogs ParentId__c;
		
		// Delete any old logs entries for master records that have now been updated successfully
		delete [select Id from LookupRollupSummaryLog__c where ParentId__c in :rollupSummaryScheduleItemsByParentId.keySet()];
		
		// Delete any schedule items for successfully updated master records
		delete rollupSummaryScheduleItemsByParentId.values();
	}

	/**
	 * Performs a recalculate on the master records for the given rollup definitions, outputs any errors in the rollup summary log
	 *
	 * @param lookups Lookup to calculate perform
	 * @param childRecords Child records being modified
	 **/ 
	public static void updateMasterRollups(Set<Id> lookupIds, Set<Id> masterRecordIds)
	{		
		// Process rollup
		List<LookupRollupSummary__c> lookups = new RollupSummariesSelector().selectById(lookupIds);
		Map<Id, SObject> masterRecords = new Map<Id, SObject>();		
		for(LREngine.Context ctx : createLREngineContexts(lookups).values())
		{
			// Produce a set of master Id's applicable to this context (parent only)			
			Set<Id> ctxMasterIds = new Set<Id>();
			for(Id masterId : masterRecordIds)
				if(masterId.getSObjectType() == ctx.master)
					ctxMasterIds.add(masterId);
			// Execute the rollup and process the resulting updated master records
			for(SObject masterRecord : LREngine.rollup(ctx, ctxMasterIds)) 
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

		// Update master records
		List<SObject> masterRecordList = masterRecords.values();
		List<Database.Saveresult> saveResults = Database.update(masterRecordList, false);
		
		// Log errors to the summary log
		Integer masterRecordIdx = 0;
		Set<Id> masterRecordsUpdatedId = new Set<Id>();
		List<LookupRollupSummaryLog__c> rollupSummaryLogs = new List<LookupRollupSummaryLog__c>();		
		for(Database.Saveresult saveResult : saveResults)
		{
			// Errors?
			if(!saveResult.isSuccess())
			{
				// Log the failure updating the master record for review
				LookupRollupSummaryLog__c logEntry = new LookupRollupSummaryLog__c();
				logEntry.ErrorMessage__c = '';
				logEntry.ParentId__c = masterRecordList[masterRecordIdx].Id;
				logEntry.ParentObject__c = masterRecordList[masterRecordIdx].Id.getSObjectType().getDescribe().getName();
				List<Database.Error> databaseErrors = saveResult.getErrors();
				for(Database.Error databaseError : databaseErrors)
					logEntry.ErrorMessage__c+= databaseError.getMessage() + ' : ' + databaseError.getStatusCode() + ' ' + databaseError.getFields() + '\n';
				rollupSummaryLogs.add(logEntry);
			}
			else
			{
				// Success
				masterRecordsUpdatedId.add(masterRecordList[masterRecordIdx].Id);
			}
			masterRecordIdx++;
		}
			
		// Insert any logs for master records that failed to update (upsert to only show last message per parent)
		upsert rollupSummaryLogs ParentId__c;
		
		// Delete any old logs entries for master records that have now been updated successfully
		delete [select Id from LookupRollupSummaryLog__c where ParentId__c in :masterRecordsUpdatedId];
	}
	
	/**
	 * Method wraps the LREngine.rolup method, provides context via the lookups described in LookupRollupSummary__c
	 *
	 * @param lookups Lookup to calculate perform
	 * @param childRecords Child records being modified
	 * @returns Array of master records containing the updated rollups, calling code must perform update DML operation
	 **/ 
	private static List<SObject> updateMasterRollupsTrigger(List<LookupRollupSummary__c> lookups, Set<Id> masterRecordIds)
	{
		// Process lookups, 
		//    Realtime are added to a list for later LRE context creation and processing, 
		//    Scheduled result in parent Id's being emitted to scheduled item object for later processing
		List<LookupRollupSummary__c> realtimeLookups = new List<LookupRollupSummary__c>();  	
		Map<Id, LookupRollupSummaryScheduleItems__c> scheduledItems = new Map<Id, LookupRollupSummaryScheduleItems__c>(); 
		for(LookupRollupSummary__c lookup : lookups)
		{
			if(lookup.CalculationMode__c == RollupSummaries.CalculationMode.Realtime.name())
			{
				// Filter realtime looks in order to generate LRE contexts below
				realtimeLookups.add(lookup);
			}
			else if(lookup.CalculationMode__c == RollupSummaries.CalculationMode.Scheduled.name())
			{		
				// For scheduled rollups queue the parent Id record for processing
		        for (Id parentId : masterRecordIds)
		        {
					LookupRollupSummaryScheduleItems__c scheduledItem = new LookupRollupSummaryScheduleItems__c();
					scheduledItem.Name = parentId;
					scheduledItem.LookupRollupSummary__c = lookup.Id;
					scheduledItem.ParentId__c = parentId;
					scheduledItem.QualifiedParentID__c = parentId + '#' + lookup.Id; 
					scheduledItems.put(parentId, scheduledItem);
		        }		            
			}
		}
		
		// Add parent Id's to schedule items object
		upsert scheduledItems.values() QualifiedParentID__c;

		// Process each context (parent child relationship) and its associated rollups
		Map<Id, SObject> masterRecords = new Map<Id, SObject>();		
		for(LREngine.Context ctx : createLREngineContexts(realtimeLookups).values())
		{
			// Produce a set of master Id's applicable to this context (parent only)			
			Set<Id> ctxMasterIds = new Set<Id>();
			for(Id masterId : masterRecordIds)
				if(masterId.getSObjectType() == ctx.master)
					ctxMasterIds.add(masterId);
			// Execute the rollup and process the resulting updated master records
			for(SObject masterRecord : LREngine.rollup(ctx, ctxMasterIds)) 
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
				new List<RollupSummaries.CalculationMode> { RollupSummaries.CalculationMode.Realtime, RollupSummaries.CalculationMode.Scheduled }, 
				new Set<String> { childRecordDescribe.getName() });
		return lookups;		
	}
		
	/**
	 * Method takes a list of Lookups and creates the most optimum list of LREngine.Context's to execute
	 **/
	private static Map<String, LREngine.Context> createLREngineContexts(List<LookupRollupSummary__c> lookups)
	{ 
		// Group lookups by parent and relationship into LREngine ctx's
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		Map<SObjectType, Map<String, Schema.SObjectField>> gdFields = new Map<SObjectType, Map<String, Schema.SObjectField>>(); 	
		Map<String, LREngine.Context> engineCtxByParentRelationship = 
			new Map<String, LREngine.Context>();
		Map<Id, LookupRollupSummaryScheduleItems__c> scheduledItems = 
			new Map<Id, LookupRollupSummaryScheduleItems__c>(); 
		for(LookupRollupSummary__c lookup : lookups)
		{
			// Resolve (and cache) SObjectType's and fields for Parent and Child objects
			SObjectType parentObjectType = gd.get(lookup.ParentObject__c);
			if(parentObjectType==null)
				throw RollupServiceException.invalidRollup(lookup);
			Map<String, Schema.SObjectField> parentFields = gdFields.get(parentObjectType);
			if(parentFields==null)
				gdFields.put(parentObjectType, ((parentFields = parentObjectType.getDescribe().fields.getMap())));
			SObjectType childObjectType = gd.get(lookup.ChildObject__c);
			if(childObjectType==null)
				throw RollupServiceException.invalidRollup(lookup);
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
		return engineCtxByParentRelationship;
	}	
}
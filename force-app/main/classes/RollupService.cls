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
 * Service class implements rollup functionality using LREngine library and based on lookups described in RollupSummary
 *
 *   TODO: This class could do with using the fflib_Describe util class, it would cut down on describe cahcing logic and make things cleaner
 *
 *   TODO: As this class has developed to support schedule and develoepr API entry points some further refactoring for reuse can be done
 **/
global with sharing class RollupService
{	
	global static Exception LastMetadataAPIConnectionException {get; private set;}

	global static Boolean checkMetadataAPIConnection()
	{
		try {
			MetadataService.MetadataPort service = new MetadataService.MetadataPort();
			service.SessionHeader = new MetadataService.SessionHeader_element();
			service.SessionHeader.sessionId = UserInfo.getSessionId();
			List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();		
			MetadataService.ListMetadataQuery remoteSites = new MetadataService.ListMetadataQuery();
			remoteSites.type_x = 'RemoteSiteSetting';
			queries.add(remoteSites);					
			service.listMetadata(queries, 28);			
		} catch (Exception e) {
			LastMetadataAPIConnectionException = e;
			return false;
		}
		LastMetadataAPIConnectionException = null;
		return true;
	}
	
	/**
	 * Starts the Job to recalculate the given rollup 
	 **/
	global static Id runJobToCalculate(Id lookupId)
	{
		return runJobToCalculate((String)lookupId, null);
	}

	/**
	 * Starts the Job to recalculate the given rollup filtering the master object records by the WHERE clause
	 **/
	global static Id runJobToCalculate(Id lookupId, String masterWhereClause)
	{
		return runJobToCalculate((String) lookupId, masterWhereClause);
	}

	/**
	 * Starts the Job to recalculate the given rollup 
	 **/
	global static Id runJobToCalculate(String lookupId)
	{
		return runJobToCalculate(lookupId, null);
	}

	/**
	 * Starts the Job to recalculate the given rollup filtering the master object records by the WHERE clause
	 **/
	global static Id runJobToCalculate(String lookupId, String masterWhereClause)
	{
		System.SavePoint sp = Database.setSavepoint();
		
		try {
			
			// Is another calculate job running for this lookup?
			List<RollupSummary> lookups = new RollupSummariesSelector().selectById(new Set<String> { (String) lookupId });
			if(lookups.size()==0)
				throw RollupServiceException.rollupNotFound(lookupId);
			RollupSummary lookup = lookups[0];
	
			// Already running?
			checkJobAlreadyRunning(lookupId, lookup.Name);
	
			// Already active?
			if((lookup.Active==null || lookup.Active==false) && lookup.CalculationMode=='Realtime' )
				throw new RollupServiceException('The rollup must be Active before you can run a Calculate job.');
	
			// Start the job and record the Job Id
			Integer scopeSize = (Integer) DeclarativeLookupRollupSummaries__c.getInstance().CalculateJobScopeSize__c;
			Id jobId = Database.executeBatch(new RollupCalculateJob(lookupId, masterWhereClause), scopeSize == null ? 100 : scopeSize);
	
			// Update CalculateJobId__c for Custom Object based rollups?
			if(lookup.Record instanceof LookupRollupSummary__c) {
				LookupRollupSummary__c rollupSummary = (LookupRollupSummary__c) lookup.Record;
				rollupSummary.CalculateJobId__c = jobId;
				update lookup.Record;
			}
	
			return jobId;
						
		} catch (Exception e) {
			// Fix for https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/511, avoid leaking control record
			Database.rollback(sp);
			throw e;
		}
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
	 * Describes a specific rollup to process
	 **/
	global class RollupToCalculate {
		global Id parentId;
		global String rollupSummaryUniqueName;
	}

	/**
	 * Executes Process Builder rollups
	 **/
	global static void rollup(List<RollupToCalculate> rollupsToCalculate) {

		// Anything to process?
		if(rollupsToCalculate==null || rollupsToCalculate.size()==0)
			return;

		// Load summaries
		Set<String> uniqueNames = new Set<String>();
		Set<Id> masterIds = new Set<Id>();
		for(RollupToCalculate rollupToCalc : rollupsToCalculate) {
			uniqueNames.add(rollupToCalc.rollupSummaryUniqueName);
			masterIds.add(rollupToCalc.parentId);
		}
		List<RollupSummary> lookups =
			new RollupSummariesSelector().selectActiveByUniqueName(uniqueNames);
		if(lookups.size()==0)
			return;

		// Process each context (parent child relationship) and its associated rollups
		Map<Id, SObject> masterRecords = new Map<Id, SObject>();		
		for(LREngine.Context ctx : createLREngineContexts(lookups))
		{
			// Produce a set of master Id's applicable to this context (parent only)			
			Set<Id> ctxMasterIds = new Set<Id>();
			for(Id masterId : masterIds)
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

		// Update the master records
		update masterRecords.values();
	}

	/**
	 * Developer API for the tool, only executes Rollup Summmaries with Calculation Mode set to Developer 
	 *
	 * Automatically resolves child records to process via LREngine and lookups described in RollupSummary
	 *    also determines if based on the old records if the rollup processing needs to occur
	 *
	 * @param existingRecords Deleted or existing version of Updated records
	 * @param newRecords Inserted/Updated/Undeleted records
	 * @param sObjectType SObjectType of the existing/new records
	 *
	 * @usage rollup(Trigger.oldMap, Trigger.newMap, Account.SObjectType)
	 *
	 * @remark All SObjects (existing and new) must be of the same SObjectType
	 * @remark Supports mixture of old/new records.  For example, you can include a record in existing 
	 *         that was deleted and a record in new that was inserted.
	 **/ 
	global static void rollup(Map<Id, SObject> existingRecords, Map<Id, SObject> newRecords, Schema.SObjectType sObjectType)
	{
		handleRollups(existingRecords, newRecords, sObjectType, new List<RollupSummaries.CalculationMode> { RollupSummaries.CalculationMode.Developer });
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
		List<RollupSummary> lookups =
			new RollupSummariesSelector().selectActiveByChildObject(
				new List<RollupSummaries.CalculationMode> { RollupSummaries.CalculationMode.Developer }, 
				new Set<String> { childRecordDescribe.getName() });
		if(lookups.size()==0)
			return new List<SObject>(); // Nothing to see here! :)
			
		// Rollup child records and update master records
		Set<Id> masterRecordIds = new Set<Id>();
		for(SObject childRecord : childRecords)
			for(RollupSummary lookup : lookups)
				if(childRecord.get(lookup.RelationShipField)!=null)
					masterRecordIds.add((Id)childRecord.get(lookup.RelationShipField));

		// Process each context (parent child relationship) and its associated rollups
		Map<Id, SObject> masterRecords = new Map<Id, SObject>();		
		for(LREngine.Context ctx : createLREngineContexts(lookups))
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
	 * Apex Test handler (call from Apex Test only)
	 **/
	global static void testHandler(SObject dummyChildRecord) 
	{
		try {
			insert dummyChildRecord;
		} catch (Exception e) {
			// If the auto generated trigger was invoked this test served its purpose (code coverage wise) ignore this error
			if(triggerHandleInvoked)
				return;
			// Otherwise fail the test with the underlying exception as it prevented our trigger being invoked
			throw e;
		}
	}
	
	/**
	 * Used in a test context to determine if errors from the dummy child insert should fail the test
	 **/
	private static boolean triggerHandleInvoked = false;

    /**
     * Apex Trigger helper, automatically resolves child records to process via LREngine and lookups described in RollupSummary
     *    also determines if based on the old trigger records if the rollup processing needs to occur
     * @param childObjectType This can be used in cases where the prior overload was used an the Id.getSobjectType method fails to return the SOBjectType (see Issue 17 in the repo)
     **/
    global static void triggerHandler(SObjectType childObjectType)
    {
        triggerHandleInvoked = true;

        // Currently no processing in the before phase
        if(Trigger.isBefore)
            return;     
            
        // Anything to rollup?
        handleRollups(Trigger.oldMap, Trigger.newMap, childObjectType, new List<RollupSummaries.CalculationMode> { RollupSummaries.CalculationMode.Realtime, RollupSummaries.CalculationMode.Scheduled });
    }

	/**
	 * Apex Trigger helper, automatically resolves child records to process via LREngine and lookups described in RollupSummary
	 *    also determines if based on the old trigger records if the rollup processing needs to occur
	 **/
	global static void triggerHandler()
	{
		triggerHandleInvoked = true;

		// Currently no processing in the before phase
		if(Trigger.isBefore)
			return;		
			
		// Anything to rollup?
		List<SObject> childRecords = Trigger.isDelete ? Trigger.old : Trigger.new;
		SObjectType childObjectType = childRecords[0].Id.getSObjectType();		
		handleRollups(Trigger.oldMap, Trigger.newMap, childObjectType, new List<RollupSummaries.CalculationMode> { RollupSummaries.CalculationMode.Realtime, RollupSummaries.CalculationMode.Scheduled });
	}

	/**
	 * Method returns a QueryLocator that returns master records (as per the lookup definition) meeting the criteria expressed (if defined)
	 **/
	public static Database.QueryLocator masterRecordsAsQueryLocator(Id lookupId)
	{
		return masterRecordsAsQueryLocator(lookupId, null);
	}

	public static Database.QueryLocator masterRecordsAsQueryLocator(Id lookupId, String whereClause)
	{
		List<RollupSummary> lookups = new RollupSummariesSelector().selectById(new Set<String> { (String) lookupId });
		if(lookups.size()==0)
			throw RollupServiceException.rollupNotFound(lookupId);
		RollupSummary lookup = lookups[0];
		if (String.isBlank(whereClause)) {
			return Database.getQueryLocator('Select Id From ' + lookup.ParentObject);
		} else {
			return Database.getQueryLocator(String.format('Select Id From {0} WHERE {1} ORDER BY Id', new List<String>{lookup.ParentObject, whereClause}));
		}
	}

	/**
	 * Clears the Calcualte Job Id's on the given lookups preventng concurrent Calculate jobs
	 **/ 	
	public static void clearCalculateJobId(Set<String> lookupIds)
	{
	    // LookupRollupSummaryId__c are 18 char Ids ensure the ones we filter on are as well 
	    Set<String> char18Ids = new Set<String>();
	    for(String lookupId : lookupIds) {
	        char18Ids.add((String) ((Id)lookupId));
	    }
		delete [select Id from LookupRollupCalculateJob__c where LookupRollupSummaryId__c in :char18Ids];
	}
	
	/**
	 * Method called from the RollupJob to handle summary schedule items that have been generated
	 **/
	public static void processScheduleItems(List<LookupRollupSummaryScheduleItems__c> rollupSummaryScheduleItems)
	{
		// Load related Lookup summaries for the scheduled items
		Set<String> lookupIds = new Set<String>();
		for(LookupRollupSummaryScheduleItems__c scheduleItem : rollupSummaryScheduleItems) {			
			lookupIds.add(scheduleItem.LookupRollupSummary2__c);
		}
		Map<String, RollupSummary> lookups = 
			RollupSummary.toMap(new RollupSummariesSelector().selectById(lookupIds));
			
		// Group the parent Id's by parent type
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		Map<String, Set<Id>> parentIdsByParentType = new Map<String, Set<Id>>();  
		for(LookupRollupSummaryScheduleItems__c scheduleItem : rollupSummaryScheduleItems)
		{
			Id parentId = scheduleItem.ParentId__c;
			RollupSummary lookup = lookups.get(scheduleItem.LookupRollupSummary2__c);
			// The lookup definition could have been changed or due to a historic bug in correctly associated
			if(parentId.getSobjectType() != gd.get(lookup.ParentObject))
				continue;
			Set<Id> parentIds = parentIdsByParentType.get(lookup.ParentObject);
			if(parentIds==null)
				parentIdsByParentType.put(lookup.ParentObject, (parentIds = new Set<Id>()));
			parentIds.add(parentId);
		}
			
		// Group lookups by parent and relationship into LREngine ctx's
		List<LREngine.Context> engineCtxByParentRelationship = createLREngineContexts(lookups.values());

		// Process each context (parent child relationship) and its associated rollups
		Map<Id, SObject> masterRecords = new Map<Id, SObject>();		
		for(LREngine.Context ctx : engineCtxByParentRelationship)
		{
			Set<Id> masterIds = parentIdsByParentType.get(ctx.master.getDescribe().getName());
			// This maybe null if the reconcilation check above to match master ID to lookup parent failed
			if(masterIds!=null && masterIds.size()>0) {
				for(SObject masterRecord : LREngine.rollup(ctx, masterIds))
				{
					// Skip master records without Id's (LREngine can return these where there was 
					//	no related master records to children, for examlpe where a relationship is optional)
					if(masterRecord.Id==null)
						continue;
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
		}

		// Map rollup summary schedule items by parent id, in order to remove only those whos parent/master record actually gets updated below
		Map<Id, List<LookupRollupSummaryScheduleItems__c>> rollupSummaryScheduleItemsByParentId = 
			new Map<Id, List<LookupRollupSummaryScheduleItems__c>>();
		for(LookupRollupSummaryScheduleItems__c rollupSummaryScheduleItem : rollupSummaryScheduleItems)
		{
			List<LookupRollupSummaryScheduleItems__c> rollupsByParentId = rollupSummaryScheduleItemsByParentId.get(rollupSummaryScheduleItem.ParentId__c);
			if(rollupsByParentId==null)
			{
				rollupsByParentId = new List<LookupRollupSummaryScheduleItems__c>();
				rollupSummaryScheduleItemsByParentId.put(rollupSummaryScheduleItem.ParentId__c, rollupsByParentId);
			}
			rollupsByParentId.add(rollupSummaryScheduleItem);
		}
			
		// Update master records
		List<LookupRollupSummaryLog__c> rollupSummaryLogs = new List<LookupRollupSummaryLog__c>();
		List<SObject> masterRecordList = masterRecords.values();
		List<Database.Saveresult> saveResults = updateRecords(masterRecordList, false, false);
		
		// Log errors to the summary log
		Integer masterRecordIdx = 0;
		for(Database.Saveresult saveResult : saveResults)
		{
			// Errors?
			if(!saveResult.isSuccess())
			{
				// Was this failure due to the parent record no longer existing?
				Boolean masterRecordDeletionError = false;
				// Log the failure updating the master record for review
				LookupRollupSummaryLog__c logEntry = new LookupRollupSummaryLog__c();
				logEntry.ErrorMessage__c = '';
				logEntry.ParentId__c = masterRecordList[masterRecordIdx].Id;
				logEntry.ParentObject__c = masterRecordList[masterRecordIdx].Id.getSObjectType().getDescribe().getName();
				List<Database.Error> databaseErrors = saveResult.getErrors();
				for(Database.Error databaseError : databaseErrors) {
					logEntry.ErrorMessage__c+= databaseError.getMessage() + ' : ' + databaseError.getStatusCode() + ' ' + databaseError.getFields() + '\n';
					if(databaseError.getStatusCode() == StatusCode.ENTITY_IS_DELETED) {
						masterRecordDeletionError = true;
						break;
					}
				}
				// Was this error a result of the parent record being deleted?
				if(!masterRecordDeletionError) {
					rollupSummaryLogs.add(logEntry);
					// Remove from scheduled items to be deleted to allow a retry
					rollupSummaryScheduleItemsByParentId.remove(masterRecordList[masterRecordIdx].Id);					
				}
			}
			masterRecordIdx++;
		}
			
		// Insert any logs for master records that failed to update (upsert to only show last message per parent)
		upsert rollupSummaryLogs ParentId__c;
		
		// Delete any old logs entries for master records that have now been updated successfully
		delete [select Id from LookupRollupSummaryLog__c where ParentId__c in :rollupSummaryScheduleItemsByParentId.keySet()];
		
		// Delete any schedule items for successfully updated master records
		List<LookupRollupSummaryScheduleItems__c> scheduleItemsToDelete = new List<LookupRollupSummaryScheduleItems__c>();
		for(List<LookupRollupSummaryScheduleItems__c> scheduleItems : rollupSummaryScheduleItemsByParentId.values())
			scheduleItemsToDelete.addAll(scheduleItems);
		delete scheduleItemsToDelete;
	}

	/**
	 * Performs a recalculate on the master records for the given rollup definitions, outputs any errors in the rollup summary log
	 *
	 * @param lookups Lookup to calculate perform
	 * @param childRecords Child records being modified
	 **/ 
	public static void updateMasterRollups(Set<String> lookupIds, Set<Id> masterRecordIds)
	{		
		// Process rollup
		List<RollupSummary> lookups = new RollupSummariesSelector().selectById(lookupIds);
		Map<Id, SObject> masterRecords = new Map<Id, SObject>();
		List<LREngine.Context> ctxs = createLREngineContexts(lookups);		
		Set<Id> ctxMasterIds = new Set<Id>();
		for(LREngine.Context ctx : ctxs)
		{
			// Produce a set of master Id's applicable to this context (parent only)			
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

		// Master records to update		
		List<SObject> masterRecordList = masterRecords.values();

		// The following optimisation currently only works if processing a single rollup (parent)
		if(ctxs.size()==1) {
			LREngine.Context ctx = ctxs[0];
			// Query the current values of the master objects rollup fields
			fflib_QueryFactory masterRecordQuery = new fflib_QueryFactory(ctx.master);
			for(LREngine.RollupSummaryField fieldToRoll : ctx.fieldsToRoll) {
				masterRecordQuery.selectField(fieldToRoll.master.getSObjectField());
			}
			// https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/619			
			masterRecordQuery.setCondition(
				// It appears there is no Apex Describe to determine FOR UPDATE support
				ctx.master == User.SObjectType ? 
					'Id in :ctxMasterIds' : 'Id in :ctxMasterIds FOR UPDATE');
			// Filter master records to update only if rollups have changed
			Map<Id, SObject> currentMasterRecordsById = new Map<Id, SObject>(Database.query(masterRecordQuery.toSOQL()));
			List<SObject> newMasterRecordList = new List<SObject>();
			for(SObject masterRecordToUpdate : masterRecordList) {
				SObject currentRecord = currentMasterRecordsById.get(masterRecordToUpdate.Id);
				boolean rollupValueChange = false;
				for(LREngine.RollupSummaryField fieldToRoll : ctx.fieldsToRoll) {
					if(currentRecord.get(fieldToRoll.master.getSObjectField()) == masterRecordToUpdate.get(fieldToRoll.master.getSObjectField())) {
						continue;
					}
					rollupValueChange = true;
					break;
				}			
				if(rollupValueChange) {
					newMasterRecordList.add(masterRecordToUpdate);
				}
			}
			masterRecordList = newMasterRecordList;
		}

		// Update master records
		List<Database.Saveresult> saveResults = updateRecords(masterRecordList, false, false);
		
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
	 * Insert the given rollup summaries (only supports Custom Metadata backed records)
	 **/
	public static List<Id> create(List<SObject> rollupSummaryRecords) {
		// Valid records?
		List<SObject> validRecords = validateRollups(rollupSummaryRecords);
		// Create
		CustomMetadataService.createMetadata(validRecords);
		return null;
	}

	/**
	 * Update the given rollup summaries (only supports Custom Metadata backed records)
	 **/
	public static List<Id> update_x(List<SObject> rollupSummaryRecords) {
		// Valid records?
		List<SObject> validRecords = validateRollups(rollupSummaryRecords);
		// Create
		CustomMetadataService.updateMetadata(validRecords);
		return null;
	}

	/**
	 * Delete the given rollup summaries (only supports Custom Metadata backed records)
	 **/
	public static void delete_x(List<String> rollupSummaryIds) {
		// Currently assumes the Id's are Custom Metadata record DeveloperName's
		CustomMetadataService.deleteMetadata(LookupRollupSummary2__mdt.getSObjectType(), rollupSummaryIds);
	}

    /**
     * Throws RollupServiceException if the Calculate Job is already running for the given lookup
     **/    
    @TestVisible
    private static void checkJobAlreadyRunning(String lookupId, String lookupName) {
        try {
            // This object has a unique constraint over LookupRollupSummaryId__c
            insert new LookupRollupCalculateJob__c(LookupRollupSummaryId__c = (String) ((Id)lookupId));
        } catch (Exception e) {
            throw RollupServiceException.jobAlreadyRunning(lookupName);
        }       
    }

	/**
	 * Validates records (currenyly only Custom Metadata based ones)
	 **/
	private static List<SObject> validateRollups(List<SObject> rollupSummaryRecords) {

		// Process only Custom Metadata records here
		List<LookupRollupSummary2__mdt> mdtRecords = new List<LookupRollupSummary2__mdt>();
		for(SObject rollupSummaryRecord : rollupSummaryRecords) {
			if(rollupSummaryRecord instanceof LookupRollupSummary2__mdt) {
				mdtRecords.add((LookupRollupSummary2__mdt) rollupSummaryRecord);
			}
		}
		if(mdtRecords.size()==0)
			return mdtRecords;

		// Validate via Domain class and throw appropirte exception
		RollupSummaries rollupSummaries = new RollupSummaries(mdtRecords);
		rollupSummaries.onValidate();
		RollupValidationException validationException = new RollupValidationException();
		for(RollupSummary rollupSummaryRecord : rollupSummaries.Records) {
			if(rollupSummaryRecord.Error!=null || 
			   rollupSummaryRecord.Fields.Errors.size() >0) {
				RollupRecordValidationError recordError = new RollupRecordValidationError();
				recordError.Error = rollupSummaryRecord.Error;
				recordError.FieldErrors = rollupSummaryRecord.Fields.Errors;
				validationException.RecordErrors.add(recordError);
			}
		}
		if(validationException.RecordErrors.size()>0) 
			throw validationException;

		return (List<SObject>) mdtRecords;
	}

	/**
	 * Represents a rollup validation exception, contains a list of record errors
	 **/
	public class RollupValidationException extends Exception {
		public final List<RollupRecordValidationError> RecordErrors = new List<RollupRecordValidationError>();
	}

	/**
	 * Represents record level error and/or field level errors
	 **/
	public class RollupRecordValidationError {
		public Id Id {get; private set;}
		public String Error {get; private set;}
		public List<String> FieldErrors {get; private set;}
	}

	/**
	 * Process rollups for specified modes 
	 *
	 * @param childRecords List of childRecords to process rollups against
	 * @param existingRecords Map of existing records.  Pass null if no existing records are available.
	 * @param calculationModes Modes to use to determine which rollups to evaluate and process
	 *
	 * @remark Will process both lists looking for insert/update/delete/undelete and execute rollups on the following conditions:
	 *             1) if in newRecords and not in existingRecords (insert and undelete)
	 *             2) if in existingRecords and not in newRecords (delete)
	 *             3) if in existingRecords and newRecords and rollup FieldToAggregate__c has changed (update)
	 *
	 **/
	@TestVisible	 
	private static void handleRollups(Map<Id, SObject> existingRecords, Map<Id, SObject> newRecords, Schema.SObjectType sObjectType, List<RollupSummaries.CalculationMode> calculationModes)
	{
		// make sure we have Maps to avoid conditional statements in loops below
		if (existingRecords == null) {
			existingRecords = new Map<Id, SObject>();
		}
		if (newRecords == null) {
			newRecords = new Map<Id, SObject>();
		}

		// Anything to process?
		if (existingRecords.isEmpty() && newRecords.isEmpty()) {
			return;
		}

		// Its possible for the user to deploy a trigger on parent objects, to monitor for merge operations...
		DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();
		Set<Id> masterRecordIdsFromMerge = new Set<Id>();
		if(sObjectDescribe.isMergeable()) {
			for(SObject existingRecord : existingRecords.values()) {
				Id masterRecordId = (Id) existingRecord.get('MasterRecordId');
				if(masterRecordId!=null) {
					masterRecordIdsFromMerge.add(masterRecordId);					
				}
			}			
		}
	
		// If this is a parent record merge operation, determine child object rollups to recalculate...
		Boolean scheduleAllRollups = false;
		Set<SObjectType> childObjects = new Set<SObjectType>();
		childObjects.add(sObjectType);
		if(masterRecordIdsFromMerge.size()>0) {
			// If a parent record is being merged, include a recalc of any related child rollups
			List<Schema.ChildRelationship> childRelationships = sObjectDescribe.getChildRelationships();
			for(Schema.ChildRelationship childRelationship : childRelationships) {
				childObjects.add(childRelationship.getChildSObject());
			}
			// Any rollups associated with these child objects will need to done in async, 
			//   as parent records cannot be updated realtime since the platform is also updating them
			scheduleAllRollups = true;
		}

		// Are there any rollups to process?
		List<RollupSummary> lookups = describeRollups(childObjects, calculationModes);
		if(lookups.isEmpty())
			return; // Nothing to see here! :)
			
		// if records exist in both maps, then we need to go through change detection.
		// Has anything changed on the child records in respect to the fields referenced on the lookup definition?
		// Or does a record exist in one map but not the other
		if(!existingRecords.isEmpty() && !newRecords.isEmpty())
		{
			// Master records to update
			Set<Id> masterRecordIds = new Set<Id>();
			 
			// Set of field names from the child used in the rollup to search for changes on
			Set<String> fieldsToSearchForChanges = new Set<String>(); 
			Set<String> relationshipFields = new Set<String>(); 
			// keep track of fields that should trigger a rollup to be processed
			// this avoids having to re-parse RelationshipCriteria & OrderBy fields during field change detection
			Map<Id, Set<String>> fieldsInvolvedInLookup = new Map<Id, Set<String>>();
			for(RollupSummary lookup : lookups)
			{
				Set<String> lookupFields = new Set<String>();				
				lookupFields.add(lookup.FieldToAggregate);
				if(!String.isBlank(lookup.RelationshipCriteriaFields)) {
					for(String criteriaField : lookup.RelationshipCriteriaFields.split('[\r\n]+')) {
						lookupFields.add(criteriaField);
					}
				}
				// only include order by fields when query based rollup (concat, first, last, etc.) since changes to them
				// will not impact the outcome of an aggregate based rollup (sum, count, etc.)
				if(LREngine.isQueryBasedRollup(RollupSummaries.OPERATION_PICKLIST_TO_ENUMS.get(lookup.AggregateOperation)) && !String.isBlank(lookup.FieldToOrderBy)) {
					List<Utilities.Ordering> orderByFields = Utilities.parseOrderByClause(lookup.FieldToOrderBy);
					if (orderByFields != null && !orderByFields.isEmpty()) {
						for (Utilities.Ordering orderByField :orderByFields) {
							lookupFields.add(orderByField.getField());
						}
					}
				}

				// add all lookup fields to our master list of fields to search for
				fieldsToSearchForChanges.addAll(lookupFields);

				// add relationshipfield to fields for this lookup
				// this comes after adding to fieldsToSearchForChanges because we handle
				// change detection separately for non-relationship fields and relationship fields
				lookupFields.add(lookup.RelationShipField);

				// add to map for later use
				fieldsInvolvedInLookup.put(lookup.Id, lookupFields);

				// add relationship field to master list of relationship fields
				relationshipFields.add(lookup.RelationShipField);
			}
			
			// merge all record Id's
			Set<Id> mergedRecordIds = new Set<Id>(existingRecords.keySet());
			mergedRecordIds.addAll(newRecords.keySet());

			// Determine if a a field referenced on the lookup has changed and thus if the lookup itself needs recalculating
			Set<String> fieldsChanged = new Set<String>();  
			for(Id recordId : mergedRecordIds)
			{
				// keep track of whether or not this child has changed in any of the fields involved in
				// lookups that are NOT relationship fields themselves.  We'll check relationship fields
				// separately to avoid unnecessary rollups firing on master records that don't require updating				
				Boolean nonRelationshipFieldsChanged = false;
							
				// Determine if any of the fields referenced on our selected rollups have changed on this record
				for(String fieldToSearch : fieldsToSearchForChanges)
				{
					// retrieve old and new records and values if they exist
					SObject oldRecord = existingRecords.get(recordId);
					Object oldValue = oldRecord == null ? null : oldRecord.get(fieldToSearch);
					SObject newRecord = newRecords.get(recordId);
					Object newValue = newRecord == null ? null : newRecord.get(fieldToSearch);

					// Register this field as having changed?
					// if in old but not in new then its a delete and rollup should be processed
					// if in new but not in old then its an insert and rollup should be processed
					// if in both then its an update and field change detection should occur and rollup should be processed if different
					if((oldRecord == null) || (newRecord == null) || (newValue != oldValue)) {
						fieldsChanged.add(fieldToSearch);
						// mark record as having a non-relationship field changed
						nonRelationshipFieldsChanged = true;
					}
				}
				
				// iterate relationship fields looking and track old/new master id
				// if there were changes to the relationship field itself or any 
				// other fields involved in a lookup
				for(String relationshipField : relationshipFields)
				{
					// should we add associated master to list?
					// default to whether or not a non-relationship field on record has changed
					Boolean addMasterIds = nonRelationshipFieldsChanged;

					// retrieve old and new records and values if they exist
					SObject oldRecord = existingRecords.get(recordId);
					Object oldValue = oldRecord == null ? null : oldRecord.get(relationshipField);
					SObject newRecord = newRecords.get(recordId);
					Object newValue = newRecord == null ? null : newRecord.get(relationshipField);

					// Register this field as having changed?
					// if in old but not in new then its a delete and rollup should be processed and master ids included
					// if in new but not in old then its an insert and rollup should be processed and master ids included
					// if in both then its an update and field change detection should occur and rollup should be processed and master ids included if different
					if((oldRecord == null) || (newRecord == null) || (newValue != oldValue)) {
						fieldsChanged.add(relationshipField);
						// master field itself changed so we force old/new master ids to be added for processing
						addMasterIds = true;
					}

					// if relationship field itself changed or if change in another non-relationship field
					// Add both old and new value to master record Id list for relationship fields 
					// to ensure old and new parent master records are updated (re-parenting)
					if (addMasterIds)
					{
						if(newValue!=null)
							masterRecordIds.add((Id) newValue);
						if(oldValue!=null)
							masterRecordIds.add((Id) oldValue);
					}
				}
			}
			
			// Build a revised list of lookups to process that includes only where fields used in the rollup have changed
			List<RollupSummary> lookupsToProcess = new List<RollupSummary>(); 
			for(RollupSummary lookup : lookups)
			{
				// Are any of the changed fields used by this lookup?
				Set<String> lookupFields = fieldsInvolvedInLookup.get(lookup.Id);
				for (String lookupField :lookupFields) {
					if (fieldsChanged.contains(lookupField)) {
						// add lookup to be processed and exit for loop since we have our answer
						lookupsToProcess.add(lookup);
						break;
					}
				}
			}
			lookups = lookupsToProcess;
			
			// Rollup child records and update master records 
			if(lookupsToProcess.size()>0)
				updateRecords(updateMasterRollupsTrigger(lookups, masterRecordIds, false), false, true);
			return;
		}
			
		// Rollup whichever side has records and update master records
		// only one map should have records at this point
		Boolean isDeleting = newRecords.isEmpty();
		Set<Id> masterRecordIds = new Set<Id>(masterRecordIdsFromMerge);
		Map<Id, SObject> recordsToProcess = existingRecords.isEmpty() ? newRecords : existingRecords;
		for(SObject childRecord : recordsToProcess.values()) {
			for(RollupSummary lookup : lookups) {
				// Does this rollup apply to this child record?
				if(lookup.ChildObject.equalsIgnoreCase(sObjectDescribe.getName())) {
					if(childRecord.get(lookup.RelationShipField)!=null) {
						// Check for self referencing rollups, https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/39
						Id masterRecordId = (Id)childRecord.get(lookup.RelationShipField);
						if(isDeleting && masterRecordId == childRecord.Id) {
							continue;
						}
						masterRecordIds.add(masterRecordId);
					}					
				}
			}
		}

		// Process the rollups and update the master records
		updateRecords(
			updateMasterRollupsTrigger(lookups, masterRecordIds, scheduleAllRollups), false, true);
	}	
	
	/**
	 * Method wraps the LREngine.rolup method, provides context via the lookups described in RollupSummary
	 *
	 * @param lookups Lookup to calculate perform
	 * @param childRecords Child records being modified
	 * @returns Array of master records containing the updated rollups, calling code must perform update DML operation
	 **/ 
	private static List<SObject> updateMasterRollupsTrigger(List<RollupSummary> lookups, Set<Id> masterRecordIds, Boolean scheduleAllRollups)
	{
		// Process lookups, 
		//    Realtime & Developer are added to a list for later LRE context creation and processing, 
		//    Scheduled result in parent Id's being emitted to scheduled item object for later processing
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        List<RollupSummary> runnowLookups = new List<RollupSummary>();      
        List<LookupRollupSummaryScheduleItems__c> scheduledItems = new List<LookupRollupSummaryScheduleItems__c>(); 
        List<LookupRollupSummaryScheduleItems__c> scheduledItemsForMDTs = new List<LookupRollupSummaryScheduleItems__c>(); 
        for(RollupSummary lookup : lookups)
        {
            if(lookup.CalculationMode == RollupSummaries.CalculationMode.Scheduled.name() || scheduleAllRollups)
            {       
            	// For polymoprhic relationships the master Id list maybe mixed types, associated with the correct rollup
                SObjectType parentType = gd.get(lookup.ParentObject);
                if(parentType==null)
                	continue;
                // For scheduled rollups queue the parent Id record for processing
                for (Id parentId : masterRecordIds)
                {
                	if(parentId.getSobjectType() == parentType) {
	                    LookupRollupSummaryScheduleItems__c scheduledItem = new LookupRollupSummaryScheduleItems__c();
	                    scheduledItem.Name = parentId;
	                    scheduledItem.LookupRollupSummary2__c = lookup.Id;
	                    scheduledItem.ParentId__c = parentId;
	                    scheduledItem.QualifiedParentID__c = parentId + '#' + lookup.Id; 
	                    scheduledItems.add(scheduledItem);
	                    if(lookup.Record instanceof LookupRollupSummary2__mdt) {
	                 		scheduledItemsForMDTs.add(scheduledItem);   	
	                    }
	                }
                }                   
            }
            else if(lookup.CalculationMode == RollupSummaries.CalculationMode.Realtime.name() ||
            	lookup.CalculationMode == RollupSummaries.CalculationMode.Developer.name())
            {
                // Filter realtime & Developer lookups in order to generate LRE contexts below
                runnowLookups.add(lookup);
            }
        }

        // Add parent Id's to schedule items object
        upsert scheduledItems QualifiedParentID__c;

		// Process each context (parent child relationship) and its associated rollups
		Map<Id, SObject> masterRecords = new Map<Id, SObject>();		
		for(LREngine.Context ctx : createLREngineContexts(runnowLookups))
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
	private static List<RollupSummary> describeRollups(Set<SObjectType> childObjectTypes, List<RollupSummaries.CalculationMode> calculationModes)
	{	
		// Query applicable lookup definitions
		Set<String> childNames = new Set<String>();
		for(SObjectType sobjectType : childObjectTypes) {
			childNames.add( sobjectType.getDescribe().getName());
		}
		List<RollupSummary> lookups =
			new RollupSummariesSelector(false).selectActiveByChildObject(
				calculationModes, 
				childNames);
		return lookups;		
	}
		
	/**
	 * Method takes a list of Lookups and creates the most optimum list of LREngine.Context's to execute
	 **/
	private static List<LREngine.Context> createLREngineContexts(List<RollupSummary> lookups)
	{ 
		// list of contexts generated
		List<LREngine.Context> engineContexts = new List<LREngine.Context>();
		// map of context criteria (except for order by) to a map of orderby with context		
		Map<String, Map<String, LREngine.Context>> engineCtxByParentRelationship = 
			new Map<String, Map<String, LREngine.Context>>();
		// list of rollupsummaryfields that do not have a specific orderby
		List<LookupRollupSummaryWrapper> noOrderByLookupWrappers = new List<LookupRollupSummaryWrapper>();
		Map<Id, LookupRollupSummaryScheduleItems__c> scheduledItems = 
			new Map<Id, LookupRollupSummaryScheduleItems__c>(); 
		for(RollupSummary lookup : lookups)
		{
			// if no order is specified, we'll defer context identification until after we build contexts for
			// all the lookups that contain a specific order by
			LookupRollupSummaryWrapper lookupWrapper = createLSFWrapper(lookup);
			if (!lookupWrapper.OrderByRequired) {
				// add to the list of lookups that do not have an order by specified
				noOrderByLookupWrappers.add(lookupWrapper);
			} else {
				// Note that context key here will not include the order by
				String contextKey = getContextKey(lookupWrapper);
				// obtain the map of orderby to context based on contextKey
				Map<String, LREngine.Context> lreContextByOrderBy = engineCtxByParentRelationship.get(contextKey);
				// if we don't have a map yet, create it
				if (lreContextByOrderBy == null) {
					lreContextByOrderBy = new Map<String, LREngine.Context>();
					engineCtxByParentRelationship.put(contextKey, lreContextByOrderBy);
				}
				String orderBy = lookupWrapper.OrderByClause; // this will be the FieldToOrderBy__c from the RollupSummary
				// Lowering case on Describable fields is only required for Legacy purposes since RollupSummary records
				// will be updated with describe names on insert/update moving forward.				
				String orderByKey = orderBy.toLowerCase();
				// obtain the context for this orderby key
				LREngine.Context lreContext = lreContextByOrderBy.get(orderByKey);
				// if not context yet, create one
				if(lreContext==null)
				{								
					// Construct LREngine.Context
					lreContext = createContext(lookupWrapper);
					lreContextByOrderBy.put(orderByKey, lreContext);
					engineContexts.add(lreContext);
				}				
				// Add the rollup summary field to the context
				lreContext.add(lookupWrapper.RollupSummaryField);
			}
		}

		// now that we have contexts built for all lookups that have a specific order by
		// we iterate those that do not and pick the first one that matches all other criteria
		// if there is not one that matches other criteria, we create a new context
		if (!noOrderByLookupWrappers.isEmpty())
		{
			// loop through our list of lookups that do not have an orderby specified
			for (LookupRollupSummaryWrapper lookupWrapper :noOrderByLookupWrappers)
			{
				// Note that context key here will not include the order by
				String contextKey = getContextKey(lookupWrapper);			
				// obtain the map of orderby to context based on contextKey
				Map<String, LREngine.Context> lreContextByOrderBy = engineCtxByParentRelationship.get(contextKey);
				// if we don't have a map yet, create it
				if (lreContextByOrderBy == null) {
					lreContextByOrderBy = new Map<String, LREngine.Context>();
					engineCtxByParentRelationship.put(contextKey, lreContextByOrderBy);
				}

				LREngine.Context lreContext = null;
				if (lreContextByOrderBy.isEmpty()) 
				{
					// if we do not have any contexts yet then create one					
					// when created, the OrderBy on the context will be set null since no order by was specified
					// Construct LREngine.Context
					lreContext = createContext(lookupWrapper);
					// ensure key is lowered
					lreContextByOrderBy.put('####NOORDERBY####', lreContext);
					engineContexts.add(lreContext);
				} 
				else 
				{
					// since no orderby was specified we can execute in a non-deterministic manner
					// so for that reason we'll just grab the first one
					// Note - In an effort to support some backwards compat here, we could try to find a context
					//        whos first orderby field (ASC NULLS FIRST) matches this lookups FieldToAggregate__c
					//        however for performance reasons, we'll forgo that and just pick the first
					lreContext = lreContextByOrderBy.values()[0];
				}

				// Add the rollup summary field to the context
				lreContext.add(lookupWrapper.RollupSummaryField);				
			}
		}

		return engineContexts;
	}

	private static LREngine.Context createContext(LookupRollupSummaryWrapper lookupWrapper)
	{
		return new LREngine.Context(
						lookupWrapper.ParentObjectType, // parent object
	                    lookupWrapper.ChildObjectType,  // child object                    
	                    lookupWrapper.RelationshipField.getDescribe(), // relationship field name
	                    lookupWrapper.Lookup.RelationShipCriteria,
	                    lookupWrapper.SharingMode,
	                    lookupWrapper.OrderByClause,
	                    lookupWrapper.AggregateAllRows);		
	}

	private static SObjectType getSObjectType(String sObjectName)
	{
		fflib_SObjectDescribe describe = fflib_SObjectDescribe.getDescribe(sObjectName);
		return (describe == null) ? null : describe.getSObjectType();

	}

	private static Map<String, Schema.SObjectField> getSObjectTypeFields(SObjectType sObjectType)
	{
		return fflib_SObjectDescribe.getDescribe(sObjectType).getFieldsMap();
	}

	private class LookupRollupSummaryWrapper
	{
		public RollupSummary Lookup;		
		public Schema.SObjectType ParentObjectType;
		public Schema.SObjectType ChildObjectType;
		public Schema.SObjectField FieldToAggregate;		
		public Schema.SObjectField RelationshipField;
		public Schema.SObjectField AggregateResultField;
		public Boolean AggregateAllRows;
		public LREngine.SharingMode SharingMode;
		public Boolean OrderByRequired; // true if FieldToOrderBy__c is not blank
		public String OrderByClause; // FieldToOrderBy__c if OrderByRequired is true; null otherwise
		public LREngine.RollupSummaryField RollupSummaryField;
	}

	private static LookupRollupSummaryWrapper createLSFWrapper(RollupSummary lookup)
	{
		// Resolve (and cache) SObjectType's and fields for Parent and Child objects
		SObjectType parentObjectType = getSObjectType(lookup.ParentObject);
		if(parentObjectType==null)
			throw RollupServiceException.invalidRollup(lookup, 'Parent Object : ' + lookup.ParentObject);
		Map<String, Schema.SObjectField> parentFields = getSObjectTypeFields(parentObjectType);
		SObjectType childObjectType = getSObjectType(lookup.ChildObject);
		if(childObjectType==null)
			throw RollupServiceException.invalidRollup(lookup, 'Child Object : ' + lookup.ChildObject);
		Map<String, Schema.SObjectField> childFields = getSObjectTypeFields(childObjectType);
		SObjectField fieldToAggregate = childFields.get(lookup.FieldToAggregate);
		SObjectField relationshipField = childFields.get(lookup.RelationshipField);
		SObjectField aggregateResultField = parentFields.get(lookup.AggregateResultField);
		if(fieldToAggregate==null)
			throw RollupServiceException.invalidRollup(lookup, 'Field to Aggregate: ' + lookup.FieldToAggregate);
        if(relationshipField==null)
            throw RollupServiceException.invalidRollup(lookup, 'Relationship Field: ' + lookup.RelationshipField);
        if(aggregateResultField==null)
            throw RollupServiceException.invalidRollup(lookup, 'Aggregate Result Field: ' + lookup.AggregateResultField);

		// Summary field definition used by LREngine
		LREngine.RollupSummaryField rsf = 
            new LREngine.RollupSummaryField(
				aggregateResultField.getDescribe(),
				fieldToAggregate.getDescribe(),
				RollupSummaries.OPERATION_PICKLIST_TO_ENUMS.get(lookup.AggregateOperation),
            	lookup.ConcatenateDelimiter,
            	Integer.valueOf(lookup.RowLimit));

		LookupRollupSummaryWrapper wrapper = new LookupRollupSummaryWrapper();
		wrapper.Lookup = lookup;
		wrapper.ParentObjectType = parentObjectType;
		wrapper.ChildObjectType = childObjectType;
		wrapper.FieldToAggregate = fieldToAggregate;
		wrapper.RelationshipField = relationshipField;
		wrapper.AggregateResultField = aggregateResultField;
		wrapper.AggregateAllRows = lookup.AggregateAllRows;
		wrapper.SharingMode =
			lookup.CalculationSharingMode == null || lookup.CalculationSharingMode == 'User' ?
				LREngine.SharingMode.User : LREngine.SharingMode.System_x;
		// if order by is not specified, orderby will be null else it will be FieldToOrderBy__c
		wrapper.OrderByRequired = !String.isBlank(lookup.FieldToOrderBy);
		wrapper.OrderByClause =  wrapper.OrderByRequired ? lookup.FieldToOrderBy : null;
		wrapper.RollupSummaryField = rsf;

		return wrapper;
	}

	private static String getContextKey(LookupRollupSummaryWrapper lookupWrapper)
	{
		// Context Key Based On: ParentObject__c, RelationshipField__c, RelationShipCriteria__c, rsfType, SharingMode, AggergateAllRows
		// Note we do not include OrderBy here because orderby map is contained within the map of contextKeys
		String rsfType = lookupWrapper.RollupSummaryField.isAggregateBasedRollup() ? 'aggregate' : 'query';
		// Lowering case on Describable fields is only required for Legacy purposes since RollupSummary records
		// will be updated with describe names on insert/update moving forward.
		// Ideally this would not be needed to save CPU cycles but including to ensure context is properly re-used when possible for
		// rollups that have not been updated/inserted after the insert/update enhancement is applied
		// Unable to lower RelationShipCriteria__c because of field value case-(in)sensitivity configuration
		return  (lookupWrapper.Lookup.ParentObject.toLowerCase() + '#' + 
			     lookupWrapper.Lookup.RelationshipField.toLowerCase() + '#' + 
			     lookupWrapper.Lookup.RelationShipCriteria + '#' + 
			     rsfType + '#' + 
			     lookupWrapper.SharingMode + '#' +
			     lookupWrapper.AggregateAllRows);
	}
	
	/**
	 * Wrapper around DML allowing with or without sharing to be applied and all or nothing exception handling
	 **/
	private static List<Database.Saveresult> updateRecords(List<SObject> masterRecords, Boolean withSharing, Boolean allOrNothing)
	{
		return withSharing ?
			new UpdateWithSharing(masterRecords).updateRecords(allOrNothing) :
			new UpdateWithoutSharing(masterRecords).updateRecords(allOrNothing);
	}
	
	private virtual class Updater	
	{
		protected List<SObject> masterRecords;
		
		public Updater(List<SObject> masterRecords)
		{
			this.masterRecords = masterRecords;	
		}
				
		public virtual List<Database.Saveresult> updateRecords(boolean allOrNothing)
		{
			// sort (selection sort) masterRecords to avoid having more than 10 chunks in a single database operation
			// masterRecords.sort() will not work
			Integer indexOfMin;
			for( Integer outerIndex = 0; outerIndex < masterRecords.size(); outerIndex++ ){
				indexOfMin = outerIndex;
				for( Integer innerIndex = outerIndex; innerIndex < masterRecords.size(); innerIndex++ ){
					if( String.valueOf(masterRecords.get(indexOfMin).getSObjectType()).compareTo( String.valueOf(masterRecords.get(innerIndex).getSObjectType()) ) > 0 ){
						indexOfMin = innerIndex;
					}
				}
				SObject temp = masterRecords.get(outerIndex);
				masterRecords.set( outerIndex, masterRecords.get(indexOfMin) );
				masterRecords.set(indexOfMin, temp);
			}
			try {
                return Database.update(masterRecords, allOrNothing);
			} catch (DMLException e) {
			    // Determine if the exception is due to parent record/s having been deleted
			    Boolean throwException = true;
			    if(allOrNothing) {
			        Integer rowIdx = 0;
			        while(rowIdx<e.getNumDml()) {
                        // Keep looking for entity/record deletion for other parent records
                        if(e.getDmlType(rowIdx) == StatusCode.ENTITY_IS_DELETED) {
                            rowIdx++;
                            continue;
                        } else {
                            break;
                        }                                    			            
			        }
			        throwException = rowIdx < e.getNumDml(); 			     
			    }
			    if(!throwException) {
	                // Swallow an exception describing failure to update parent rows that have been deleted
	                // See related discussion here https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/39
                    return new List<Database.Saveresult>();
			    }
                // Throw on as normal
                throw e;        
			}
		}						
	}
	
	private with sharing class UpdateWithSharing extends Updater 
	{ 
		public UpdateWithSharing(List<SObject> masterRecords) 
			{ super(masterRecords); }
				
		public override List<Database.Saveresult> updateRecords(boolean allOrNothing) 
			{ return super.updateRecords(allOrNothing); }		
	}
	
	private without sharing class UpdateWithoutSharing extends Updater 
	{
		public UpdateWithoutSharing(List<SObject> masterRecords) 
			{ super(masterRecords); }
		
		public override List<Database.Saveresult> updateRecords(boolean allOrNothing) 
			{ return super.updateRecords(allOrNothing); }		
	}
}
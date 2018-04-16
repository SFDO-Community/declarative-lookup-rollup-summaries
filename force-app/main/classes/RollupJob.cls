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
 * Processes chunks of Rollup Summary Schedule records on a scheduled basis
 **/
global with sharing class RollupJob 
	implements Schedulable, Database.Batchable<sObject>
{
	global void execute(SchedulableContext sc)
	{
		// Run the job to process the scheduled records for rolling up
		RollupService.runJobToProcessScheduledItems();
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC)
	{
		// Query all the currently available scheduled records indicating records requiring rollups
		return new RollupSummaryScheduleItemsSelector().selectAllQueryLocator();
	}

	public void execute(Database.BatchableContext BC, List<sObject> rollupSummaryScheduleItems)
	{
		try {
			// Process the given schedule item rollups
			RollupService.processScheduleItems((List<LookupRollupSummaryScheduleItems__c>) rollupSummaryScheduleItems);
		} catch (Exception e) {
			// Ids in scope
			List<String> ids = new List<String>();
			for(Id recordId : new Map<Id, SObject> (rollupSummaryScheduleItems).keySet()) {
				ids.add(recordId);
			}
            // Errors are emailed to the user that scheduled this job
			//  (note parent record update errors are routed via Lookup Rollup Summmary Log via the service code)
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { UserInfo.getUserId() });
            mail.setSubject(String.format('Apex job id {0} failed to update rollups ', new String[] { BC.getJobId() }));
            mail.setPlainTextBody(String.format('Error: {0}. Review Rollup Summary Schedule Items {1}', 
				new String[] { e.getMessage(), String.join(ids, ',') } ));
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } 		
	}
	
	public void finish(Database.BatchableContext BC) { }
}
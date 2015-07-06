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

public class AsyncApexJobsSelector extends fflib_SObjectSelector
{    
    List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            AsyncApexJob.Id,
            AsyncApexJob.Status,
            AsyncApexJob.ExtendedStatus,
            AsyncApexJob.CreatedDate,
            AsyncApexJob.CompletedDate,
            AsyncApexJob.JobItemsProcessed,
            AsyncApexJob.TotalJobItems,
            AsyncApexJob.NumberOfErrors
        };
    }
    
    Schema.SObjectType getSObjectType()
    {
        return AsyncApexJob.sObjectType;
    }

    public override String getOrderBy()
    {
        return 'CreatedDate';
    }
	
    public List<AsyncApexJob> selectById(Set<ID> idSet)
    {
        return (List<AsyncApexJob>) selectSObjectsById(idSet);
    }
    
    /**
     * True if any of the given jobs (expressed by their class names) are queued, processing or preparing
     **/
    public Boolean jobsExecuting(Set<String> classNames)
    {
    	Set<String> statuses = new Set<String> { 'Queued', 'Processing', 'Preparing' };
    	String jobType = 'BatchApex';
    	String query = 
			newQueryFactory().
                setCondition(
					'JobType = :jobType And ' + 
						'ApexClass.Name in :classNames And ' + 
						'Status in :statuses').toSOQL();
    	List<AsyncApexJob> jobs = (List<AsyncApexJob>) 
    		Database.query(query);		    
    	return jobs.size()>0;	
    }
}
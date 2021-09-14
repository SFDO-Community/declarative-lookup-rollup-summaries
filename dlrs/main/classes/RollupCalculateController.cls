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

public with sharing class RollupCalculateController 
{
	private ApexPages.StandardController standardController;
	public String masterObjectWhere { get; set; }
	
	public RollupCalculateController(ApexPages.StandardController standardController)
	{
		this.standardController = standardController;

		// Deprication warning
		if(standardController.getRecord() instanceof LookupRollupSummary__c) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Use of the Lookup Rollup Summaries tab is still functional but no longer being enhanced. Consider using the Manage Lookup Rollup Summaries tab.'));
		}
		
		// Page load messages
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Clicking the Run Full Calculate Job will start a background rebuild for this rollup only.'));
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Once the job completes any failed rollups will be shown in the Rollup Summary Logs tab.'));
	}
	
	public PageReference runCalculateJob()
	{
		try
		{
			// Kickoff the calculate job for this lookup
			RollupService.runJobToCalculate(standardController.getId(), this.masterObjectWhere);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Calculate job started for this lookup.'));
		}
		catch (Exception e)
		{
			ApexPages.addMessages(e);
			return null;
		}

		// Custom Metadata backed rollup?
		if(standardController.getRecord() instanceof LookupRollupSummary2__mdt) {
			PageReference manageRollupsPage = Page.managelookuprollupsummaries;
			manageRollupsPage.getParameters().put('id', standardController.getId());
			return manageRollupsPage;
		}

		return standardController.view();
	}
}
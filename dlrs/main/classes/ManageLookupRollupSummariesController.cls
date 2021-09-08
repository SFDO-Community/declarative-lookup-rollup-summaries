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

public with sharing class ManageLookupRollupSummariesController {

	public LookupRollupSummary2__mdt LookupRollupSummary {get;set;}

	public String selectedLookup {get;set;}
	
	public Boolean MetadataConnectionError {get;set;}	

	public ManageLookupRollupSummariesController() {
		LookupRollupSummary = new LookupRollupSummary2__mdt();
	}

	public List<SelectOption> getLookups() {
		// List current rollup custom metadata configs
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('[new]','Create new...'));
		for(RollupSummary rollup : new RollupSummariesSelector.CustomMetadataSelector(false, false).selectAll())
			options.add(new SelectOption(rollup.Id,rollup.Name));
		return options;
	}

	public PageReference init() {

		// Metadata API connection?
		MetadataConnectionError = !RollupService.checkMetadataAPIConnection();
		if(MetadataConnectionError)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Salesforce Metadata API connection failure, click the link below to configure.'));
			return null;
		}

		// URL parameter?
		selectedLookup = (Id) ApexPages.currentPage().getParameters().get('id');		
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
		}
		return null;
	}

	public PageReference load() {
		// Reload the page
		PageReference newPage = Page.managelookuprollupsummaries;
		newPage.setRedirect(true);
		if(selectedLookup != '[new]')
			newPage.getParameters().put('id', selectedLookup);
		return newPage;
	}

	public PageReference save() {
		try {
			// Insert / Update the rollup custom metadata
			if(LookupRollupSummary.Id==null)
				RollupService.create(new List<SObject> { LookupRollupSummary });
			else
				RollupService.update_x(new List<SObject> { LookupRollupSummary });
			// Reload this page (and thus the rollup list in a new request, metadata changes are not visible until this request ends)
			PageReference newPage = Page.managelookuprollupsummaries;
			newPage.setRedirect(true);
			newPage.getParameters().put('developerName', LookupRollupSummary.DeveloperName);
			return newPage;			
		} catch (RollupService.RollupValidationException e) {
			// Extract errors from exception and display on the page
			for(RollupService.RollupRecordValidationError recordError : e.RecordErrors) {
				if(recordError.Error!=null) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, recordError.Error));
				}
				for(String fieldError : recordError.FieldErrors) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, fieldError));
				}
			}
		} catch (Exception e) {
			ApexPages.addMessages(e);
		}
		return null;
	}

	public PageReference deleteX() {
		try {
			// Delete the rollup custom metadata
			RollupService.delete_X(new List<String> { LookupRollupSummary.DeveloperName });
			// Reload this page (and thus the rollup list in a new request, metadata changes are not visible until this request ends)
			PageReference newPage = Page.managelookuprollupsummaries;
			newPage.setRedirect(true);
			return newPage;			
		} catch (Exception e) {
			ApexPages.addMessages(e);
		}
		return null;
	}	

	public PageReference hideMessage() {
		DeclarativeLookupRollupSummaries__c settings = DeclarativeLookupRollupSummaries__c.getOrgDefaults();
		settings.HideManageLookupRollupSummariesInfo__c = true;
		upsert settings;
		return null;
	}

	public List<SelectOption> getCalculationModes(){
		List<SelectOption> options = new List<SelectOption>();
        for(Schema.Picklistentry picklistEntry : LookupRollupSummary__c.fields.CalculationMode__c.getDescribe().getPickListValues()) {
        	options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        return options;
    }   	

	public List<SelectOption> getAggregateOperations(){
		List<SelectOption> options = new List<SelectOption>();
        for(Schema.Picklistentry picklistEntry : LookupRollupSummary__c.fields.AggregateOperation__c.getDescribe().getPickListValues()) {
        	options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        return options;
    }   	

	public List<SelectOption> getCalculationSharingModes(){
		List<SelectOption> options = new List<SelectOption>();
        for(Schema.Picklistentry picklistEntry : LookupRollupSummary__c.fields.CalculationSharingMode__c.getDescribe().getPickListValues()) {
        	options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        return options;
    }	
}
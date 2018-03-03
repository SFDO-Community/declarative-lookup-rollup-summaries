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
 * Controller logic ensures there is a valid connection to the Metadata API (aka a Remote Site Setting exists for the appropite URL)
 **/
public with sharing class WelcomeController {
	
	public String Host {get;set;}

	public String RemoteSiteName { get { return Utilities.componentPrefix() + 'mdapi'; } }

	public String MetadataResponse {get;set;}
	
	public Boolean MetadataConnectionWarning {get;set;}

	public String MetadataApiException {get;set;}
		
	public PageReference checkMetadataAPIConnection()
	{
		// Get Host Domain
		Host = ApexPages.currentPage().getHeaders().get('Host');
				
		// Attempt to connect to the Metadata API
		MetadataConnectionWarning = false;
		if(!RollupService.checkMetadataAPIConnection())
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to connect to the Salesforce Metadata API.'));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'This could be because it is the first time installing this tool or your Salesforce domain has changed.'));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'A Remote Site Setting must be created or updated in your org before you can use this tool.'));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Press the Create Remote Site Setting button to perform this step or refer to the post install step below to perform this manually.'));
			MetadataConnectionWarning = true;
			MetadataApiException = '';
			if(RollupService.LastMetadataAPIConnectionException!=null)
				MetadataApiException = RollupService.LastMetadataAPIConnectionException.getMessage();
		}
		
		return null;				
	}
	
	public PageReference displayMetadataResponse()
	{
		// Display the response from the client side Metadata API callout
		if(metadataResponse.length()==0)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Remote Site Setting ' + RemoteSiteName + ' has been created.' ));
			MetadataConnectionWarning = false;
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, metadataResponse));
			MetadataConnectionWarning = true;
		}
		return null;
	}	
}
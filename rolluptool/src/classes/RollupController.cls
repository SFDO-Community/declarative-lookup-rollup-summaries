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
 * Handles the Manage Trigger and Calculate Custom Buttons
 **/
public with sharing class RollupController 
{
	public String ZipData { get; set; }	
	
	public MetadataService.AsyncResult AsyncResult {get; private set;}
	
	public LookupRollupSummary__c RollupSummary  { get; set; }

	public String RollupTriggerName { get; set; }
	
	public String RollupTriggerTestName { get; set; }
	
	public Boolean Deployed { get; set; }
	
	public ApexTrigger RollupTrigger { get; private set; }
	
	public ApexClass RollupTriggerTest { get; private set; }
	
	public Integer deployCount;
	
	public RollupController(ApexPages.StandardController standardController)
	{
		// Query Lookup Rollup Summary record
		RollupSummary = new RollupSummariesSelector().selectById(new Set<Id> { standardController.getId() })[0];
		
		// Generate names for test and triggers to deploy / undeploy
		RollupTriggerName = RollupSummaries.makeTriggerName(RollupSummary);
		RollupTriggerTestName = RollupSummaries.makeTriggerTestName(RollupSummary);
				
		// Initialise view state
		init();
	}
	
	public String getPackageXml()
	{
		if(Deployed)
			// package.xml for undeploy
			return 
			    '<?xml version="1.0" encoding="UTF-8"?>' + 
				'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
	    			'<version>28.0</version>' + 
				'</Package>';		
		else
			// package.xml for deploy
			return 
			    '<?xml version="1.0" encoding="UTF-8"?>' + 
				'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
	    			'<types>' + 
	        			'<members>'+RollupTriggerName+'</members>' +
	        			'<name>ApexTrigger</name>' + 
	    			'</types>' + 
	    			'<types>' + 
	        			'<members>'+RollupTriggerTestName+'</members>' +
	        			'<name>ApexClass</name>' + 
	    			'</types>' + 
	    			'<version>28.0</version>' + 
				'</Package>';		
	}
	
	public String getDestructiveChangesXml()
	{
		return 
		    '<?xml version="1.0" encoding="UTF-8"?>' + 
			'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
    			'<types>' + 
        			'<members>'+RollupTriggerName+'</members>' +
        			'<name>ApexTrigger</name>' + 
    			'</types>' + 
    			'<types>' + 
        			'<members>'+RollupTriggerTestName+'</members>' +
        			'<name>ApexClass</name>' + 
    			'</types>' + 
    			'<version>28.0</version>' + 
			'</Package>';				
	}
	
	public String getTriggerTestCodeMetadata()
	{
		return 
		    '<?xml version="1.0" encoding="UTF-8"?>' +
			'<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">' +
			    '<apiVersion>28.0</apiVersion>' + 
			    '<status>Active</status>' +
			'</ApexClass>';		
	}
		
	public String getTriggerTestCode()	
	{
		if(Deployed && RollupTriggerTest!=null)
			// Display currently deployed code for confirmation
			return RollupTriggerTest.Body; 
		else
			// Deploy generated code
			return
			 	'/**\n' +
				' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
				' **/\n' +	
				'@IsTest\n' +	 
			    'private class ' + RollupTriggerTestName + '\n' +  
				'{\n' + 
				'    private static testmethod void testTrigger()\n' +
				'    {\n' + 
				'        // Code to cover the one line trigger, the method called has been tested separately by the packaged tests.\n' +
				'        try { insert new ' + RollupSummary.ChildObject__c + '(); } catch(Exception e) { }\n' +
				'    }\n' +
				'}';
	}
	
	public String getTriggerCodeMetadata()
	{
		return 
		    '<?xml version="1.0" encoding="UTF-8"?>' +
			'<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">' +
			    '<apiVersion>28.0</apiVersion>' + 
			    '<status>Active</status>' +
			'</ApexTrigger>';		
	}
	
	public String getTriggerCode()
	{
		if(Deployed && RollupTrigger!=null)
		{
			// Display currently deployed code for confirmation
			return RollupTrigger.Body;
		} 
		else
		{
			// Namespace?
			Schema.DescribeSObjectResult describe = LookupRollupSummary__c.sObjectType.getDescribe();
			String name = describe.getName();
			String localName = describe.getLocalName();
			String namespace = name.removeEnd(localName).removeEnd('__');					
			// Deploy generated code		
			return 
				'/**\n' +
				' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
				' **/\n' +
				'trigger ' + RollupTriggerName + ' on ' + RollupSummary.ChildObject__c + '\n' + 
				'    (before delete, before insert, before update, after delete, after insert, after undelete, after update)\n'+ 
				'{\n'+
				'    '+ (namespace.length() > 0 ? namespace + '.' : '') + 'RollupService.triggerHandler();\n'+
				'}\n';
		}		
	}
	
	public PageReference deployZip()
	{
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Deployed ? 'Removing...' : 'Deploying...'));

		// Deploy zip file posted back from the page action function				
		MetadataService.MetadataPort service = createService();
		MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.runAllTests = false;
        deployOptions.runTests = null;
        deployOptions.singlePackage = true;		
		AsyncResult = service.deploy(ZipData, DeployOptions);				
		return null;
	}	
	
	public PageReference checkAsyncRequest()
	{	
		// Check the status of the retrieve request
		MetadataService.MetadataPort service = createService();
		MetadataService.AsyncResult[] aysncResults = service.checkStatus(new String[] { AsyncResult.Id });
		if(aysncResults[0].done)
		{
			// Errors?
			if(aysncResults[0].state == 'Error')
			{
			 	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, aysncResults[0].message));
				AsyncResult = null;				
			}
			else
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Deployed ? 'Remove complete.' : 'Deployment complete.'));

				// Deployment errors?
				MetadataService.DeployResult deployResult = service.checkDeployStatus(AsyncResult.Id);
				for(MetadataService.DeployMessage deployMessage : deployResult.messages)
					if(deployMessage.problem!=null)
						ApexPages.addMessage(
							new ApexPages.Message(ApexPages.Severity.Error, 
								deployMessage.fileName + 
									' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + 
										deployMessage.problem));
				
				AsyncResult = null;
				
				// If this was an undeploy and was successful?
				if(Deployed && !ApexPages.hasMessages(ApexPages.Severity.Error))
				{
					// Determine active rollups for this child and deactivate them
					List<LookupRollupSummary__c> rollups = 
						new RollupSummariesSelector().selectActiveByChildObject(
							RollupSummaries.CalculationMode.Realtime, new Set<String> { RollupSummary.ChildObject__c });
					for(LookupRollupSummary__c rollup : rollups)
						rollup.Active__c = false;
					update rollups;
				}
				
				// Initialise view state to try again
				init();
			}
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, (Deployed ? 'Removing...' : 'Deploying...') + '.'.repeat(deployCount++)));
		}	
		return null;
	}
	
	private void init()
	{
		// Already deployed?
		Map<String, ApexTrigger> apexTriggers = new ApexTriggersSelector().selectByName(new Set<String> { RollupTriggerName });
		Map<String, ApexClass> apexClasses = new ApexClassesSelector().selectByName(new Set<String> { RollupTriggerTestName });
		Deployed = apexTriggers.size()==1 && apexClasses.size()==1;
		RollupTrigger = Deployed ? apexTriggers.values()[0] : null;
		RollupTriggerTest = Deployed ? apexClasses.values()[0] : null;
		deployCount = 0;
		
		// Message to confirm current status
		if(Deployed)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Apex Trigger <b>' + RollupTriggerName + '</b> is installed.'));  		
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Apex Class <b>' + RollupTriggerTestName + '</b> is installed.'));  		
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Click <b>Remove</b> to uninstall the Apex Trigger and Apex Class for this child object.'));  					
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Click <b>Deploy</b> to install the Apex Trigger and Apex Class for this child object.'));  					
		}
	}
	
	private static MetadataService.MetadataPort createService()
	{ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
	}		
}
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
 * Handles the Manage Trigger and Calculate Custom Buttons
 **/
public with sharing class RollupController
{
    public static String API_VERSION = '42.0';
    
	public String ZipData { get; set; }	
	
	public MetadataService.AsyncResult AsyncResult {get; private set;}
	
	public RollupSummary RollupSummary  { get; set; }

	public String RollupTriggerName { get; set; }
	
	public String RollupTriggerTestName { get; set; }

	public String RollupParentTriggerName { get; set; }
	
	public String RollupParentTriggerTestName { get; set; }
	
	public Boolean Deployed { get; set; }

	public Boolean ParentMergeable { get; set; }

	public Boolean ParentTriggerRequired { get; set; }
	
	public ApexTrigger RollupTrigger { get; private set; }
	
	public ApexClass RollupTriggerTest { get; private set; }
	
	public ApexTrigger RollupParentTrigger { get; private set; }
	
	public ApexClass RollupParentTriggerTest { get; private set; }
	
	public Integer deployCount;
	
	public Boolean MetadataConnectionError {get;set;}	
	
	public RollupController(ApexPages.StandardController standardController)
	{
		// Query Lookup Rollup Summary record
		this(new RollupSummariesSelector(true, true).selectById(new Set<String> { (String) standardController.getId() })[0]);
	}

	@TestVisible
	private RollupController(RollupSummary rollupSummary) {
		
		this.RollupSummary = rollupSummary;
		
		// Generate names for test and triggers to deploy / undeploy
		RollupTriggerName = RollupSummaries.makeTriggerName(RollupSummary);
		RollupTriggerTestName = RollupSummaries.makeTriggerTestName(RollupSummary);
		RollupParentTriggerName = RollupSummaries.makeParentTriggerName(RollupSummary);
		RollupParentTriggerTestName = RollupSummaries.makeParentTriggerTestName(RollupSummary);

		// Does the parent object support merge?
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		SObjectType parentObjectType = gd.get(RollupSummary.ParentObject);
		ParentTriggerRequired = ParentMergeable = parentObjectType.getDescribe().isMergeable();

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
	    			'<version>' + API_VERSION + '</version>' + 
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
	    			(ParentTriggerRequired ? 
		    			('<types>' + 
		        			'<members>'+RollupParentTriggerName+'</members>' +
		        			'<name>ApexTrigger</name>' + 
		    			'</types>' + 
		    			'<types>' + 
		        			'<members>'+RollupParentTriggerTestName+'</members>' +
		        			'<name>ApexClass</name>' + 
		    			'</types>') : '') + 
	    			'<version>' + API_VERSION + '</version>' + 
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
    			(ParentTriggerRequired ? 
	    			('<types>' + 
	        			'<members>'+RollupParentTriggerName+'</members>' +
	        			'<name>ApexTrigger</name>' + 
	    			'</types>' + 
	    			'<types>' + 
	        			'<members>'+RollupParentTriggerTestName+'</members>' +
	        			'<name>ApexClass</name>' + 
	    			'</types>') : '') +     			
    			'<version>' + API_VERSION + '</version>' + 
			'</Package>';				
	}
	
	/**
	 * CHILD OBJECT CODE
	 **/

	public String getTriggerTestCodeMetadata()
	{
		return 
		    '<?xml version="1.0" encoding="UTF-8"?>' +
			'<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">' +
			    '<apiVersion>' + API_VERSION + '</apiVersion>' + 
			    '<status>Active</status>' +
			'</ApexClass>';		
	}
		
	public String getTriggerTestCode()	
	{
		if(Deployed && RollupTriggerTest!=null)
			// Display currently deployed code for confirmation
			return RollupTriggerTest.Body; 
		else
		{
			// Namespace?
			String namespace = Utilities.namespace();
			// Deploy generated code
			return
			 	'/**\n' +
				' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
				' **/\n' +	
				'@IsTest\n' +	 
			    'private class ' + RollupTriggerTestName + '\n' +  
				'{\n' + 
					 (RollupSummary.TestCodeSeeAllData == true ? '    @IsTest(SeeAllData=true)\n' : '    @IsTest\n') +
				'    private static void testTrigger()\n' +
				'    {\n' + 
					((RollupSummary.TestCode!=null && RollupSummary.TestCode.length()>0) ? 
						RollupSummary.TestCode + '\n' : 
						(
							'        // Force the ' + RollupTriggerName + ' to be invoked, fails the test if org config or other Apex code prevents this.\n' +
							'        ' + (namespace.length() > 0 ? namespace + '.' : '') + 'RollupService.testHandler(new ' + RollupSummary.ChildObject + '());\n')
						) +
				'    }\n' +
				'}';			
		}
	}
	
	public String getTriggerCodeMetadata()
	{
		return 
		    '<?xml version="1.0" encoding="UTF-8"?>' +
			'<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">' +
			    '<apiVersion>' + API_VERSION + '</apiVersion>' + 
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
			String namespace = Utilities.namespace();
			// Deploy generated code		
			return 
				'/**\n' +
				' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
				' **/\n' +
				'trigger ' + RollupTriggerName + ' on ' + RollupSummary.ChildObject + '\n' + 
				'    (before delete, before insert, before update, after delete, after insert, after undelete, after update)\n'+ 
				'{\n'+
				'    '+ (namespace.length() > 0 ? namespace + '.' : '') + 'RollupService.triggerHandler(' + RollupSummary.ChildObject + '.SObjectType);\n'+
				'}\n';
		}		
	}

	/**
	 * PARENT OBJECT CODE
	 **/
	 
	public String getParentTriggerTestCodeMetadata()
	{
		return 
		    '<?xml version="1.0" encoding="UTF-8"?>' +
			'<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">' +
			    '<apiVersion>' + API_VERSION + '</apiVersion>' + 
			    '<status>Active</status>' +
			'</ApexClass>';		
	}
		
	public String getParentTriggerTestCode()	
	{
		if(Deployed && RollupTriggerTest!=null)
			// Display currently deployed code for confirmation
			return RollupParentTriggerTest.Body; 
		else
		{
			// Namespace?
			String namespace = Utilities.namespace();
			// Deploy generated code
			return
			 	'/**\n' +
				' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
				' **/\n' +	
				'@IsTest\n' +	 
			    'private class ' + RollupParentTriggerTestName + '\n' +  
				'{\n' + 
					 (RollupSummary.TestCodeSeeAllData == true ? '    @IsTest(SeeAllData=true)\n' : '    @IsTest\n') +
				'    private static void testTrigger()\n' +
				'    {\n' + 
					((RollupSummary.TestCodeParent!=null && RollupSummary.TestCodeParent.length()>0) ? 
						RollupSummary.TestCodeParent + '\n' : 
						(
							'        // Force the ' + RollupTriggerName + ' to be invoked, fails the test if org config or other Apex code prevents this.\n' +
							'        ' + (namespace.length() > 0 ? namespace + '.' : '') + 'RollupService.testHandler(new ' + RollupSummary.ChildObject + '());\n')
						) +
				'    }\n' +				
				'}';			
		}
	}
	
	public String getParentTriggerCodeMetadata()
	{
		return 
		    '<?xml version="1.0" encoding="UTF-8"?>' +
			'<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">' +
			    '<apiVersion>' + API_VERSION + '</apiVersion>' + 
			    '<status>Active</status>' +
			'</ApexTrigger>';		
	}
	
	public String getParentTriggerCode()
	{
		if(Deployed && RollupTrigger!=null)
		{
			// Display currently deployed code for confirmation
			return RollupParentTrigger.Body;
		} 
		else
		{
			// Namespace?
			String namespace = Utilities.namespace();
			// Deploy generated code		
			return 
				'/**\n' +
				' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
				' **/\n' +
				'trigger ' + RollupParentTriggerName + ' on ' + RollupSummary.ParentObject + '\n' + 
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
		deployOptions.testLevel = 'RunSpecifiedTests';
        deployOptions.runTests = new List<String> { RollupTriggerTestName };
        if(ParentTriggerRequired) {
        	deployOptions.runTests.add(RollupParentTriggerTestName);
        }
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.singlePackage = true;		
		AsyncResult = service.deploy(ZipData, DeployOptions);		
		return null;
	}	
	
	public PageReference checkAsyncRequest()
	{	
		// Check the status of the retrieve request
		MetadataService.MetadataPort service = createService();
		MetadataService.DeployResult deployResult = service.checkDeployStatus(AsyncResult.Id, true);
		if(deployResult.done)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Deployed ? 'Remove complete.' : 'Deployment complete.'));

			// Deployment errors?
			if(deployResult.details!=null && deployResult.details.componentFailures!=null)
				for(MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures)
					if(deployMessage.problem!=null)
						ApexPages.addMessage(
							new ApexPages.Message(ApexPages.Severity.Error, 
								deployMessage.fileName + 
									' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + 
										deployMessage.problem));
			// Test errors?
			MetadataService.RunTestsResult runTestResult = deployResult.details.runTestResult;
			if(runTestResult.numFailures > 0)
				for(MetadataService.RunTestFailure testFailure : runTestResult.failures)
					ApexPages.addMessage(
						new ApexPages.Message(ApexPages.Severity.Error, 
							testFailure.name + '.' + testFailure.methodName + ' ' + testFailure.message + ' ' + testFailure.stackTrace));
			// Code coverage warnings?
			if(runTestResult.codeCoverageWarnings!=null)
				for(MetadataService.CodeCoverageWarning codeCoverageWarning : runTestResult.codeCoverageWarnings)
					ApexPages.addMessage(
						new ApexPages.Message(ApexPages.Severity.Warning, 
							(codeCoverageWarning.namespace!=null ? codeCoverageWarning.namespace+'.' : '') +
							codeCoverageWarning.name + ':' +
							codeCoverageWarning.message));
			
			AsyncResult = null;
			
			// If this was an undeploy and was successful?
			if(Deployed && !ApexPages.hasMessages(ApexPages.Severity.Error))
			{
				// Determine active rollups for this child and deactivate them
				List<RollupSummary> rollups = 
					new RollupSummariesSelector().selectActiveByChildObject(
						RollupSummaries.CalculationMode.Realtime, new Set<String> { RollupSummary.ChildObject });
				List<LookupRollupSummary__c> recordsToUpdate = new List<LookupRollupSummary__c>();
				for(RollupSummary rollup : rollups) {
					// TODO: Can only auto deactivate Custom Object based rollups
					if(rollup.Record instanceof LookupRollupSummary__c) {
						rollup.Active = false;
						recordsToUpdate.add((LookupRollupSummary__c) rollup.Record);						
					}
				}
				update recordsToUpdate;
			}
			
			// Initialise view state to try again
			init();
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, (Deployed ? 'Removing...' : 'Deploying...') + '.'.repeat(deployCount++)));
		}	
		return null;
	}
	
	private void init()
	{
		// Metadata API connection?
		MetadataConnectionError = !RollupService.checkMetadataAPIConnection();
		if(MetadataConnectionError)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Salesforce Metadata API connection failure, click the link below to configure.'));
			return;			
		}
		
		// Already deployed?
		Set<String> triggerNames = new Set<String> { RollupTriggerName };
		Set<String> testNames = new Set<String> { RollupTriggerTestName };
		if(ParentMergeable) {
			triggerNames.add(RollupParentTriggerName);
			testNames.add(RollupParentTriggerTestName);			
		}
		Map<String, ApexTrigger> apexTriggers = new ApexTriggersSelector().selectByName(triggerNames);
		Map<String, ApexClass> apexClasses = new ApexClassesSelector().selectByName(testNames);
		Deployed = apexTriggers.containsKey(RollupTriggerName) && apexClasses.containsKey(RollupTriggerTestName);
		RollupTrigger = Deployed ? apexTriggers.get(RollupTriggerName) : null;
		RollupTriggerTest = Deployed ? apexClasses.get(RollupTriggerTestName) : null;
		RollupParentTrigger = Deployed ? apexTriggers.get(RollupParentTriggerName) : null;
		RollupParentTriggerTest = Deployed ? apexClasses.get(RollupParentTriggerTestName) : null;
		ParentTriggerRequired = Deployed ? RollupParentTrigger!=null && RollupParentTriggerTest!=null : ParentTriggerRequired;
		deployCount = 0;
		
		// Deprication warning
		if(RollupSummary.Record instanceof LookupRollupSummary__c) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Use of the Lookup Rollup Summaries tab is still functional but no longer being enhanced. Consider using the Manage Lookup Rollup Summaries tab.'));
		}

		// Message to confirm current status
		if(Deployed)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Apex Trigger <b>' + RollupTriggerName + '</b> is installed.'));  		
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Apex Class <b>' + RollupTriggerTestName + '</b> is installed.'));  		
			if(RollupParentTrigger!=null) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Apex Trigger <b>' + RollupParentTriggerName + '</b> is installed.'));  		
			}
			if(RollupParentTriggerTest!=null) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Apex Trigger <b>' + RollupParentTriggerTestName + '</b> is installed.'));  		
			}
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
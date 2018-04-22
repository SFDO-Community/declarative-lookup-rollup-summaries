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

@IsTest
private class RollupControllerTest
{
	private testmethod static void testDeployedStatus()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		System.runAs(setupTestUser('Read Only')) {
			
	    	// Metadata API web Service mock implementation for tests
	        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
			
			// Test data
			LookupRollupSummary__c rollupSummaryA = new LookupRollupSummary__c();
			rollupSummaryA.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
			rollupSummaryA.ParentObject__c = 'Account';
			rollupSummaryA.ChildObject__c = 'Opportunity';
			rollupSummaryA.RelationShipField__c = 'AccountId';
			rollupSummaryA.RelationShipCriteria__c = null;
			rollupSummaryA.FieldToAggregate__c = 'Amount';
			rollupSummaryA.AggregateOperation__c = 'Sum';
			rollupSummaryA.AggregateResultField__c = 'AnnualRevenue';
			rollupSummaryA.Active__c = true;
			rollupSummaryA.CalculationMode__c = 'Realtime';			
			LookupRollupSummary__c rollupSummaryB = new LookupRollupSummary__c();
			rollupSummaryB.Name = 'Total Opportunities into Number Of Locations on Accountt';
			rollupSummaryB.ParentObject__c = 'Account';
			rollupSummaryB.ChildObject__c = 'Opportunity';
			rollupSummaryB.RelationShipField__c = 'AccountId';
			rollupSummaryB.RelationShipCriteria__c = null;
			rollupSummaryB.FieldToAggregate__c = 'CloseDate';
			rollupSummaryB.AggregateOperation__c = 'Count';
			rollupSummaryB.AggregateResultField__c = 'NumberOfLocations__c';
			rollupSummaryB.Active__c = true;
			rollupSummaryB.CalculationMode__c = 'Realtime';
			insert new List<LookupRollupSummary__c> { rollupSummaryA, rollupSummaryB };
									
			// Open test context, permits callouts following DML
			Test.startTest();
						
			// Assert initial state of controller when the trigger for the child object is deployed
			RollupController controller = new RollupController(new ApexPages.StandardController( rollupSummaryA ));
			System.assertEquals(true, controller.Deployed);
			System.assertEquals('RollupServiceTestTrigger', controller.RollupTriggerName);
			System.assertEquals('RollupSummariesTest', controller.RollupTriggerTestName);
			System.assertEquals('RollupServiceTestTrigger', controller.RollupTrigger.Name);
			System.assertEquals('RollupSummariesTest', controller.RollupTriggerTest.Name);
			System.assertEquals(controller.RollupTrigger.Body, controller.getTriggerCode());
			System.assertEquals(controller.RollupTriggerTest.Body, controller.getTriggerTestCode());
			System.assertEquals(
				    '<?xml version="1.0" encoding="UTF-8"?>' + 
					'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
		    			'<version>' + RollupController.API_VERSION + '</version>' + 
					'</Package>',	
				controller.getPackageXml());
			System.assertEquals(
				    '<?xml version="1.0" encoding="UTF-8"?>' + 
					'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
		    			'<types>' + 
		        			'<members>'+controller.RollupTriggerName+'</members>' +
		        			'<name>ApexTrigger</name>' + 
		    			'</types>' + 
		    			'<types>' + 
		        			'<members>'+controller.RollupTriggerTestName+'</members>' +
		        			'<name>ApexClass</name>' + 
		    			'</types>' + 
		    			'<version>' + RollupController.API_VERSION + '</version>' + 
					'</Package>',				
					controller.getDestructiveChangesXml());
			System.assertEquals(
			    '<?xml version="1.0" encoding="UTF-8"?>' +
				'<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">' +
				    '<apiVersion>' + RollupController.API_VERSION + '</apiVersion>' + 
				    '<status>Active</status>' +
				'</ApexTrigger>',		
				controller.getTriggerCodeMetadata());
			System.assertEquals(
			    '<?xml version="1.0" encoding="UTF-8"?>' +
				'<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">' +
				    '<apiVersion>' + RollupController.API_VERSION + '</apiVersion>' + 
				    '<status>Active</status>' +
				'</ApexClass>',		
				controller.getTriggerTestCodeMetadata());
				
			// Undeploy (no need to emulate the zip contents prepared by the client as mock service does not bother with this)
			controller.deployZip();
			
			// Check deployment (mock service impl emulates a positive response)
			// TODO: Revist this, broken since started making HTTP callouts in the init function 
			// controller.checkAsyncRequest();
			
			Test.stopTest();
			
			// Assert Active__c is false on lookups referencing this child object
			// TODO: Revist this, broken since started making HTTP callouts in the init function
			/*
			List<LookupRollupSummary__c> lookups = [select Active__c from LookupRollupSummary__c];
			System.assertEquals(false, lookups[0].Active__c);
			System.assertEquals(false, lookups[1].Active__c);
			*/			
		}
	}

	private testmethod static void testNotDeployedStatus()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
			
		System.runAs(setupTestUser('Read Only')) {
						
	    	// Metadata API web Service mock implementation for tests
	        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
	
			// Test data		
			LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
			rollupSummary.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
			rollupSummary.ParentObject__c = 'Account';
			rollupSummary.ChildObject__c = 'Contact';
			rollupSummary.RelationShipField__c = 'AccountId';
			rollupSummary.RelationShipCriteria__c = null;
			rollupSummary.FieldToAggregate__c = 'LastCURequestDate';
			rollupSummary.AggregateOperation__c = 'Count';
			rollupSummary.AggregateResultField__c = 'AnnualRevenue';
			rollupSummary.Active__c = false;
			rollupSummary.CalculationMode__c = 'Realtime';
			insert rollupSummary;
				
			// Open test context, permits callouts following DML
			Test.startTest();
			
			// Assert initial state of controller when the trigger for the child object is deployed
			RollupController controller = new RollupController(new ApexPages.StandardController( rollupSummary ));
			System.assertEquals(false, controller.Deployed);
			System.assertEquals(null, controller.RollupTrigger);
			System.assertEquals(null, controller.RollupTriggerTest);
			System.assertEquals(
					'/**\n' +
					' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
					' **/\n' +
					'trigger ' + controller.RollupTriggerName + ' on ' + rollupSummary.ChildObject__c + '\n' + 
					'    (before delete, before insert, before update, after delete, after insert, after undelete, after update)\n'+ 
					'{\n'+
					'    ' + Utilities.classPrefix() + 'RollupService.triggerHandler(Contact.SObjectType);\n'+
					'}\n', controller.getTriggerCode());
			System.assertEquals(
				 	'/**\n' +
					' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
					' **/\n' +	
					'@IsTest\n' +	 
				    'private class ' + controller.RollupTriggerTestName + '\n' +  
					'{\n' + 
					'    @IsTest\n' +
					'    private static void testTrigger()\n' +
					'    {\n' + 
					'        // Force the ' + controller.RollupTriggerName + ' to be invoked, fails the test if org config or other Apex code prevents this.\n' +
					'        ' + Utilities.classPrefix() + 'RollupService.testHandler(new ' + rollupSummary.ChildObject__c + '());\n' +
					'    }\n' +
					'}', controller.getTriggerTestCode());
			System.assertEquals(
				    '<?xml version="1.0" encoding="UTF-8"?>' + 
					'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
		    			'<types>' + 
		        			'<members>'+controller.RollupTriggerName+'</members>' +
		        			'<name>ApexTrigger</name>' + 
		    			'</types>' + 
		    			'<types>' + 
		        			'<members>'+controller.RollupTriggerTestName+'</members>' +
		        			'<name>ApexClass</name>' + 
		    			'</types>' + 
		    			'<types>' + 
		        			'<members>'+controller.RollupParentTriggerName+'</members>' +
		        			'<name>ApexTrigger</name>' + 
		    			'</types>' + 
		    			'<types>' + 
		        			'<members>'+controller.RollupParentTriggerTestName+'</members>' +
		        			'<name>ApexClass</name>' + 
		    			'</types>' + 
		    			'<version>' + RollupController.API_VERSION + '</version>' + 
					'</Package>',
				controller.getPackageXml());
			System.assertEquals(
			    '<?xml version="1.0" encoding="UTF-8"?>' +
				'<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">' +
				    '<apiVersion>' + RollupController.API_VERSION + '</apiVersion>' + 
				    '<status>Active</status>' +
				'</ApexTrigger>',
				controller.getTriggerCodeMetadata());
			System.assertEquals(
			    '<?xml version="1.0" encoding="UTF-8"?>' +
				'<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">' +
				    '<apiVersion>' + RollupController.API_VERSION + '</apiVersion>' + 
				    '<status>Active</status>' +
				'</ApexClass>',		
				controller.getTriggerTestCodeMetadata());
												
			Test.stopTest();
		}
	}

	private testmethod static void testWithCustomTestCode()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		System.runAs(setupTestUser('Read Only')) {
					
	    	// Metadata API web Service mock implementation for tests
	        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
			
			// Test data
			LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
			rollupSummary.Name = 'Total Opportunities greater than 200 into Annual Revenue on Account';
			rollupSummary.ParentObject__c = 'Account';
			rollupSummary.ChildObject__c = 'Contact';
			rollupSummary.RelationShipField__c = 'AccountId';
			rollupSummary.RelationShipCriteria__c = null;
			rollupSummary.FieldToAggregate__c = 'LastCURequestDate';
			rollupSummary.AggregateOperation__c = 'Count';
			rollupSummary.AggregateResultField__c = 'AnnualRevenue';
			rollupSummary.Active__c = false;
			rollupSummary.CalculationMode__c = 'Realtime';
			rollupSummary.TestCode__c = 'System.assertEquals(1,1);';
			rollupSummary.TestCodeSeeAllData__c = true;
			insert rollupSummary;
	
			// Open test context, permits callouts following DML
			Test.startTest();
	
			// Assert initial state of controller when the trigger for the child object is deployed
			RollupController controller = new RollupController(new ApexPages.StandardController( rollupSummary ));
			System.assertEquals(
				 	'/**\n' +
					' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
					' **/\n' +	
					'@IsTest\n' +	 
				    'private class ' + controller.RollupTriggerTestName + '\n' +  
					'{\n' + 
					'    @IsTest(SeeAllData=true)\n' +
					'    private static void testTrigger()\n' +
					'    {\n' + 
					'System.assertEquals(1,1);\n' +
					'    }\n' +
					'}', controller.getTriggerTestCode());
		}	
	}	

	private testmethod static void testWithCustomParentTestCode()
	{
		// Test supported?
		if(!TestContext.isSupported())
			return;
		
		System.runAs(setupTestUser('Read Only')) {
					
	    	// Metadata API web Service mock implementation for tests
	        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
			
			// Custom Metadata test data
			LookupRollupSummary2__mdt rollupSummary = new LookupRollupSummary2__mdt();
			Map<String, Object> fields = (Map<String, Object>) JSON.deserializeUntyped(JSON.serializePretty(rollupSummary));
			fields.put(LookupRollupSummary2__mdt.Label.getDescribe().getName(), 'Total Opportunities greater than 200 into Annual Revenue on Account');
			fields.put(LookupRollupSummary2__mdt.DeveloperName.getDescribe().getName(), 'AccountRollup');			
			fields.put(LookupRollupSummary2__mdt.ParentObject__c.getDescribe().getName(),'Account');
			fields.put(LookupRollupSummary2__mdt.ChildObject__c.getDescribe().getName(),'Contact');
			fields.put(LookupRollupSummary2__mdt.RelationShipField__c.getDescribe().getName(),'AccountId');
			fields.put(LookupRollupSummary2__mdt.RelationShipCriteria__c.getDescribe().getName(), null);
			fields.put(LookupRollupSummary2__mdt.FieldToAggregate__c.getDescribe().getName(), 'LastCURequestDate');
			fields.put(LookupRollupSummary2__mdt.AggregateOperation__c.getDescribe().getName(), 'Count');
			fields.put(LookupRollupSummary2__mdt.AggregateResultField__c.getDescribe().getName(), 'AnnualRevenue');
			fields.put(LookupRollupSummary2__mdt.Active__c.getDescribe().getName(), false);
			fields.put(LookupRollupSummary2__mdt.CalculationMode__c.getDescribe().getName(),'Realtime');
			fields.put(LookupRollupSummary2__mdt.TestCodeParent__c.getDescribe().getName(), 'System.assertEquals(1,1);');
			fields.put(LookupRollupSummary2__mdt.TestCodeSeeAllData__c.getDescribe().getName(), true);
			rollupSummary = (LookupRollupSummary2__mdt) JSON.deserialize(JSON.serialize(fields), LookupRollupSummary2__mdt.class);
	
			// Open test context, permits callouts following DML
			Test.startTest();
	
			// Assert initial state of controller when the trigger for the child object is deployed
			RollupController controller = new RollupController(new RollupSummary(rollupSummary));
			System.assertEquals(
				 	'/**\n' +
					' * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)\n' +
					' **/\n' +	
					'@IsTest\n' +	 
				    'private class ' + controller.RollupParentTriggerTestName + '\n' +  
					'{\n' + 
					'    @IsTest(SeeAllData=true)\n' +
					'    private static void testTrigger()\n' +
					'    {\n' + 
					'System.assertEquals(1,1);\n' +
					'    }\n' +
					'}', controller.getParentTriggerTestCode());
		}	
	}	
		
    /**
     * Metadata API web service mock class for tests above
     **/
	private class WebServiceMockImpl implements WebServiceMock 
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
			if(request instanceof MetadataService.deploy_element)
			{				
				MetadataService.deployResponse_element response_x = new MetadataService.deployResponse_element();
				response_x.result = new MetadataService.AsyncResult();
				response_x.result.id = 'someid';
				response_x.result.done = true;				
				response_x.result.state = 'Complete';
				response.put('response_x', response_x);
			}			
			else if(request instanceof MetadataService.checkDeployStatus_element)
			{
				System.assertEquals('someid', ((MetadataService.checkDeployStatus_element) request).asyncProcessId);
				MetadataService.checkDeployStatusResponse_element response_x = new MetadataService.checkDeployStatusResponse_element();
				response_x.result = new MetadataService.DeployResult();
				response_x.result.details = new MetadataService.DeployDetails();
				response_x.result.details.runTestResult = new MetadataService.RunTestsResult();
				response_x.result.details.runTestResult.numFailures = 0;
				response_x.result.details.componentFailures = new List<MetadataService.DeployMessage>();
				response.put('response_x', response_x);
			}
			else if(request instanceof MetadataService.checkDeployStatus_element)
			{
				System.assertEquals('someid', ((MetadataService.checkDeployStatus_element) request).asyncProcessId);
				MetadataService.checkDeployStatusResponse_element response_x = new MetadataService.checkDeployStatusResponse_element();
				response_x.result = new MetadataService.DeployResult(); 
				response_x.result.details = new MetadataService.DeployDetails();
				response_x.result.details.runTestResult = new MetadataService.RunTestsResult();
				response_x.result.details.runTestResult.numFailures = 0;
				response_x.result.details.componentFailures = new List<MetadataService.DeployMessage>();
				response.put('response_x', response_x);
			}
			else if(request instanceof MetadataService.listMetadata_element)
			{
				MetadataService.listMetadataResponse_element response_x = new MetadataService.listMetadataResponse_element();
				response_x.result = new List<MetadataService.FileProperties>();
				response.put('response_x', response_x);
			}
			return;
		}
	}    	
	
	static User setupTestUser(String profileName){
		//username global uniqueness is still enforced in tests 
		//make sure we get something unique to avoid issues with parallel tests
		String uniqueness = DateTime.now()+':'+Math.random();
		try{ 
			throw new NullPointerException();
		}catch(Exception e){
			uniqueness += e.getStackTraceString(); //includes the top level test method name without having to pass it
		}
		Profile p = [SELECT id, Name FROM Profile WHERE Name = :profileName];
		User result = new User(
			username=UserInfo.getUserId()+'.'+uniqueness.HashCode()+'@'+UserInfo.getOrganizationId()+'.sfdcOrg',
			alias = 'testExec',
			email='apextests@example.com',
			emailencodingkey='UTF-8',
			lastname='Testing',
			languagelocalekey='en_US',
			localesidkey='en_US',
			profileid = p.Id,
			timezonesidkey='America/Los_Angeles'
		);
		insert result;
		
		// Grant permissions to DLRS 
		PermissionSetAssignment psa = new PermissionSetAssignment();
		psa.AssigneeId = result.Id;
		psa.PermissionSetId = [select Id from PermissionSet where Name = 'LookupRollupSummariesFull'].Id;
		insert psa; 
		
		// Account permission set
		PermissionSet ps = new PermissionSet(Name='Account', Label='Account');
		insert ps;		
		ObjectPermissions accountPerm = 
			new ObjectPermissions(
				SobjectType = 'Account',
				ParentId = ps.Id,
				PermissionsCreate = true,
				PermissionsDelete = true,
				PermissionsEdit = true,
				PermissionsRead = true);
		insert accountPerm;		

		// Grant permissions to Account 
		PermissionSetAssignment psa2 = new PermissionSetAssignment();
		psa2.AssigneeId = result.Id;
		psa2.PermissionSetId = ps.Id;
		insert psa2; 
		
		return result;
	}
}
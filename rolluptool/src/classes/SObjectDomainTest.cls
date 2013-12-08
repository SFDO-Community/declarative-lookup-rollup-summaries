/**
 * Copyright (c), Andrew Fawcett, inc
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

@IsTest
private with sharing class SObjectDomainTest 
{
	
	@IsTest
	private static void testValidationWithoutDML()
	{
		TestSObjectDomain opps = new TestSObjectDomain(new Opportunity[] { new Opportunity ( Name = 'Test', Type = 'Existing Account' ) } );
		opps.onValidate();
		System.assertEquals(1, SObjectDomain.Errors.getAll().size());		
		System.assertEquals('You must provide an Account for Opportunities for existing Customers.', SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(Opportunity.AccountId, ((SObjectDomain.FieldError)SObjectDomain.Errors.getAll()[0]).field); 		
	}
	
	@IsTest
	private static void testInsertValidationFailedWithoutDML()
	{
		Opportunity opp = new Opportunity ( Name = 'Test', Type = 'Existing Account' );
		System.assertEquals(false, SObjectDomain.Test.Database.hasRecords());
		SObjectDomain.Test.Database.onInsert(new Opportunity[] { opp } );		
		System.assertEquals(true, SObjectDomain.Test.Database.hasRecords());
		SObjectDomain.triggerHandler(TestSObjectDomainConstructor.class);		
		System.assertEquals(1, SObjectDomain.Errors.getAll().size());		
		System.assertEquals('You must provide an Account for Opportunities for existing Customers.', SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(Opportunity.AccountId, ((SObjectDomain.FieldError)SObjectDomain.Errors.getAll()[0]).field); 		
	}

	@IsTest
	private static void testUpdateValidationFailedWithoutDML()
	{
		Opportunity oldOpp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ');
		oldOpp.Name = 'Test';
		oldOpp.Type = 'Existing Account'; 
		Opportunity newOpp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ'); 
		newOpp.Name = 'Test';
		newOpp.Type = 'New Account'; 
		System.assertEquals(false, SObjectDomain.Test.Database.hasRecords());		
		SObjectDomain.Test.Database.onUpdate(new Opportunity[] { newOpp }, new Map<Id, SObject> { newOpp.Id => oldOpp } );
		System.assertEquals(true, SObjectDomain.Test.Database.hasRecords());				
		SObjectDomain.triggerHandler(TestSObjectDomainConstructor.class);		
		System.assertEquals(1, SObjectDomain.Errors.getAll().size());		
		System.assertEquals('You cannot change the Opportunity type once it has been created.', SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(Opportunity.Type, ((SObjectDomain.FieldError)SObjectDomain.Errors.getAll()[0]).field); 		
	}
	
	@IsTest
	private static void testOnBeforeDeleteWithoutDML()
	{
		Opportunity opp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ'); 
		opp.Name = 'Test';
		opp.Type = 'Existing Account';
		System.assertEquals(false, SObjectDomain.Test.Database.hasRecords());		
		SObjectDomain.Test.Database.onDelete(new Map<ID, Opportunity> { opp.Id => opp } );		
		System.assertEquals(true, SObjectDomain.Test.Database.hasRecords());				
		SObjectDomain.triggerHandler(TestSObjectDomainConstructor.class);		
		System.assertEquals(1, SObjectDomain.Errors.getAll().size());		
		System.assertEquals('You cannot delete this Opportunity.', SObjectDomain.Errors.getAll()[0].message);
	}
	
	@IsTest
	private static void testObjectSecurity()
	{
		// Create a user which will not have access to the test object type
		User testUser = createChatterExternalUser();
		if(testUser==null)
			return; // Abort the test if unable to create a user with low enough acess
		System.runAs(testUser)
		{					
			// Test Create object security
			Opportunity opp = new Opportunity ( Name = 'Test', Type = 'Existing Account' );
			SObjectDomain.Test.Database.onInsert(new Opportunity[] { opp } );
			try {
				SObjectDomain.triggerHandler(TestSObjectDomainConstructor.class);
				System.assert(false, 'Expected access denied exception');						
			} catch (Exception e) {
				System.assertEquals('Permission to create an Opportunity denied.', e.getMessage());
			}		
			
			// Test Update object security
			Opportunity existingOpp = (Opportunity) Opportunity.sObjectType.newSObject('006E0000006mkRQ');
			existingOpp.Name = 'Test';
			existingOpp.Type = 'Existing Account'; 			
			SObjectDomain.Test.Database.onUpdate(new List<Opportunity> { opp }, new Map<Id, Opportunity> { opp.Id => opp } );
			try {
				SObjectDomain.triggerHandler(TestSObjectDomainConstructor.class);
				System.assert(false, 'Expected access denied exception');						
			} catch (Exception e) {
				System.assertEquals('Permission to udpate an Opportunity denied.', e.getMessage());
			}		
			
			// Test Delete object security
			SObjectDomain.Test.Database.onDelete(new Map<Id, Opportunity> { opp.Id => opp });
			try {
				SObjectDomain.triggerHandler(TestSObjectDomainConstructor.class);
				System.assert(false, 'Expected access denied exception');						
			} catch (Exception e) {
				System.assertEquals('Permission to delete an Opportunity denied.', e.getMessage());
			}		
		}			
	}
	
	@IsTest
	public static void testErrorLogging()
	{	
		// Test static helpers for raise none domain object instance errors
		Opportunity opp = new Opportunity ( Name = 'Test', Type = 'Existing Account' );		
		SObjectDomain.Errors.error('Error', opp);
		SObjectDomain.Errors.error('Error', opp, Opportunity.Type);
		System.assertEquals(2, SObjectDomain.Errors.getAll().size());		
		System.assertEquals('Error', SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals('Error', SObjectDomain.Errors.getAll()[1].message);
		System.assertEquals(Opportunity.Type, ((SObjectDomain.FieldError)SObjectDomain.Errors.getAll()[1]).field);
		SObjectDomain.Errors.clearAll();		
		System.assertEquals(0, SObjectDomain.Errors.getAll().size());		
	}
	
	private static User createChatterExternalUser()
	{
		// Can only proceed with test if we have a suitable profile - Chatter External license has no access to Opportunity
		List<Profile> testProfiles = [Select Id From Profile where UserLicense.Name='Chatter External' limit 1];
		if(testProfiles.size()!=1)
			return null; 		

		// Can only proceed with test if we can successfully insert a test user 
		String testUsername = System.now().format('yyyyMMddhhmmss') + '@testorg.com';
		User testUser = new User(Alias = 'test1', Email='testuser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = testProfiles[0].Id, TimeZoneSidKey='America/Los_Angeles', UserName=testUsername);
		try {
			insert testUser;
		} catch (Exception e) {
			return null;
		}		
		return testUser;
	}

	/**
	 * Test domain class
	 **/
	public with sharing class TestSObjectDomain extends SObjectDomain
	{
		public TestSObjectDomain(List<Opportunity> sObjectList)
		{
			// Domain classes are initialised with lists to enforce bulkification throughout
			super(sObjectList);
		}
		
		public override void onApplyDefaults()
		{
			// Not required in production code
			super.onApplyDefaults();
			
			// Apply defaults to TestSObjectDomain
			for(Opportunity opportunity : (List<Opportunity>) Records)
			{
				opportunity.CloseDate = System.today().addDays(30);						
			}
		}
	
		public override void onValidate()	
		{
			// Not required in production code
			super.onValidate();
			
			// Validate TestSObjectDomain
			for(Opportunity opp : (List<Opportunity>) Records)
			{
				if(opp.Type!=null && opp.Type.startsWith('Existing') && opp.AccountId == null)
				{
					opp.AccountId.addError( error('You must provide an Account for Opportunities for existing Customers.', opp, Opportunity.AccountId) );					
				}			
			}		
		}
		
		public override void onValidate(Map<Id,SObject> existingRecords)
		{
			// Not required in production code	
			super.onValidate(existingRecords);
			
			// Validate changes to TestSObjectDomain
			for(Opportunity opp : (List<Opportunity>) Records)
			{
				Opportunity existingOpp = (Opportunity) existingRecords.get(opp.Id);
				if(opp.Type != existingOpp.Type)
				{
					opp.Type.addError( error('You cannot change the Opportunity type once it has been created.', opp, Opportunity.Type) );
				}
			}
		}
		
		public override void onBeforeDelete()
		{
			// Not required in production code
			super.onBeforeDelete();
			
			// Validate changes to TestSObjectDomain
			for(Opportunity opp : (List<Opportunity>) Records)
			{
				opp.addError( error('You cannot delete this Opportunity.', opp) );
			}			
		}
	}	
	
	/**
	 * Typically an inner class to the domain class, supported here for test purposes
	 **/
	public class TestSObjectDomainConstructor implements SObjectDomain.IConstructable
	{
		public SObjectDomain construct(List<SObject> sObjectList)
		{
			return new TestSObjectDomain(sObjectList);
		}
	}	
}
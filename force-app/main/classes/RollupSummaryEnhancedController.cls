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
 * Contributed by Wes Weingartner, https://github.com/wes1278
 *
 * https://github.com/afawcett/declarative-lookup-rollup-summaries/pull/15
 **/
public with sharing class RollupSummaryEnhancedController {
	private ApexPages.StandardController controller {get; set;}
	private LookupRollupSummary__c rus;
	private Set<String> numeric;
	public List<SelectOption> parentObjects {get;set;}
	public List<SelectOption> parentFields {
		get{
			List<SelectOption> retList = new List<SelectOption>();
			retList.add(new SelectOption('','Select'+ (String.isBlank(rus.ParentObject__c)?'':' ' +rus.ParentObject__c) + ' field...'));
			if(String.isNotBlank(rus.ParentObject__c))
			{

				Map<String, Schema.SObjectField> parentFieldMap = gd.get(rus.ParentObject__c).getDescribe().fields.getMap();
				for(Schema.SObjectField field : parentFieldMap.values())
				{
					Schema.DescribeFieldResult res = field.getDescribe();
					if(res.isAccessible() && res.isUpdateable() && numeric.contains(String.valueOf(res.getType()).trim().toLowercase()))
					{
						String objLabel = res.getLabel();
						String objAPI = res.getName();
						retList.add(new SelectOption(objApi,objLabel));
					}
				}	
			}
			retList.sort();
			return retList;
		}
		set;
	}
	public List<SelectOption> childObjects {
		get{
			List<SelectOption> retList = new List<SelectOption>();
			retList.add(new SelectOption('','Select a child object.'));
			if(String.isNotBlank(rus.ParentObject__c))
			{
				for(Schema.ChildRelationship rel : gd.get(rus.ParentObject__c).getDescribe().getChildRelationships())
				{
					Schema.DescribeSObjectResult res = rel.getChildSObject().getDescribe();
					if(res.isAccessible() && res.isUpdateable())
					{
						String objLabel = res.getLabel() + ' (' + rel.getField() +')';
						String objAPI = res.getName()+'.'+rel.getField();
						retList.add(new SelectOption(objApi,objLabel));
					}
				}	
			}
			retList.sort();
			return retList;
		}
		set;
	}
	public List<SelectOption> childFields {
		get{
			List<SelectOption> retList = new List<SelectOption>();
			retList.add(new SelectOption('','Select child field...'));
			if(String.isNotBlank(rus.ChildObject__c))
			{
				String strChildObject = rus.ChildObject__c.substringBefore('.');

				Map<String, Schema.SObjectField> parentFieldMap = gd.get(strChildObject).getDescribe().fields.getMap();
				for(Schema.SObjectField field : parentFieldMap.values())
				{
					Schema.DescribeFieldResult res = field.getDescribe();
					if(res.isAccessible() && res.isUpdateable() && numeric.contains(String.valueOf(res.getType()).trim().toLowercase()))
					{
						String objLabel = res.getLabel();
						String objAPI = res.getName();
						retList.add(new SelectOption(objApi,objLabel));
					}
				}	
			}
			retList.sort();
			return retList;
		}
		set;
	}
	private Map<String, Schema.SObjectType> gd;
	public RollupSummaryEnhancedController(ApexPages.StandardController stdController) {
		this.controller = stdController;
		this.controller.addFields(
			new String[] { 
				LookupRollupSummary__c.ChildObject__c.getDescribe().getName(),
				LookupRollupSummary__c.RelationshipField__c.getDescribe().getName() });
		this.rus = (LookupRollupSummary__c)controller.getRecord();
		gd = Schema.getGlobalDescribe();
		numeric = new Set<String>();
		numeric.add('currency');
		numeric.add('date');
		numeric.add('double');
		numeric.add('integer');
		numeric.add('percent');

		// Get the list of creatable,updateable objects.
		parentObjects = new List<SelectOption>();
		parentObjects.add(new SelectOption('','Select Parent Object'));
		for(String obj : gd.keySet())
		{
			Schema.DescribeSObjectResult res = gd.get(obj).getDescribe();
			if(res.isCreateable() && res.isUpdateable())
			{
				String objLabel = res.getLabel();
				String objAPI = res.getName();
				parentObjects.add(new SelectOption(objApi,objLabel));
			}
		}
		parentObjects.sort();

		// Deprication warning
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Use of the Lookup Rollup Summaries tab is still functional but no longer being enhanced. Consider using the Manage Lookup Rollup Summaries tab.'));
	}	
	public String getRelationshipField() {
		return rus.ChildObject__c+'.'+rus.RelationshipField__c;
	}	
	public void setRelationshipField(String value) {
		rus.ChildObject__c = value;	
	}	
	public void calculateRelationshipField() {
		rus.RelationshipField__c = (rus!=null && String.isNotBlank(rus.ChildObject__c)?rus.ChildObject__c.substringAfter('.'):'');
	}
	public PageReference save()
	{
		// trigger exists?
		Boolean foundTrigger = false;
		if(rus.ChildObject__c!=null)
		{
			rus.ChildObject__c = rus.ChildObject__c.substringBefore('.');
			Set<String> childTrigger = new Set<String>();
			childTrigger.add(rus.ChildObject__c);
			Map<String, ApexTrigger> apexTriggers = new ApexTriggersSelector().selectByName(childTrigger);
			String triggerName = RollupSummaries.makeTriggerName(new RollupSummary(rus));
			foundTrigger = apexTriggers.containsKey(triggerName);
		}
		 
		Database.SaveResult sr;
		if((rus.CalculationMode__c == RollupSummaries.CalculationMode.Realtime.name() ||
			rus.CalculationMode__c == RollupSummaries.CalculationMode.Scheduled.name()) && 
			!foundTrigger)
		{
			//we need the trigger to be created so let's create it,
			// and then let's set rus.Active__c = true; 
			//and then insert the rus record.
			Boolean triggerWasDeployedSuccessfully = true; // TODO if the trigger deployment was successful
			if(triggerWasDeployedSuccessfully)
			{
				//rus.Active__c = true; //Uncomment once the trigger deploying works.
				if(rus.Id!=null) {
				    fflib_SecurityUtils.checkObjectIsUpdateable(LookupRollupSummary__c.SObjectType);
                    sr = Database.update(rus, false);				    
				}
				else {
                    fflib_SecurityUtils.checkObjectIsInsertable(LookupRollupSummary__c.SObjectType);
                    sr = Database.insert(rus, false);				    
				}
			}
		}
		else
		{
			//rus.Active__c = true; //Uncomment once the trigger deploying works.
			if(rus.Id!=null) {
                fflib_SecurityUtils.checkObjectIsUpdateable(LookupRollupSummary__c.SObjectType);
                sr = Database.update(rus, false);			    
			}
			else {
                fflib_SecurityUtils.checkObjectIsInsertable(LookupRollupSummary__c.SObjectType);			    
                sr = Database.insert(rus, false);			    
			}
		}
		PageReference pageRef;
		if(sr.isSuccess())
		{
			pageRef = new PageReference('/' + rus.Id);
			pageRef.setRedirect(true);
		}
		else
		{
			for(Database.Error err : sr.getErrors())
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,err.getMessage()));
			}
		}
		return pageRef;
	}
	public void getChildFields(String parentObjectName)
	{
		Map<SObjectType, Map<String, Schema.SObjectField>> gdFields = new Map<SObjectType, Map<String, Schema.SObjectField>>();
		SObjectType parentObjectType = gd.get(rus.ParentObject__c);
		SObjectType childObjectType = gd.get(rus.ChildObject__c);

		if(parentObjectType!=null && !gdFields.containsKey(parentObjectType))
		gdFields.put(parentObjectType, parentObjectType.getDescribe().fields.getMap());
		if(childObjectType!=null && !gdFields.containsKey(childObjectType))
		gdFields.put(childObjectType, childObjectType.getDescribe().fields.getMap());
	}
}
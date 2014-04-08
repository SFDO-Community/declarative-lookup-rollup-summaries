public class RollupSummary_NewPage_Controller {
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
	public RollupSummary_NewPage_Controller(ApexPages.StandardController stdController) {
		this.controller = stdController;
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
	}
	public void setRelationshipField()
	{
		rus.RelationshipField__c = (rus!=null && String.isNotBlank(rus.ChildObject__c)?rus.ChildObject__c.substringAfter('.'):'');
	}

	public PageReference save()
	{
		rus.ChildObject__c = rus.ChildObject__c.substringBefore('.');
		Set<String> childTrigger = new Set<String>();
		childTrigger.add(rus.ChildObject__c);
		Map<String, ApexTrigger> apexTriggers = new ApexTriggersSelector().selectByName(childTrigger);
		String triggerName = RollupSummaries.makeTriggerName(rus); 
		Database.SaveResult sr;
		if((rus.CalculationMode__c == RollupSummaries.CalculationMode.Realtime.name() ||
			rus.CalculationMode__c == RollupSummaries.CalculationMode.Scheduled.name()) && 
			!apexTriggers.containsKey(triggerName))
		{
			//we need the trigger to be created so let's create it,
			// and then let's set rus.Active__c = true; 
			//and then insert the rus record.
			Boolean triggerWasDeployedSuccessfully = true; // TODO if the trigger deployment was successful
			if(triggerWasDeployedSuccessfully)
			{
				//rus.Active__c = true; //Uncomment once the trigger deploying works.
				sr = Database.insert(rus);
			}
		}
		else
		{
			//rus.Active__c = true; //Uncomment once the trigger deploying works.
			sr = Database.insert(rus);
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
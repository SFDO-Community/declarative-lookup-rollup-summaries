/**
* NOTE: DO NOT PACKAGE THIS TRIGGER
**/

/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger RollupServiceTest2Trigger on LookupChild__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	// Avoids the unit test triggers conflicting with manual testing in the org
	if(Test.isRunningTest()) {
	    // Emulate another trigger on the child going in and deleting the parent record! 
	    // https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/39
	    if(TestContext.DeleteParentRecord && Trigger.isBefore && Trigger.isDelete) {
            List<LookupParent__c> parentRecordsToDelete = new List<LookupParent__c>();
            for(LookupChild__c child : Trigger.old) {
                parentRecordsToDelete.add(new LookupParent__c(Id = child.LookupParent__c));
            }
            delete parentRecordsToDelete;
	    }
	    // Call regular handler
    	RollupService.triggerHandler();		
	}
}
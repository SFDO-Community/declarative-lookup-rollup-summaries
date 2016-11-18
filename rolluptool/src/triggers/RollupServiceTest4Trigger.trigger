/**
* NOTE: DO NOT PACKAGE THIS TRIGGER
**/

/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger RollupServiceTest4Trigger on Task
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	// Avoids the unit test triggers conflicting with manual testing in the org
	if(Test.isRunningTest()) {		
    	RollupService.triggerHandler();
    }
}
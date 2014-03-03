/**
* NOTE: DO NOT PACKAGE THIS TRIGGER
**/

/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger RollupServiceTest2Trigger on LookupChild__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    RollupService.triggerHandler();
}
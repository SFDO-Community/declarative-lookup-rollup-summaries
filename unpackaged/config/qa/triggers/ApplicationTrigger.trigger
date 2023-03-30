/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger ApplicationTrigger on Application__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    RollupService.triggerHandler(Application__c.SObjectType);
}
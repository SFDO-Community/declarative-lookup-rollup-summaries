/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger QALookupParentTrigger on QALookupParent__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    RollupService.triggerHandler(QALookupParent__c.SObjectType);
}
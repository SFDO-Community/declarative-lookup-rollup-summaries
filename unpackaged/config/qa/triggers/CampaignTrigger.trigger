/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger CampaignTrigger on Campaign
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    RollupService.triggerHandler(Campaign.SObjectType);
}
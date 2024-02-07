/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class CampaignMemberTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the CampaignMemberTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        RollupService.testHandler(new CampaignMember());
    }
}
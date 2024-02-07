/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class OpportunityTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the OpportunityTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        RollupService.testHandler(new Opportunity());
    }
}
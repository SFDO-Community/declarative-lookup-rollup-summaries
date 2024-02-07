/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class OpportunityContactRoleTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the OpportunityContactRoleTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        RollupService.testHandler(new OpportunityContactRole());
    }
}
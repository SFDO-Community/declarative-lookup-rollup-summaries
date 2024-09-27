/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class ContactTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the ContactTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        RollupService.testHandler(new Contact());
    }
}
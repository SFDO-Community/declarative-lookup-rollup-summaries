/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class ApplicationTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the ApplicationTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        RollupService.testHandler(new Application__c());
    }
}
/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class QALookupChildTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the QALookupChildTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        RollupService.testHandler(new QALookupChild__c());
    }
}
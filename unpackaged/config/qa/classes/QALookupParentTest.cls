/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class QALookupParentTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the QALookupParentTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        RollupService.testHandler(new QALookupParent__c());
    }
}
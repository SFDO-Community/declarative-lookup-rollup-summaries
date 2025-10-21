/**
 * NOTE: DO NOT PACKAGE THIS TRIGGER
 **/

/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger UnpackagedRollupServiceTestTrigger on Opportunity(
  before delete,
  before insert,
  before update,
  after delete,
  after insert,
  after undelete,
  after update
) {
  // Avoids the unit test triggers conflicting with manual testing in the org
  if (Test.isRunningTest()) {
    if (TestContext.OpportunityTestTriggerEnabled) {
      RollupService.triggerHandler();
    }
  }
}

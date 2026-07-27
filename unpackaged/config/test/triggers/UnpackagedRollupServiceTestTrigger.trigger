/**
 * NOTE: DO NOT PACKAGE THIS TRIGGER
 *
 * Write referencing the namespaced components. Namespaces will be removed by the CLI when deployed to dev environments
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
    if (DlrsTestContext.OpportunityTestTriggerEnabled) {
      dlrs.RollupService.triggerHandler();
    }
  }
}

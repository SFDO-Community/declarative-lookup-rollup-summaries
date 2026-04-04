/**
 * NOTE: DO NOT PACKAGE THIS TRIGGER
 *
 * Write referencing the namespaced components. Namespaces will be removed by the CLI when deployed to dev environments
 **/

/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger UnpackagedRollupServiceTest2Trigger on dlrs__LookupChild__c(
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
    // Emulate another trigger on the child going in and deleting the parent record!
    // https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/39
    if (
      DlrsTestContext.DeleteParentRecord &&
      Trigger.isBefore &&
      Trigger.isDelete
    ) {
      List<dlrs__LookupParent__c> parentRecordsToDelete = new List<dlrs__LookupParent__c>();
      for (dlrs__LookupChild__c child : Trigger.old) {
        parentRecordsToDelete.add(
          new dlrs__LookupParent__c(Id = child.dlrs__LookupParent__c)
        );
      }
      delete parentRecordsToDelete;
    }
    // Call regular handler
    dlrs.RollupService.triggerHandler();
  }
}

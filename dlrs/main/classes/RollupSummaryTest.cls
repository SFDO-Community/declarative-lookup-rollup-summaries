@IsTest
public class RollupSummaryTest {
  @IsTest
  static void testBypassCustPermApiName() {
    LookupRollupSummary2__mdt rollup = new LookupRollupSummary2__mdt();
    rollup.BypassPermissionApiName__c = null;
    RollupSummary rs = new RollupSummary(rollup);
    Assert.areEqual(null, rs.BypassCustPermApiName);
    rollup.BypassPermissionApiName__c = 'Rollup1';
    rs = new RollupSummary(rollup);
    Assert.areEqual('Rollup1', rs.BypassCustPermApiName);

    rs.BypassCustPermApiName = 'Rollup2';
    Assert.areEqual('Rollup2', rs.BypassCustPermApiName);

    LookupRollupSummary__c rollupCO = new LookupRollupSummary__c();
    rs = new RollupSummary(rollupCO);
    Assert.areEqual(null, rs.BypassCustPermApiName);
    rs.BypassCustPermApiName = 'Rollup1';
    // we're not building support in the Custom Object rollup versions, setting the value is ignored
    Assert.areEqual(null, rs.BypassCustPermApiName);
  }
}

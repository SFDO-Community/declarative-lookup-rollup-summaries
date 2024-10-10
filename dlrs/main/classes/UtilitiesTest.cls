@IsTest
public class UtilitiesTest {
  @IsTest
  static void testUserHasCustomPermission() {
    Assert.areEqual(false, Utilities.userHasCustomPermission(null));
    Assert.areEqual(false, Utilities.userHasCustomPermission('madeup_name'));
    Assert.areEqual(
      false,
      Utilities.userHasCustomPermission('madeup_name,name2 , name3,name4')
    );
    // TODO: add custom perm and perm set assigned to working user for tests but not add to package
    // Assert.areEqual(
    //   true,
    //   Utilities.userHasCustomPermission('DLRSLimitedDisable')
    // );
    // Assert.areEqual(
    //   true,
    //   Utilities.userHasCustomPermission('rollup1, DLRSLimitedDisable ,rollup2')
    // );
  }
}

@IsTest
public class UtilitiesTest {
  @IsTest
  static void testUserHasCustomPermission() {
    // find the permission set that has access to the Custom Permission we want to use to check (if it even exists in the system)
    List<SetupEntityAccess> permSetsWithAccess = [
      SELECT ParentId
      FROM SetupEntityAccess
      WHERE
        SetupEntityId IN (
          SELECT Id
          FROM CustomPermission
          WHERE DeveloperName = 'DisableDLRS'
        )
        AND Parent.IsOwnedByProfile = FALSE
    ];
    if (!permSetsWithAccess.isEmpty()) {
      // there is a compatible permission set that we can use for testing
      // see if the running user already has that permission set
      List<PermissionSetAssignment> assignments = [
        SELECT Id
        FROM PermissionSetAssignment
        WHERE
          AssigneeId = :UserInfo.getUserId()
          AND PermissionSetId = :permSetsWithAccess[0].ParentId
      ];
      if (assignments.isEmpty()) {
        // user doesn't have the necessary perm set to grant it to them, add it
        System.runAs(new User(Id = UserInfo.getUserId())) {
          insert new PermissionSetAssignment(
            AssigneeId = UserInfo.getUserId(),
            PermissionSetId = permSetsWithAccess[0].ParentId
          );
        }
      }
      // make sure the utility can see the perm set correctly
      // (we do it here because any earlier and the utility would have built the cache already)
      Assert.areEqual(false, Utilities.userHasCustomPermission('DisableDLRS'));
    }

    Assert.areEqual(false, Utilities.userHasCustomPermission(null));
    Assert.areEqual(false, Utilities.userHasCustomPermission('madeup_name'));
    Assert.areEqual(
      false,
      Utilities.userHasCustomPermission('madeup_name,name2 , name3,name4')
    );
  }
}

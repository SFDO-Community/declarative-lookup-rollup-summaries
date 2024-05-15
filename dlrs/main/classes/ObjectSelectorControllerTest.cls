@IsTest
public with sharing class ObjectSelectorControllerTest {
  @IsTest
  static void testGetParentObjList() {
    List<ObjectSelectorController.SObjectInfo> objects = ObjectSelectorController.getParentObjList();
    Assert.isFalse(objects.isEmpty());

    Set<String> expected = new Set<String>{
      'Account',
      'Opportunity',
      Schema.LookupRollupSummary2__mdt.getSObjectType().getDescribe().getName()
    };
    for (ObjectSelectorController.SObjectInfo sobj : objects) {
      expected.remove(sobj.fullName);
    }

    // expected items should have been removed
    Assert.isTrue(expected.isEmpty());
  }
}

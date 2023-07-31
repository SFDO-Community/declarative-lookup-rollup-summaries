/**
 * Helper class for QA-related functionality.
 */
public with sharing class QAHelper {
  private static final String QA_APP_NAME = 'DLRS_QA_App';

  /**
   * Queries AppMenuItems and reorders them so that the QA app is first.
   */
  public static void updateAppMenuOrdering() {
    AppMenuItem[] menuItems = [SELECT ApplicationId, Name FROM AppMenuItem];
    Map<String, AppMenuItem> menuItemMap = new Map<String, AppMenuItem>();
    for (AppMenuItem item : menuItems) {
      menuItemMap.put(item.Name, item);
    }
    Id[] orderedItems = new List<Id>{};
    orderedItems.add(menuItemMap.remove(QA_APP_NAME).ApplicationId);
    for (String key : menuItemMap.keyset()) {
      orderedItems.add(menuItemMap.get(key).ApplicationId);
    }
    AppLauncher.AppMenu.setOrgSortOrder(orderedItems);
  }
}

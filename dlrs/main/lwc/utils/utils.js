// import so we can get a namespace from it
// can't import the Platform Event or CMDT directly
// because they get corrupted
import SCHEDULE_ITEMS_OBJECT from "@salesforce/schema/LookupRollupSummaryScheduleItems__c";

// use an imported API name and swap parts to apply namespace to other API names that we can't import correctly
export function buildApiName(value, useDefaultNamespace = false) {
  let apiName = SCHEDULE_ITEMS_OBJECT.objectApiName;
  if (useDefaultNamespace) {
    if (apiName === "LookupRollupSummaryScheduleItems__c") {
      apiName = "c__LookupRollupSummaryScheduleItems__c";
    }
  }
  return apiName.replace("LookupRollupSummaryScheduleItems__c", value);
}

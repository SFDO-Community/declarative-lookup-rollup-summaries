---
layout: default
title: Change Log
nav_order: 7
has_children: false
---

# Packaged Release History

You can install a packaged version of the tool into your production org (sandbox testing as always recommended).

<br/>
**Latest Release Version 2.17**

---

Install DLRS 2.17 into your production, sandbox, or scratch org via [Salesforce.org MetaDeploy](https://install.salesforce.org/products/dlrs/latest).

- Feature - [New creation wizard: Custom UI for creation of Lookup Rollup Summaries](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/pull/1113).
- Feature - [List view for Rollup records within lightning app: Shows all rollups including information to quickly see if a rollup is scheduled and the schedule date](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/issues/1131).
- Feature - [Integrate NPSP and TDTM with Declarative Lookup Rollup Summaries](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/issues/1112).
- Performance - [Reduced number of SOQL queries made by using custom metadata methods for Rollup Summaries Selector](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/issues/1049).
- Enhancement - [Added `Clone` Button on main Rollup creation page to quickly copy lookup rollup summaries](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/issues/1121).
- Enhancement - [Added `Schedule` Full Calculate field to rollup creation page – Adds ability to track next scheduled full calculate on rollup](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/issues/1126).
- Enhancement - [Added error and informational messages to guide user through rollup activation](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/issues/1123).
- Enhancement - [Added ability to sort fields by label instead of API name in New Wizard](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/issues/1130).
- Bug - [Fixed issue preventing scheduled rollups from working if different child objects and the same parent object](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/issues/802).
- Bug - [Fixed broken image link on app homepage](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/issues/1170).
- Bug - [Fixed missing namespace in trigger test code](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/pull/1177).
- Bug - [Add global access modifier for NPSP](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/pull/1180).
- Bug - [New Wizard throwing error if picklist exceeds 1000 objects](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/pull/1223)

<br/><br/>
**Version 2.16**

---

Install DLRS 2.16 into your production, sandbox, or scratch org via [Salesforce.org MetaDeploy](https://install.salesforce.org/products/dlrs/latest).

- Internal release

<br/><br/>
**Release Version 2.15**

---

Install DLRS 2.15 into your production, sandbox, or scratch org via [Salesforce.org MetaDeploy](https://install.salesforce.org/products/dlrs/latest).

<br/><br/>
**Version 2.14**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5p000000eegF&isdtp=p1), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t5p000000eegF&isdtp=p1)

- Enhancement - Moved to API 51.0

<br/><br/>
**Release Version 2.13**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0N000000YGN9&isdtp=p1), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t0N000000YGN9&isdtp=p1)

- Enhancement - Moved to API 50.0
- Enhancement - Fixed Remote Site would incorrectly show as created and enhanced the whole Welcome tab
- Enhancement - Added new [Wiki page](https://github.com/afawcett/declarative-lookup-rollup-summaries/wiki/Metadata-API-Connection-Issues-FAQ), linked from Welcome tab relating to various requirements and gotcha's on Metadata API connection issues
- Bug - Optimizer tab would not show correctly if the user was not an Admin - now works for any user so long as they are assigned the Lookup Rollup Summary Configure permission set.

<br/><br/>
**Release Version 2.12**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0N000000YGN4&isdtp=p1), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t0N000000YGN4&isdtp=p1)

- Enhancement - [Avoid need for Remote Site setup](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/925)
- Enhancement - [Cannot disable DLRS in Apex](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/889)
- Enhancement - [Update API version of DLRS](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/831)
- Enhancement - [New "Lookup Rollup Summaries Tools" tab](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/678)
- Enhancement - [Improved UI messaging to direct users to the Manage Lookup Rollup Summaries tab](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/677)
- Enhancement - [Minor tweaks to the messaging on the full recalc UI's](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/675)
- Enhancement - [Route various apex job errors to scheduling/running users email](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/671)
- Enhancement - [Modify test code for parent object](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/637)
- Enhancement - [Avoid Shadow Custom Object Based Rollup Records - Total DLRS Newbie frustration](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/618)
- Bug - [Master branch has Apex Unit test failures](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/894)
- Bug - [Clicking Cancel on Full Calculate schedule page goes back to wrong page](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/676)

Also see [Declarative Rollup Summary Tool Update for v2.12](https://andyinthecloud.com/2020/04/05/declarative-rollup-summary-tool-update/).

<br/><br/>
**Release Version 2.11.1**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0N000001E2L5), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t0N000001E2L5)

- Bug [Summer 19-Invalid field MasterRecordId for Case SobjectException due version 42](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/818)

**IMPORTANT NOTE:**
The Cases DLRS Trigger will fail in Summer '19 if you do not upgrade to 2.11.1 until the related known issue is fixed by Salesforce. This only impacts users with the Case object DLRS Child Trigger created and active.

<br/><br/>
**Release Version 2.11**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0N000000IyYr), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t0N000000IyYr)

- Enhancement [OR clause in top level filter breaks SOQL query](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/631)
- Enhancement [Upgrade to Latest API: New object are not available](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/627)
- Bug [SObject type does not allow locking rows](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/619)
- Enhancement [Remote Settings update](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/372)
- Enhancement [Lightning Enterprise Edition](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/569)

<br/><br/>
**Release Version 2.10**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000UvwL), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000UvwL)

- Enhancement [Enhancement: Schedule calculate - don't DML update record if rollup value unchanged](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/547)
- Enhancement [Known ordering for RollupCalculateJob records](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/518)
- Enhancement [Can't aggregate Salesforce Files (ContentDocumentLink) as child object](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/433)
- Enhancement [Reinstate support for Test Code field on Rollups using Custom Metadata](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/304)
- Bug [Error When Adding a Note in SF Lightning Due to DLRS Trigger](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/558)
- Bug [Calculate new roll up failing on "The rollup must be Active before you can run a Calculate job"](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/511)

**UPGRADE NOTE:** If you access the Rollup definitions via the standard Salesforce Custom Metadata UI under the Setup menu. Make sure to remove 'Test Code (Deprecated)' (small one) from the layout and add the new 'Test Code' field (large one). If you only ever use the Manage Rollup Summaries tab you do not need to worry about this. Also note that any test code placed in the original smaller field will be automatically migrated to the new field on next edit (via Manage Rollup Summaries tab).

<br/><br/>
**Release Version 2.9**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXnE), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXnE)

- Enhancement [Support API 37.0 onwards objects. Update RollupController.cls to remove hard-coded API version references](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/505)
- Enhancement [Update to new fflib and optimised selector code](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/476)
- Enhancement [Enhancement - Button on the Summary Logs List View for deleting Logs](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/474)
- Enhancement [Support for Currency Roll Ups with Community Portal Users](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/454)
- Enhancement [Improve error message Lookup Rollup Summary 'X' is invalid, your org configuration may have changed](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/377)
- Bug [Support WorkOrder. Deploy Trigger. Entity is not API accessible.](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/481)
- Bug [Support AccountContactRelation. Deploy Trigger. Entity is not api accessible](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/438)
- Bug [RollupServiceTestTrigger, RollupServiceTest4Trigger and RollupServiceTest5Trigger has not been deployed](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/365)
- Bug [Support CaseComment Rollups, Cannot locate Apex Type for ID CaseComment](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/17)

**IMPORTANT NOTES:**

- Please check your Rollup Calculate Job records and if needed (no jobs are actually running) delete them.
- There is a new Delete Log button on the Summary Logs List View layout please add it

<br/><br/>
**Release Version 2.8**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXkF), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXkF)

- Bug [Lookup Rollup Calculate Job records are not being deleted even after the Calculate Job finishes](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/460)
- Bug [Help Text for Calculation Mode needs updating](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/350)
- Bug [Account Trigger->Decimal to Integer Illegal Assignment](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/326)
- Enhancement [Feature Request - the ability to set schedule dlrs job name](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/415)
- Enhancement [Better messaging when scheduling jobs](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/353)

**IMPORTANT NOTE:** Please check your Rollup Calculate Job records and if needed delete them.

<br/><br/>
**Release Version 2.7**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXk5), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXk5)

- Bug [Validation Errors 'ENTITY_IS_DELETED' While Saving when Parent gets Deleted As Well](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/39)

<br/><br/>
**Release Version 2.6**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXZG), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXZG)

- Bug [DLRS fails rollup on Checkbox when no records found](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/379) Thanks Wes Weingartner!
- Bug [Developer Script Exception : Entity is not api accessible](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/360)
- Bug [Lookup Rollup Calculate Jobs not Case-sensitive](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/347)

<br/><br/>
**Release Version 2.5**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXVO), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXVO)

- Bug [After Delete trigger for merging fails when new dlrs added](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/371)
- Bug [Should not need to mark Active to do a manual Calculation](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/359)
- Bug [Apex Scheduler Day of Week Drop down is a day out](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/349)
- Bug [Merging lead causes Permission to create dlrs**LookupRollupSummary**c error](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/345)
- Enhancement [Support ContentNote rollups (upgraded to API 37.0)](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/351)

<br/><br/>
**Release Version 2.4.2**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000ka9e), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000ka9e)

- Bug [Install failed 2.4 update - New dependency on LookupChild's Sharing mode in Apex Unit Test](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/344)

<br/><br/>
**Release Version 2.4.1**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000ka90), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000ka90)

**Documentation:** See [Declarative Rollup Tool Summer (2016) Release](https://andyinthecloud.com/2016/06/19/declarative-rollup-tool-summer-release/)

- Bug [Installation Issue - The user license doesn't allow the permission: Read All dlrs**LookupRollupCalculateJob**c](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/331)
- Enhancement [Roll Up just for few number of records](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/315)
- Enhancement [Support for rollups on Account when doing Merge Account](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/303)
- Enhancement [Add support for ALL ROWS](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/267)
- Enhancement [Scheduled Calculate Custom Settings](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/265)
- Enhancement [Open Activities still associated to the Converted Lead](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/164)
- Enhancement [Remove from Lookup Rollup Summary Schedule Items when Parent is deleted](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/147)

<br/><br/>
**Version 2.3**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBqJ), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBqJ)

- Bug [Attempt to de-reference a null object from RollupJob (as seen on Apex Jobs page)](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/318)
- Bug [SP(), BR(), TB() not working in 2.2](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/291)
- Bug [Calculation Id not populating in Version 2.1](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/280)
- Bug [Validation Errors 'ENTITY_IS_DELETED' While Saving when Parent gets Deleted As Well](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/39)

<br/><br/>
**Version 2.2**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBh0), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBh0)

- Bug [multiple criteria fields don't work anymore.](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/281)
- Enhancement [Add support for space & tab in concat delimiter](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/278) thanks to [jondavis9898](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues?q=is%3Aissue+is%3Aopen+author%3Ajondavis9898)
- Enhancement [Multiple BR() for Concatenate](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/258)

<br/><br/>
**Version 2.1**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBgv), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBgv)

- Bug [Manage Lookup Rollup Summaries produces error CurrencyIsoCode not valid](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/273)

<br/><br/>
**Version 2.0**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBgl), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBgl)

- Enhancement [Support for Custom Metadata](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/242) (Pilot). See [Declarative Lookup Rollup Summary Tool and Custom Metadata](http://andyinthecloud.com/2015/12/24/declarative-lookup-rollup-summary-tool-and-custom-metadata/) for more information.

**UPGRADE NOTE:** There is a new **Manage Lookup Rollup Summaries** tab to support Custom Metadata support.

**Known Current Limitations of Custom Metadata Support**

- Ability to override the generated Apex Test code is not supported (due to platform restriction)
- Aesthetic case adjustment for object field API names will not be performed, e.g. account would not change to Account
- When you Undeploy via Manage Child Triggers button, Active Custom Metadata based rollups are not automatically deactivated, please deactivate manually via un-ticking the Active checkbox.
- Advanced Rollup UI is not currently available, this will be integrated at a later date
- Description field is limited to only 255 characters (due to platform restriction)
- List View support is available under Setup, Custom Metadata Types, Manage Records but does not invoke the new UI for editing

<br/><br/>
**Version 1.25**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBPs), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBPs)

- Enhancement [Allow First/Last Summaries to work on Id and Reference Fields](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/264) thanks to [Christian Carter](https://github.com/cdcarter).
- Enhancement [Nightly Scheduled RollupJob running, but Summaries not updating](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/142), thanks to [frontendloader](https://github.com/frontendloader).

**UPDATE NOTE:** There is a new **Schedule Calculate** button to add to the object Layout, see screenshots below.

![New Calc Screen Button](https://raw.githubusercontent.com/afawcett/declarative-lookup-rollup-summaries/master/images/newscheduledcalcbutton.png)

This will show the following UI related to the enhancement above.

![New Calc Screen](https://raw.githubusercontent.com/afawcett/declarative-lookup-rollup-summaries/master/images/newscheduledcalc.png)

<br/><br/>
**Version 1.24**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QgPw), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QgPw)

- Bug fix [Rollup not recalculated when order by field changes](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/240)
- Bug fix [Concatenation Rollups order maybe none Deterministic - Consider moving order by from LREngine.RollupSummaryField to LREngine.Context](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/239)
- Enhancement [Enhance Order by to allow multiple fields and specify ASC/DESC](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/216)

**IMPORTANT NOTE:** This release improves the query optimisation within the tool when there are multiple rollups. There is also a small change in behaviour from previous releases, relating to default ordering. If you have been using concat, first or last operations and have not specified explicit order by on the rollup, you must do from now on, it no longer defaults to the field to rollup. In prior releases the behaviour of this operation may or may not have been consistently working as expected, depending on the existence of one or more rollups.

<br/><br/>
**Version 1.23**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QgAc), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QgAc)

- Enhancement for [Add developer API to mirror triggerHandler behavior](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/236)
- Enhancement for [Advanced Rollup API Reqiurement: Count of Child on Parent, Child Re-parent, Old Parent Count not Correct](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/167)
- Bug fix for [Reduced number of queries when object name case differs across rollups : Multiple LRE Contexts when rollup definition only differs by case](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/229)
- Bug fix for [Master records updated when related records have not changed ](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/226)
- Bug fix for [Different order by on same relationship field results in incorrect result](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/222)
- Bug fix for [Rollup Summary validations not being enforced on updates after fflib upgrade ](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/212)

<br/><br/>
**Version 1.22**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qg9t), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qg9t)

- Enhancement for [Ability to enable SeeAllData in the generated tests](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/202)
- Bug fix for [Error with multi-currency](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/204)
- Bug fix for [Some of the new fields in the last release are not in the Manage Rollup Permission Set](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/201)

If you are upgrading, you will need to make the following changes to the Layout.

- Add **Test Code See All Data** field to the layout

<br/><br/>
**Version 1.21**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QfxT), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QfxT)

- Enhancement for [Can't get Apex Trigger to Deploy in Production](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/199)
- Enhancement for [Implement the new test level features in Summer 15 to deploy triggers faster](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/190)
- Enhancement for [Allow users to edit child records without needing access to Rollup Summary object](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/162)
- Fix for [First error: Invalid Id when in Scheduled Mode](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/185)
- Fix for [Duplicate Field Selected error message](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/155)

If you are upgrading, you will need to make the following changes to the Layout.

- Add **Test Code** field to the layout

<br/><br/>
**Version 1.20**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QfxO), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QfxO)

- Enhancement for [Private Objects / Sharing Rule](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/183)
- Enhancement for [Allow Master Records To Be Filtered During Calculate](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/179) thanks to [Christian G. Warden](https://github.com/cwarden)
- Fix for [Some tests have hard-coded namespace](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/175) thanks to [Christian G. Warden](https://github.com/cwarden)
- Fix for [Rollup fails when child field is Multi-select picklist and is null](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/150) thanks to [Daniel Hoechst](https://github.com/dhoechst)

If you are upgrading, you will need to make the following changes to the Layout.

- Add **Calculation Sharing Mode** field to the layout

![Calculation Sharing Mode](https://cloud.githubusercontent.com/assets/1167760/7896771/29740d96-06bd-11e5-926f-a6fc402c85b1.png)

<br/><br/>
**Version 1.19**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QewZ), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QewZ)

- Fix for [Concatenate Distinct Duplicates Values When Rolling up Multi-Select Picklists](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/128)
- Enhancement for [Improve trigger test deployment failure reporting when Code coverage error received](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/122)
- Fix for [Currency Fields in the Rollup causing the issues - "Master and detail fields must be the same field type (or text based) for First or Last operations"](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/121)

<br/><br/>
**Version 1.18**

---

Read more about this releae [here](http://andyinthecloud.com/2015/02/16/declarative-lookup-rollup-summaries-tool-dlrs-spring15-release/).

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeuE), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeuE)

- Debug added for bug [Unable to connect to the Salesforce Metadata API](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/110)
- Enhancement [How to rollup count of unique values](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/99)
- Enhancement [Rollup picklist or text values?](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/76)
- Enhancement [Filter by last create date](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/79)
- Enhancement [Support for Lightning Process Builder](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/117)

If you are upgrading, you will need to make the following changes to the Layout and Picklists.

- Add **Lookup Rollup Summary Unique Name**, **Concatenate Delimiter**, **Field to Order By** fields to the layout
- Add **Count Distinct**, **Concatenate**, **Concatenate Distinct**, **First** and **Last** picklist items to **Aggregate Operation**
- Add **Process Builder** picklist item to **Calculation Mode**

<br/><br/>
**Version 1.17**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qeej), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qeej)

- Fix for [Exception when saving a new rollup when the child object is invalid](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/115)
- Enhancement for [Validate the Rollup Criteria on Save ](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/108)
- Enhancement for [Suggestion: Add 'Description' field to Lookup Rollup Summary SObject](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/90) (requires manually adding to Layout for upgrades)
- Fix for [Null object error - Aggregating null currency field on child](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/107) also same fix for [System.NullPointerException: Attempt to de-reference a null object - Error - Post v1.14 Upgrade](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/95)
- Fix for [Salesforce Standard Order object OpportunityID field not recognized](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/98)
- Upgrade to API 32 (sees new Standard objects) related to attempted fix for [Error "Object does not exist" for CombinedAttachment](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/103)

<br/><br/>
**Version 1.16**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeZ0), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeZ0)

- Fix for [RollupJob error: Cannot have more than 10 chunks in a single operation](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/51), thanks to [David Carter](https://github.com/dcarter).

<br/><br/>
**Version 1.15**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeSJ), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeSJ)

- Fix for [Two rules using same set of RelationshipCriteria fields don't create scheduled items](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/100)
- Fix for [System.NullPointerException: Attempt to de-reference a null object when saving a Rule](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/97)
- Fix for [Install error Version 1.12 - Requires Streaming API](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/86)
- Fix for [Support installation without having to have Ideas enabled](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/33)

<br/><br/>
**Version 1.14**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeNs), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeNs)

- Fix for [Enable count rollup on any field](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/92)
- Fix for [Only one rollup per field working at a time](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/63)
- Fix for [Multiple rollups on same field fail to execute](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/85)

<br/><br/>
**Version 1.13**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeLD), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeLD)

- Fix for [Apex Error Query Exception](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/83)

<br/><br/>
**Version 1.12**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeFj), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeFj)

**KNOWN ISSUE:** [Apex Error Query Exception](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/83), please use version v1.11 below if you encounter this issue.

- Fix for [Currency Conversion?](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/57), special thanks to [Anthony Heber](https://github.com/aheber) for submitting the enhancement to [LREngine](https://github.com/abhinavguptas/Salesforce-Lookup-Rollup-Summaries) to fix this. The result of the child aggregation is converted to the parent record currency if the child field being aggregated is a Currency type and the org is using Multi-Currency. Note currently dated exchanged rates (available through Advanced Mulit-Currency) are currently not supported.

<br/><br/>
**Version 1.11**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QdRT), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QdRT)

- Fix for [Issue Deploy Trigger not successful, with no error (due to code coverage being low)](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/54)

<br/><br/>
**Version 1.10**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qbz8), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qbz8)

- Enhancement for [Issue 52 Auto Create Remote Site Setting](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/52)
- Fix for [Issue 25 Error with Manage Child Trigger button for very long object names](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/25)

<br/><br/>
**Version 1.9 - Community Powered!**

---

Read more about this release [here](http://andyinthecloud.com/2014/04/09/new-declarative-rollup-tool-release-community-powered)

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qbz3), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qbz3)

- Fix for [Issue 23](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/23)
- Fix for [Issue 22](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/22)
- Fix for [Issue 21](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/21)
- Enhancement for [Issue 16](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/16)
- Enhancement for [Issue 5](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/5)
- Enhancement for [Issue 15](https://github.com/afawcett/declarative-lookup-rollup-summaries/pull/15)

**KNOWN INSTALL ISSUE** There appears to be an install issue identified when installing into orgs without Ideas installed for v1.9, if you encourter this enable Ideas if you can, otherwise use v1.7 until the issue is resolved.

<br/><br/>
**Version 1.8**

---

Not released

<br/><br/>
**Version 1.7**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QYAW), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QYAW)

- Fix for [Issue 14](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/14), relating to null pointer exception

<br/><br/>
**Version 1.6 - Spring'14 Release - 9th February 2014**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QRXG), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QRXG)

- Enhancements to support Schedule mode, Calculate historic records, Developer API and more, see [here](http://andyinthecloud.com/2014/02/09/new-release-spring14-declarative-rollup-summary-tool/).
- Fix for [Issue 10](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/10)
- Fix for [Issue 11](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/11)

<br/><br/>
**Version 1.5**

---

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QCpr), [Sandbox URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QCpr)

- Fix for [Issue 7](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/7) and [Issue 8](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/8), relating to failure to report test execution errors in production org.

<br/><br/>
**Version 1.4**

---

- Fix for [Issue 3](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/4), relating to issue when deleting last child record not updating rollup fields to 0.

<br/><br/>
**Version 1.3**

---

- Fix for [Issue 2](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/2), relating to error 'purgeOnDelete option can only be used on a non-active org'

<br/><br/>
**Version 1.2**

---

- Support for Realtime calculations
- Validation of valid fields and field types on Declarative Rollup definition fields
- Optimisation during update of child records to only apply rollup when field to aggregate changes
- More extensive unit tests, also those around use of limits such as queries, rows etc.

![Upload](https://raw.githubusercontent.com/afawcett/declarative-lookup-rollup-summaries/master/images/PublisherConsole.png)
![Review Passed](https://raw.githubusercontent.com/afawcett/declarative-lookup-rollup-summaries/master/images/UploadedPackages.png)

<br/><br/>
**Version Beta 6**

---

- Support for Realtime calculations
- Limited validation on Declarative Rollup definition fields
- Limited testing on multiple lookups
- Fixed issue with multiple lookups

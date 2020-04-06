Declarative Rollups for Lookup Field Relationships
==================================================

[![Build Status](https://travis-ci.org/afawcett/declarative-lookup-rollup-summaries.svg)](https://travis-ci.org/afawcett/declarative-lookup-rollup-summaries)

Features Summary
----------------

- Rollup information between Lookup relationships not previously possible without writing Apex Triggers
- Define rollups using standard UI declaratively, no coding required
- Define filter criteria on rollups for example Rollup Amount on Opportunity onto Account for Closed Won
- Supports Realtime, Scheduled and Developer API modes
- Open source, available in code and managed package form.
- Managed package has passed Salesforce Security Review and is Aloha enabled
- Supports Custom Metadata, rollups can be included in Change Sets and Packages for easier deployment

Please refer to the blog posts below for more detailed information.

Community Support
-----------------

This is a community driven tool, please help support it, share your experiences in this [Chatter group](https://success.salesforce.com/_ui/core/chatter/groups/GroupProfilePage?g=0F9300000009O5p).

Documentation
-------------

In addition to the [Wiki](https://github.com/afawcett/declarative-lookup-rollup-summaries/wiki) the tool has been featured in a number of blog entries as it has evolved...

**NOTE:** The links are in chronological order, if your new to the tool, read from the bottom upwards

- [Declarative Rollup Summary Tool Update for v2.12](https://andyinthecloud.com/2020/04/05/declarative-rollup-summary-tool-update/)
- [Salesforce Rollup Summary on Lookup Relationship | DLRS Tutorial](https://www.youtube.com/watch?v=sjRlou2-N6I&feature=youtu.be)
- [Monitoring your Scheduled Rollups via Report Subscriptions](https://www.dandonin.com/2017/05/24/automated-error-alerts-and-mass-delete-error-records/)
- [Counting Tasks with DLRS](https://www.dandonin.com/2017/04/21/counting-tasks-with-dlrs/)
- [Getting Started With DLRS](https://www.dandonin.com/2017/03/16/how-to-dlrs/)
- [Refer to this for Schedule mode usage](https://github.com/afawcett/declarative-lookup-rollup-summaries/wiki/What-you-need-to-know-about-Scheduling-Rollups)
- [Declarative Rollup Tool Summer (2016) Release](https://andyinthecloud.com/2016/06/19/declarative-rollup-tool-summer-release/)
- [Rollups and Cross Object Formula Fields](http://andyinthecloud.com/2016/02/13/rollups-and-cross-object-formula-fields/)
- [Packaging and Installing Rollups](https://andyinthecloud.com/2016/01/24/packaging-and-installing-rollups/)
- [Declarative Lookup Rollup Summary Tool and Custom Metadata](http://andyinthecloud.com/2015/12/24/declarative-lookup-rollup-summary-tool-and-custom-metadata/)
- [Declarative Lookup Rollup Summaries – Spring’15 Release](http://andyinthecloud.com/2015/02/16/declarative-lookup-rollup-summaries-tool-dlrs-spring15-release/)
- [A Declarative Rollup Summary Tool for Force.com Lookup Relationships](https://developer.salesforce.com/page/Declarative_Rollup_Summary_Tool_for_Force.com_Lookup_Relationships)
- [Account Hierarchy Rollups #ClicksNotCode](http://andyinthecloud.com/2014/05/08/account-hierarchy-rollups-clicksnotcode/)
- [New Release: Declarative Rollup Summary Tool Community Powered!](http://andyinthecloud.com/2014/04/09/new-declarative-rollup-tool-release-community-powered/)
- [New Release: Spring’14 Declarative Rollup Summary Tool](http://andyinthecloud.com/2014/02/09/new-release-spring14-declarative-rollup-summary-tool/) 
- [New Tool : Declarative Rollups for Lookups!](http://andyinthecloud.com/2013/07/07/new-tool-declarative-rollups-for-lookups/)

Implementation Considerations
-----------------------------

- **Professional Edition**. Professional Edition is supported only when using Process Builder or a [Scheduled Full Recalculation](https://github.com/afawcett/declarative-lookup-rollup-summaries/wiki/What-you-need-to-know-about-Scheduling-Rollups). Ignore prompts to setup the Remote Site for Metadata API callouts, as this will not be needed. You can use either the new  Manage Lookup Rollup Summaries tab (recommended) or the older Lookup Rollup Summaries tab. Make to select Calculation Mode as Process Builder when setting up your rollup (this will not require an Apex Trigger deployment). Please note that record deletion is not captured using Process Builder. For more information on using Process Builder with this tool see [here](https://andyinthecloud.com/2015/02/16/declarative-lookup-rollup-summaries-tool-dlrs-spring15-release/).
- **Check Existings Apex Tests.** This tool dynamically deploys Apex Triggers and Apex tests, please make sure your Sandbox and Production org tests are all fully working before you attempt to use this tool. Otherwise usage of this tool will be blocked until you resolve such errors. If you have an org with triggers on the sObject that will contain the roll up result, installation into sandbox is VERY HIGHLY recommended so that after Lookup Rollup Summary records are added/enabled, you should rerun all testmethods to ensure nothing has broken as your before/after update triggers on the parent sObject will re-execute.
- **Existing Tests on Parent Objects**. This tool will update the indicated fields on your Parent objects when it senses activity on Child objects. Ensure an Apex Triggers you have written on your Parent objects are written with best practices around bulkification in mind. If in doubt be sure to perform significant testing.

Usage Information and Known Issues
----------------------------------

- **Platform SOQL Limits**. This tool uses [SOQL Aggregate](http://www.salesforce.com/us/developer/docs/apexcode/Content/langCon_apex_SOQL_agg_fns.htm) queries and is subject to [platform limitations](http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_gov_limits.htm). This basically means...
- **Deployment issues into Production**. This tool dynamically deploys a small trigger and test class to the org. This is subject to the same rules and compliances as as a regular human developer. The generate test class, can in some cases be to simplisitc to get code coverage, requiring at present a developer to assist with the deployment, especially to production. There is more details on how to look for this scenario and how to workaround it, as well as future thoughts [here](https://github.com/afawcett/declarative-lookup-rollup-summaries/wiki/Challenges-with-Code-Coverage).
- **Volume Considerations**. For each rollup, there is a maximum of 50,000 child relation records that can be summarised each time child record/s insert/update/delete operations are made (which may process several configured rollups). The rollup processes children to rollup by their parent record relationship and an optional further filter if provided. Meaning so long as this relationship does not result in more than 50,000 child records per parent parent record it will be successful. Take a look at this [blog post](http://andyinthecloud.com/2014/02/09/new-release-spring14-declarative-rollup-summary-tool/) which describes some new configuration settings (see bottom of blog post) to help calibrate the tool when running the Scheduled or Calculate jobs to help work within the 50,000 row limit.
- **Indexing Fields**. For performance reasons ensure the fields used are indexed (lookups are by default) and also any fields used in the filter criteria. This can be very important as without this, a full table scan will occur when the platform executes the SOQL and cause performance issues. For more information from Salesforce please see [here](http://wiki.developerforce.com/page/Best_Practices_for_Deployments_with_Large_Data_Volumes) and [here](http://blogs.developerforce.com/engineering/2013/02/force-com-soql-best-practices-nulls-and-formula-fields.html).
- **Realtime Mode and Formula Fields**. When using the Realtime mode, certain Formula field expressions need more consideration. If your formula field refereces other fields defined on the object the formula field is defined on, please state the fields these formulas reference in the Realtionship Field Criteria fields (the tool does not monitor changes in formula fields). If your formulas reference fields on related records (via lookup fields) see this [blog](https://andyinthecloud.com/2016/02/13/rollups-and-cross-object-formula-fields/). If your formula field uses formula functions that are date sensitive like YEAR the tool will not auto recacluate in realtime (as no field has changed). To work around this, either switch to Scheduled mode or in Relatime mode use a Workflow Field Update to copy the formula field value to a physical field and reference that.
- **Sandbox Testing**. While the tool can be installed and enabled directly in production, sandbox testing is still strongly recommended.
- **INVALID_SESSION_ID: Invalid Session ID found in SessionHeader: Illegal Session faultcode=sf:INVALID_SESSION_ID faultactor=**. This can occur when your using the Manage Child Trigger button or editing rollups via the Manage Lookup Rollup Summaries tab. Solution is to disable the 'Lock sessions to the IP address from which they they originated.' setting under Session Settings under Setup. Salesforce documentation notes the following 'This option can inhibit various applications and mobile devices.'. Note this issue only applies while configuration changes are being made with the tool, especially via the Manage Lookup Rollup Summaries (see release notes v2.0). Once rollups are configured this issue does not apply during rollup calculations.
- **Schedule Mode Setup**. This is not so much a know issue, but a known source of confusion with the current tool. If you want to use the schedule mode features please read [this first](https://github.com/afawcett/declarative-lookup-rollup-summaries/wiki/What-you-need-to-know-about-Scheduling-Rollups)

Please feel free to raise feedback and issues via the **Github Issues** page [here](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues).

Packaged Release History
------------------------

You can install a packaged version of the tool into your production org (sandbox testing as always recommended). Check the limatations and known issues above first! 

**Latest Release Version 2.12**
_______________________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0N000000YGN4&isdtp=p1), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t0N000000YGN4&isdtp=p1)

- Enhancement - [Avoid need for Remote Site setup](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/925)
- Enhancement - [Cannot disable DLRS in Apex](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/889)
- Enhancement - [Update API version of DLRS](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/831)
- Enhancement - [New "Lookup Rollup Summaries Tools" tab](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/678)
- Enhancement - [Improved UI messaging to direct users to the Manage Lookup Rollup Summaries tab](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/677)
- Enhancement - [Minor tweeks to the messaging on the full recalc UI's](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/675)
- Enhancement - [Route various apex job errors to scheduling/running users email](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/671)
- Enhancement - [Modify test code for parent object](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/637)
- Enhancement - [Avoid Shadow Custom Object Based Rollup Records - Total DLRS Newbie frustration](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/618)
- Bug - [Master branch has Apex Unit test failures](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/894)
- Bug - [Clicking Cancel on Full Calculate schedule page goes back to wrong page](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/676)

Also see [Declarative Rollup Summary Tool Update for v2.12](https://andyinthecloud.com/2020/04/05/declarative-rollup-summary-tool-update/).

**Release Version 2.11.1**
__________________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0N000001E2L5), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t0N000001E2L5)

- Bug [Summer 19-Invalid field MasterRecordId for Case SobjectException due version 42](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/818)

**IMPORTANT NOTE:**
The Cases DLRS Trigger will fail in Summer '19 if you do not upgrade to 2.11.1 until the related known issue is fixed by Salesforce. This only impacts users with the Case object DLRS Child Trigger created and active.

**Release Version 2.11**
_______________________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0N000000IyYr), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t0N000000IyYr)

- Enhancement [OR clause in top level filter breaks SOQL query](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/631)
- Enhancement [Upgrade to Latest API: New object are not available](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/627)
- Bug [SObject type does not allow locking rows](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/619)
- Enhancement [Remote Settings update](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/372)
- Enhancement [Lightning Enterprise Edition](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/569)

**Release Version 2.10**
________________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000UvwL), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000UvwL)

- Enhancement [Enhancement: Schedule calculate - don't DML update record if rollup value unchanged](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/547)
- Enhancement [Known ordering for RollupCalculateJob records](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/518)
- Enhancement [Can't aggregate Salesforce Files (ContentDocumentLink) as child object](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/433)
- Enhancement [Reinstate support for Test Code field on Rollups using Custom Metadata](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/304)
- Bug [Error When Adding a Note in SF Lightning Due to DLRS Trigger](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/558)
- Bug [Calculate new roll up failing on "The rollup must be Active before you can run a Calculate job"](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/511)

**UPGRADE NOTE:** If you access the Rollup definitions via the standard Salesforce Custom Metadata UI under the Setup menu. Make sure to remove 'Test Code (Depricated)' (small one) from the layout and add the new 'Test Code' field (large one). If you only ever use the Manage Rollup Summaries tab you do not need to worry about this. Also note that any test code placed in the original smaller field will be automatically migrated to the new field on next edit (via Manage Rollup Summaries tab).

**Release Version 2.9**
_______________________

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

**Release Version 2.8**
_______________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXkF), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXkF)

- Bug [Lookup Rollup Calculate Job records are not being deleted even after the Calculate Job finishes](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/460)
- Bug [Help Text for Calculation Mode needs updating](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/350)
- Bug [Account Trigger->Decimal to Integer Illegal Assignment](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/326)
- Enhancement [Feature Request - the ability to set schedule dlrs job name](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/415)
- Enhancement [Better messaging when scheduling jobs](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/353)

**IMPORTANT NOTE:** Please check your Rollup Calculate Job records and if needed delete them.

**Release Version 2.7**
_______________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXk5), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXk5)

- Bug [Validation Errors 'ENTITY_IS_DELETED' While Saving when Parent gets Deleted As Well](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/39)

**Release Version 2.6**
_______________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXZG), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXZG)

- Bug [DLRS fails rollup on Checkbox when no records found](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/379) Thanks Wes Weingartner!
- Bug [Developer Script Exception : Entity is not api accessible](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/360)
- Bug [Lookup Rollup Calculate Jobs not Case-sensitive](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/347)

**Release Version 2.5**
_______________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXVO), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000MXVO)

- Bug [After Delete trigger for merging fails when new dlrs added](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/371)
- Bug [Should not need to mark Active to do a manual Calculation](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/359)
- Bug [Apex Scheduler Day of Week Drop down is a day out](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/349)
- Bug [Merging lead causes Permission to create dlrs__LookupRollupSummary__c error](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/345)
- Enhancement [Support ContentNote rollups (upgraded to API 37.0)](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/351)

**Release Version 2.4.2**
_________________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000ka9e), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000ka9e)

- Bug [Install failed 2.4 update - New dependency on LookupChild's Sharing mode in Apex Unit Test](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/344)

**Release Version 2.4.1**
_________________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000ka90), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000ka90)

**Documentation:** See [Declarative Rollup Tool Summer (2016) Release](https://andyinthecloud.com/2016/06/19/declarative-rollup-tool-summer-release/)

- Bug [Installation Issue - The user license doesn't allow the permission: Read All dlrs__LookupRollupCalculateJob__c](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/331)
- Enhancement [Roll Up just for few number of records](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/315)
- Enhancement [Support for rollups on Account when doing Merge Account](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/303)
- Enhancement [Add support for ALL ROWS](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/267)
- Enhancement [Scheduled Calculate Custom Settings](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/265)
- Enhancement [Open Activities still associated to the Converted Lead](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/164)
- Enhancement [Remove from Lookup Rollup Summary Schedule Items when Parent is deleted](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/147)

**Version 2.3**
_______________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBqJ), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBqJ)

- Bug [Attempt to de-reference a null object from RollupJob (as seen on Apex Jobs page)](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/318)
- Bug [SP(), BR(), TB() not working in 2.2](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/291)
- Bug [Calculation Id not populating in Version 2.1](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/280)
- Bug [Validation Errors 'ENTITY_IS_DELETED' While Saving when Parent gets Deleted As Well](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/39)

**Version 2.2**
_______________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBh0), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBh0)

- Bug [multiple criteria fields don't work anymore.](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/281)
- Enhancement [Add support for space & tab in concat delimiter](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/278) thanks to [jondavis9898](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues?q=is%3Aissue+is%3Aopen+author%3Ajondavis9898)
- Enhancement [Multiple BR() for Concatenate](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/258)

**Version 2.1**
______________________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBgv), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBgv)

- Bug [Manage Lookup Rollup Summaries produces error CurrencyIsoCode not valid](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/273)

**Version 2.0**
________________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBgl), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBgl)

- Enhancement [Support for Custom Metadata](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/242) (Pilot). See [Declarative Lookup Rollup Summary Tool and Custom Metadata](http://andyinthecloud.com/2015/12/24/declarative-lookup-rollup-summary-tool-and-custom-metadata/) for more information.

**UPGRADE NOTE:** There is a new **Manage Lookup Rollup Summaries** tab to support Custom Metadata support.

**Known Current Limitiations of Custom Metadata Support**
- Ability to override the generated Apex Test code is not supported (due to platform restriction)
- Aesthetic case adjustment for object field API names will not be performed, e.g. account would not change to Account
- When you Undeploy via Manage Child Triggers button, Active Custom Metadata based rollups are not automatically deactivated, please deactivate manually via unticking the Active checkbox.
- Advanced Rollup UI is not currently available, this will be integrated at a later date
- Description field is limited to only 255 characters (due to platform restriction)
- List View support is available under Setup, Custom Metadata Types, Manage Records but does not invoke the new UI for editing

**Version 1.25**
________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBPs), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000cBPs)

- Enhancement [Allow First/Last Summaries to work on Id and Reference Fields](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/264) thanks to [Christian Carter](https://github.com/cdcarter).
- Enhancement [Nightly Scheduled RollupJob running, but Summaries not updating](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/142), thanks to [frontendloader](https://github.com/frontendloader).

**UPDATE NOTE:** There is a new **Schedule Calculate** button to add to the object Layout, see screenshots below.

![New Calc Screen Button](https://raw.githubusercontent.com/afawcett/declarative-lookup-rollup-summaries/master/images/newscheduledcalcbutton.png)

This will show the following UI related to the enhancement above. 

![New Calc Screen](https://raw.githubusercontent.com/afawcett/declarative-lookup-rollup-summaries/master/images/newscheduledcalc.png)

**Version 1.24**
________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QgPw), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QgPw)

- Bug fix [Rollup not recalculated when order by field changes](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/240)
- Bug fix [Concatenation Rollups order maybe none Deterministic - Consider moving order by from LREngine.RollupSummaryField to LREngine.Context](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/239)
- Enhancement [Enhance Order by to allow multiple fields and specify ASC/DESC](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/216)

**IMPORTANT NOTE:** This release improves the query optimisation within the tool when there are multiple rollups. There is also a small change in behaviour from previous releases, relating to default ordering. If you have been using concat, first or last operations and have not specified explicit order by on the rollup, you must do from now on, it no longer defaults to the field to rollup. In prior releases the behaviour of this operation may or may not have been consistantly working as expected, depending on the existance of one or more rollups.

**Version 1.23**
________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QgAc), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QgAc)

- Enhancement for [Add developer API to mirror triggerHandler behavior](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/236)
- Enhancement for [Advanced Rollup API Reqiurement: Count of Child on Parent, Child Re-parent, Old Parent Count not Correct](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/167)
- Bug fix for [Reduced number of queries when object name case differs across rollups : Multiple LRE Contexts when rollup definition only differs by case](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/229)
- Bug fix for [Master records updated when related records have not changed ](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/226)
- Bug fix for [Different order by on same relationship field results in incorrect result](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/222)
- Bug fix for [Rollup Summary validations not being enforced on updates after fflib upgrade ](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/212)

**Version 1.22**
_______________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qg9t), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qg9t)

- Enhancement for [Ability to enable SeeAllData in the generated tests](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/202)
- Bug fix for [Error with multi-currency](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/204)
- Bug fix for [Some of the new fields in the last release are not in the Manage Rollup Permission Set](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/201)

If you are upgrading, you will need to make the following changes to the Layout.
- Add **Test Code See All Data** field to the layout

**Version 1.21**
_______________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QfxT), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QfxT)

- Enhancement for [Can't get Apex Trigger to Deploy in Production](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/199)
- Enhancement for [Implement the new test level features in Summer 15 to deploy triggers faster](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/190)
- Enhancement for [Allow users to edit child records without needing access to Rollup Summary object](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/162)
- Fix for [First error: Invalid Id when in Scheduled Mode](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/185)
- Fix for [Duplicate Field Selected error message](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/155)

If you are upgrading, you will need to make the following changes to the Layout.
- Add **Test Code** field to the layout

**Version 1.20**
_______________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QfxO), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QfxO)

- Enhancement for [Private Objects / Sharing Rule](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/183)
- Enhancement for [Allow Master Records To Be Filtered During Calculate](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/179) thanks to [Christian G. Warden](https://github.com/cwarden)
- Fix for [Some tests have hard-coded namespace](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/175) thanks to [Christian G. Warden](https://github.com/cwarden)
- Fix for [Rollup fails when child field is Multi-select picklist and is null](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/150) thanks to [Daniel Hoechst](https://github.com/dhoechst)

If you are upgrading, you will need to make the following changes to the Layout.
- Add **Calculation Sharing Mode** field to the layout

![Calculation Sharing Mode](https://cloud.githubusercontent.com/assets/1167760/7896771/29740d96-06bd-11e5-926f-a6fc402c85b1.png)

**Version 1.19**
_______________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QewZ), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QewZ)

- Fix for [Concatenate Distinct Duplicates Values When Rolling up Multi-Select Picklists](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/128)
- Enhancement for [Improve trigger test deployment failure reporting when Code coverage error received](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/122)
- Fix for [Currency Fields in the Rollup causing the issues - "Master and detail fields must be the same field type (or text based) for First or Last operations"](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/121)

**Version 1.18**
_______________________

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

**Version 1.17**
________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qeej), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qeej)

- Fix for [Exception when saving a new rollup when the child object is invalid](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/115)
- Enhancement for [Validate the Rollup Criteria on Save ](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/108)
- Enhancement for [Suggestion: Add 'Description' field to Lookup Rollup Summary SObject](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/90) (requires manually adding to Layout for upgrades)
- Fix for [Null object error - Aggregating null currency field on child](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/107) also same fix for [System.NullPointerException: Attempt to de-reference a null object - Error - Post v1.14 Upgrade](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/95)
- Fix for [Salesforce Standard Order object OpportunityID field not recognized](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/98)
- Upgrade to API 32 (sees new Standard objects) related to attempted fix for [Error "Object does not exist" for CombinedAttachment](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/103)

**Version 1.16**
________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeZ0), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeZ0)

- Fix for [RollupJob error: Cannot have more than 10 chunks in a single operation](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/51), thanks to [David Carter](https://github.com/dcarter).

**Version 1.15**
________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeSJ), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeSJ)

- Fix for [Two rules using same set of RelationshipCriteria fields don't create scheduled items](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/100)
- Fix for [System.NullPointerException: Attempt to de-reference a null object when saving a Rule](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/97)
- Fix for [Install error Version 1.12 - Requires Streaming API](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/86)
- Fix for [Support installation without having to have Ideas enabled](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/33)

**Version 1.14**
________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeNs), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeNs)

- Fix for [Enable count rollup on any field](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/92)
- Fix for [Only one rollup per field working at a time](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/63)
- Fix for [Multiple rollups on same field fail to execute](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/85)

**Version 1.13**
________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeLD), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeLD)

- Fix for [Apex Error Query Exception](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/83)

**Version 1.12**
________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeFj), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QeFj)

**KNOWN ISSUE:** [Apex Error Query Exception](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/83), please use version v1.11 below if you encounter this issue.

- Fix for [Currency Conversion?](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/57), special thanks to [Anthony Heber](https://github.com/aheber) for submitting the enhancement to [LREngine](https://github.com/abhinavguptas/Salesforce-Lookup-Rollup-Summaries) to fix this. The result of the child aggregation is converted to the parent record currency if the child field being aggregated is a Currency type and the org is using Multi-Currency. Note currently dated exchanged rates (available through Advanced Mulit-Currency) are currently not supported.

**Version 1.11**
________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QdRT), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QdRT)

- Fix for [Issue Deploy Trigger not successful, with no error (due to code coverage being low)](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/54)

**Version 1.10**
________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qbz8), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qbz8)

- Enhancement for [Issue 52 Auto Create Remote Site Setting](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/52)
- Fix for [Issue 25 Error with Manage Child Trigger button for very long object names](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/25)

**Version 1.9 - Community Powered!**
____________________________________

Read more about this release [here](http://andyinthecloud.com/2014/04/09/new-declarative-rollup-tool-release-community-powered)

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qbz3), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qbz3)

- Fix for [Issue 23](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/23)
- Fix for [Issue 22](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/22)
- Fix for [Issue 21](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/21)
- Enhancement for [Issue 16](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/16)
- Enhancement for [Issue 5](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/5)
- Enhancement for [Issue 15](https://github.com/afawcett/declarative-lookup-rollup-summaries/pull/15) 

**KNOWN INSTALL ISSUE** There appears to be an install issue identified when installing into orgs without Ideas installed for v1.9, if you encourter this enable Ideas if you can, otherwise use v1.7 until the issue is resolved.

**Version 1.8**
________________

Not released

**Version 1.7**
________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QYAW), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QYAW)

- Fix for [Issue 14](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/14), relating to null pointer exception

**Version 1.6 - Spring'14 Release - 9th February 2014**
_______________________________________________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QRXG), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QRXG)

- Enhancements to support Schedule mode, Calculate historic records, Developer API and more, see [here](http://andyinthecloud.com/2014/02/09/new-release-spring14-declarative-rollup-summary-tool/).
- Fix for [Issue 10](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/10)
- Fix for [Issue 11](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/11)

**Version 1.5**
_______________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QCpr), [Sandbox URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QCpr)

- Fix for [Issue 7](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/7) and [Issue 8](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/8), relating to failure to report test execution errors in production org.

**Version 1.4**
_______________

- Fix for [Issue 3](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/4), relating to issue when deleting last child record not updating rollup fields to 0.

**Version 1.3**
_______________

- Fix for [Issue 2](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/2), relating to error 'purgeOnDelete option can only be used on a non-active org'

**Version 1.2**
_______________

- Support for Realtime calculations
- Validation of valid fields and field types on Declarative Rollup definition fields
- Optimisation during update of child records to only apply rollup when field to aggregate changes
- More extensive unit tests, also those around use of limits such as queries, rows etc.

![Upload](https://raw.githubusercontent.com/afawcett/declarative-lookup-rollup-summaries/master/images/PublisherConsole.png)
![Review Passed](https://raw.githubusercontent.com/afawcett/declarative-lookup-rollup-summaries/master/images/UploadedPackages.png)

**Version Beta 6**
__________________

- Support for Realtime calculations
- Limited validation on Declarative Rollup definition fields
- Limited testing on multiple lookups
- Fixed issue with multiple lookups

Installing the Source Code (Developers)
=======================================

This project now uses Salesforce DX for development and packaging. Clone this org and deploy the code to a scratch org to develop and contribute back changes via Pull Requests. If you want to deploy the unmanaged version of this to your sandbox or production org you can use the Salesforce DX convert and deploy commands to do so. However the recommended deployment for these orgs is via the managed package links above.

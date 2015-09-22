Declarative Rollups for Lookups!
================================

[![Build Status](https://travis-ci.org/afawcett/declarative-lookup-rollup-summaries.svg)](https://travis-ci.org/afawcett/declarative-lookup-rollup-summaries)

Features Summary
----------------

- Rollup information between Lookup relationships not previously possible without writing Apex Triggers
- Define rollups using standard UI declaratively, no coding required
- Define filter criteria on rollups for example Rollup Amount on Opportunity onto Account for Closed Won
- Supports Realtime, Scheduled and Developer API modes
- Open source, available in code and managed package form.
- Managed package has passed Salesforce Security Review and is Aloha enabled (does not consume app, tab limits)

Please refer to the blog posts below for more detailed information.

Community
---------

This is a community driven tool, please help support it, share your experiences in this [Chatter group](https://success.salesforce.com/_ui/core/chatter/groups/GroupProfilePage?g=0F9300000009O5p).

Documentation
-------------

The tool has been featured in a number of blog entries as it has evolved...

- [Declarative Lookup Rollup Summaries – Spring’15 Release](http://andyinthecloud.com/2015/02/16/declarative-lookup-rollup-summaries-tool-dlrs-spring15-release/)
- [A Declarative Rollup Summary Tool for Force.com Lookup Relationships](https://developer.salesforce.com/page/Declarative_Rollup_Summary_Tool_for_Force.com_Lookup_Relationships)
- [Account Hierarchy Rollups #ClicksNotCode](http://andyinthecloud.com/2014/05/08/account-hierarchy-rollups-clicksnotcode/)
- [New Release: Declarative Rollup Summary Tool Community Powered!](http://andyinthecloud.com/2014/04/09/new-declarative-rollup-tool-release-community-powered/)
- [New Release: Spring’14 Declarative Rollup Summary Tool](http://andyinthecloud.com/2014/02/09/new-release-spring14-declarative-rollup-summary-tool/) 
- [New Tool : Declarative Rollups for Lookups!](http://andyinthecloud.com/2013/07/07/new-tool-declarative-rollups-for-lookups/)

There is also an early releaes video demonstration here...

<a href="http://www.youtube.com/watch?feature=player_embedded&v=6BST-TpyHHk" target="_blank"><img src="http://img.youtube.com/vi/6BST-TpyHHk/0.jpg" 
width="420" height="315" border="10" /></a>

Implementation Considerations
-----------------------------

- **Check Existings Apex Tests.** This tool dynamically deploys Apex Triggers and Apex tests, please make sure your Sandbox and Production org tests are all fully working before you attempt to use this tool. Otherwise usage of this tool will be blocked until you resolve such errors. If you have an org with triggers on the sObject that will contain the roll up result, installation into sandbox is VERY HIGHLY recommended so that after Lookup Rollup Summary records are added/enabled, you should rerun all testmethods to ensure nothing has broken as your before/after update triggers on the parent sObject will re-execute.
- **Existing Tests on Parent Objects**. This tool will update the indicated fields on your Parent objects when it senses activity on Child objects. Ensure an Apex Triggers you have written on your Parent objects are written with best practices around bulkification in mind. If in doubt be sure to perform significant testing.

Usage Information and Known Issues
----------------------------------

- **Platform SOQL Limits**. This tool uses [SOQL Aggregate](http://www.salesforce.com/us/developer/docs/apexcode/Content/langCon_apex_SOQL_agg_fns.htm) queries and is subject to [platform limitations](http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_gov_limits.htm). This basically means...
- **Deployment issues into Production**. This tool dynamically deploys a small trigger and test class to the org. This is subject to the same rules and compliances as as a regular human developer. The generate test class, can in some cases be to simplisitc to get code coverage, requiring at present a developer to assist with the deployment, especially to production. There is more details on how to look for this scenario and how to workaround it, as well as future thoughts [here](https://github.com/afawcett/declarative-lookup-rollup-summaries/wiki/Challenges-with-Code-Coverage).
- **Volume Considerations**. For each rollup, there is a maximum of 50,000 child relation records that can be summarised each time child record/s insert/update/delete operations are made (which may process several configured rollups). The rollup processes children to rollup by their parent record relationship and an optional further filter if provided. Meaning so long as this relationship does not result in more than 50,000 child records per parent parent record it will be successful. Take a look at this [blog post](http://andyinthecloud.com/2014/02/09/new-release-spring14-declarative-rollup-summary-tool/) which describes some new configuration settings (see bottom of blog post) to help calibrate the tool when running the Scheduled or Calculate jobs to help work within the 50,000 row limit.
- **Indexing Fields**. For performance reasons ensure the fields used are indexed (lookups are by default) and also any fields used in the filter criteria. This can be very important as without this, a full table scan will occur when the platform executes the SOQL and cause performance issues. For more information from Salesforce please see [here](http://wiki.developerforce.com/page/Best_Practices_for_Deployments_with_Large_Data_Volumes) and [here](http://blogs.developerforce.com/engineering/2013/02/force-com-soql-best-practices-nulls-and-formula-fields.html).
- **Realtime Mode and Formula Fields**. When using the Realtime mode, Formula fields as fields to aggregate are not supported (validation will be added in a future release to block this). To work around this, either switch to Scheduled mode or in Relatime mode use a Workflow Field Update to copy the formula field value to a physical field and reference that.
- **Sandbox Testing**. While the tool can be installed and enabled directly in production, sandbox testing is still strongly recommended.
- **Professional Edition**. Professional Edition is not supported, due to the Metadata API used by the tool not being available in this edition.

Please feel free to raise feedback and issues via the **Github Issues** page [here](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues).

Packaged Release History
------------------------

You can install a packaged version of the tool into your production org (sandbox testing as always recommended). Check the limatations and known issues above first! 

**Latest Version 1.23**
_______________________

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QgAc), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QgAc)

- Enhancement for [Add developer API to mirror triggerHandler behavior](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/236)
- Enhancement for [Advanced Rollup API Reqiurement: Count of Child on Parent, Child Re-parent, Old Parent Count not Correct](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/167)
- Bug fix for [Reduced number of queries when object name case differs accross rollups : Multiple LRE Contexts when rollup definition only differs by case](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/229)
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

If you are a developer obtain the source code from this repository if you wish to develop it further and/or contribute to it. Click the button below to deploy the source code to your developer or sandbox org.

<a href="https://githubsfdeploy.herokuapp.com?owner=afawcett&repo=declarative-lookup-rollup-summaries">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

**KNOWN INSTALL ISSUE** Sometimes the Permission Set files will not deploy, based on org differences, such as features enabled. If you encounter this problem, Clone the repo manually and use your IDE or Ant script to deploy without the Permission Sets. I will be looking into fixing this [issue](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/58) in the future.


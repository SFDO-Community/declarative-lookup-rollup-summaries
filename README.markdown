Declarative Rollups for Lookups!
================================

Features Summary
----------------

- Rollup information between Lookup relationships not previously possible without writing Apex Triggers
- Define rollups using standard UI declaratively, no coding required
- Define filter criteria on rollups for example Rollup Amount on Opportunity onto Account for Closed Won
- Supports Realtime, Scheduled and Developer API modes
- Open source, available in code and managed package form.
- Managed package has passed Salesforce Security Review and is Aloha enabled (does not consume app, tab limits)

Please refer to the blog posts below for more detailed information.

Documentation
-------------

The tool has been feature in a number of blog entries as it has evolved...

- [New Tool : Declarative Rollups for Lookups!](http://andyinthecloud.com/2013/07/07/new-tool-declarative-rollups-for-lookups/) 
- [New Release: Spring’14 Declarative Rollup Summary Tool](http://andyinthecloud.com/2014/02/09/new-release-spring14-declarative-rollup-summary-tool/) 
- [New Release: Declarative Rollup Summary Tool Community Powered!](http://andyinthecloud.com/2014/04/09/new-declarative-rollup-tool-release-community-powered/)
- [Account Hierarchy Rollups #ClicksNotCode](https://github.com/afawcett/declarative-lookup-rollup-summaries)

There is also an early releaes video demonstration here...

<a href="http://www.youtube.com/watch?feature=player_embedded&v=6BST-TpyHHk" target="_blank"><img src="http://img.youtube.com/vi/6BST-TpyHHk/0.jpg" 
width="420" height="315" border="10" /></a>

Usage Information and Known Issues
----------------------------------

- This tool uses [SOQL Aggregate](http://www.salesforce.com/us/developer/docs/apexcode/Content/langCon_apex_SOQL_agg_fns.htm) queries and is subject to [platform limitations](http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_gov_limits.htm). This basically means...
- For each rollup, there is a maximum of 50,000 child relation records that can be summarised each time child record/s insert/update/delete operations are made (which may process several configured rollups). The rollup processes children to rollup by their parent record relationship and an optional further filter if provided. Meaning so long as this relationship does not result in more than 50,000 child records per parent parent record it will be successful. Take a look at the second blog post above which describes some new configuration settings to help calibrate the tool when running the Scheduled or Calculate jobs to help work within the 50,000 row limit.
- For performance reasons ensure the fields used are indexed (lookups are by default) and also any fields used in the filter criteria. This can be very important as without this, a full table scan will occur when the platform executes the SOQL and cause performance issues. For more information from Salesforce please see [here](http://wiki.developerforce.com/page/Best_Practices_for_Deployments_with_Large_Data_Volumes) and [here](http://blogs.developerforce.com/engineering/2013/02/force-com-soql-best-practices-nulls-and-formula-fields.html).
- When using the Realtime mode, Formula fields as fields to aggregate are not supported (validation will be added in a future release to block this). To work around this, either switch to Scheduled mode or in Relatime mode use a Workflow Field Update to copy the formula field value to a physical field and reference that.
- While the tool can be installed and enabled directly in production, sandbox testing is still strongly recommended.

Please feel free to raise feedback and issues via the **Github Issues** page [here](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues).

Packaged Release History
------------------------

You can install a packaged version of the tool into your production org (sandbox testing as always recommended). Check the limatations and known issues above first! 

**Latest - Version 1.10**

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qbz8), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Qbz8)

- Enhancement for [Issue 52 Auto Create Remote Site Setting](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/52)
- Fix for [Issue 25 Error with Manage Child Trigger button for very long object names](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/25)


**Version 1.9 - Community Powered!**

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

Not released

**Version 1.7**

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QYAW), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QYAW)

- Fix for [Issue 14](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/14), relating to null pointer exception

**Version 1.6 - Spring'14 Release - 9th February 2014**

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QRXG), [Sandbox URL](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QRXG)

- Enhancements to support Schedule mode, Calculate historic records, Developer API and more, see [here](http://andyinthecloud.com/2014/02/09/new-release-spring14-declarative-rollup-summary-tool/).
- Fix for [Issue 10](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/10)
- Fix for [Issue 11](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/11)

**Version 1.5**

Package [Production URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QCpr), [Sandbox URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QCpr)

- Fix for [Issue 7](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/7) and [Issue 8](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/8), relating to failure to report test execution errors in production org.

**Version 1.4**

- Fix for [Issue 3](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/4), relating to issue when deleting last child record not updating rollup fields to 0.

**Version 1.3**

- Fix for [Issue 2](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/2), relating to error 'purgeOnDelete option can only be used on a non-active org'

**Version 1.2**

- Support for Realtime calculations
- Validation of valid fields and field types on Declarative Rollup definition fields
- Optimisation during update of child records to only apply rollup when field to aggregate changes
- More extensive unit tests, also those around use of limits such as queries, rows etc.

![Upload](https://raw.githubusercontent.com/afawcett/declarative-lookup-rollup-summaries/master/images/PublisherConsole.png)
![Review Passed](https://raw.githubusercontent.com/afawcett/declarative-lookup-rollup-summaries/master/images/UploadedPackages.png)

**Version Beta 6**

- Support for Realtime calculations
- Limited validation on Declarative Rollup definition fields
- Limited testing on multiple lookups
- Fixed issue with multiple lookups

Installing the Source Code (Developers)
=======================================

If you are a developer obtain the source code from this repository if you wish to develop it further and/or contribute to it. Click [Deploy to Salesforce](https://githubsfdeploy.herokuapp.com/app/githubdeploy/afawcett/declarative-lookup-rollup-summaries) to deploy the source code to your developer org.

**KNOWN INSTALL ISSUE** Sometimes the Permission Set files will not deploy, based on org differences, such as features enabled. If you encounter this problem, Clone the repo manually and use your IDE or Ant script to deploy without the Permission Sets. I will be looking into fixing this [issue](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/58) in the future.


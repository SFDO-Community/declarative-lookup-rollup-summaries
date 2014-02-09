Declarative Rollups for Lookups!
================================

Documentation
-------------

You can read more detailed information about this tool and how to use it at my blog [here](http://andyinthecloud.com/2013/07/07/new-tool-declarative-rollups-for-lookups/) and the latest features in the **Spring'14** release [here](http://andyinthecloud.com/2014/02/09/new-release-spring14-declarative-rollup-summary-tool/). There is also an early releaes video demonstration here...

<a href="http://www.youtube.com/watch?feature=player_embedded&v=6BST-TpyHHk" target="_blank"><img src="http://img.youtube.com/vi/6BST-TpyHHk/0.jpg" 
width="420" height="315" border="10" /></a>


Usage Information and Known Issues
----------------------------------

- This tool uses [SOQL Aggregate](http://www.salesforce.com/us/developer/docs/apexcode/Content/langCon_apex_SOQL_agg_fns.htm) queries and is subject to [platform limitations](http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_gov_limits.htm). This basically means...
- For each rollup, there is a maximum of 50,000 child relation records that can be summarised each time child record/s insert/update/delete operations are made (which may process several configured rollups). The rollup processes children to rollup by their parent record relationship and an optional further filter if provided. Meaning so long as this relationship does not result in more than 50,000 child records per parent parent record it will be successful.
- For performance reasons ensure the fields used are indexed (lookups are by default) and also any fields used in the filter criteria. This can be very important as without this, a full table scan will occur when the platform executes the SOQL and cause performance issues. For more information from Salesforce please see [here](http://wiki.developerforce.com/page/Best_Practices_for_Deployments_with_Large_Data_Volumes) and [here](http://blogs.developerforce.com/engineering/2013/02/force-com-soql-best-practices-nulls-and-formula-fields.html).
- Formula fields as fields to aggregate are not supported (validation will be added in a future release to block this). To work around this, use a Workflow Field Update to copy the formula field value to a physical field and reference that.
- While the tool can be installed and enabled directly in production, sandbox testing is still strongly recommended.

Please feel free to raise feedback and issues via the **Github Issues** page [here](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues).

Packaged Release History
------------------------

You can install a packaged version of the tool into your production org (sandbox testing as always recommended). Check the limatations and known issues above first! If you are a developer obtain the source code from this repository if you wish to develop it further and/or contribute to it. Click [Deploy to Salesforce](https://githubsfdeploy.herokuapp.com/app/githubdeploy/afawcett/declarative-lookup-rollup-summaries) to deploy the source code to your developer org. 

**Latest Version 1.6 - 9th February 2014**

Package [Install URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QRXG)

- Enhancements to support Schedule mode, Calculate historic records, Developer API and more, see [here](http://andyinthecloud.com/2014/02/09/new-release-spring14-declarative-rollup-summary-tool/).
- Fix for [Issue 10](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/10)
- Fix for [Issue 11](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/11)

**Version 1.5**

Package [Install URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000QCpr)

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

**Version Beta 6**

- Support for Realtime calculations
- Limited validation on Declarative Rollup definition fields
- Limited testing on multiple lookups
- Fixed issue with multiple lookups

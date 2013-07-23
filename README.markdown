Declarative Rollups for Lookups!
================================

Documentation
-------------

You can read more information about this tool at my blog [here](http://andyinthecloud.com/2013/07/07/new-tool-declarative-rollup-summaries-for-lookups).

Packaged Release History
------------------------

You can obtain the source code for this tool via this repository.

Alternatively you may install a packaged version of it into your production org (sandbox testing as always recommended).

**Latest Version 1.2**

Package [Install URL](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb0000000Q7ms)

- Support for Realtime calculations
- Validation of valid fields and field types on Declarative Rollup definition fields
- Optimisation during update of child records to only apply rollup when field to aggregate changes
- More extensive unit tests, also those around use of limits such as queries, rows etc.

**Version Beta 6**

- Support for Realtime calculations
- Limited validation on Declarative Rollup definition fields
- Limited testing on multiple lookups
- Fixed issue with multiple lookups

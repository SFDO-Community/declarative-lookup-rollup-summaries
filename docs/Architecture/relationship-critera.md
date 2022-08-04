---
layout: default
title: Relationship Criteria (SOQL Queries)
nav_order: 2
parent: Architecture
has_children: false
---

Needs Content
{: .label .label-yellow }

# How to Construct Relationship Criteria (SOQL Queries)

(This page is under construction)
You can write any where clause that's valid into the tool. A good way to play around with how to create multiple criteria is to use the Query tool in the Workbench (https://workbench.developerforce.com/query.php). You'll see a section called "Filter results by:" where you can create some conditions and see the WHERE clause that's generated from that.

#Multiple Parameters

## AND

The following criteria would be valid:
StageName='Closed Won' AND RecordTypeId= 'XXXXXXXXXXXXXXXX'
You would need to include StageName and RecordTypeId in the fields list.

related issue #41

## OR

Make sure to wrap the query with parenthesis:

`(CRITERIA1 OR Criteria2)`

related issue #138

#Date Literals
Date literals can be used but are tricky, because as time advances the trigger will not know to re-evaluate the rollup unless the child record changes.

You can read about [SOQL Date and Date Literal formats](http://www.salesforce.com/us/developer/docs/officetoolkit/Content/sforce_api_calls_soql_select_dateformats.htm).

## Examples:

- `Invoice_Date__c = LAST_N_DAYS:365`
- `Invoice_Date__c = THIS_YEAR`
- `Invoice_Date__c = THIS_QUARTER`

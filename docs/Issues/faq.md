---
layout: default
title: FAQ
nav_order: 1
parent: Issues/FAQ
has_children: false
---

Needs Content
{: .label .label-red }

# Frequent Asked Questions

## Why do I need to allow Metadata API in remote site settings?

To **configure** rollups with this tool your user needs a connection and permissions to the **Salesforce Metadata API**. The **Welcome** tab for the tool provides a check for this and help guide through the configuration required. If your org is using **My Domain** you will have a much easier time and no Remote Site setting will be required. Regardless though your user will need the following permissions.

- API Access
- Metadata API Access or Modify All Data
- Author Apex (needed to use Manage Child Triggers button)
- Customize Application (needed to use Manage Rollup Summaries tab to update Custom Metadata)

**Note:** The above are powerful permissions [please review fully before enabling](https://help.salesforce.com/articleView?id=000198725&r=https:%2F%2Fwww.google.com%2F&type=1) - typically these are enabled for Admin users.

**Known Issues**

- Release v2.12 Welcome tab incorrectly stated in some cases the Remote Site was created when it was not
- Starting with v2.13 of the Welcome tab has been fixed and enhanced to improve the setup experience
- Session based IP restrictions can interfere with the tool, see [here](https://github.com/afawcett/declarative-lookup-rollup-summaries#usage-information-and-known-issues).

## Why did I recieve a warning that "Lookup Rollup Summary Logs Exist?

**What is this?**

Rollups that have [Calculation Mode set to Scheduled](https://github.com/afawcett/declarative-lookup-rollup-summaries/wiki/What-you-need-to-know-about-Scheduling-Rollups) generate logs when failures occur.

**What do I do?**

This warning lets you know that you have some log entries to view for failed parent record updates. Once you address the issues the logs should be removed the next time the scheduled job runs. Or if you prefer you can delete them yourself. Go to the **Lookup Rollup Summary Logs** tab to view them.

## How do I optimize DLRS? I am running into Apex CPU Limits or other performance issues!

DLRS gives you many options for controlling how it runs. It can run in realtime synchronously from a DLRS Trigger, your own Trigger, or Process Builder. It can also be run asynchronously with it's [Scheduled Incremental Mode or Scheduled Full Calculate Mode](https://github.com/afawcett/declarative-lookup-rollup-summaries/wiki/What-you-need-to-know-about-Scheduling-Rollups). Additionally you can use Process Builder and a Scheduled Action with a delay such as `0 Hours from now` which will happen typically within a few minutes.

Strongly consider whether you need DLRS to run in realtime or not. Also consider whether you want to deploy the DLRS trigger or call the DLRS Trigger Handler from your own trigger framework. Consider calling `dlrs.RollupService.triggerHandler()` directly.

## How do you get OR to work in the Relationship Criteria?

Make sure to wrap the query with parenthesis:

`(CRITERIA1 OR Criteria2)`

related issue [#138](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/138)

## How do I know if my scheduled Calculation Mode is working?

- Make sure your trigger is deployed and you can manually run your summary with the Calculate button
- Make sure you see the Related List: Lookup Rollup Summary Schedule Items at the bottom of your Summary
- Go and manually edit a child record's Relationship Field or any Relationship Criteria field and save the record
- Now you should see a record listed in the Lookup Rollup Summary Schedule Items list
- Let your schedule run
- Check Recent Lookup Rollup Summary Logs
- Check Setup > Jobs > Scheduled Jobs & Apex Jobs

## Why am I recieving this error "System.LimitException: dlrs:Too many query rows: 50001"

DLRS usually queries from the perspective of the parents, retrieving all of the child records that match the given criteria. If the parents in a given batch have an average of 250 (50,000 / 200) children, have many DLRS jobs configured, or have lots of cascading rollups (rollup from grandchild to parent to grandparent) then DLRS can easily request a total of >50,000 records in the given transaction.

If this is happening during a scheduled calculation or a full calculation batch job then you can adjust the batch size in the Declarative Lookup Rollup Summaries hierarchy custom setting. It defaults to 200.

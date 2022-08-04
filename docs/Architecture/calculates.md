---
layout: default
title: DLRS Calculation
nav_order: 1
parent: Architecture
has_children: false
---

# Understanding when DLRS Calculates

Understanding when DLRS calculates and how to set your rollups for most effective use is not as simple as it might seem at first glance. In fact, I was misunderstanding some of the finer distinctions for several years. Therefore, I present this summary to help the community:

There are three main settings that you should understand:

- Realtime
- Scheduled
- Full Calculate

Though their names may seem self-explanatory, please read below for some important detail.

**Realtime** means that as soon as a child record is created or updated the rollup will run on save. (Technically, it will only run if the fields listed in the Field to Aggregate or Criteria fields of the rollup are edited.) This is triggered by an Apex trigger that DLRS installs on the child object. Setting a DLRS to Realtime reduces Salesforce performance, as every update to a child record causes the DLRS to run. But the hit is usually small and in many cases it makes sense to have instantaneous monitoring of data. For example, it might be confusing for users if you have a rollup counting Tasks as you work an Opportunity that doesn't immediately update the count on the parent Opportunity as soon as you log your call. Realtime can be a wider performance danger if it runs in a context with other automations, such as Flow or Process Builder, which could result in looping automations and eventually hit Salesforce governor limits.
To set a rollup to realtime, you must deploy the child trigger. The Calculation Mode picker is set to Realtime.

**Scheduled** rollups do not run instantly. A trigger installed by DLRS makes note of each child record that gets changed and stores it in the Lookup Rollup Summary Schedule Items object. Then whenever the Apex Class "RollupJob" runs all of those items are taken care of and then the Schedule Item deleted. Scheduling RollupJob must be accomplished outside of the DLRS app. Go to Setup>Custom Code>Apex Classes and click Schedule Apex. You can actually do this multiple times, setting the RollupJob class to run, for example, at 9am, noon, 3pm, and 6pm. That would ensure that your rollups are never more than three hours stale during the workday.
If you want to monitor the status of rollups, it's easy to make a report of Lookup Rollup Summary Schedule Items and make sure that there are few records (or none) sitting and waiting to calculate.
To set a DLRS to Scheduled, you must deploy the child trigger. The Calculation Mode picker is set to Scheduled.

**Full Calculate** is when DLRS loops through every existing child record and does the rollup to the parent, regardless of whether the child record has been edited or not. Within the DLRS app you can start this going by clicking the Full Calculate button. This is often something you want to run when you create a new rollup, for example. You can also schedule this to happen regularly using the Schedule Full Calculate button right within the DLRS. (It's like clicking the Full Calculate button, but you don't have to actually go to it.) Because a Full Calculate runs on every record it uses server resources and can take some time. More importantly, if a full calculate runs during the workday on a large number of records it could result in "row lock" errors--when the calculation and a user are both trying to edit the same record at the same time. The main use case for a scheduled full calculate is for rollups that have a relative time filter (like "Last Week"), because the move from this week to next week is not an edit to a record, so it won't trigger a Scheduled rollup. You want to set this type of rollup to be fully calculated once a week (or once a day) to account for the movement in time. Generally scheduled Full Calculates make sense to run in the wee hours of the night, when server capacity is idle and row lock conflicts are unlikely. If you have rollups for Opportunities that refer to "last fiscal year," these need to run at least monthly to make sure they roll over when the fiscal year changes.
For only Full Calculate, whether once or scheduled, no child trigger is required. The Calculation Mode picker is set to Process Builder. (Even though you might not be using a Process Builder to trigger the rollups, this setting makes it possible for you to save and activate your Full Calculate rollup.)

# What you need to know about Scheduling Rollups

## Scheduling Options

Depending on your needs there are three ways to schedule, please read carefully.

- **Scheduled Full Calculate**, also know as **Schedule Calculate** is just setting up automation to press the Calculate button for you
- **Scheduled Incremental Calculate**, also known as **Calculation Mode - Schedule** is to have DLRS not run in realtime but in batches based on when you run an Apex job.
- **Process Builder - Scheduled Action**, is to have Process Builder call a specific rollup in a Scheduled Action

## IMPORTANT NOTE

When using the **Schedule Full Calculate** option below, you **DO
NOT** need an Apex Trigger, but it's perfectly fine to still use one
(required for the Scheduled or Realtime calculation modes). If you
want to run full recalculations without a trigger, you can set the
**Calculate Mode field** to **Process Builder** or **Developer** (you
do not have to use the rollup from Process Builder or from Apex code).
This allows you to Activate the rollup without requiring an Apex
Trigger to be deployed. As mentioned before, it's OK to use Scheduled
or Realtime modes and also have full recalculations running on a
schedule, just make sure that if you are using Scheduled mode you
schedule the RollupJob Apex class, as described below.

# Scheduled Incremental Calculate

**Calculation Mode field set to Schedule, Trigger Required**
In place of DLRS record running in realtime when a record is edited that would normally trigger that DLRS to fire it will create a record and queue it up. That queue will not process until you manually go and set up an apex job for the ApexClass "**RollupJob**" to run. This can be done by going to Setup > Develop > Apex Classes and click Schedule Apex. When RollupJob runs it will process all DLRS records that are active with Calculation Mode set to Schedule. There is no way to control the order that this fires if you have 3 DLRS records set up in Calculation Mode - Schedule it might one time run a/b/c and next time run b/c/a. As it completes the queue it will remove the records from the Lookup Rollup Summary Schedule Items. When these fail they fail silently and logs are posted to Lookup Rollup Summary Logs Object.

**Failures:** If updates to the parent records fail they will be retried the next time the job runs. Or in other words queued parent record updates items remain on the queue until the parent is successfully updated. Check Lookup Rollup Summary Schedule Items and Lookup Rollup Summary Log for errors regularly (both are cleared when parent records update successfully). This is [a good blog for automating monitoring](https://www.dandonin.com/2017/05/24/automated-error-alerts-and-mass-delete-error-records/).

# Scheduled Full Calculate

**Calculate Mode field set to Process Builder, No Trigger Required**
This is like pressing the "Calculate" button. It does an entire recalculation of the parent object. This allows you to set up a schedule to it so you don't have to remember to come in and press it on a set timeline. It does allow you to set up a WHERE on the parent so it doesn't scan the entire parent object if you don't need it to. This is unique to EACH dlrs record. So you need to set it up on EACH dlrs record you want to recalculate on a schedule. This is mostly used when you have Date/Time variables used in your relationship criteria as once the date/time passes the record might not be edited but you want the rollup data to be recalculated to show the correct new value. Note you **DO NOT** need schedule the RollupJob yourself in this mode. Note that the class **RollupCalculateJobSchedulable** is scheduled by this button for you.

**Failures:** If updates to the parent records fail they will only be retried when the next full calculate runs again. Failures are stored in Lookup Rollup Summary Log, check this regularly. Log records are cleared once parent records are updated. This is [a good blog for automating monitoring](https://www.dandonin.com/2017/05/24/automated-error-alerts-and-mass-delete-error-records/).

# Process Builder - Scheduled Actions

**Calculate Mode field set to Process Builder, No Trigger Required**
You can use Process Builder with a Scheduled Action, instead of an Immediate Action, and control the delay in processing. It will call the Parent account and recalculate the specified rollup. Create a `Call Apex` action in Process Builder and select the DLRS `Calculates a rollup` class.

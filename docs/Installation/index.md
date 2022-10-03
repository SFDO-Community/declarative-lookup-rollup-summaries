---
layout: default
title: Installation
nav_order: 2
has_children: true
---

# Installation

Install the latest version of DLRS into your production, sandbox, or scratch org via :
<br/><br/>
[Salesforce.org MetaDeploy](https://install.salesforce.org/products/dlrs/latest){: .btn .btn-blue }
<br/>

Here is the App and Objects that are installed. You can see there are two permission sets that can be used to give access.
![Installed Components](https://raw.githubusercontent.com/wiki/afawcett/declarative-lookup-rollup-summaries/images/InstalledComponents.PNG)

## Permissions

You can install the package for Admins only and open up permissions for all users/profiles with the options below or install for all users.

![Install for Admins](https://raw.githubusercontent.com/wiki/afawcett/declarative-lookup-rollup-summaries/images/Install-Admins-Only.PNG)

There are two types of DLRS Users:

### Admin

Kind of a tool admin user that both configures and activates the rollups (this has to be an admin to deploy and manage the trigger for example). This user also needs full read/write access to all the objects in the package.

### User

Then there is the users that don't directly use the tool, but indirectly invoke its rollups. These users need read access to all the objects in the package. You don't however need to give them access to the app, tabs or Visualforce pages for example since they don't need to be able to access the tools admin UI.

### Assigning Permissions

- You can click on Permission itself **Lookup Rollup Summaries - Process Rollups** and there is a button **Manage Assignments**. From the page that is displayed you can create a List View to filter for the users you want, tick them and click **Add Assignments**.
  ![Process Rollups Permission Set](https://raw.githubusercontent.com/wiki/afawcett/declarative-lookup-rollup-summaries/images/Process-Rollups.PNG)
- You can update a **Profile** by giving **Read** access to the following objects, **Lookup Rollup Summaries**, **Lookup Rollup Summary Logs** and **Lookup Rollup Summary Schedule Items**.
- Finally, if you didn't find the first option useful enough, you may want can try out the free The Permissioner tool on [AppExchange](https://appexchange.salesforce.com/listingDetail?listingId=a0N30000008XYMlEAO).

You can also [Read the Salesforce documentation on installing and permissions](https://developer.salesforce.com/docs/atlas.en-us.packagingGuide.meta/packagingGuide/packaging_install.htm)

## Professional Edition

It is now possible to install the managed package in a Lightning Professional Edition and configure entries to trigger Process Builder to action the declarative roll up summary. (per [341](https://github.com/afawcett/declarative-lookup-rollup-summaries/issues/341))

![Process Builder Sharing Mode](https://raw.githubusercontent.com/wiki/afawcett/declarative-lookup-rollup-summaries/images/Process-Builder-Sharing-Mode.PNG)

# Creating a New Lookup Rollup Summary

![Manage Lookup Rollups Screen](https://raw.githubusercontent.com/wiki/afawcett/declarative-lookup-rollup-summaries/images/Manage-Lookups.PNG)

## Lookup Relationship

### Parent Object

Enter the API name of the object in salesforce.com that you want the rollup summary to be stored on

### Child Object

Enter the API name of the object that you want to query and rollup to the Parent Object

### Relationship Field

Enter the API name of the lookup field on the Child Object relating to the Parent Object

### Relationship Criteria (Optional)

If you would like to filter the Child Object records that get summarized enter the SOQL WHERE query here.

e.g. `Amount > 200 AND Stage = 'Closed Won'`

[Examples & Details](<https://github.com/afawcett/declarative-lookup-rollup-summaries/wiki/Relationship-Criteria-(SOQL-Queries)>)

### Relationship Criteria Fields

Any field used in the Relationship Criteria needs to be entered here, one field per line
e.g.

```
Amount
Stage
```

NOTE: If you are referencing Recordtype.Name or Recordtype.DeveloperName in your WHERE clause, exclude them from the Relationship Criteria Fields, because it will throw an error.

## Rollup Details

### Field to Aggregate

This is the API name of the field on the child record

### Field to Order By

This is useful if you are concatenating

### Aggregate Operation

### Aggregate Result Field

Where on the Parent to place/write the result

### Active

Must be set to Active to Calculate manually now or to set as Realtime. In order to set as Active you must deploy the child trigger.

### Calculation Mode

Choose your calculation mode carefully. **Using realtime can run into performance issues and Apex CPU limits.** See [Scheduling](https://github.com/afawcett/declarative-lookup-rollup-summaries/wiki/What-you-need-to-know-about-Scheduling-Rollups) and [Performance Issues FAQ](https://github.com/afawcett/declarative-lookup-rollup-summaries/wiki/FAQs#how-do-i-optimize-dlrs-i-am-running-into-apex-cpu-limits-or-other-performance-issues)

Using Scheduled Incremental Calculation or using Process Builder with a Scheduled Action are good ways to avoid issues.

- Scheduled
  - Run a full or incremental calculate on a schedule with Scheduled Apex
- Process Builder
  - Call the DLRS Apex Action from a Process builder either as an immediate or scheduled action
- Realtime
  - Uses the child trigger to immediately calculate rollups
- Developer
  - Allows you to call DLRS from your own apex without using the DLRS trigger

### Calculation Sharing Mode

Calculation Sharing Mode determines whether Salesforce sharing configurations should be taken into account when the rollup calculates. **User** mode will calculate all records visible to the user who triggered the rollup calculation. **System** mode will calculate all records regardless of the current User’s access.
---
layout: default
title: Getting Started
nav_order: 1
has_children: false
---

[Join the DLRS Trailblaizer Community - Today!](https://trailhead.salesforce.com/trailblazer-community/groups/0F9300000009O5pCAE){: .btn .btn-green }

# What is Declarative Lookup Rollup Summaries?

DLRS is a mechanism for aggregating or summarizing data from child objects and displaying it on a parent object. It serves the same purpose as Rollup Summary fields, but it is much more flexible with the kind of data that can be rolled up and how criteria are formed.

## What business problems does DLRS solve?

In Salesforce, there are “Rollup Summary Fields” that exist as standard fields in your instance and allow you to calculate metrics on a related list record (child object) and then show that value on the parent object. The business problem solved here is generally the ability to create a key metric or “summary” of a calculated value on a field in your Salesforce instance. Some examples may be Total Closed Won Amount.

There is a limit to how many “RUS” fields that Salesforce permits you to create. With DLRS - there is no such limit - you can create as many of them as needed.

Additionally - the metrics available with RUS fields - are limited to sum, minimum value, or maximum value as a calculated metric. There are extended “Operations” that can be performed with DLRS.

## Features Summary

- Rollup information between Lookup relationships not previously possible without writing Apex Triggers
- Define rollups using standard UI declaratively, no coding required
- Define filter criteria on rollups for example Rollup Amount on Opportunity onto Account for Closed Won
- Supports Realtime, Scheduled and Developer API modes
- Open source, available in code and managed package form.
- Managed package has passed Salesforce Security Review and is Aloha enabled
- Supports Custom Metadata, rollups can be included in Change Sets and Packages for easier deployment

## DLRS Misconceptions

- Real-time trigger - Set Lookup Rollup to `Realtime` Calculation Mode. [Info](https://sfenton3.github.io/DLRS-Github-Pages/Architecture/calculates.html)
- Invocable from Flow or Process Builder - This is what allows DLRS to run in Professional Edition. [Info](https://sfenton3.github.io/DLRS-Github-Pages/Installation/configuration.html#implementation-considerations)
- Scheduled full calculations - There is a button to schedule full calculations. [Info](https://sfenton3.github.io/DLRS-Github-Pages/Architecture/calculates.html)
- Async trigger based calculations - This is a feature of `Scheduled` Calculation Mode. [Info](https://sfenton3.github.io/DLRS-Github-Pages/Architecture/calculates.html)

## Follow the DLRS Journey

<br/>
**NOTE:** The links are in chronological order, if your new to the tool, read from the bottom upwards

- [Declarative Rollup Summary Tool Update for v2.12](https://andyinthecloud.com/2020/04/05/declarative-rollup-summary-tool-update/)
- [Salesforce Rollup Summary on Lookup Relationship - DLRS Tutorial](https://www.youtube.com/watch?v=sjRlou2-N6I&feature=youtu.be)
- [Monitoring your Scheduled Rollups via Report Subscriptions](https://www.dandonin.com/2017/05/24/automated-error-alerts-and-mass-delete-error-records/)
- [Counting Tasks with DLRS](https://www.dandonin.com/2017/04/21/counting-tasks-with-dlrs/)
- [Getting Started With DLRS](https://www.dandonin.com/2017/03/16/how-to-dlrs/)
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

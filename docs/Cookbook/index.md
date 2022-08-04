---
layout: default
title: Cookbook
nav_order: 3
has_children: true
---

# How to Use This Cookbook

In this section you’ll find a collection of examples of how DLRS has been used to summarize data for common use cases.

Just like a “kitchen” cookbook, we’ve laid out the ingredients and the steps you need to follow to make these rollup summaries for yourself. These rollup “recipes” have been tried and tested in Salesforce instances, and are shared here to provide inspiration for other users.

The introduction below explains how the recipes are laid out, and the examples are grouped in sections around similar issues - see the links in the navigation sidebar. We hope you’ll find these helpful for your work!

The DLRS Cookbook was started at an Open Source Community Sprint in October 2021 by a group of seasoned DLRS users who wanted to share examples of rollups that have worked well for them. This is just the beginning of the collection: please help us to expand the range of examples by contributing a recipe of your own, using this form (link to Google Form or contribution page).

## Read the whole recipe

You can use the name and description of each recipe to decide if it will work for you, but please read the whole recipe before you try it out. Our template provides the information for each field and setting of a Lookup Rollup Summary (see the detailed list below). All recipes have been contributed by users of DLRS, and edited by our volunteer team, but we can’t guarantee that they will work perfectly in every organization. Please read the details carefully, and ask in the [Trailblazer Community](https://trailhead.salesforce.com/trailblazer-community/groups/0F9300000009O5pCAE?tab=discussion) if you have any questions.

## Prepare your ingredients

- Create a new target field on the Parent object to display the results of your summary.
- Know the name of the relationship field between the two objects. You might even need to create the relationship if either the child or parent is a custom object.
- Remember that you need the API name of both fields and objects to create a rollup. Custom field and object names end in `__c`
- Think about naming conventions. We suggest that you name your roll-ups based on the parent object with a convention of Object.Action.Name of Target Field (example: Opportunity: Sum of Paid Payments This FY)
- For your target fields, one option is to start all API names with `DLRS_` so that it is clear these are fields that DLRS is going to fill. [If the field itself will not show up on page layouts, you can have `DLRS_` in the label as well, but this is obviously problematic if the label will be seen, so you will probably want to do this for the names only.]
- Name as Text: when your result is also a lookup field, you might need to create a custom formula field to show the name of the lookup record as text, otherwise your result will display a Salesforce Record Id (example: rollup of Primary Campaign Source from an Opportunity needs a formula field that gives you the Campaign Name).

## Know your SOQL

If your rollups are going to have any kind of filter on the child records, you will need to express that filter as a SOQL query. Start learning about SOQL [here on Trailhead](https://trailhead.salesforce.com/en/content/learn/modules/soql-for-admins). [Workbench](https://workbench.developerforce.com/login.php) also has a SOQL query builder. In particular, relative dates in SOQL queries can be difficult to remember:

- [Relative Dates (Salesforce Help)](https://help.salesforce.com/s/articleView?language=en_US&id=filter_dates_relative.htm)
- [About Relative Dates](https://admin.salesforce.com/blog/2019/five-things-salesforce-admins-can-do-with-relative-dates)

We provide examples of SOQL queries with our recipes to give you a starting point.

## Consider schedules and triggers to determine “doneness”

It’s important to understand the different Calculation Modes and the use of the DLRS Full Calculate Scheduler (see [this link](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/wiki/Understanding-When-DLRS-Calculates))

- The Calculation Mode picklist offers Realtime, Scheduled, Process Builder, and Developer modes.
  - “Realtime”: this setting requires deployment of the child trigger and will run your rollups whenever a child record is saved.
  - “Scheduled”: this setting will create helper records when a child record is saved and then those will all be processed when the Apex job RollupJob runs. You must manually set this job to run or no rollups will calculate!
  - Process Builder and Developer modes allow you to cause the rollups to calculate using automation, so you can avoid deploying the child trigger.
- The Schedule Full Calculate button (at the top of a saved rollup) allows you to schedule your rollups to run (nightly, monthly, etc.) This is known as “Using the DLRS Scheduler” as opposed to being set in “Scheduled” mode. You can use this action with Process Builder or Developer Calculation Mode, without needing automation to launch the rollup.

## Sample the variations

Often rollup summaries come in pairs, or groups: for example, if you calculate the first value you’ll probably also need the last or most recent. If you count the number of child records, you may also want to total the amounts, or find the largest or average amount. With our recipes, we’ve given you the basic template, and then suggested variations, where the ingredients will be almost the same, except perhaps the action or the target field. You can clone Lookup Rollup Summaries in the Custom Metadata Settings, and make adjustments to set up your variations quickly and easily.

## Share your results!

Please share your culinary creations! We hope to keep adding to this resource, so please send us your feedback and let us know if you have new [recipe ideas](https://sfenton3.github.io/DLRS-Github-Pages/About%20Us%20&%20Contribution/cookbook). You’ll find us in the [DLRS Trailblazer Community group](https://trailhead.salesforce.com/trailblazer-community/groups/0F9300000009O5pCAE?tab=discussion).

# How to Read our Template

- **Page:** We’ve grouped similar recipes together on separate pages. A page will be either a topic, a package or a parent object.

- **Suggested Rollup Name:** We’ve suggested a name for the rollup based on the naming convention we mentioned in the Prepare Your Ingredients section.

- **Description:** This is a brief summary of what the rollup summary does and a use case, to help you decide if it’s helpful to you.

- **Objects, Fields, Relationships:** If the rollup uses custom fields and objects, there will be more detail here.

- **Parent Object:** The object where the target field will be, with the result of your rollup summary.

- **Child Object:** The object with the records that you are counting or calculating from.

- **Relationship Field:** The (lookup) field that links the two objects.

- **Relationship Criteria (SOQL Query):** The criteria that you’ll use on the child object records to use only some of them in your calculation.

- **Relationship Criteria Fields:** The fields included in the criteria. If you list them here, it helps the rollup summary calculation to run a bit faster (it’s like drawing attention to them).

- **Field to Aggregate:** The field that you are counting or totaling in your calculation. For a straightforward count, you’ll use the record Id.

- **Field to Order By:** When calculating a first or last value, or concatenating several values, you’ll need to tell the rollup summary the order in which to review the records (example: Close Date or Created Date).

- **Aggregate Operation:** Options here are Count, Count Distinct, Sum, Average, Min, Max, First, Last, Concatenate and Concatenate Distinct (for more details about what each option does, see here: https://dandonin.com/2017/03/16/how-to-dlrs/)

- **Aggregate Result Field:** The target field on your parent object where the results will be displayed.

- **Calculation Mode:** Options are: Realtime, Scheduled, Process Builder, Developer (see the Consider schedules and triggers to determine “doneness” section for more details)

- **Schedule vs Child Trigger:** Refers to the actions to deploy the Child Trigger or use the Schedule Full Calculate option (see the Consider schedules and triggers to determine “doneness” section for more details)

- **Preparation:** Gives you more information about the ingredients, or if you need test code to avoid rollup errors.

- **Variations:** Ways that you can adjust the recipe to get other similar results (example: get the last or most recent date of an event as well as the first date).

- **See also:** Links to similar recipes elsewhere in the cookbook.

### Credits

> Thanks to the top chefs/editing team for their time and commitment to this project: especially _Marc Baizman_, _Michael Kolodner_, _Jodi Nemster-Abrahams_, _Jillian Nii_, _Caroline Renard_, _Rachel Sinex_, _Amanda Styles_ and _Kathy Waterworth_.
>
> Tip of the hat to _Ruth Mar Tam_ for the inspiration of the headings from her wonderful [Baked to Order Cookbook](https://cooktildelicious.com/baked-to-order-cookbook/)
>
> Tip of the hat to _Andrew Adamyk_ for his Markdown conversion help.

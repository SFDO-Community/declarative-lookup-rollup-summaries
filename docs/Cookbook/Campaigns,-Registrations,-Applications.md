---
layout: default
title: Campaigns, Registrations, Applications
parent: Cookbook
nav_order: 2
---

# Contact: Count Campaign Memberships

**Description**

> Counts the number of campaigns a contact has been involved in. This is not possible with a standard rollup summary field because you can't create one on Contact record to summarize Campaign Member records.

**Objects, Fields, Relationships**

| Fields                             | Description                   |
| ---------------------------------- | ----------------------------- |
| Parent Object                      | `Contact`                     |
| Child Object                       | `CampaignMember`              |
| Relationship Field                 | `ContactId`                   |
| Relationship Criteria (SOQL Query) | n/a                           |
| Relationship Criteria Fields       | n/a                           |
| Field to Aggregate                 | `Id`                          |
| Order By Field                     | n/a                           |
| Aggregate Operation                | `COUNT`                       |
| Aggregate Result Field             | `DLRS_CampaignMemberships__c` |
| Calculation Mode                   | `Realtime`                    |
| Schedule vs Child Trigger          | `Child Trigger deployed`      |

**Variations**

- You could count only the number of "responded" statuses using SOQL criteria "HasResponded = true"
- If your org standardizes campaign member status options, you could also make counts of memberships in various statuses.
- You could also count specific types of Campaigns, by adding criteria for Campaign Type.

**Contributed By**
Michael Kolodner, [Kolodner.com](https://kolodner.com/)

<!-- Edited by Kathy Waterworth 05/05/2022 -->

# Contact: Campaign of First Donation

**Description**

> This rollup example uses the Nonprofit Success Pack (NPSP), which has a primary campaign source and a primary contact on each opportunity. Rolling up the Campaign (used for the appeal) on a contact’s first donation tells us which appeal they first responded to with a donation.

**Objects, Fields, Relationships**

|                     Field | Value                                                                                                                                                                                        |
| ------------------------: | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|             Parent Object | `Contact`                                                                                                                                                                                    |
|              Child Object | `Opportunity`                                                                                                                                                                                |
|        Relationship Field | `Primary Contact`                                                                                                                                                                            |
|     Relationship Criteria | None                                                                                                                                                                                         |
|        Field to Aggregate | `CampaignID`                                                                                                                                                                                 |
|         Field to Order By | `CloseDate`                                                                                                                                                                                  |
|       Aggregate Operation | `First`                                                                                                                                                                                      |
|    Aggregate Result Field | `DLRS_First_Campaign_Supported__c`                                                                                                                                                           |
|          Calculation Mode | Scheduled                                                                                                                                                                                    |
| Schedule vs Child Trigger | Deploy the Child Trigger, and since this is unlikely to be urgent and would not change after creation, this roll-up is a good fit for scheduling to run with the DLRS calculation scheduler. |

**Preparation**

> As currently written, you’d see the Campaign Id rather than the name in the result field, so you might want to create an additional text formula field on Opportunity to show the Campaign Name, and aggregate that field instead. (You can display this field in related lists, and use as an email merge field too, so it’s helpful to have anyway!)

**Variations**

- Identify the campaign for a contact’s most recent gift. All you would need to do is change the Action to Last.

- Show the first or last Campaign on Account instead, using Account as the relationship field.

**Contributed by** Amanda Styles, [Traction on Demand](https://www.tractionondemand.com/)

# Account: First Event Purchased Date

**Description**

> Rolls up the date of the first event that someone in a household has purchased a ticket for. The ticket record must be active, and the amount paid for the ticket must be greater than $0. This version is specifically for _PatronManager_ users, and summarizes custom Ticket Order Item records, but you could use it for any custom objects that represent tickets or registrations.

**Objects, Fields, Relationships**

|                              Field | Value                                                                                                                                                                                                                                                  |
| ---------------------------------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
|                      Parent Object | `Account`                                                                                                                                                                                                                                              |
|                       Child Object | `PatronTicket__TicketOrderItem__c`                                                                                                                                                                                                                     |
|                 Relationship Field | `PatronTicket__Account__c`                                                                                                                                                                                                                             |
| Relationship Criteria (SOQL Query) | `PatronTicket__Status__c = 'Active' AND PatronTicket__EffectiveTicketPrice__c > 0`                                                                                                                                                                     |
|       Relationship Criteria Fields | `PatronTicket__Status__c` `PatronTicket__EffectiveTicketPrice__c`                                                                                                                                                                                      |
|                 Field to Aggregate | `Event_Instance_As_Date__c`                                                                                                                                                                                                                            |
|                     Order By Field | n/a                                                                                                                                                                                                                                                    |
|                Aggregate Operation | `MIN`                                                                                                                                                                                                                                                  |
|             Aggregate Result Field | `DLRS_First_Purchased_Event_Date__c`                                                                                                                                                                                                                   |
|                   Calculation Mode | `Process Builder`                                                                                                                                                                                                                                      |
|          Schedule vs Child Trigger | Run on a schedule every morning at 5am, and don’t deploy the Child Trigger (since there are a lot of other triggers involved in a ticket purchase). It seems to be fine to have this field updated once a day, as it is mostly used in annual reports. |

**Preparation**

> As the Event object comes with only a Date/Time field, I added a formula to show the value just as a Date field for the field that is summarized.

**Variations**

- The Last (or Most Recent) Event Purchased Date - same thing, only with a `Max` action and a different target field.

- Rollup on `Contact` instead of `Account`. Substitute the parent object with Contact, and adjust the relationship and target fields.

**Contributed by** Caroline Renard, [Data Geeks Lab](https://www.datageekslab.com)

# Contact: Current Program Engagement Status

**Description**

> Shows the current status of a program engagement (or any object that may have an open and closed option). Multiple other use cases for this rollup as this function will work with any field.

**Objects, Fields, Relationships**

| Fields                             | Description                              |
| ---------------------------------- | ---------------------------------------- |
| Parent Object                      | `Contact`                                |
| Child Object                       | `Program_Engagement__c`                  |
| Relationship Field                 | `Member__c` (this is the contact lookup) |
| Relationship Criteria (SOQL Query) | n/a                                      |
| Relationship Criteria Fields       | n/a                                      |
| Field to Aggregate                 | `Intake_Status__c`                       |
| Order By Field                     | `CreatedDate`                            |
| Aggregate Operation                | `LAST`                                   |
| Aggregate Result Field             | `Current_PE_Status__c`                   |
| Calculation Mode                   | `Realtime`                               |
| Schedule vs Child Trigger          | `Child Trigger deployed`                 |

**Preparation**

> I have also scheduled the rollup to run nightly if a child record was deleted for some reason.

**Variations**

- Multiple use cases when you want to display the first or last of something on the main contact page (or any other parent page), helps with ease of reporting and having some check and balances as well as adding guardrails into automation or new record creation, etc

**Contributed By**
Heath Parks, [North Peak Solutions](https://www.northpeak.com/)

<!-- Kathy Waterworth 05/05/2022  Email: heath.parks@northpeak.com -->

# Contact: List of Years Engaged in Programs

**Description**

> Rollup that displays the calendar year(s) in which a person engaged in services. For organizations that offer long term programs, people often engage and disengage, so this rollup shows in which years a person engaged with the services. But this could be applied to any situation where a constituent engages on a yearly basis.
>
> A pre-work for this is to create a custom formula text field on the child object to display the value of the calendar (or fiscal) year from the engagement date field.

**Objects, Fields, Relationships**

| Fields                             | Description                                      |
| ---------------------------------- | ------------------------------------------------ |
| Parent Object                      | `Contact`                                        |
| Child Object                       | `Program_Engagement__c`                          |
| Relationship Field                 | `Member__c` (this is the contact lookup)         |
| Relationship Criteria (SOQL Query) | n/a                                              |
| Relationship Criteria Fields       | n/a                                              |
| Field to Aggregate                 | `Engagement_Year__c`                             |
| Order By Field                     | `Engagement_Date__c`                             |
| Aggregate Operation                | `CONCATENATE DISTINCT`                           |
| Aggregate Result Field             | `DLRS_Engagement_Year_s__c`                      |
| Concatenate Delimiter              | comma “,” or semicolon “;” to separate the years |
| Calculation Mode                   | `Realtime or Process Bulder`                     |
| Schedule vs Child Trigger          | `Child Trigger deployed for Realtime`            |

**Preparation**

> You will need a custom text formula to extract the year from the application date or service engagement date on the child object.
>
> You will also need to use the Concatenate Delimiter field and use “,” or “; “ to separate each year.

**Variations**

- This can be used in any situation where you want to roll up and display multiple text values from a child object.
- This rollup would work well as a nightly or even weekly scheduled calculation, as well as in realtime.

**Contributed By**
Heath Parks, [North Peak Solutions](https://www.northpeak.com/)

<!-- Edited by Jillian Nii 05/05/2022 -->

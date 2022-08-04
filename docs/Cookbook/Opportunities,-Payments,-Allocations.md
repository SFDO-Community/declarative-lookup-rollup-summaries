---
layout: default
title: Opportunities, Payments, Allocations
parent: Cookbook
nav_order: 4
---

# Opportunity: Sum of Paid Payments This Financial Year

**Description**

> Rollup all child payment records for an Opportunity if the Payment Status is "Paid" and the Payment Date falls in the current fiscal year.

**Objects, Fields, Relationships**

This rollup example uses the [Nonprofit Success Pack (NPSP)](https://www.salesforce.org/nonprofit/nonprofit-success-pack-new/), which has a child object of Opportunity called Payment (`npe01__OppPayment__c`). There can be multiple payments before an opportunity moves into a fully paid status. The Opportunity field on Payment (`npe01__Opportunity__c`) is the lookup to Opportunity. Payments each have their own Payment Date field (`npe01__Payment_Date__c`) and a checkbox to indicate that they are paid (`npe01__Paid__c`). While this uses NPSP objects and fields as examples, the idea of multiple payments on an opportunity is applicable in many organizations.

|                              Field | Value                                                                                                                                                                                                                                               |
| ---------------------------------: | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|                      Parent Object | `Opportunity`                                                                                                                                                                                                                                       |
|                       Child Object | `npe01__OppPayment__c`                                                                                                                                                                                                                              |
|                 Relationship Field | `npe01__Opportunity__c`                                                                                                                                                                                                                             |
| Relationship Criteria (SOQL Query) | `npe01__Paid__c = True AND npe01__Payment_Date__c = THIS_YEAR`                                                                                                                                                                                      |
|       Relationship Criteria Fields | `npe01__Paid__c, npe01__Payment_Date__c`                                                                                                                                                                                                            |
|                 Field to Aggregate | `npe01__Payment_Amount__c`                                                                                                                                                                                                                          |
|                  Field to Order By | `n/a`                                                                                                                                                                                                                                               |
|                Aggregate Operation | `SUM`                                                                                                                                                                                                                                               |
|             Aggregate Result Field | `DLRS_Payments_This_Year__c`                                                                                                                                                                                                                        |
|                   Calculation Mode | `Realtime`                                                                                                                                                                                                                                          |
|          Schedule vs Child Trigger | `Deploy the child trigger for a realtime update whenever a payment is marked paid AND click Schedule Full Calculate to have all records recalculated on the first of each month, so that the relative date filter for the year is kept up to date.` |

**Variations**

- Use for any child payment or transaction records linked to Opportunity, or for child Opportunities related to a parent Opportunity.

- Create a version for LAST YEAR.

- Unpaid payment records, so you can see outstanding balance.

**Contributed By** Jared Henning, [Salesforce.com](https://salesforce.com/)

# Opportunity: List GAU Allocations

**Description**

> Displays a concatenated list of the General Accounting Unit names from related GAU allocation records in a single field. GAU Allocations are a feature of the NPSP, and there can be multiple Allocations on a single Opportunity. The concatenated field allows us to display the value in the related lists and see at a glance how a donor might restrict their giving.

**Objects, Fields, Relationships**

|                     Field | Value                                         |
| ------------------------: | --------------------------------------------- |
|             Parent Object | `Opportunity`                                 |
|              Child Object | `npsp__Allocation__c`                         |
|        Relationship Field | `npsp__Opportunity__c`                        |
|     Relationship Criteria | None                                          |
|        Field to Aggregate | `General_Accounting_Unit_Name__c`             |
|         Field to Order By | `npsp__Amount__c DESC, npsp__Percent__c DESC` |
|       Aggregate Operation | `Concatenate Distinct`                        |
|    Aggregate Result Field | `DLRS_GAU_Allocations_List__c`                |
|          Calculation Mode | Realtime                                      |
| Schedule vs Child Trigger | Deploy the Child Trigger                      |

**Preparation**

> You’ll require a custom formula text field built on `npsp__Allocation__c` to display the name of the General Accounting Unit.
>
> This rollup requires test code to function correctly.
>
> Can also be run on a schedule.

**Contributed By**
Rachel Sinex, [Pedal Lucid](https://www.pedallucid.com/) _and_ Maida Rider, [Jesuit Refugee Service](https://jrsusa.org/)

# Contact: Sum of won Tribute Gifts

**Description**

> Calculate the total amount of won tribute gifts received in honor of a Contact. Note that the relationship between the objects here is via the Honoree Contact lookup (which is an NPSP package field), not the Primary Contact.

| Fields                             | Description                                     |
| ---------------------------------- | ----------------------------------------------- |
| Parent Object                      | `Contact`                                       |
| Child Object                       | `Opportunity`                                   |
| Relationship Field                 | `npsp__Honoree_Contact__c`                      |
| Relationship Criteria (SOQL Query) | `npsp_Tribute_Type__c != null AND isWon = True` |
| Relationship Criteria Fields       | `npsp_Tribute_Type__c, isWon`                   |
| Field to Aggregate                 | `Amount`                                        |
| Order By Field                     | n/a                                             |
| Aggregate Operation                | `SUM`                                           |
| Aggregate Result Field             | `Sum_of_Tribute_Gifts__c`                       |
| Calculation Mode                   | `Realtime`                                      |
| Schedule vs Child Trigger          | `Child Trigger deployed`                        |

**Contributed By**
Amanda Styles, [Traction on Demand](https://www.tractionondemand.com/)

# Campaign: Total Amount Won from Opportunity Record Type or Lead Source

**Description**

> These are two variations for summarizing the total amount of a specific category of won Opportunities on a Campaign record. The first is for a specific Record Type of 'Donation' (from Laurel Taylor), and the second is for Opportunities where the Lead Source is 'Web' (from Amy Utkan).

**Objects, Fields, Relationships**

| Fields                             | Description                                                                       |
| ---------------------------------- | --------------------------------------------------------------------------------- |
| Parent Object                      | `Campaign`                                                                        |
| Child Object                       | `Opportunity`                                                                     |
| Relationship Field                 | `CampaignId`                                                                      |
| Relationship Criteria (SOQL Query) | `RecordType.Name = Donation AND Stage <> ‘Closed Lost’` _or_ `LeadSource = ‘Web’` |
| Relationship Criteria Fields       | `RecordType.Name, Stage` _or_ `LeadSource`                                        |
| Field to Aggregate                 | `Amount`                                                                          |
| Order By Field                     | n/a                                                                               |
| Aggregate Operation                | `SUM`                                                                             |
| Aggregate Result Field             | `Total_Related_Donations__c` _or_ `Opportunities_from_Web_Source__c`              |
| Calculation Mode                   | `Realtime`                                                                        |
| Schedule vs Child Trigger          | `Child Trigger deployed`                                                          |

**Variations**

> Count Opportunities where a matching gift has been received ( Relationship Criteria: Matching_Gift_Status = ‘Received’, Aggregate Operation: `COUNT`)

**Contributed By** Laurel Taylor, [Town Hall Seattle](https://townhallseattle.org/) _and_ Amy Utkan, [BRDPro](https://brdpro.com/)

# Contact: Current Active Recurring Donations

**Description**

> Shows whether or not this contact has 1 or more currently active recurring donations (uses the NPSP Recurring Donations custom object).

| Fields                             | Description                                                       |
| ---------------------------------- | ----------------------------------------------------------------- |
| Parent Object                      | `Contact`                                                         |
| Child Object                       | `npe03__Recurring_Donation__c`                                    |
| Relationship Field                 | `npe03__Contact__c`                                               |
| Relationship Criteria (SOQL Query) | `npsp__Status__c=’Active’`                                        |
| Relationship Criteria Fields       | `npsp__Status__c`                                                 |
| Field to Aggregate                 | `Name`                                                            |
| Order By Field                     | n/a                                                               |
| Aggregate Operation                | `COUNT`                                                           |
| Aggregate Result Field             | `Related_Active_Recurring_Donations__c`                           |
| Calculation Mode                   | `Realtime`                                                        |
| Schedule vs Child Trigger          | `Child Trigger deployed. Could also be scheduled to run nightly.` |

**Preparation**

> Because NPSP, I had to do some hunting for [test code in GitHub](https://github.com/SFDO-Community/declarative-lookup-rollup-summaries/issues/490)

**Contributed By**
Marc Baizman, [Salesforce.com](https://www.salesforce.com/)

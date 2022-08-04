---
layout: default
title: Students, Scores, Attendance
parent: Cookbook
nav_order: 6
---

# Account: Count of Student Applications This Year

**Description**

> Count the number of student applications to a college this year. Assuming a student can or does only submit one application, this can also be considered the count of students who applied. There was no need for this to be realtime, especially due to the potential for a negative (slight) performance impact if it was.

**Objects, Fields, Relationships**

|                              Field | Value                                                                                                                           |
| ---------------------------------: | ------------------------------------------------------------------------------------------------------------------------------- |
|                      Parent Object | `Account`                                                                                                                       |
|                       Child Object | `CollegeApp__c`                                                                                                                 |
|                 Relationship Field | `AccountId`                                                                                                                     |
| Relationship Criteria (SOQL Query) | `Year_of_Application_Date__c = N_Fiscal_Years_Ago AND IsApplied__c = true`                                                      |
|       Relationship Criteria Fields | `Year_of_Application_Date__c` `N_Fiscal_Years_Ago` `IsApplied__c`                                                               |
|                 Field to Aggregate | `Id`                                                                                                                            |
|                  Field to Order By | n/a                                                                                                                             |
|                Aggregate Operation | `COUNT`                                                                                                                         |
|             Aggregate Result Field | `DLRS_Applications_This_Year__c`                                                                                                |
|                   Calculation Mode | `Scheduled`                                                                                                                     |
|          Schedule vs Child Trigger | `Deploy the Child Trigger, and also set using the DLRS scheduler to recalculate monthly (to keep the relative date up-to-date)` |

**Preparation**

> No special preparation required. `N_Fiscal_Years_Ago` is a formula field that displays the current fiscal year.

**Variations**

- Additional versions of this roll-up can be configured to show a count of applications last year, two years ago, etc.

**Contributed By** Michael Kolodner, [Kolodner.com LLC](https://kolodner.com/) for client: [The Academy Group](https://theacademygroup.com/)

# Contact: Current Traction Rec Membership Type

**Description**

> Rolls up the Type of the current membership to the contact for easy access. This is a part of a managed package called [Traction Rec](https://appexchange.salesforce.com/listingDetail?listingId=a0N3A00000FYE1kUAH&msclkid=5bfeec30cbe311ec88624bc25754db7d).

| Fields                             | Description                                                                                                                          |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Parent Object                      | `Contact`                                                                                                                            |
| Child Object                       | `TREX1__Membership__c`                                                                                                               |
| Relationship Field                 | `TREX1__Contact__c`                                                                                                                  |
| Relationship Criteria (SOQL Query) | `RecordTypeId = '012f4000000DdFgAAK' AND TREX1__Status__c IN ('Active', 'Pending Active', 'Pending Withdrawal', 'Pending Transfer')` |
| Relationship Criteria Fields       | `RecordTypeId, TREX1__Status__c`                                                                                                     |
| Field to Aggregate                 | `TREX1__Type__c`                                                                                                                     |
| Order By Field                     | `TREX1__Start_Date__c`                                                                                                               |
| Aggregate Operation                | `CONCATENATE DISTINCT`                                                                                                               |
| Aggregate Result Field             | `Current_Membership_Type__c`                                                                                                         |
| Calculation Mode                   | `Realtime`                                                                                                                           |
| Schedule vs Child Trigger          | `Child Trigger deployed`                                                                                                             |

**Variations**

- Membership Start Date (using a MAX operation) & Membership Status (using LAST, sorted by Start Date) are defined in similar ways.

**Contributed By**
John McInnes, [Traction Rec, Uncommon Purpose](http://www.uncommonpurpose.com)

# Contact: Authorized Pickup Contacts

**Description**

> We often need to see a list of key contacts (authorized to pick up students) - in a short field on the student Contact record to review in one place. Using the concatenate operator can list all of this information in one field. The child objects here are part of a managed package called [Traction Rec](https://appexchange.salesforce.com/listingDetail?listingId=a0N3A00000FYE1kUAH&msclkid=5bfeec30cbe311ec88624bc25754db7d)

| Fields                             | Description                                                |
| ---------------------------------- | ---------------------------------------------------------- |
| Parent Object                      | `Contact`                                                  |
| Child Object                       | `TREX1__Authorized_Pickup__c`                              |
| Relationship Field                 | `ContactId`                                                |
| Relationship Criteria (SOQL Query) | `TREX1__End_Date__c >= Today OR TREX1__End_Date__c = NULL` |
| Relationship Criteria Fields       | `TREX1__End_Date__c`                                       |
| Field to Aggregate                 | `Authorized_Pickup_Name__c`                                |
| Order By Field                     | n/a                                                        |
| Aggregate Operation                | `CONCATENATE`                                              |
| Aggregate Result Field             | `Authorized_Pickups__c`                                    |
| Calculation Mode                   | `Realtime`                                                 |
| Schedule vs Child Trigger          | `Child Trigger deployed`                                   |

**Contributed By**
John McInnes, [Traction Rec, Uncommon Purpose](http://www.uncommonpurpose.com)

# Report Card: Calculate Grade Point Average (GPA)

**Description**

> Count all grades and average them to determine Grade Point Average (GPA) for core classes. We only want to calculate the GPA for core academic courses (Math and English).

**Objects, Fields, Relationships**

> The School Report Card custom object has a child object, Grade. The field GPA_Pts**c is a formula that translates a letter grade into points on a 4-point GPA scale (leaving pass/fail grades blank). Grades also have a field Course_Type**c that is a picklist to choose English, Math, Art, etc. The field Interim_Final\_\_c tells us if this is a final grade or an interim report.

| Fields                             | Description                                                                                                     |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Parent Object                      | `School_Report_Card__c`                                                                                         |
| Child Object                       | `Grade__c`                                                                                                      |
| Relationship Field                 | `School_Report_Card__c`                                                                                         |
| Relationship Criteria (SOQL Query) | `(Course_Type__c = 'Math' OR Course_Type__c = 'English') AND Interim_Final__c = 'Final' AND GPA_Pts__c != null` |
| Relationship Criteria Fields       | `Course_Type__c, Interim_Final__c, GPA_Pts__c `                                                                 |
| Field to Aggregate                 | `GPA_Pts__c`                                                                                                    |
| Order By Field                     | n/a                                                                                                             |
| Aggregate Operation                | `AVERAGE`                                                                                                       |
| Aggregate Result Field             | `DLRS_CoreGPA__c`                                                                                               |
| Calculation Mode                   | `Realtime`                                                                                                      |
| Schedule vs Child Trigger          | Child Trigger deployed.                                                                                         |

**Contributed By**
Michael Kolodner, [Kolodner.com](https://kolodner.com/)

<!-- Edited by Jillian Nii 5/5/22 -->

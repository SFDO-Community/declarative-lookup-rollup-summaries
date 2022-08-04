---
layout: default
title: Affiliations, Relationships, Accounts, Contacts
parent: Cookbook
nav_order: 1
---

# Contact: Count Current Board Member Affiliation

**Description**

> Identify on the Contact record their active affiliation, such as if they are a board member or sponsor. This rollup is based on information on the Role field in a Contact’s related Affiliations.

**Objects, Fields, Relationships**

|                              Field | Value                                                            |
| ---------------------------------: | ---------------------------------------------------------------- |
|                      Parent Object | `Contact`                                                        |
|                       Child Object | `NPSP Affiliation`                                               |
| Relationship Criteria (SOQL Query) | `npe5__Role__c = ‘Board Member’ AND npe5__Status__c = ‘Current’` |
|       Relationship Criteria Fields | `npe5__Role__c` `Status`                                         |
|                 Field to Aggregate | `Id`                                                             |
|                  Field to Order By | n/a                                                              |
|                Aggregate Operation | `COUNT`                                                          |
|             Aggregate Result Field | `Current_Board_Count__c`                                         |
|                   Calculation Mode | `Realtime`                                                       |
|          Schedule vs Child Trigger | `Child Trigger deployed`                                         |

**Preparation**

> Customize `npe5__Role__c` (Role on Affiliation) to include Board Member or any other roles you want to roll up to the Contact.

**Variations**

- Use different roles for the rollup, such as sponsor. If you only want to rollup the role from the Contact’s Primary Affiliation, you can add “AND npe5**Primary**c=TRUE” to the Relationship Criteria SOQL query.

- You could also have a checkbox formula field on the contact object for easy reporting. If the rollup value >=1, then the checkbox is checked (true), meaning they are a board member. If the rollup is 0, then the checkbox is unchecked (false).

**Contributed By** Hua Ping Tan, [Belmar Consulting Group](https://www.belmar.ca/)

# Contact: Count Relationships to Accounts

**Description**

> Count the number of AccountContactRelation records for a particular contact to be able to see if that person is related to more than one Account. This rollup uses the [Relate Contacts to Multiple Accounts feature](https://help.salesforce.com/s/articleView?id=sf.shared_contacts_overview.htm&type=5)

**Objects, Fields, Relationships**

| Fields                             | Description                 |
| ---------------------------------- | --------------------------- |
| Parent Object                      | `Contact`                   |
| Child Object                       | `AccountContactRelation`    |
| Relationship Field                 | `ContactId`                 |
| Relationship Criteria (SOQL Query) | n/a                         |
| Relationship Criteria Fields       | n/a                         |
| Field to Aggregate                 | `Id`                        |
| Order By Field                     | n/a                         |
| Aggregate Operation                | `COUNT`                     |
| Aggregate Result Field             | `Count_of_Relationships__c` |
| Calculation Mode                   | `Realtime`                  |
| Schedule vs Child Trigger          | `Child Trigger deployed`    |

**Preparation**

> It took me a little while to realize the field I needed to summarize was Id. Normally for the Count function with DLRS I summarize “Name” but AccountContactRelation doesn’t have a name field!

**Contributed By**
Sarah Pilzer, [Country Dance & Song Society](https://www.cdss.org/)

# Account: Count Number of Contacts

**Description**

> Count number of Contacts associated with an Account.

| Fields                             | Description              |
| ---------------------------------- | ------------------------ |
| Parent Object                      | `Account`                |
| Child Object                       | `Contact`                |
| Relationship Field                 | `Account`                |
| Relationship Criteria (SOQL Query) | n/a                      |
| Relationship Criteria Fields       | n/a                      |
| Field to Aggregate                 | `Id`                     |
| Order By Field                     | n/a                      |
| Aggregate Operation                | `COUNT`                  |
| Aggregate Result Field             | `Count_of_Contacts__c`   |
| Calculation Mode                   | `Realtime`               |
| Schedule vs Child Trigger          | `Child Trigger deployed` |

**Contributed By**
Michael Kolodner, for client: [Clean Air Council](https://cleanair.org/)

# Account: Address Type Count

**Description**

> Counts the number of Address Types associated with an Account. We use the Address Type field to indicate specific purposes for addresses, including Acknowledgements, Direct Mail, and Event Invitations. This rollup counts how many addresses have a specific type value, 'Direct Mail' in this case, to check that the value exists.

| Fields                             | Description                             |
| ---------------------------------- | --------------------------------------- |
| Parent Object                      | `Account`                               |
| Child Object                       | `npsp__Address__c`                      |
| Relationship Field                 | `npsp__Household_Account__c`            |
| Relationship Criteria (SOQL Query) | `npsp__Address_Type__c = ‘Direct Mail’` |
| Relationship Criteria Fields       | `npsp__Address_Type__c`                 |
| Field to Aggregate                 | `Id`                                    |
| Order By Field                     | n/a                                     |
| Aggregate Operation                | `COUNT`                                 |
| Aggregate Result Field             | `Count_of_DirectMail Address__c`        |
| Calculation Mode                   | `Scheduled`                             |
| Schedule vs Child Trigger          | `Run on a schedule`                     |

**Preparation**

> I think I would do an incremental scheduled batch if I did this again.

**Contributed By**
Amanda Styles, [Traction on Demand](https://www.tractionondemand.com/)

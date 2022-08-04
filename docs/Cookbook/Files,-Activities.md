---
layout: default
title: Files, Activities
parent: Cookbook
nav_order: 3
---

# Object: Count Attached Files with Certain Text in their Name

**Description**

> Salesforce Files are incredibly useful, but hard to report on. One of the first things you need to figure out in working with them is that the “File” itself is actually a ContentDocument and it is shared onto a record with a ContentDocumentLink. Sometimes you just need to know how many files are connected to a record (or if there are any files at all). This recipe counts the number of Files related to a record that have the specific text “resume” somewhere in the title of the file. So you can use this to determine if a job application has an attached résumé or not. Replace the name “resume” with something else and you’ve got endless variations available.

**Objects, Fields, Relationships**

|                     Field | Value                                         |
| ------------------------: | --------------------------------------------- |
|             Parent Object | Can be used on any object, standard or custom |
|              Child Object | `ContentDocumentLink`                         |
|     Relationship Criteria | `ContentDocument.Title LIKE '%resume%'`       |
|             Rollup Action | `Count`                                       |
|        Field to Aggregate | `Id`                                          |
|         Field to Order By | N/A                                           |
|       Aggregate Operation | `COUNT`                                       |
|    Aggregate Result Field | `DLRS_File_Count__c`                          |
|          Calculation Mode | `Realtime`                                    |
| Schedule vs Child Trigger | Deploy the Child Trigger                      |

**Preparation**

> `Relationship Field = LinkedEntityId` Rollup works fine BUT you CANNOT create this rollup in the UI (you will receive an error)! Instead you have to create the rollup by going directly to the DLRS custom metadata records and creating it there

**Variations**

- In SQL Query: replace "resume" with any appropriate text and potentially move/remove the % symbols.

**Contributed by** Jon LaRosa, [LaRosa Consulting](https://trailblazer.me/id/jonlarosa)

# Contact: Completed Log-a-Call Activities LastYear

**Description**

> Counts the number of completed log-a-call activities for a contact over the past year. Was used to get an idea of how many times we were logging a call for a contact to gauge engagement and "high touch".

**Objects, Fields, Relationships**

| Fields                             | Description                                                            |
| ---------------------------------- | ---------------------------------------------------------------------- |
| Parent Object                      | `Contact`                                                              |
| Child Object                       | `Task`                                                                 |
| Relationship Field                 | `WhoID`                                                                |
| Relationship Criteria (SOQL Query) | `Status='Completed' AND TaskSubtype='Call' AND ActivityDate=LAST_YEAR` |
| Relationship Criteria Fields       | `Status, TaskSubtype, ActivityDate`                                    |
| Field to Aggregate                 | `Id`                                                                   |
| Order By Field                     | n/a                                                                    |
| Aggregate Operation                | `COUNT`                                                                |
| Aggregate Result Field             | `Completed_Activities_LY__c`                                           |
| Calculation Mode                   | `Scheduled`                                                            |
| Schedule vs Child Trigger          | Schedule, No Child Trigger.                                            |

**Preparation**

> You will need to select Aggregate All Rows, since activities get archived (better safe than sorry).

**Variations**

- Multiple variations for based on record type for task, can also be used to track high value contacts/donors etc to make sure that key people are being touched regularly over time, etc

**Contributed By**
Heath Parks, [North Peak Solutions](https://www.northpeak.com/)

<!-- Kathy Waterworth 05/05/2022  Email: heath.parks@northpeak.com -->

# Require Receipts on Expense Reports

**Description**

> Counts the number of attached Files on a custom object (Expense Report). Though this won't guarantee that the files are actually receipts, it can be used as part of a check to make sure that expense reports are complete before sending them to managers for checking and approval.
>
> This simplified example is based on use in real life at my prior job. In that org we had a Monthly Expense Report object and child Expense Report Items. We asked people to upload files onto the top-level object and prevented putting the Monthly Expense Report into the approval process if there was not at least one attached File. (Some people would scan multiple receipts into a single PDF, so we couldn't assume a 1:1 count of files to receipts.)

**Objects, Fields, Relationships**

| Fields                             | Description                       |
| ---------------------------------- | --------------------------------- |
| Parent Object                      | `Expense_Report__c`               |
| Child Object                       | `ContentDocumentLink`             |
| Relationship Field                 | `LinkedEntityId`                  |
| Relationship Criteria (SOQL Query) | n/a                               |
| Relationship Criteria Fields       | n/a                               |
| Field to Aggregate                 | `Id`                              |
| Order By Field                     | n/a                               |
| Aggregate Operation                | `COUNT`                           |
| Aggregate Result Field             | `DLRS_Count_Attached_Receipts__c` |
| Calculation Mode                   | `Realtime`                        |
| Schedule vs Child Trigger          | `Child Trigger deployed`          |

**Variations**

- Working with Salesforce Files (which are actually several objects, to account for versioning and attachment to multiple records) is challenging. This recipe shows a basic use case that can allow the requirement of an attached file, from which you could have all sorts of variations. You could require that ".jpg" or ".pdf" be part of the filename, or that a certain string be part of the name, etc. But note that it's very difficult to actually require much about the file itself.
- If you have an expense report object with individual line items for each expense, you could either use this setup to require an attached file on each line item. Or you could combine this count with a field that counts line items and then require that there be at least one attached file for each line item.
- The User Story here, for capturing receipts on expense reports, is a good example of how working with Files is tricky. We can use the count of attached files to ensure that some file has been attached. But there is nothing to stop someone from attaching the first jpg they find on their desktop, rather than an actual receipt. So in this case, we had to make sure that managers would spot check their team's expense reports. But this at least allowed us to prevent submission of expense reports with no attached receipts at all.

**Contributed By**
Michael Kolodner, [Kolodner.com](https://kolodner.com/)

<!-- Edited by Kathy Waterworth 05/05/2022 -->

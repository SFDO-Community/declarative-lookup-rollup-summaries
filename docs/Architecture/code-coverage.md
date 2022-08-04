---
layout: default
title: Challenges with Code Coverage
nav_order: 3
parent: Architecture
has_children: false
---

# Problem

The tool works its magic because it dynamically deploys an Apex Trigger into the org that differs the actual processing of the rollup into the package. The processing is driven by the Rollup definitions the user defines. The tool, like a real developer, is subject to the same Apex deployment rules (e.g. code coverage) and requires an Apex Test to cover the trigger code it generates.

As it's a machine generated test it's not very bright. Often it's just enough to cause the dummy child object record insert to fire the generated trigger and cover the code. However, if the child object has some validation (typically another Apex trigger) that prevents the generated trigger executing, you can see a code coverage error (or other error, such as a null pointer exception).

This can be seen variably, as trigger execution order is not fixed on the platform, so sometimes the generated trigger may fire first and other times not. Also this issue is mostly only seen when you're deploying to production (either via Change Set or using Manage Child Trigger in production) because only production insists on test coverage, so the problem may go unnoticed in Sandbox.

# More Light on the Problem

The generated test just needs the generated trigger to fire, just once, and it does not need the child record to actually insert. As such it catches all exceptions to avoid test failures that it doesn't really care about (since the packaged rollup code has plenty of testing in it and it's not testing any other trigger code on the object either). As such in previous versions of the tool generated tests made it hard to see the underlying problem. This has been addressed in the latest version of the tool, but you may need to refresh the generated test in Sandbox by using Manage Child Triggers to remove and deploy. You can see if you've got a new style generated test, by looking for dlrs.RollupService.handleTest in the generated test code.

Once you have a new style generated test in Sandbox, if you try to either explicitly run the test from the Apex Test Execution page under Setup or Developer Console, you can see if you've got any coverage or errors that would preventing it going into production. Note due to the trigger order of execution behaviour above, you may not still see any problems. It's only when trying to push to production or use the Manage Child Trigger page in production you may finally see the error preventing code coverage.

# Solutions Today

In order to address errors preventing code coverage, it's likely you will need a developer to help. If you're lucky it may just be a need to run the Change Set or Manage Child Trigger deployments by another user that satisfies whatever other Apex Trigger validation logic is throwing the error.

If you're not lucky, it maybe that the rather basic generated code to insert a child object record needs some field values assigned to it. Where the test constructs the child object, in the bit between the braces you can populate other fields. This will require a developer in Sandbox to edit the test and deploy it via Change Sets to accomplish this. Note that if you manage to get the generated trigger and test into production via Change Sets, there is no need to use the Manage Child Trigger button in production; just tick the Active field on the rollup and you're set.

Once you can see the underlying error resulting from the simplistic generated test code failure, which is likely caused by validation in another child object trigger, you should hopefully be able to see from the error message which fields might need populating. This will inform your plan to enhance the test code to get the generated trigger to be invoked and thus covered for code coverage purposes.

While you do this, an easier way to reproduce what the test is failing with is to run the line of test code via Developer Console Execute Anonymous, which you can do in production (if your changeset is failing) or sandbox as it happens...

Something like this... (where Opportunity is your child)

    SavePoint sp = Database.setSavepoint();
    dlrs.RollupService.testHandler(new Opportunity());
    Database.rollback(sp);

**NOTE:** If you don't understand the errors you're getting from the child object triggers, you may need to contact the developer or package owner to get them to use Subscriber Support and run the above to get more details.

Study the errors you get and adjust the second line to populate required fields and/or insert dummy related records to associate. Once you have a working code snippet (like the example below), paste the lines between the first and last lines into the test code and retry running and deploying the test.

    SavePoint sp = Database.setSavepoint();
    dlrs.RollupService.testHandler(
       new Opportunity(SomeRequiredField__c = 'AValue', SomeOtherRequiredField__c = 'AnotherValue'));
    Database.rollback(sp);

# Solutions Going Forward

Looking forward i'm keen to make a few enhancements in this area to ease these types of problems.

- The first is one we've not really spoken about here: a Manage Child Trigger deploy in Production requires ALL unmanaged tests to run. If you have some broken in your production org (this can happen over time), it prevents the tools generated triggers and tests from being deployed. There is a new feature Summer'15 that can be leveraged by the tool, to only ensure its test runs in this use case.
- The second area i want to improve, but cannot commit to keeping 'code free' is helping the tool generate test code that satisfies whatever other child object validation (typically via other Apex Triggers). As you've read above, to address this use case it involves using developer tools to hand edit the generated test. This is something i believe can be smooth out, by allowing the rollup definition to have a large text area field that contains a means to override the generated code, so that you can paste in working test code that a developer has given you.

**UPDATE:** As of version v1.22 the above has been implemented.

I'm open to thoughts from others on this idea. It's reasonably cheap to implement but sadly doesn't keep the tool 100% code free for these use cases where child object validation is stopping the tools generated tests get coverage. Here is [list of issues reported](https://github.com/afawcett/declarative-lookup-rollup-summaries/labels/code%20coverage%20or%20test%20issue) around this to date.

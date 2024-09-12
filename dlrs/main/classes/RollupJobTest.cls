/**
 * Copyright (c) 2013, Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

@IsTest
private class RollupJobTest {
  @IsTest
  static void testSchedule() {
    RollupJob job = new RollupJob();
    Test.startTest();
    Id schedId = System.schedule('TestSchedRollupJob8724', '0 0 * * * ?', job);
    Test.stopTest();
  }

  @IsTest
  static void testRunJob() {
    String prefix = LookupRollupSummary2__mdt.sObjectType.getDescribe()
      .getKeyPrefix();

    LookupRollupSummary2__mdt rollupCfg = new LookupRollupSummary2__mdt(
      Id = prefix + '00000000000000D',
      Label = 'A Summary',
      DeveloperName = 'A_Summary',
      ParentObject__c = 'Account',
      ChildObject__c = 'Contact',
      RelationshipField__c = 'AccountId',
      AggregateOperation__c = RollupSummaries.AggregateOperation.Count.name(),
      AggregateResultField__c = 'Description',
      FieldToAggregate__c = 'Id',
      CalculationMode__c = 'Realtime',
      AggregateAllRows__c = false,
      Active__c = true
    );

    RollupSummariesSelector.setRollupCache(
      false,
      false,
      RollupSummary.toList(new List<LookupRollupSummary2__mdt>{ rollupCfg })
    );

    Account a = new Account(Name = 'Test');
    insert a;

    DeclarativeLookupRollupSummaries__c settings = new DeclarativeLookupRollupSummaries__c(
      DisableProblemEmails__c = true
    );
    insert settings;

    List<LookupRollupSummaryScheduleItems__c> items = new List<LookupRollupSummaryScheduleItems__c>();

    LookupRollupSummaryScheduleItems__c scheduledItem = new LookupRollupSummaryScheduleItems__c();
    scheduledItem.Name = a.Id;
    scheduledItem.LookupRollupSummary2__c = rollupCfg.Id;
    scheduledItem.ParentId__c = a.Id;
    scheduledItem.QualifiedParentID__c = a.Id + '#' + rollupCfg.Id;

    items.add(scheduledItem);

    insert items;

    RollupJob job = new RollupJob();
    Test.startTest();
    Database.executeBatch(job);
    Test.stopTest();

    List<LookupRollupSummaryLog__c> logs = [
      SELECT Id, ParentId__c, ParentObject__c
      FROM LookupRollupSummaryLog__c
    ];
    Assert.areEqual(0, logs.size());
  }

  @IsTest
  static void testFailureWithEmail() {
    String prefix = LookupRollupSummary2__mdt.sObjectType.getDescribe()
      .getKeyPrefix();

    LookupRollupSummary2__mdt rollupCfg = new LookupRollupSummary2__mdt(
      Id = prefix + '00000000000000D',
      Label = 'A Summary',
      DeveloperName = 'A_Summary',
      ParentObject__c = 'A',
      ChildObject__c = 'X',
      RelationshipField__c = '1',
      CalculationMode__c = 'Realtime',
      Active__c = true
    );
    RollupSummariesSelector.setRollupCache(
      false,
      false,
      RollupSummary.toList(new List<LookupRollupSummary2__mdt>{ rollupCfg })
    );

    Account a = new Account(Name = 'Test');
    insert a;

    List<LookupRollupSummaryScheduleItems__c> items = new List<LookupRollupSummaryScheduleItems__c>();

    LookupRollupSummaryScheduleItems__c scheduledItem = new LookupRollupSummaryScheduleItems__c();
    scheduledItem.Name = a.Id;
    scheduledItem.LookupRollupSummary2__c = rollupCfg.Id;
    scheduledItem.ParentId__c = a.Id;
    scheduledItem.QualifiedParentID__c = a.Id + '#' + rollupCfg.Id;

    items.add(scheduledItem);

    insert items;

    RollupJob job = new RollupJob();
    Test.startTest();
    job.execute(new MockBatchableContext(), items);
    Test.stopTest();

    List<LookupRollupSummaryLog__c> logs = [
      SELECT Id, ParentId__c, ParentObject__c
      FROM LookupRollupSummaryLog__c
    ];
    Assert.areEqual(1, logs.size());
    Assert.areEqual('RollupJob', logs[0].ParentObject__c);
    Assert.areEqual('RollupJob', logs[0].ParentId__c);
    Assert.areEqual(1, MessageService.sentEmailList.size());
  }

  @IsTest
  static void testFailureWithoutEmail() {
    String prefix = LookupRollupSummary2__mdt.sObjectType.getDescribe()
      .getKeyPrefix();

    LookupRollupSummary2__mdt rollupCfg = new LookupRollupSummary2__mdt(
      Id = prefix + '00000000000000D',
      Label = 'A Summary',
      DeveloperName = 'A_Summary',
      ParentObject__c = 'A',
      ChildObject__c = 'X',
      RelationshipField__c = '1',
      CalculationMode__c = 'Realtime',
      Active__c = true
    );
    RollupSummariesSelector.setRollupCache(
      false,
      false,
      RollupSummary.toList(new List<LookupRollupSummary2__mdt>{ rollupCfg })
    );

    Account a = new Account(Name = 'Test');
    insert a;

    DeclarativeLookupRollupSummaries__c settings = new DeclarativeLookupRollupSummaries__c(
      DisableProblemEmails__c = true
    );
    insert settings;

    List<LookupRollupSummaryScheduleItems__c> items = new List<LookupRollupSummaryScheduleItems__c>();

    LookupRollupSummaryScheduleItems__c scheduledItem = new LookupRollupSummaryScheduleItems__c();
    scheduledItem.Name = a.Id;
    scheduledItem.LookupRollupSummary2__c = rollupCfg.Id;
    scheduledItem.ParentId__c = a.Id;
    scheduledItem.QualifiedParentID__c = a.Id + '#' + rollupCfg.Id;

    items.add(scheduledItem);

    insert items;

    RollupJob job = new RollupJob();
    Test.startTest();
    job.execute(new MockBatchableContext(), items);
    Test.stopTest();

    List<LookupRollupSummaryLog__c> logs = [
      SELECT Id, ParentId__c, ParentObject__c
      FROM LookupRollupSummaryLog__c
    ];
    Assert.areEqual(1, logs.size());
    Assert.areEqual('RollupJob', logs[0].ParentObject__c);
    Assert.areEqual('RollupJob', logs[0].ParentId__c);
    Assert.areEqual(0, MessageService.sentEmailList.size());
  }

  public class MockBatchableContext implements Database.BatchableContext {
    public Id getJobId() {
      return '100000000000000';
    }

    public Id getChildJobId() {
      return '100000000000000';
    }
  }
}

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
private class RollupLoggerTest {
  @IsTest
  static void testLogSingleEntry() {
    Test.startTest();
    RollupLogger.log('RollupJob', 'RollupJob', 'Test error message');
    Test.stopTest();

    List<LookupRollupSummaryLog__c> logs = [
      SELECT Id, ParentId__c, ParentObject__c, ErrorMessage__c
      FROM LookupRollupSummaryLog__c
      WHERE ParentId__c = 'RollupJob'
    ];
    Assert.areEqual(1, logs.size());
    Assert.areEqual('RollupJob', logs[0].ParentObject__c);
    Assert.areEqual('Test error message', logs[0].ErrorMessage__c);
  }

  @IsTest
  static void testLogException() {
    Test.startTest();
    try {
      Integer x = 1 / 0;
    } catch (Exception e) {
      RollupLogger.log('RollupJob', 'RollupJob', e);
    }
    Test.stopTest();

    List<LookupRollupSummaryLog__c> logs = [
      SELECT Id, ParentId__c, ParentObject__c, ErrorMessage__c
      FROM LookupRollupSummaryLog__c
      WHERE ParentId__c = 'RollupJob'
    ];
    Assert.areEqual(1, logs.size());
    Assert.isTrue(logs[0].ErrorMessage__c.contains('Divide by 0'));
  }

  @IsTest
  static void testLogAllBulk() {
    LookupRollupSummaryLog__c log1 = new LookupRollupSummaryLog__c();
    log1.ParentId__c = 'TestParent1';
    log1.ParentObject__c = 'Account';
    log1.ErrorMessage__c = 'Error 1';

    LookupRollupSummaryLog__c log2 = new LookupRollupSummaryLog__c();
    log2.ParentId__c = 'TestParent2';
    log2.ParentObject__c = 'Contact';
    log2.ErrorMessage__c = 'Error 2';

    Test.startTest();
    RollupLogger.logAll(new List<LookupRollupSummaryLog__c>{ log1, log2 });
    Test.stopTest();

    List<LookupRollupSummaryLog__c> logs = [
      SELECT Id, ParentId__c, ParentObject__c
      FROM LookupRollupSummaryLog__c
      WHERE ParentId__c IN ('TestParent1', 'TestParent2')
    ];
    Assert.areEqual(2, logs.size());
  }

  @IsTest
  static void testLogDmlExceptionFallback() {
    RollupLogger.forceDmlException = true;

    Test.startTest();
    // When DML fails (such as in an inactive user context), it should not throw an unhandled exception
    RollupLogger.log('RollupJobFallback', 'RollupJob', 'Simulated failure');
    Test.stopTest();

    RollupLogger.forceDmlException = false;
  }

  @IsTest
  static void testSendSafeEmail() {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
    mail.setSubject('Test Subject');
    mail.setPlainTextBody('Test Body');

    Test.startTest();
    RollupLogger.sendSafeEmail(mail);
    Test.stopTest();

    Assert.areEqual(1, MessageService.sentEmailList.size());
  }

  @IsTest
  static void testSendSafeEmailDisabled() {
    DeclarativeLookupRollupSummaries__c settings = new DeclarativeLookupRollupSummaries__c(
      DisableProblemEmails__c = true
    );
    insert settings;

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
    mail.setSubject('Test Subject');
    mail.setPlainTextBody('Test Body');

    Test.startTest();
    RollupLogger.sendSafeEmail(mail);
    Test.stopTest();

    Assert.areEqual(0, MessageService.sentEmailList.size());
  }
}

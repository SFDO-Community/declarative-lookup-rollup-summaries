/**
 * Copyright (c), Andrew Fawcett
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
private class OptimizerServiceTest {
  @IsTest
  public static void givenLogRecordsThenCompletedWithWarnings() {
    // Given
    LookupRollupSummaryLog__c log1 = new LookupRollupSummaryLog__c(
      ParentId__c = 'abc'
    );
    LookupRollupSummaryLog__c log2 = new LookupRollupSummaryLog__c(
      ParentId__c = 'xyz'
    );
    insert new List<LookupRollupSummaryLog__c>{ log1, log2 };

    // When
    OptimizerService.Summary summary = OptimizerService.analyize();

    // Then
    System.assertEquals(
      OptimizerService.SummaryStatus.CompleteWithWarnings,
      summary.Status
    );
    System.assertEquals(
      OptimizerService.NotificationStatus.Warning,
      summary.Notifications.get(
          OptimizerService.NotificationReference.LookupRollupSummaryLogsExist
        )
        .Status
    );
  }

  @IsTest
  public static void givenNoLogRecordsThenCompleteWithoutWarnings() {
    // Given
    // No Logs

    // When
    OptimizerService.Summary summary = OptimizerService.analyize();

    // Then
    System.assertEquals(
      OptimizerService.SummaryStatus.Complete,
      summary.Status
    );
    System.assertEquals(0, summary.Notifications.size());
  }

  @IsTest
  static void givenManyScheduleItemsThenCompleteWithWarning() {
    // Given
    OptimizerService.NotificationReference nf = OptimizerService.NotificationReference.LookupRollupSummaryScheduleItemsCount;

    //When
    Test.startTest();
    List<LookupRollupSummaryScheduleItems__c> newList = new List<LookupRollupSummaryScheduleItems__c>();

    for (Integer i = 5; i < 300; i++) {
      LookupRollupSummaryScheduleItems__c item = new LookupRollupSummaryScheduleItems__c();
      item.QualifiedParentId__c = String.valueOf(i);
      newList.add(item);
    }

    insert newList;

    OptimizerService.Summary summary = OptimizerService.analyize(
      new Set<OptimizerService.NotificationReference>{ nf }
    );
    Test.stopTest();

    //Then
    System.assertEquals(
      OptimizerService.SummaryStatus.CompleteWithWarnings,
      summary.Status,
      'Status should have completed with warnings given scheduled items in queue'
    );
  }

  @IsTest
  static void givenNoScheduleItemsThenCompleteWithoutWarning() {
    // Given
    OptimizerService.NotificationReference nf = OptimizerService.NotificationReference.LookupRollupSummaryScheduleItemsCount;

    //When
    Test.startTest();
    OptimizerService.Summary summary = OptimizerService.analyize(
      new Set<OptimizerService.NotificationReference>{ nf }
    );
    Test.stopTest();

    //Then
    System.assertEquals(
      OptimizerService.SummaryStatus.Complete,
      summary.Status,
      'Status should have completed without warnings given no scheduled items in queue'
    );
  }
}

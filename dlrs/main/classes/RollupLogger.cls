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

public without sharing class RollupLogger {
  @TestVisible
  private static Boolean forceDmlException = false;

  /**
   * Log an error entry for a rollup failure safely
   */
  public static void log(String parentId, String parentObject, String errorMessage) {
    if (String.isBlank(parentId)) {
      return;
    }
    String safeParentId = parentId.length() > 18 ? parentId.substring(0, 18) : parentId;

    LookupRollupSummaryLog__c logEntry = new LookupRollupSummaryLog__c();
    logEntry.ParentId__c = safeParentId;
    logEntry.ParentObject__c = parentObject;
    logEntry.ErrorMessage__c = errorMessage;

    logAll(new List<LookupRollupSummaryLog__c>{ logEntry });
  }

  /**
   * Log an error from an Exception
   */
  public static void log(String parentId, String parentObject, Exception e) {
    String errorMsg = e == null ? 'Unknown error' : e.getMessage() + ' : ' + e.getStackTraceString();
    log(parentId, parentObject, errorMsg);
  }

  /**
   * Safe upsert for multiple LookupRollupSummaryLog__c records
   */
  public static void logAll(List<LookupRollupSummaryLog__c> logEntries) {
    if (logEntries == null || logEntries.isEmpty()) {
      return;
    }
    try {
      if (Test.isRunningTest() && forceDmlException) {
        throw new System.DmlException('Simulated DML Exception (e.g. inactive user)');
      }
      upsert logEntries ParentId__c;
    } catch (Exception dmlEx) {
      System.debug(
        LoggingLevel.ERROR,
        'RollupLogger failed to upsert LookupRollupSummaryLog__c directly: ' + dmlEx.getMessage()
      );
      for (LookupRollupSummaryLog__c logEntry : logEntries) {
        tryPublishEvent(logEntry.ParentId__c, logEntry.ParentObject__c, logEntry.ErrorMessage__c);
      }
    }
  }

  /**
   * Safe email dispatch to prevent inactive user exceptions
   */
  public static void sendSafeEmail(Messaging.SingleEmailMessage mail) {
    if (mail == null) {
      return;
    }
    if (
      DeclarativeLookupRollupSummaries__c.getInstance()
        .DisableProblemEmails__c == true
    ) {
      return;
    }
    try {
      // Check if running user is active before attempting to send email
      User runningUser = [
        SELECT Id, IsActive
        FROM User
        WHERE Id = :UserInfo.getUserId()
        LIMIT 1
      ];
      if (runningUser.IsActive == false) {
        System.debug(
          LoggingLevel.WARN,
          'Skipping email notification because running user is inactive: ' + runningUser.Id
        );
        return;
      }
      MessageService.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Failed to send problem email: ' + e.getMessage()
      );
    }
  }

  private static void tryPublishEvent(String parentId, String parentObject, String errorMessage) {
    try {
      UserNotification__e event = new UserNotification__e();
      event.Type__c = 'RollupError';
      event.Recipient__c = UserInfo.getUserId();
      event.Payload__c = JSON.serialize(
        new Map<String, String>{
          'parentId' => parentId,
          'parentObject' => parentObject,
          'errorMessage' => errorMessage
        }
      );
      EventBus.publish(event);
    } catch (Exception e) {
      System.debug(
        LoggingLevel.ERROR,
        'Failed to publish UserNotification__e: ' + e.getMessage()
      );
    }
  }
}

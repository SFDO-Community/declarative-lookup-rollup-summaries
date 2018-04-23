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

public with sharing class OptimizerComponentController {

    // Map notification status from the service to UI severity
    private static Map<OptimizerService.NotificationStatus, String> mapNotificationStatusToUIServerity = 
            new Map<OptimizerService.NotificationStatus, String> {
                OptimizerService.NotificationStatus.CheckFailed => 'error',
                OptimizerService.NotificationStatus.Warning => 'info',
                OptimizerService.NotificationStatus.Attention => 'warning'
             };

    // Map summary status from the service to UI severity
    private static Map<OptimizerService.SummaryStatus, String> mapSummaryStatusToUIServerity = 
            new Map<OptimizerService.SummaryStatus, String> {
                OptimizerService.SummaryStatus.Complete => 'info',
                OptimizerService.SummaryStatus.CompleteWithWarnings => 'warning',
                OptimizerService.SummaryStatus.CompleteNeedsAttention => 'error'
             };
    private static Map<OptimizerService.SummaryStatus, String> mapSummaryStatusToUITitle = 
            new Map<OptimizerService.SummaryStatus, String> {
                OptimizerService.SummaryStatus.Complete => 'Status: Good',
                OptimizerService.SummaryStatus.CompleteWithWarnings => 'Status: Warnings',
                OptimizerService.SummaryStatus.CompleteNeedsAttention => 'Status: Errors'
             };
    private static Map<OptimizerService.SummaryStatus, String> mapSummaryStatusToUIMessage = 
            new Map<OptimizerService.SummaryStatus, String> {
                OptimizerService.SummaryStatus.Complete => 'It looks like you are all good for the moment, check back again regularly!',
                OptimizerService.SummaryStatus.CompleteWithWarnings => 'It looks like you have some warnings to review.',
                OptimizerService.SummaryStatus.CompleteNeedsAttention => 'It looks like you have some errors to review.'
             };

    @AuraEnabled
    public static Summary analyze() {
        try {
            OptimizerService.Summary summary = OptimizerService.analyize();
            // Marshall into a response the Aura serializer supports
            Summary responseSummary = new Summary();
            responseSummary.severity = mapSummaryStatusToUIServerity.get(summary.Status);
            responseSummary.title = mapSummaryStatusToUITitle.get(summary.Status);
            responseSummary.message = mapSummaryStatusToUIMessage.get(summary.Status);
            responseSummary.notifications = new List<Notification>();
            for(OptimizerService.Notification notification : summary.Notifications.values()) {
                Notification responseNotification = new Notification();
                responseNotification.id = notification.Id.name();
                responseNotification.severity = mapNotificationStatusToUIServerity.get(notification.Status);
                responseNotification.message = notification.Message;
                responseSummary.notifications.add(responseNotification);
            }
            return responseSummary;
        } catch (Exception e) {
            // Marshall into an exception the Aura serializer supports
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Summary {
        @AuraEnabled
        public String severity;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public List<Notification> notifications;
    }

    public class Notification {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String severity;
        @AuraEnabled
        public String message;
    }
}

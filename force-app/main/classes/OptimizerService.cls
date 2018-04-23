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

/**
 * Performs various health checks to keeping the tool running in tip top shape!
 **/
global with sharing class OptimizerService {

    /**
     * Run all know checks
     **/
    global static Summary analyize() {
        return analyize(new Set<NotificationReference>(NotificationReference.values()));
    }

    /**
     * Run specified checks
     **/
    global static Summary analyize(Set<NotificationReference> checksToRun) {
        Summary summary = new Summary();
        summary.Notifications = new Map<NotificationReference, Notification>();
        for(NotificationReference ref : checksToRun) {
            // Look for an inner class in the service implementing the check
            Type checkType = Type.forName(OptimizerService.class+'.'+ref.name());
            if(checkType!=null) {
                OptimizationCheckRunner check = (OptimizationCheckRunner) checkType.newInstance();
                try {
                    // Run the optimization check
                    Notification notification = check.execute();
                    if(notification!=null) {
                        // Return the notiifcation for this check
                        summary.Notifications.put(ref, notification);                    
                        // Summary status reflects the most significant notificaiton status
                        if(notification.Status == NotificationStatus.Warning && summary.Status != SummaryStatus.CompleteNeedsAttention) {
                            summary.Status = SummaryStatus.CompleteWithWarnings;
                        } else if(notification.Status == NotificationStatus.Attention) {
                            summary.Status = SummaryStatus.CompleteNeedsAttention;
                        }
                    }
                } catch (Exception e) {
                    // Return a failed notification notification!
                    Notification failedCheck = new Notification();
                    failedCheck.Status = NotificationStatus.CheckFailed;
                    failedCheck.Message = 'Optimization check ' + ref + ' failed to complete: ' + e.getMessage();
                    failedCheck.MoreInfoURL = null;
                    summary.Notifications.put(ref, failedCheck);
                    summary.Status = SummaryStatus.CompleteNeedsAttention;
                }
            }
        }
        if(summary.Status==null) {
            summary.Status = SummaryStatus.Complete;
        }
        return summary;
    }

    /**
     * Results of the optimizer analysis
     **/
    global class Summary {
        global SummaryStatus Status {get; private set;}
        global Map<NotificationReference, Notification> Notifications {get; private set;}
    }

    /**
     * Notification to the user from a given analysis
     **/
    global class Notification {
        global NotificationReference Id {get; private set;}
        global NotificationStatus Status {get; private set;}
        global String Message {get; private set;}
        global String MoreInfoURL {get; private set;}
    }

    /** 
     * Status of the optimizer analysis (in future this may require background processing)
     **/
    global enum SummaryStatus { 
        Complete,
        CompleteWithWarnings,
        CompleteNeedsAttention
    }

    global enum NotificationStatus {
        CheckFailed,
        Warning,
        Attention
    }
    
    /**
     * Known optimization notications this service can return, use .values() to enumerate
     **/
    global enum NotificationReference {
        LookupRollupSummaryLogsExist,
        LookupRollupSummaryScheduleItemsInError,
        LookupShadowRecordsNeedDeleting,
        LookupRollupSummaryScheduleItemsFieldDeletion,
        LookupRollupSummaryScheduleItemsWithFullCalcScheduleJob
    }

    /**
     * Notifies the user if they have some records in the LookupRollupSummaryLogs__c record
     **/
    public class LookupRollupSummaryLogsExist extends OptimizationCheckRunner {
        public override Notification execute() {
            Notification notification = new Notification();
            notification.Id = NotificationReference.LookupRollupSummaryLogsExist;
            notification.Status = NotificationStatus.Warning;
            notification.Message = 'Check the Lookup Rollup Summary Log tab for errors updating rollups.';
            return notification;
        }
    }

    /**
     * Ability to run a optimization check
     **/
    public abstract class OptimizationCheckRunner {
        public abstract Notification execute(); 
    }
}

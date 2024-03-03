import { api } from "lwc";
import LightningModal from "lightning/modal";
import getCurrentJobs from "@salesforce/apex/SchedulerController.getCurrentJobs";
import getTotalScheduledJobs from "@salesforce/apex/SchedulerController.getAllScheduledJobs";
import scheduleJobs from "@salesforce/apex/SchedulerController.scheduleJobs";
import cancelScheduledJob from "@salesforce/apex/SchedulerController.cancelScheduledJob";

export default class ClassSchedulerModal extends LightningModal {
  cronStrings = [];
  // async apex jobs
  currentSchedule = [];
  // using the configured Cron strings stub new instances to be scheduled
  proposedSchedule = [];
  scheduledJobCount = 0;
  totalAllowedScheduledJobs = 100;

  @api
  className;

  @api
  allowsWhereClause;

  @api
  disableHandleSchedule;

  @api
  templates;

  async connectedCallback() {
    this.currentSchedule = await getCurrentJobs({ className: this.className });
    this.scheduledJobCount = (await getTotalScheduledJobs()).length;
  }

  handleOnCronUpdate(event) {
    this.cronStrings = event.detail.value;
  }

  async handleCancelJob(event) {
    // get the job id, send to the server to cancel
    await cancelScheduledJob({
      jobId: event.currentTarget.dataset.jobid
    });

    // refresh current jobs list
    this.currentSchedule = await getCurrentJobs({ className: this.className });
    this.scheduledJobCount = (await getTotalScheduledJobs()).length;
  }

  async handleSchedule() {
    try {
      await scheduleJobs({
        className: this.className,
        newSchedules: this.cronStrings
      });
      this.close();
    } catch (error) {
      // TODO: handle the error better
      console.error(error);
    }
  }

  handleCancel() {
    this.close();
  }
}

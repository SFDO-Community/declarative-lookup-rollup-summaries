import { api } from "lwc";
import LightningModal from "lightning/modal";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningConfirm from "lightning/confirm";

import getCurrentJobs from "@salesforce/apex/SchedulerController.getCurrentJobs";
import getTotalScheduledJobs from "@salesforce/apex/SchedulerController.getAllScheduledJobs";
import scheduleJobs from "@salesforce/apex/SchedulerController.scheduleJobs";
import cancelScheduledJob from "@salesforce/apex/SchedulerController.cancelScheduledJob";

export default class ClassSchedulerModal extends LightningModal {
  cronStrings = [];
  // async apex jobs
  currentSchedule = [];
  currentColumns = [
    { label: "Name", fieldName: "name" },
    {
      label: "Next Run At",
      fieldName: "nextRunAt",
      type: "date",
      typeAttributes: {
        month: "short",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit"
      },
      hideDefaultActions: true
    },
    { label: "Cron String", fieldName: "cronString", hideDefaultActions: true },
    {
      type: "action",
      typeAttributes: { rowActions: [{ label: "Delete", name: "delete" }] },
      hideDefaultActions: true
    }
  ];

  // using the configured Cron strings stub new instances to be scheduled
  proposedSchedule = [];
  scheduledJobCount = 0;
  // Can this be changes for some customers? Is there a place we can get this from?
  totalAllowedScheduledJobs = 100;

  @api
  className;

  @api
  allowsWhereClause;

  @api
  disableHandleSchedule;

  @api
  templates;

  connectedCallback() {
    this.updateScheduledData();
  }

  handleOnCronUpdate(event) {
    this.cronStrings = event.detail.value;
  }

  handleRowAction(event) {
    this.handleCancelJob(event.detail.row.id);
  }

  async handleCancelJob(jobId) {
    const confirmed = await LightningConfirm.open({
      label: "Delete Scheduled Job",
      message: `Are you sure you want to remove the scheduled job?`,
      theme: "warning"
    });

    if (!confirmed) {
      return;
    }
    // get the job id, send to the server to cancel
    await cancelScheduledJob({
      jobId
    });

    this.updateScheduledData();
  }

  updateScheduledData() {
    getCurrentJobs({
      className: this.className
    }).then((jobs) => {
      this.currentSchedule = jobs.map((j) => ({
        id: j.CronTrigger.Id,
        name: j.CronTrigger.CronJobDetail.Name,
        nextRunAt: j.CronTrigger.NextFireTime,
        cronString: j.CronTrigger.CronExpression
      }));
      console.log(this.currentSchedule);
    });

    getTotalScheduledJobs().then((jobs) => {
      this.scheduledJobCount = jobs.length;
    });
  }

  async handleSchedule() {
    try {
      await scheduleJobs({
        className: this.className,
        newSchedules: this.cronStrings
      });
      const evt = new ShowToastEvent({
        title: "Succesfully Added Jobs",
        variant: "success"
      });
      this.dispatchEvent(evt);
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

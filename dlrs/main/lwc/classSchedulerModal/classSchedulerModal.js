import { api } from "lwc";
import LightningModal from "lightning/modal";
import dlrs from "@salesforce/resourceUrl/dlrs";
import { loadScript } from "lightning/platformResourceLoader";

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
    {
      label: "Name",
      fieldName: "name",
      initialWidth: 150,
      wrapText: true,
      hideDefaultActions: true
    },
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
      hideDefaultActions: true,
      initialWidth: 150
    },
    {
      label: "Frequency",
      fieldName: "humanReadable",
      hideDefaultActions: true,
      wrapText: true
    },
    {
      label: "Cron String",
      fieldName: "cronString",
      hideDefaultActions: true,
      initialWidth: 100
    },
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
    loadScript(this, dlrs + "/js/cronstrue/dist/cronstrue.min.js").then(() => {
      // your code with calls to the JS library
      console.log("construe loaded");
      this.cronStrings.forEach((v) => {
        v.humanReadable = window.cronstrue.toString(v.cronString, {
          verbose: true
        });
      });
    });
    this.updateScheduledData();
  }

  handleOnCronUpdate(event) {
    // see if this library is globally loaded yet

    this.cronStrings = event.detail.value.map((v) => ({
      cronString: v,
      humanReadable: ""
    }));
    if (window.cronstrue) {
      this.cronStrings.forEach((v) => {
        v.humanReadable = cronstrue.toString(v.cronString, {
          verbose: true
        });
      });
    }
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
        cronString: j.CronTrigger.CronExpression,
        humanReadable: cronstrue.toString(j.CronTrigger.CronExpression, {
          verbose: true
        })
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
        newSchedules: this.cronStrings.map((c) => c.cronString)
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

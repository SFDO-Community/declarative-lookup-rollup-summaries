import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningConfirm from "lightning/confirm";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";

import getAllRollupConfigs from "@salesforce/apex/RollupEditorController.getAllRollupConfigs";
import deleteRollupConfig from "@salesforce/apex/RollupEditorController.deleteRollupConfig";
import USER_ID from "@salesforce/user/Id";

import RollupEditor, { CLASS_SCHEDULER_CONFIG } from "c/rollupEditor";
import ClassSchedulerModal from "c/classSchedulerModal";
import { buildApiName } from "c/utils";

import {
  subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";

import userNotification from "@salesforce/messageChannel/UserNotification__c";

const STATUS_LABELS = {
  Scheduled: "Watch and Process",
  Realtime: "Realtime",
  "Process Builder": "Automatable",
  Developer: "Developer"
};

export default class ManageRollups extends NavigationMixin(LightningElement) {
  dtColumns = [
    {
      type: "url",
      label: "Name",
      sortable: true,
      fieldName: "tabUrl",
      initialWidth: 300,
      typeAttributes: {
        label: { fieldName: "label" },
        target: "_self",
        stretch: true
      }
    },
    {
      label: "Parent",
      fieldName: "parentObject",
      sortable: true
    },
    {
      label: "Child",
      fieldName: "childObject",
      sortable: true
    },
    {
      label: "Field To Aggregate",
      fieldName: "fieldToAggregate",
      sortable: true
    },
    {
      label: "Aggregate Result Field",
      fieldName: "aggregateResultField",
      sortable: true
    },
    {
      label: "Rollup Type",
      fieldName: "aggregateOperation",
      sortable: true,
      filterable: true
    },
    {
      label: "Calc Mode",
      fieldName: "calculationMode",
      sortable: true,
      filterable: true
    },
    {
      label: "Active",
      fieldName: "active",
      initialWidth: 75,
      type: "boolean",
      sortable: true,
      filterable: true
    },
    {
      type: "button-icon",
      initialWidth: 50,
      typeAttributes: {
        name: "rollup_delete",
        iconName: "action:delete",
        value: "delete",
        variant: "natrual"
      }
    }
  ];

  @wire(CurrentPageReference)
  pageRef;

  sortByField = "active";
  sortDirection = "desc";
  pendingSaveRollupName;

  @wire(MessageContext)
  messageContext;

  rollups = {};
  rollupList = [];
  searchFilter = "";
  isLoading = true;
  selectedRollup = undefined;
  filters = {};

  connectedCallback() {
    this.refreshRollups();
    this.subscribeToMessageChannel();
  }

  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  subscribeToMessageChannel() {
    // Handler for message received by component
    // Callback invoked whenever a new event message is received
    const handleMessage = (response) => {
      // console.log("New message received: ", JSON.stringify(response));
      // deployment probably changed the rollup definitions, should refresh
      this.isLoading = false;
      this.refreshRollups();
      let title, message, messageData, variant, mode;
      const deploymentData = JSON.parse(response.payload);

      switch (response.type) {
        case "DeleteRequestResult":
          this.pendingSaveRollupName = undefined;
          if (deploymentData.success) {
            title = "Delete Completed!";
            message = `${deploymentData.metadataNames} deleted successfully`;
            variant = "success";
            mode = "dismissible";
          } else {
            title = "Delete Failed!";
            message = `Attempt to delete ${deploymentData.metadataNames} returned with errors [${deploymentData.error}]`;
            variant = "error";
            mode = "sticky";
          }
          break;
        case "DeploymentResult":
          if (deploymentData.status === "Succeeded") {
            title = "Deployment Completed!";
            message = "Metadata saved successfully";
            variant = "success";
            mode = "dismissible";
          } else {
            title = "Deployment Failed!";
            message =
              "Status of " +
              deploymentData.status +
              ", errors [" +
              deploymentData.details.componentFailures
                .map((failure) => `${failure.fullName}: ${failure.problem}`)
                .join("\n") +
              "], \n{0}";
            // if you know a better way to build this URL please replace this
            messageData = [
              {
                label: "Click to view Deployment",
                url: `/lightning/setup/DeployStatus/page?address=%2Fchangemgmt%2FmonitorDeploymentsDetails.apexp%3FasyncId%3D${deploymentData.id}`
              }
            ];
            variant = "error";
            mode = "sticky";
          }

          if (this.pendingSaveRollupName) {
            let pendingRollupName = this.pendingSaveRollupName;
            if (deploymentData.status !== "Succeeded") {
              // allows for recovery of non-saved rollup editor state
              pendingRollupName = "pending-" + pendingRollupName;
            }
            this.pendingSaveRollupName = undefined;
            this.openEditor(pendingRollupName);
          }
          break;
        default:
          break;
      }

      const evt = new ShowToastEvent({
        title,
        message,
        messageData,
        variant,
        mode
      });
      this.dispatchEvent(evt);
      // Response contains the payload of the new message received
    };

    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        userNotification,
        (message) => handleMessage(message),
        {}
      );
    }
  }

  async refreshRollups() {
    this.isLoading = true;
    this.rollups = await getAllRollupConfigs();

    await Promise.all(
      Object.keys(this.rollups).map(async (k) => {
        this.rollups[k] = {
          ...this.rollups[k],
          tabUrl: await this[NavigationMixin.GenerateUrl]({
            type: "standard__component",
            attributes: {
              componentName: buildApiName("rollupTab", true)
            },
            state: {
              c__rollupName: this.rollups[k].developerName
            }
          }),
          calculationMode:
            STATUS_LABELS[this.rollups[k].calculationMode] ??
            this.rollups[k].calculationMode
        };
      })
    );

    if (this.rollups.length === 0) {
      // no rollups in the database, start to create a new one
      this.openEditor(null);
    }
    this.updateColumnFilters();
    this.calcRollupList();
    this.isLoading = false;
  }

  updateColumnFilters() {
    this.dtColumns = [...this.dtColumns].map((conf) => {
      if (conf.filterable) {
        // reset actions
        if (conf.actions) {
          conf.actions = conf.actions.filter(
            (action) => action.type !== "filter"
          );
        } else {
          conf.actions = [];
        }

        const availableValues = this.rollups.reduce((result, rollup) => {
          const fieldValue = rollup[conf.fieldName];

          if (!result.includes(fieldValue)) {
            result.push(fieldValue);
          }

          return result;
        }, []);

        conf.actions.push({
          type: "filter",
          label: "All",
          checked: true,
          name: "All"
        });

        availableValues.sort().forEach((val) => {
          conf.actions.push({
            type: "filter",
            label: val,
            checked: false,
            name: val
          });
        });

        if (conf.fieldName in this.filters) {
          const filteredValue = this.filters[conf.fieldName].value;

          // check if currently filtered value is still relevant
          if (availableValues.includes(filteredValue)) {
            conf.actions.find(
              (a) => a.type === "filter" && a.name === "All"
            ).checked = false;
            conf.actions.find(
              (a) => a.type === "filter" && a.name === filteredValue
            ).checked = true;
          } else {
            // remove filter
            delete this.filters[conf.fieldName];
            conf.iconName = "";
          }
        }
      }

      return conf;
    });
  }

  calcRollupList() {
    this.rollupList = Object.values(this.rollups).filter((r) => {
      return this.meetsSearchFilter(r) && this.meetsColumnFilters(r);
    });
    this.rollupList.sort((a, b) => {
      const dirModifier = this.sortDirection === "asc" ? 1 : -1;
      const aVal = a[this.sortByField];
      const bVal = b[this.sortByField];
      let res = 0;
      if (typeof aVal === "boolean") {
        if (aVal) {
          // pull up
          res = 1;
        }
        if (bVal) {
          // pull down
          res = res - 1;
        }
      } else {
        res = aVal.localeCompare(bVal);
      }
      if (res === 0) {
        return a.label.localeCompare(b.label) * dirModifier;
      }

      return res * dirModifier;
    });
  }

  meetsSearchFilter(rollup) {
    if (this.searchFilter.trim().length === 0) {
      return true;
    }
    for (const c of this.dtColumns) {
      if (
        rollup[c.fieldName] &&
        ("" + rollup[c.fieldName]).toLowerCase().indexOf(this.searchFilter) >= 0
      ) {
        return true;
      }
    }
    // didn't match any of the displayed fields
    return false;
  }

  meetsColumnFilters(rollup) {
    return Object.keys(this.filters).every((fieldName) => {
      return rollup[fieldName] === this.filters[fieldName].value;
    });
  }

  rollupSelectHandler(event) {
    const action = event.detail.action;
    const row = event.detail.row;
    switch (action.name) {
      case "rollup_delete":
        this.requestDelete(row.developerName);
        break;
      default:
        throw new Error("unexpected action on rollupSelectHandler");
    }
  }

  async openEditor(rollupName) {
    const result = await RollupEditor.open({
      description: "Rollup Config Editor",
      rollupName
    });

    switch (result?.action) {
      case "delete":
        this.requestDelete(result.rollupName);
        break;
      case "deloyStart":
        this.isLoading = true;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Deployment Started",
            message:
              "Started Metadata Record Updates in Deployment " + result.jobId,
            variant: "info"
          })
        );
        this.pendingSaveRollupName = result.rollupName;
        break;
      case "navigate":
        this[NavigationMixin.Navigate](result.config);
        break;
      default:
        break;
    }
  }

  async requestDelete(rollupName) {
    const confirmed = await LightningConfirm.open({
      message: `Are you sure you want to delete the rollup named: ${rollupName}`,
      label: "Delete Rollup Configuration",
      theme: "warning"
    });
    if (confirmed) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Delete Started",
          message: `Started request to delete ${rollupName}`,
          variant: "info"
        })
      );
      this.isLoading = true;
      deleteRollupConfig({ rollupName: rollupName });
    }
  }

  runCreateNew() {
    this.openEditor(null);
  }

  async manageRollupJobSchedule() {
    await ClassSchedulerModal.open(CLASS_SCHEDULER_CONFIG).then((results) => {
      if (results) {
        try {
          const evt = new ShowToastEvent(results);
          this.dispatchEvent(evt);
        } catch (err) {
          // known issue with Lighting Locker can cause this to fail
          console.error("Failed to create toast with outcome", err);
        }
      }
    });
  }

  handleInputChange() {
    this.searchFilter = this.template
      .querySelector("lightning-input")
      .value.toLowerCase();
    this.calcRollupList();
  }

  handleRequestDelete(event) {
    this.requestDelete(event.detail.rollupName);
  }

  handleOnSort(event) {
    // The method onsort event handler
    this.sortByField = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    // assign the latest attribute with the sorted column fieldName and sorted direction
    this.calcRollupList();
  }

  handleHeaderAction(event) {
    const filteredFieldName = event.detail.columnDefinition.fieldName;
    const columnRef = [...this.dtColumns];
    const currentColumn = columnRef.find(
      (f) => f.fieldName === filteredFieldName
    );
    const previousAction = currentColumn.actions.find(
      (action) => action.checked
    );
    const currentAction = currentColumn.actions.find(
      (action) => action.name === event.detail.action.name
    );

    if (event.detail.action.type === "filter") {
      if (event.detail.action.name === "All") {
        delete this.filters[filteredFieldName];
        delete currentColumn.iconName;
      } else {
        this.filters = {
          ...this.filters,
          [filteredFieldName]: {
            type: event.detail.columnDefinition.type,
            value: event.detail.action.name
          }
        };
        currentColumn.iconName = "utility:filterList";
      }

      this.calcRollupList();
    }

    previousAction.checked = false;
    currentAction.checked = true;
    this.dtColumns = columnRef;
  }
}

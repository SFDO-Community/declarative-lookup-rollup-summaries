import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningConfirm from "lightning/confirm";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";

import getAllRollupConfigs from "@salesforce/apex/RollupEditorController.getAllRollupConfigs";
import deleteRollupConfig from "@salesforce/apex/RollupEditorController.deleteRollupConfig";
import RollupEditor, { CLASS_SCHEDULER_CONFIG } from "c/rollupEditor";
import ClassSchedulerModal from "c/classSchedulerModal";
import DeploymentMonitorModal from "c/deploymentMonitorModal";

const STATUS_LABELS = {
  Scheduled: "Watch and Process",
  Realtime: "Realtime",
  "Process Builder": "Automatable",
  Developer: "Developer"
};

export default class ManageRollups extends NavigationMixin(LightningElement) {
  dtColumns = [
    {
      type: "button",
      label: "Name",
      sortable: true,
      fieldName: "label",
      initialWidth: 300,
      typeAttributes: {
        label: { fieldName: "label" },
        name: "rollup_select",
        title: "Edit",
        value: "edit",
        variant: "base",
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

  rollups = {};
  rollupList = [];
  searchFilter = "";
  isLoading = true;
  selectedRollup = undefined;
  filters = {};

  connectedCallback() {
    this.refreshRollups();
  }

  async refreshRollups() {
    this.isLoading = true;
    this.rollups = await getAllRollupConfigs();

    Object.keys(this.rollups).forEach((k) => {
      this.rollups[k] = {
        ...this.rollups[k],
        calculationMode:
          STATUS_LABELS[this.rollups[k].calculationMode] ??
          this.rollups[k].calculationMode
      };
    });

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
      case "rollup_select":
        this.openEditor(row.developerName);
        break;
      case "rollup_delete":
        this.requestDelete(row.developerName);
        break;
      default:
        throw new Error("unexpected action on rollupSelectHandler");
    }
  }

  async openEditor(rollupName) {
    const result = await RollupEditor.open({
      whenRollupUpdated: this.refreshRollups.bind(this),
      description: "Rollup Config Editor",
      rollupName
    });

    switch (result?.action) {
      case "delete":
        this.requestDelete(result.rollupName);
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
      // Start listening for updates
      DeploymentMonitorModal.open({
        label: "Deploying Rollup Changes",
        headerLabel: "Deleting...",
        size: "small",
        deploymentManagerProps: {
          trackDeployments: true,
          spinnerOnly: true,
          publishToastOnCompletion: true
        }
      }).then(() => {
        // after the delete is completed and the modal closes, cleanup and refresh
        this.isLoading = false;
        this.refreshRollups();
      });
      // start the delete action (the Modal is async so doesn't have to complete before this runs)
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

import { api, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getChildTriggerInfo from "@salesforce/apex/ManageChildTriggerController.getChildTriggerInfo";
import startDeployment from "@salesforce/apex/ManageChildTriggerController.startDeployment";

const SELECT_OPTIONS = {
  ignore: {
    label: "No Change",
    value: "ignore",
    action: "none"
  },
  remove: {
    label: "Remove",
    value: "remove",
    action: "delete"
  },
  update: {
    label: "Update",
    value: "update",
    action: "deploy"
  },
  deploy: {
    label: "Install",
    value: "deploy",
    action: "deploy"
  }
};

const EXISTING_CODE_UP_TO_DATE = [
  { ...SELECT_OPTIONS.ignore, label: "Do Not Remove" },
  SELECT_OPTIONS.remove
];

const EXISTING_CODE_WITH_UPDATES = [
  SELECT_OPTIONS.update,
  { ...SELECT_OPTIONS.ignore, label: "Do Not Update" },
  SELECT_OPTIONS.remove
];

const NEW_CODE = [
  SELECT_OPTIONS.deploy,
  { ...SELECT_OPTIONS.ignore, label: "Do Not Install" }
];

export default class ManageChildTriggers extends LightningElement {
  @api
  rollupName;

  @api
  async deploy() {
    return this.startDeployment();
  }

  testLevel = "RunSpecifiedTests";
  testLevelOptions = [
    {
      label: "RunSpecifiedTests",
      value: "RunSpecifiedTests"
    },
    // TODO: make this available when it comes out of beta
    // {
    //   label: "RunRelevantTests",
    //   value: "RunRelevantTests"
    // },
    {
      label: "RunLocalTests",
      value: "RunLocalTests"
    }
  ];

  isLoading = true;
  isNotDeploying = true;
  isAdvancedMode = false;
  isHealthy = false;
  needsUpdates = false;
  generatedApex = [];

  async connectedCallback() {
    this.fetchGeneratedApex();
  }

  async fetchGeneratedApex() {
    this.isLoading = true;
    try {
      this.generatedApex = await getChildTriggerInfo({
        rollupName: this.rollupName
      });
    } catch (err) {
      console.error("Error retrieving generated code:", err);
      throw err;
    }
    this.generatedApex.forEach((apx) => {
      if (apx.existingBody) {
        if (apx.apiVersion !== apx.existingApiVersion) {
          apx.needsApiUpdate = true;
        }
        if (apx.body !== apx.existingBody) {
          apx.needsBodyUpdate = true;
        }
        if (apx.needsBodyUpdate || apx.needsApiUpdate) {
          this.needsUpdates = true;
          apx.changeType = "update";
          apx.changeIcon = "utility:replace";
          apx.changeIconVariant = "warning";
          apx.changeIconAltText = "An update will be deployed";
          apx.changeOptions = EXISTING_CODE_WITH_UPDATES;
        } else {
          apx.changeType = "ignore";
          apx.changeIcon = "utility:check";
          apx.changeIconVariant = "";
          apx.changeIconAltText = "No change will happen";
          apx.changeOptions = EXISTING_CODE_UP_TO_DATE;
        }
      } else {
        apx.changeType = "deploy";
        apx.changeIcon = "utility:upload";
        apx.changeIconVariant = "success";
        apx.changeIconAltText = "Will be deployed";
        apx.changeOptions = NEW_CODE;
      }
    });
    // if everything is ignore, then default them to remove
    if (
      this.generatedApex.length ===
      this.generatedApex.filter((apx) => apx.changeType === "ignore").length
    ) {
      this.isHealthy = true;
      this.generatedApex.forEach((apx) => {
        apx.changeType = "remove";
        apx.changeIconVariant = "error";
        apx.changeIcon = "utility:clear";
        apx.changeIconAltText = "Will be removed via deployment";
      });
    }
    this.isLoading = false;
  }

  async startDeployment() {
    this.refs.deploymentMonitor.monitorDeployment("WAIT");
    this.isLoading = true;
    this.isNotDeploying = false;
    // figure out which elements should be deployed
    // build the list and send it to Apex to build and deploy the zip
    const changePlan = {
      delete: {},
      deploy: {}
    };
    const testsToRun = [];
    let testLevel = "RunSpecifiedTests";
    if (this.isAdvancedMode) {
      testLevel = this.testLevel;
      this.template
        .querySelectorAll("lightning-select[data-mdt-type]")
        .forEach((sel) => {
          const asset = this.generatedApex.find(
            (apx) => apx.assetName === sel.name
          );
          asset.changeType = sel.value;
        });
      testsToRun.push(
        ...this.refs.testsToRun.value.split(",").map((val) => val.trim())
      );
    }
    this.generatedApex.forEach((asset) => {
      if (asset.changeType === "ignore") {
        return;
      }
      if (asset.testedBy) {
        testsToRun.push(...asset.testedBy);
      }
      const actionType = changePlan[SELECT_OPTIONS[asset.changeType].action];
      if (actionType[asset.mdtType] == null) {
        actionType[asset.mdtType] = [];
      }
      actionType[asset.mdtType].push(asset.assetName);
    });
    await startDeployment({
      rollupName: this.rollupName,
      changes: changePlan,
      testLevel,
      testsToRun
    });
    this.lastDeployStatus = "Started";
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Deployment Started",
        variant: "info"
      })
    );

    this.dispatchEvent(new CustomEvent("deploymentstarted"));
  }

  handleDeploymentCompleted(event) {
    const deployResult = event.detail.deployResult;
    if (deployResult.success === true) {
      this.isNotDeploying = true;
      this.isLoading = false;
      this.dispatchEvent(
        new CustomEvent("deploymentcompleted", { detail: event.detail })
      );
    }
  }

  handleAdvancedToggle(event) {
    this.isAdvancedMode = event.target.checked;
  }

  handleTestLevelChange(event) {
    this.testLevel = event.target.value;
  }

  get shouldDisplayTestInput() {
    return this.isAdvancedMode && this.testLevel === "RunSpecifiedTests";
  }

  get isBasicMode() {
    return !this.isAdvancedMode;
  }
}

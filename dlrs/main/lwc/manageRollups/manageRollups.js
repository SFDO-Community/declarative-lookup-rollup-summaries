import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAllRollupConfigs from "@salesforce/apex/RollupEditorController.getAllRollupConfigs";
import USER_ID from "@salesforce/user/Id";

import {
  subscribe,
  unsubscribe,
  onError,
  isEmpEnabled
} from "lightning/empApi";

export default class ManageRollups extends LightningElement {
  // We only want events for which we've been assigned as the recipient
  channelName = `/event/UserNotification__e?Recipient__c='${USER_ID.substring(
    1,
    15
  )}'`;
  subscription = {};

  rollups = {};
  selectedRollup = undefined;

  async connectedCallback() {
    this.rollups = await getAllRollupConfigs();
    // Register error listener
    this.registerErrorListener();
    this.handleSubscribe();
  }

  rollupSelectHandler(event) {
    this.selectedRollup = event.currentTarget.dataset.apiName;
  }

  get rollupList() {
    if (!this.rollups) {
      return [];
    }
    return Object.values(this.rollups);
  }

  ////////////////////
  // Tracks changes to channelName text field
  handleChannelName(event) {
    this.channelName = event.target.value;
  }

  disconnectedCallback() {
    this.handleUnsubscribe();
  }

  // Handles subscribe button click
  handleSubscribe() {
    if (!isEmpEnabled) {
      console.error("Emp API Is not currently enabled");
      return;
    }
    // Callback invoked whenever a new event message is received
    const messageCallback = (response) => {
      console.log("New message received: ", JSON.stringify(response));
      if (!USER_ID.startsWith(response.data.payload.Recipient__c)) {
        // This message isn't for us, don't do anything
        return;
      }
      // TODO: handle this way better

      let title, message, messageData, variant, mode;
      const deploymentData = JSON.parse(response.data.payload.Payload__c);
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

    // Invoke subscribe method of empApi. Pass reference to messageCallback
    subscribe(this.channelName, -1, messageCallback).then((response) => {
      // Response contains the subscription information on subscribe call
      this.subscription = response;
      this.toggleSubscribeButton(true);
    });
  }

  // Handles unsubscribe button click
  handleUnsubscribe() {
    this.toggleSubscribeButton(false);

    // Invoke unsubscribe method of empApi
    unsubscribe(this.subscription, (response) => {
      console.log("unsubscribe() response: ", JSON.stringify(response));
      // Response is true for successful unsubscribe
    });
  }

  registerErrorListener() {
    // Invoke onError empApi method
    onError((error) => {
      console.error("Received error from server: ", JSON.stringify(error));
      // Error contains the server-side error
    });
  }
}

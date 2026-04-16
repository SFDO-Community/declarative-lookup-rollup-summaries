// imported in the top-level component, once per-page
// this subscribes to UserNotification__e platform events and
// republishes to the UserNotification messaging channel
import { LightningElement, wire } from "lwc";
import { publish, MessageContext } from "lightning/messageService";
import {
  subscribe,
  unsubscribe,
  onError,
  isEmpEnabled
} from "lightning/empApi";

import userNotification from "@salesforce/messageChannel/UserNotification__c";
import USER_ID from "@salesforce/user/Id";

import { buildApiName } from "c/utils";

export default class NotificationListener extends LightningElement {
  @wire(MessageContext)
  messageContext;

  channelName = `/event/${buildApiName("UserNotification__e")}`;
  subscription = {};

  connectedCallback() {
    this.registerErrorListener();
    this.handleSubscribe();
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
      if (
        !USER_ID.startsWith(response.data.payload[buildApiName("Recipient__c")])
      ) {
        // This message isn't for us, don't do anything
        return;
      }

      const payload = {
        payload: response.data.payload[buildApiName("Payload__c")],
        type: response.data.payload[buildApiName("Type__c")],
        recipient: response.data.payload[buildApiName("Recipient__c")]
      };

      publish(this.messageContext, userNotification, payload);
    };

    // Invoke subscribe method of empApi. Pass reference to messageCallback
    subscribe(this.channelName, -1, messageCallback).then((response) => {
      // Response contains the subscription information on subscribe call
      this.subscription = response;
    });
  }

  // Handles unsubscribe button click
  handleUnsubscribe() {
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

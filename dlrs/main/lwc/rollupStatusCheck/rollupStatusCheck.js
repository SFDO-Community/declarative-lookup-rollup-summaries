import { LightningElement, api, wire, track } from "lwc";

import getAllScheduledItems from "@salesforce/apex/LookupRollupStatusCheckController.getAllScheduledItems";
import getSpecificScheduledItems from "@salesforce/apex/LookupRollupStatusCheckController.getSpecificScheduledItems";
import hasChildTriggerDeployed from "@salesforce/apex/LookupRollupStatusCheckController.hasChildTriggerDeployed";
import hasParentTriggerDeployed from "@salesforce/apex/LookupRollupStatusCheckController.hasParentTriggerDeployed";
import getScheduledFullCalculates from "@salesforce/apex/LookupRollupStatusCheckController.getScheduledFullCalculates";
import getCalculateJobs from "@salesforce/apex/LookupRollupStatusCheckController.getCalculateJobs";
import getScheduledJobs from "@salesforce/apex/LookupRollupStatusCheckController.getScheduledJobs";

const mockLookupRollupSummary2 = '';

export default class rollupStatusCheck extends LightningElement {

  // Khang Ly contribute
  header = 'Status Check';  

  lookupID;

  // General status check variables
  scheduledCronJobs = "No Rollup Jobs Found";
  recordCountAll = "0";

  // Rollup Specific Status Check Variables
  recordCount = "0";
  nextFullCalculateDate = "NA";
  triggerCount = "0";
  parentTrigger = "NA";
  childTrigger = "NA";
  calculateJobError = "No Errors Found";
  
  // Error Handling
  error = [];

  connectedCallback() {
    console.log("connectedCallback");
    console.log("my lookup id is :" + this._name);
    this.allScheduleItems();
    this.scheduleJobs();
  } 


  // Get record lookup from parent component
  @track _name = mockLookupRollupSummary2;
  @api
  get name() { 
    return this._name; 
  }
  set name(value) { 
    this._name = value; 
  }

  // Method to check if there are any failed calculate jobs for the specific rollup
  @wire(getCalculateJobs, { lookupID : '$_name'})
  wiredGetCalculateJobs({error, data}){ this.handleApexResponse(data, error, 'calculateJobError'); }

  // Method to check if there are any scheduled full calculates for the specific rollup
  @wire(getScheduledFullCalculates, { lookupID : '$_name'})
  wiredGetScheduledFullCalculates({error, data}){ this.handleApexResponse(data, error, 'nextFullCalculateDate'); }

  // Method to check if there are any scheduled items for the specific rollup
  @wire(getSpecificScheduledItems, { lookupID : '$_name'})
  wiredGetSpecificScheduledItems({error, data}){ this.handleApexResponse(data, error, 'recordCount'); }

  // Method to check if child triggers are present
  @wire(hasChildTriggerDeployed, { lookupID : '$_name'})
  wiredHasChildTriggerDeployed({error, data}){ this.handleApexResponse(data, error, 'childTrigger'); }

  // Method to check if child triggers are present
  @wire(hasParentTriggerDeployed, { lookupID : '$_name' })
  wiredHasParentTriggerDeployed({ error, data }){ this.handleApexResponse(data, error, 'parentTrigger'); }

  // General status method to grab all scheduled items regardless of rollup
  async allScheduleItems() {
    let data, error;
    try{ data = await getAllScheduledItems(); } 
    catch(err){ error = err }
    this.handleApexResponse(data, error, 'recordCountAll');
  }

  async scheduleJobs() {
    let data, error;
    try{ data = await getScheduledJobs(); } 
    catch(err){ error = err }
    this.handleApexResponse(data, error, 'scheduledCronJobs');
  }

// *** Utility ***
  handleApexResponse(data, error, propertyName){
    if(data){
      console.log(propertyName + '- data: ' + data);
      this[propertyName] = data;
    } else if(error){
      console.log(propertyName + '- error: ' + error);
      this.error.push(error);
    }
  }
}

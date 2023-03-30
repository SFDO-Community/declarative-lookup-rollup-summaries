import { LightningElement } from 'lwc';
import getAllScheduledItems from '@salesforce/apex/LookupRollupStatusCheckController.getAllScheduledItems';
import getSpecificScheduledItems from '@salesforce/apex/LookupRollupStatusCheckController.getSpecificScheduledItems';
import hasChildTriggerDeployed from '@salesforce/apex/LookupRollupStatusCheckController.hasChildTriggerDeployed';
import hasParentTriggerDeployed from '@salesforce/apex/LookupRollupStatusCheckController.hasParentTriggerDeployed';
import getScheduledFullCalculates from '@salesforce/apex/LookupRollupStatusCheckController.getScheduledFullCalculates';
import getCalculateJobs from '@salesforce/apex/LookupRollupStatusCheckController.getCalculateJobs';

export default class Test extends LightningElement {

    recordCount = '0';
    recordCountAll = '0';
    nextFullCalculateDate = 'NA';
    triggerCount = '0';
    parentTrigger = 'NA';
    childTrigger = 'NA';
    calculateJobError = 'No Errors Found';
    error = [];

    connectedCallback() {
        console.log('connectedCallback');

        this.allScheduleItems();
        this.specificScheduleItems();
        this.childTriggers();
        this.parentTriggers();
        this.scheduledFullCalculate();
        this.calculateJobs();

    }

    // Method to check if there are any failed calculate jobs for the specific rollup
    calculateJobs(){
        console.log('calculateJobs');
        getCalculateJobs({ lookupID : 'm008N000000AnYwQAK'}).then(result => {
            this.calculateJobError = result;
        }).catch(error => {
            this.error.push(error);
            console.log(error);
        });
    }

    // Method to check if there are any scheduled full calculates for the specific rollup
    scheduledFullCalculate(){
        console.log('scheduledFullCalculate');
        getScheduledFullCalculates({ lookupID : 'm008N000000AnYwQAK'}).then(result => {
            this.nextFullCalculateDate = result;
        }).catch(error => {
            this.error.push(error);
            console.log(error);
        });
    }

    // Method to check if there are any scheduled items for the specific rollup
    specificScheduleItems(){
        console.log('specificScheduleItems');
        getSpecificScheduledItems({ lookupID : 'm008N000000AnYwQAK'})
        .then(result => {
            this.recordCount = result;
        })
        .catch(error => {
            this.error.push(error);
            console.log(error);
        });
    }

    // Method to check if child triggers are present
    childTriggers(){
        console.log('childTriggers');
        hasChildTriggerDeployed({ lookupID : 'm008N000000AnYwQAK'})
        .then(result => {
            this.childTrigger = result;
        })
        .catch(error => {
            this.error.push(error);
            console.log(error);
        });
    }

    // Method to check if child triggers are present
    parentTriggers(){
        console.log('childTriggers');
        hasParentTriggerDeployed({ lookupID : 'm008N000000AnYwQAK'})
        .then(result => {
            this.parentTrigger = result;
        })
        .catch(error => {
            this.error.push(error);
            console.log(error);
        });
    }

    // General status method to grab all scheduled items regardless of rollup
    allScheduleItems(){
        console.log('allScheduleItems');
        getAllScheduledItems()
        .then(result => {
            this.recordCountAll = result;
        })
        .catch(error => {
            this.error.push(error);
            console.log(error);
        });
    }
}
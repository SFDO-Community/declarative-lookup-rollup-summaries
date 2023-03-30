import { LightningElement, api } from 'lwc';
import getAllScheduledItems from '@salesforce/apex/LookupRollupStatusCheckController.getAllScheduledItems';
import getSpecificScheduledItems from '@salesforce/apex/LookupRollupStatusCheckController.getSpecificScheduledItems';
import hasChildTriggerDeployed from '@salesforce/apex/LookupRollupStatusCheckController.hasChildTriggerDeployed';
import hasParentTriggerDeployed from '@salesforce/apex/LookupRollupStatusCheckController.hasParentTriggerDeployed';
import getScheduledFullCalculates from '@salesforce/apex/LookupRollupStatusCheckController.getScheduledFullCalculates';
import getCalculateJobs from '@salesforce/apex/LookupRollupStatusCheckController.getCalculateJobs';
import getScheduledJobs from '@salesforce/apex/LookupRollupStatusCheckController.getScheduledJobs';

export default class rollupStatusCheck extends LightningElement {

    // Get record lookup from parent component
    _name;
    lookupID;

    // General status check variables
    scheduledCronJobs = 'No Jobs Found';
    recordCountAll = '0';

    // Rollup Specific Status Check Variables
    recordCount = '0';
    nextFullCalculateDate = 'NA';
    triggerCount = '0';
    parentTrigger = 'NA';
    childTrigger = 'NA';
    calculateJobError = 'No Errors Found';

    // Error Handling
    error = [];

    connectedCallback() {
        console.log('connectedCallback');
        console.log('my lookup id is :' + this._name );

        if(this._name  == null){
        // General Status Checks
        this.allScheduleItems();
        this.scheduleJobs();
        } else {
            
        // General Status Checks
        this.allScheduleItems();
        this.scheduleJobs();

        // Rollup Specific Status Checks
        this.specificScheduleItems();
        this.childTriggers();
        this.parentTriggers();
        this.scheduledFullCalculate();
        this.calculateJobs();
        }
    }

    @api
    get name(){
        return this._name;
    }

    set name(value){
        // Rollup Specific Status Checks
        this._name = value;
        this.specificScheduleItems();
        this.childTriggers();
        this.parentTriggers();
        this.scheduledFullCalculate();
        this.calculateJobs();
        
    }

    // Method to check if there are any failed calculate jobs for the specific rollup
    calculateJobs(){
        console.log('calculateJobs');
        getCalculateJobs({ lookupID : this._name }).then(result => {
            this.calculateJobError = result;
        }).catch(error => {
            this.error.push(error);
            console.log(error);
        });
    }

    // Method to check if there are any scheduled full calculates for the specific rollup
    scheduledFullCalculate(){
        console.log('scheduledFullCalculate');
        getScheduledFullCalculates({ lookupID : this._name }).then(result => {
            this.nextFullCalculateDate = result;
        }).catch(error => {
            this.error.push(error);
            console.log(error);
        });
    }

    // Method to check if there are any scheduled items for the specific rollup
    specificScheduleItems(){
        console.log('specificScheduleItems');
        getSpecificScheduledItems({ lookupID : this._name })
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
        hasChildTriggerDeployed({ lookupID : this._name })
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
        hasParentTriggerDeployed({ lookupID : this._name })
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

    scheduleJobs(){
        console.log('All Scheduled Cron Jobs');
        getScheduledJobs()
        .then(result => {
            this.scheduledCronJobs = result;
        })
        .catch(error => {
            this.error.push(error);
            console.log(error);
        });        
    }
}
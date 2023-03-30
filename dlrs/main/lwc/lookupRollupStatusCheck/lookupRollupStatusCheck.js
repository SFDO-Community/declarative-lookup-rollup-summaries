import { LightningElement, track } from 'lwc';
import getAllScheduledItems from '@salesforce/apex/LookupRollupStatusCheckController.getAllScheduledItems';
import getSpecificScheduledItems from '@salesforce/apex/LookupRollupStatusCheckController.getSpecificScheduledItems';
import hasChildTriggers from '@salesforce/apex/LookupRollupStatusCheckController.hasChildTriggers';

export default class LookupRollupStatusCheck extends LightningElement {

    @track recordCount = '0';
    @track recordCountAll = '0';
    @track triggerCount = '0';
    @track error;

    handleLoad(){
        getAllScheduledItems()
            .then(result => {
                this.recordCount = result;
                console.log(result);
            })
            .catch(error => {
                this.error = error;
                console.log(error);
        });

        getSpecificScheduledItems()
        .then(result => {
            this.recordCountAll = result;
            console.log(result);
        })
        .catch(error => {
            this.error = error;
            console.log(error);
        });

        hasChildTriggers()
        .then(result => {
            this.triggerCount = result;
            console.log(result);
        })
        .catch(error => {
            this.error = error;
            console.log(error);
        });
    }

}
import { LightningElement } from 'lwc';

export default class ParentRollupStatusCheck extends LightningElement {

    lookupID = 'm008N000000AnYwQAK';

    handleInputChange(event) {
        if(event.keyCode === 13){
        this.lookupID = this.template.querySelector('lightning-input').value;

        console.log(this.lookupID);
        }
    }
}
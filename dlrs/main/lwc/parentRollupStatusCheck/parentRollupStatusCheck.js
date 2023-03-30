import { LightningElement } from 'lwc';

export default class ParentRollupStatusCheck extends LightningElement {

    lookupID = '';

    handleInputChange(event) {
        console.log('handleInputChange');
        if(event.keyCode === 13){
        this.lookupID = this.template.querySelector('lightning-input').value;
        console.log(this.lookupID);
        }

        
    }
}
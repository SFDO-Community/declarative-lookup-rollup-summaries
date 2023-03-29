import { LightningElement, track } from 'lwc';

export default class RollupEditor extends LightningElement {

    @track rollup = {
        name: '',
        label: '',
        relationshipField: '',
        relationshipCriteria: '',
        relationshipCriteriaFields: ''
      };
}
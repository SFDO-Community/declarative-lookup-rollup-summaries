import { LightningElement,api,wire } from 'lwc';

import getAllObjects from '@salesforce/apex/ObjectSelectorController.getParentObjList';

const DELAY = 300; // delay apex callout timing in miliseconds  
export default class ObjectSelector extends LightningElement {
  // public properties with initial default values 
  @api label = 'Object';
  @api placeholder = 'Search...'; 
  @api iconName = 'standard:account';
@api currentSelection;
  // private properties 
  lstResult = []; // to store list of returned records   
  hasRecords = true; 
  searchKey=''; // to store input field value    
  isSearchLoading = false; // to control loading spinner  
  delayTimeout;
  selectedRecord = {}; // to store selected lookup record in object formate 
   mapData = [];
  connectedCallback(){
  
    //GET LIST OF ALL OBJECTS
    getAllObjects()
    .then((result) => {
        if(result != null){
             this.mapData=JSON.parse(JSON.stringify(result));
        }
    })
    .catch((error) => {
        this.error = error;
        this.mapData = {};
    });
 }


 // update searchKey property on input field change  
 handleKeyChange(event) {
    // Debouncing this method: Do not update the reactive property as long as this function is
    // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
   
   
    var matchedRecords=[];
    this.isSearchLoading = true;
    window.clearTimeout(this.delayTimeout);
    const searchKey = event.target.value;
    this.delayTimeout = setTimeout(() => {
     matchedRecords = this.mapData.filter(function(link){
        return link.toLowerCase().includes(searchKey.toLowerCase())
      });

    this.hasRecords = matchedRecords.length == 0 ? false : true; 
    this.lstResult = JSON.parse(JSON.stringify(matchedRecords));
    }, DELAY);
   
}

 // method to toggle lookup result section on UI 
 toggleResult(event){
    const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
    const clsList = lookupInputContainer.classList;
    const whichEvent = event.target.getAttribute('data-source');
    switch(whichEvent) {
        case 'searchInputField':
            clsList.add('slds-is-open');
           break;
        case 'lookupContainer':
            clsList.remove('slds-is-open');    
        break;                    
       }
}

  // method to clear selected lookup record  
  handleRemove(){
    this.searchKey = '';    
    this.selectedRecord = {};
    this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function 
    
    // remove selected pill and display input field again 
    const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-hide');
     searchBoxWrapper.classList.add('slds-show');
     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-show');
     pillDiv.classList.add('slds-hide');
  }
  // method to update selected record from search result 
handelSelectedRecord(event){ 
     var objId = event.target.getAttribute('data-recid'); // get selected record Id  
     this.selectedRecord = this.lstResult.find(data => data === objId); // find selected record from list 
     this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function 
     this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
}
/*COMMON HELPER METHOD STARTED*/
handelSelectRecordHelper(){
    this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
     const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-show');
     searchBoxWrapper.classList.add('slds-hide');
     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-hide');
     pillDiv.classList.add('slds-show');     
}
// send selected lookup record to parent component using custom event
lookupUpdatehandler(value){    
    //Send only the API Name in the event
    var regExp = /\(([^)]+)\)/;
    var retVal = regExp.exec(JSON.stringify(value));
      const oEvent = new CustomEvent('lookupupdate',
      {
          'detail': {selectedRecord: retVal[1]}
      }
  );
  this.dispatchEvent(oEvent);
}




}

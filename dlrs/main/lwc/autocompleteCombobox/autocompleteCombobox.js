import { LightningElement, api, track } from "lwc";

const DELAY = 300; // timing in miliseconds

export default class AutocompleteCombobox extends LightningElement {

//  *** PROPERTIES ***

    @api label;
    @api placeholder;
    @api helperText;

    @track selectedOption = {};
    @api 
    get value(){ return this.selectedOption.value; }
    set value(selectedValue){
        if(!selectedValue) return;
        console.log('selectedValue: ' + selectedValue);
        this.searchKey = selectedValue;
        this.selectOptionBySearchKey();
        this.showSelectionInput();
    }

    @track filteredOptions = [];
    _firstTimeSetOptions = true; // handle when "Set Value" is executed before "Set Options"
    _options = [];
    @api
    get options(){ return this._options; }
    set options(val){ 
        if(!val || val.length === 0) return;
        this._options = val; 
        this.filterOptionsBySearchKey();
        if(this._firstTimeSetOptions){
            this.selectOptionBySearchKey();
            this.showSelectionInput();
            this._firstTimeSetOptions = false
        }
    }

    @track isLoading = false;
    @track searchKey = ""; 

    get styleClassCombobox(){
        let styleClass = "slds-combobox__form-element slds-input-has-icon slds-input-has-icon_left-right";
        if(this.selectedOption && !this.selectedOption.icon){
            styleClass = styleClass.replace('slds-input-has-icon_left-right' , 'slds-input-has-icon_right');
        }
        return styleClass;
    }

// *** EVENT METHODS ***

    onToggleDropdown(event){
        const targetDataSource = event.target.getAttribute("data-source");
        const lookupInputContainer = this.template.querySelector(
            ".lookupInputContainer"
        );
        const clsList = lookupInputContainer.classList;
        const whichEvent = targetDataSource;
        switch (whichEvent) {
            case "searchInputField":
                clsList.add("slds-is-open");
                break;
            case "lookupContainer":
                clsList.remove("slds-is-open");
                break;
            default: break;
        }
    }

    onChangeSearchKey(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        this.isLoading = true;
        window.clearTimeout(this.delayTimeout);
        this.searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => { // eslint-disable-line
            this.filterOptionsBySearchKey();
            this.isLoading = false;
        }, DELAY);
    }

    onSelectOption(event) {
        this.searchKey = event.target.getAttribute("data-name");
        this.selectOptionBySearchKey();
        this.showSelectionInput();
        this.dispatchSelectionEvent()
    }

    // method to clear selected lookup record
    onRemoveSelection() {
        this.searchKey = "";
        this.selectedOption = {};
        this.filterOptionsBySearchKey();
        this.showSearchInput();
        this.dispatchSelectionEvent();
    }


// *** CONTROLLER

    filterOptionsBySearchKey() {
        try {
            const lowerCaseSearchKey = this.searchKey.toLowerCase();
            this.filteredOptions = this._options.filter(({value, label}) => {
                return value.toLowerCase().includes(lowerCaseSearchKey)
                    || label.toLowerCase().includes(lowerCaseSearchKey);
            })
        } catch(error){
            this.filteredOptions = this._options;
        }
    }

    selectOptionBySearchKey(){
        try{
            const lowerCaseValue = this.searchKey.toLowerCase();
            this.selectedOption = this._options.find(option => {
                return option.value.toLowerCase().includes(lowerCaseValue)
            })
            if(!this.selectedOption) this.selectedOption = {};
        }catch(error){
            this.selectedOption = {};
        }
    }

    dispatchSelectionEvent(){
        const _event = new CustomEvent("changeselection", {
            detail: { selectedOption: this.selectedOption }
        });
        this.dispatchEvent(_event); 
    }

// *** UI HELPER ***

    showSelectionInput() {
        if(!this.selectedOption) return;
        try {
            const inputElement = this.template.querySelector(".lookupInputContainer");
            inputElement.classList.remove('slds-is-open');

            const searchBoxWrapper = this.template.querySelector(".searchBoxWrapper");
            searchBoxWrapper.classList.remove("slds-show");
            searchBoxWrapper.classList.add("slds-hide");

            const pillDiv = this.template.querySelector(".pillDiv");
            pillDiv.classList.remove("slds-hide");
            pillDiv.classList.add("slds-show");
        } catch(err){
            console.log(err);
        }
    }

    showSearchInput(){
        // remove selected pill and display input field again
        const searchBoxWrapper = this.template.querySelector(".searchBoxWrapper");
        searchBoxWrapper.classList.remove("slds-hide");
        searchBoxWrapper.classList.add("slds-show");

        const pillDiv = this.template.querySelector(".pillDiv");
        pillDiv.classList.remove("slds-show");
        pillDiv.classList.add("slds-hide");
    }


}
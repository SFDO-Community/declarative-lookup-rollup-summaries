import { LightningElement, api, track } from "lwc";

const DELAY = 100; // timing in miliseconds

export default class AutocompleteCombobox extends LightningElement {
  //  *** PROPERTIES ***

  @api label;
  @api placeholder;
  @api helperText;
  @api disabled = false;

  @track selectedOption = {};
  @track _value = "";
  @api
  get value() {
    return this._value;
  }
  set value(val) {
    this._value = val;
    this.selectOptionByValue();
    if (this._value) {
      this.showSelectionInput();
    } else {
      this.showSearchInput();
    }
  }
  _firstTimeSetOptions = true;
  @track filteredOptions = [];
  _options = [];
  @api
  get options() {
    return this._options;
  }
  set options(val) {
    this._options = val ? val : [];
    this.filteredOptions = this._options;
    this.searchKey = "";
    this.selectedOption = {};
    if (this._value) {
      this.selectOptionByValue();
      this.showSelectionInput();
    } else {
      this.showSearchInput();
    }
  }
  @track isLoading = false;
  @track searchKey = "";
  get styleClassCombobox() {
    let styleClass =
      "slds-combobox__form-element slds-input-has-icon slds-input-has-icon_left-right";
    if (this.selectedOption && !this.selectedOption.icon) {
      styleClass = styleClass.replace(
        "slds-input-has-icon_left-right",
        "slds-input-has-icon_right"
      );
    }
    return styleClass;
  }
  // *** EVENT METHODS ***
  onToggleDropdown(event) {
    const lookupInputContainer = this.template.querySelector(
      ".lookupInputContainer"
    );
    const clsList = lookupInputContainer.classList;
    if (clsList.contains('slds-is-open')) {
      // Allow enough time for the click handler of the object list to run before we burn the elements
      // 310 is chosen because on some mobile devices clicks can take up to 300ms to fire
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        clsList.remove("slds-is-open");
      }, 310);
    } else {
      clsList.add('slds-is-open');
    }
  }
  onChangeSearchKey(event) {
    // Debouncing this method: Do not update the reactive property as long as this function is
    // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
    this.isLoading = true;
    window.clearTimeout(this.delayTimeout);
    this.searchKey = event.target.value;
    this.delayTimeout = setTimeout(() => {
      // eslint-disable-line
      this.filterOptions(this.searchKey);
      this.isLoading = false;
    }, DELAY);
  }
  onSelectOption(event) {
    this._value = event.target.getAttribute("data-name");
    this.selectOptionByValue();
    this.showSelectionInput();
    this.dispatchSelectionEvent();
  }
  // method to clear selected lookup record
  onRemoveSelection() {
    this._value = "";
    this.searchKey = "";
    this.selectedOption = {};
    this.filteredOptions = this._options;
    this.showSearchInput();
    this.dispatchSelectionEvent();
  }
  // *** CONTROLLER
  filterOptions(searchKey) {
    try {
      const lowerCaseSearchKey = searchKey.toLowerCase();
      this.filteredOptions = this._options.filter(({ value, label }) => {
        return (
          value.toLowerCase().includes(lowerCaseSearchKey) ||
          label.toLowerCase().includes(lowerCaseSearchKey)
        );
      });
    } catch (error) {
      this.filteredOptions = this._options;
    }
  }
  selectOptionByValue() {
    if (!this._value) {
      this.selectedOptions = {};
      this.searchKey = "";
      return;
    }
    try {
      const lowerCaseValue = this._value.toLowerCase();
      this.selectedOption = this._options.find((option) => {
        return option.value.toLowerCase().includes(lowerCaseValue);
      });
      this.searchKey = this.selectedOption.label;
    } catch (error) {
      this.selectedOption = {};
      this.searchKey = "";
    }
  }
  dispatchSelectionEvent() {
    const _event = new CustomEvent("changeselection", {
      detail: { selectedOption: this.selectedOption }
    });
    this.dispatchEvent(_event);
  }
  // *** UI HELPER ***
  showSelectionInput() {
    try {
      if (!this.selectedOption.value) return;
      const inputElement = this.template.querySelector(".lookupInputContainer");
      if (inputElement) {
        inputElement.classList.remove("slds-is-open");
      }
      const searchBoxWrapper = this.template.querySelector(".searchBoxWrapper");
      if (searchBoxWrapper) {
        searchBoxWrapper.classList.remove("slds-show");
        searchBoxWrapper.classList.add("slds-hide");
      }
      const pillDiv = this.template.querySelector(".pillDiv");
      if (pillDiv) {
        pillDiv.classList.remove("slds-hide");
        pillDiv.classList.add("slds-show");
      }
    } catch (err) {
      console.log(err);
    }
  }
  showSearchInput() {
    try {
      // remove selected pill and display input field again
      const searchBoxWrapper = this.template.querySelector(".searchBoxWrapper");
      if (searchBoxWrapper) {
        searchBoxWrapper.classList.remove("slds-hide");
        searchBoxWrapper.classList.add("slds-show");
      }
      const pillDiv = this.template.querySelector(".pillDiv");
      if (pillDiv) {
        pillDiv.classList.remove("slds-show");
        pillDiv.classList.add("slds-hide");
      }
    } catch (error) {
      console.log(error);
    }
  }
}

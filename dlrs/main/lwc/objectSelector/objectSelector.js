import { LightningElement, api, wire } from "lwc";
import getAllObjects from "@salesforce/apex/ObjectSelectorController.getParentObjList";
import jsLevenshtein from "./js-levenshtein";
import { getObjectInfos } from "lightning/uiObjectInfoApi";

const DELAY = 100; // delay apex callout timing in miliseconds
const MAX_RESULTS = 5;
export default class ObjectSelector extends LightningElement {
  // public properties with initial default values
  @api label = "Object";
  @api placeholder = "Select on object";
  @api iconName = "standard:custom"; // would be awesome to use the correct icon
  _currentSelection;
  @api
  get currentSelection() {
    return this._currentSelection;
  }
  set currentSelection(val) {
    this._currentSelection = val;
    this.selectObject(val);
  }
  // private properties
  objectApiNames = [];
  objectIconCache;
  lstResult = []; // to store list of returned records
  searchKey = ""; // to store input field value
  isSearchLoading = false; // to control loading spinner
  delayTimeout;
  selectedRecord = "";
  selectedRecordIconName;
  objects;
  preventBlur = false;
  connectedCallback() {
    this.selectedRecordIconName = this.iconName;
    this.isSearchLoading = true;
    //GET LIST OF ALL OBJECTS
    getAllObjects()
      .then((objects) => {
        if (objects != null) {
          this.objects = objects.map((o) => {
            return { ...o, iconName: this.iconName };
          });
          this.objectApiNames = objects.map((o) => o.fullName);
          if (this.currentSelection) {
            this.selectObject(this.currentSelection);
          }
        }
      })
      .catch((error) => {
        this.error = error;
        this.objects = {};
      })
      .finally(() => {
        this.isSearchLoading = false;
      });
  }

  // use the UI API to determine the iconName for each object
  // this call is slow and if you're interacting with the UI before this loads
  // you'll get the generic/fallback icon
  @wire(getObjectInfos, { objectApiNames: "$objectApiNames" })
  wiredObjectInfos({ data }) {
    if (data) {
      // try and extract the Icon path from
      const iconNameRegEx = /(\w+)\/(\w+)(?:_\d+)\./;
      const objectIconCache = data.results
        .filter((r) => r.statusCode === 200)
        .filter((r) => r.result.themeInfo)
        .reduce((t, v) => {
          t[v.result.apiName] = v.result?.themeInfo;
          return t;
        }, {});
      this.objects.forEach((o) => {
        if (!objectIconCache[o.fullName]?.iconUrl) {
          return;
        }
        o.iconUrl = objectIconCache[o.fullName].iconUrl;
        o.iconColor = `#${objectIconCache[o.fullName].color}`;
        o.iconStyle = `background-color: #${
          objectIconCache[o.fullName].color
        };`;
        if (o.iconUrl) {
          const matches = iconNameRegEx.exec(o.iconUrl);
          if (matches) {
            o.iconName = `${matches[1]}:${matches[2]}`;
          }
        }
      });
    }
  }

  get isReady() {
    return !this.objects;
  }

  // update searchKey property on input field change
  handleKeyChange(event) {
    window.clearTimeout(this.delayTimeout);
    const searchKey = event.target.value;
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.delayTimeout = setTimeout(() => {
      // Require at least two character for matches
      if (searchKey.trim().length < 2) {
        this.lstResult = [];
        return;
      }
      // constrain results to those containing the text
      this.lstResult = this.objects.filter(function (obj) {
        return (
          obj.fullName.toLowerCase().includes(searchKey.toLowerCase()) ||
          obj.label.toLowerCase().includes(searchKey.toLowerCase())
        );
      });
      // sort by most similar, either label or API name
      this.lstResult.sort((a, b) => {
        return (
          // take the nearest of the Label and API name
          Math.min(
            jsLevenshtein(searchKey.toLowerCase(), `${a.fullName}`),
            jsLevenshtein(searchKey.toLowerCase(), `${a.label}`)
          ) -
          Math.min(
            jsLevenshtein(searchKey.toLowerCase(), `${b.fullName}`),
            jsLevenshtein(searchKey.toLowerCase(), `${b.label}`)
          )
        );
      });
      // limit to the MAX_RESULTS closest matches
      this.lstResult.splice(MAX_RESULTS);
    }, DELAY);
  }

  showResultList() {
    const lookupInputContainer = this.template.querySelector(
      ".lookupInputContainer"
    );
    const clsList = lookupInputContainer.classList;
    clsList.add("slds-is-open");
  }

  hideResultList() {
    // Allow enough time for the click handler of the object list to run before we burn the elements
    // 310 is chosen because on some mobile devices clicks can take up to 300ms to fire
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      const lookupInputContainer = this.template.querySelector(
        ".lookupInputContainer"
      );
      const clsList = lookupInputContainer.classList;
      clsList.remove("slds-is-open");
    }, 310);
  }

  // method to toggle lookup result section on UI
  toggleResult(event) {
    const lookupInputContainer = this.template.querySelector(
      ".lookupInputContainer"
    );
    const clsList = lookupInputContainer.classList;
    const whichEvent = event.target.getAttribute("data-source");
    switch (whichEvent) {
      case "searchInputField":
        clsList.add("slds-is-open");
        break;
      case "lookupContainer":
        clsList.remove("slds-is-open");
        break;
      default:
        break;
    }
  }

  // method to clear selected lookup record
  handleRemove() {
    this.searchKey = "";
    this.selectedRecord = "";
    this.lstResult = [];
    this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function

    // remove selected pill and display input field again
    const searchBoxWrapper = this.template.querySelector(".searchBoxWrapper");
    if (searchBoxWrapper) {
      searchBoxWrapper.classList.remove("slds-hide");
      searchBoxWrapper.classList.add("slds-show");
      searchBoxWrapper.querySelector("lightning-input").value =
        this.selectedRecord;
    }
    const pillDiv = this.template.querySelector(".pillDiv");
    if (pillDiv) {
      pillDiv.classList.remove("slds-show");
      pillDiv.classList.add("slds-hide");
    }
  }
  // method to update selected record from search result
  handleSelectedRecord(event) {
    const selectedName = event.target.getAttribute("data-objname"); // get selected record Idrd from list
    this.selectObject(selectedName);
    this.lookupUpdatehandler(selectedName); // update value on parent component as well from helper function
  }

  selectObject(val) {
    if (!val || val.trim().length === 0) {
      this.handleRemove();
      return;
    }
    // data isn't ready yet, will auto-retry on data loaded
    if (!this.objects) {
      return;
    }
    const obj = this.objects.find((o) => o.fullName === val);
    this.selectedRecord = `${obj.label} (${obj.fullName})`;
    this.selectedRecordIconName = obj.iconName;
    this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
  }

  /*COMMON HELPER METHOD STARTED*/
  handelSelectRecordHelper() {
    this.template
      .querySelector(".lookupInputContainer")
      .classList.remove("slds-is-open");
    const searchBoxWrapper = this.template.querySelector(".searchBoxWrapper");
    searchBoxWrapper.classList.remove("slds-show");
    searchBoxWrapper.classList.add("slds-hide");
    const pillDiv = this.template.querySelector(".pillDiv");
    pillDiv.classList.remove("slds-hide");
    pillDiv.classList.add("slds-show");
  }
  // send selected lookup record to parent component using custom event
  lookupUpdatehandler(value) {
    //Send only the API Name in the event
    const oEvent = new CustomEvent("lookupupdate", {
      detail: { selectedRecord: value }
    });
    this.dispatchEvent(oEvent);
  }
}

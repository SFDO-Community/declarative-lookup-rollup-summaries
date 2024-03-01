import { LightningElement, api, wire } from "lwc";
import getAllObjects from "@salesforce/apex/ObjectSelectorController.getParentObjList";
import { getObjectInfos } from "lightning/uiObjectInfoApi";

export default class ObjectSelector extends LightningElement {
  // public properties with initial default values
  @api label = "Object";
  @api placeholder = "Select on object";
  @api helperText = '';
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
  searchThreshold = 3;
  searchRequired = true;
  maxSearchResults = 5;
  objectApiNames = [];
  selectedRecord = "";
  objects = [];
  connectedCallback() {
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
      this.objects = this.objects.map((o) => {
        if (!objectIconCache[o.fullName]?.iconUrl) {
          return o;
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
        return o;
      });
    }
  }

  get objectsLoading() {
    return this.objects.length === 0;
  }

  get objectOptions() {
    return this.objects.map(o => {
      return {
        value: o.fullName,
        label: `${o.label} (${o.fullName})`,
        icon: o.iconName,
      }
    });
  }

  // method to update selected record from search result
  handleSelectedRecord(event) {
    const selectedName = event.detail.selectedOption.value; // get selected record Id from list
    this.selectObject(selectedName);
    this.lookupUpdatehandler(selectedName); // update value on parent component as well from helper function
  }

  selectObject(val) {
    if (!val || val.trim().length === 0) {
      return;
    }
    // data isn't ready yet, will auto-retry on data loaded
    if (this.objectsLoading) {
      return;
    }
    const obj = this.objects.find((o) => o.fullName === val);
    this.selectedRecord = obj.fullName;
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

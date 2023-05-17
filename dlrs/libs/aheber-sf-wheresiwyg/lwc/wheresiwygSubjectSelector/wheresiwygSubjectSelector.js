import { LightningElement, api, track } from "lwc";
import getFieldsForObject from "@salesforce/apex/WhereSiwygController.getFieldsForObject";

// TODO: handle free text inputs that aren't fields (like formulas)
export default class WheresiwygSubjectSelector extends LightningElement {
  @api
  mode; // "where","soql-select","group-by","order-by"
  // TODO: take input of existing subjects and pre-build the data and pull the field relationships
  // TODO: what does it look like to take in non-field data?
  loading = false;
  @track
  selectedFields = [];
  selectedFieldsMetadata = [];
  @api
  get baseObject() {
    return this._baseObject;
  }
  set baseObject(val) {
    this._baseObject = val;
    this.loadObjectFields(val).then(() => {
      if (this.selectedFields.length > 0) {
        this.loadFieldMetadata();
      }
    });
  }
  @api
  get subjects() {
    return this.selectedFields;
  }
  set subjects(val) {
    console.log("Subjects", JSON.stringify(val));
    this.selectedFields = JSON.parse(
      JSON.stringify(val.filter((v) => v.trim().length > 0))
    );
    this.loadFieldMetadata();
  }

  fields;
  @track
  availableFields;
  displayFieldPicker = true;
  fieldPickerIsReadOnly = true;
  currentField = 0;
  showInputOptions = false;

  recommendedFields = [];

  textInputChange(event) {
    const text = this.template.querySelector(".subjectInput").value;
    this.recommendedFields = this.availableFields.filter((f) =>
      f.value.includes(text)
    );
  }

  handleRecommendationClicked(event) {
    const clicked = event.target.closest("li");
    this.template.querySelector(".subjectInput").value = "";
    this.handleFieldSelected({ detail: { value: clicked.dataset.value } });
  }

  blurTextInput(event) {
    this.sendFields([
      ...this.selectedFields,
      this.template.querySelector(".subjectInput").value
    ]);
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.showInputOptions = false;
      this.recommendedFields = [];
    }, 350);
  }

  focusTextInput(event) {
    this.showInputOptions = true;
  }

  get hasSelectedFields() {
    return this.selectedFields.length > 0;
  }

  handleFieldSelected(event) {
    this.selectedFields.push(event.detail.value);
    const selectedFieldRelationship = this.fields.find(
      (f) => f.relationshipName === event.detail.value
    );
    if (!selectedFieldRelationship) {
      this.displayFieldPicker = false;
      const selectedField = this.fields.find(
        (f) => f.name === event.detail.value
      );
      this.selectedFieldsMetadata.push(selectedField);
      // TODO: this is a field reference and we don't need to do anything else
      this.sendFields(this.selectedFields);
      return;
    }
    this.selectedFieldsMetadata.push(selectedFieldRelationship);
    console.log("Selected:", selectedFieldRelationship);
    this.loadObjectFields(selectedFieldRelationship.referencesTo[0]);
  }

  sendFields(fields) {
    this.dispatchEvent(
      new CustomEvent("subjectselected", {
        detail: { subjects: fields }
      })
    );
  }

  async loadFieldMetadata() {
    if (!this.baseObject) {
      if (this.template.querySelector(".subjectInput")) {
        this.template.querySelector(".subjectInput").value =
          this.selectedFields.join(".");
        this.selectedFields = [];
      }
      this.displayFieldPicker = true;
      return;
    }
    this.selectedFieldsMetadata = [];
    let fields = await getFieldsForObject({ objectName: this.baseObject });
    let fMdt;
    for (let fName of this.selectedFields) {
      fMdt = fields.find(
        (f) => f.name === fName || f.relationshipName === fName
      );
      if (!fMdt) {
        this.template.querySelector(".subjectInput").value =
          this.selectedFields.pop();
        this.displayFieldPicker = true;
        return;
      }
      this.selectedFieldsMetadata.push(fMdt);
      if (fName === fMdt.relationshipName) {
        // eslint-disable-next-line no-await-in-loop
        fields = await getFieldsForObject({ objectName: fMdt.referencesTo[0] });
      }
    }
    if (fMdt && fMdt.relationshipName) {
      this.loadObjectFields(fMdt.referencesTo[0]);
    }
  }

  handleRemoveSubject(event) {
    console.log("Drop Index", event.currentTarget.dataset.index);
    this.selectedFields.pop();
    this.selectedFieldsMetadata.pop();
    if (this.selectedFieldsMetadata.length > 0) {
      this.loadObjectFields(
        this.selectedFieldsMetadata[this.selectedFieldsMetadata.length - 1]
          .referencesTo[0]
      );
    } else {
      this.loadObjectFields(this.baseObject);
    }
    this.displayFieldPicker = true;
  }

  async loadObjectFields(objectName) {
    this.loading = true;
    if (!objectName || objectName.trim().length === 0) {
      return;
    }
    const fields = await getFieldsForObject({ objectName: objectName });
    this.fields = fields;
    this.availableFields = [
      ...this.fields.map((f) => {
        return { label: f.label, value: f.name, description: f.name };
      }),
      ...this.fields
        .filter((f) => f.type === "REFERENCE")
        .filter((f) => f.relationshipName)
        .map((f) => {
          return {
            label: `${f.relationshipName} >`,
            value: f.relationshipName,
            description: "..."
          };
        })
    ].sort((a, b) => a.value.localeCompare(b.value));
    this.recommendedFields = this.availableFields;
    // Increment an arbitrary counter to clear the combobox
    // if the next deep object has the same relationship then it didn't clear
    this.currentField = 1 + this.currentField;
    this.fieldPickerIsReadOnly = false;
    this.loading = false;
  }
}

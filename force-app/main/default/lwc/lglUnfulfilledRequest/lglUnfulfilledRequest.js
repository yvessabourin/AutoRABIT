import { LightningElement, api } from "lwc";
import { createRecord } from "lightning/uiRecordApi";
import UNFULFILLED_RQ_OBJECT from "@salesforce/schema/LGL_Unfulfilled_Request__c";

export default class LglUnfulfilledRequest extends LightningElement {
  @api serviceTypes;
  @api serviceLocations;

  get serviceTypeOptions() {
    return this.convertToOptions(this.serviceTypes, "Id", "Name");
  }

  get serviceLocationsOptions() {
    return this.convertToOptions(this.serviceLocations, "Id", "Name");
  }

  @api saveUnfulfilledRequest() {
    let fields = {};
    let validForm = true;
    let recordInput = {
      apiName: UNFULFILLED_RQ_OBJECT.objectApiName,
      fields
    };

    this.template.querySelectorAll("lightning-combobox").forEach((element) => {
      fields[element.name] = element.value;
      validForm = validForm && element.checkValidity();
      element.reportValidity();
    });

    if (validForm) {
      createRecord(recordInput)
        .then(() => {
          this.dispatchEvent(new CustomEvent("save"));
        })
        .catch((err) => console.log(err));
    } else {
      this.dispatchEvent(new CustomEvent("error"));
    }
  }

  convertToOptions(elements, idField, labelField) {
    return elements
      ? elements.map((element) => {
          return {
            value: element[idField],
            label: element[labelField]
          };
        })
      : [];
  }
}
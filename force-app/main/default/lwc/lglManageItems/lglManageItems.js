import { LightningElement, wire, api } from "lwc";
import getServiceOfferings from "@salesforce/apex/LGL_DashController.getServiceOfferings";
import { refreshApex } from "@salesforce/apex";
import { updateRecord } from "lightning/uiRecordApi";

const NON_MANAGEABLE_ITEMS = ["lLugg"];

export default class LglManageItems extends LightningElement {
	@api userVillage = "";

	@wire(getServiceOfferings, { village: "$userVillage" })
	_serviceOfferings;

	get serviceOfferings() {
		let matrixOfferings = {};

		if (this._serviceOfferings && this._serviceOfferings.data) {
			for (let offering of this._serviceOfferings.data) {
				//There are services that are not suposed to be manageable. In that case, we exclude them from the page
				if (
					!NON_MANAGEABLE_ITEMS.includes(offering.LGL_Service_Type__r.LGL_Service_Id__c)
				) {
					if (matrixOfferings[offering.LGL_Service_Offering_Location__r.Name]) {
						matrixOfferings[offering.LGL_Service_Offering_Location__r.Name][
							offering.LGL_Service_Type__r.Name
						] = offering;
					} else {
						matrixOfferings[offering.LGL_Service_Offering_Location__r.Name] = {};
						matrixOfferings[offering.LGL_Service_Offering_Location__r.Name][
							offering.LGL_Service_Type__r.Name
						] = offering;
					}
				}
			}
			return matrixOfferings;
		}
		return {};
	}

	get matrixHeaders() {
		let serviceOfferings = Object.assign({}, this.serviceOfferings);
		let rows = Object.keys(serviceOfferings);
		let columns = rows.length > 0 ? Object.keys(serviceOfferings[rows[0]]) : [];
		return { rows: rows, columns: columns };
	}

	@api
	resetMatrixValues() {
		for (let matrixElement of this.template.querySelectorAll("c-lgl-matrix-element")) {
			matrixElement.resetValue();
		}
	}

	@api
	saveValues() {
		let promisesList = [];
		for (let matrixElement of this.template.querySelectorAll("c-lgl-matrix-element")) {
			if (matrixElement.edited) {
				let fields = {
					Id: matrixElement.element.Id,
					LGL_Quantity__c: matrixElement.element.LGL_Quantity__c
				};
				promisesList.push(updateRecord({ fields }));
			}
		}
		if (promisesList.length > 0) {
			Promise.all(promisesList)
				.then(() => {
					const selectedEvent = new CustomEvent("save");
					this.dispatchEvent(selectedEvent);
					return refreshApex(this._serviceOfferings);
				})
				.then(() => {
					this.resetMatrixValues();
				})
				.catch((error) => {
					console.log(error);
				});
		}
	}
}
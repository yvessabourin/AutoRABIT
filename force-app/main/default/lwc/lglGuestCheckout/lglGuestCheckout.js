import { LightningElement, api, track } from "lwc";

import SERVICE_ITEM_ID_FIELD from "@salesforce/schema/LGL_Service_Item__c.LGL_Service_Item_Identifier__c";
import DEPOSIT_STATUS_FIELD from "@salesforce/schema/LGL_Service_Item__c.LGL_Deposit_Status__c";
import STATUS_FIELD from "@salesforce/schema/LGL_Service_Item__c.LGL_Status__c";
import SERVICE_NAME_FIELD from "@salesforce/schema/LGL_Service_Item__c.LGL_Service_Name__c";

import checkoutServices from "@salesforce/apex/LGL_DashController.checkoutServices";
import { updateRecord } from "lightning/uiRecordApi";

const ERROR_CLASS = "lgl-has-error";

const SERVICE_ITEMS_TABLE_FIELDS = [
	{
		fieldId: SERVICE_NAME_FIELD.fieldApiName,
		fieldLabel: "Service Type"
	},
	{
		fieldId: SERVICE_ITEM_ID_FIELD.fieldApiName,
		fieldLabel: "Service Identifier"
	},
	{
		fieldId: STATUS_FIELD.fieldApiName,
		fieldLabel: "Status"
	},
	{
		fieldId: DEPOSIT_STATUS_FIELD.fieldApiName,
		fieldLabel: "Deposit Status"
	}
];

const TOTAL_LABEL = "Total Items to Checkout";

const CHECKOUT_CHECKBOX_LABEL =
	"I confirm I have collected all bags listed above and they are in good condition / undamaged";

export default class LglGuestCheckout extends LightningElement {
	@api checkoutItems;
	@api serviceRequestId;

	serviceItemsTableFields = SERVICE_ITEMS_TABLE_FIELDS;

	checkoutCheckboxLabel = CHECKOUT_CHECKBOX_LABEL;

	loading = false;

	@track surveyData = {};

	handleCancel() {
		this.template
			.querySelector("c-lgl-lock-screen")
			.show()
			.then(() => {
				this.dispatchEvent(new CustomEvent("cancel"));
			});
	}

	handleRadioChange(event) {
		this.surveyData[event.currentTarget.radioGroupName] = event.detail;
	}

	handleTextAreaChange(event) {
		this.surveyData.LGL_Improve_Comments__c = event.currentTarget.value;
	}

	handleCloseServices() {
		if (this.validateForm()) {
			this.template
				.querySelector("c-lgl-lock-screen")
				.show()
				.then(() => {
					this.closeServices();
				});
		}
	}

	validateForm() {
		let isFormValid = this.checkValidity();
		if (!isFormValid) {
			this.reportValidity();
		}
		return isFormValid;
	}

	reportValidity() {
		let formElements = [
			...this.template.querySelectorAll(
				"c-lgl-rating-component,c-lgl-signature-canvas,lightning-input"
			)
		];
		formElements.forEach((formElements) => formElements.reportValidity());
	}

	checkValidity() {
		let formElements = [
			...this.template.querySelectorAll(
				"c-lgl-rating-component,c-lgl-signature-canvas,lightning-input"
			)
		];
		const isFormValid = formElements.reduce((validSoFar, formElement) => {
			return validSoFar && formElement.checkValidity();
		}, true);

		return isFormValid;
	}

	closeServices() {
		this.loading = true;

		let serviceItemsToUpdate = this.checkoutItems.map((checkoutItem) => {
			let serviceItemToUpdate = { Id: checkoutItem.Id };
			Object.assign(serviceItemToUpdate, this.surveyData);
			return serviceItemToUpdate;
		});

		let signature = this.template.querySelector("c-lgl-signature-canvas").signatureValue;

		checkoutServices({
			serviceItemsList: serviceItemsToUpdate,
			serviceRequestId: this.serviceRequestId,
			signature: signature
		})
			.then(() => {
				this.loading = false;
				if (this.manuallyLockedServices.size > 0) {
					//In case we are checking out a manually locked service, we offer by modal the unlocking of the service now that should be available again
					this.template.querySelector("c-lgl-modal").show();
				} else {
					this.dispatchEvent(new CustomEvent("checkout"));
				}
			})
			.catch((e) => {
				this.loading = false;
				console.log(e);
			});
	}

	handleUnlockingRequestModal(event) {
		if (event.currentTarget.value === "yes") {
			this.loading = true;
			let promisesList = [];
			for (let lockedServiceOffering of this.manuallyLockedServices) {
				let fields = {
					Id: lockedServiceOffering,
					LGL_Manually_Lock__c: false
				};
				promisesList.push(updateRecord({ fields }));
			}
			if (promisesList.length > 0) {
				Promise.all(promisesList)
					.then(() => {
						this.dispatchEvent(new CustomEvent("checkout"));
						this.loading = false;
					})
					.catch((e) => {
						console.log(e);
						this.loading = false;
					});
			}
		} else {
			this.dispatchEvent(new CustomEvent("checkout"));
		}
	}

	get showAcceptCheckbox() {
		let showCheckbox = false;
		if (this.checkoutItems) {
			this.checkoutItems.forEach((serviceItem) => {
				if (serviceItem.LGL_Service_Type_Identifier__c === "lLugg") {
					showCheckbox = true;
				}
			});
		}
		return showCheckbox;
	}

	get showTextArea() {
		// The value 0 has to be manually included because, by checking this.surveyData.LGL_Likely_To_Recommend__c,
		// the showTextTarea was being returned false when 0 was selected because 0 is a falsy value.
		// Hence, plain this.surveyData.LGL_Likely_To_Recommend__c validation was evaluating to false
		return (
			(this.surveyData.LGL_Likely_To_Recommend__c ||
				this.surveyData.LGL_Likely_To_Recommend__c === 0) &&
			this.surveyData.LGL_Satisfaction_Level__c &&
			this.surveyData.LGL_Likely_To_Recommend__c <= 5 &&
			this.surveyData.LGL_Satisfaction_Level__c <= 3
		);
	}

	get manuallyLockedServices() {
		//We search the items to checkout and return a Set with all the locked Service Offerings that have a Service Item being closed
		let lockedServiceOfferings = new Set();
		if (this.checkoutItems) {
			this.checkoutItems.forEach((checkoutItem) => {
				if (checkoutItem.LGL_Service_Offering__r.LGL_Manually_Lock__c) {
					lockedServiceOfferings.add(checkoutItem.LGL_Service_Offering__c);
				}
			});
			return lockedServiceOfferings;
		}
	}
}
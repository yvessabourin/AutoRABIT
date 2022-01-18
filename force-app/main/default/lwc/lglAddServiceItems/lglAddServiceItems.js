import { LightningElement, api } from "lwc";

import SERVICE_ITEM_ID_FIELD from "@salesforce/schema/LGL_Service_Item__c.LGL_Service_Item_Identifier__c";
import DEPOSIT_STATUS_FIELD from "@salesforce/schema/LGL_Service_Item__c.LGL_Deposit_Status__c";
import STATUS_FIELD from "@salesforce/schema/LGL_Service_Item__c.LGL_Status__c";
import SERVICE_NAME_FIELD from "@salesforce/schema/LGL_Service_Item__c.LGL_Service_Name__c";

import createServiceItems from "@salesforce/apex/LGL_DashController.createServiceItems";

const EXISTING_SERVICE_ITEMS_TABLE_FIELDS = [
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

export default class LglAddServiceItems extends LightningElement {
	@api activeServiceItems;
	@api serviceRequest;
	@api serviceOfferings;
	activeItemsTableFields = EXISTING_SERVICE_ITEMS_TABLE_FIELDS;
	selectedServices;

	loading = false;

	get showActiveItemsTable() {
		return this.activeServiceItems && this.activeServiceItems.length > 0;
	}

	get serviceLocation() {
		if (this.serviceRequest) {
			return this.serviceRequest.LGL_Request_Location__c;
		}
		return null;
	}

	handleSelectServices() {
		let validItems = this.validateServicesSelector();
		if (validItems) {
			this.selectedServices = this.template.querySelector(
				"c-lgl-services-selector"
			).selectedServices;
		}
	}

	validateServicesSelector() {
		let servicesSelectorComponent = this.template.querySelector("c-lgl-services-selector");
		servicesSelectorComponent.reportValidity();

		return servicesSelectorComponent.checkValidity();
	}

	connectedCallback(){console.log(JSON.stringify(this.serviceRequest))}

	handleCancel() {
		this.dispatchEvent(new CustomEvent("cancel"));
	}

	handleCreateServices() {
		const isFormValid = this.validateServiceSettingsForm();
		if (isFormValid) {
			let serviceItems = this.template.querySelector("c-lgl-new-service-form-service-details")
				.serviceItemsList;
			serviceItems.forEach((serviceItem) => {
				serviceItem.LGL_Service_Request__c = this.serviceRequest.Id;
			});
			this.loading = true;
			createServiceItems({ serviceItems: serviceItems })
				.then(() => {
					this.dispatchEvent(new CustomEvent("save"));
				})
				.catch((e) => {
					this.dispatchEvent(new CustomEvent("error"));
					console.log(e);
				})
				.finally(() => {
					this.loading = false;
				});
		}
	}

	validateServiceSettingsForm() {
		const serviceSettingsComponent = this.template.querySelector(
			"c-lgl-new-service-form-service-details"
		);
		serviceSettingsComponent.reportValidity();
		return serviceSettingsComponent.checkValidity();
	}
}
import { LightningElement, track, api, wire } from "lwc";
import Id from "@salesforce/user/Id";
import VILLAGE_FIELD from "@salesforce/schema/User.Village__c";
import { getRecord } from "lightning/uiRecordApi";
import getOfferedServices from "@salesforce/apex/LGL_DashController.getOfferedServices";

export default class LglServicesSelector extends LightningElement {
	@track _selectedServices = []; //We use an Array and not a Set because salesforce @track doesn't track changes on Set variables although a Set is more suitable for the use case

	userId = Id;
	userVillage = "";

	@wire(getOfferedServices, { village: "$userVillage" })
	offeredServicesResponse;

	@api get selectedServices() {
		return this._selectedServices;
	}

	get serviceTypes() {
		let serviceTypes = [];
		if (this.offeredServicesResponse && this.offeredServicesResponse.data) {
			serviceTypes = this.offeredServicesResponse.data;
		}
		return serviceTypes;
	}

	get serviceTypesList() {
		let serviceTypes = [];
		if (this.serviceTypes) {
			serviceTypes = this.serviceTypes.map((serviceType) => ({
				value: serviceType.Id,
				label: serviceType.Name
			}));
		}
		return serviceTypes;
	}

	get selectedServicePills() {
		let selectedServicePills = this._selectedServices.map((selectedService) => {
			return {
				name: selectedService.Id,
				label: selectedService.Name
			};
		});
		return selectedServicePills;
	}

	handleAddService() {
		let pikclistElement = this.template.querySelector("lightning-combobox");
		if (pikclistElement.value) {
			let serviceAlreadySelected = this._selectedServices.find(
				(selectedService) => selectedService.Id === pikclistElement.value
			);
			if (!serviceAlreadySelected) {
				let selectedService = this.serviceTypes.find(
					(serviceType) => serviceType.Id === pikclistElement.value
				);
				this._selectedServices.push(selectedService);
			}
		}
	}

	handleRemoveService(event) {
		let removedServiceIndex = this._selectedServices.findIndex(
			(serviceType) => serviceType.Id === event.currentTarget.name
		);
		this._selectedServices.splice(removedServiceIndex, 1);
	}

	@wire(getRecord, { recordId: "$userId", fields: VILLAGE_FIELD })
	getUserVillage({ error, data }) {
		if (data) {
			this.userVillage = data.fields[VILLAGE_FIELD.fieldApiName].value;
		}
	}

	@api reportValidity() {
		let serviceSelectorCombo = this.template.querySelector("lightning-combobox");
		this._selectedServices.length === 0
			? serviceSelectorCombo.classList.add("slds-has-error")
			: serviceSelectorCombo.classList.remove("slds-has-error");
	}

	@api checkValidity() {
		return this._selectedServices.length > 0;
	}
}
import { LightningElement, api, wire } from "lwc";
import Id from "@salesforce/user/Id";
import VILLAGE_FIELD from "@salesforce/schema/User.Village__c";
import { getRecord } from "lightning/uiRecordApi";
import getServiceLocations from "@salesforce/apex/LGL_DashController.getServiceLocations";
import getGuestTypes from "@salesforce/apex/LGL_DashController.getGuestTypes";

const SUCCESS_TYPE = "success";
const ERROR_TYPE = "error";
const WARNING_TYPE = "warning";

export default class LglNewServiceFormServiceDetails extends LightningElement {
	@api serviceDetails = {};
	@api selectedServices; //List of selected services as LGL_Service_Type__c objects
	@api defaultLocation; //Allows to preselect a location. For example, from the lglAddServiceITems component
	selectedLocation;
	@api hideGuestTypeField = false; //Allows the reutilization of the component for already existing requests when we want to add new service items. In this case, the Service Request fields aren't needed
	@api serviceOfferings;
	userVillage = "";
	userId = Id;


	connectedCallback() {
		this.selectedLocation = this.defaultLocation;
		this.serviceDetails.LGL_Request_Location__c = this.defaultLocation;
	}

	@api get serviceItemsList() {
		let serviceSettingComponents = [
			...this.template.querySelectorAll("c-lgl-service-settings")
		];
		let serviceItemsList = serviceSettingComponents.reduce(
			(accumulated, serviceSettingComponent) => {
				serviceSettingComponent.serviceItems.forEach((serviceItem) => {
					serviceItem.LGL_Service_Offering__c = this.serviceOfferingsMap[
						this.serviceDetails.LGL_Request_Location__c
					][serviceSettingComponent.serviceType].Id;
				});
				accumulated.push(...serviceSettingComponent.serviceItems);

				return accumulated;
			},
			[]
		);
		return serviceItemsList;
	}

	@wire(getRecord, { recordId: "$userId", fields: VILLAGE_FIELD })
	getUserVillage({ error, data }) {
		if (data) {
			this.userVillage = data.fields[VILLAGE_FIELD.fieldApiName].value;
		}
	}

	get serviceOfferingsMap() {
		if (this.serviceOfferings) {
			let serviceOfferingsMap = {};
			this.serviceOfferings.forEach((serviceOffering) => {
				if (serviceOfferingsMap[serviceOffering.LGL_Service_Offering_Location__c]) {
					serviceOfferingsMap[serviceOffering.LGL_Service_Offering_Location__c][
						serviceOffering.LGL_Service_Type__r.LGL_Service_Id__c
					] = serviceOffering;
				} else {
					serviceOfferingsMap[serviceOffering.LGL_Service_Offering_Location__c] = {};
					serviceOfferingsMap[serviceOffering.LGL_Service_Offering_Location__c][
						serviceOffering.LGL_Service_Type__r.LGL_Service_Id__c
					] = serviceOffering;
				}
			});
			return serviceOfferingsMap;
		}
		return {};
	}

	@wire(getServiceLocations, { village: "$userVillage" })
	serviceLocations;

	get serviceLocationsList() {
		let serviceLocationsList = [];
		if (this.serviceLocations && this.serviceLocations.data) {
			serviceLocationsList = this.serviceLocations.data.map((serviceLocation) => ({
				value: serviceLocation.Id,
				label: serviceLocation.Name
			}));
		}
		return serviceLocationsList;
	}

	guestTypesList;

	@wire(getGuestTypes, { village: "$userVillage" })
	getGuestTypes({ error, data }) {
		if (data) {
			this.guestTypesList = data.map((guestType) => ({
				value: guestType.Data_Label__c,
				label: guestType.Data_Label__c
			}));
		}
	}

	handleFieldChange(event) {
		this.serviceDetails[event.currentTarget.name] = event.currentTarget.value;

		if (event.currentTarget.name === "LGL_Request_Location__c") {
			this.selectedLocation = event.currentTarget.value;
		}
	}

	@api reportValidity() {
		let formInputs = [
			...this.template.querySelectorAll("lightning-combobox,c-lgl-service-settings")
		];
		formInputs.forEach((formInput) => formInput.reportValidity());

		//This is needed because the actual lglServiceSetting components don't exist until their tab is clicked.
		//Hence, we need to check if all the components have been clicked once by comparing the result of the existing quried services with the size of the selected services variable
		let serviceSettings = [...this.template.querySelectorAll("c-lgl-service-settings")];

		const validServiceSettings = serviceSettings.reduce((validSoFar, serviceSetting) => {
			return validSoFar && serviceSetting.checkValidity();
		}, true);

		if (!validServiceSettings || serviceSettings.length < this.selectedServices.length) {
			this.showNotification(
				"There is a problem in the service items configuration. Check all the service tabs",
				ERROR_TYPE
			);
		}
	}

	@api checkValidity() {
		let formInputs = [
			...this.template.querySelectorAll("lightning-combobox,c-lgl-service-settings")
		];
		const isFormValid = formInputs.reduce((validSoFar, formElement) => {
			return validSoFar && formElement.checkValidity();
		}, true);

		//This is needed because the actual lglServiceSetting components don't exist until their tab is clicked.
		//Hence, we need to check if all the components have been clicked once by comparing the result of the existing quried services with the size of the selected services variable
		let serviceSettings = [...this.template.querySelectorAll("c-lgl-service-settings")];

		return isFormValid && serviceSettings.length === this.selectedServices.length;
	}

	showNotification(message, type) {
		this.template.querySelector("c-lgl-notifications-component").show(message, type);
	}
}
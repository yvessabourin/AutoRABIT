import { LightningElement, api, wire } from "lwc";
import saveServiceRequest from "@salesforce/apex/LGL_DashController.saveServiceRequest";
import getVillageUrls from "@salesforce/apex/LGL_DashController.getVillageUrls";

const DEFAULT_SECTION = "guestSection";
const DEFAULT_SERVICE_REQUEST_STATUS = "using";

const SECTIONS_MAP = {
	guestSection: ["guestDetailsRegion", "guestServicesRegion", "guestDetailsButtons"],
	servicesSection: ["guestDetailsRegion", "serviceSettingsRegion", "serviceSettingsButtons"]
};

export default class LglNewServiceForm extends LightningElement {
	@api guestId;
	@api serviceOfferings;

	isSaving = false;
	serviceRequestData = { LGL_Status__c: DEFAULT_SERVICE_REQUEST_STATUS };
	selectedServices;
	signatureData;
	serviceItemsList;
	initialized = false;
	activeSection = DEFAULT_SECTION;
	createPrivilegeAccount = false;

	villageUrls = {};

	renderedCallback() {
		if (!this.initialized) {
			this.initialized = true;
			this.changeFormSection(DEFAULT_SECTION);
		}
	}

	get showMarketing() {
		return !this.guestId; //We display the marketing checkbox in cause we have a new Id (thus, the guestId is blank)
	}

	@wire(getVillageUrls)
	getVillageUrls({ error, data }) {
		if (data) {
			this.villageUrls = data;
		} else if (error) {
			console.log(error);
		}
	}

	handleSaveGuestDetails() {
		const isGuestFormValid = this.validateGuestForm();

		if (isGuestFormValid) {
			const guestDetailsComponent = this.template.querySelector("c-lgl-guest-details-form");
			const signatureComponent = this.template.querySelector("c-lgl-signature-canvas");
			const servicesSelectorComponent = this.template.querySelector(
				"c-lgl-services-selector"
			);
			const newPrivilegeCheckbox = this.template.querySelector(".lgl-privilege");

			Object.assign(this.serviceRequestData, guestDetailsComponent.guestDetailFields); //serviceRequestData is suposed to be the whole service data (also the data from the second part of the form). That's why, for coherence, we use Object.assign
			this.selectedServices = servicesSelectorComponent.selectedServices;
			this.signatureData = signatureComponent.signatureValue;
			this.createPrivilegeAccount = newPrivilegeCheckbox
				? newPrivilegeCheckbox.checked
				: false; //It is needed to set the check to false even when the field is not displayed for those case when a Request was previously created with the checkbox true but now is not needed to avoid creating a new privilege account

			this.template
				.querySelector("c-lgl-lock-screen")
				.show()
				.then(() => this.changeFormSection("servicesSection"));
		}
	}

	handleCreateServiceRequest() {
		const isFormValid = this.validateGuestForm() && this.validateServiceSettingsForm();
		if (isFormValid) {
			const serviceSettingsComponent = this.template.querySelector(
				"c-lgl-new-service-form-service-details"
			);
			Object.assign(this.serviceRequestData, serviceSettingsComponent.serviceDetails);
			this.serviceItemsList = serviceSettingsComponent.serviceItemsList;
			this.saveServiceRequest();
		}
	}

	saveServiceRequest() {
		this.isSaving = true;
		saveServiceRequest({
			serviceRequest: this.serviceRequestData,
			serviceItems: this.serviceItemsList,
			signature: this.signatureData,
			createPrivilegeAccount: this.createPrivilegeAccount
		})
			.then(() => {
				this.dispatchEvent(new CustomEvent("save"));
			})
			.catch((error) => console.log(error))
			.finally(() => (this.isSaving = false));
	}

	validateGuestForm() {
		const guestDetailsComponent = this.template.querySelector("c-lgl-guest-details-form");
		const signatureComponent = this.template.querySelector("c-lgl-signature-canvas");
		const servicesSelectorComponent = this.template.querySelector("c-lgl-services-selector");
		const checkboxComponent = this.template.querySelector(".lgl-terms");

		guestDetailsComponent.reportValidity();
		signatureComponent.reportValidity();
		servicesSelectorComponent.reportValidity();
		//We don't use reportValidity for the checkbox because we don't want the message about the required selection to be shown
		checkboxComponent.checked
			? checkboxComponent.classList.remove("slds-has-error")
			: checkboxComponent.classList.add("slds-has-error");

		return (
			signatureComponent.checkValidity() &&
			guestDetailsComponent.checkValidity() &&
			servicesSelectorComponent.checkValidity() &&
			checkboxComponent.checked
		);
	}

	validateServiceSettingsForm() {
		const serviceSettingsComponent = this.template.querySelector(
			"c-lgl-new-service-form-service-details"
		);
		serviceSettingsComponent.reportValidity();
		return serviceSettingsComponent.checkValidity();
	}

	handleCancelRegistration() {
		this.dispatchEvent(new CustomEvent("cancel"));
	}

	changeFormSection(targetSection) {
		for (let section in SECTIONS_MAP) {
			//We hide all the regions first and after that show the onces that are part of the active section. This way, a same region can be part of several sections.
			//Delaying the showing of the sections allows us to always show at the end the regions that we want
			if (Object.prototype.hasOwnProperty.call(SECTIONS_MAP, section)) {
				SECTIONS_MAP[section].forEach((region) => this.hide(region));
			}
		}
		SECTIONS_MAP[targetSection].forEach((region) => this.show(region));
		this.activeSection = targetSection;
	}

	hide(sectionIdentifier) {
		let element = this.template.querySelector(`[data-region=${sectionIdentifier}]`);
		if (element) {
			element.classList.add("slds-hide");
		}
	}

	show(sectionIdentifier) {
		let element = this.template.querySelector(`[data-region=${sectionIdentifier}]`);
		if (element) {
			element.classList.remove("slds-hide");
		}
	}
}
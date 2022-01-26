import { LightningElement, api, wire } from "lwc";
import getCountries from "@salesforce/apex/LGL_DashController.getCountries";
import getGuestAccount from "@salesforce/apex/LGL_DashController.getGuestAccount";
import getSalutationLabels from "@salesforce/apex/LGL_DashController.getSalutationLabels";
import getMethodsTransport from "@salesforce/apex/LGL_DashController.getMethodsTransport";

const DEFAULT_LANG = "en";
const NAME_FIELDS_MAX_LENGTH = 20;
const COUNTRIES_SEPARATOR = "--------";

export default class LglGuestDetailsForm extends LightningElement {
	@api guestId;
	guestAccount = {};

	@api readOnly = false;
	@api guestDetailFields = {};
	namesMaxLength = NAME_FIELDS_MAX_LENGTH;

	salutationsList = [];
	loading = false;

	connectedCallback() {
		if (this.guestId) {
			this.loading = true;
		}
	}

	@wire(getSalutationLabels, { language: DEFAULT_LANG })
	getSalutationLabels({ error, data }) {
		if (data) {
			this.salutationsList = data.map((salutationLabel) => ({
				value: salutationLabel.Custom_Label_Value__c,
				label: salutationLabel.Custom_Label_Value__c
			}));
		}
	}

	countriesList;

	@wire(getCountries)
	getCountries({ error, data }) {
		if (data) {
			let defaultCountries = data.defaultCountries.map((country) => ({
				value: country.HFS_Country_Code__c,
				label: country.HFS_Country_Name__c
			}));
			let otherCountries = data.otherCountries.map((country) => ({
				value: country.HFS_Country_Code__c,
				label: country.HFS_Country_Name__c
			}));

			let countriesList = [];
			countriesList.push(
				...defaultCountries,
				{ value: COUNTRIES_SEPARATOR, label: COUNTRIES_SEPARATOR },
				...otherCountries
			);
			this.countriesList = countriesList;
		}
	}

	@wire(getGuestAccount, { guestId: "$guestId" })
	getGuestAccount({ error, data }) {
		if (data) {
			this.guestAccount = data;

			//Feeling the guestDetail object which is the one that we use for the Service Request creation
			this.guestDetailFields.LGL_Title__c = data.Salutation;
			this.guestDetailFields.LGL_First_Name__c = data.FirstName;
			this.guestDetailFields.LGL_Last_Name__c = data.LastName;
			this.guestDetailFields.LGL_Email__c = data.PersonEmail;
			this.guestDetailFields.LGL_Phone__c = data.PersonMobilePhone;
			this.guestDetailFields.LGL_Guest__c = data.Id;
			this.guestDetailFields.LGL_Country_Residence__c = data.Country_of_Residence__c;

			this.loading = false;
		}
	}

	//Because the information about the country that is saved in the Account record is the Label of the country and the picklist needs the code, we separate the code from the guest information
	get guestsCountryCode() {
		if (this.countriesList && this.guestAccount.Country_of_Residence__c) {
			return this.countriesList.find(
				(country) => country.label === this.guestAccount.Country_of_Residence__c
			).value;
		}
		return "";
	}

	methodTransportList = [];

	@wire(getMethodsTransport, { language: DEFAULT_LANG })
	getMethodsTransport({ error, data }) {
		if (data) {
			this.methodTransportList = data.map((methodOfTransport) => ({
				value: methodOfTransport.Custom_Label_Value__c,
				label: methodOfTransport.Custom_Label_Value__c
			}));
		}
	}

	handleFieldChange(event) {
		if (event.currentTarget.name !== "LGL_Country_Residence__c") {
			this.guestDetailFields[event.currentTarget.name] = event.currentTarget.value;
		} else {
			if (event.currentTarget.value !== COUNTRIES_SEPARATOR) {
				event.currentTarget.setCustomValidity("");
				event.currentTarget.reportValidity();
				this.setCountry(event.currentTarget.value);
			} else {
				event.currentTarget.setCustomValidity("Choose a country");
				event.currentTarget.reportValidity();
			}
		}
	}

	setCountry(countryCode) {
		let selectedCountry = this.countriesList.find((country) => country.value === countryCode);
		this.guestDetailFields.LGL_Country_Residence__c = selectedCountry.label;
	}

	@api reportValidity() {
		let formElements = [
			...this.template.querySelectorAll("lightning-input,lightning-combobox")
		];
		formElements.forEach((formElement) => formElement.reportValidity());
	}

	@api checkValidity() {
		let formElements = [
			...this.template.querySelectorAll("lightning-input,lightning-combobox")
		];
		const isFormValid = formElements.reduce((validSoFar, formElement) => {
			return validSoFar && formElement.checkValidity();
		}, true);
		return isFormValid;
	}
}
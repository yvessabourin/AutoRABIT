import { LightningElement, api } from 'lwc';

const PLACEHOLDER_VALUE = "-";
const ERROR_CLASS = "slds-has-error";
const ERROR_MESSAGE = "You must choose a value";

export default class LglSelect extends LightningElement {

	@api options;
	@api label;
	@api placeholder;
	@api value;
	@api fieldName;

	valid = true;
	errorMessage = ERROR_MESSAGE;

	handleChange(event) {
		this.value = event.currentTarget.value;
		if (!this.valid) {
			this.reportValidity();
		}
	}
	renderedCallback() {
		if (!this.initialized && this.value) {
			this.template.querySelector("select").value = this.value;
			this.initialized = true;
		}
	}

	@api reportValidity() {
		this.valid = this.template.querySelector("select").value !== PLACEHOLDER_VALUE;
		return this.template.querySelector("select").value !== PLACEHOLDER_VALUE;
	}

	get containerClass() {
		return this.valid ? "" : ERROR_CLASS;
	}

}
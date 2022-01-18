import { LightningElement, api } from "lwc";

const SHOW_BACKDROP_CLASS = "slds-backdrop_open";
const SHOW_MODAL_CLASS = "slds-fade-in-open";

export default class LglModal extends LightningElement {
	@api show() {
		this.template.querySelector(".slds-modal").classList.add(SHOW_MODAL_CLASS);
		this.template.querySelector(".slds-backdrop").classList.add(SHOW_BACKDROP_CLASS);
	}

	@api hide() {
		this.template.querySelector(".slds-modal").classList.remove(SHOW_MODAL_CLASS);
		this.template.querySelector(".slds-backdrop").classList.remove(SHOW_BACKDROP_CLASS);
	}
}
import { LightningElement, api } from "lwc";

const SLDS_HIDE = "slds-hide";
const PASSWORD = "2019";

export default class LglLockScreen extends LightningElement {
	resolve;

	@api show() {
		this.template.querySelector(".lgl-lock-screen").classList.remove(SLDS_HIDE);
		this.template.querySelector("lightning-input").focus();
		let promiseResponse = new Promise((resolve) => {
			this.resolve = resolve;
		});
		return promiseResponse;
	}

	hide() {
		this.template.querySelector(".lgl-lock-screen").classList.add(SLDS_HIDE);
	}

	handleKeyUp(event) {
		const passwordInput = this.template.querySelector("lightning-input");
		const isEnterKey = event.keyCode === 13;
		if (isEnterKey) {
			if (event.currentTarget.value === PASSWORD) {
				passwordInput.setCustomValidity("");
				passwordInput.reportValidity();
				this.hide();
				this.resolve();
			} else {
				passwordInput.setCustomValidity("Invalid Code");
				passwordInput.reportValidity();
			}
		}
	}
}
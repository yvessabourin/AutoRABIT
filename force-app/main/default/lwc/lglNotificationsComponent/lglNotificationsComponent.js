import { LightningElement, api } from "lwc";

const NOTIFICATION_TIMEOUT = 3000;
const NOTIFICATION_FADEOUT = 300;
const NOTIFICATION_CLASS_DEFAULT = "lgl-notification slds-var-p-horizontal_small ";

const THEME_CLASS_MAP = {
	success: "slds-theme_success",
	error: "slds-theme_error",
	warning: "slds-theme_warning"
};

const ICON_MAP = {
	success: "standard:task2",
	error: "standard:opportunity_splits",
	warning: "standard:opportunity_splits"
};

const ICON_CLASS_MAP = {
	success: "lgl-success-icon",
	error: "lgl-error-icon",
	warning: "lgl-warning-icon"
};

export default class LglNotificationsComponent extends LightningElement {
	isVisible = false;
	message;
	type;

	@api show(message = "Operation successfully completed", type = "success") {
		this.type = type;
		this.message = message;
		this.isVisible = true;
		setTimeout(() => this.hide(), NOTIFICATION_TIMEOUT);
	}

	hide() {
		if (this.template.querySelector(".slds-notify_container")) {
			this.template.querySelector(".slds-notify_container").classList.add("lgl-hide");
			setTimeout(() => (this.isVisible = false), NOTIFICATION_FADEOUT); //We need to change the isVisible after to allow the lgl-hide animation to work. Th isVisible is need to reset the tamplate of the component
		}
	}

	handleCloseClick() {
		this.hide();
	}

	get notificationClass() {
		return NOTIFICATION_CLASS_DEFAULT + THEME_CLASS_MAP[this.type];
	}

	get notificationIcon() {
		return ICON_MAP[this.type];
	}

	get iconClass() {
		return ICON_CLASS_MAP[this.type];
	}

	get closeIconClass() {
		return ICON_CLASS_MAP[this.type] + " lgl-close-button";
	}
}
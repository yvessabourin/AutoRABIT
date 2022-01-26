import { LightningElement, api } from "lwc";
import { updateRecord } from "lightning/uiRecordApi";

const FULL_CLASS = "lgl-full lgl-badge";
const INFO_CLASS = "lgl-info lgl-badge";
const EMPTY_CLASS = "lgl-empty lgl-badge";

export default class LglDashSummaryItem extends LightningElement {
	@api cell = {};
	lockedCell = false;

	connectedCallback() {
		this.lockedCell = this.cell.lockedServiceOffering;
	}

	get showLockableCell() {
		return this.cell.serviceTypeIdentifier === "lLugg";
	}

	get showLockIcon() {
		return this.cell.itemsInUse > 0;
	}

	get lockableCellClass() {
		if (this.cell.itemsInUse == 0) {
			return EMPTY_CLASS;
		} else if (this.lockedCell) {
			return FULL_CLASS;
		} else {
			return INFO_CLASS;
		}
	}

	handleLockClick() {
		this.lockedCell = !this.lockedCell;
		this.updateServiceOfferingLock();
	}

	updateServiceOfferingLock() {
		let fields = {
			Id: this.cell.serviceOfferingId,
			LGL_Manually_Lock__c: this.lockedCell
		};
		updateRecord({ fields })
			.then(() => {
				this.dispatchEvent(new CustomEvent("locktoggle"));
			})
			.catch((error) => console.error(error));
	}
}
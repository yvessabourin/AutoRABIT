import { LightningElement, api } from "lwc";

const AVAILABLE_CLASS = "lgl-badge lgl-available";
const FULL_CLASS = "lgl-badge lgl-full";

const SUCCESS_TYPE = "success";
const ERROR_TYPE = "error";
const WARNING_TYPE = "warning";
export default class LglDashSummary extends LightningElement {
	@api dashColumns;

	@api dashRows;

	get rows() {
		if (this.dashRows && this.dashColumns && this.dashColumns.length > 0) {
			let finalRows = [];
			for (let dashRow of this.dashRows) {
				let element = { location: dashRow.location, cells: [] };
				for (let column of this.dashColumns) {
					element.cells.push(dashRow.dashCells[column.fieldId]);
				}
				finalRows.push(element);
			}
			finalRows.sort(this.orderItems);
			return finalRows;
		} else {
			return [];
		}
	}

	get serviceTotals() {
		if (this.dashRows && this.dashColumns && this.dashColumns.length > 0) {
			let totals = { loan: [], luggage: [], limits: [] };
			for (let column of this.dashColumns) {
				let totalEntry = { label: column.fieldName, total: 0 };
				let availableItems = 0;
				let itemsInUse = 0;
				let allManuallyLocked = true;

				for (let dashRow of this.dashRows) {
					totalEntry.total += dashRow.dashCells[column.fieldId].totalUsedItemsToday;
					availableItems += dashRow.dashCells[column.fieldId].totalItems;
					itemsInUse += dashRow.dashCells[column.fieldId].itemsInUse;
					allManuallyLocked =
						allManuallyLocked &&
						dashRow.dashCells[column.fieldId].lockedServiceOffering; //Check if all the collection points have been manually locked
				}
				totals[column.type].push(totalEntry);

				if (
					this.isServiceFull(
						column.fieldIdentifier,
						availableItems,
						itemsInUse,
						allManuallyLocked
					)
				) {
					totals.limits.push({
						serviceId: column.fieldId,
						limitReached: "YES",
						css_class: FULL_CLASS
					});
				} else {
					totals.limits.push({
						serviceId: column.fieldId,
						limitReached: "NO",
						css_class: AVAILABLE_CLASS
					});
				}
			}
			return totals;
		} else {
			return [];
		}
	}

	isServiceFull(serviceTypeIdentifier, availableItems, itemsInUse, allManuallyLocked) {
		//For the lLugg service, we use the manually locking to determine if the limit has been reached (allManuallyLocked)
		if (serviceTypeIdentifier === "lLugg") {
			return allManuallyLocked;
		} else {
			return itemsInUse >= availableItems;
		}
	}

	handleLockToggle() {
		this.dispatchEvent(new CustomEvent("locktoggle"));
	}

	handleLockError() {
		this.showNotification("An error has ocurred when trying to lock the Service", ERROR_TYPE);
	}

	showNotification(message, type) {
		this.template.querySelector("c-lgl-notifications-component").show(message, type);
	}

	orderItems(a, b) {
		let retValue;
		if (a.location > b.location) {
			retValue = 1;
		} else if (a.location < b.location) {
			retValue = -1;
		} else {
			retValue = 0;
		}
		return retValue;
	}
}
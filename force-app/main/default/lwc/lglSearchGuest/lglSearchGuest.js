import { LightningElement, wire } from "lwc";

import searchGuests from "@salesforce/apex/LGL_DashController.searchGuests";

const SEARCH_GUEST_TABLE_COLUMNS = [
	{
		fieldId: "Name",
		fieldLabel: "Name"
	},
	{
		fieldId: "PersonEmail",
		fieldLabel: "Email"
	},
	{
		fieldId: "PersonMobilePhone",
		fieldLabel: "Mobile Phone"
	},
	{
		fieldId: "Country_of_Residence__c",
		fieldLabel: "Country"
	},
	{
		fieldId: "RecordType.Name",
		fieldLabel: "Guest Account Type"
	}
];

const SUCCESS_TYPE = "success";
const ERROR_TYPE = "error";
const WARNING_TYPE = "warning";

export default class LglSearchGuest extends LightningElement {
	searchTerm;
	guestSearchResults = [];
	hasSearched = false;
	searchResultsTableColumns = SEARCH_GUEST_TABLE_COLUMNS;
	loading = false;

	@wire(searchGuests, { searchTerm: "$searchTerm" })
	searchGuests({ data, error }) {
		if (this.searchTerm) {
			if (data) {
				if (data.length <= 10) {
					this.guestSearchResults = data;
				} else {
					this.showNotification(
						"Too many search results. Try restricting the search more",
						WARNING_TYPE
					);
				}
			} else {
				this.showNotification("An error has ocurred", ERROR_TYPE);
				console.error(error);
			}
			this.hasSearched = true;
		}
		this.loading = false;
	}

	handleSearchButton() {
		let inputElement = this.template.querySelector("lightning-input");
		if (this.searchTerm !== inputElement.value) {
			this.searchTerm = inputElement.value;
			this.loading = true;
		}
	}

	handleKeyUp(event) {
		const isEnterKey = event.keyCode === 13;
		if (isEnterKey && this.searchTerm !== event.target.value) {
			this.searchTerm = event.target.value;
			this.loading = true;
		}
	}

	handleGuestSelect(event) {
		this.dispatchEvent(new CustomEvent("rowselection", { detail: event.detail }));
	}

	showNotification(message, type) {
		this.template.querySelector("c-lgl-notifications-component").show(message, type);
	}
}
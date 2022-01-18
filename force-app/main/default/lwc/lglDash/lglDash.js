/*
 * MAIN COMPONENT FOR THE LUGGAGE AND LOANS APP
 * The component instantiates each of the sections that are needed with the sectionVisibility variable.
 * Also gets the basic information needed and passes that into the other components
 */

import { LightningElement, track, wire } from "lwc";
import Id from "@salesforce/user/Id";
import VILLAGE_FIELD from "@salesforce/schema/User.Village__c";

import { getRecord } from "lightning/uiRecordApi";
import getServiceRequests from "@salesforce/apex/LGL_DashController.getServiceRequests";
import getOfferedServices from "@salesforce/apex/LGL_DashController.getOfferedServices";
import getDashInformation from "@salesforce/apex/LGL_DashController.getDashInformation";
import getServiceLocations from "@salesforce/apex/LGL_DashController.getServiceLocations";
import getServiceOfferings from "@salesforce/apex/LGL_DashController.getServiceOfferings";
import { refreshApex } from "@salesforce/apex";

const SUCCESS_TYPE = "success";
const ERROR_TYPE = "error";
const WARNING_TYPE = "warning";

const DEFAULT_SECTION = "dash";
const SECTIONS_MAP = {
	dash: ["dashSummary", "recordsTable"],
	manageItems: ["manageItems"],
	unfulfilled: ["unfulfilled"],
	newService: ["newService"],
	guestDetails: ["guestDetails"]
};

const RECORD_TABLE_COLUMNS = [
	{
		fieldId: "guestID",
		fieldLabel: "GuestID"
	},
	{
		fieldId: "name",
		fieldLabel: "Name"
	},
	{
		fieldId: "luggageItems",
		fieldLabel: "Luggage Items"
	},
	{
		fieldId: "loanItems",
		fieldLabel: "Loan Items"
	},
	{
		fieldId: "lglLocation",
		fieldLabel: "Luggage / Loan Location"
	},
	{
		fieldId: "statusLabel",
		fieldLabel: "Status"
	},
	{
		fieldId: "hasHFS",
		fieldLabel: "Also has HFS?"
	},
	{
		fieldId: "arriveCollectionPoint",
		fieldLabel: "HFS Collection Time"
	}
];

export default class LglDash extends LightningElement {
	userId = Id;
	userVillage = "";
	@track sectionVisibility = {};
	loading = false;
	selectedServiceRequestId;

	@wire(getRecord, { recordId: "$userId", fields: VILLAGE_FIELD })
	getUserVillage({ error, data }) {
		if (data) {
			this.userVillage = data.fields[VILLAGE_FIELD.fieldApiName].value;
		}
	}

	@wire(getServiceRequests, { village: "$userVillage" })
	servicesList;

	@wire(getServiceLocations, { village: "$userVillage" })
	serviceLocations;

	@wire(getOfferedServices, { village: "$userVillage" })
	offeredServices;

	@wire(getDashInformation, { village: "$userVillage" })
	dashRows;

	@wire(getServiceOfferings, { village: "$userVillage" })
	_serviceOfferings;

	get serviceOfferings() {
		if (this._serviceOfferings && this._serviceOfferings.data) {
			return this._serviceOfferings.data;
		}
		return [];
	}

	get recordsCardTitle() {
		return `Left Luggage & Loans for ${this.userVillage} Today`;
	}

	get dashColumns() {
		if (this.offeredServices && this.offeredServices.data) {
			let columns = [];
			for (let offeredService of this.offeredServices.data) {
				columns.push({
					fieldId: offeredService.Id,
					fieldName: offeredService.Name,
					type: offeredService.LGL_Type__c,
					fieldIdentifier: offeredService.LGL_Service_Id__c
				});
			}
			return columns;
		}
		return [];
	}

	get openServices() {
		if (this.servicesList && this.servicesList.data) {
			return this.servicesList.data.filter((service) => service.status !== "closed");
		}
	}

	get closedServices() {
		if (this.servicesList && this.servicesList.data) {
			return this.servicesList.data.filter((service) => service.status === "closed");
		}
	}

	activeSections = [];

	servicesListFields = RECORD_TABLE_COLUMNS;

	connectedCallback() {
		this.changeSection(DEFAULT_SECTION);
	}

	changeSectionFromButton(event) {
		this.changeSection(event.currentTarget.value);
	}

	changeSectionFromEvent(event) {
		this.changeSection(event.detail);
	}

	changeSection(targetSection) {
		for (let section in SECTIONS_MAP) {
			if (Object.prototype.hasOwnProperty.call(SECTIONS_MAP, section)) {
				let isActiveSection = section === targetSection;
				for (let subElement of SECTIONS_MAP[section]) {
					this.sectionVisibility[subElement] = isActiveSection;
				}
			}
		}
	}

	saveMatrixValues() {
		this.loading = true;
		this.template.querySelector("c-lgl-manage-items").saveValues();
	}

	resetMatrixValues() {
		this.template.querySelector("c-lgl-manage-items").resetMatrixValues();
	}

	saveUnfulfilledRequest() {
		this.loading = true;
		this.template.querySelector("c-lgl-unfulfilled-request").saveUnfulfilledRequest();
	}

	handleServiceRequestSelect(event) {
		this.selectedServiceRequestId = event.detail.serviceId;
		this.changeSection("guestDetails");
	}

	handleUrlClick(event) {
		let guestHFSPageUrl = `/apex/HFSGuestPage?ID=${event.detail.caseId}`;
		this.redirectExternalPage(guestHFSPageUrl);
	}

	handleUnfulfilledRequestSave() {
		this.changeSection("dash");
		this.loading = false;
		this.showNotification("Unfulfilled request correctly saved", SUCCESS_TYPE);
	}

	handleUnfulfilledRequestError() {
		this.loading = false;
		this.showNotification(
			"An error has ocurred while saving the unfulfilled request",
			ERROR_TYPE
		);
	}

	handleManageItemsSave() {
		this.refreshDash(() => this.showNotification("Items correctly updated", SUCCESS_TYPE));
		this.refreshServiceOfferings();
	}

	handleNewServiceSave() {
		this.refreshAll(() => {
			this.showNotification("Service request correctly created", SUCCESS_TYPE);
			this.changeSection(DEFAULT_SECTION);
		});
	}

	handleCheckout() {
		this.refreshAll();
	}

	handleLockToggle() {
		this.refreshDash();
		this.refreshServiceOfferings();
	}

	refreshDash(callback) {
		refreshApex(this.dashRows).then(() => {
			this.loading = false;
			if (callback) {
				callback();
			}
		});
	}

	refreshServiceOfferings() {
		refreshApex(this._serviceOfferings);
	}

	refreshAll(callback) {
		this.loading = true;
		const refreshPromises = [
			refreshApex(this.dashRows),
			refreshApex(this.servicesList),
			refreshApex(this._serviceOfferings)
		];
		Promise.all(refreshPromises)
			.then(() => {
				this.loading = false;
				if (callback) {
					callback();
				}
			})
			.catch((error) => {
				this.loading = false;
				console.error(error);
				this.showNotification("An error has ocurred", ERROR_TYPE);
			});
	}

	showNotification(message, type) {
		this.template.querySelector("c-lgl-notifications-component").show(message, type);
	}

	redirectExternalPage(url) {
		window.location = url;
	}
}
import { LightningElement, api, wire, track } from "lwc";
import { getRecord, getFieldValue, getFieldDisplayValue } from "lightning/uiRecordApi";
import getServiceItems from "@salesforce/apex/LGL_DashController.getServiceItems";
import { refreshApex } from "@salesforce/apex";

/* SERVICE REQUEST FIELDS */
import ID_FIELD from "@salesforce/schema/LGL_Service__c.Id";
import NAME_FIELD from "@salesforce/schema/LGL_Service__c.LGL_Name__c";
import EMAIL_FIELD from "@salesforce/schema/LGL_Service__c.LGL_Email__c";
import PHONE_FIELD from "@salesforce/schema/LGL_Service__c.LGL_Phone__c";
import LOCATION_NAME_FIELD from "@salesforce/schema/LGL_Service__c.LGL_Request_Location__r.Name";
import LOCATION_ID_FIELD from "@salesforce/schema/LGL_Service__c.LGL_Request_Location__c";
import SERVICE_START_DATE_FIELD from "@salesforce/schema/LGL_Service__c.LGL_Service_Start_Date__c";
import HFS_CASE_FIELD from "@salesforce/schema/LGL_Service__c.LGL_HFS_Case__c";
import SERVICE_REQUEST_STATUS_FIELD from "@salesforce/schema/LGL_Service__c.LGL_Status__c";

/* SERVICE ITEM FIELDS */
import SERVICE_ITEM_ID_FIELD from "@salesforce/schema/LGL_Service_Item__c.LGL_Service_Item_Identifier__c";
import DEPOSIT_STATUS_FIELD from "@salesforce/schema/LGL_Service_Item__c.LGL_Deposit_Status__c";
import SERVICE_ITEM_STATUS_FIELD from "@salesforce/schema/LGL_Service_Item__c.LGL_Status__c";
import CHECKOUT_HOUR from "@salesforce/schema/LGL_Service_Item__c.LGL_Checkout_Time__c";

import LUGGAGE_TYPE_FIELD from "@salesforce/schema/LGL_Service_Item__c.LGL_Type__c";

const SUCCESS_TYPE = "success";
const ERROR_TYPE = "error";
const WARNING_TYPE = "warning";

const SERVICE_REQUEST_FIELDS = [
	ID_FIELD,
	NAME_FIELD,
	EMAIL_FIELD,
	PHONE_FIELD,
	LOCATION_NAME_FIELD,
	LOCATION_ID_FIELD,
	SERVICE_START_DATE_FIELD,
	HFS_CASE_FIELD,
	SERVICE_REQUEST_STATUS_FIELD
];

const SERVICE_BY_TYPE_TABLE_FIELDS = [
	{
		fieldId: "serviceName",
		fieldLabel: "Service Name"
	},
	{
		fieldId: "serviceStatus",
		fieldLabel: "Status"
	},
	{
		fieldId: "quantity",
		fieldLabel: "Quantity"
	}
];

const SERVICE_ITEMS_TABLE_FIELDS_MAP = {
	lLugg: [
		{
			fieldId: LUGGAGE_TYPE_FIELD.fieldApiName,
			fieldLabel: "Luggage Type"
		},
		{
			fieldId: SERVICE_ITEM_ID_FIELD.fieldApiName,
			fieldLabel: "Key Number"
		},
		{
			fieldId: SERVICE_ITEM_STATUS_FIELD.fieldApiName,
			fieldLabel: "Status"
		},
		{
			fieldId: DEPOSIT_STATUS_FIELD.fieldApiName,
			fieldLabel: "Deposit Status"
		},
		{
			fieldId: "formattedDate",
			fieldLabel: "Collection time"
		}
	],
	default: [
		{
			fieldId: SERVICE_ITEM_ID_FIELD.fieldApiName,
			fieldLabel: "Asset Number"
		},
		{
			fieldId: SERVICE_ITEM_STATUS_FIELD.fieldApiName,
			fieldLabel: "Status"
		},
		{
			fieldId: DEPOSIT_STATUS_FIELD.fieldApiName,
			fieldLabel: "Deposit Status"
		},
		{
			fieldId: "formattedDate",
			fieldLabel: "Return time"
		}
	]
};

const DEFAULT_SECTION = "displayServiceRequestSection";
const SECTIONS_MAP = {
	displayServiceRequestSection: ["displayServiceRequestSection"],
	checkoutSection: ["checkoutSection"],
	addNewService: ["addNewService"]
};

export default class LglServiceRequestDetails extends LightningElement {
	@api serviceRequestId;
	@api serviceOfferings;
	@track sectionVisibility = {};

	serviceRequest = {};
	serviceItemsByType = {};
	serviceItemsByTypeTableFields = SERVICE_BY_TYPE_TABLE_FIELDS;
	@track selectedServiceItemType = {};
	checkoutItems;

	//Created properties to be able to refreshApex on
	wiredServiceRequest;
	wiredServiceItems;

	get loading() {
		return !(
			this.wiredServiceRequest &&
			this.wiredServiceItems &&
			this.wiredServiceRequest.data &&
			this.wiredServiceItems.data
		);
	}

	connectedCallback() {
		this.changeSection(DEFAULT_SECTION);
	}

	@wire(getRecord, {
		recordId: "$serviceRequestId",
		fields: SERVICE_REQUEST_FIELDS
	})
	getServiceRequestDetails(val) {
		this.wiredServiceRequest = val;
		let { data, error } = val;
		if (data) {
			let serviceRequestAux = {}; //We do that to avoid using the @track annotation. Salesforce default tracks when the entire object reference is changed
			for (let serviceRequestField of SERVICE_REQUEST_FIELDS) {
				serviceRequestAux[serviceRequestField.fieldApiName] = getFieldDisplayValue(
					data,
					serviceRequestField
				)
					? getFieldDisplayValue(data, serviceRequestField)
					: getFieldValue(data, serviceRequestField);
			}
			this.serviceRequest = serviceRequestAux;
		} else if (error) {
			this.handleError(error);
		}
	}

	//Needed because, if serviceRequest.LGL_Request_Location__r.Name is directly used in the component, because serviceRequest.LGL_Request_Location__r is
	//undefined when loading, undefined.Name causes an error at component initialization
	get locationName() {
		return this.serviceRequest && this.serviceRequest["LGL_Request_Location__r.Name"]
			? this.serviceRequest["LGL_Request_Location__r.Name"]
			: "";
	}

	get hasHFS() {
		return !!this.serviceRequest[HFS_CASE_FIELD.fieldApiName];
	}

	get hasHFSText() {
		let hasHFSText = "NO";
		if (this.serviceRequest[HFS_CASE_FIELD.fieldApiName]) {
			hasHFSText = "YES";
		}
		return hasHFSText;
	}

	get caseUrl() {
		let caseUrl = "";
		if (this.serviceRequest[HFS_CASE_FIELD.fieldApiName]) {
			caseUrl = `/apex/HFSGuestPage?ID=${this.serviceRequest[HFS_CASE_FIELD.fieldApiName]}`;
		}
		return caseUrl;
	}

	get showCloseAllButton() {
		if (this.wiredServiceRequest.data) {
			return this.wiredServiceRequest.data.fields.LGL_Status__c.value !== "closed";
		} else {
			return false;
		}
	}

	get showCloseButton() {
		return (
			this.selectedServiceItemType.serviceStatus &&
			this.selectedServiceItemType.serviceStatus != "Closed"
		);
	}

	@wire(getServiceItems, { serviceRequestId: "$serviceRequestId" })
	getServiceItems(val) {
		this.wiredServiceItems = val;
		let { data, error } = val;
		if (data) {
			let serviceItemsByType = {};
			data.forEach((serviceItem) => {
				let serviceItemAux = {};
				Object.assign(serviceItemAux, serviceItem); //We do this in order to be able to modify the object. The serviceItems returned from the wire service are not extensible
				serviceItemAux.formattedDate = this.formatDate(
					serviceItem[CHECKOUT_HOUR.fieldApiName]
				);
				if (serviceItemsByType[serviceItemAux.LGL_Service_Type_Identifier__c]) {
					serviceItemsByType[serviceItemAux.LGL_Service_Type_Identifier__c].push(
						serviceItemAux
					);
				} else {
					serviceItemsByType[serviceItemAux.LGL_Service_Type_Identifier__c] = [
						serviceItemAux
					];
				}
			});
			this.serviceItemsByType = serviceItemsByType;
		} else if (error) {
			this.handleError(error);
		}
	}

	get serviceItemsByTypeList() {
		let serviceItemsByTypeList = [];
		if (this.serviceItemsByType) {
			for (let serviceType in this.serviceItemsByType) {
				serviceItemsByTypeList.push({
					serviceIdentifier: serviceType,
					serviceName: this.serviceItemsByType[serviceType][0].LGL_Service_Name__c,
					serviceStatus: this.serviceItemsByType[serviceType][0].LGL_Status__c,
					quantity: this.serviceItemsByType[serviceType].length
				});
			}
		}
		return serviceItemsByTypeList;
	}

	get serviceItemsDetailTableFields() {
		if (
			this.selectedServiceItemType.serviceIdentifier &&
			SERVICE_ITEMS_TABLE_FIELDS_MAP[this.selectedServiceItemType.serviceIdentifier]
		) {
			return SERVICE_ITEMS_TABLE_FIELDS_MAP[this.selectedServiceItemType.serviceIdentifier];
		} else {
			return SERVICE_ITEMS_TABLE_FIELDS_MAP["default"];
		}
	}

	handleServiceTypeSelection(event) {
		this.selectedServiceItemType = {
			serviceName: event.detail.serviceName,
			serviceIdentifier: event.detail.serviceIdentifier,
			serviceStatus: event.detail.serviceStatus,
			serviceItems: this.serviceItemsByType[event.detail.serviceIdentifier]
		};

		let serviceItemsTable = this.template.querySelector(".lgl-service-item-details");
		serviceItemsTable.classList.remove("slds-hide");
		serviceItemsTable.scrollIntoView({
			behavior: "smooth"
		});
	}

	handleCloseAllServices() {
		this.checkoutItems = this.activeServiceItems;
		this.changeSection("checkoutSection");
	}

	handleCloseService() {
		let servicesToCheckout = [
			...this.serviceItemsByType[this.selectedServiceItemType.serviceIdentifier]
		];
		this.checkoutItems = servicesToCheckout;
		this.changeSection("checkoutSection");
	}

	handleAddNewServices() {
		this.changeSection("addNewService");
	}

	handleCheckout() {
		this.refreshComponentDetails(() => {
			this.showNotification("Checkout successfully", SUCCESS_TYPE);
			this.changeSection(DEFAULT_SECTION);
		});
	}

	handleCancelCheckout() {
		this.changeSection(DEFAULT_SECTION);
	}

	handleSaveAddItems() {
		this.refreshComponentDetails(() => {
			this.showNotification("Items Saved Correctly", SUCCESS_TYPE);
			this.changeSection(DEFAULT_SECTION);
		});
	}

	handleErrorAddItems() {
		this.showNotification("An error has ocurred. Contact your administrator", ERROR_TYPE);
	}

	handleCancelAddItems() {
		this.changeSection(DEFAULT_SECTION);
	}

	changeSection(targetSection) {
		for (let section in SECTIONS_MAP) {
			let isActiveSection = section === targetSection;
			for (let subElement of SECTIONS_MAP[section]) {
				this.sectionVisibility[subElement] = isActiveSection;
			}
		}
	}

	showNotification(message, type) {
		this.template.querySelector("c-lgl-notifications-component").show(message, type);
	}

	handleError(error) {
		console.error(error);
		this.showNotification("An error has ocurred. Contact your administrator", ERROR_TYPE);
	}

	get activeServiceItems() {
		let servicesToCheckout = [];

		for (let serviceItemType in this.serviceItemsByType) {
			if (this.serviceItemsByType[serviceItemType][0].LGL_Status__c !== "Closed") {
				servicesToCheckout.push(...this.serviceItemsByType[serviceItemType]);
			}
		}

		return servicesToCheckout;
	}

	formatDate(aDate) {
		let formattedDate = "";
		if (aDate) {
			aDate = new Date(aDate);
			formattedDate = aDate.toLocaleTimeString(navigator.language, {
				hour: "2-digit",
				minute: "2-digit"
			});
		}
		return formattedDate;
	}

	refreshComponentDetails(callback) {
		const refreshPromises = [
			refreshApex(this.wiredServiceRequest),
			refreshApex(this.wiredServiceItems)
		];

		Promise.all(refreshPromises)
			.then(() => {
				if (callback) {
					callback();
				}
			})
			.catch(() => {})
			.finally(() => {
				this.dispatchEvent(new CustomEvent("checkout"));
			});
	}
}
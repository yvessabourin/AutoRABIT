import { LightningElement, api, track, wire } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import getDepositStatuses from "@salesforce/apex/LGL_DashController.getDepositStatuses";

import SERVICE_ITEM_OBJECT from "@salesforce/schema/LGL_Service_Item__c";
import LUGGAGE_TYPE from "@salesforce/schema/LGL_Service_Item__c.LGL_Type__c";

const DUPLICATE_SERVICE_ITEMS_MESSAGE =
	"You must select different identifiers for each service item";

const SERVICE_IDENTIFIER_IN_USE =
	"This service identifier is being used at this moment. Please select another one";

export default class LglServiceSettings extends LightningElement {
	@api userVillage;
	@api serviceType;
	@api serviceOfferingsMap;
	@api selectedLocation;

	exceedingItemsMessage;

	@api get serviceItems() {
		return this.serviceItemsList.map((serviceItem) => {
			serviceItem.LGL_Deposit_Status__c = this.depositStatus;
			return serviceItem;
		});
	}

	get hasExceedingItems() {
		if (this.serviceOfferingsMap && this.selectedLocation && this.serviceType) {
			let selectedServiceOffering = this.serviceOfferingsMap[this.selectedLocation][
				this.serviceType
			];
			if (!selectedServiceOffering.LGL_Manually_Lock__c) {
				let itemsInUse = selectedServiceOffering.Service_Items__r
					? selectedServiceOffering.Service_Items__r.length
					: 0;
				if (itemsInUse + this.numberOfItems > selectedServiceOffering.LGL_Quantity__c) {
					this.exceedingItemsMessage = `There are already ${itemsInUse} ${selectedServiceOffering.LGL_Service_Type__r.Name}
													being used from a total of ${selectedServiceOffering.LGL_Quantity__c}`;
					return true;
				}
				return false;
			}
			this.exceedingItemsMessage = `This service is manually locked at this moment`;
			return true;
		}
		return false;
	}

	@track serviceItemsList = [{}];
	numberOfItems = 1;
	depositStatus;
	depositStatusList;

	defaultRecordType;
	lugaggeTypeOptionsList;

	visibility = {
		lLugg: false,
		wChair: false,
		pChair: false,
		mScoot: false,
		dStrol: false
	};

	get serviceOfferingItemsOptionsList() {
		if (this.serviceOfferingsMap) {
			/* After demoing the functionality, users explain that it is better for now to display all the Identifiers
			 * and not filter by location. For this reason, we temporarily avoid the filtering by location
			 */

			/*if (this.selectedLocation) {
				let serviceOffering = this.serviceOfferingsMap[this.selectedLocation][this.serviceType];
				return serviceOffering.Service_Offering_Items__r.map(serviceOfferingItem => ({
					value: serviceOfferingItem.LGL_Item_Number__c,
					label: serviceOfferingItem.LGL_Item_Number__c
				}));
			} else*/

			let serviceOfferingItemsAllLocations = [];
			for (let serviceLocation in this.serviceOfferingsMap) {
				if (
					Object.prototype.hasOwnProperty.call(this.serviceOfferingsMap, serviceLocation)
				) {
					if (
						this.serviceOfferingsMap[serviceLocation][this.serviceType]
							.Service_Offering_Items__r
					) {
						serviceOfferingItemsAllLocations.push(
							...this.serviceOfferingsMap[serviceLocation][this.serviceType]
								.Service_Offering_Items__r
						);
					}
				}
			}
			serviceOfferingItemsAllLocations.sort(this.orderItems);
			return serviceOfferingItemsAllLocations.map((serviceOfferingItem) => ({
				value: serviceOfferingItem.LGL_Item_Number__c,
				label: serviceOfferingItem.LGL_Item_Number__c
			}));
		}
		return [];
	}

	orderItems(a, b) {
		let retValue;
		if (a.LGL_Item_Number__c > b.LGL_Item_Number__c) {
			retValue = 1;
		} else if (a.LGL_Item_Number__c < b.LGL_Item_Number__c) {
			retValue = -1;
		} else {
			retValue = 0;
		}
		return retValue;
	}

	connectedCallback() {
		this.visibility[this.serviceType] = true;
	}

	handleQtyChange(event) {
		if (event.currentTarget.value && event.currentTarget.value > 0) {
			this.numberOfItems = parseInt(event.currentTarget.value);
		}
		this.adjustServiceItemsList();
	}

	adjustServiceItemsList() {
		while (this.serviceItemsList.length !== this.numberOfItems) {
			if (this.numberOfItems > this.serviceItemsList.length) {
				this.serviceItemsList.push({});
			} else {
				this.serviceItemsList.pop();
			}
		}
	}

	handleDepositStatusChange(event) {
		this.depositStatus = event.currentTarget.value;
	}

	handleFieldChange(event) {
		let editedServiceItem = this.serviceItemsList[parseInt(event.currentTarget.dataset.index)];
		editedServiceItem[event.currentTarget.name] = event.currentTarget.value;

		if (event.currentTarget.name === "LGL_Service_Item_Identifier__c") {
			this.reportServiceItemsValidity();
		}
	}

	getServicesMap() {
		let serviceIdentifierMap = new Map();
		let serviceIdentifierFormElements = [
			...this.template.querySelectorAll("lightning-combobox")
		].filter((formElement) => formElement.name === "LGL_Service_Item_Identifier__c");

		serviceIdentifierFormElements.forEach((formElement) => {
			if (formElement.value) {
				if (serviceIdentifierMap.has(formElement.value)) {
					serviceIdentifierMap.get(formElement.value).push(formElement);
				} else {
					serviceIdentifierMap.set(formElement.value, [formElement]);
				}
			}
		});

		return serviceIdentifierMap;
	}

	reportServiceItemsValidity() {
		let servicesMapByIdentifier = this.getServicesMap();
		servicesMapByIdentifier.forEach((serviceItems) => {
			//First Validation: Check that the selected identifiers are not duplicated in the form
			if (serviceItems.length > 1) {
				serviceItems.forEach((serviceItem) => {
					serviceItem.setCustomValidity(DUPLICATE_SERVICE_ITEMS_MESSAGE);
					serviceItem.reportValidity();
				});
				//Second Validation: Check that the item identifier isn't already being used
			} else if (this.reportItemsInUse(serviceItems[0])) {
				serviceItems[0].setCustomValidity(SERVICE_IDENTIFIER_IN_USE);
				serviceItems[0].reportValidity();
			} else {
				serviceItems[0].setCustomValidity("");
				serviceItems[0].reportValidity();
			}
		});
	}

	reportItemsInUse(formServiceItem) {
		let isServiceItemIdentifierInUse = false;
		if (formServiceItem.value) {
			//We use the serviceoffering map to find it the
			for (let serviceLocation in this.serviceOfferingsMap) {
				if (
					Object.prototype.hasOwnProperty.call(this.serviceOfferingsMap, serviceLocation)
				) {
					let serviceItemsInUse = this.serviceOfferingsMap[serviceLocation][
						this.serviceType
					].Service_Items__r;
					if (serviceItemsInUse) {
						isServiceItemIdentifierInUse = serviceItemsInUse.find(
							(serviceItemInUse) =>
								serviceItemInUse.LGL_Service_Item_Identifier__c ===
								formServiceItem.value
						);
					}
				}
			}
		}
		if (isServiceItemIdentifierInUse) {
			formServiceItem.setCustomValidity(SERVICE_IDENTIFIER_IN_USE);
			formServiceItem.reportValidity();
		} else {
			formServiceItem.setCustomValidity("");
			formServiceItem.reportValidity();
		}
		return isServiceItemIdentifierInUse;
	}

	@wire(getObjectInfo, { objectApiName: SERVICE_ITEM_OBJECT })
	_getObjectInfo({ error, data }) {
		if (data) {
			this.defaultRecordType = data.defaultRecordTypeId;
		}
	}

	@wire(getPicklistValues, {
		recordTypeId: "$defaultRecordType",
		fieldApiName: LUGGAGE_TYPE
	})
	getLugageTypeOptions({ error, data }) {
		if (data) {
			this.lugaggeTypeOptionsList = data.values;
		}
	}

	@wire(getDepositStatuses, { village: "$userVillage" })
	getDepositStatuses({ error, data }) {
		if (data) {
			this.depositStatusList = data.map((depositStatus) => ({
				value: depositStatus.Data_Code__c,
				label: depositStatus.Data_Label__c
			}));
		}
	}

	@api reportValidity() {
		let formInputs = [...this.template.querySelectorAll("lightning-input,lightning-combobox")];
		formInputs.forEach((formInput) => formInput.reportValidity());
	}

	@api checkValidity() {
		let formElements = [
			...this.template.querySelectorAll("lightning-input,lightning-combobox")
		];
		const isFormValid = formElements.reduce((validSoFar, formElement) => {
			formElement.reportValidity();
			return validSoFar && formElement.checkValidity();
		}, true);
		return isFormValid && !this.hasExceedingItems;
	}
}
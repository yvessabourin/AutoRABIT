import { LightningElement, api } from "lwc";

export default class LglServiceOfferingItemsSection extends LightningElement {
	@api serviceOfferingsItemsMap;
	@api serviceType;

	serviceOfferingItems;

	connectedCallback() {
		this.serviceOfferingItems = this.serviceOfferingsItemsMap[this.serviceType];
	}
}
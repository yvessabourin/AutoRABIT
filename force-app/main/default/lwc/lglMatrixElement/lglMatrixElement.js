import { LightningElement, api, track } from "lwc";

const EDITED_ELEMENT = "lgl-edited slds-var-m-horizontal_x-small slds-var-p-horizontal_x-small";
const NON_EDITED_ELEMENT = "slds-var-m-horizontal_x-small slds-var-p-horizontal_x-small";

export default class LglMatrixElement extends LightningElement {
	@api allElements = {};
	@api rowId;
	@api columnId;

	@track _element;

	@api get element() {
		return this._element;
	}

	@api get edited() {
		return (
			this._element.LGL_Quantity__c !==
			this.allElements[this.rowId][this.columnId].LGL_Quantity__c
		);
	}

	addItem() {
		this._element.LGL_Quantity__c++;
	}

	deleteItem() {
		this._element.LGL_Quantity__c--;
	}

	connectedCallback() {
		this._element = Object.assign({}, this.allElements[this.rowId][this.columnId]);
	}

	get disabledSubstract() {
		return this._element.LGL_Quantity__c === 0;
	}

	get elementClass() {
		return this._element.LGL_Quantity__c !==
			this.allElements[this.rowId][this.columnId].LGL_Quantity__c
			? EDITED_ELEMENT
			: NON_EDITED_ELEMENT;
	}

	@api resetValue() {
		this._element = Object.assign({}, this.allElements[this.rowId][this.columnId]);
	}
}
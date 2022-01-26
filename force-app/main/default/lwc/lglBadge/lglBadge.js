import { LightningElement, api } from "lwc";
const FULL_CLASS = "lgl-full lgl-badge";
const INFO_CLASS = "lgl-info lgl-badge";
const EMPTY_CLASS = "lgl-empty lgl-badge";

export default class LglBadge extends LightningElement {
	@api usedElements = 0;
	@api totalElements = 0;

	get badgeClass() {
		if (this.usedElements === 0) {
			return EMPTY_CLASS;
		} else if (this.usedElements === this.totalElements) {
			return FULL_CLASS;
		}
		return INFO_CLASS;
	}
}
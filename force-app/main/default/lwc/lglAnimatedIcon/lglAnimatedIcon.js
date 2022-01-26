import { LightningElement, api } from "lwc";

export default class LglAnimatedIcon extends LightningElement {
	@api iconName = "utility:lock";
	@api size = "xx-small";

	handleIconClick(event) {
		event.currentTarget.classList.toggle("lgl-rotated-icon");

		this.dispatchEvent(new CustomEvent("iconclick"));
	}
}
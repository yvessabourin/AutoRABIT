import { LightningElement, api } from "lwc";

const ROTATED_CLASS = "lgl-rotated";
const COLLAPSED_CLASS = "lgl-collapsed";

export default class LglCollapsableSection extends LightningElement {
	@api title;
	@api initiallyCollapsed = false;
	@api sectionMaxHeight;

	initializedComponent = false;

	get initialClasses() {
		let initialIconClass = this.initiallyCollapsed
			? "lgl-collapse-icon"
			: "lgl-collapse-icon " + ROTATED_CLASS;
		let initialSectionClass = this.initiallyCollapsed
			? "lgl-collapse-section " + COLLAPSED_CLASS
			: "lgl-collapse-section";

		let initialClassesObject = {
			icon: initialIconClass,
			section: initialSectionClass
		};
		return initialClassesObject;
	}

	toggleSection() {
		this.template.querySelector(".lgl-collapse-section").classList.toggle(COLLAPSED_CLASS);
		this.template.querySelector(".lgl-collapse-icon").classList.toggle(ROTATED_CLASS);
	}

	renderedCallback() {
		if (!this.initializedComponent) {
			this.template
				.querySelector(".lgl-collapse-section")
				.style.setProperty("--section-max-height", this.sectionMaxHeight);
			this.initializedComponent = true;
		}
	}
}
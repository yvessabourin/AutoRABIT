import { LightningElement, api, track } from "lwc";

const SECTIONS_MAP = {
	searchSection: ["searchSection", "searchSection"],
	newServiceSection: ["newServiceForm"]
};

const DEFAULT_SECTION = "searchSection";

export default class LglNewService extends LightningElement {
	@api userVillage;
	@api serviceOfferings;
	@track sectionVisibility = {};

	selectedGuestId;

	connectedCallback() {
		this.changeSection(DEFAULT_SECTION);
	}

	handleGuestSelection(event) {
		this.selectedGuestId = event.detail.Id;
		this.changeSection("newServiceSection");
	}

	handleNewService() {
		this.selectedGuestId = null;
		this.changeSection("newServiceSection");
	}

	changeSection(targetSection) {
		let targetSubElements = SECTIONS_MAP[targetSection];
		for (let section in SECTIONS_MAP) {
			let isActiveSection = section === targetSection;
			for (let subElement of SECTIONS_MAP[section]) {
				this.sectionVisibility[subElement] = isActiveSection;
			}
		}
	}

	handleSaveEvent() {
		this.dispatchEvent(new CustomEvent("save"));
	}

	handleCancelEvent() {
		this.changeSection(DEFAULT_SECTION);
	}
}
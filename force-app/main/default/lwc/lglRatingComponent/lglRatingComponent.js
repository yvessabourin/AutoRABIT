import { LightningElement, api } from "lwc";

const ERROR_CLASS = "lgl-has-error";

export default class LglRatingComponent extends LightningElement {
	@api rating;
	@api ratingText;
	@api label = "Select a Rating";
	@api minValueLabel = "Highly dissatisfied";
	@api maxValueLabel = "Highly satisfied";
	@api minValue = 1;
	@api maxValue = 5;
	@api radioGroupName = "radioGroup";
	@api required = false;

	radioItems = [];

	get valuesDescription() {
		return `${this.minValue} - ${this.minValueLabel}, ${this.maxValue} - ${this.maxValueLabel}`;
	}

	connectedCallback() {
		this.createRadioItems();
	}

	createRadioItems() {
		let counter = this.minValue;
		do {
			this.radioItems.push(counter);
			counter++;
		} while (counter <= this.maxValue);
	}

	handleRadioSelection(event) {
		this.rating = parseInt(event.currentTarget.value);
		this.dispatchEvent(
			new CustomEvent("change", {
				detail: parseInt(event.currentTarget.value)
			})
		);
		this.reportValidity();
	}

	@api checkValidity() {
		return !(this.required && !this.rating && this.rating !== 0);
	}

	@api reportValidity() {
		//Because 0 is a falsy value, we must take this into account because 0 is a valid value
		if (this.required && !this.rating && this.rating !== 0) {
			this.template.querySelector(".lgl-rating-container").classList.add(ERROR_CLASS);
		} else {
			this.template.querySelector(".lgl-rating-container").classList.remove(ERROR_CLASS);
		}
	}
}
import { LightningElement, api } from "lwc";

export default class LglSignatureCanvas extends LightningElement {
	hasSigned = false;
	initialized = false;
	canvas;
	context;
	isDrawing = false;
	accountId = "";
	touch;
	prevX = 0;
	prevY = 0;
	currX = 0;
	currY = 0;
	canvasWidth;
	canvasHeight;

	@api get signatureValue() {
		let strDataURI = this.canvas.toDataURL();
		return strDataURI.replace(/^data:image\/(png|jpg);base64,/, "");
	}

	@api reportValidity() {
		this.hasSigned
			? this.canvas.classList.remove("lgl-required")
			: this.canvas.classList.add("lgl-required");
	}

	@api checkValidity() {
		return this.hasSigned;
	}

	renderedCallback() {
		if (!this.initialized) {
			this.canvas = this.template.querySelector("canvas");
			this.context = this.canvas.getContext("2d");
			this.context.strokeStyle = "black";
			this.context.lineWidth = "2";
			this.canvasWidth = this.canvas.width;
			this.canvasHeight = this.canvas.height;
			this.initialized = true;
		}
	}

	clearSignature() {
		this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
		this.hasSigned = false;
	}

	start(event) {
		event.preventDefault();
		this.isDrawing = true;

		if (event.clientX) {
			this.currX = event.clientX + window.pageXOffset - this.canvas.offsetLeft;
			this.currY = event.clientY + window.pageYOffset - this.canvas.offsetTop;
		} else {
			// it is probably a mobile, and need to use touch
			this.touch = event.touches[0];
			this.currX = this.touch.pageX - this.canvas.offsetLeft;
			this.currY = this.touch.pageY - this.canvas.offsetTop;
		}

		this.context.beginPath();
		this.context.fillStyle = "cadetblue";
		this.context.fillRect(this.currX, this.currY, 2, 2);
		this.context.closePath();
		// since its starting, there should be no previous
		// the next previous should be the current
		this.prevX = this.currX;
		this.prevY = this.currY;
	}

	draw(event) {
		event.preventDefault();

		if (this.isDrawing) {
			//DEV TEAM L
			if (event.clientX) {
				this.currX = event.clientX + window.pageXOffset - this.canvas.offsetLeft;
				this.currY = event.clientY + window.pageYOffset - this.canvas.offsetTop;
			} else {
				// it is probably a mobile, and need to use touch
				this.touch = event.touches[0];
				this.currX = this.touch.pageX - this.canvas.offsetLeft;
				this.currY = this.touch.pageY - this.canvas.offsetTop;
			}

			this.context.beginPath();
			this.context.moveTo(this.prevX, this.prevY);
			this.context.lineTo(this.currX, this.currY);
			this.context.strokeStyle = "cadetblue";
			this.context.lineWidth = "2";
			this.context.stroke();
			this.context.closePath();
			this.prevX = this.currX;
			this.prevY = this.currY;
		}
	}

	stop(event) {
		event.preventDefault();

		if (this.isDrawing) {
			this.context.stroke();
			this.context.closePath();
			this.isDrawing = false;
			this.prevX = this.currX;
			this.prevY = this.currY;
			this.hasSigned = true;
			this.isDrawing = false;
		}
	}
}
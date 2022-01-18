import { LightningElement, api } from "lwc";
const LINK_CELL_CLASS = "lgl-link-cell";

export default class LglTable extends LightningElement {
	@api columns;
	@api rows;
	@api tableKey = "";
	@api emptyTableText;
	@api showTotal = false;
	@api totalLabel = "Total";

	get hasTableRows() {
		return this.rows && this.rows.length > 0;
	}

	get _rows() {
		if (
			this.rows &&
			this.rows.length > 0 &&
			this.columns &&
			this.columns.length > 0 &&
			this.tableKey
		) {
			return this.convertRowFieldsToArrays();
		}
		return [];
	}

	get totalColSpan() {
		if (this.columns) {
			return this.columns.length - 1;
		}
		return 0;
	}

	get totalValue() {
		if (this.rows) {
			return this.rows.length;
		}
		return 0;
	}

	convertRowFieldsToArrays() {
		let finalRows = [];

		for (let row of this.rows) {
			let newRow = { key: row[this.tableKey], columns: [] };
			for (let column of this.columns) {
				let columnValue = this.getColumnValue(row, column.fieldId);
				newRow.columns.push({
					name: column.fieldId,
					value: columnValue,
					class:
						column.fieldId === "hasHFS" && row[column.fieldId] === "YES"
							? LINK_CELL_CLASS
							: ""
				});
			}
			finalRows.push(newRow);
		}

		return finalRows;
	}

	handleRowClick(event) {
		let selectedRow = this.rows.find(
			(row) => event.currentTarget.dataset.id === row[this.tableKey]
		);

		if (event.target.classList.contains(LINK_CELL_CLASS)) {
			this.dispatchEvent(new CustomEvent("urlclick", { detail: selectedRow }));
		} else {
			this.dispatchEvent(new CustomEvent("rowselection", { detail: selectedRow }));
		}
	}

	//Gets the value of the row by considering also fields on possible parent objects (with dot . notation)
	getColumnValue(row, field) {
		if (row && field) {
			let fieldIdentifiers = field.includes(".") ? field.split(".") : [field];
			return fieldIdentifiers.reduce(
				(valueSoFar, fieldIdentifier) => valueSoFar[fieldIdentifier],
				row
			);
		}
		return "";
	}
}
import {
    LightningElement,
    track,
    api
} from 'lwc';
import Sort_by from "@salesforce/label/c.Sort_by";

export default class Brs_sortDropDown extends LightningElement {
    @api options = ["name", "date", "time"];
    @api defaultValue;
    @api selectedSort;
    @track expandSort = false;

    label = {
        Sort_by
    }
    connectedCallback() {
        document.addEventListener('keydown', function () {
            document.documentElement.classList.remove('mouseClick');
        });
        document.addEventListener('mousedown', function () {
            document.documentElement.classList.add('mouseClick');
        });
    }
    handleExpandSort() {
        this.expandSort = !this.expandSort;
    }
    handleExpandSortKey(event) {
        if (event.keyCode == 13) {
            this.handleExpandSort();
        }
    }
    handleSort(event) {
        this.selectedSort = event.currentTarget.dataset.id;
        this.expandSort = false;
        const sortevent = new CustomEvent("sortselected", {
            detail: this.selectedSort
        });
        this.dispatchEvent(sortevent);
    }
    handleSortKey(event) {
        if (event.keyCode == 13) {
            this.handleSort(event);
        }
    }
}
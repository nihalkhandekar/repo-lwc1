import { LightningElement, track, api } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import select_filters from "@salesforce/label/c.select_filters";
import clear_all_filters from "@salesforce/label/c.clear_all_filters";
import rc_Filters_label from "@salesforce/label/c.rc_Filters_label";
import Date_placeholder from "@salesforce/label/c.Date_placeholder";

export default class Brs_advanceSearchFilters extends LightningElement {
    @track closeIcon = assetFolder + "/icons/closeIcon.png";
    @track showSelectedFilter = false;
    @track expandFilter = true;
    @track showFilters = false;
    @api filters;
    @api showDateFilter;
    @track selectedOptions;
    @track selectedFiltersList = [];

    labels = {
        select_filters,
        clear_all_filters,
        rc_Filters_label,
        Date_placeholder
    }

    showAllFilters(event) {
        const searchType = event.currentTarget.dataset.id;
        const showAll = new CustomEvent("showall", {
            bubbles: true,
            composed: true,
            detail: { searchType: searchType }
        });
        this.dispatchEvent(showAll);
    }

    /**
     * @function handleFilterClose - Updates the filter array on click of close button on 
     * selected filter option in mobile
     * @param event
     */
    handleFilterClose(event) {
        let targetId = event.target.id;
        let filterIndex = event.currentTarget.dataset.id;
        let temp = targetId.split("-");
        if(temp.length > 2){
            temp.pop();
            targetId = temp.join("-");
          } else {
              targetId = temp[0];
          }
        let tempList = [];
        let tempListValue = [];
        this.selectedFiltersList.forEach(element => {
            if (element.value != targetId) {
                tempList.push(element);
            }
        });

        this.selectedFiltersList = tempList;
        const type = this.filters[filterIndex].apiName;
        const searchType = this.filters[filterIndex].searchType;
        const selectedOptions = this.filters[filterIndex].selectedOptions;
        selectedOptions.forEach(element => {
            if (element != targetId) {
                tempListValue.push(element);
            }
        });
        this.selectedOptions = tempListValue;
        const selectedEvent = new CustomEvent("filterselection", {
            bubbles: true,
            composed: true,
            detail: { type: type, selectedOptions: this.selectedOptions, searchType: searchType }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        this.updateFilters(filterIndex, this.filters);
    }
    /**
     * handleClearFilters - method to clears all filters
     */
    handleClearFilters() {
        this.selectedFiltersList.length = 0;
        this.selectedOptions.length = 0;
        const selectedEvent = new CustomEvent("clearfilter", {
            bubbles: true,
            composed: true,
            // detail: { type: selectedFilterType, selectedOptions: [selectedDate] }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        this.showSelectedFilter = false;
    }

    handleShowFilter() {
        this.expandFilter = !this.expandFilter;
    }

    handleDate(event) {
        const selectedDate = event.detail;
        const selectedFilterType = event.currentTarget.dataset.id;
        const selectedEvent = new CustomEvent("filterselection", {
            bubbles: true,
            composed: true,
            detail: { type: selectedFilterType, selectedOptions: [selectedDate] }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    /**
     * @function handlecheckboxResult - Callback for checkbox selection and dispatches filterselection event to parent
     * @param event
     */
    handlecheckboxResult(event) {
        let filterIndex;
        this.selectedOptions = event.detail.result;
        const selectedFilterType = event.currentTarget.dataset.id;
        filterIndex = this.filters.findIndex(element => element.searchType == selectedFilterType);
        const type = this.filters[filterIndex].apiName;
        const searchType = this.filters[filterIndex].searchType;
        const selectedEvent = new CustomEvent("filterselection", {
            bubbles: true,
            composed: true,
            detail: { type: type, selectedOptions: this.selectedOptions, searchType: searchType }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        this.updateFilters(filterIndex, this.filters);
    }

    /**
     * @function updateFilters - update the selectedFiltersList filter array with the values 
     * selected based on isChecked property
     * @param  index 
     * @param  inputArray
     */
    updateFilters(index, inputArray) {
        inputArray[index].filterOptions.forEach((elm) => {
            const found = this.selectedFiltersList.findIndex(filter => filter.value === elm.value);
            if (elm.isChecked) {
                if (found === -1) {
                    this.selectedFiltersList.push({
                        "label": elm.label,
                        "value": elm.value,
                        "parentIndex": index
                    })
                }
            } else {
                if (found !== -1) {
                    this.selectedFiltersList.splice(found, 1);
                }
            }
        });
        if (this.selectedFiltersList.length) {
            this.showSelectedFilter = true;
        } else {
            this.showSelectedFilter = false;
        }
    }
}
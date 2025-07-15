import { LightningElement, track, api, wire } from 'lwc';
import fatchPickListValue from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.fatchPickListValue';
import label_Filter from '@salesforce/label/c.recovery_transparencyFilterLabel';
import label_Sector from '@salesforce/label/c.recovery_transparencySectorLabel';
import label_County from '@salesforce/label/c.recovery_transparencyCountyLabel';
import label_Clear from '@salesforce/label/c.recovery_transparencyClearLabel';

export default class Recovery_transparencyFilterLWC extends LightningElement {
    @track sectorValues;            
    @track countyValues;
    @track showClearSectorFilter = false;
    @track showClearCountyFilter = false;

    @api selectedSectorValues = [];
    @api selectedCountyValues = [];

    label = {
        label_Filter,
        label_Sector,
        label_County,
        label_Clear
    }

    connectedCallback(){
        this.countyValues = [];
        this.sectorValues = [];
    }
 
    handleSectorFilterChange(event){
        this.selectedSectorValues = event.detail.value;
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("selectedsectorvalueschange", {
            detail: this.selectedSectorValues
        });
            
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

        if (this.selectedSectorValues.length >= 1) { 
            this.showClearSectorFilter = true;
        }
        else{
            this.showClearSectorFilter = false;
        }
    }

    handleSectorClear(event){
        this.selectedSectorValues = [];
        // Creates the event with the data.
            const selectedEvent = new CustomEvent("selectedsectorvalueschange", {
            detail: this.selectedSectorValues
        });
            
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

        if (this.selectedSectorValues.length >= 1) { 
            this.showClearSectorFilter = true;
        }
        else{
            this.showClearSectorFilter = false;
        }
    }

    handleCountyFilterChange(event){
        this.selectedCountyValues = event.detail.value;
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("selectedcountyvalueschange", {
            detail: this.selectedCountyValues
        });
            
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

        if (this.selectedCountyValues.length >= 1) { 
            this.showClearCountyFilter = true;
        }
        else{
            this.showClearCountyFilter = false;
        }
    }

    handleCountyClear(event){
        this.selectedCountyValues = [];
        // Creates the event with the data.
            const selectedEvent = new CustomEvent("selectedcountyvalueschange", {
            detail: this.selectedCountyValues
        });
            
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

        if (this.selectedCountyValues.length >= 1) { 
            this.showClearCountyFilter = true;
        }
        else{
            this.showClearCountyFilter = false;
        }
    }

    @wire(fatchPickListValue, {objInfo: {'sobjectType' : 'Business_Reopen_Certification__c'},
        picklistFieldApi:['Business_Address_County__c','Sector__c']}) picklistValues({error,data}){
			if(data){
                var countyPicklistValues = [];
                var businessSectorPicklistValues = [];

                data.forEach (function(item) {
                    if(item.fieldName === 'Business_Address_County__c'){
                        const option = {};
                        option.label = item.label;
                        option.value = item.value;
                        countyPicklistValues.push(option);
                    }
                    else if(item.fieldName === 'Sector__c'){
                        const option = {};
                        option.label = item.label;
                        option.value = item.value;
                        businessSectorPicklistValues.push(option);
                    }
                })
                this.countyValues = countyPicklistValues;
                this.sectorValues = businessSectorPicklistValues;
			}
    }
    
}
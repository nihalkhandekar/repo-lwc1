import { LightningElement, track, api } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import label_Header from '@salesforce/label/c.recovery_transparencySearchHeader';
import label_BusinessName from '@salesforce/label/c.Recovery_SelfCertify_BusinessNameLabel';
import label_City from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderCity';
import label_ZipcCode from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderBusinessZipCode';
import label_searchPlaceholder from '@salesforce/label/c.recovery_transparencySearchPlaceholder';

export default class Recovery_transparencySearchLWC extends LightningElement {
    @track searchIcon = assetFolder + "/icons/searchIcon.svg";    
    @track closeIcon = assetFolder + "/icons/close-circle.svg";
    @track searchIconSymbol = true;

    @api selectedFilterType = "Business_Name__c";
    @api inputValue="";

    label = {
        label_Header,
        label_searchPlaceholder
    }

    connectedCallback(){
    }
  
    get filterType() {
        return [
            { label: label_BusinessName, value: 'Business_Name__c' },
            { label: label_City, value: 'Business_Address_City__c' },
            { label: label_ZipcCode, value: 'Business_Address_Zip_Code__c'},
        ];
    }

    handleSearchValue(event){    
        this.inputValue= event.target.value;
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("inputvaluechange", {
            detail: this.inputValue
        });
    
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

        if (this.inputValue == null || this.inputValue == undefined || this.inputValue.length == 0) { 
            this.searchIconSymbol = true;
        }
        else{
            this.searchIconSymbol = false;
        } 
    }

    handleSearchClick(event){
        if (this.inputValue == null || this.inputValue == undefined || this.inputValue.length == 0) { 
            this.searchIconSymbol = true;
        }
        else{
            this.searchIconSymbol = false;
        }
    }

    handleClearClick(event){
        this.inputValue="";
        if (this.inputValue == null || this.inputValue == undefined || this.inputValue.length == 0) { 
            this.searchIconSymbol = true;
        }
        else{
            this.searchIconSymbol = false;
        }
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("inputvaluechange", {
            detail: this.inputValue
        });
    
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    handleFilterType(event){
        this.selectedFilterType = event.detail.value;
          // Creates the event with the data.
        const selectedEvent = new CustomEvent("selectedfiltertypechange", {
           detail: this.selectedFilterType
        });
        
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }    
}
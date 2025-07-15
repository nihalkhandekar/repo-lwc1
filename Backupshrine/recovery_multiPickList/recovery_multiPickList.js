import {LightningElement, wire, api, track} from 'lwc';
import fatchPickListValue from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.fatchPickListValue';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Recovery_SignupMorethan3IndustryError from '@salesforce/label/c.Recovery_SignupMorethan3IndustryError';
import recovery_SignupPageIndustry1 from '@salesforce/label/c.recovery_SignupPageIndustry1';
import recovery_SignupPageIndustry2 from '@salesforce/label/c.recovery_SignupPageIndustry2';
import recovery_SignupPageIndustry3 from '@salesforce/label/c.recovery_SignupPageIndustry3';

export default class recovery_multiPickList extends LightningElement {

    @api labelValue=''; //Name of the dropDown
    @api placeholderValue=''; // Placeholder Value
    @api sobjectTypeName; // SObject API Name
    @api picklistFieldApiName; // Field API Name

    @track _mOptions; // Options to display on UI
    @track industryPickVal; // Picklist Values from Wire method
    @track _selectedItems;  //Store selected items
    @track _initializationCompleted = false;
    @track showSelectedArray = false;
    @track yourSelectedValues;
    @track closeIcon = assetFolder + "/icons/closeIcon.png";
    @track yourSelectedValuesLength=0;
    @track showUIError = false;
    @track objInfoValue;

    label = {
        Recovery_SignupMorethan3IndustryError
    }
    constructor () {
        super();
    }

    connectedCallback () {
        this._mOptions = [];
        this.yourSelectedValues = [];
        this.objInfoValue = {'sobjectType' : this.sobjectTypeName};
    }

    @wire(fatchPickListValue, {objInfo: '$objInfoValue',
        picklistFieldApi:'$picklistFieldApiName'}) picklistValues({data,error}){
            if(data)
            {
                var industryPicklistOptions = [];
                data.forEach (function(item,i) {
                    const option = {};                    
                    option.key = data[i].label;
                    option.value = data[i].value;
                    option.selected = false;
                    industryPicklistOptions.push(option);
                })
                this._mOptions  = industryPicklistOptions;
                this._mOptions  = JSON.parse(JSON.stringify (this._mOptions));
            }
            else if(error)
            {
                console.log('Error'+JSON.stringify(error));
            }
    }

    renderedCallback () {
        let self = this;
        if (!this._initializationCompleted) {
            this.template.querySelector ('.ms-input').addEventListener ('click', function (event) {
                self.onDropDownClick(event.target);
                event.stopPropagation ();
            });
            document.addEventListener ('click', function (event) {
                self.closeAllDropDown();
            });
            this._initializationCompleted = true;
            this.setPickListName ();
        }
    }

    handleItemSelected (event) {
        let currTargetItem = event.currentTarget.title;
        let self = this;
        let addItem = false;
        self.showUIError = false;

        this._mOptions.forEach (function (item){                      
            if(item.key == event.currentTarget.title){
                if(!item.selected){
                    if(self.yourSelectedValuesLength < 3){
                        item.selected = true;
                        addItem = true;
                        self.showUIError = false;
                    }
                    else{
                        self.showUIError = true;
                    }
                }
                else{
                    item.selected = false;
                    addItem = false;
                }
            }
        });

        if(!self.showUIError){
            let lstClss = this.template.querySelector(`[title="${currTargetItem}"]`);
            if(addItem){
                lstClss.classList.add('slds-is-selected');
            }
            else{
                lstClss.classList.remove('slds-is-selected');
            }

            this.setPickListName ();
            this.onItemSelected ();
        }
    }
    
    handleClose(event){
        let currTargetItem = event.currentTarget.title;
        let removeItem = false;
        let self = this;

        this._mOptions.forEach (function (item){                      
            if(item.key == event.currentTarget.title){
                item.selected = false;
                removeItem = true;
                self.showUIError = false;
            }         
        });

        let lstClss = this.template.querySelector(`[title="${currTargetItem}"]`);
        if(removeItem){
            lstClss.classList.remove('slds-is-selected');
        }

        this.setPickListName ();
        this.onItemSelected ();
    }

    closeAllDropDown () {
        Array.from (this.template.querySelectorAll ('.ms-picklist-dropdown')).forEach (function (node) {
             node.classList.remove('slds-is-open');
        });
        let lstClss = this.template.querySelector ('.ms-input');  

        if(this.yourSelectedValues == null || this.yourSelectedValues == undefined || this.yourSelectedValues.length == 0){
            lstClss.classList.add('errorBorderClass');
        }
        else{
            lstClss.classList.remove('errorBorderClass');
        } 
    }

    onDropDownClick (dropDownDiv) {
        Array.from (this.template.querySelectorAll ('.ms-picklist-dropdown')).forEach (function (node) {
            if(!(String(node.classList).includes("slds-is-open"))){
                node.classList.add('slds-is-open');
            }
            else{
                node.classList.remove('slds-is-open');
            }            
        });

        let lstClss = this.template.querySelector ('.ms-input');  

        if(this.yourSelectedValues == null || this.yourSelectedValues == undefined || this.yourSelectedValues.length == 0){
            lstClss.classList.add('errorBorderClass');
        }
        else{
            lstClss.classList.remove('errorBorderClass');
        }       
    }

    setPickListName () {
        let selecedItems = this.getSelectedItems ();
        this.yourSelectedValues = selecedItems;
        this.yourSelectedValuesLength = this.yourSelectedValues.length;

        let selections = '' ;
        if (selecedItems.length === 1) {
            selections = recovery_SignupPageIndustry1;
        }
        else if (selecedItems.length === 2) {
            selections = recovery_SignupPageIndustry2;
        }
        else if (selecedItems.length === 3) {
            selections = recovery_SignupPageIndustry3;
        }
        else {
            selecedItems.forEach (option => {
                selections += option.value+',';
            });
        }
        this._selectedItems = selections;
        if (selecedItems.length > 0) {
            this.showSelectedArray = true;
        }
    }

    @api
    getSelectedItems () {
        let resArray = new Array ();
        this._mOptions.forEach (function (eachItem) {
            if (eachItem.selected) {
                resArray.push (eachItem);
            }
        });
        return resArray;
    }

    onItemSelected () {
        const evt = new CustomEvent ('itemselected', {
            detail : this.getSelectedItems ()
        });
        this.dispatchEvent (evt);
    }
}
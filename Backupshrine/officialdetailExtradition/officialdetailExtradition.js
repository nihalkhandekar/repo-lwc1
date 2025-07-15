import { LightningElement,track,wire,api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';
import ADDRESS_STYLES from '@salesforce/resourceUrl/addressStyles'; 
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PUBLIC_OFFICIALS_OBJECT from '@salesforce/schema/Contact';
import POSITION_FIELD from '@salesforce/schema/Contact.Position__c';
import JUDICIAL_DISTRICT_FIELD from '@salesforce/schema/Contact.Judicial_District__c';

export default class OfficialdetailExtradition extends LightningElement {


   // Public properties for the Flow
   @api position;
   @api location='';
   @api judicialDistrict;
   @api GA;
   @api termstartDate;
   @api termendDate;
   @api isIndefiniteTerm = false;

   @api showError = false;

   @api isReadOnly = false;

    @track positionSelectOptions = [];
    @track judicialSelectOptions = [];

    @api city = '';
    @api state = '';
    @api zipCode = '';
    @api country = '';
  

   @wire(getObjectInfo, { objectApiName: PUBLIC_OFFICIALS_OBJECT })
   publicOfficialsObjectInfo;

   @wire(getPicklistValues, {
    recordTypeId: '$publicOfficialsObjectInfo.data.defaultRecordTypeId',
    fieldApiName: POSITION_FIELD
    })
    positionPicklistValues({ error, data }) {
        if (data) {
            this.positionSelectOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching status by values', error);
            this.positionSelectOptions = [];
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$publicOfficialsObjectInfo.data.defaultRecordTypeId',
        fieldApiName: JUDICIAL_DISTRICT_FIELD
        })
        judicialPicklistValues({ error, data }) {
            if (data) {
                this.judicialSelectOptions = data.values.map(picklistOption => ({
                    label: picklistOption.label,
                    value: picklistOption.value
                }));
            } else if (error) {
                console.error('Error fetching status by values', error);
                this.judicialSelectOptions = [];
            }
        }

    connectedCallback() {
      loadStyle(this, stateExtradition)
        .then(() => {
            console.log('First CSS file (stateExtradition) loaded successfully');
            return loadStyle(this, ADDRESS_STYLES);
        })
          .catch(error => console.error('Error loading CSS file:', error));
      }


    handlepositionChange(event) {
      this.position = event.target.value;
    }

    handlelocationChange(event) {
        this.location = event.target.value;
      }

      handlejudicialChange(event) {
        this.judicialDistrict = event.target.value;
      }

      handlegaChange(event) {
        this.GA = event.target.value;
      }

      handletermstartChange(event) {
        this.termstartDate = event.target.value;
      }

      handletermendChange(event) {
        this.termendDate = event.target.value;
      }

  handleIndefiniteTermChange(event) {
    this.isIndefiniteTerm = !this.isIndefiniteTerm;
    }
 
    handleAddressChange(event) {
      this.city = event.detail.city;
      this.state = event.detail.province;
      this.zipCode = event.detail.postalCode;
      this.country = event.detail.country;
  }




}
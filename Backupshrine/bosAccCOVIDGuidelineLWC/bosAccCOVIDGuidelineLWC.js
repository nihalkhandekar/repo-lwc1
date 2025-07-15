/**********************************************************************************************
 * NAME:  bosAccCOVIDGuidelineLWC.js
 * DESCRIPTION: Covid-19 Rules and guidlines Registration Form. 
 *
 * @AUTHOR: Devesh Murdiya
 * @DATE: 12/05/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Devesh Murdiya                    12/05/2020                         Created the first version
 *
*********************************************************************************************/
import { LightningElement,api,track,wire } from 'lwc';
import fatchPickListValue from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.fatchPickListValue';
import createBusinessReopenCertificationRecord from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.createBusinessReopenCertificationRecord';
//import updateBusinessReopenCertificationRecord from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.updateBusinessReopenCertificationRecord';
import getSector from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.getSector';
import REG_OBJECT from '@salesforce/schema/Business_Reopen_Certification__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class BosAccCOVIDGuidelineLWC extends LightningElement {
    @track
    countryValues;
    @track
    stateValues;
	@track
	buisnessTypeValues;
	@track
	regRecord = REG_OBJECT;
    @track
    sectorValues;
    @track
    pdfValue;
    sectorPdfMap = new Map();
	@track
    isSector = false;
    @track
	state = 'Connecticut'
	@track
	aptNumber;
	@track
	isReview = false;
	@track
	isRegister = true;
    connectedCallback() {
        this.regRecord = {};
        this.isSector = false;
		this.isReview = false;
		this.isRegister = true;
        this.buisnessTypeValues =[];
        this.stateValues=[];
        this.countryValues =[];
		this.sectorValues =[];
		this.aptNumber ='';
    }
    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    @wire(getSector) getSector({error,data}){
        if(data){
            var sectorOptions =[];
            for(let key in data){
                console.log('Dev:'+key+data[key]);
                const option = {};
                option.label = key;
                option.value = key;
                sectorOptions.push(option);
                this.sectorPdfMap.set(key,data[key]);
            }
            this.sectorValues= sectorOptions;
        }
    }
    @wire(fatchPickListValue, {objInfo: {'sobjectType' : 'Business_Reopen_Certification__c'},
        picklistFieldApi:['Business_Type__c','Business_Address_County__c','Business_Address_State__c']}) picklistValues({error,data}){
			if(data){
                var buisnessTypeOptions = [];
                var stateOptions = [];
                var countryOptions = [];
                data.forEach (function(item) {
                    if(item.fieldName === 'Business_Type__c'){
                        const option = {};
                        option.label = item.label;
                        option.value = item.value;
                        buisnessTypeOptions.push(option);
                    }
                    else if(item.fieldName === 'Business_Address_County__c'){
                        const option = {};
                        option.label = item.label;
                        option.value = item.value;
                        countryOptions.push(option);
                    }
                    else if(item.fieldName === 'Business_Address_State__c'){
                        const option = {};
                        option.label = item.label;
                        option.value = item.value;
                        stateOptions.push(option);
                    }
                })
                this.buisnessTypeValues = buisnessTypeOptions;
                this.stateValues = stateOptions;
                this.countryValues = countryOptions;
			}
		}
    handleChange(event) {
		if(this.regRecord.Business_Address_State__c === undefined){
			this.regRecord.Business_Address_State__c = this.state;
		}
		if(event.target.name === 'businessType'){
			this.regRecord.Business_Type__c = event.target.value;
		}
		else if(event.target.name === 'businessName'){
			this.regRecord.Business_Name__c = event.target.value;
		}
		else if(event.target.name === 'businessAddress'){
			this.regRecord.Business_Address_Street__c = event.target.value;
		}
		else if(event.target.name === 'emailAddress'){
			this.regRecord.Email_Address__c = event.target.value;
		}
		else if(event.target.name === 'phone1'){
			this.regRecord.Contact_Phone_Number_1__c = event.target.value;
		}
		else if(event.target.name === 'firstName'){
			this.regRecord.Representative_First_Name__c = event.target.value;
		}
		else if(event.target.name === 'lastName'){
			this.regRecord.Representative_last_Name__c = event.target.value;
		}
		else if(event.target.name === 'acknowledgement'){
            this.regRecord.Attestation_Acknowledgement__c = event.target.checked;
		}
		else if(event.target.name === 'country'){
			this.regRecord.Business_Address_County__c = event.target.value;
		}
		else if(event.target.name === 'state'){
			this.regRecord.Business_Address_State__c = event.target.value;
		}
		else if(event.target.name === 'city'){
			this.regRecord.Business_Address_City__c = event.target.value;
		}
		else if(event.target.name === 'zipCode'){
			this.regRecord.Business_Address_Zip_Code__c = event.target.value;
		}
		else if(event.target.name === 'womenBusiness'){
			this.regRecord.WBE_Women_Owned_Business__c = event.target.value;
		}
		else if(event.target.name === 'minorityBusiness'){
			this.regRecord.MBE_Minority_Business_Enterprise__c = event.target.value;
		}
		else if(event.target.name === 'veteranBusiness'){
			this.regRecord.Veteran_Owned_Business__c = event.target.value;
		}
		else if(event.target.name === 'sector'){
            this.pdfValue = this.sectorPdfMap.get(event.target.value);
			this.regRecord.Sector__c = event.target.value;
            this.isSector = true;
		}
		else if(event.target.name === 'date'){
			this.regRecord.Date__c = event.target.value;
		}
		else if(event.target.name === 'aptNumber'){
            this.aptNumber = event.target.value;
		}
        console.log('Dev:'+event.target.value + event.target.name);
    }
	validate(event){
		const inputTextValidation=[...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
		const inputComboValidation=[...this.template.querySelectorAll('lightning-combobox')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
		if (inputTextValidation && inputComboValidation) {
            this.isReview = true;
        }
		else{
            // Show success messsage
            this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: 'Please Enter all the required field value',
            variant: 'error'
            }));
			
		}
        document.documentElement.scrollTop = 0;
	}
	register(){
		if(this.aptNumber != undefined){
            this.regRecord.Business_Address_Street__c = this.regRecord.Business_Address_Street__c+','+this.aptNumber;
        }
        createBusinessReopenCertificationRecord({
            businessReOpenString: JSON.stringify(this.regRecord)
        })
        .then(result => {
            if(result.success){
				this.isSector = false;
                this.isReview = false;
				this.isRegister = false;
		        //this.regRecord = {};
                this.aptNumber ='';
            }
            else{
                // Show success messsage
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Error while Registration, please contact Admin',
                    variant: 'error'
                }));
            }
        })
        .catch(error => {
            // Show success messsage
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                message: error.message,
                variant: 'error'
            }));
        });

	}
	submit(event){
		const inputTextValidation=[...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
		const inputComboValidation=[...this.template.querySelectorAll('lightning-combobox')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
		if (inputTextValidation && inputComboValidation) {
            this.register();
            document.documentElement.scrollTop = 0;
        }
		else{
            // Show success messsage
            this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: 'Please Enter all the required field value',
            variant: 'error'
            }));
			
		}
	}
}
import { LightningElement,track,wire,api} from 'lwc';
import fatchPickListValue from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.fatchPickListValue';
import createFeedbackRecord from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.createFeedbackRecord';
//import updateBusinessReopenCertificationRecord from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.updateBusinessReopenCertificationRecord';
import getSector from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.getSector';
import REG_OBJECT from '@salesforce/schema/Business_Reopen_Certification__c';
import FEED_OBJECT from '@salesforce/schema/Feedback__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HOME_PAGE from '@salesforce/label/c.COVID19_navigateURLFeedback';
export default class BosAccCOVIDGuidelineLWC extends LightningElement {
   
    @track
    isFeedback = true;
    @track
    isRegister = true;
	@track
	buisnessTypeValues;
    @track
    regRecord = REG_OBJECT;
    @track
    feedRecord = REG_OBJECT;
    @track
    sectorValues;
    @track
    pdfValue;
    sectorPdfMap = new Map();
	@track
    isSector = false;
    @track value=[]; 
 
    //new changes
    @track
    feedRecord = FEED_OBJECT;    
    
    checkBoxValues;
    radiovalue='';
    checkbox1value=[];
    checkbox2value=[];

    get radioOptions(){
        return [
            { label: 'Yes', value: 'yes' },
            { label: 'No', value: 'no' },
        ];
    }

    get Checkbox1options(){
        return [
            { label: 'Impacts my ability to operate at full pre-COVID capacity', value: 'Impacts my ability to operate at full pre-COVID capacity' },
            { label: 'Impacts my ability to operate at full pre-COVID workforce', value: 'Impacts my ability to operate with full pre-COVID workforce' },
            { label: 'Impacts my ability to be financially viable', value: 'Impacts my ability to be financially viable' },
        ];
    }
    get Checkbox2options(){
        return [
            { label: 'Reopening Process', value: 'Reopening Process' },
            { label: 'Physical Space set up', value: 'Physical Space set up' },
            { label: 'Personal Protection', value: 'Personal Protection' },
            { label: 'Cleaning and Disinfecting', value: 'Cleaning and Disinfecting' },
            { label: 'Health Guidance for employees', value: 'Health Guidance for employees' },
            { label: 'Other', value: 'Other' },
        ];
    }
    connectedCallback() {
        this.feedRecord = {};
        this.isRegister = true;
        this.isFeedback = true;
        this.isSector = false;
        //this.buisnessTypeValues =[];
        //this.sectorValues =[];
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
    @wire(fatchPickListValue, {objInfo: {'sobjectType' : 'Feedback__c'},
        picklistFieldApi:['Your_business_sector__c','Your_business_industry__c',]}) picklistValues({error,data}){
			if(data){
                var buisnessTypeOptions = [];
                var stateOptions = [];
                var countryOptions = [];
                data.forEach (function(item) {
                    console.log('item:'+item);
                    if(item.fieldName === 'Your_business_industry__c'){
                        const option = {};
                        option.label = item.label;
                        option.value = item.value;
                        buisnessTypeOptions.push(option);
                    }
                })
                console.log('Here!!');
                this.buisnessTypeValues = buisnessTypeOptions;
                //this.stateValues = stateOptions;
                //this.countryValues = countryOptions;
			}
		}
    handleChange(event) {
		if(event.target.name === 'businessType'){
			this.feedRecord.Your_business_industry__c = event.target.value;
        }
        else if(event.target.name === 'sector'){
            this.feedRecord.Your_business_sector__c = event.target.value;
        }
        else if(event.target.name === 'radioGroup'){
            this.feedRecord.safety_guidelines_complete__c = event.target.value;
        }
        else if(event.target.name === 'checkboxOne'){
            console.log('chk1'+e.detail.value);
            this.feedRecord.Business_impact__c= e.detail.value;
            console.log('chk-1'+this.feedRecord.Business_impact__c);
        }
		else if(event.target.name === 'checkboxTwo'){
			this.feedRecord.Feedback_Topics__c= e.detail.value;
		}
		else if(event.target.name === 'feedback'){
			this.feedRecord.Feedback__c = event.target.value;
		}
		else if(event.target.name === 'businessName'){
			this.feedRecord.Business_Name__c = event.target.value;
		}
		else if(event.target.name === 'emailAddress'){
			this.feedRecord.Business_Email_Address__c = event.target.value;
		}
		else if(event.target.name === 'repName'){
			this.feedRecord.Business_Representative_Name__c = event.target.value;
		}
		else if(event.target.name === 'phone1'){
            this.feedRecord.Business_Phone_Number__c = event.target.checked;
        }
        // else if(event.target.name === 'Reopening Process'){
        //     this.feedRecord.Reopening_process__c = event.target.checked;
        // }
        // else if(event.target.name === 'Physical Space set up'){
        //     this.feedRecord.Physical_space_set_up__c = event.target.checked;
        // }
        // else if(event.target.name === 'Personal Protection'){
        //     this.feedRecord.Personal_Protection__c = event.target.checked;
        // }
        // else if(event.target.name === 'Cleaning and Disinfecting'){
        //     this.feedRecord.Cleaning_and_Disinfecting__c = event.target.checked;
        // }
        // else if(event.target.name === 'Health Guidance for employees'){
        //     this.feedRecord.Health_Guidance_for_employees__c = event.target.checked;
        // }
        // else if(event.target.name === 'Other'){
        //     this.feedRecord.Other__c = event.target.checked;
		// }
        console.log('Dev:'+event.target.value + event.target.name);
    }

    handleCheckboxChange(event) {
        console.log('**event.target.value***',event.target.value);
        //var q= JSON.parse(JSON.stringify(event.target.value));
        
        var scheckboxOptions =event.target.value;
        try{
        var schanged = scheckboxOptions.toString().split(',').join(';');
        this.feedRecord.Business_impact__c=schanged;
        console.log('****'+schanged);
        }
        catch(e){
            
            
            console.log('in exception::',e);
        }
        console.log('****'+schanged);

    }
    handleCheckboxTwoChange(event){
        this.value = event.detail.value;
        
        // var scheckboxOptions =event.target.value;
        // var schanged = scheckboxOptions.toString().split(',').join(';');
        // this.feedRecord.Feedback_Topics__c=schanged;
        // console.log('****'+schanged);
    }
   
    get selectedValues() {
    return this.value.join(',');        
    }
    
    validate(event){
        for(let i=0;i<this.value.length;i++){
            if(this.value[i] === 'Reopening Process'){
                this.feedRecord.Reopening_process__c = true;
            }
            else if(this.value[i] === 'Physical Space set up'){
                this.feedRecord.Physical_space_set_up__c = true;
            }
            else if(this.value[i] === 'Personal Protection'){
                this.feedRecord.Personal_Protection__c = true;
            }
            else if(this.value[i] === 'Cleaning and Disinfecting'){
                this.feedRecord.Cleaning_and_Disinfecting__c = true;
            }
            else if(this.value[i] === 'Health Guidance for employees'){
                this.feedRecord.Health_Guidance_for_employees__c = true;
            }
            else if(this.value[i] === 'Other'){
                this.feedRecord.Other__c = true;
            }
        }

		const inputTextValidation=[...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        // const inputCheckboxGrpValidation=[...this.template.querySelectorAll('lightning-checkbox-group')]
        // .reduce((validSoFar, inputCmp) => {
        //             inputCmp.reportValidity();
        //             return validSoFar && inputCmp.checkValidity();
        // }, true);
        
		const inputComboValidation=[...this.template.querySelectorAll('lightning-combobox')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);

        const inputTextAreaValidation=[...this.template.querySelectorAll('lightning-textarea')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);

		if (inputTextValidation && inputComboValidation && inputTextAreaValidation) {            
            this.register();
        }      
	}
	register(){
        createFeedbackRecord({
            feedbackString: JSON.stringify(this.feedRecord)
        })
        .then(result => {
            if(result.success){
                // Show success messsage
                this.dispatchEvent(new ShowToastEvent({
                    //title: 'Success!!',
                    message: 'Thank you for your Feedback',
                    variant: 'success'
                }));
				this.certificationId = result.certificationId;
				this.isSector = false;
                this.feedRecord = {};
                this.checkbox1value=[];
                this.checkbox2value=[];
                this.navigate();
            }
            else{
                // Show success messsage
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: result.message,
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
    navigate(){
        location.href = HOME_PAGE;
    }
}
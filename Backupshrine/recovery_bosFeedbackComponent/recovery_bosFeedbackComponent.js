import { LightningElement,track,wire,api} from 'lwc';
import fatchPickListValue from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.fatchPickListValue';
import createFeedbackRecord from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.createFeedbackRecord';
import getSector from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.getSector';
import REG_OBJECT from '@salesforce/schema/Business_Reopen_Certification__c';
import FEED_OBJECT from '@salesforce/schema/Feedback__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HOME_PAGE from '@salesforce/label/c.COVID19_navigateURLFeedback';
//importing lqbels for spanish language
import label_feedback_Title from '@salesforce/label/c.Recovery_Feedback_Title';
import label_feedback_Intro from '@salesforce/label/c.Recovery_Feedback_Intro';
import label_feedback_guidelines from '@salesforce/label/c.Recovery_Feedback_Guidelines';
import label_feedback_topicsPart1 from '@salesforce/label/c.Recovery_Feedback_TopicsPart1';
import label_feedback_submitbutton from '@salesforce/label/c.Recovery_Feedback_SubmitButton';
import label_feedback_businessSectorLabel from '@salesforce/label/c.Recovery_SelfCertify_BusinessSectorLabel';
import label_feedback_businessSector from '@salesforce/label/c.Recovery_SelfCertify_BusinessSector';
import label_feedback_businessIndustryLabel from '@salesforce/label/c.Recovery_SelfCertify_BusinessIndustryLabel';
import label_feedback_businessIndustry from '@salesforce/label/c.Recovery_SelfCertify_BusinessIndustry';
import label_feedback_safetyGuidelines from '@salesforce/label/c.Recovery_Feedback_SafetyGuidelines';
import label_feedback_topics from '@salesforce/label/c.Recovery_Feedback_Topics';
import label_feedback_businessNameLabel from '@salesforce/label/c.Recovery_SelfCertify_BusinessNameLabel';
import label_feedback_businessPhoneNmbrLabel from '@salesforce/label/c.Recovery_SelfCertify_BusinessPhoneNmbrLabel';
import label_feedback_businessPhoneNmbr from '@salesforce/label/c.Recovery_SelfCertify_BusinessPhoneNmbr';
import label_feedback_businessEmailAddressLabel from '@salesforce/label/c.Recovery_SelfCertify_BusinessEmailAddressLabel';
import label_feedback_businessRepFName from '@salesforce/label/c.Recovery_SelfCertify_BusinessRepFName';
import label_feedback_businessRepLName from '@salesforce/label/c.Recovery_SelfCertify_BusinessRepLName';
import label_feedback_businessRepPart1 from '@salesforce/label/c.Recovery_SelfCertify_BusinessRepPart1';
import label_feedback_topicsPart2 from '@salesforce/label/c.Recovery_Feedback_TopicsPart2';
import label_feedback_businessName from '@salesforce/label/c.Recovery_SelfCertify_BusinessName';
import label_feedback_submitbutoon_c from '@salesforce/label/c.Recovery_Feedback_SubmitButton';
import label_feedback_businessRepPart2 from '@salesforce/label/c.Recovery_SelfCertify_BusinessRepPart2';
import label_feedback_businessEmailAddress from '@salesforce/label/c.Recovery_SelfCertify_BusinessEmailAddress';
import label_optional from '@salesforce/label/c.Recovery_Feedback_Optional';
import label_feedback_PlaceholderBusinessSector from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderBusinessSector';
import label_feedback_PlaceholderBusinessselect from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderBusinessselect';
import label_RProcess from '@salesforce/label/c.Recovery_Feedback_Reopening_process';
import label_Other from '@salesforce/label/c.Recovery_Feedback_Other';
import label_PProtection from '@salesforce/label/c.Recovery_Feedback_Personal_Protection';
import label_PSpace from '@salesforce/label/c.Recovery_Feedback_Physical_space';
import label_Cleaning from '@salesforce/label/c.Recovery_Feedback_Cleaning';
import label_HGuide from '@salesforce/label/c.Recovery_Feedback_Health_guide';
import label_PlaceholderSelectOption from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderSelectOption';
import label_Captcha from '@salesforce/label/c.Recovery_ReCaptcha_Error'
import label_ToastError from '@salesforce/label/c.Recovery_Toast_Error';
import label_ToastSuccessMssg from '@salesforce/label/c.Recovery_Toast_SuccessMssg';
import label_ToastErrorMssg from '@salesforce/label/c.Recovery_Toast_ErrorMssg';
import label_Recovery_CaptchaExpired from '@salesforce/label/c.Recovery_CaptchaExpired';
import { CurrentPageReference } from 'lightning/navigation';
import verified from '@salesforce/apex/RecaptchaServerVerification.verified';

export default class Recovery_bosFeedbackComponent extends LightningElement {
    @track
    isFeedback = true;
    @track
    isRegister = true;
	@track
    buisnessTypeValues;
    @track
    safetyGuidelinesValues;
    @track
    regRecord = REG_OBJECT;
    @track
    feedRecord = REG_OBJECT;
    @track
    sectorValues;
	@track
    isSector = false;
    @track value=[]; 
 
    //new changes
    @track
    feedRecord = FEED_OBJECT;  
    @track
    languageValue='en_US';
    
    toastError = label_ToastError;
    toastSuccessMssg = label_ToastSuccessMssg;
    toastErrorMssg = label_ToastErrorMssg;

    checkBoxValues;
    radiovalue='';
    checkbox1value=[];
    checkbox2value=[];

    label={
        label_feedback_Title,
        label_feedback_Intro,
        label_feedback_submitbutton,
        label_feedback_topicsPart1,
        label_feedback_guidelines,
        label_feedback_businessSectorLabel,
        label_feedback_businessSector,
        label_feedback_businessIndustryLabel,
        label_feedback_businessIndustry,
        label_feedback_safetyGuidelines,
        label_feedback_topics,
        label_feedback_businessNameLabel,
        label_feedback_businessPhoneNmbrLabel,
        label_feedback_businessPhoneNmbr,
        label_feedback_businessEmailAddressLabel,
        label_feedback_businessRepFName,
        label_feedback_businessRepLName,
        label_feedback_businessRepPart1,
        label_feedback_topicsPart2,
        label_feedback_businessName,
        label_feedback_submitbutoon_c,
        label_feedback_businessEmailAddress,
        label_feedback_businessRepPart2,
        label_optional,
        label_feedback_PlaceholderBusinessSector,
        label_feedback_PlaceholderBusinessselect,
        label_PlaceholderSelectOption
    };

    get Checkbox1options(){
        return [
            { label: 'Impacts my ability to operate at full pre-COVID capacity', value: 'Impacts my ability to operate at full pre-COVID capacity' },
            { label: 'Impacts my ability to operate at full pre-COVID workforce', value: 'Impacts my ability to operate with full pre-COVID workforce' },
            { label: 'Impacts my ability to be financially viable', value: 'Impacts my ability to be financially viable' },
        ];
    }
    get Checkbox2options(){
        return [
            { label: label_RProcess, value: 'Reopening Process' },
            { label: label_PSpace, value: 'Physical Space set up' },
            { label: label_PProtection, value: 'Personal Protection' },
            { label: label_Cleaning, value: 'Cleaning and Disinfecting' },
            { label: label_HGuide, value: 'Health Guidance for employees' },
            { label: label_Other, value: 'Other' },
        ];
    }
    connectedCallback() {
        this.feedRecord = {};
        this.isRegister = true;
        this.isFeedback = true;
        this.isSector = false;
        const param='language';
        const paramValue = this.getUrlParamValue(window.location.href, param);
        this.languageValue = paramValue;
        //this.buisnessTypeValues =[];
        //this.sectorValues =[];
    }    
    
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    @wire(CurrentPageReference)
        setCurrentPageReference(currentPageReference) {
        if(currentPageReference){
        }
    }

    @wire(fatchPickListValue, {objInfo: {'sobjectType' : 'Feedback__c'},
        picklistFieldApi:['Your_business_sector__c','Your_business_industry__c','safety_guidelines_complete__c']}) picklistValues({error,data}){
			if(data){
                var buisnessTypeOptions = [];
                var businessSectorPicklistValues = [];
                var guidelinesValue = [];

                data.forEach (function(item) {
                    if(item.fieldName === 'Your_business_industry__c'){
                        const option = {};
                        option.label = item.label;
                        option.value = item.value;
                        buisnessTypeOptions.push(option);
                    }
                    else if(item.fieldName === 'Your_business_sector__c'){
                        const option = {};
                        option.label = item.label;
                        option.value = item.value;
                        businessSectorPicklistValues.push(option);
                    }
                    else if(item.fieldName === 'safety_guidelines_complete__c'){
                        const option = {};
                        option.label = item.label;
                        option.value = item.value;
                        guidelinesValue.push(option);
                    }
                })
                this.buisnessTypeValues = buisnessTypeOptions;
                this.sectorValues = businessSectorPicklistValues;
                this.safetyGuidelinesValues = guidelinesValue;
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
            this.feedRecord.Business_impact__c= e.detail.value;
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
            this.feedRecord.Business_Phone_Number__c = event.target.value;
        }
    }

    handleCheckboxChange(event) {
        var scheckboxOptions =event.target.value;
        try{
        var schanged = scheckboxOptions.toString().split(',').join(';');
        this.feedRecord.Business_impact__c=schanged;
        }
        catch(e){           
        }
    }

    handleCheckboxTwoChange(event){
        this.value = event.detail.value;
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

        if(this.languageValue !== undefined){
            this.feedRecord.Language__c = this.languageValue;
        }

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

        const inputTextAreaValidation=[...this.template.querySelectorAll('lightning-textarea')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);

		if (inputTextValidation && inputComboValidation && inputTextAreaValidation) {        
            this.captcha();
        }
        else{
            // Show error messsage
            this.dispatchEvent(new ShowToastEvent({
            title: this.toastError,
            message: this.toastErrorMssg,
            variant: 'error'
            }));
			
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
                    message: this.toastSuccessMssg,
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
                    title: this.toastError,
                    message: result.message,
                    variant: 'error'
                }));
            }
        })
        .catch(error => {
            // Show error messsage
            this.dispatchEvent(new ShowToastEvent({
                title: this.toastError,
                message: error.message,
                variant: 'error'
            }));
        });

    }
    navigate(){
        location.href = HOME_PAGE;
    }

    captcha(event){
        const res = this.template.querySelector("c-re-Captcha-Certification").getValue();
		if(res.length>0){
			if(res === 'captcha expired'){
                this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: label_Recovery_CaptchaExpired,
                variant: 'error'
                }));
			}
			else{
				verified({recaptchaResponse : res})
				.then(result => {
					if(result === 'Valid Verification'){
						this.register();
					}
					else{
						this.dispatchEvent(new ShowToastEvent({
						title: 'Error',
						message: result,
						variant: 'error'
						}));
					}
				})			
			}
		}
		else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: label_Captcha,
                variant: 'error'
                }));
		}
    }
}
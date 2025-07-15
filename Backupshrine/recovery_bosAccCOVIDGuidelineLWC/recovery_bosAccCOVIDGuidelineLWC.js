/**********************************************************************************************
 * NAME:  recovery_bosAccCOVIDGuidelineLWC.js
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
import getSector from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.getSector';

import REG_OBJECT from '@salesforce/schema/Business_Reopen_Certification__c';
import SUBSCRIPTION_OBJECT from '@salesforce/schema/Subscription__c';
//Retreiving Custom labels
import SRULESLINK from '@salesforce/label/c.BosAcc_SectorRules';
import label_Title from '@salesforce/label/c.Recovery_SelfCertify_Title';
import label_IntroPart1 from '@salesforce/label/c.Recovery_SelfCertify_IntroPart1';
import label_IntroPart2 from '@salesforce/label/c.Recovery_SelfCertify_IntroPart2';
import label_IntroPart3 from '@salesforce/label/c.Recovery_SelfCertify_IntroPart3';
import label_IntroPart4 from '@salesforce/label/c.Recovery_SelfCertify_IntroPart4';
import label_IntroPart5 from '@salesforce/label/c.Recovery_SelfCertify_IntroPart5';
import label_BusinessSector from '@salesforce/label/c.Recovery_SelfCertify_BusinessSector';
import label_BusinessSectorHeader from '@salesforce/label/c.Recovery_SelfCertify_BusinessSectorLabel';
import label_BusinessIndustry from '@salesforce/label/c.Recovery_SelfCertify_BusinessIndustry';
import label_BusinessIndustryHeader from '@salesforce/label/c.Recovery_SelfCertify_BusinessIndustryLabel';
import label_BusinessName from '@salesforce/label/c.Recovery_SelfCertify_BusinessName';
import label_BusinessNameHeader from '@salesforce/label/c.Recovery_SelfCertify_BusinessNameLabel';
import label_BusinessAddress from '@salesforce/label/c.Recovery_SelfCertify_BusinessAddress';
import label_BusinessAddressHeader from '@salesforce/label/c.Recovery_SelfCertify_BusinessAddressLabel';
import label_WomenOwnedBusiness from '@salesforce/label/c.Recovery_SelfCertify_BusinessWomenOwned';
import label_WomenOwnedBusinessHeader from '@salesforce/label/c.Recovery_SelfCertify_BusinessWomenOwnedLabel';
import label_MinorityOwnedBusiness from '@salesforce/label/c.Recovery_SelfCertify_BusinessMinorityOwned';
import label_MinorityOwnedBusinessHeader from '@salesforce/label/c.Recovery_SelfCertify_BusinessMinorityOwnedLabel';
import label_VeteranOwnedBusiness from '@salesforce/label/c.Recovery_SelfCertify_BusinessVeteranOwned';
import label_VeteranOwnedBusinessHeader from '@salesforce/label/c.Recovery_SelfCertify_BusinessVeteranOwnedLabel';
import label_BusinessEmail from '@salesforce/label/c.Recovery_SelfCertify_BusinessEmailAddress';
import label_BusinessEmailHeader from '@salesforce/label/c.Recovery_SelfCertify_BusinessEmailAddressLabel';
import label_BusinessPhone from '@salesforce/label/c.Recovery_SelfCertify_BusinessPhoneNmbr';
import label_BusinessPhoneHeader from '@salesforce/label/c.Recovery_SelfCertify_BusinessPhoneNmbrLabel';
import label_RulesPart1 from '@salesforce/label/c.Recovery_SelfCertify_RulesPart1';
import label_RulesPart2 from '@salesforce/label/c.Recovery_SelfCertify_RulesPart2';
import label_RulesPart3 from '@salesforce/label/c.Recovery_SelfCertify_RulesPart3';
import label_SelfCertPart1 from '@salesforce/label/c.Recovery_SelfCertify_SelfCertPart1';
import label_SelfCertPart2 from '@salesforce/label/c.Recovery_SelfCertify_SelfCertPart2';
import label_CheckboxLabel from '@salesforce/label/c.Recovery_SelfCertify_Checkbox';
import label_BusinessRepPart1 from '@salesforce/label/c.Recovery_SelfCertify_BusinessRepPart1';
import label_BusinessRepPart2 from '@salesforce/label/c.Recovery_SelfCertify_BusinessRepPart2';
import label_BusinessRepFName from '@salesforce/label/c.Recovery_SelfCertify_BusinessRepFName';
import label_BusinessRepLName from '@salesforce/label/c.Recovery_SelfCertify_BusinessRepLName';
import label_DateHeader from '@salesforce/label/c.Recovery_SelfCertify_DateLabel';
import label_ReviewBttn from '@salesforce/label/c.Recovery_SelfCertify_Button1';
import label_CertifyBttn from '@salesforce/label/c.Recovery_SelfCertify_Button2';
import label_Placeholderapartment from '@salesforce/label/c.Recovery_SelfCertify_Placeholderapartment';
import label_PlaceholderBusinessCountry from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderBusinessCountry';
import label_PlaceholderBusinessSector from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderBusinessSector';
import label_PlaceholderBusinessselect from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderBusinessselect';
import label_PlaceholderBusinessZipCode from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderBusinessZipCode';
import label_PlaceholderCity from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderCity';
import label_PlaceholderStreetAddress from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderStreetAddress';
import label_PlaceholderSelectOption from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderSelectOption';
import label_ToastError from '@salesforce/label/c.Recovery_Toast_Error';
import label_ToastErrorMssg from '@salesforce/label/c.Recovery_Toast_ErrorMssg';
import label_ToastRegisterErrorMssg from '@salesforce/label/c.Recovery_Toast_RegisterErrorMssg';
import label_Captcha from '@salesforce/label/c.Recovery_ReCaptcha_Error'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import label_here from '@salesforce/label/c.Recovery_Confirmation_Here';
import label_Recovery_CaptchaExpired from '@salesforce/label/c.Recovery_CaptchaExpired';
import label_Recovery_SubscriptionOptIn from '@salesforce/label/c.Recovery_SubscriptionOptIn';
import verified from '@salesforce/apex/RecaptchaServerVerification.verified';
export default class Recovery_bosAccCOVIDGuidelineLWC extends LightningElement {    
    @track
    countryValues;
    @track
    stateValues;
	@track
    buisnessTypeValues;
    @track
    mbeOwnedValues;
    @track
    veteranOwnedBusiness;
    @track
    womanOwnedBusiness;
	@track
	regRecord = REG_OBJECT;
	@track
	subscriptionRecord = SUBSCRIPTION_OBJECT;
    @track
    sectorValues;
    @track
    sectorValuesPDF;
    @track
    pdfValueLabel;
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
    @track
    languageValue='en_US';
    @track
    sectorrules = SRULESLINK;
    @track
    subscription = false;
    @track verificationMessage='';

    toastError = label_ToastError;
    toastErrorMssg = label_ToastErrorMssg;
    toastRegisterErrMssg = label_ToastRegisterErrorMssg;
    
    //setting labels to be used in HTML
    label = {
        label_Title,
        label_IntroPart1,
        label_IntroPart2,
        label_IntroPart3,
        label_IntroPart4,
        label_IntroPart5,
        label_BusinessSector,
        label_BusinessSectorHeader,
        label_BusinessIndustry,
        label_BusinessIndustryHeader,
        label_BusinessName,
        label_BusinessNameHeader,
        label_BusinessAddress,
        label_BusinessAddressHeader,
        label_WomenOwnedBusiness,
        label_WomenOwnedBusinessHeader,
        label_MinorityOwnedBusiness,
        label_MinorityOwnedBusinessHeader,
        label_VeteranOwnedBusiness,
        label_VeteranOwnedBusinessHeader,
        label_BusinessEmail,
        label_BusinessEmailHeader,
        label_BusinessPhone,
        label_BusinessPhoneHeader,
        label_RulesPart1,
        label_RulesPart2,
        label_RulesPart3,
        label_SelfCertPart1,
        label_SelfCertPart2,
        label_CheckboxLabel,
        label_BusinessRepPart1,
        label_BusinessRepPart2,
        label_BusinessRepFName,
        label_BusinessRepLName,
        label_DateHeader,
        label_ReviewBttn,
        label_CertifyBttn,
        label_Placeholderapartment,
        label_PlaceholderBusinessCountry,
        label_PlaceholderBusinessSector,
        label_PlaceholderBusinessselect,
        label_PlaceholderBusinessZipCode,
        label_PlaceholderCity,
        label_PlaceholderStreetAddress,
        label_PlaceholderSelectOption,
        label_here,
        label_Recovery_SubscriptionOptIn
    };

    connectedCallback() {
        this.regRecord = {};
        this.isSector = false;
		this.isReview = false;
		this.isRegister = true;
        this.buisnessTypeValues =[];
        this.stateValues=[];
        this.countryValues =[];
        this.sectorValues =[];
        this.mbeOwnedValues = [];
        this.womanOwnedBusiness = [];
        this.veteranOwnedBusiness = [];
        this.aptNumber ='';
        this.verificationMessage = '';
        this.regRecord.WBE_Women_Owned_Business__c = 'Choose not to answer';
        this.regRecord.MBE_Minority_Business_Enterprise__c = 'Choose not to answer';
        this.regRecord.Veteran_Owned_Business__c = 'Choose not to answer'; 
        const param='language';
        const paramValue = this.getUrlParamValue(window.location.href, param);
        this.languageValue = paramValue;
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    @wire(getSector,{code: '$languageValue'}) getSector({error,data}){
        if(data){
            var sectorOptions =[];
            for(let key in data){
                const option = {};
                option.label = key;
                option.value = key;
                sectorOptions.push(option);
                this.sectorPdfMap.set(key,data[key]);
            }
            this.sectorValuesPDF= sectorOptions;
        }
    }

    @wire(fatchPickListValue, {objInfo: {'sobjectType' : 'Business_Reopen_Certification__c'},
        picklistFieldApi:['Business_Type__c','Business_Address_County__c','Business_Address_State__c','Sector__c','MBE_Minority_Business_Enterprise__c','Veteran_Owned_Business__c','WBE_Women_Owned_Business__c']}) picklistValues({error,data}){
			if(data){
                var buisnessTypeOptions = [];
                var stateOptions = [];
                var countryOptions = [];
                var businessSectorPicklistValues = [];
                var mbeValues = [];
                var woValues = [];
                var voValues = [];

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
                    else if(item.fieldName === 'Sector__c'){
                        const option = {};
                        option.label = item.label;
                        option.value = item.value;
                        businessSectorPicklistValues.push(option);
                    }
                    else if(item.fieldName === 'MBE_Minority_Business_Enterprise__c'){
                        const option = {};
                        option.label = item.label;
                        option.value = item.value;
                        mbeValues.push(option);
                    }
                    else if(item.fieldName === 'Veteran_Owned_Business__c'){
                        const option = {};
                        option.label = item.label;
                        option.value = item.value;
                        woValues.push(option);
                    }
                    else if(item.fieldName === 'WBE_Women_Owned_Business__c'){
                        const option = {};
                        option.label = item.label;
                        option.value = item.value;
                        voValues.push(option);
                    }
                })
                this.buisnessTypeValues = buisnessTypeOptions;  
                this.stateValues = stateOptions;
                this.countryValues = countryOptions;
                this.sectorValues = businessSectorPicklistValues;
                this.mbeOwnedValues = mbeValues;
                this.womanOwnedBusiness = woValues;
                this.veteranOwnedBusiness = voValues;
			}
    }
        
    handleChange(event) {
        if(this.languageValue !== undefined){
            this.regRecord.Language__c = this.languageValue;
        }
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
            const findLabel = this.sectorValues.find(element => 
                element.value === event.target.value);
            
            this.pdfValueLabel = findLabel.label
            this.isSector = true;    
		}
		else if(event.target.name === 'date'){
			this.regRecord.Date__c = event.target.value;
		}
		else if(event.target.name === 'aptNumber'){
            this.aptNumber = event.target.value;
		}
		else if(event.target.name === 'subscription'){
            this.subscription = event.target.checked;
            this.regRecord.Notification_Subscribed__c = event.target.checked;   
		}
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
            title: this.toastError,
            message: this.toastErrorMssg,
            variant: 'error'
            }));
			
		}
        document.documentElement.scrollTop = 0;
    }
    
	register(){
        const bolSubscribe = this.subscription;
		if(this.aptNumber != undefined){
            this.regRecord.Business_Address_Street__c = this.regRecord.Business_Address_Street__c+','+this.aptNumber;
        }
        createBusinessReopenCertificationRecord({
            businessReOpenString: JSON.stringify(this.regRecord),
            isSubscribed: bolSubscribe
        })
        .then(result => {
            if(result.success){
				this.isSector = false;
                this.isReview = false;
				this.isRegister = false;
                this.aptNumber ='';
                this.verificationMessage = result.message;
            }
            else{
                // Show error messsage
                this.dispatchEvent(new ShowToastEvent({
                    title: this.toastError,
                    message: this.toastRegisterErrMssg,
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
			this.captcha();
            document.documentElement.scrollTop = 0;
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
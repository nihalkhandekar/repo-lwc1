import { LightningElement,api,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import label_badgemssgPart1 from '@salesforce/label/c.Recovery_findbadge_Part1'
import label_badgemssgPart2 from '@salesforce/label/c.Recovery_findbadge_Part2'
import label_backBttn from '@salesforce/label/c.Recovery_backbutton';
import LINK from '@salesforce/label/c.BosAcc_RedirectionLink';
import HOME_PAGE from '@salesforce/label/c.COVID19_navigateURLFeedback';
import label_ToastErrorMssg from '@salesforce/label/c.Recovery_Toast_ErrorMssg1';
import label_ToastError from '@salesforce/label/c.Recovery_Toast_Error';
import label_Captcha from '@salesforce/label/c.Recovery_ReCaptcha_Error';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import emailIdExists from '@salesforce/apex/SelfCeriftyBadgeLWCController.emailIdExists';
import label_email from '@salesforce/label/c.Recovery_Email';
import label_subBttn from '@salesforce/label/c.Recovery_Feedback_SubmitButton';
import label_Recovery_CaptchaExpired from '@salesforce/label/c.Recovery_CaptchaExpired';
import verified from '@salesforce/apex/RecaptchaServerVerification.verified';
export default class Navtab extends NavigationMixin(LightningElement) {
    @api
    businessowneremail;
    @track
    pdfLink = LINK;
    @track
    feedback;
    @track
    emailId;
    @track
    isSubmit;
    @track
    isEmailfound;
    @track
    isReview;


    toastError = label_ToastError;
    toastErrorMssg = label_ToastErrorMssg;

    label = {
        label_badgemssgPart1,
        label_badgemssgPart2,
        label_backBttn,
        label_email,
        label_subBttn,
       
    };

    connectedCallback(){
        this.isSubmit = false;
        this.isEmailfound = true;
        this.isReview=true;
    }

    handleChange(event) {
        this.emailId = event.target.value;
    }
    
    back(event){
        location.href = HOME_PAGE;
    }
    submit(event){
        if(this.emailId == null || this.emailId == undefined || this.emailId.length == 0){
            this.dispatchEvent(new ShowToastEvent({
            title: this.toastError,
            message: this.toastErrorMssg,
            variant: 'error'
            }));
        }
        else{
        const inputTextValidation=[...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        
        if(inputTextValidation){
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
				const text = this.emailId;
				verified({recaptchaResponse : res})
				.then(result => {
					if(result === 'Valid Verification'){
						emailIdExists({SearchEmail: this.emailId})
						.then(result => {
							if(result.success){
								this.isSubmit=true;
								this.isEmailfound=true;
								
							}
							else{
								this.isSubmit=true;
								this.isEmailfound=false;

							}
						})
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
/**********************************************************************************************
 * NAME:  thankyouLWC.js
 * DESCRIPTION: Covid-19 thankyou page. 
 *
 * @AUTHOR: Mohan Mullapudi
 * @DATE: 12/05/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Mohan Mullapudi               12/05/2020                         Created the first version
 *
*********************************************************************************************/
import { LightningElement,api,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//custom lables import statements
import LINK from '@salesforce/label/c.BosAcc_RedirectionLink';
import feedbackPageName from '@salesforce/label/c.Recovery_FeedbackPageName';
import HOME_PAGE from '@salesforce/label/c.COVID19_navigateURLFeedback';
import label_areSelfCert from '@salesforce/label/c.Recovery_Confirmation_Part1';
import label_thankYou from '@salesforce/label/c.Recovery_Confirmation_Part2';
import label_mssgPart1 from '@salesforce/label/c.Recovery_Confirmation_Part3';
import label_mssgPart2 from '@salesforce/label/c.Recovery_Confirmation_Part4';
import label_mssgPart3 from '@salesforce/label/c.Recovery_Confirmation_Part5';
import label_mssgPart4 from '@salesforce/label/c.Recovery_Confirmation_Part6';
import label_mssgPart5 from '@salesforce/label/c.Recovery_Feedback_Intro';
import label_click from '@salesforce/label/c.Recovery_Confirmation_Click';
import label_here from '@salesforce/label/c.Recovery_Confirmation_Here';
import label_submitBttn from '@salesforce/label/c.Recovery_Confirmation_Button';
import label_Recovery_ThankyouPageVerificationMessage from '@salesforce/label/c.Recovery_ThankyouPageVerificationMessage';

export default class Navtab extends NavigationMixin(LightningElement) {
    @api
    businessowneremail;
    @track
    pdfLink = LINK;
    @track
    feedback;
    @api
    verification;
    @track
    verificationMessageBol = false;

    //setting labels to be used in HTML
    label = {
        label_areSelfCert,
        label_thankYou,
        label_mssgPart1,
        label_mssgPart2,
        label_mssgPart3,
        label_mssgPart4,
        label_mssgPart5,
        label_click,
        label_here,
        label_submitBttn,
        label_Recovery_ThankyouPageVerificationMessage
    };

   connectedCallback(){
       if(this.verification === 'Verification Requested'){
            this.verificationMessageBol = true;
       }
       else{
           this.verificationMessageBol = false;
       }
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                pageName: feedbackPageName
            },
        }).then(url => {
            this.feedback = url;
        });        
    } 

    submit(event){
        location.href = HOME_PAGE;
    }
}
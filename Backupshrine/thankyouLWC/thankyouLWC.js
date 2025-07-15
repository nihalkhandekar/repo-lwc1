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
import { LightningElement,api,track,wire } from 'lwc';
import fatchPickListValue from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.fatchPickListValue';
import createBusinessReopenCertificationRecord from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.createBusinessReopenCertificationRecord';
//import updateBusinessReopenCertificationRecord from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.updateBusinessReopenCertificationRecord';
import getSector from '@salesforce/apex/BosAccCOVIDGuidelineLWCController.getSector';
import { NavigationMixin } from 'lightning/navigation';
import REG_OBJECT from '@salesforce/schema/Business_Reopen_Certification__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LINK from '@salesforce/label/c.BosAcc_RedirectionLink';
import FEEDBACK_PAGE from '@salesforce/label/c.BosAcc_FeedbackPage';
import HOME_PAGE from '@salesforce/label/c.COVID19_navigateURLFeedback';

export default class Navtab extends NavigationMixin(LightningElement) {
    @api
    businessowneremail;
    @track
    pdfLink = LINK+'.pdf';
    @track
    feedback = FEEDBACK_PAGE;
    submit(event){
        location.href = HOME_PAGE;
    }
}
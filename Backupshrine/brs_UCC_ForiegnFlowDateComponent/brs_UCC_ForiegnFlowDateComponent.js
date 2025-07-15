import { LightningElement, track, api } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

//custom labels
import Back from '@salesforce/label/c.Back';
import Next from '@salesforce/label/c.Next';
import Ok_Label from '@salesforce/label/c.Ok_Label';
import confirmLabel from '@salesforce/label/c.Confirm';
import Authorized_Date from "@salesforce/label/c.Authorized_Date";
import brs_CloseBusiness_AuthorizeDateHeader from '@salesforce/label/c.brs_CloseBusiness_AuthorizeDateHeader';
import Withdrawal_Label from "@salesforce/label/c.Withdrawal_Label";
import Dissolution_Label from "@salesforce/label/c.Dissolution_Label";
import Renunciation_Label from "@salesforce/label/c.Renunciation_Label";
import Revocation_Dissolution_Flow from "@salesforce/label/c.Revocation_Dissolution_Flow";
import Please_Note from "@salesforce/label/c.Please_Note";
import Please_Note_Dessolution_Content from "@salesforce/label/c.Please_Note_Dessolution_Content";
import Business_Type_LLC from "@salesforce/label/c.Business_Type_LLC";
import updateBusinessClosingEffectiveDate from '@salesforce/apex/BRS_Utility.updateBusinessClosingEffectiveDate';
import effective_days_llc_error from "@salesforce/label/c.effective_days_llc_error";

import { NavigationMixin } from 'lightning/navigation';
import brs_FIlingLandingPage from "@salesforce/label/c.brs_FIlingLandingPage";
import go_to_summary from '@salesforce/label/c.go_to_summary';
import { getDate } from 'c/appUtility';
import effective_time_past_error from "@salesforce/label/c.effective_time_past_error";
import { ComponentErrorLoging } from "c/formUtility";
import loading_brs from "@salesforce/label/c.loading_brs";
import { fireEvent } from 'c/commonPubSub';
export default class Brs_UCC_ForiegnFlowDateComponent extends NavigationMixin(LightningElement) {
    //Resources
    @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
    // APIs
    @api dateEntered;
    @api minDate;
    @api minDateValidationMessage;
    @api maxDate;
    @api maxDateValidationMessage;
    @api isRequired = false;
    @api isRequiredValidationMessage;
    @api validationErrorBlockTitle = '';
    @api dateLabel = '';
    @api showConfirmationBlock = false;
    @api confirmationBlockTitle = '';
    @api confirmationBlockSubTitle = '';
    @api confirmationBlockMessage = '';
    @api showUserInput = false;
    @api placeholder = '';
    @api badInputMessage='';
    // Below api variables are created for closeBusiness
    @api accountRecord;
    @api maintennaceType;
    @api authorizedDateEntered;
    @api effectiveDateEntered;
    @api effectiveTimeSelected;
    @api withdrawalEffectiveTimeSelected;
    @api businessFiling;
    @api effectiveDate;
    @api effectiveTime;
    @api showTimePicker;
    @api isGotoSummary;
    @api showGotoSummary;
    @api goToDashBoardPage = false;
    @api twentyFourHourTime;
    //Track
    @track showConfirmationBlockFE = false;
    @track showMessageContainer = false;
    @track showErrorBlock = false;
    @track errorMessage = '';

    @track nextLabel = Next;
    @track backLabel = Back;
    @track Ok = Ok_Label;
    @track confirmLabelFE = confirmLabel;
    //Added as part of BRS-2241
    @track isNotValid = true;
    @track isDateChanged=false;
    @track showAuthorizedDate = false;
    @track authorizedDateLabel;
    @track disableEffectiveDateField = false;
    @track isLLC = false;
    @track isCloseBusiness;
    @track topPleaseNoteContent;
    @track showNoteSection = false;
    @track showTimeError= false;
    @track isLoading = false;
    @track isRevocationDissolution = false;
    @track timeNotSelectedError = false;

    label = {
        Withdrawal_Label,
        Dissolution_Label,
        Renunciation_Label,
        Revocation_Dissolution_Flow,
        Authorized_Date,
        brs_CloseBusiness_AuthorizeDateHeader,
        Please_Note,
        Please_Note_Dessolution_Content,
        Business_Type_LLC,
        effective_days_llc_error,
        brs_FIlingLandingPage,
        go_to_summary,
        effective_time_past_error,
        loading_brs
    }

    connectedCallback() {
        this.isGotoSummary = false;
        let accountRecord = Object.assign({}, this.accountRecord);
        this.topPleaseNoteContent = `<p class="small"><b class="dull-orange-text">${this.label.Please_Note}</b></p><p class="small" <b class="karaka-text">${this.label.Please_Note_Dessolution_Content}</p>`;
        this.isCloseBusiness = [this.label.Withdrawal_Label,this.label.Renunciation_Label,this.label.Dissolution_Label,this.label.Revocation_Dissolution_Flow].includes(this.maintennaceType);
        if(this.maintennaceType && this.maintennaceType === this.label.Dissolution_Label){
            if (accountRecord && accountRecord.Business_Type__c && accountRecord.Business_Type__c === this.label.Business_Type_LLC) {
                this.showAuthorizedDate =  false;
                this.isLLC = true;
                this.showNoteSection = true;
            } else {
                this.showAuthorizedDate =  true;
                this.authorizedDateLabel = this.label.brs_CloseBusiness_AuthorizeDateHeader;
            }
        } else if (this.maintennaceType && this.maintennaceType === this.label.Revocation_Dissolution_Flow) {
            this.showAuthorizedDate =  true;
            this.authorizedDateLabel = this.label.Authorized_Date;
            this.disableEffectiveDateField = true;
            this.isRevocationDissolution = true;
        } else if(this.maintennaceType && this.maintennaceType === this.label.Withdrawal_Label){
            if (accountRecord && accountRecord.Business_Type__c && accountRecord.Business_Type__c === this.label.Business_Type_LLC) {
               this.isLLC = true;
            }
       }
    }
    /**
     * Used for setting value from date input field change to dateEntered
     * @param {NA} event 
     */
    handleDate(event) {
        this.dateEntered = event.target.value;
        //Added as part of BRS-2241
        this.checkDateValidity();
        if(!this.isDateChanged){
            this.isDateChanged=true;
        }
    }
    handleEffectiveDate(event) {
        this.effectiveDateEntered = event.target.value;
        this.checkDateValidity();
        this.isDateChanged = true;
        this.checkTimeValidity();

    }
    handleAuthorizedDate(event) {
        this.authorizedDateEntered = event.target.value;
        this.checkDateValidity();
        this.isDateChanged = true;
    }
    handleChangeEffectiveTime(event) {
        this.withdrawalEffectiveTimeSelected = event.detail.selectedTime;
        this.twentyFourHourTime = event.detail.twentyFourHourTime;
        this.timeNotSelectedError = event.detail.showTimeError;
        this.checkTimeValidity();
    }
    //Added as part of BRS-2241
    checkDateValidity() {
        this.errorMessage = '';
        let inputFields = this.template.querySelectorAll('[data-id="inputfields"]');
        if(inputFields){
            inputFields.forEach((element) => {
                const type = element.dataset.type;
                if (element.validity.badInput) {
                    this.errorMessage = this.badInputMessage;
                    element.setCustomValidity(this.badInputMessage);
                    element.value='';
                } else if ((this.maxDate || this.minDate) && element.value) {
                    if(!this.isCloseBusiness || this.isRevocationDissolution){
                        if (this.maxDate && (element.value > this.maxDate)) {
                            this.errorMessage = this.maxDateValidationMessage;
                            element.setCustomValidity(this.maxDateValidationMessage);
                        } else if (this.minDate && element.value < this.minDate) {
                            this.errorMessage = this.minDateValidationMessage;
                            element.setCustomValidity(this.minDateValidationMessage);
                        } else {
                            this.errorMessage = '';
                            element.setCustomValidity('');
                        }
                    } else {
                        if(type === 'authorizedDate' && element.value > this.maxDate){
                            this.errorMessage = this.maxDateValidationMessage;
                            element.setCustomValidity(this.maxDateValidationMessage);
                        } else if(type === 'effectiveDate' && element.value < this.minDate){
                            this.errorMessage = this.minDateValidationMessage;
                            element.setCustomValidity(this.minDateValidationMessage);
                        } else {
                            const diffInDays = Math.ceil((new Date(element.value) - new Date()) / (1000 * 60 * 60 * 24));
                            if(type === 'effectiveDate' && this.isLLC && diffInDays > 90){
                                this.errorMessage = this.label.effective_days_llc_error;
                                element.setCustomValidity(this.label.effective_days_llc_error);
                            } else {
                                this.errorMessage = '';
                                element.setCustomValidity('');
                            }
                        }
                    }
                } else if (element.required && !element.value) {
                    this.errorMessage = this.isRequiredValidationMessage;
                    element.setCustomValidity(this.isRequiredValidationMessage);
                }
                else {
                    this.errorMessage = '';
                    element.setCustomValidity('');
                }
                element.reportValidity();
            });
            this.isNotValid =[...inputFields].some((inputCmp) => {
                        return inputCmp.validity.customError;
            });
        }
    }

    handleWitdrawalDates() {
        this.isLoading = true;
        this.effectiveDateEntered = this.effectiveDateEntered ? this.effectiveDateEntered : null;
        this.withdrawalEffectiveTimeSelected = this.withdrawalEffectiveTimeSelected ? this.withdrawalEffectiveTimeSelected.trim() : null;
        updateBusinessClosingEffectiveDate({ sId: this.businessFiling, effectiveDate: this.effectiveDateEntered, effectiveTime: this.withdrawalEffectiveTimeSelected }).then(data => {
            this.isLoading = false;
            this.next();
        }).catch(error => {
            this.isLoading = false;
            ComponentErrorLoging(this.compName, "handleWitdrawalDates", "", "", "Medium", error.message);
        });
    }

    /**
     * Method is used for confirmation from user when selects NEXT. All the required validation on date input are managed from this method.
     */
    handleClickNext() {
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1702 
        * Change(s)/Modification(s) Description : Removing pop up for error message.
        * Change(s)/Modification(s) Description : Added variables : isMaxError,isMinError and made modification in checkInputValidity method.
        */
        try {
            if(!this.isDateChanged){
                this.checkDateValidity();
                this.isDateChanged = true;
            }        
            if (!this.showErrorBlock && !this.isNotValid) {
                if (this.showConfirmationBlock) {
                    this.showConfirmationBlockFE = true;
                    this.showMessageContainer = true;
                } else if(this.isCloseBusiness && !this.isRevocationDissolution){
                    fireEvent(this.pageRef, "onTimeVerifyEvent", true);
                    if((this.withdrawalEffectiveTimeSelected && this.showTimeError) || this.timeNotSelectedError){
                        return;
                    }
                    this.handleWitdrawalDates();
                } else {
                    this.next();
                }
            } 
            /*else {
                if (this.showConfirmationBlock) {
                this.showErrorBlock = true;
                this.showMessageContainer = true;
                }
            }*/
        } catch (error) {
            ComponentErrorLoging(this.brs_UCC_ForiegnFlowDateComponent, "brs_UCC_ForiegnFlowDateComponent", "", "", "Medium", error.message);
        }

    }
    
    /**
     * Method used when user clicks on the (X) button on popup to close the pop up.
     */
    closePopUp() {
        this.showMessageContainer = false;
        this.showErrorBlock = false;
        this.showConfirmationBlockFE = false;
    }
    goToSummaryPageWithOutConfirmation() {
        this.isGotoSummary = true;
        // Onclick of goToSummary should do validation and make BE call to save effectivedate 
        this.handleClickNext();
    }
    /**
     * Similar to closePopUp this method is used as a confirmation from user that message has been read.
     */
    confirmAccept() {
        this.showMessageContainer = false;
        this.showErrorBlock = false;
        this.errorMessage = '';
    }
    /**
     * Method is used when the data entered by user has passed all validations and after confirm the user is sent to the next screen on the flow.
     */
    confirmAcceptAndNavigateNext() {
        //Next Screen Navigation FLOW Event
        const navigateNextEventCOnfirm = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEventCOnfirm);
    }
    /**
     * Used for firing event for flow to go on next screen
     */
    next() {
        //Next Screen Navigation FLOW Event
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
    /**
     * Used for firing event for flow to go on back screen
     */
    back() {
        //Previous Screen Navigation FLOW Event
        if(this.goToDashBoardPage)
            {
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: this.label.brs_FIlingLandingPage
                    },
                });
        } else{
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
        }
    }

    
  /**
   * validateEffectiveTime - checks if the time selected is not in the past
   * @param time - time in 24hr format like (18:30)
   */
  validateEffectiveTime(time) {
    const selectedHour = time.split(':')[0];
    const selectedMinute = time.split(':')[1];
    const currentDate = new Date();
    let selectedDate = new Date();
    selectedDate.setHours(selectedHour, selectedMinute, 0);
    return selectedDate < currentDate;
  }

  checkTimeValidity(){
    if(this.withdrawalEffectiveTimeSelected && this.effectiveDateEntered ){
        const today = getDate(new Date());
        const istodaysDateSelected = this.effectiveDateEntered === today;
        if(istodaysDateSelected){
            this.showTimeError = this.validateEffectiveTime(this.twentyFourHourTime);
        } else{
            this.showTimeError = false;
        }
    }
  }

  handleTimeSelectionError(event){
    this.timeNotSelectedError = event.detail.showTimeError;
  }
}
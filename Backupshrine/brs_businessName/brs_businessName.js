import { LightningElement, track, api } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationBackEvent, } from 'lightning/flowSupport';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import checkDuplicateAccName from "@salesforce/apex/brs_businessNameCheck.checkDuplicateAccName";
import { NavigationMixin } from 'lightning/navigation';

//custom labels
import Back from '@salesforce/label/c.Back';
import Next from '@salesforce/label/c.Next';
import NoFe from '@salesforce/label/c.No';
import YesFe from '@salesforce/label/c.Yes';
import businessNameNotAvailableMessageFE from '@salesforce/label/c.businessNameNotAvailableMessage';
import businessNameNotAvailableMessageDomestic from '@salesforce/label/c.businessNameNotAvailableMessageDomestic';
import businessNameNotAvailableMessageNameRes from '@salesforce/label/c.businessNameNotAvailableMessageNameRes';
import businessNameAvailableMessageFE from '@salesforce/label/c.businessNameAvailableMessage';
import businessTypeLLCFE from '@salesforce/label/c.businessTypeLLC';
import businessTypeLLPFE from '@salesforce/label/c.businessTypeLLP';
import businessTypeNon_StockFE from '@salesforce/label/c.businessTypeNon_Stock';
import domestic from '@salesforce/label/c.Domestic';
import businessTypeStockFE from '@salesforce/label/c.businessTypeStock';
import Barbs_Placeholder from '@salesforce/label/c.Barbs_Placeholder';
import Add_Legal_Designation from '@salesforce/label/c.Add_Legal_Designation';
import Business_Name_Max_Characters from "@salesforce/label/c.Business_Name_Max_Characters";
import ModalHeadNameRes from "@salesforce/label/c.ModalHeadNameRes";
import ModalBodyNameRes from "@salesforce/label/c.ModalBodyNameRes";
import Confirm from "@salesforce/label/c.Confirm";
import FormButton from "@salesforce/label/c.FormButton";
import ConfirmReservation from "@salesforce/label/c.ConfirmReservation";
import brs_name_change_amendment_flow from "@salesforce/label/c.brs_name_change_amendment_flow";
import go_to_summary from '@salesforce/label/c.go_to_summary';
import { ComponentErrorLoging } from "c/formUtility";
import brs_FIlingLandingPage from "@salesforce/label/c.brs_FIlingLandingPage";
import Please_Note from "@salesforce/label/c.Please_Note";
import business_name_screen_note from "@salesforce/label/c.business_name_screen_note";
let typingTimer;
const doneTypingInterval = 300;
export default class Brs_UCC_ForiegnFlowDateComponent extends NavigationMixin(LightningElement) {
    //Resources
    @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
    // APIs
    @api businessNameEntered;
    @api accountId;
    @api businessType;
    @track isBackButtonDisplay =true;
    @api bType;
    @api isDomestic = false; //Not in use
    @api isRequired = false;
    @api isRequiredValidationMessage;
    @api inputFieldLabel = '';
    @api showConfirmationBlock = false;
    @api confirmationBlockTitle = '';
    @api confirmationBlockSubTitle = '';
    @api confirmationBlockMessage = '';
    @api showUserInput = false;
    @api placeholder = Barbs_Placeholder;
    @api goToLegalDesignationScreen = false;
    @api isNameRes = false;
    @api flowName = "";
    @api filingId;
    @api varNewFilingId;
    @api isDisabled = false;
    @api goToDashBoardPage = false;
    @api showPleaseNoteSection = false;

    //Track
    @track topPleaseNoteSection;
    @track showConfirmationBlockFE = false;
    @track showMessageContainer = false;
    @track isDomesticBusiness;
    @track showAvailability = false;
    @track businessNameAvailable = false;
    @track isNameChangeAmendFlow = false;
    @api isGoToSummary = false;
    @api showSummaryButton = false;
    @api oldBusinessType;
    @api isPaperFilingIntake = false;
    @api isEditClicked = false;
    @api errorMsg;
    @api intakeReservation=false;
    @track labels = {
        Next,
        Back,
        NoFe,
        YesFe,
        businessNameNotAvailableMessageFE,
        businessNameNotAvailableMessageDomestic,
        businessNameAvailableMessageFE,
        businessTypeLLCFE,
        businessTypeLLPFE,
        businessTypeNon_StockFE,
        businessTypeStockFE,
        Add_Legal_Designation,
        domestic,
        Business_Name_Max_Characters,
        businessNameNotAvailableMessageNameRes,
        ModalBodyNameRes,
        ModalHeadNameRes,
        Confirm,
        FormButton,
        ConfirmReservation,
        brs_name_change_amendment_flow,
        go_to_summary,
        brs_FIlingLandingPage,
        Please_Note,
        business_name_screen_note
    };

    connectedCallback() {
        this.topPleaseNoteSection = `<p class="small"><b class="dull-orange-text">${this.labels.Please_Note}</b></p><p class="small karaka-text">${this.labels.business_name_screen_note}</p>`;
        this.errorMsg = this.errorMsg ? this.errorMsg : this.labels.businessNameNotAvailableMessageFE;
        this.isBackButtonDisplay = false;
        this.isDomesticBusiness = (this.bType === this.labels.domestic);
        this.oldBusinessName = this.businessNameEntered ? this.businessNameEntered.trim() : null;
        this.isNameChangeAmendFlow = (this.flowName && this.flowName.toLowerCase() === this.labels.brs_name_change_amendment_flow.toLowerCase());
        this.isRegisterABizIntake = (this.flowName && this.flowName.toLowerCase() === "register a business");
        if(this.businessType === 'LLC' && this.flowName === 'Business Formation')
{
    this.isBackButtonDisplay = true;
}
        if(this.varNewFilingId != null && this.varNewFilingId != undefined)
        {
           var cloneRes = JSON.parse(this.varNewFilingId);
           this.filingId = cloneRes[0].filingId;
        }
        //BRS-1840 - Making Business name null if business type changed
        if (this.oldBusinessType && this.businessNameEntered && this.businessType !== this.oldBusinessType) {
            this.businessNameEntered = null;
        }
        //BRS -1840
        if (!this.businessNameEntered) {
            this.showAvailability = false;
            this.businessNameAvailable = false;
        }
        else{
            if(!this.isDisabled && !this.intakeReservation) {
                if(!this.isEditClicked) {
                    this.checkDuplicateBusinessName(this.accountId, this.businessNameEntered);
                }
            }
        } 
    }

    /**
     * Used for setting value from business name input field change to businessNameEntered
     * @param {NA} event 
     */
    handleBusinessNameInput(event) {
        const businessNameEntered = event.target.value;
        this.businessNameEntered = businessNameEntered;
        clearTimeout(typingTimer);
        typingTimer = setTimeout(() => {
            this.handleBusinessNameAvailability(businessNameEntered.trim())
        }, doneTypingInterval);
    }

    handleBusinessNameInputBlur(event){
        this.businessNameEntered = event.target.value.trim();
    }

    //clearing timer when user typing
    handleBusinessNameInputDown(){
        clearTimeout(typingTimer);
    }

    handleBusinessNameAvailability(searchKey) {
        //BRS -1840 - Bug Fix
        if (searchKey) {
            this.checkInputValidity();
        }
        //BRS -1840
        if (!searchKey) {
            this.showAvailability = false;
            this.businessNameAvailable = false;
        }
        else {
            if (searchKey.trim() !== '') {
                // Implement BRS-9 functionality check here.
                this.isNameChanged =  this.oldBusinessName && (this.oldBusinessName.trim().toLowerCase() !== searchKey.toLowerCase());
                if (this.accountId || this.isNameRes) {
                    if(this.isNameChanged){
                        this.checkDuplicateBusinessName(this.accountId, searchKey);
                    }
                } else {
                    if(this.isPaperFilingIntake && !this.intakeReservation){
                        this.checkDuplicateBusinessName(this.accountId, searchKey);
                    }
                }
            }
        }
    }

    /**
     * Method is used for confirmation from user when selects NEXT. All the required validation on business name field input are managed from this method.
     */
    handleClickNext() {
        try {
            this.showAvailability = false;
            if (this.isRequired) {
                if (!this.businessNameEntered) {
                    this.showAvailability = false;
                    this.checkInputValidity();
                    return;
                } else if (this.businessNameEntered) {
                    if (this.isNameRes) {
                        checkDuplicateAccName({ businessName: this.businessNameEntered, accId: this.accountId })
                            .then((data) => {
                                this.businessNameAvailable = data;
                                this.showAvailability = true;
                                if(data) {
                                    this.nextScreen();
                                }
                            })
                    } else {
                        if ((this.isNameChangeAmendFlow || this.isPaperFilingIntake) && this.isDisabled) {
                            this.nextScreen(); 
                        } else if(this.isPaperFilingIntake){
                            if((this.isEditClicked && this.isNameChanged && !this.intakeReservation) || !this.isEditClicked && !this.intakeReservation){
                                checkDuplicateAccName({ businessName: this.businessNameEntered, accId: this.accountId })
                                .then((data) => {
                                    this.businessNameAvailable = data;
                                    this.showAvailability = true;
                                    const isRegisterABizForeign = this.isRegisterABizIntake && !this.isDomesticBusiness;
                                    if(isRegisterABizForeign){
                                        this.goToLegalDesignationScreen = data;
                                    }
                                    if(data || (isRegisterABizForeign)) {
                                        this.nextScreen();
                                    }
                                })
                            } else {
                                this.nextScreen();
                            }
                        } else{
                                checkDuplicateAccName({ businessName: this.businessNameEntered, accId: this.accountId })
                                .then((data) => {
                                    this.businessNameAvailable = data;
                                    this.showAvailability = true;
                                    this.nextScreen();
                                });
                        }
                    }
                }
            } else {
                if (this.businessNameEntered != undefined && this.businessNameEntered != null && this.businessNameEntered !== "") {
                    this.showAvailability = false;
                    if (this.accountId || this.isNameRes || this.isNameChangeAmendFlow) {
                        this.checkDuplicateBusinessName(this.accountId, this.businessNameEntered);
                    } else if(this.isPaperFilingIntake){
                        if((this.isEditClicked && this.isNameChanged && !this.intakeReservation) || !this.isEditClicked && !this.intakeReservation){
                            checkDuplicateAccName({ businessName: this.businessNameEntered, accId: this.accountId })
                            .then((data) => {
                                this.businessNameAvailable = data;
                                this.showAvailability = true;
                                if(data) {
                                    this.nextScreen();
                                }
                            })
                        } else {
                            this.nextScreen();
                        }
                    }                   
                } else {
                    this.nextFlowEvent();
                }
            }
        } catch (error) {
            ComponentErrorLoging(this.brs_businessName, "brs_businessName", "", "", "Medium", error.message);
        }

    }
    /**
     * Method used for the purpose of validation on the input field. This is used when the field has no input or has invalid input.
     */
    checkInputValidity() {
        this.template.querySelectorAll('[data-id="inputfields"]').forEach((element) => {
            if (element.required && !element.value) {
                element.setCustomValidity(this.isRequiredValidationMessage);
            } else {
                element.setCustomValidity("");
            }
            element.reportValidity();
        });
    }
    /**
     * Method used when user clicks on the (X) button on popup to close the pop up.
     */
    closePopUp() {
        this.showMessageContainer = false;
        this.showConfirmationBlockFE = false;
    }
    /**
     * Method is used to set goToLegalDesignationScreen to true and navigate the user to Legal Designation Screen.
     */
    userResponseNo() {
        this.goToLegalDesignationScreen = false;
        this.nextFlowEvent();
    }
    goToMainFlow(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'brsflow'
            }
        });
    }


    /**
     * Method is used to set goToLegalDesignationScreen to true and navigate the user to Legal Designation Screen.
     */
    userResponseYes() {
        this.goToLegalDesignationScreen = true;
        this.nextFlowEvent();
    }

    goToSummaryPage() {
        this.nextFlowEvent();
    }
    /**
     * Used for firing event for flow to go on next screen
     */
    nextScreen() {
        /**
        * If business name is not available, we are setting the value for goToLegalDesignationScreen as false.
        * In the flows we manage further propagation. If goToLegalDesignationScreen is true which means we send user to Legal Designation Page.
        * If goToLegalDesignationScreen is set to false then we check if has reserved names
        * If yes GO to reserved name page
        * If no GO to legal designation screen with null input from user and business name field enabled.
        * The logic condition being considered here are managed by the flow.
        */

        // For domestic business type
        if(!this.intakeReservation)
        {   
            if (this.isDomesticBusiness) {
                if (this.businessNameAvailable) {
                    this.goToLegalDesignationScreen = true;
                    this.nextFlowEvent();
                } else if (!this.businessNameAvailable) {
                    this.goToLegalDesignationScreen = false;
                }
            }
            // Business type selected is LLC, Stock and Non Stock.
            else {
                if (this.businessType == this.labels.businessTypeLLCFE ||
                    this.businessType == this.labels.businessTypeNon_StockFE ||
                    this.businessType == this.labels.businessTypeStockFE) {
                    if (this.businessNameAvailable) {
                        this.goToLegalDesignationScreen = true;
                        this.nextFlowEvent();
                    } else if (!this.businessNameAvailable) {
                        this.goToLegalDesignationScreen = false;
                        this.nextFlowEvent();
                    }
                    // Business type selected is LLP.
                }else if(this.isNameChangeAmendFlow){
                    this.goToLegalDesignationScreen=this.isDisabled? true: this.businessNameAvailable;
                    this.nextFlowEvent();
                    return;
                } else if(this.isPaperFilingIntake){
                    this.nextFlowEvent();
                    return;
                } else if (this.businessType == this.labels.businessTypeLLPFE) {
                    if (this.businessNameAvailable) {
                        // Show pop-up for business name
                        this.showConfirmationBlockFE = true;
                        this.showMessageContainer = true;
                    }
                    //BRS -1840 Changes related to show popup always
                    else if (!this.businessNameAvailable && this.businessNameEntered) {
                        // uncommenting below line as per BRS-4924 
                        this.goToLegalDesignationScreen = false;                    
                        this.nextFlowEvent();
                        /*this.businessNameAvailable = true;
                        this.showConfirmationBlockFE = true;
                        this.showMessageContainer = true;*/
                    }
                    //BRS - 1840
                }
            }
        }
        else
        {
            this.goToLegalDesignationScreen = true;
             this.nextFlowEvent();
        }
        
        if (!this.businessType && this.businessNameAvailable && this.businessNameEntered) {
            this.goToLegalDesignationScreen = false;
            this.showConfirmationBlockFE = true;
            if(!this.isPaperFilingIntake){
                this.showMessageContainer = true;
            } else {
                this.nextFlowEvent();
            }
        } else {
            if(this.isEditClicked){
                this.nextFlowEvent();
            }
        }
    }
    /**
     * Used for firing event for flow to go on back screen
     */
    back() {
        //Previous Screen Navigation FLOW Event
        if (this.goToDashBoardPage) {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: this.label.brs_FIlingLandingPage
                },
            });
        }else if (this.isNameRes) {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'nameres'
                }
            });

        }
        else {
            this.oldBusinessType = this.businessType;
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }

    }
    nextFlowEvent() {
        //Next Screen Navigation FLOW Event
        this.goToDashBoardPage=false;
        const navigateNextEvent = this.isGoToSummary ? new FlowNavigationNextEvent("isGoToSummary", this.isGoToSummary) : new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

    goToSummaryPageClick(){
        this.isGoToSummary = true;
        this.handleClickNext();
    }

    checkDuplicateBusinessName(accId, accName){
        checkDuplicateAccName({
          businessName: accName,
          accId: accId
        })
        .then((data) => {
          this.showAvailability = true;
          this.businessNameAvailable = data;
        })
        .catch(error => {
            ComponentErrorLoging("brs_businessName","checkDuplicateAccName","","","Medium",error.message);  
        });
    }
}
import { LightningElement, track, api } from 'lwc';
import AddressUnit_Apt from "@salesforce/label/c.AddressUnit_Apt";
import Com_PhoneAlert from "@salesforce/label/c.Com_PhoneAlert";
import { emailPattern, formatMobileNumberOnEntering } from "c/appUtility";
import Back from '@salesforce/label/c.Back';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import getPaymentDetails from '@salesforce/apex/ACHPaymentController.getPaymentDetails';
import achPaymentCallout from '@salesforce/apex/ACHPaymentController.achPaymentCallout';
import createDebitVoucherRecordsForOnlineFiling from '@salesforce/apex/BRS_PaymentUtility.createDebitRecordsForOnlineFiling';
import Transaction from "@salesforce/label/c.Transaction";
import Amount from "@salesforce/label/c.Amount";
import TotalAmount from "@salesforce/label/c.TotalAmount";
import Balancededucted from '@salesforce/label/c.Balancededucted';
import Balanceremaining from '@salesforce/label/c.Balanceremaining';
import profileCard_Filing_Fee from '@salesforce/label/c.profileCard_Filing_Fee';
import FinalAmount from '@salesforce/label/c.FinalAmount';
import FRANCHISE_TAX from '@salesforce/label/c.FRANCHISE_TAX';
import ExpeditedFee from "@salesforce/label/c.ExpeditedFee";
import getFilingFees from '@salesforce/apex/BRS_PaymentUtility.getFilingFees';
import { ComponentErrorLoging } from "c/formUtility";
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import Your_selected_payment_method from '@salesforce/label/c.Your_selected_payment_method';
import Select_the_account_owner from '@salesforce/label/c.Select_the_account_owner';
import Personal from '@salesforce/label/c.Personal';
import ACH from '@salesforce/label/c.ACH';
import Credit_Card from '@salesforce/label/c.Credit_Card'; 
import Agent_Business_Option from '@salesforce/label/c.Agent_Business_Option';
import Checking from '@salesforce/label/c.Checking';
import Savings from '@salesforce/label/c.Savings';
import Account_type_required from '@salesforce/label/c.Account_type_required';
import Account_number_required from '@salesforce/label/c.Account_number_required';
import Confirm_account_number_required from '@salesforce/label/c.Confirm_account_number_required';
import Routing_number_required from '@salesforce/label/c.Routing_number_required';
import Bank_name_required from '@salesforce/label/c.Bank_name_required';
import First_Name_Required from '@salesforce/label/c.First_Name_Required';
import Last_Name_Required from '@salesforce/label/c.Last_Name_Required';
import Email_Address_Required from '@salesforce/label/c.Email_Address_Required';
import Phone_number_required from '@salesforce/label/c.Phone_number_required';
import Company_name_required from '@salesforce/label/c.Company_name_required';
import Attention from '@salesforce/label/c.Attention';
import Check_Draft_Instructions from '@salesforce/label/c.Check_Draft_Instructions';
import Where_is_Account_and_Routing from '@salesforce/label/c.Where_is_Account_and_Routing';
import Account_numbers_entered_must_match from '@salesforce/label/c.Account_numbers_entered_must_match';
import something_went_wrong from '@salesforce/label/c.something_went_wrong';
import Generic_Input_Error_Message from '@salesforce/label/c.Generic_Input_Error_Message';
import GenericInput_Invalid_Email from "@salesforce/label/c.GenericInput_Invalid_Email";
export default class Brs_achPaymentScreen extends LightningElement {
    @api source = "Worker Portal";
    @api parentRecordId;
    @api customerId;
    @api workorderId;
    @api feeAmt;
    @track selectedAccOwnerType;
    @track selectedAccType;
    @track accNo;
    @track accNoConfirm;
    @track routingNo;
    @track firstName;
    @track lastName;
    @track companyName;
    @track attention;
    @track businessAddressFields = {};
    @track phone;
    @track email;
    @track hasError = false;
    @track cardicon = assetFolder + "/icons/card-payment-icon.svg";
    @track achicon = assetFolder + "/icons/ach-payment-icon.svg";
    @track filingObj;
    @track isLoading = false;
    @track showConfirmationPopUp = false;
    @track confirmationHeaderMsg;
    @track message;
    @track showCompanyName = false;
    @track emailPattern = emailPattern;
    @track accPaymentOpts = [
        { label: ACH, value: "ACH", id: "ACH", imgSrc: this.achicon },
        { label: Credit_Card, value: "Credit", id: "Credit", imgSrc: this.cardicon }
    ];
    @track accOwnerOptions = [
        { label: Personal, value: "Personal", id: "Personal" },
        { label: Agent_Business_Option, value: "Business", id: "Business" }
    ]
    @track accTypeOptions = [
        { label: Checking, value: "1" },
        { label: Savings, value: "2" }
    ]
    label = {
        AddressUnit_Apt,
        Com_PhoneAlert,
        Back,
        Transaction,
        Amount,
        TotalAmount,
        Balancededucted,
        Balanceremaining,
        profileCard_Filing_Fee,
        FinalAmount,
        FRANCHISE_TAX,
        ExpeditedFee,
        Your_selected_payment_method,
        Select_the_account_owner,
        Account_type_required,
        Account_number_required,
        Confirm_account_number_required,
        Routing_number_required,
        Bank_name_required,
        First_Name_Required,
        Last_Name_Required,
        Email_Address_Required,
        Phone_number_required,
        Company_name_required,
        Attention,
        Check_Draft_Instructions,
        Where_is_Account_and_Routing,
        Account_numbers_entered_must_match,
        something_went_wrong,
        Generic_Input_Error_Message,
        GenericInput_Invalid_Email
    }
    connectedCallback() {
        getFilingFees({
            filingId: this.parentRecordId,
            customerId: this.customerId,
            workorderId: this.workorderId,
            feeAmount: this.feeAmt
        })
            .then(result => {
                if (result) {
                    this.filingObj = result;
                }
            })
            .catch(error => {
                this.spinner = false;
                ComponentErrorLoging(
                    this.compName,
                    "getFilingFees",
                    "",
                    "",
                    this.severity,
                    error.message
                );
            })
    }
    handleAccOwnerSelect(event) {
        this.selectedAccOwnerType = event.detail.value;
        this.companyName = "";
        if(this.selectedAccOwnerType === "Business"){
            this.showCompanyName = true;
        } else {
            this.showCompanyName = false;
        }
        this.hasError = false;
    }
    handleTypeSelection(event) {
        this.selectedAccType = event.detail.value;
    }
    handleAccNo(event) {
        this.accNo = event.target.value.trim();
        if (this.accNoConfirm) {
            this.checkConfirmAccountNumber();
        }
    }
    handleConfirmAccNo(event) {
        this.accNoConfirm = event.target.value.trim();
        if (this.accNo) {
            this.checkConfirmAccountNumber();
        }
    }
    handleRoutingNo(event) {
        this.routingNo = event.target.value.trim();
    }
    handleBankName(event) {
        this.bankName = event.target.value.trim();
    }
    handleFirstName(event) {
        this.firstName = event.target.value.trim();
    }
    handleLastName(event) {
        this.lastName = event.target.value.trim();
    }
    handleCompanyName(event) {
        this.companyName = event.target.value.trim();
    }
    handleAttention(event) {
        this.attention = event.target.value.trim();
    }
    onMobileNumberKeyPress(event) {
        const charCode = event.keyCode || event.which;
        if (charCode < 48 || charCode > 57) {
            event.preventDefault();
        }
    }
    removeCopyPaste(e) {
        e.preventDefault();
        return false;
    }
    handlePhoneBlur(event) {
        this.phone = event.target.value.trim();
    }
    mobileHandler(event) {
        this.mobilenumberFormate(event.target.value);
    }
    mobilenumberFormate(mobileNumber) {
        let formatedNumber = formatMobileNumberOnEntering(mobileNumber);
        this.phone = formatedNumber;
    }
    onEmailChange(event) {
        let input = this.template.querySelector(
            "lightning-input[data-my-id=input-box1]"
          );
          let val =event.detail.value.trim().toLowerCase();
          if(input){
            if (val && !val.match(this.emailPattern)) {
              //set an error
              input.setCustomValidity(this.label.GenericInput_Invalid_Email);
              input.reportValidity();              
            } else {
              //reset an error
              input.setCustomValidity("");
              input.reportValidity(); 
              this.email = event.detail.value.trim().toLowerCase();            
            }
          }
        
    }
    validateEmail() {

    }
    validate() {
        let isInputsCorrect;
        isInputsCorrect = [...this.template.querySelectorAll('.ach-inputs')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        const accAddress = this.template.querySelector("c-brs_address.accountAddress");
        const validAccAddress = accAddress.validateaddress();
        if (!isInputsCorrect || !validAccAddress || !this.selectedAccOwnerType) {
            this.hasError = this.selectedAccOwnerType ? false : true;
        } else {
            const { city, state, zip, street, unit, country, internationalAddress, countryFormat } = JSON.parse(JSON.stringify(accAddress.getdata()));
            const requestObj = {
                selectedAccOwnerType: this.selectedAccOwnerType,
                selectedAccType: this.selectedAccType,
                accNo: this.accNo,
                routingNo: this.routingNo,
                firstName: this.firstName,
                lastName: this.lastName,
                companyName: this.companyName ? this.companyName: "",
                attention: this.attention ? this.attention : "",
                phone: this.phone,
                email: this.email,
                city, state, zip, street, unit, country, internationalAddress, countryFormat,
                filingId: this.parentRecordId,
                customerId: this.customerId,
                workorderId: this.workorderId,
                amount: this.filingObj.finalAmount
            }
            this.isLoading = true;
            getPaymentDetails({ requestString: JSON.stringify(requestObj) }).then((result) => {
                this.isLoading = false;
                if (result) {
                    this.callACHPaymentMethod(result);
                    //const navigateNextEvent = new FlowNavigationNextEvent();
                    //this.dispatchEvent(navigateNextEvent);
                }
                else {

                }

            }).catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    'brs_achPaymentScreen',
                    "getPaymentDetails",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            })
        }
    }
    handlePropagateBack() {

    }

    checkConfirmAccountNumber() {
        let input = this.template.querySelector("lightning-input[data-id=acc-input]");
        if (this.accNo && this.accNoConfirm && this.accNo === this.accNoConfirm) {
            input.setCustomValidity("");
            input.reportValidity();
        } else {
            input.setCustomValidity(this.label.Account_numbers_entered_must_match);
            input.reportValidity();
        }
    }

    callACHPaymentMethod(reqString) {
        this.isLoading = true;
        achPaymentCallout({ requestString: reqString }).then((result) => {
            this.isLoading = false;
            if (result) {
                const response = JSON.parse(result);
            if (response.responseMessage !=null && response.responseMessage.toLowerCase().includes("transaction approved")) {
                    
		    this.callVoucherDebit();
                    //this.navigateNext();
                } else {
                    // this.message = response.responseMessage;
                    this.message = response.errorMessage;
                    this.confirmationHeaderMsg = this.label.something_went_wrong;
                    this.showConfirmationPopUp = true;
                }
            }
            else {

            }

        }).catch(error => {
            this.isLoading = false;
            ComponentErrorLoging(
                'brs_achPaymentScreen',
                "callACHPaymentMethod",
                "",
                "",
                "Medium",
                error.message
            );
        })
    }

    navigateNext() {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

    closeModal() {
        this.showConfirmationPopUp = false;
    }

    onRoutingInputBlur(event){
        const charCode = event.keyCode || event.which;
        if ((charCode < 48 || charCode > 57)) {
            if(charCode !=8){
                event.preventDefault();
            }
        }
    }

    callVoucherDebit(){
        this.isLoading = true;
        createDebitVoucherRecordsForOnlineFiling({workorderId :  this.workorderId ,
            filingId : this.filingObj.filingId
        }).then((result)=>{            
            this.navigateNext();
            setTimeout(()=>{
                this.isLoading = false
            },1000)
        })
    }
}
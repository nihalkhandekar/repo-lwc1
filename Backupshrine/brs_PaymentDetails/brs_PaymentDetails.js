import { LightningElement, wire, track, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import CONTACT_TOTAL_VOUCHER_FIELD from '@salesforce/schema/Contact.Total_Voucher_Balance__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import PaymentDetails from "@salesforce/label/c.PaymentDetails";
import PaymentAlmostFinished from "@salesforce/label/c.PaymentAlmostFinished";
import PaymentDetailsTerms from "@salesforce/label/c.PaymentDetailsTerms";
import Transaction from "@salesforce/label/c.Transaction";
import Amount from "@salesforce/label/c.Amount";
import TotalAmount from "@salesforce/label/c.TotalAmount";
import Back from '@salesforce/label/c.Back';
import Next from '@salesforce/label/c.Next';

import CurrentBalance from '@salesforce/label/c.CurrentBalance';
import BalanceRedeemtext from '@salesforce/label/c.BalanceRedeemtext';
import RedeemVoucher from '@salesforce/label/c.RedeemVoucher';
import RedeemVoucherSentenceCase from '@salesforce/label/c.BRS_RedeemVoucher';
import Balancededucted from '@salesforce/label/c.Balancededucted';
import Balanceremaining from '@salesforce/label/c.Balanceremaining';
import profileCard_Filing_Fee from '@salesforce/label/c.profileCard_Filing_Fee';
import FinalAmount from '@salesforce/label/c.FinalAmount';
import Termsandondition from '@salesforce/label/c.Termsandondition';
import InvalidVoucherErrorMessage from '@salesforce/label/c.InvalidVoucherErrorMessage';
import InvalidVouchercode from '@salesforce/label/c.InvalidVouchercode';
import CancelButton from '@salesforce/label/c.CancelButton';
import Apply from '@salesforce/label/c.Apply';
import VoucherCode from '@salesforce/label/c.VoucherCode';
import FRANCHISE_TAX from '@salesforce/label/c.FRANCHISE_TAX';
import ContinuetoPayment from "@salesforce/label/c.ContinuetoPayment";
import VoucherToastMessage from "@salesforce/label/c.VoucherToastMessage";
import { FlowNavigationBackEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
//import { publish, createMessageContext, releaseMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
//import lmsDemoMC from "@salesforce/messageChannel/LMSDemoWin__c";
import redeemVoucher from '@salesforce/apex/BRS_PaymentUtility.redeemVoucher';
import getFilingFees from '@salesforce/apex/BRS_PaymentUtility.getFilingFees';
import getPaymentHistoryData from '@salesforce/apex/BRS_PaymentUtility.getPaymentHistoryData';
import ph_Gotissue from "@salesforce/label/c.ph_Gotissue";
import ph_Gotissue_link from "@salesforce/label/c.ph_Gotissue_link";
import Please_note_Label from '@salesforce/label/c.Please_note_Label';
import Generic_Input_Error_Message from "@salesforce/label/c.Generic_Input_Error_Message";
import Enable_ACH from "@salesforce/label/c.Enable_ACH";
import {
    ComponentErrorLoging
} from "c/formUtility";
import ExpeditedFee from "@salesforce/label/c.ExpeditedFee";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Select_a_payment_method from '@salesforce/label/c.Select_a_payment_method';
import Select_a_Payment_method_to_continue from '@salesforce/label/c.Select_a_Payment_method_to_continue';
import Credit_Card from '@salesforce/label/c.Credit_Card'; 
import ACH from '@salesforce/label/c.ACH';
const FIELDS = ['Contact.Total_Voucher_Balance__c'];


// export default class Brs_PaymentDetails extends NavigationMixin(LightningElement) {
export default class Brs_PaymentDetails extends LightningElement {
    label = {
        PaymentDetails,
        PaymentAlmostFinished,
        PaymentDetailsTerms,
        Transaction,
        Amount,
        TotalAmount,
        Back,
        Next,
        profileCard_Filing_Fee,
        FRANCHISE_TAX,
        CurrentBalance,
        BalanceRedeemtext,
        RedeemVoucher,
        Balancededucted,
        Balanceremaining,
        FinalAmount,
        FinalAmount,
        Termsandondition,
        InvalidVoucherErrorMessage,
        InvalidVouchercode,
        CancelButton,
        Apply,
        VoucherCode,
        ContinuetoPayment,
        VoucherToastMessage,
		RedeemVoucherSentenceCase,
        ph_Gotissue,
        ph_Gotissue_link,
        Generic_Input_Error_Message,
        ExpeditedFee,
        Please_note_Label,
        Select_a_payment_method,
        Select_a_Payment_method_to_continue,
        Enable_ACH
    }
    @api busType;
    @api feeAmt;
    @api filingFeeAmount;
    @api totalFee;
    @api parentRecordId;
    @api parentObjectName;
    @api workorderRecord;
    @api workorderId;
    @api customerId;
    @track filingObj;
    @track contact;
    @api voucherId;
    @track paymentTerms = [{
        label: PaymentDetailsTerms,
        value: PaymentDetailsTerms,
        isChecked: false
    }];
    @track showErrorMsg = false;
    @track franchiseTax;
    @track accountIdToPass = '';
    @track currentBalance;
    @api balancededucted;
    @track balanceremaining;
    @api finalAmount;
    @track voucherCode;
    @track isModalOpen=false;
    @track showErrorMessage=false;
    @track showFranchiseTax=false;
    @track spinner = false;
    @track dateFrom;
    @track dateTo;
    @track compName = "paymentdetails";
    @track severity = "medium";
    @track showExpeditedFees = false;
    @track expeditedFees;
    @api tablecolumns;
    @api tabledata;
    @api showHistoryTable =false;
	@api paymentAck;
    @api selectedPaymentMethod = "Credit";
    @track cardicon =  assetFolder + "/icons/card-payment-icon.svg";
    @track achicon =  assetFolder + "/icons/ach-payment-icon.svg";
    @track radioOptions = [
         { label: Credit_Card, value: "Credit", id: "Credit", imgSrc: this.cardicon }
//         { label: ACH, value: "ACH", id: "ACH", imgSrc: this.achicon }
     ]
    @track hasError = false;

    connectedCallback(){
        if(this.label.Enable_ACH.toLowerCase() === 'true'){
            this.radioOptions.push({ label: "ACH", value: "ACH", id: "ACH", imgSrc: this.achicon });
        }
        if(this.showHistoryTable==false){
            this.spinner = true;
            getFilingFees({
                filingId:this.parentRecordId,
                customerId:this.customerId,
                workorderId:this.workorderId,
				feeAmount: this.feeAmt
            })
            .then(result => {
                if(result){
                    var filingObj = result;
                    this.filingObj = filingObj;
                    this.currentBalance = filingObj.customerBalance;
                    this.filingFeeAmount = filingObj.filingFee;
                    this.showFranchiseTax = filingObj.showFranchiseTax;
                    if(this.showFranchiseTax){
                        this.franchiseTax = filingObj.franchiseTax;
                    }
                    this.showExpeditedFees = filingObj.showExpeditedFees;
                    this.expeditedFees = filingObj.expeditedFees;
                    this.totalFee = filingObj.totalFee;
                    var balance = parseInt(this.currentBalance);
                    var totalfilingfee = filingObj.totalFee;
                    this.balancededucted = filingObj.balancededucted;
                    this.balanceremaining = filingObj.balanceremaining;
                    this.finalAmount = filingObj.finalAmount;
                       this.spinner = false;
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
        if(this.showHistoryTable==true){
            this.showHistoryTable = false;
            this.spinner = true;
            getPaymentHistoryData()
            .then(result=>{
                this.tablecolumns=result.tableColumns;
                this.tabledata=result.tableData;
                this.currentBalance=result.currentBalance;
                    let header = this.template.querySelector('.headerWrapper');
                   if (header) {
                        header.classList.remove("headerMargin")
                    }
                    this.setPaymentTableData();
                    this.showHistoryTable = true;
                    this.spinner = false;
                })
                .catch(error => {
                    this.spinner = false;
                    ComponentErrorLoging(
                        this.compName,
                        "getPaymentHistoryData",
                        "",
                        "",
                        this.severity,
                        error.message
                    );
                })

        }
    }
    setPaymentTableData() {
                    this.tabledata.forEach(item => {
            let status = item.status;
            if (status.toLowerCase() === "complete") {
                            item.isComplete = true;
            } else if (status.toLowerCase() === "pending" || status.toLowerCase() === "in progress") {
                            item.isPending = true;
            } else if (status.toLowerCase() === "failed") {
                item.isFailed = true;
                        } else {
                            item.isOther = true;
                        }
                    });
    }
    handleDateFilter(event) {
        this.showHistoryTable = false;
        this.spinner = true;
        let result = JSON.parse(event.detail.result);
        this.dateFrom = event.detail.from;
        this.dateTo = event.detail.to;
        this.tabledata = result.tableData;
        this.setPaymentTableData();
        setTimeout(() => {
                    this.showHistoryTable = true;
                    this.spinner = false;
        }, 100);
        }
    handleRedeemVoucher(){
        this.isModalOpen=true;
    }

    handleVoucherCode(event) {
        var voucherCode = event.detail.value;
        this.voucherCode = voucherCode;
        this.showErrorMessage = false;
        let inputElement = this.template.querySelector(".codeInput");
        if (inputElement) {
            inputElement.setCustomValidity("");
            inputElement.reportValidity();
        } 
    }

    closeModal(){
        this.isModalOpen = false;
    }
    submitVoucherDetails(){
        if(this.voucherCode!=null){
            this.spinner = true;
            redeemVoucher({
                voucherCode: this.voucherCode,
                workorderId: this.workorderId,
                filingId: this.parentRecordId
            })
            .then(result => {
            this.spinner = false;
                if(result !=null && result!=undefined){
                    this.voucherId = result;
                    this.isModalOpen=false;
                    this.dispatchEvent(
                            new ShowToastEvent({
                              title: '',
                              message: VoucherToastMessage
                            })
                          );
                     this.connectedCallback();
                }else{
                    this.showErrorMessage=true;
                        let inputElement = this.template.querySelector(".codeInput");
                        if (inputElement) {
                            inputElement.setCustomValidity(InvalidVouchercode);
                            inputElement.reportValidity();
                        } 
                }
            })
            .catch(error => {
                    this.spinner = false;
                    ComponentErrorLoging(
                        this.compName,
                        "redeemVoucher",
                        "",
                        "",
                        this.severity,
                        error.message
                    );
            })
        }else {
            this.showErrorMessage = true;
            let inputElement = this.template.querySelector(".codeInput");
            if (inputElement) {
                inputElement.setCustomValidity(Generic_Input_Error_Message);
                inputElement.reportValidity();
            }
        }
    }

    showToast(){
        const event = new ShowToastEvent({
            title: '',
            message: 'Voucher code successfully applied to your current balance.',
        });
        this.dispatchEvent(event);
    }

    onAcceptTerms() {
        this.showErrorMsg = false;
        const isChecked = !this.paymentTerms[0].isChecked;
        this.paymentTerms = [{
            ...this.paymentTerms[0],
            isChecked
        }]
    }

    validateNext() {
		this.paymentAck= this.paymentTerms[0].isChecked;
        if (this.paymentTerms[0].isChecked) {
            this.showErrorMsg = false;
            if(this.selectedPaymentMethod){
                const nextNavigationEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(nextNavigationEvent);
            } else {
                this.hasError = true;
            }
        } else {
            this.showErrorMsg = true;
        }
    }

    handleBack() {
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    handleRadioSelect(event){
        this.selectedPaymentMethod = event.detail.value;
        this.hasError = false;
    }
}
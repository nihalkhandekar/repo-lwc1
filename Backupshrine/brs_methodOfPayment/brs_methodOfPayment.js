import { LightningElement, api, track, wire } from "lwc";
import Next from "@salesforce/label/c.Next";
import Back from "@salesforce/label/c.Back";
import {
  FlowNavigationNextEvent,
  FlowNavigationBackEvent,
} from "lightning/flowSupport";
import { CurrentPageReference } from "lightning/navigation";
import Select_Payment_Method from "@salesforce/label/c.Select_Payment_Method";
import Select_FirstOrFullPayment from "@salesforce/label/c.Select_FirstOrFullPayment";
import Method from "@salesforce/label/c.Method";
import Total_amount from "@salesforce/label/c.Total_amount";
import No_of_months from "@salesforce/label/c.No_of_months";
import Monthly_payable from "@salesforce/label/c.Monthly_payable";
import First_payment_comparable from "@salesforce/label/c.First_payment_comparable";
import Monthly_comparable from "@salesforce/label/c.Monthly_comparable";
import Full_comparable from "@salesforce/label/c.Full_comparable";
import Full from "@salesforce/label/c.Full";
import First_payment from "@salesforce/label/c.First_payment";
import Monthly from "@salesforce/label/c.Monthly";
import month from "@salesforce/label/c.month";

export default class Brs_methodOfPayment extends LightningElement {
  @api foreignInvRec;
  @wire(CurrentPageReference) pageRef;
  @track showErrorMessage;
  @track errorMessage;
  @api selectedPayment;
  @track showPopup;
  @api noOfMonths;
  @track modalSize = "small";
  @track radioOptions = [];
  @track isPicklistRequired;
  @track typeOfPayments = [
    First_payment_comparable,
    Monthly_comparable,
    Full_comparable,
  ];
  @track monthsList = [];
  @track hasFirstPayment = false;
  @track tablecolumns = [];
  @track tabledata = [];
  @api totalAmount;
  @track monthlyPayable;

  label = {
    Next,
    Back,
    Select_Payment_Method,
    Select_FirstOrFullPayment,
    Method,
    Total_amount,
    No_of_months,
    Monthly_payable,
    First_payment_comparable,
    Monthly_comparable,
    Full_comparable,
    Full,
    First_payment,
    Monthly,
	month
  };
  connectedCallback() {
    this.noOfMonths = this.noOfMonths ? `${this.noOfMonths}` : '1';
    if (this.foreignInvRec) {
      this.calculateInstallments();
      this.setRadioOptions();
    }
  }

  handleNext() {
    this.checkRadioSelection();
    if (!this.showErrorMessage) {
      this.calculateAmountPayable();
      this.setTableData();
      this.showPopup = true;
    }
  }

  setTableData() {
	var selectedPaymentLabel;
    if (this.selectedPayment === this.label.Monthly_comparable) {
	  selectedPaymentLabel = this.label.Monthly;
      this.tablecolumns = [
        {
          label: this.label.Method,
          fieldName: "selectedPayment",
        },
        {
          label: this.label.No_of_months,
          fieldName: "noOfMonths",
        },
        {
          label: this.label.Monthly_payable,
          fieldName: "monthlyPayable",
          type: 'showFormattedNumber'
        },
        {
          label: this.label.Total_amount,
          fieldName: "amount",
          type: 'showFormattedNumber'
        },
      ];
      this.tabledata = [
        {
          selectedPayment: selectedPaymentLabel,
          noOfMonths: this.noOfMonths,
          monthlyPayable: `${this.monthlyPayable}`,
          amount: `${this.totalAmount}`,
        },
      ];
    } else {
		if(this.selectedPayment === this.label.First_payment_comparable){
        selectedPaymentLabel = this.label.First_payment;
      }
      else if(this.selectedPayment === this.label.Full_comparable){
        selectedPaymentLabel = this.label.Full;
      }
      this.tablecolumns = [
        {
          label: this.label.Method,
          fieldName: "selectedPayment",
        },
        {
          label: this.label.Total_amount,
          fieldName: "amount",
          type: 'showFormattedNumber'
        },
      ];
      this.tabledata = [
        {
          selectedPayment: selectedPaymentLabel,
          amount: `${this.totalAmount}`,
        },
      ];
    }
  }

  handleBack() {
    const navigateBackEvent = new FlowNavigationBackEvent();
    this.dispatchEvent(navigateBackEvent);
  }

  handlePaymentSelection(event) {
    this.selectedPayment = event.detail.value;
    this.checkRadioSelection();
  }
  handleCloseModal() {
    this.showPopup = false;
  }
  checkRadioSelection() {
    this.isPicklistRequired = false;
    this.showErrorMessage = false;
    if (!this.selectedPayment) {
      this.showErrorMessage = true;
      this.errorMessage = this.label.Select_Payment_Method;
    } else if (
      this.hasFirstPayment &&
      this.selectedPayment === this.label.Monthly_comparable
    ) {
      this.showErrorMessage = true;
      this.errorMessage = this.label.Select_FirstOrFullPayment;
    } else if (this.selectedPayment === this.label.Monthly_comparable) {
      this.isPicklistRequired = true;
    }
  }
  handleModalConfirm() {
    this.showPopup = false;
    const nextNavigationEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(nextNavigationEvent);
  }
  handlePicklistChange(event) {
    this.noOfMonths = event.detail.val;
  }

  calculateAmountPayable() {
    let amount;
    const selectedPaymentOption = this.radioOptions.filter(
      (item) => item.value === this.selectedPayment
    );
    if (selectedPaymentOption && selectedPaymentOption.length) {
      if (selectedPaymentOption[0].value === this.label.Monthly_comparable) {
        amount = this.monthlyPayable * Number(this.noOfMonths);
      } else if (
        selectedPaymentOption[0].value === this.label.First_payment_comparable
      ) {
        amount = this.foreignInvRec.First_Payment__c;
      } else {
        amount = this.foreignInvRec.Outstanding_Amount_Due__c;
      }
    }

    this.totalAmount = amount;
  }

  setRadioOptions() {
    this.typeOfPayments.forEach((element) => {
      var tempObj = {};
      tempObj.id = element;
      tempObj.value = element;
      tempObj.show = false;
      if (
        element == this.label.First_payment_comparable &&
        this.foreignInvRec.First_Payment__c != null &&
        !this.foreignInvRec.First_Payment_Done__c
      ) {
        tempObj.amount = this.foreignInvRec.First_Payment__c;
        this.hasFirstPayment = true;
        tempObj.show = true;
        tempObj.type = this.label.First_payment;
      } else if (
        element == this.label.Monthly_comparable &&
        this.foreignInvRec.Monthly_Payable__c != null && !this.foreignInvRec.Auto_payment_plan__c
      ) {
        tempObj.amount = this.foreignInvRec.Monthly_Payable__c;
        this.monthlyPayable = this.foreignInvRec.Monthly_Payable__c;
        tempObj.amountLabel = this.label.month;
        tempObj.show = true;
        tempObj.type = this.label.Monthly;
        this.monthsList = this.monthsList.map((month) => {
          return {
            label: month,
            value: month,
          };
        });
        tempObj.dropDownOpts = this.monthsList;
        tempObj.required = true;
      } else if (element == this.label.Full_comparable) {
        tempObj.show = true;
        tempObj.type = this.label.Full;
        tempObj.amount = this.foreignInvRec.Outstanding_Amount_Due__c;
      }
      this.radioOptions.push(tempObj);
    });
  }

  calculateInstallments() {
    let noOfInstalments;
    const totalInstalments = this.foreignInvRec.Payment_Duration__c;
    const paidInstalments = this.foreignInvRec.Months_Paid__c;
    if (totalInstalments && paidInstalments) {
      noOfInstalments = totalInstalments - paidInstalments;
    } else {
      noOfInstalments = totalInstalments;
    }
    for (var i = 1; i <= noOfInstalments; i++) {
      this.monthsList.push(`${i}`);
    }
  }
}
import { api, LightningElement, track} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Congratulations from "@salesforce/label/c.Congratulations";
import loading_brs from "@salesforce/label/c.loading_brs";
import copy_of_payment_receipt_is_sent from "@salesforce/label/c.copy_of_payment_receipt_is_sent";
import getFIForConfirmation from '@salesforce/apex/BRS_ForeignInvestigationController.getFIForConfirmation';
import {ComponentErrorLoging} from "c/formUtility";
import Dasboard_Url from "@salesforce/label/c.AccountDashboard_comparable";
import { NavigationMixin } from 'lightning/navigation';
import Access_Account_Dashboard from '@salesforce/label/c.Access_Account_Dashboard';
import Outstanding_dues from "@salesforce/label/c.Outstanding_dues";
import Upcoming_dues_for_Investigation from "@salesforce/label/c.Upcoming_dues_for_Investigation";
import Monthly_payable from "@salesforce/label/c.Monthly_payable";
import Outstanding_Amount from "@salesforce/label/c.Outstanding_Amount";
import Next_installment from "@salesforce/label/c.Next_installment";
import Payment_towards from "@salesforce/label/c.Payment_towards";
import has_been_successfully_completed from "@salesforce/label/c.has_been_successfully_completed";
import account_dashboard_for_confirmation_of_payment from "@salesforce/label/c.account_dashboard_for_confirmation_of_payment";
import confirmationMessage_FI from "@salesforce/label/c.confirmationMessage_FI";

export default class Brs_foreignInvestigationConfirmation extends NavigationMixin(LightningElement) {
    @track successIcon = assetFolder + "/icons/successverification.png";
    @track successMessage;
    @track emailLinkText;
    @api emailId;
    @api businessemailId;
    @api phoneNumber;
    @api Id;
    @api noOfMonths;
    @track investigationDetails;
    @track compName = "brs_foreignInvestigationConfirmation";
    @track severity = "medium";
    @track showDuesTable = false;
    @track isLoading = false;
    @track tablecolumns = [];
    @track tabledata = [];

    label = {
        Congratulations,
        loading_brs,
        Dasboard_Url,
        Access_Account_Dashboard,
        Outstanding_dues,
        Upcoming_dues_for_Investigation,
        copy_of_payment_receipt_is_sent,
        Monthly_payable,
        Outstanding_Amount,
        Next_installment,
        Payment_towards,
        has_been_successfully_completed,
        account_dashboard_for_confirmation_of_payment,
		confirmationMessage_FI
    }

    connectedCallback() {
        this.getFiDetails();
    }

    updateEmailLinkText(){
      this.emailLinkText = this.confirmationMessage_FI;
     }

     setTableData(){
        this.tablecolumns = [{
          label: this.label.Next_installment,
          fieldName: 'nextInstallmentDate'
        },
        {
          label: this.label.Monthly_payable,
          fieldName: 'monthlyPayable',
          type: 'showFormattedNumber'
        },{
            label: this.label.Outstanding_Amount,
           fieldName: 'amount',
           type: 'showFormattedNumber'
        }];
        this.tabledata = [{
          nextInstallmentDate: this.investigationDetails.nextInstallmentDate ? this.investigationDetails.nextInstallmentDate: null,
          monthlyPayable: this.investigationDetails.monthlyPayableAmount ? `${this.investigationDetails.monthlyPayableAmount}`: null,
          amount: this.investigationDetails.outstandingAmount ? `${this.investigationDetails.outstandingAmount}` : null
        }];
    }

    goToAccountDashboard(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.label.Dasboard_Url
            }
        }, false);
    }

    getFiDetails(){
        this.isLoading = true;
        getFIForConfirmation({
            fIRecId:this.Id,
            noOfMonths:this.noOfMonths
          })
          .then(result => {
            if(result){
              this.investigationDetails = result;
              this.emailId = result.contactEmail;
              this.phoneNumber = result.contactPhone;
              this.businessemailId = result.businessEmail;
              this.showDuesTable = result.monthlyPlanPresent;
              this.setTableData();
              this.updateEmailLinkText();
              this.successMessage = `${this.label.Payment_towards} ${this.investigationDetails.fIName} ${this.label.has_been_successfully_completed}`;
            }
            this.isLoading = false;
          })
          .catch(error => {
            this.isLoading = false;
            ComponentErrorLoging(
                this.compName,
                "getFIForConfirmation",
                "",
                "",
                this.severity,
                error.message
            );
          })
    }
}
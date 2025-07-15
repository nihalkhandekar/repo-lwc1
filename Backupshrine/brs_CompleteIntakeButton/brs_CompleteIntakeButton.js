import { LightningElement,api,track,wire  } from 'lwc';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/commonPubSub';
import {
	CurrentPageReference
  } from "lightning/navigation";

  import { NavigationMixin } from 'lightning/navigation';
  import updateStatus from '@salesforce/apex/Brs_CompleteIntakeButton.updateStatus';
  import brs_BackofficeUrl from "@salesforce/label/c.brs_BackofficeUrl";

export default class Brs_CompleteIntakeButton extends NavigationMixin(
    LightningElement
) {
@api filingtype;
@api amendmenttype;
    @api spinner;
    @api businessfilingID;
    @api isBusinessFormation;
    @api workorderID;
    @api businessNameEntered;
    @api businessNameAvailable;
    @track showError = false;
    @track showbutton = true;
    @api subtype;
    @wire(CurrentPageReference) pageRef;
    completeIntake(){
        if(this.businessNameEntered && this.businessNameAvailable ){
            this.showError = false;
            this.goToSearchBusiness();
        } else {
         
            this.isBusinessFormation = false;
          
                this.showError = false;
                this.goToSearchBusiness();   
            
        }
    }
connectedCallback() {
    if(this.filingtype!=null && this.filingtype!=undefined && ( 
        this.filingtype =='Business Name Reservation' || this.filingtype =='Registration of Corporate Name' ||this.filingtype =='Registration of Name' || this.filingtype =='Name Change Amendment' || (this.filingtype == 'Reinstatement' && ( this.subtype == 'With Annual report & Name Change Amendment') || this.subtype == 'With Annual report' )
    || (this.filingtype == 'Revocation of dissolution' && (this.subtype == 'With Annual report & Name Change Amendment'  || this.subtype == 'With Name Change Amendment' || this.subtype == 'With Org & 1st report & Name Change Amendment') ))){
        this.showbutton = false;
    }else{
        this.showbutton = true;
    }
}
    goToSearchBusiness(){

        this.spinner = true;

        updateStatus({
            workorder: this.workorderID,
            businessFiling:this.businessfilingID ,
            isFormation: this.isBusinessFormation,
            businessName:this.businessNameEntered
          })
            .then((result) => {
                this.spinner = false;
                console.log("workorderId", this.workorderID);
                
                  const url = `${brs_BackofficeUrl}${this.workorderID}`;
                  window.location.href = url;
               
            })
            .catch((err) => {
                ComponentErrorLoging(
                  this.compName,
                  "handleChecklistRemoveConfirm",
                  "",
                  "",
                  this.severity,
                  err.message
                );
              this.hideSpinner();
            });
    }
    renderedCallback(){
        if (!this.pageRef) {
			this.pageRef = {};
			this.pageRef.attributes = {};
			this.pageRef.attributes.LightningApp = "LightningApp";
		  }
        registerListener("businessNameValidation", this.busNameValid, this);
    }
    busNameValid(det){
        console.log('business name entered '+ det.detail.busNameEntered);
        this.businessNameEntered =det.detail.busNameEntered;
        this.businessNameAvailable = det.detail.busNameAvailable;
        
    }
}
import { LightningElement, track, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import Search_Business from "@salesforce/label/c.Search_Business";
import SearchPin_Placeholder from "@salesforce/label/c.SearchPin_Placeholder";
import Reserved_Name_Found from "@salesforce/label/c.Reserved_Name_Found";
import Search_Again_Text from "@salesforce/label/c.Search_Again_Text";
import No_Reserved_Name_Found from "@salesforce/label/c.No_Reserved_Name_Found";
import No_Reserved_Name_Text from "@salesforce/label/c.No_Reserved_Name_Text";
import No_Results_Found from "@salesforce/label/c.No_Results_Found";
import getBusinessNameUsingPIN from "@salesforce/apex/brs_businessReservation.getBusinessNameUsingPIN";
import Enter_Pin from "@salesforce/label/c.Enter_Pin";
import Next from "@salesforce/label/c.Next";
import Back from "@salesforce/label/c.Back";
import { ComponentErrorLoging } from "c/formUtility";
import {
  FlowAttributeChangeEvent,
  FlowNavigationBackEvent,
  FlowNavigationNextEvent
} from "lightning/flowSupport";
import { fireEvent, registerListener } from "c/commonPubSub";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
export default class Brs_searchReservedName extends LightningElement {
  @wire(CurrentPageReference) pageRef;
  @api selectedBusiness;
  @track showNoResultsFound = false;
  @track resultsFound = false;
  @api selectedPin = "";
  @api reservedNames;
  @api businessname;
  @api accountID;
  @api oldBusinessname;
  @api oldAccountID;
  @track showError = false;
  @track pinNotSelected = false;
  @track isLoading = false;
  @track compName = 'brs_searchReservedName';
  label = {
    Search_Business,
    SearchPin_Placeholder,
    Reserved_Name_Found,
    Search_Again_Text,
    No_Reserved_Name_Found,
    No_Reserved_Name_Text,
    No_Results_Found,
    Enter_Pin,
    Next,
    Back
  };
  searchIcon = assetFolder + "/icons/searchIcon.svg";
  connectedCallback() {
    this.oldAccountID = this.accountID;
    this.oldBusinessname = this.businessname;
    if(this.selectedPin)
    {
      this.searchReservedName(); 
    }
    registerListener("flowvalidation", this.handleNotification, this);
  }
  handleNotification(event) {
    if (event.detail.isValid == undefined || event.detail.isValid) {
      return;
    }
    this.pinNotSelected = true;
  }
  @api
  validate() {
    if (!this.selectedPin || !this.selectedBusiness) {
      this.pinNotSelected = true;
    } else {
      this.pinNotSelected = false;
      const nextNavigationEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(nextNavigationEvent);
    }
  }
  handleBack() {
    const navigateBackEvent = new FlowNavigationBackEvent();
    this.dispatchEvent(navigateBackEvent);
  }
  setSearchData(event) {
    this.selectedPin = event.target.value;
    if (this.selectedPin !== "") {
      this.pinNotSelected = false;
    } else {
      this.pinNotSelected = true;
    }
  }
  handleSearchNames(event){
    if(event.keyCode === 13){
      this.searchReservedName();
    }
  }
  searchReservedName() {
    this.accountID = "";
    this.selectedBusiness = "";
    this.isLoading = true;
    if (this.selectedPin) {
      this.pinNotSelected = false;
      getBusinessNameUsingPIN({ pinNum: this.selectedPin })
        .then((data) => {
          if (data.length) {
            this.reservedNames = data;
            this.showNoResultsFound = false;
            this.resultsFound = true;
          } else {
            this.showNoResultsFound = true;
            this.resultsFound = false;
          }
          this.isLoading = false;
        })
        .catch((error) => {
          this.isLoading = false;
          ComponentErrorLoging(
            this.compName,
            "getBusinessNameUsingPIN",
            "",
            "",
            this.severity,
            error.message
          );
        });
    } else {
      this.pinNotSelected = true;
      this.isLoading = false;
    }
  }
  handleSelectedReservedName(event) {
    this.selectedBusiness = event.detail.screen.label;
    if(this.selectedBusiness){
      this.pinNotSelected = false;
    }
    this.businessname = event.detail.screen.label;
    this.accountID = event.detail.screen.name;
  }
}
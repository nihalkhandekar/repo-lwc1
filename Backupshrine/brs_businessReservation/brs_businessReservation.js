import { LightningElement, track, wire, api } from "lwc";
import getReservedNames from "@salesforce/apex/brs_businessReservation.getReservedNames";
import newBusiness from "@salesforce/label/c.New_Business";
import businessReservation from "@salesforce/label/c.Business_Reservation";
import No_Reserved_Name from "@salesforce/label/c.No_Reserved_Name";
import Search_Business from "@salesforce/label/c.Search_Business";
import No_Reserved_Name_Text from "@salesforce/label/c.No_Reserved_Name_Text";
import No_Associated_Name from "@salesforce/label/c.No_Associated_Name";
import Select_Reserved_Name from "@salesforce/label/c.Select_Reserved_Name";
import No_Reserved_Name_Found from "@salesforce/label/c.No_Reserved_Name_Found";
import Next from "@salesforce/label/c.Next";
import Back from "@salesforce/label/c.Back";
import {
  fireEvent,
  registerListener,
  unregisterAllListeners
} from "c/commonPubSub";
import {
  FlowAttributeChangeEvent,
  FlowNavigationNextEvent,
  FlowNavigationBackEvent,
  FlowNavigationPauseEvent,
  FlowNavigationFinishEvent
} from "lightning/flowSupport";
import { NavigationMixin } from "lightning/navigation";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
//import { CurrentPageReference } from "lightning/navigation";
export default class Brs_businessReservation extends LightningElement {
  @api reservedNames = [];
  @api selectedValue;
  @api noReservedNames;
  @api accountrecord;
  @api question;
  @api searchClicked = false;
  @api accountID;
  @api oldAccountID;
  @api oldBusinessName;
  @track haserror = false;
  @track businessNotSelected = false;
  @track showBusinessData = false;
  @track isLoading = true;
  label = {
    No_Reserved_Name,
    Search_Business,
    No_Reserved_Name_Text,
    No_Associated_Name,
    Select_Reserved_Name,
    No_Reserved_Name_Found,
    Next,
    Back
  };
  searchIcon = assetFolder + "/icons/searchIcon.svg";
  @api
  get businessname() {
    return this._businessname;
  }

  set businessname(value) {
    this._businessname = value;
  }
  connectedCallback() {
    this.oldAccountID = this.accountID;
    this.oldBusinessName = this.businessname;
    this.searchClicked = false;
    if (!this.pageRef) {
      this.pageRef = {};
      this.pageRef.attributes = {};
      this.pageRef.attributes.LightningApp = "LightningApp";
    }
    // For updating flow variable with the selected business name
    if (this.accountID) {
      this.reservedNames.forEach((row) => {
        if (row.accountID == this.accountID) {
          this.businessname = row.value;
        }
      });
    }
    registerListener("flowvalidation", this.handleNotification, this);
  }
  @wire(getReservedNames)
  wiredReservedNames({ error, data }) {
    if (Array.isArray(data)) {
      if (data.length === 0) {
        this.noReservedNames = true;
        this.isLoading = false;
      } else {
        let optionsValues = [];
        let dataLength = data.length;
        data.forEach((row)=>{
          if (row.name == newBusiness) {
            optionsValues.push({
              label: `<p class="smallBold">${row.label}</p>`,
              value: row.name,
              shortValue: row.shortValue,
              accountID: row.name,
              id:row.name
            });
          } else {
            optionsValues.push({
              label: `<p class="smallBold">${row.label}</p>`,
              value: row.label,
              shortValue: row.shortValue,
              accountID: row.name,
              id:row.name
            });
          }

          if (dataLength == 1 && row.name == newBusiness) {
            this.noReservedNames = true;
            this.showBusinessData = false;
          } else {
            this.noReservedNames = false;
            this.showBusinessData = true;
          }
        });
        this.reservedNames = optionsValues;
        this.isLoading = false;
      }
    } else {
      this.isLoading = false;
    }
  }

  changeHandler(event) {
    this.businessname = event.detail.value;
    this.accountID = event.detail.screen.accountID;
    if (
      this.businessname !== newBusiness ||
      this.businessname !== "" ||
      this.businessname
    ) {
      this.businessNotSelected = false;
    } else if (this.accountrecord !== null && this.businessname !== this.accountrecord.Name
    ) {
      this.businessNotSelected = false;
    }
    let account = this.accountrecord;
    account.Name = this.businessname;

    const attributeChangeEventAccount = new FlowAttributeChangeEvent(
      "accountrecord",
      account
    );
    this.dispatchEvent(attributeChangeEventAccount);
    const attributeChangeEvent = new FlowAttributeChangeEvent(
      "businessname",
      this.businessname
    );
    this.dispatchEvent(attributeChangeEvent);
  }
  handleNotification(event) {
    if (event.detail.isValid == undefined || event.detail.isValid == true)
      return;
    this.businessNotSelected = true;
  }
  @api
  validate() {
    if (this.searchClicked === false) {
      if (
        this.businessname === newBusiness ||
        this.businessname === "" ||
        !this.businessname
      ) {
        this.businessNotSelected = true;
      } else if(this.accountrecord !== undefined && this.businessname === this.accountrecord.Name)
      {
        this.businessNotSelected = true;
      } else {
        this.businessNotSelected = false;
        this.searchClicked = false;
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
      }
    }
  }

  handleBack() {
    const navigateBackEvent = new FlowNavigationBackEvent();
    this.dispatchEvent(navigateBackEvent);
  }
  searchForBusiness() {
    this.searchClicked = true;
    const searchClickedEvent = new FlowAttributeChangeEvent(
      "searchClicked",
      this.searchClicked
    );
    this.dispatchEvent(searchClickedEvent);
    const nextNavigationEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(nextNavigationEvent);
  }
}
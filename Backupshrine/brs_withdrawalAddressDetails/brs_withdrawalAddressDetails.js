import { LightningElement, track, wire, api } from 'lwc';
import Next from '@salesforce/label/c.Next';
import Back from '@salesforce/label/c.Back';
import {
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
} from 'lightning/flowSupport';
import go_to_summary from '@salesforce/label/c.go_to_summary';
import Withdrawal_Label from '@salesforce/label/c.Withdrawal_Label';
import Mailing_Address from '@salesforce/label/c.Mailing_Address';
import { NavigationMixin } from 'lightning/navigation';
import brs_FIlingLandingPage from "@salesforce/label/c.brs_FIlingLandingPage";
import AddressUnit_Apt from "@salesforce/label/c.AddressUnit_Apt";

export default class Brs_withdrawalAddressDetails extends NavigationMixin(LightningElement) {
    @api accountrecord;
    @api businessFiling;
    @api mailingAddress;
    @api getMailingDetails;
    @api mailingStreet;
    @api mailingCity;
    @api mailingZip;
    @api mailingState;
    @api mailingUnit;
    @api mailingCountry;
    @api mailingInternational;
    @api success;
    @api isGotoSummary = false;
    @api flowType;
    @api showGotoSummary = false;
    @api compname = 'brs_withdrawalAddressDetails';
    @api goToDashBoardPage = false;
    @track isNotCloseBusiness = false;
    @track accountId = "";
    @api mailingAddressFields = {
        ...this.initialAddressFields
    }

    @track initialAddressFields = {
        addressStreet: "",
        addressUnit: "",
        addressCity: "",
        addressState: "",
        addressZip: "",
        addressInternational: "",
        addressCountry: ""
    }

    label = {
        Next,
        Back,
        go_to_summary,
        Withdrawal_Label,
        Mailing_Address,
        brs_FIlingLandingPage,
        AddressUnit_Apt
    }

    connectedCallback() {
        this.isGotoSummary = false;
        this.isNotCloseBusiness = this.flowType !== this.label.Withdrawal_Label
        if (this.accountrecord) {
            var accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
            if (accRecValue) {
                this.accountId = accRecValue.Id;
            }
        }
        this.setMailingAddressFields();
    }
    handleBack() {
        if (this.goToDashBoardPage) {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: this.label.brs_FIlingLandingPage
                },
            });
        } else {
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }
    }

    handleMailingAdress() {
        const mailingAddressFields = this.template.querySelector("c-brs_address.mailingAddress");
        const mValidate = mailingAddressFields.validateaddress();
        return mValidate;
    }

    sendMailingAddressDetails() {
        const mailingAddressFields = this.template.querySelector("c-brs_address.mailingAddress");
        var maddress = JSON.parse(JSON.stringify(mailingAddressFields.getdata()));
        this.mailingStreet = maddress.street;
        this.mailingCity = maddress.city;
        this.mailingZip = maddress.zip;
        this.mailingState = maddress.state;
        this.mailingUnit = maddress.unit;
        this.mailingCountry = maddress.country;
        this.mailingInternational = maddress.internationalAddress;
    }

    setMailingAddressFields() {
        this.mailingAddressFields = {
            addressStreet: this.mailingStreet,
            addressUnit: this.mailingUnit,
            addressCity: this.mailingCity,
            addressState: this.mailingState,
            addressZip: this.mailingZip,
            addressCountry: this.mailingCountry,
            addressInternational: this.mailingInternational
        }
    };
    validate() {
        if (this.handleMailingAdress()) {
            this.sendMailingAddressDetails();
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
    goToSummaryPageWithOutConfirmation() {
        if (this.handleMailingAdress()) {
            this.sendMailingAddressDetails();
            this.isGotoSummary = true;
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
}
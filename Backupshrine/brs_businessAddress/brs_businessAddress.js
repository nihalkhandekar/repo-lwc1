import { LightningElement, api, track, wire } from 'lwc';
import { fireEvent, registerListener } from 'c/commonPubSub';
import { CurrentPageReference } from "lightning/navigation";
import Domestic from '@salesforce/label/c.Domestic';
import PrincipalOffice from '@salesforce/label/c.BRS_Location_PrincipalOffice';
import Jurisdiction from '@salesforce/label/c.BRS_Location_JurisdictionOffice';
import Mailing from '@salesforce/label/c.BRS_Location_MailingAddr';
import StateOfFormation from '@salesforce/label/c.BRS_Location_StateOfFormation';
import Same_As_Principal_Address from '@salesforce/label/c.Same_As_Principal_Address';
import US_address from "@salesforce/label/c.US_address";
import BRS_addresschange_flow_name_comparable from "@salesforce/label/c.BRS_addresschange_flow_name_comparable";
import Please_update_an_address_to_proceed from "@salesforce/label/c.Please_update_an_address_to_proceed";
import { isUndefinedOrNull } from "c/appUtility";
import Limited_Partnership_Comparable from "@salesforce/label/c.Limited_Partnership_Comparable";
import LLP from "@salesforce/label/c.LLP";
import AddressUnit_Apt from '@salesforce/label/c.AddressUnit_Apt';

export default class Brs_businessAddress extends LightningElement {
    @track stateMap ={"ALASKA":"AK",
    "ALABAMA":"AL",
    "ARKANSAS":"AR",
    "AMERICAN SAMOA":"AS",
    "ARIZONA":"AZ",
    "CALIFORNIA":"CA",
    "COLORADO":"CO",
    "CONNECTICUT":"CT",
    "DISTRICT OF COLUMBIA":"DC",
    "DELAWARE":"DE",
    "FLORIDA":"FL",
    "MICRONESIA":"FM",
    "GEORGIA":"GA",
    "GUAM":"GU",
    "HAWAII":"HI",
    "IOWA":"IA",
    "IDAHO":"ID",
    "ILLINOIS":"IL",
    "INDIANA":"IN",
    "KANSAS":"KS",
    "KENTUCKY":"KY",
    "LOUISIANA":"LA",
    "MASSACHUSETTS":"MA",
    "MARYLAND":"MD",
    "MAINE":"ME",
    "MARSHALL ISLANDS":"MH",
    "MICHIGAN":"MI",
    "MINNESOTA":"MN",
    "MISSOURI":"MO",
    "NORTHERN MARIANA ISLANDS":"MP",
    "MISSISSIPPI":"MS",
    "MONTANA":"MT",
    "NORTH CAROLINA":"NC",
    "NORTH DAKOTA":"ND",
    "NEBRASKA":"NE",
    "NEW HAMPSHIRE":"NH",
    "NEW JERSEY":"NJ",
    "NEW MEXICO":"NM",
    "NEVADA":"NV",
    "NEW YORK":"NY",
    "OHIO":"OH",
    "OKLAHOMA":"OK",
    "OREGON":"OR",
    "PENNSYLVANIA":"PA",
    "PUERTO RICO":"PR",
    "PALAU":"PW",
    "RHODE ISLAND":"RI",
    "SOUTH CAROLINA":"SC",
    "SOUTH DAKOTA":"SD",
    "TENNESSEE":"TN",
    "TEXAS":"TX",
    "UNITED STATES MINOR OUTLYING ISLANDS":"UM",
    "UTAH":"UT",
    "VIRGINIA":"VA",
    "U.S. VIRGIN ISLANDS":"VI",
    "VERMONT":"VT",
    "WASHINGTON":"WA",
    "WISCONSIN":"WI",
    "WEST VIRGINIA":"WV",
    "WYOMING":"WY",
    };
    @wire(CurrentPageReference) pageRef;
    @api accountrecord;
    @api addressStreet;
    @api addressStreet1;
    @api businessCity = '';
    @api businessState = '';
    @api businessZipcode = '';
    @api businessUnit = '';
    @api businessStreet = '';
    @api businessCountry = '';
    @api mailingCity = '';
    @api mailingZipcode = '';
    @api mailingStreet = '';
    @api mailingState = '';
    @api mailingUnit = '';
    @api mailingCountry = '';
    @api showMailingAddress;
    @api sameAsPrincipalCheckbox = false;
    @api sameAsTopPrincipalCheckbox = false;
    @api source = "Worker Portal";
    @track acceptPoBox = true;
    @track isAddreessChangeFlow = false;
    @track isJurisdictionLLPFlow = false;
    @track initialAddressFields = {
        addressStreet: "",
        addressUnit: "",
        addressCity: "",
        addressState: "",
        addressZip: "",
        addressCountry:""
    }
    @api jurisdictionScreen = false;
    @api showFirstCopyCheckBox = false;
    @api mailingAddressNotInCT = false;
    @api selectedStateOrTerritoryFormation = "";
    @api businessAddressFormat;
    @api mailingAddressFormat;
    @api businessInternationalAddress = "";
    @api mailingInternationalAddress = "";
    @api hideFirstCopyCheckBox;
    @track label1;
    @track label2;
    @api errorMessage;
    @track showErrorMessage = false;
    @track defaultState = "";
    @track defaultCountry = "";
    @track canBeOutSideUS = true;
    @track hideCopyPrincipalCheckBoxes = false;
    @api isUsAddress = "Yes";
    @track isInternationalAddress = false;
    @track showPrincipalCheckboxs = true;
    @api isMailingRequired;
    @api isPrincipalRequired;
    @api isJurisdictionRequired;
    @api flowName;
    @api hasTwoAddressScreens = false;
    @api isAddressChangedInFirstScreen = false;

    label = {
        Domestic,
        PrincipalOffice,
        Jurisdiction,
        Mailing,
        StateOfFormation,
        Same_As_Principal_Address,
        BRS_addresschange_flow_name_comparable,
        Please_update_an_address_to_proceed,
        Limited_Partnership_Comparable,
        LLP,
        AddressUnit_Apt
    };

    @api principalAddressFields = {
        ...this.initialAddressFields
    }
    @api mailingAddressFields = {
        ...this.initialAddressFields
    }

    @api checkboxTitle = this.label.Same_As_Principal_Address;

    @track principalAddressCheckboxOptions = [];
    @track topPrincipalAddressCheckboxOptions = [];

    get isPrincipalAddressChecked() {
        if (this.sameAsPrincipalCheckbox) {
            return [this.checkboxTitle];
        }
        return "";
    }

    get isTopPrincipalAddressChecked() {
        if (this.sameAsTopPrincipalCheckbox) {
            return [this.label.Same_As_Principal_Address];
        }
        return "";
    }

    get isBusinessUsAddress() {
        if (isUndefinedOrNull(this.businessAddressFormat)) {
            return this.businessAddressFormat === US_address;
        }
    }

    get isMailingUSAddress() {
        return this.mailingAddressFormat === US_address;
    }

    @api validate() {
        var principalAddress = this.template.querySelector("c-brs_address.principalAddress");
        var paddress = JSON.parse(JSON.stringify(principalAddress.getdata()));
        let pError = true;
        if (this.isJurisdictionRequired) {
            pError = principalAddress.validateaddress();
        }
        let hasError;
        let addressNotUpdated = false;
        if (this.isAddreessChangeFlow && this.hasTwoAddressScreens && !this.jurisdictionScreen) {
            this.isAddressChangedInFirstScreen = !this.isAddreeNotChanged();
        } else if (this.isAddreessChangeFlow && ((!this.hasTwoAddressScreens && !this.jurisdictionScreen) || (this.jurisdictionScreen && !this.isAddressChangedInFirstScreen))) {
            addressNotUpdated = this.isAddreeNotChanged();
        }
        let mailingAddress;
        let maddress;
        if (this.showMailingAddress) {
            mailingAddress = this.template.querySelector("c-brs_address.mailingAddress");
            maddress = JSON.parse(JSON.stringify(mailingAddress.getdata()));
            this.mailingAddressFormat = maddress.countryFormat;
        }

        if (this.showMailingAddress) {
            let mError = true;
            if (this.isMailingRequired) {
                mError = mailingAddress.validateaddress();
            }
            hasError = !pError || !mError;
            this.mailingCity = maddress.city;
            this.mailingZipcode = maddress.zip;
            this.mailingStreet = maddress.street;
            this.mailingState = maddress.state;
            this.mailingUnit = maddress.unit;
            this.mailingCountry = maddress.country;
            this.mailingInternationalAddress = maddress.internationalAddress;
        } else {
            hasError = !pError;
        }
        this.businessCity = paddress.city;
        this.businessState = paddress.state;
        this.businessZipcode = paddress.zip;
        this.businessStreet = paddress.street;
        this.businessUnit = paddress.unit;
        this.businessCountry = paddress.country;
        this.businessInternationalAddress = paddress.internationalAddress;
        this.businessAddressFormat = paddress.countryFormat;
        registerListener('flowvalidation', this.handleNotification, this);
        if (hasError || addressNotUpdated) {
            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: false }
            });
            return { isValid: false, errorMessage: "" };
        } else {
            if (this.jurisdictionScreen && (this.defaultState || this.defaultCountry)) {               
                if(this.showMailingAddress && !this.isMailingRequired && !(maddress.street || maddress.unit || maddress.city || maddress.zip || maddress.internationalAddress)){
                    this.mailingState = "";
                    this.mailingCountry = "";
                }
                
                if(!(paddress.street || paddress.unit || paddress.city || paddress.zip || paddress.internationalAddress) && !this.isJurisdictionRequired){
                    this.businessState = "";
                    this.businessCountry = "";
                }
            }
            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: true }
            });
            return { isValid: true };
        }

    }

    connectedCallback() {
        //Jurisdiction screen setting dafault address state and changing labels
        this.isAddreessChangeFlow = (this.flowName === this.label.BRS_addresschange_flow_name_comparable);
        this.isPrincipalRequired = true;
        if (isUndefinedOrNull(this.showMailingAddress)) {
            this.showMailingAddress = true;
        }
        if (isUndefinedOrNull(this.isMailingRequired)) {
            this.isMailingRequired = true;
        }
        if (isUndefinedOrNull(this.isJurisdictionRequired)) {
            this.isJurisdictionRequired = true;
        }
        if (this.jurisdictionScreen) {
            this.label1 = this.label.Jurisdiction;
            this.label2 = this.label.StateOfFormation;
            this.defaultState = this.businessState && this.businessState.length === 2 ? this.businessState : this.stateMap[this.businessState.toUpperCase()];
            this.defaultCountry = this.businessCountry ? this.businessCountry.toUpperCase():"";
        } else {
            this.label1 = this.label.PrincipalOffice;
            this.label2 = this.label.Mailing;
        }
        if (this.accountrecord) {
            var accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
            if (accRecValue) {
                this.accountId = accRecValue.Id;
                if (accRecValue.Citizenship__c == this.label.Domestic) {
                    //When business type is Limited partnership we need same LLP functionality so overwriting business type
                    if (accRecValue.Business_Type__c === this.label.Limited_Partnership_Comparable) {
                        accRecValue.Business_Type__c = this.label.LLP;
                    }
                    if (accRecValue.Business_Type__c == 'LLP') {
                        this.showMailingAddress = false;
                    } else {
                        this.showMailingAddress = true;
                        this.setMailingAddressFields();
                    }
                } else {
                    if (this.showMailingAddress == true) {
                        this.setMailingAddressFields();
                    }
                }
                this.checkPrincipalCheckBoxes(accRecValue);
            }
        }
        this.setPrincipalAddressFields();


        if (!this.pageRef) {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
        }

        this.principalAddressCheckboxOptions = [{
            label: this.checkboxTitle,
            value: this.checkboxTitle
        }];

        this.topPrincipalAddressCheckboxOptions = [{
            label: this.checkboxTitle,
            value: this.checkboxTitle
        }];
        this.principalCheckBoxStatus();
        registerListener('flowvalidation', this.handleNotification, this);
    }

    isAddreeNotChanged(){        
        let mailingNotChanged = true;
        let principalNotChanged = true;
        if (this.accountrecord) {
            var accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
            if (this.showMailingAddress) {
                let mailingAddress = this.template.querySelector("c-brs_address.mailingAddress");
                let maddress = JSON.parse(JSON.stringify(mailingAddress.getdata()));
                let mailingStreet, mailingUnit, mailingCity, mailingState, mailingZipcode, mailingCountry, mailingInternationalAddress;
                if (this.jurisdictionScreen && !this.isJurisdictionLLPFlow) {
                    mailingStreet = accRecValue.Mailing_Jurisdiction_BusinessStreet__c ? accRecValue.Mailing_Jurisdiction_BusinessStreet__c : "";
                    mailingUnit= accRecValue.Mailing_Jurisdiction_BusinessUnit__c ? accRecValue.Mailing_Jurisdiction_BusinessUnit__c : "";
                    mailingCity = accRecValue.Mailing_Jurisdiction_BusinessCity__c ? accRecValue.Mailing_Jurisdiction_BusinessCity__c : "";
                    mailingState = accRecValue.Mailing_Jurisdiction_BusinessState__c ? accRecValue.Mailing_Jurisdiction_BusinessState__c : "";
                    mailingZipcode = accRecValue.Mailing_Jurisdiction_BusinessZipCode__c ? accRecValue.Mailing_Jurisdiction_BusinessZipCode__c : "";
                    mailingCountry = accRecValue.Mailing_Jurisdiction_Country__c ? accRecValue.Mailing_Jurisdiction_Country__c : "";
                    mailingInternationalAddress = accRecValue.Mail_Jurisdiction_International_address__c ? accRecValue.Mail_Jurisdiction_International_address__c : "";                  
                } else {
                    mailingStreet = accRecValue.ShippingStreet ? accRecValue.ShippingStreet : "";
                    mailingUnit = accRecValue.Shipping_Unit__c ? accRecValue.Shipping_Unit__c : ""; // need confirmation
                    mailingCity = accRecValue.ShippingCity ? accRecValue.ShippingCity : "";
                    mailingState = accRecValue.ShippingState ? accRecValue.ShippingState : "";
                    mailingZipcode = accRecValue.ShippingPostalCode ? accRecValue.ShippingPostalCode : "";
                    mailingCountry = accRecValue.ShippingCountry ? accRecValue.ShippingCountry : "";
                    mailingInternationalAddress = accRecValue.Mailing_International_Address__c ? accRecValue.Mailing_International_Address__c : "";
                }
               
                let allOtherMailingFieldsSame = (mailingStreet === maddress.street && mailingUnit === maddress.unit && mailingCity === maddress.city && mailingZipcode === maddress.zip && mailingInternationalAddress === maddress.internationalAddress)
                if(this.defaultState && !this.isJurisdictionLLPFlow){
                    mailingNotChanged = (allOtherMailingFieldsSame && mailingCountry === maddress.country);
                } else if(this.defaultCountry) { 
                    mailingNotChanged = (allOtherMailingFieldsSame && mailingState === maddress.state);
                } else{
                    mailingNotChanged = (allOtherMailingFieldsSame && mailingState === maddress.state && mailingCountry === maddress.country);
                }
                
            }
            var principalAddress = this.template.querySelector("c-brs_address.principalAddress");
            var paddress = JSON.parse(JSON.stringify(principalAddress.getdata()));
            let businessStreet, businessUnit, businessCity, businessState, businessZipcode, businessCountry, businessInternationalAddress;
            if (this.jurisdictionScreen) {
                businessStreet = accRecValue.Office_Jurisdiction_BusinessStreet__c ? accRecValue.Office_Jurisdiction_BusinessStreet__c : "";
                businessUnit = accRecValue.Office_Jurisdiction_BusinessUnit__c ? accRecValue.Office_Jurisdiction_BusinessUnit__c : "";
                businessCity= accRecValue.Office_Jurisdiction_BusinessCity__c ? accRecValue.Office_Jurisdiction_BusinessCity__c : "";
                businessState= accRecValue.Office_Jurisdiction_BusinessState__c ? accRecValue.Office_Jurisdiction_BusinessState__c : "";
                businessZipcode = accRecValue.Office_Jurisdiction_BusinessZipCode__c ? accRecValue.Office_Jurisdiction_BusinessZipCode__c : "";
                businessCountry = accRecValue.Office_in_Jurisdiction_Country__c ? accRecValue.Office_in_Jurisdiction_Country__c : "";
                businessInternationalAddress = accRecValue.Jurisdiction_International_address__c ? accRecValue.Jurisdiction_International_address__c : "";
            } else {
                businessStreet = accRecValue.BillingStreet ? accRecValue.BillingStreet : "";
                businessUnit = accRecValue.Billing_Unit__c ? accRecValue.Billing_Unit__c : "";
                businessCity = accRecValue.BillingCity ? accRecValue.BillingCity : "";
                businessState = accRecValue.BillingState ? accRecValue.BillingState : "";
                businessZipcode = accRecValue.BillingPostalCode ? accRecValue.BillingPostalCode : "";
                businessCountry = accRecValue.BillingCountry ? accRecValue.BillingCountry : "";
                businessInternationalAddress = accRecValue.Principle_Office_International_Address__c ? accRecValue.Principle_Office_International_Address__c : "";
            }
               
            let allOtherBusinessFieldsSame = (businessStreet === paddress.street && businessUnit === paddress.unit && businessCity === paddress.city && businessZipcode === paddress.zip && businessInternationalAddress === paddress.internationalAddress);

            if (this.defaultState) {
                principalNotChanged = (allOtherBusinessFieldsSame && businessCountry === paddress.country);
            } else if (this.defaultCountry) {
                principalNotChanged = (allOtherBusinessFieldsSame && businessState === paddress.state);
            } else {
                principalNotChanged = (allOtherBusinessFieldsSame && businessState === paddress.state && businessCountry === paddress.country);
            }
        }
        return !(!mailingNotChanged || !principalNotChanged);
    }

    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true) {


        } else {
            var principalAddress = this.template.querySelector("c-brs_address.principalAddress");
            var maddress;
            if (this.showMailingAddress === true && this.isMailingRequired === true) {
                var mailingAddress = this.template.querySelector("c-brs_address.mailingAddress");
                mailingAddress.validateaddress();
            }
            principalAddress.validateaddress();
            if(this.flowName === this.label.BRS_addresschange_flow_name_comparable && !this.isAddressChangedInFirstScreen){
                this.showErrorMessage = true;
                this.errorMessage = this.label.Please_update_an_address_to_proceed;
            }
        }
    }

    principalCheckBoxStatus() {
        /*showFirstCopyCheckBox true case copying principal address that filled 
        in previous screen, so disable checkbox not needed*/
        if (!this.businessStreet && !this.businessZipcode && (!this.businessInternationalAddress || 
            !this.businessCountry) && !this.sameAsPrincipalCheckbox && !this.showFirstCopyCheckBox) {
            this.principalAddressCheckboxOptions = [{
                label: this.checkboxTitle,
                value: this.checkboxTitle,
                isDisabled: true
            }];
        }
    }


    // show or hide principal checkboxes based on principal address
    checkPrincipalCheckBoxes(accRecValue) {
        if (this.jurisdictionScreen && accRecValue.Business_Type__c !== "LLP") {
            this.isInternationalAddress = this.isUsAddress !== "Yes";
            this.canBeOutSideUS = false;
            if (this.isUsAddress === "Yes" && (!accRecValue.BillingStreet || accRecValue.BillingState !== this.businessState)) {
                this.showPrincipalCheckboxs = false;
            } else if (this.isUsAddress !== "Yes" && accRecValue.BillingCountry !== this.businessCountry) {
                this.showPrincipalCheckboxs = false;
            }
        } else if (this.jurisdictionScreen && accRecValue.Business_Type__c === "LLP") {
            this.label2 = this.label.Mailing;
            if (this.isUsAddress === "Yes") {
                this.isInternationalAddress = false;
            } else {
                this.isInternationalAddress = true;
            }
            this.isJurisdictionLLPFlow = true;
        }
    }

    onCopyPrincipalAddressCheck(event) {
        this.showErrorMessage = false;
        var principalAddress = this.template.querySelector("c-brs_address.principalAddress");
        var paddress = JSON.parse(JSON.stringify(principalAddress.getdata()));
        if (this.accountrecord) {
            var accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
        }
        if (!this.sameAsPrincipalCheckbox) {
            this.sameAsPrincipalCheckbox = true;
            // jurisdictionScreen with LLC flow we need to copy principal address
            if (this.jurisdictionScreen && accRecValue && accRecValue.Business_Type__c === "LLC") {
                this.mailingStreet = accRecValue.BillingStreet ? accRecValue.BillingStreet:"";
                this.mailingCity = accRecValue.BillingCity ?accRecValue.BillingCity:"";
                this.mailingUnit = accRecValue.Billing_Unit__c ? accRecValue.Billing_Unit__c : "";
                this.mailingState = accRecValue.BillingState ? accRecValue.BillingState:"";
                if(this.mailingState.length >2){
                    this.mailingState = this.stateMap[this.mailingState.toUpperCase()];
                }
                this.mailingZipcode = accRecValue.BillingPostalCode ? accRecValue.BillingPostalCode :"";                
                this.mailingInternationalAddress = accRecValue.Principle_Office_International_Address__c ? accRecValue.Principle_Office_International_Address__c:"";
                this.mailingCountry = accRecValue.BillingCountry ? accRecValue.BillingCountry:"";
            } else {
                this.mailingStreet = paddress.street;
                this.mailingCity = paddress.city;
                this.mailingUnit = paddress.unit;
                this.mailingState = paddress.state;
                if(this.mailingState.length >2){
                    this.mailingState = this.stateMap[this.mailingState.toUpperCase()];
                }
                this.mailingZipcode = paddress.zip;
                this.mailingAddressFormat = paddress.countryFormat;
                this.mailingInternationalAddress = paddress.internationalAddress;
                this.mailingCountry = paddress.country;
            }
        } else {
            this.sameAsPrincipalCheckbox = false;
            this.mailingStreet = "";
            this.mailingCity = "";
            this.mailingStreet = "";
            this.mailingUnit = "";
            this.mailingZipcode = "";
            this.mailingInternationalAddress = "";
            this.mailingCountry = "";
        }
        this.setMailingAddressFields();
        var mailingAddress = this.template.querySelector("c-brs_address.mailingAddress");
        if (mailingAddress && this.sameAsPrincipalCheckbox) {
            setTimeout(() => {
                mailingAddress.validateaddress();
            }, 500);
        }
    }

    onCopyTopPrincipalAddressCheck() {
        this.showErrorMessage = false;
        var accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
        if (!this.sameAsTopPrincipalCheckbox) {
            this.sameAsTopPrincipalCheckbox = true;
            this.businessStreet = accRecValue.BillingStreet ? accRecValue.BillingStreet:"";
            this.businessCity = accRecValue.BillingCity ? accRecValue.BillingCity:"";
            this.businessUnit = accRecValue.Billing_Unit__c ? accRecValue.Billing_Unit__c : "";
            this.businessState = accRecValue.BillingState? accRecValue.BillingState:"";
            if(this.businessState.length >2){
                this.businessState = this.stateMap[this.businessState.toUpperCase()];
            }
            this.businessZipcode = accRecValue.BillingPostalCode ? accRecValue.BillingPostalCode:"";
            this.businessInternationalAddress = accRecValue.Principle_Office_International_Address__c ? accRecValue.Principle_Office_International_Address__c:"";
            this.businessCountry = accRecValue.BillingCountry ? accRecValue.BillingCountry:"";
        } else {
            this.sameAsTopPrincipalCheckbox = false;
            this.businessStreet = "";
            this.businessCity = "";
            this.businessStreet = "";
            this.businessUnit = "";
            this.businessZipcode = "";
            this.businessInternationalAddress = "";
            this.businessCountry = "";
        }
        this.setPrincipalAddressFields();
        var businessAddress = this.template.querySelector("c-brs_address.principalAddress");
        if (businessAddress && this.sameAsTopPrincipalCheckbox) {
            setTimeout(() => {
                businessAddress.validateaddress();
            }, 500);
        }
    }

    setMailingAddressFields() {
        if(this.mailingState.length >2){
            this.mailingState = this.stateMap[this.mailingState.toUpperCase()];
        }

        this.mailingAddressFields = {
            addressStreet: this.mailingStreet,
            addressUnit: this.mailingUnit,
            addressCity: this.mailingCity,
            addressState: this.mailingState,
            addressZip: this.mailingZipcode,
            addressCountryFormat: this.mailingAddressFormat,
            addressInternational: this.mailingInternationalAddress,
            addressCountry: this.mailingCountry
        }
    }

    setPrincipalAddressFields() {

        if(this.businessState.length >2){
            this.businessState = this.stateMap[this.businessState.toUpperCase()];
        }
        this.principalAddressFields = {
            addressStreet: this.businessStreet,
            addressUnit: this.businessUnit,
            addressCity: this.businessCity,
            addressState: this.businessState,
            addressZip: this.businessZipcode,
            addressCountryFormat: this.businessAddressFormat,
            addressInternational: this.businessInternationalAddress,
            addressCountry: this.businessCountry
        }
    }

    onMailingAddressChange(){        
        this.showErrorMessage = false;
    }

    onPrincipalAddressChange(event) {
        this.showErrorMessage = false;
        if (!this.showFirstCopyCheckBox) {
            var address = JSON.parse(JSON.stringify(event.detail));
            this.sameAsPrincipalCheckbox = false;
            let isChecked = false;
            let isDisabled = false;
            if ((address.street && address.city && address.state && address.zip &&
                (address.zip.length === 5 || address.zip.length === 10)) ||
                (address.internationalAddress !== "" && address.country !== "")) {
                isDisabled = false;
                isChecked = false;
            } else {
                isDisabled = true;
                isChecked = false;
            }
            this.principalAddressCheckboxOptions = [{
                ...this.principalAddressCheckboxOptions[0],
                isChecked,
                isDisabled
            }];
        }
    }
}
import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import getStates from '@salesforce/apex/brs_contactDetailPage.getStates';
import getCountries from '@salesforce/apex/BRS_Utility.getCountries';
import {
    getAuthIdKeys
} from 'c/smartStreetUtil';

import {
    getAddressSuggestions,
} from 'c/melissaAddressUtil';
import { ComponentErrorLoging } from "c/formUtility";
import ADDUPD_ADDRESS from '@salesforce/label/c.ADDUPD_Address';
import ADDUPD_CITY from '@salesforce/label/c.ADDUPD_City';
import ADDUPD_STATE from '@salesforce/label/c.ADDUPD_State';
import ADDUPD_UNIT_APT from '@salesforce/label/c.ADDUPD_Unit_Apt';
import ADDUPD_ZIP_CODE from '@salesforce/label/c.ADDUPD_Zip_Code';
import API_US_SMARTY_STREET_URL from '@salesforce/label/c.API_US_SMARTY_STREET_URL';
import API_US_SMARTY_STREET_AUTHID from '@salesforce/label/c.API_US_SMARTY_STREET_AUTHID';
import API_US_SMARTY_STREET_AUTH_TOKEN from '@salesforce/label/c.API_US_SMARTY_STREET_AUTH_TOKEN';
import API_US_SMART_STREET_SITEKEY from '@salesforce/label/c.API_US_SMART_STREET_SITEKEY';
import ADDUPD_ADDMandatory from '@salesforce/label/c.ADDUPD_ADDMandatory';
import ADDUPD_CityMandatory from '@salesforce/label/c.ADDUPD_CityMandatory';
import ADD_Address from '@salesforce/label/c.ADD_Address';
import ADD_City from '@salesforce/label/c.ADD_City';
import ADD_State from '@salesforce/label/c.ADD_State';
import ADD_Zip from '@salesforce/label/c.ADD_Zip';
import ADD_Zip_Pattern_Error from '@salesforce/label/c.ADD_Zip_Pattern_Error';
import ADD_Addr_Field_Placeholder from '@salesforce/label/c.ADD_Addr_Field_Placeholder';
import ADD_City_Field_Placeholder from '@salesforce/label/c.ADD_City_Field_Placeholder';
import Address_POBox_Error from "@salesforce/label/c.Address_POBox_Error";
import US_address from "@salesforce/label/c.US_address";
import US_addressLabel from "@salesforce/label/c.US_addressLabel";
 import ADD_Int_Addr_Label_text from "@salesforce/label/c.ADD_Int_Addr_Label_text";
import ADD_Int_Addr_Label from "@salesforce/label/c.ADD_Int_Addr_Label";
import Address_Format from "@salesforce/label/c.Address_Format";
import United_States from '@salesforce/label/c.United_States';
import ADDUPD_CountryMandatory from '@salesforce/label/c.ADDUPD_CountryMandatory';
import ADDUPD_CountryLabel from '@salesforce/label/c.ADDUPD_CountryLabel';

export default class Dmv_address extends LightningElement {
    @track addressStreet = '';
    @track addressUnit = '';
    @track addressCity = '';
    @track addressState = '';
    @track addressZip = '';
    @track addressDropdown = [];
    @track addressInternational = '';
    @track stateReadOnly = false;
    @track countryReadOnly = false;
    @track stateOptions = [];
    @track countryOptions = [{
        label: US_addressLabel,
        value: US_address
    },
    {
        label: ADD_Int_Addr_Label,
        value: ADD_Int_Addr_Label
    }
    ];
    @track cityOptions = [];
    @track originalCities = [];
    @track hasDefaultState = false;
    @track _disabled = false;
    @api source = 'community';
    @api variant;
    @api compname = 'brs_address';
    @api addressType = "";
    @track addressClass = "slds-col slds-size_1-of-1 slds-large-size_8-of-12 formCol"
    @track aptClass = "slds-col slds-size_1-of-1 slds-large-size_4-of-12 formCol inputForm"
    @track cityClass = "slds-col slds-size_1-of-1 slds-large-size_5-of-12 formCol"
    @track stateClass = "slds-col slds-size_1-of-1 slds-large-size_3-of-12 inputForm formCol"
    @track countryClass = "slds-col slds-size_1-of-1 slds-large-size_6-of-12 inputForm formCol"
    @track zipClass = "slds-col slds-size_1-of-1 slds-large-size_4-of-12 formCol inputForm"
    @track fieldsWrapperClass = "slds-grid slds-wrap slds-gutters slds-grid_align-center formRow"
    @track defaultStateValue;
    @track defaultCountryValue;
    @track streetHasError = '';
    @track countryHasError = '';
    @track cityHasError = '';
    @track stateHasError = '';
    @track zipHasError = '';
    @track internationalHasError = '';
    @track isFieldRequired = true;
    @track unitLabel;
    @track hasPOBOX = false;
    @track retainedresadd;
    @api acceptPo = false;
    @api canBeOutsideUs = false;
    @api addresschanges;
    @api callonsetvalues = false;
    @track addressCountryFormat = US_address;
    @track lwcName = 'brs_address';
    @track countriesList = [];
    @api set setRetainedAddress(val) {
        if (val) {
            this.retainedresadd = val;
            if (this.retainedresadd && ((this.retainedresadd.addressStreet && this.retainedresadd.addressStreet.trim()) || this.retainedresadd.addressUnit || this.retainedresadd.addressCity || this.retainedresadd.addressState || this.retainedresadd.addressZip)) {
                var streetValue = this.retainedresadd.addressStreet ? this.retainedresadd.addressStreet.replace(/[^a-zA-Z0-9]/g, "").toUpperCase() :"";
                var hasPOBOX = streetValue.includes("POBOX") ? true : false;
                this.hasPOBOX = (hasPOBOX && !this.acceptPo) ? true : false;

                this.addressStreet = this.retainedresadd.addressStreet;
                this.addressUnit = this.retainedresadd.addressUnit;
                this.addressCity = this.retainedresadd.addressCity;
                this.addressState = this.defaultStateValue ? this.defaultStateValue : this.retainedresadd.addressState;
                this.addressZip = this.retainedresadd.addressZip;
                this.addressCountryFormat = US_address;
                this.addressCountry = this.labels.United_States;
                this.addressInternational = "";
                setTimeout(() => {
                    if (this._disabled) {
                        this.validateaddress();
                    }
                }, 50);
            } else if (this.retainedresadd && this.retainedresadd.addressInternational) {
                this.addressCountryFormat = ADD_Int_Addr_Label;
                this.addressInternational = this.retainedresadd.addressInternational;
                this.addressCountry = this.retainedresadd.addressCountry.toUpperCase();
                this.addressStreet = "";
                this.addressUnit = "";
                this.addressCity = "";
                this.addressState = "";
                this.addressZip = "";
                setTimeout(() => {
                    if (this._disabled) {
                        this.validateaddress();
                    }
                }, 50);
            } else {
                this.addressStreet = "";
                this.addressUnit = "";
                this.addressCity = "";
                this.addressDropdown = [];
                this.addressState = this.hasDefaultState ? this.defaultStateValue :"";
                this.addressZip = "";
                this.addressCountry = this.defaultCountryValue ? this.defaultCountryValue :"";
                this.addressInternational = "";
                let combobox = this.template.querySelectorAll('.address-country');
                if(combobox && !this.defaultCountryValue){
                combobox.forEach(field => {
                    field.value = "";
                });
                }
            }
            if(this.callonsetvalues){
              this.handlefieldchange();
             }
        }
    }
    get setRetainedAddress() {
        return this.retainedresadd;
    }
    @api retainedmailadd;
    @api autocomplete = false;
    @api isInternationalAddress = false;
    @api set defaultState(val) {
        if (val) {
            this.hasDefaultState = true;
            this.defaultStateValue = val;
            this.addressState = val;
            this.stateReadOnly = true;
        }
    }

    get defaultState() {
        return this.addressState;
    }

    @api set defaultCountry(val) {
        if (val) {
            this.addressCountry = val;
            this.countryReadOnly = true;
            this.defaultCountryValue = val;
        }
    }

    get defaultCountry() {
        return this.addressCountry;
    }

    @api set disabled(value) {
        if (this.normalizeBoolean(value)) {
            this._disabled = true;
        } else {
            this._disabled = false;
        }
    }

    @api get unitlabel() {
        return this.unitLabel;
    }

    set unitlabel(val) {
        this.unitLabel = val;
    }


    @api get fieldreq() {
        return this.isFieldRequired;
    }

    @api isreadonly;

    set fieldreq(val) {
        this.isFieldRequired = val ? true : false;
        if (!val) {
            this.labels = {
                ...this.labels,
                ADDUPD_ADDRESS: ADDUPD_ADDRESS.slice(0, -1),
                ADDUPD_CITY: ADDUPD_CITY.slice(0, -1),
                ADDUPD_STATE: ADDUPD_STATE.slice(0, -1),
                ADDUPD_ZIP_CODE: ADDUPD_ZIP_CODE.slice(0, -1),
                ADD_Int_Addr_Label: this.labels.ADD_Int_Addr_Label.slice(0, -1),
                ADDUPD_CountryLabel: ADDUPD_CountryLabel.slice(0, -1)
            }
        }
    }

    get disabled() {
        return this._disabled;
    }

    get isStateReadOnly() {
        return (this.stateReadOnly || this._disabled || this.isreadonly);
    }

    get isCountryReadOnly() {
        return (this.countryReadOnly || this._disabled || this.isreadonly);
    }

    that = this;

    updateCityPicklist() {
        if (this.originalCities) {
            this.originalCities = Array.from(this.originalCities);
            this.cityOptions = this.originalCities.map(city => {
                return {
                    label: city.City__c,
                    value: city.City__c,
                    Tax_Town__c: city.Tax_Town__c,
                    DMV_Multi_Town__c: city.DMV_Multi_Town__c
                };
            })
        }
    }

    @track labels = {
        ADDUPD_ADDRESS,
        ADDUPD_CITY,
        ADDUPD_STATE,
        ADDUPD_UNIT_APT,
        ADDUPD_ZIP_CODE,
        API_US_SMARTY_STREET_URL,
        API_US_SMARTY_STREET_AUTHID,
        API_US_SMARTY_STREET_AUTH_TOKEN,
        API_US_SMART_STREET_SITEKEY,
        ADDUPD_ADDMandatory,
        ADDUPD_CityMandatory,
        ADD_Address,
        ADD_City,
        ADD_State,
        ADD_Zip,
        ADD_Zip_Pattern_Error,
        ADD_Addr_Field_Placeholder,
        ADD_City_Field_Placeholder,
        Address_POBox_Error,
        Address_Format,
        ADD_Int_Addr_Label: ADD_Int_Addr_Label + "*",
        ADDUPD_CountryMandatory,
        ADDUPD_CountryLabel,
        United_States
    }

    get isCityPicklist() {
        return false;
    }

    get isUSCountry() {
        return this.addressCountryFormat === US_address;
    }


    connectedCallback() {
        this.getStatesList();
        this.getCountriesList();
        if(this.addressType){
            //when ever address type is there we are splitting "International address" and changing to "international {addressType} address"
            const internationalAddressLabel = this.labels.ADD_Int_Addr_Label.split(" ");
            const internationalAddress = internationalAddressLabel[0]+" "+(this.addressType).toLowerCase( )+" "+internationalAddressLabel[1];
            this.labels.ADDUPD_ADDRESS = this.labels.ADDUPD_ADDRESS.toLowerCase();
            this.labels = {
                ...this.labels,
                ADDUPD_ADDRESS: `${this.addressType} ${this.labels.ADDUPD_ADDRESS}`,
                ADD_Int_Addr_Label: internationalAddress
            }
        }
        if (this.variant === "popup") {
            this.addressClass = "slds-col slds-size_1-of-1 slds-large-size_12-of-12 formCol inputForm popup-fields";
            this.aptClass = "slds-col slds-size_1-of-1 slds-large-size_12-of-12 formCol inputForm popup-fields";
            this.cityClass = "slds-col slds-size_1-of-1 slds-large-size_8-of-12 formCol inputForm popup-fields";
            this.zipClass = "slds-col slds-size_1-of-1 slds-large-size_8-of-12 formCol inputForm popup-fields";
            this.fieldsWrapperClass = "slds-grid slds-wrap slds-gutters formRow popup-row";
        } else {
            this.addressClass = "slds-col slds-size_1-of-1 slds-large-size_8-of-12 formCol";
            this.aptClass = "slds-col slds-size_1-of-1 slds-large-size_4-of-12 formCol inputForm";
            this.cityClass = this.isCityPicklist ? "slds-col slds-size_1-of-1 slds-large-size_5-of-12 formCol" : "slds-col slds-size_1-of-1 slds-large-size_5-of-12 inputForm formCol";
            this.zipClass = "slds-col slds-size_1-of-1 slds-large-size_4-of-12 formCol inputForm";
            this.fieldsWrapperClass = "slds-grid slds-wrap slds-gutters slds-grid_align-center formRow";
        }
        if (this.retainedresadd && ((this.retainedresadd.addressStreet && this.retainedresadd.addressStreet.trim()) || this.retainedresadd.addressCity || this.retainedresadd.addressState || this.retainedresadd.addressZip || this.retainedresadd.addressUnit)) {
            this.addressStreet = this.retainedresadd.addressStreet;
            this.addressUnit = this.retainedresadd.addressUnit;
            this.addressCity = this.retainedresadd.addressCity;
            this.addressState = this.hasDefaultState ? this.defaultStateValue : this.retainedresadd.addressState;
            this.addressZip = this.retainedresadd.addressZip;
            this.addressCountryFormat = US_address;
            this.addressCountry = this.labels.United_States;
        } else if (this.retainedresadd && this.retainedresadd.addressInternational) {
            this.addressCountryFormat = ADD_Int_Addr_Label;
            this.addressInternational = this.retainedresadd.addressInternational;
            this.addressCountry = this.retainedresadd.addressCountry.toUpperCase();
        } else if (this.retainedmailadd) {
            this.addressStreet = this.retainedmailadd.addressStreet;
            this.addressUnit = this.retainedmailadd.addressUnit;
            this.addressCity = this.retainedmailadd.addressCity;
            this.addressState =  this.hasDefaultState ? this.defaultStateValue : this.retainedmailadd.addressState;
            this.addressZip = this.retainedmailadd.addressZip;
        } else if (this.retainedresadd.addressCountryFormat) {
            this.addressCountryFormat = this.retainedresadd.addressCountryFormat;
        }
        //hiding addressformat dropdown isInternationalAddress true
        if (this.isInternationalAddress) {
            this.addressCountryFormat = ADD_Int_Addr_Label;
        }
        getAuthIdKeys();
    }

    getStatesList(){
        let states = sessionStorage.getItem("states");
        if(!states){
            getStates().then((data) => {
                data = Array.from(JSON.parse(data));
                if (data.length) {                
                    this.stateOptions = data.map(state => {
                        return {
                            label: state.value,
                            value: state.value
                        }
                    });
                    sessionStorage.setItem("states",JSON.stringify(JSON.parse(JSON.stringify(this.stateOptions))));
                }
            }
            ).catch((error) => {
                ComponentErrorLoging(
                    this.lwcName,
                    "getStates",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        } else {
            this.stateOptions = JSON.parse(states);
        }
    }

    getCountriesList() {
        let countries = sessionStorage.getItem("countries");
        if(!countries){
        getCountries({}).then((allCountries) => {
            if (allCountries) {
                const removeUnitedStates = allCountries.filter(country => country !== United_States);
                this.countriesList = removeUnitedStates.map(state => {
                    return {
                        label: state.toUpperCase(),
                        value: state.toUpperCase()
                    }
                });
                sessionStorage.setItem("countries",JSON.stringify(JSON.parse(JSON.stringify(this.countriesList))));
            }
        }).catch((error) => {
            ComponentErrorLoging(
                this.lwcName,
                "getCountries",
                "",
                "",
                "Medium",
                error.message
            );
        });
        }else{
            this.countriesList = JSON.parse(countries);
        }
    }

    getSuggestion(search) {
        const state_filter = [];
        let state;
        let country = 'US';
        if (this.hasDefaultState && this.defaultStateValue !== "CT") {
            state_filter.push(this.defaultStateValue);
            state = this.defaultStateValue;
        } else if (this.hasDefaultState) {
            state_filter.push("CT");
            state = "CT"

        }
        getAddressSuggestions(search, state, country).then(data => {
            var dataSuggestions;
            if (data) {
                dataSuggestions = data;

                this.addressDropdown = dataSuggestions.map(d => {
                    return {
                        label: d.text,
                        value: d.text,
                        state: d.state,
                        street_line: d.street_line,
                        city: d.city,
                        zipcode: d.zipcode,
                        secondary: d.secondary
                    }
                });
            }
        }).catch(err => {
            ComponentErrorLoging(this.lwcName, 'addressSuggestion', '', '', 'Medium', err.message);
        })
    }

    buildAddress(suggestion) {
        var whiteSpace = "";
        if (suggestion.secondary || suggestion.entries > 1) {
            whiteSpace = " ";
        }
        var address = suggestion.street_line + whiteSpace + suggestion.secondary + ", " + suggestion.city + ", " + suggestion.state + " " + suggestion.zipcode;
        return address;
    }

    handleOnDoneTyping(event) {
        this.addressStreet = event.detail.value;
    }

    handleAddressChange(event) {
        const value = event.detail.value ? event.detail.value.trim():"";
        if (value || value === '') {
            if (event.detail.type && event.detail.type === 'keyup') {
                this.addressStreet = value;
                if (value) {
                    var streetValue = value.replace(/[^a-zA-Z0-9]/g, "").toUpperCase();
                    var hasPOBOX = streetValue.includes("POBOX") ? true : false;
                    this.hasPOBOX = (hasPOBOX && !this.acceptPo) ? true : false;
                    if (this.autocomplete && value.length > 2 && !this.hasPOBOX) {
                        this.getSuggestion(value);
                    } else {
                        if (this.addressDropdown.length > 0) {
                            this.addressDropdown = [];
                        }
                    }
                }
            }
        }
        this.handlefieldchange();
    }

    handleAddressSelect(event) {
        const selected = event.detail.value;
        if (selected && selected !== "") {
            var streetValue = selected.replace(/[^a-zA-Z0-9]/g, "").toUpperCase();
            var hasPOBOX = streetValue.includes("POBOX") ? true : false;
            this.hasPOBOX = (hasPOBOX && !this.acceptPo) ? true : false;
        }
        this.addressStreet = selected;
        if (selected && !this.hasPOBOX) {
            const option = this.addressDropdown.filter(add => add.label === selected);
            if (option && option.length) {
                this.addressStreet = option[0].street_line;
                this.addressUnit = option[0].secondary;
                this.addressCity = option[0].city;
                this.addressState = option[0].state;
                this.addressZip = option[0].zipcode;
            }
        } else if (this.hasPOBOX) {
            this.streetHasError = this.labels.Address_POBox_Error;
        }
        window.setTimeout(() => {
            this.reportFieldsValidity();
        }, 100);
        this.handlefieldchange();
    }

    checkValidCity(event) {
    }

    handleCityDropChange(event) {
        let value = event.detail.value.trim();
        if (event.detail.type && event.detail.type === 'keyup') {
            this.addressCity = value;
            if (value) {
                if (value.length > 1) {
                    const selection = value;

                    if (selection) {
                        const cities = this.originalCities.filter(city => {
                            return city.City__c.toUpperCase().indexOf(selection.toUpperCase()) > -1
                        })
                        if (cities.length) {
                            this.cityOptions = cities.map(city => {
                                return {
                                    label: city.City__c,
                                    value: city.City__c,
                                    Tax_Town__c: city.Tax_Town__c,
                                    DMV_Multi_Town__c: city.DMV_Multi_Town__c
                                };
                            })
                        }
                    }
                }
            } else {
                this.addressCity = value;
                this.updateCityPicklist();
            }
        }
    }

    handleAddressFormatChange(event) {
        this.addressCountryFormat = event.detail.value;
        this.streetHasError = "";
        this.countryHasError = "";
        this.clearAddress();
        this.handlefieldchange();
    }

    handleCountryChange(event) {
        this.addressCountry = event.detail.value;
        this.streetHasError = "";
        this.countryHasError = "";
        this.handlefieldchange();
    }

    handleAddressInternational(event) {
        this.addressInternational = event.target.value;
        this.handlefieldchange();
    }

    handleAddressInternationalBlur(event) {
        this.addressInternational = event.target.value.trim();
        this.handlefieldchange();
    }

    handleCitySelect(event) {
        if (event.detail.value) {
            this.addressCity = event.detail.value;
        }
        this.handlefieldchange();
    }

    handlePlainAddressChange(event) {
        this.addressStreet = event.detail.value;
        this.handlefieldchange();
    }

    handleAddUnitChange(event) {
        this.addressUnit = event.detail.value;
        this.handlefieldchange();
    }

    handleAddUnitChangeBlur(event){
        this.addressUnit = event.target.value.trim();
        this.handlefieldchange();
    }

    handleCityChange(event) {
        this.addressCity = event.detail.value;
        this.handlefieldchange();
    }

    handleCityChangeBlur(event) {
        this.addressCity = event.target.value.trim();
        this.handlefieldchange();
    }

    handlefieldchange() {

        const selectedEvent = new CustomEvent("addresschange", {
            detail: { ...this.getdata(), compname: this.compname }
        });
        this.dispatchEvent(selectedEvent);
    }
    handleStateChange(event) {
        this.addressState = event.detail.value;
        if (event.detail.value === 'CT' && this.originalCities) {
            this.updateCityPicklist();
        }
        this.handlefieldchange();
    }

    handlePlainStateChange(event) {
        this.addressState = event.detail.value;
        this.handlefieldchange();
    }

    handleZipCodeChange(event) {
        var fieldVal = event.target.value;
        if (!this.specChar) {
            if (fieldVal.length == 6) {
                if (fieldVal.substr(5, 1) !== '-') {
                    this.addressZip = fieldVal.substr(0, 5) + '-' + fieldVal.substr(5, 1);
                } else {
                    this.addressZip = fieldVal;
                }
            } else {
                this.addressZip = fieldVal;
            }
        } else {
            event.target.value = fieldVal.substr(0, fieldVal.length - 1);
            this.addressZip = fieldVal.substr(0, fieldVal.length - 1);
        }
        this.handlefieldchange();
    }

    handlePlainZipCodeChange(event) {
        this.addressZip = event.target.value;
    }

    get streetError() {
        return this.streetHasError ? true : false
    }

    get countryError() {
        return this.countryHasError ? true : false;
    }

    get cityError() {
        return this.cityHasError ? true : false
    }

    get stateError() {
        return this.stateHasError ? true : false
    }

    get zipError() {
        return this.zipHasError ? true : false
    }

    onZipBlur(event) {
        if (this.isFieldRequired) {
            event.target.reportValidity();
        }
    }

    onPlainZipBlur(event) {
        if (this.addressZip.length < 6) {
            event.target.setCustomValidity("Must be 6 or more.");
        } else {
            event.target.setCustomValidity("");
        }
        event.target.reportValidity();
    }

    reportFieldsValidity() {
        let inputs = this.template.querySelectorAll('lightning-input');
        let combobox = this.template.querySelectorAll('lightning-combobox');
        let textarea = this.template.querySelectorAll('lightning-textarea');
        textarea.forEach(field => {
            field.reportValidity();
        });
        inputs.forEach(field => {
            field.reportValidity();
        });
        combobox.forEach(field => {
            field.reportValidity();
        });
        this.streetHasError = "";
        this.cityHasError = "";
        this.countryHasError = "";
    }

    handleZipCodePress(event) {
        var charCode = event.keyCode;
        if (charCode !== 229 && charCode !== 8 && (charCode < 48 || (charCode > 57 && charCode < 96) || charCode > 105)) {
            this.specChar = true;
        } else {
            this.specChar = false;
        }
    }

    @api
    validateaddress(type) {
        if (this.isFieldRequired) {
            let inputs = this.template.querySelectorAll('lightning-input');
            let combobox = this.template.querySelectorAll('lightning-combobox');
            let textarea = this.template.querySelectorAll('lightning-textarea');
            let elements = [...inputs, ...combobox, ...textarea];
            const allValid = elements.reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                var fieldValidation = inputCmp.checkValidity();
                return validSoFar && fieldValidation;
            }, true);
            const street = this.addressStreet ? this.addressStreet.trim() : "";
            this.streetHasError = street ? "" : this.labels.ADDUPD_ADDMandatory;
            if (this.hasPOBOX && !this.acceptPo) {
                this.streetHasError = this.labels.Address_POBox_Error;
            }
            const city = this.addressCity ? this.addressCity.trim() : "";
            this.cityHasError = city ? "" : this.labels.ADDUPD_CityMandatory;
            this.stateHasError = this.addressState ? "" : this.labels.ADD_State;
            this.zipHasError = this.addressZip ? "" : this.labels.ADD_Zip;
            const isInternational = (this.addressCountryFormat === ADD_Int_Addr_Label);
            this.internationalHasError = (isInternational && this.addressInternational) ? "" : this.labels.ADD_Address;
            this.countryHasError = (isInternational && !this.addressCountry) ? this.labels.ADDUPD_CountryMandatory :"";
            let finalValidate = false;
            if (isInternational && this.internationalHasError === '' && this.countryHasError === '') {
                finalValidate = true;
            } else {
                finalValidate = this.addressStreet && this.addressCity && this.addressState && this.addressZip && (this.streetHasError === "");
            }
            return (allValid && finalValidate);
        }else {
            if(this.addressStreet){
                const isPoBoxNotValid = this.hasPOBOX && !this.acceptPo;
                if (isPoBoxNotValid) {
                    this.streetHasError = this.labels.Address_POBox_Error;
                }
                return !isPoBoxNotValid;
            }
            return true;
        }        
    }

    @api
    getdata() {
        const countryValue = this.returnCountryBasedOnFields();
        let add = {
            street: this.addressStreet,
            unit: this.addressUnit ? this.addressUnit :"",
            city: this.addressCity,
            state: this.addressState,
            zip: this.addressZip,
            countryFormat: this.addressCountryFormat,
            country: this.addressCountry ? this.addressCountry : (this.isUSCountry ? countryValue : ""),
            internationalAddress: this.addressInternational ? this.addressInternational :""
        }
        return add;
    }

    @api
    hideAllErrors() {
        let inputs = this.template.querySelectorAll('lightning-input');
        let combobox = this.template.querySelectorAll('lightning-combobox');
        let textarea = this.template.querySelectorAll('lightning-textarea');
        textarea.forEach(field => {
            field.setCustomValidity("");
            field.reportValidity();
        });
        inputs.forEach(field => {
            field.setCustomValidity("");
            field.reportValidity();
        });
        combobox.forEach(field => {
            field.setCustomValidity("");
            field.reportValidity();
        });
        this.streetHasError = "";
        this.cityHasError = "";
        this.countryHasError = "";
    }

    returnCountryBasedOnFields(){
        const hasAddress = this.addressStreet || this.addressUnit || this.addressCity || this.addressState || this.addressZip;
        return hasAddress ? United_States : "";
    }

    normalizeBoolean(value) {
        return typeof value === 'string' || !!value;
    }

    @api
    clearAddress() {
        this.addressStreet = '';
        this.addressUnit = '';
        if (this.hasDefaultState) {
            this.addressState = this.defaultStateValue;
        } else {
            this.addressState = '';
        }
        this.addressCity = '';
        this.addressZip = '';
        this.addressInternational = '';
        this.addressCountry = '';
    }

    handleStreetBlur(event) {
        var value = event.detail.value.trim();
        this.streetHasError = "";
        if (this.isFieldRequired) {
            if (value && value !== "") {
                if (this.hasPOBOX) {
                    this.streetHasError = this.labels.Address_POBox_Error;
                } else {
                    this.addressStreet = this.addressStreet ? this.addressStreet : value;
                }
            } else {
                if (!this.disabled && this.isFieldRequired) {
                    this.streetHasError = this.labels.ADDUPD_ADDMandatory;
                }
            }
        } else {
            if (value && value !== "") {
                if (this.hasPOBOX) {
                    this.streetHasError = this.labels.Address_POBox_Error;
                } else {
                    this.addressStreet = this.addressStreet ? this.addressStreet : value;
                }
            }
        }
    }

    handleCityLookupBlur(event) {
        if (event && event.detail && this.isFieldRequired) {
            this.addressCity = event.detail.value.trim();
            if (!event.detail.cityFlag) {
                this.cityHasError = this.labels.ADDUPD_CityMandatory;
            } else {
                this.cityHasError = "";
            }
        }
    }

    @api focus() {
        let element = this.template.querySelector('c-lookup, lightning-input');
        element.focus();
    }

    handleFormSubmit(event) {
        event.preventDefault();
    }
}
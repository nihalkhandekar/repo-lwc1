import { LightningElement, api, track, wire } from 'lwc';
import getStates from '@salesforce/apex/brs_contactDetailPage.getStates';
import getCountries from '@salesforce/apex/BRS_Utility.getCountries';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener } from 'c/commonPubSub';
import Foreign_cannot_CT from '@salesforce/label/c.Foreign_cannot_CT';
import Select_StateorTerritory from '@salesforce/label/c.Select_StateorTerritory';
import Select_Country_Formation from '@salesforce/label/c.Select_Country_Formation';
import Select_Country_Label from '@salesforce/label/c.Select_Country_Label';
import Select_State_or_Territory_Label from '@salesforce/label/c.Select_State_or_Territory_Label';
import { ComponentErrorLoging } from "c/formUtility";

export default class Brs_stateorCountryofFormation extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @api isUsAddress;
    @track isLoading = false;
    @track label = Select_State_or_Territory_Label;
    @api selectedValue = "";
    @api selectedStateValue = "";
    @api selectedCountryValue = "";
    @track picklistOptions = [];
    @api originalPickList = [];
    @track errorMsg;
    @track showErrorMessage = false;
    @api source = 'community';
    @track compName = "brs_stateorCountryofFormation";
    @track isUSCountry = false;
    connectedCallback() {
        this.isUSCountry = this.isUsAddress === 'Yes';
        if (this.isUSCountry) {
            this.isLoading = true;
            getStates({}).then((allUsStates) => {
                if (allUsStates) {
                    const states = JSON.parse(allUsStates).map(state => {
                        return {
                            label: state.label.toUpperCase(),
                            value: state.label.toUpperCase(),
                            shortcut: state.value
                        }
                    });
                    this.originalPickList = states;
                    this.picklistOptions = states;
                }
                this.isLoading = false;
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "getStates",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        }
        else {
            this.label = Select_Country_Label;
            this.isLoading = true;
            getCountries({}).then((allCountries) => {
                if (allCountries) {
                    const removeUnitedStates = allCountries.filter(state => state !== "United States");
                    const countries = removeUnitedStates.map(state => {
                        return {
                            label: state.toUpperCase(),
                            value: state.toUpperCase()
                        }
                    });
                    this.originalPickList = countries;
                    this.picklistOptions = countries;
                }
                this.isLoading = false;
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "getCountries",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        }
        if (!this.pageRef) {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
        }
        registerListener('flowvalidation', this.handleNotification, this);
    }

    setShorcutStateValue(selectedState) {
        const list = this.originalPickList.filter(state => state.value === selectedState);
        if(list.length > 0){
            this.selectedValue = list[0].shortcut;
        }
    }

    @api validate() {
        let isValid = true;
        if (this.isUSCountry && this.selectedStateValue === 'CONNECTICUT') {
            isValid = false;
        } else if (this.isUSCountry && !this.selectedStateValue) {
            isValid = false;
        } else if (!this.isUSCountry && !this.selectedCountryValue) {
            isValid = false;
        } else if (this.isUSCountry && this.selectedStateValue) {
            let hasValue = false;
            if (this.originalPickList && this.originalPickList.length) {
                this.originalPickList.forEach(state => {
                    if (state.value.toUpperCase() === this.selectedStateValue.toUpperCase()) {
                        hasValue = true;
                    }
                });
            }
            if (!hasValue) {
                this.selectedStateValue = "";
            }
            isValid = hasValue;
        } else if (!this.isUSCountry && this.selectedCountryValue) {
            let hasValue = false;
            if (this.originalPickList && this.originalPickList.length) {
                this.originalPickList.forEach(country => {
                    if (country.value.toUpperCase() === this.selectedCountryValue.toUpperCase()) {
                        hasValue = true;
                    }
                });
            }
            if (!hasValue) {
                this.selectedCountryValue = "";
            }
            isValid = hasValue;
        }
        fireEvent(this.pageRef, "flowvalidation", {
            detail: { isValid }
        });
        return {
            isValid,
            errorMessage: ""
        };
    }

    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true) {
            this.showErrorMessage = false;
        }
        else {
            this.showErrorMessage = true;
        }
    }

    get getErrorMsg() {
        let errorsMsg = "";
        if (this.isUSCountry && this.selectedStateValue === 'CONNECTICUT') {
            errorsMsg = Foreign_cannot_CT;
        } else if (this.isUSCountry && !this.selectedStateValue) {
            errorsMsg = Select_StateorTerritory;
        } else if (!this.isUSCountry && !this.selectedCountryValue) {
            errorsMsg = Select_Country_Formation;
        }
        return errorsMsg;
    }

    updatePicklist() {
        this.picklistOptions = this.originalPickList;
    }

    setValue(value) {
        if (this.isUSCountry) {
            this.selectedStateValue = value;
            this.setShorcutStateValue(value);
        } else {
            this.selectedCountryValue = value;
        }
    }

    handleChange(event) {
        let value = event.detail.value;
        if (event.detail.type && event.detail.type === 'keyup') {
            this.setValue(event.detail.value);
            if (value) {
                if (value.length > 0) {
                    const selection = value;
                    if (selection) {
                        const lists = this.originalPickList.filter(stateOrCountry => {
                            return stateOrCountry.label.toUpperCase().indexOf(selection.toUpperCase()) > -1
                        })
                        if (lists.length) {
                            this.picklistOptions = lists.map(stateOrCountry => {
                                return {
                                    label: stateOrCountry.label,
                                    value: stateOrCountry.value
                                };
                            })
                        } else {
                            this.picklistOptions = [];
                        }
                    }
                }
            } else {
                this.setValue(event.detail.value);
                this.updatePicklist();
            }
        }
    }

    handleSelect(event) {
        if (event.detail.value) {
            if (this.isUSCountry) {
                this.selectedStateValue = event.detail.value;
                this.setShorcutStateValue(event.detail.value);
                this.showErrorMessage = event.detail.value === 'CONNECTICUT';
            } else {
                this.selectedCountryValue = event.detail.value;
                this.showErrorMessage = false;
            }
        }
    }

    handleBlur(event) {
        if (this.selectedStateValue.length === 0 && this.selectedCountryValue.length === 0) {
            if (event && event.detail) {
                this.setValue(event.detail.value);
            }
        }
        this.updatePicklist();
    }


}
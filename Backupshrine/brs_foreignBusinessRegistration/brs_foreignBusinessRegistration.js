import { LightningElement, api, track } from 'lwc';
import BRS_Enter_ALEI from '@salesforce/label/c.BRS_Enter_ALEI';
import Brs_ALEI_Placeholder from '@salesforce/label/c.Brs_ALEI_Placeholder';
import Brs_Foreign_State_Error from '@salesforce/label/c.Brs_Foreign_State_Error';
import Brs_Foreign_Country_Error from '@salesforce/label/c.Brs_Foreign_Country_Error';
import getLatestStateForALEI from "@salesforce/apex/BRS_Utility.getLatestStateForALEI";
import loading_brs from '@salesforce/label/c.loading_brs';
import {
    isUndefinedOrNull
  } from "c/appUtility";

export default class Brs_foreignBusinessRegistration extends LightningElement {
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
    @api value;
    @track isState;
    @api enteredValue;
    @api displayValue;
    @api ALEIValue;
    @track stateAppendedText;
    @api accountId;
    @track isLoading = false;
    label = {
        BRS_Enter_ALEI,
        Brs_ALEI_Placeholder,
        Brs_Foreign_State_Error,
        Brs_Foreign_Country_Error,
        loading_brs
    }
    connectedCallback(){
        if(this.accountId){
            this.isLoading = true;
            getLatestStateForALEI({
                accountId: this.accountId
            })
            .then((data) => {
                this.isLoading = false;
                this.value = data;
                if(this.value){

            if(this.value.length >2){
                this.value = this.stateMap[this.value.toUpperCase()];
            }
            this.isState = true;
            this.stateAppendedText = 'US-'+this.value+'.BER:';
            }else{
                this.isState = false;
            }
            this.displayValue=this.enteredValue;
            if(!isUndefinedOrNull(this.enteredValue)){
                this.ALEIValue = this.enteredValue;
                var splitedValue = this.enteredValue.split(':');
                    if(splitedValue.length===2){
                        this.displayValue = splitedValue[1];
                    }
                }
                this.enteredValue = this.enteredValue;
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(this.compName, "getLatestStateForALEI", "", "", "Medium", error.message);
            });
        }
    }
    removeCopyPaste(event) {
        event.preventDefault();
        return false;
    }
    handleChange(event){
        let value = event.detail.value.trim();
        this.enteredValue = value;
        if(value){
            this.ALEIValue= this.isState ? this.stateAppendedText+value : value;
        }else {
            this.ALEIValue = value;
        }
    }
    onlyNumbers(event){
        const charCode = event.keyCode || event.which;
        if (charCode < 48 || charCode > 57) {
            event.preventDefault();
        }
    }
    onlyAlphanumeric(event){
        const charCode = event.keyCode || event.which;
        if(!(charCode > 47 && charCode < 58) && 
           !(charCode > 64 && charCode < 91) && 
           !(charCode > 96 && charCode < 123)){
            event.preventDefault();
        } 
    }
}
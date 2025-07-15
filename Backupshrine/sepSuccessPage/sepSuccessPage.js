import { LightningElement, api, track } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { getDateTimeInYYYYMMDDhhmmss } from 'c/appUtility';
import { SEPComponentErrorLoging } from "c/formUtility";

import fetchRecordDetails from '@salesforce/apex/sep_SuccessPageController.getRecordDetails';
import SEP_SuccessPageHeading from '@salesforce/label/c.SEP_SuccessPageHeading';
import SEP_SuccessPageContentOne from '@salesforce/label/c.SEP_SuccessPageContentOne';
import SEP_SuccessPageContentTwo from '@salesforce/label/c.SEP_SuccessPageContentTwo';
import SEP_SuccessPageBackButton from '@salesforce/label/c.SEP_SuccessPageBackButton';

import SEP_ErrorPageHeading from '@salesforce/label/c.SEP_ErrorPageHeading';
import SEP_ErrorPageContentOne from '@salesforce/label/c.SEP_ErrorPageContentOne';
import SEP_ErrorPageContentTwo from '@salesforce/label/c.SEP_ErrorPageContentTwo';
import SEP_ErrorPageContentLinkText from '@salesforce/label/c.SEP_ErrorPageContentLinkText';

import SEP_AlreadyRegisteredHeading from '@salesforce/label/c.SEP_AlreadyRegisteredHeading';
import SEP_AlreadyRegisteredContent from '@salesforce/label/c.SEP_AlreadyRegisteredContent';
import SEP_AlreadyRegisteredIssueNumber from '@salesforce/label/c.SEP_AlreadyRegisteredIssueNumber';
import SEP_SuccessPageMainHeading from '@salesforce/label/c.SEP_SuccessPageMainHeading';
import SEP_SuccessPageMainHeadingError from '@salesforce/label/c.SEP_SuccessPageMainHeadingError';
import SEP_SuccessPageSelfExclusion from '@salesforce/label/c.SEP_SuccessPageSelfExclusion';
import SEP_SuccessPageReqDate from '@salesforce/label/c.SEP_SuccessPageReqDate';
import SEP_SuccessPageSelfExclusionPeriod from '@salesforce/label/c.SEP_SuccessPageSelfExclusionPeriod';
import SEP_SuccessPageRemovalAllowed from '@salesforce/label/c.SEP_SuccessPageRemovalAllowed';
import SEP_ErrorScreenHelpTxt from '@salesforce/label/c.SEP_ErrorScreenHelpTxt';
import SEP_FlowErrorMsg from "@salesforce/label/c.SEP_FlowErrorMsg";
import SEP_Error_Header from '@salesforce/label/c.SEP_Error_Header';
import SEP_Error_Header_ID_Proofing from "@salesforce/label/c.SEP_Error_Header_ID_Proofing";
import SEP_IDproofingTimeOutMsg from '@salesforce/label/c.SEP_IDproofingTimeOutMsg';
import {  changeDateFormat } from "c/appUtility";
import SEP_EmailAddress from "@salesforce/label/c.SEP_EmailAddress";
import SEP_EmailAddressMailTo from "@salesforce/label/c.SEP_EmailAddressMailTo";
import SEP_RemovalSuccessPageMainHeading from "@salesforce/label/c.SEP_RemovalSuccessPageMainHeading";
import SEP_RemovalSuccessPageHeadingSuccess from "@salesforce/label/c.SEP_RemovalSuccessPageHeadingSuccess"
import SEP_RemovalSuccessPageContentOne from "@salesforce/label/c.SEP_RemovalSuccessPageContentOne";
import SEP_RemovalSuccessPageRemovalAllowed from "@salesforce/label/c.SEP_RemovalSuccessPageRemovalAllowed";
import SEP_RemovalSuccessPageContentThree from "@salesforce/label/c.SEP_RemovalSuccessPageContentThree";
import SEP_RemovalSuccessPageContentTwo from "@salesforce/label/c.SEP_RemovalSuccessPageContentTwo";
import SEP_ErrorPageContentTwolink from "@salesforce/label/c.SEP_ErrorPageContentTwolink";
import SEP_IDproofingGenericErrorPara2 from "@salesforce/label/c.SEP_IDproofingGenericErrorPara2";
import SEP_CtPortalExclusionLink from "@salesforce/label/c.SEP_CtPortalExclusionLink";
import SEP_IDproofingUserBlockedMsg from "@salesforce/label/c.SEP_IDproofingUserBlockedMsg";
import SEP_SuccessPageRemovalLifeTime from "@salesforce/label/c.SEP_SuccessPageRemovalLifeTime";




export default class SepSuccessPage extends LightningElement {

    labels = {
        SEP_IDproofingUserBlockedMsg,
        SEP_ErrorPageContentTwolink,
        SEP_IDproofingGenericErrorPara2,
        SEP_CtPortalExclusionLink,
        SEP_SuccessPageHeading,
        SEP_SuccessPageContentOne,
        SEP_SuccessPageContentTwo,
        SEP_SuccessPageBackButton,
        SEP_ErrorPageHeading,
        SEP_ErrorPageContentOne,
        SEP_ErrorPageContentTwo,
        SEP_ErrorPageContentLinkText,
        SEP_AlreadyRegisteredHeading,
        SEP_AlreadyRegisteredContent,
        SEP_AlreadyRegisteredIssueNumber,
        SEP_SuccessPageMainHeading,
        SEP_SuccessPageMainHeadingError,
        SEP_SuccessPageSelfExclusion,
        SEP_SuccessPageReqDate,
        SEP_SuccessPageSelfExclusionPeriod,
        SEP_SuccessPageRemovalAllowed,
        SEP_EmailAddress,
        SEP_ErrorScreenHelpTxt,
        SEP_FlowErrorMsg,
        SEP_EmailAddressMailTo,
        SEP_Error_Header_ID_Proofing,
        SEP_Error_Header,
        SEP_IDproofingTimeOutMsg,
        SEP_RemovalSuccessPageMainHeading,
        SEP_RemovalSuccessPageHeadingSuccess,
        SEP_RemovalSuccessPageContentOne,
        SEP_RemovalSuccessPageRemovalAllowed,
        SEP_RemovalSuccessPageContentTwo,
        SEP_RemovalSuccessPageContentThree,
    };

    @track params;
    @track variationOne;
    @track variationTwo;
    @track variationThree;
    @track variationFour; 
    @track variationFive; //flow Technical Error
    @track variationSix; //id proofing time out error screen
    @track variationSeven; //id proofing user blocked error screen
    @track removalVariationOne; // Removal Success
    @track removalVariationTwo; // Removal Duplicate
    @track removalVariationThree; // Removal Error
    @track registrationNumber = '8972e7399e';
    @track requestDate = '08/23/2021';
    @track minSelfExePeriod;
    @track removalAllowedAfter;
    @track tableData = [];

    @track successVerificationIcon = assetFolder + "/icons/verificationModal/ic_successverification.png";
    @track failedVerificationIcon = assetFolder + "/icons/verificationModal/ic_failedverification.png";
    @track calendarIcon = assetFolder + "/icons/ReviewPageIcons/calendar-outline.svg";
    @track fileIcon = assetFolder + "/icons/ReviewPageIcons/reader-outline.svg";
    @track arrowRightWhite = assetFolder + "/icons/arrow-right-white.svg";
    
    @track isLoading = false;
    compName = 'sepConsentPage';

    connectedCallback() {
        try {
            window.pageName = "successpage";
            //Disabling back button code
            let state = Object.assign({}, history.state);
            state.page = 'successpage';
            history.pushState(state, document.title, window.location.href);
            window.onpopstate = (ev) => {
                setTimeout(() => {
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                }, 0);
                let state = Object.assign({}, history.state);
                window.history.pushState(state, document.title, window.location.href);
            };
            history.pushState({}, '');

            var params = {};
            var search = location.search.substring(1);
            if (search) {
                params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                    return key === "" ? value : decodeURIComponent(value)
                });
            }
            this.params = params;
            if(!this.params.isRemoval || this.params.isRemoval == "false"){  //registration flow
                if (this.params.pageVariant == 'Duplicate') {
                    this.isLoading = true;
                    fetchRecordDetails({ sConsentRegistrationNumber: this.params.ConsentRegistrationNumber,sOperation :this.params.Operation, sDateTime: getDateTimeInYYYYMMDDhhmmss()})
                        .then(result => {
                            if (result) {
                                this.assignDetailsToTracks(result);
                            }
                            this.isLoading = false;
                        }).catch(error => {
                            this.isLoading = false;
                        });
                    this.variationThree = true;
                } else if (this.params.pageVariant == 'Success') {
                    this.isLoading = true;
                    fetchRecordDetails({ sConsentRegistrationNumber: this.params.ConsentRegistrationNumber,sOperation :this.params.Operation, sDateTime: getDateTimeInYYYYMMDDhhmmss() })
                        .then(result => {
                            if (result) {
                                this.assignDetailsToTracks(result);
                            }
                            this.isLoading = false;
                        }).catch(error => {
                            this.isLoading = false;
                        });
                    this.variationOne = true;
                } else if (this.params.pageVariant == 'Error') {
    
                    this.variationTwo = true;
                }
                else if(this.params.pageVariant == 'Technical Error') {
                    this.variationFive = true;
                }
                else if(this.params.pageVariant == 'ErrorTimeOut'){
                    this.variationSix = true;
                }
                else if(this.params.pageVariant == 'userBlocked'){
                    this.variationSeven = true;
                }
            } else {                // removal flow
                if(this.params.pageVariant == 'Duplicate'){
                    this.isLoading = true;
                    fetchRecordDetails({ sConsentRegistrationNumber: this.params.ConsentRegistrationNumber,sOperation :this.params.Operation, sDateTime: getDateTimeInYYYYMMDDhhmmss() })
                        .then(result => {
                            if (result) {
                                this.assignDetailsToTracks(result);
                            }
                            this.isLoading = false;
                            this.removalVariationTwo = true;
                        }).catch(error => {
                            this.isLoading = false;
                        });
                    
                } else if(this.params.pageVariant == 'Success'){
                    this.removalVariationOne = true;
                    this.assignDetailsToTracksRemoval();
                } else if(this.params.pageVariant == 'Not Found'){
                    this.removalVariationThree = true
                } else if (this.params.pageVariant == 'Error'){
                    this.variationTwo = true;
                } else if(this.params.pageVariant == 'Technical Error') {
                    this.variationFive = true;
                }
                else if(this.params.pageVariant == 'ErrorTimeOut'){
                    this.variationSix = true;
                }
                else if(this.params.pageVariant == 'userBlocked'){
                    this.variationSeven = true;
                }
            }
            
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'connectedCallback', '', '', 'High', e);
        }
    }
    assignDetailsToTracksRemoval(){
        try {
            this.tableData = [
            {
                icon: assetFolder + "/icons/ReviewPageIcons/calendar-outline.svg",
                firstLabel: this.labels.SEP_RemovalSuccessPageRemovalAllowed,
                secondLabel: changeDateFormat(new Date(), false),
            }];
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'assignDetailsToTracks', '', '', 'High', e);
        }
    }
    assignDetailsToTracks(result) {
        try {
            this.tableData = [{
                icon: assetFolder + "/icons/ReviewPageIcons/reader-outline.svg",
                firstLabel: this.labels.SEP_SuccessPageSelfExclusion,
                secondLabel: result.sExclusionRegistrationNumber
            },
            {
                icon: assetFolder + "/icons/ReviewPageIcons/calendar-outline.svg",
                firstLabel: this.labels.SEP_SuccessPageReqDate,
                secondLabel: changeDateFormat(result.sExclusionRequestDate, true)
            },
            {
                icon: assetFolder + "/icons/clock.svg",
                firstLabel: this.labels.SEP_SuccessPageSelfExclusionPeriod,
                secondLabel: result.sMinimumExclusionPeriod
            },
            {
                icon: assetFolder + "/icons/ReviewPageIcons/calendar-outline.svg",
                firstLabel: this.labels.SEP_SuccessPageRemovalAllowed,
                secondLabel: (result.sMinimumExclusionPeriod && result.sMinimumExclusionPeriod != SEP_SuccessPageRemovalLifeTime) ? changeDateFormat(result.sRemovalAllowedOnAfter, true) :result.sRemovalAllowedOnAfter
            }];
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'assignDetailsToTracks', '', '', 'High', e);
        }
    }
    handleBackToWebsite() {
        try {
            window.location.href = this.labels.SEP_CtPortalExclusionLink;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleBackToWebsite', '', '', 'High', e);
        }
    }
}
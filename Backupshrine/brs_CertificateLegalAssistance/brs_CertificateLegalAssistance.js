import { LightningElement, api, track, wire } from 'lwc';
import getCertificate from '@salesforce/apex/BRS_Utility.getCertificate';
import GetEntityRecordFiles from '@salesforce/apex/brs_fileUploaderController.getDocuments';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { ComponentErrorLoging } from "c/formUtility";
import brs_VerifyCert_FlowTitle from "@salesforce/label/c.brs_VerifyCert_FlowTitle";
import Back from "@salesforce/label/c.Back";
import Next from "@salesforce/label/c.Next";
import verify_Certificate_Search from "@salesforce/label/c.verify_Certificate_Search";
import verify_certificate_search_result from "@salesforce/label/c.verify_certificate_search_result";
import verify_Certificate_question from "@salesforce/label/c.verify_Certificate_question";
import no_Certificate_Title from "@salesforce/label/c.no_Certificate_Title";
import no_Certificate_subTitle from "@salesforce/label/c.no_Certificate_subTitle";
import no_Certificate_description from "@salesforce/label/c.no_Certificate_description";
import verify_certificate_search_result_1 from "@salesforce/label/c.verify_certificate_search_result_1";
import verify_certificate_search_result_2 from "@salesforce/label/c.verify_certificate_search_result_2";
import Certificate_Of_Text from "@salesforce/label/c.Certificate_Of_Text";
import { NavigationMixin } from 'lightning/navigation';
import BRS_Certificate_Maintainence from "@salesforce/label/c.BRS_Certificate_Maintainence";
import businessIdLabel from "@salesforce/label/c.businessId";
import loading_brs from "@salesforce/label/c.loading_brs";
import certificate_number from "@salesforce/label/c.certificate_number";
import getDownloadFileCommunityUser from '@salesforce/apex/BRS_Utility.getDownloadFileCommunityUser';
import ALEI_Label from '@salesforce/label/c.ALEI_Label';
import Connecticut_ALEI_Prefix from '@salesforce/label/c.Connecticut_ALEI_Prefix';
import Certificate_Number_Placeholder from '@salesforce/label/c.Certificate_Number_Placeholder';

export default class Brs_CertificateLegalAssistance extends NavigationMixin(LightningElement) {
    @api businessId;
    @api certificateNumber;
    @api certificateId;
    @api previewLink;
    @api downloadLink;
    @track isLoading = false;
    @track showCertDetails = false;
    @track showEmptyCertDetails = false;
    @track showDataCertDetails = false;
    @track noCertImage = assetFolder + "/icons/no-biz-found.svg";
    @track searchIcon = assetFolder + "/icons/searchIcon.svg";
    @track certificateDetails = [];
    @track nextButton = Next;
    @track prevButton = Back;
    @track compName = "brs_CertificateLegalAssistance";
    @track isDisableNextButton = true;
    @track selectedCertificate;
    @track addressCheck;

    label = {
        verify_Certificate_Search,
        verify_certificate_search_result,
        verify_Certificate_question,
        no_Certificate_Title,
        no_Certificate_subTitle,
        no_Certificate_description,
        verify_certificate_search_result_1,
        verify_certificate_search_result_2,
        Certificate_Of_Text,
        businessIdLabel,
        loading_brs,
        certificate_number,
        ALEI_Label,
        Connecticut_ALEI_Prefix,
        brs_VerifyCert_FlowTitle,
        Certificate_Number_Placeholder
    }

    onBusinessIdChange(event) {
        this.businessId = event.target.value;
    }
    onCerticateNumberChange(event) {
        this.certificateNumber = event.target.value;
    }
    handleEnter(event){
        if(event.keyCode === 13){
          this.onSearchBusiness();
        }
    }
    onSearchBusiness() {
        this.showCertDetails = false;
        this.showEmptyCertDetails = false;
        this.showDataCertDetails = false;

        let isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if (isInputsCorrect) {
            this.isLoading = true;
            getCertificate({ certificateNumber: this.certificateNumber, businessId: this.businessId })
                .then(data => {
                    this.isLoading = false;
                    let details = JSON.parse(JSON.stringify(data));
                    let otherRequestData = JSON.stringify(details['Other_Request__r'])!=null?JSON.parse(JSON.stringify(details['Other_Request__r'])):null;
                    let certificateData = details['Business__r']!=null?details['Business__r']:otherRequestData!=null?otherRequestData['Business__r']:null;
                    let filingData = (JSON.stringify(details['UCC_Filing__r']))!=null?JSON.parse(JSON.stringify(details['UCC_Filing__r'])):(JSON.stringify(details['Mark_Filing__r']))!=null?JSON.parse(JSON.stringify(details['Mark_Filing__r'])):null;
                    this.showDataCertDetails = true;
                    this.nextButton = this.label.brs_VerifyCert_FlowTitle;
                    if (certificateData && certificateData['BillingAddress'] != null) {
                        this.addressCheck = this.getFormattedAddressData(certificateData['BillingAddress']);
                    }
                    if(certificateData){
                        this.certificateDetails = [
                            {
                                ConnecticutAlei: certificateData ? this.label.businessIdLabel + " " + certificateData['AccountNumber']:null,
                                status:  certificateData ? certificateData['Status__c'].toUpperCase():null,
                                label: certificateData ? certificateData['Name']:null,
                                address: this.addressCheck,
                                certificateType: details['Certificate_Type__c']!=null ? details['Certificate_Type__c'] : (details['Copy_Type__c']!=null ? details['Copy_Type__c'] :null),
                                dateGenerated: details['Requested_On__c']!=null ? details['Requested_On__c'] : details['CreatedDate']!=null ? details['CreatedDate']:null,
                                value: certificateData ? certificateData['AccountNumber']:null
                            }
                        ]
                    }
                    else if(filingData){
                        this.certificateDetails = [
                            {
                                ConnecticutAlei: null,
                                status: otherRequestData['Status__c']!=null ? otherRequestData['Status__c'].toUpperCase() : null,
                                label: details['Mark_Filing_Number__c']!=null ? (details['Mark_Filing_Number__c'] + '-' + filingData['Filing_Type__c']) : details['UCC_Filing_Number__c']!=null ? (details['UCC_Filing_Number__c'] + '-' + filingData['Type__c']) : null,
                                address: null,
                                certificateType: details['Certificate_Type__c']!=null ? details['Certificate_Type__c'] : (details['Copy_Type__c']!=null ? details['Copy_Type__c'] :null),
                                dateGenerated: details['Requested_On__c']!=null ? details['Requested_On__c'] : (details['CreatedDate']!=null ? details['CreatedDate'] :null),
                                value: filingData['Id']
                            }
                        ]
                    }
                    this.selectedCertificate = certificateData ? certificateData['AccountNumber']: filingData ? filingData['Id']: null;
                    this.certificateId = data.Id;
                    this.isDisableNextButton = false;
                }).catch(error => {
                    this.isLoading = false;
                    this.showEmptyCertDetails = true;
                    this.selectedCertificate = '';
                    this.isDisableNextButton = true;
                    ComponentErrorLoging(
                        this.compName,
                        "getCertificate",
                        "",
                        "",
                        "Medium",
                        error.message
                    );
                }).finally(() => {
                    this.showCertDetails = true;
                });
        }
    }
    handleCertificateSelection() {
        this.isDisableNextButton = false;
    }
    onVerfiyCertificate() {
        if(this.certificateId) {
            this.isLoading = true;
            GetEntityRecordFiles({recId:this.certificateId,fileValue:''})
            .then(data =>{
                this.isLoading = false;
                const linkDetails = JSON.parse(JSON.stringify(data));
                const nextNavigationEvent = new FlowNavigationNextEvent();
                if(linkDetails.length > 0) {
                    this.downloadLink = linkDetails[0]['downloadUrl'];
                    this.previewLink = linkDetails[0]['fileUrl'];
                }
                this.dispatchEvent(nextNavigationEvent);
            }).catch(error =>{
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "GetEntityRecordFiles",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            })
        }
    }
    getFormattedAddressData(billingAddress) {
        let address = [];
        if (billingAddress.street) {
            address.push(billingAddress.street);
        }
        if (billingAddress.city) {
            address.push(billingAddress.city);
        }
        if (billingAddress.state) {
            address.push(billingAddress.state);
        }
        if (billingAddress.postalCode) {
            address.push(billingAddress.postalCode);
        }
        if (billingAddress.country) {
            address.push(billingAddress.country);
        }
        return address.join(", ");
    }

    gotoCertificateLandingPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: BRS_Certificate_Maintainence
            },
        });
    }
}
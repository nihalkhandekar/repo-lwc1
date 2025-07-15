import {
    LightningElement,
    track,
    api
} from 'lwc';
import certFolder from "@salesforce/resourceUrl/Certificate";
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationBackEvent,
    FlowNavigationPauseEvent,
    FlowNavigationFinishEvent
} from 'lightning/flowSupport';
import getAllcerts from '@salesforce/apex/BRS_Utility.getAllcerts';
import BRS_Total_Fee from "@salesforce/label/c.BRS_Total_Fee";
import BRS_Cert_Type_Error from "@salesforce/label/c.BRS_Cert_Type_Error";
import Next from '@salesforce/label/c.Next';
import Back from '@salesforce/label/c.Back';
import BRS_Proceed_Payment from "@salesforce/label/c.BRS_Proceed_Payment";
import Domestic from "@salesforce/label/c.Domestic";
import brs_CertficateTypes from "@salesforce/label/c.brs_CertficateTypes";
import brs_CertficateTypeStandard from "@salesforce/label/c.brs_CertficateTypeStandard";
import brs_CertficateTypeLongform from "@salesforce/label/c.brs_CertficateTypeLongform";
import BRS_Express_Desc from "@salesforce/label/c.BRS_Express_Desc";
import BRS_Standard_Desc from "@salesforce/label/c.BRS_Standard_Desc";
import BRS_Longform_Desc from "@salesforce/label/c.BRS_Longform_Desc";
import { ComponentErrorLoging } from "c/formUtility";

export default class Brs_certificateTypes extends LightningElement {

    @track certificateCards = [];
    @track selectedCertsArray = [];
    @track feesTotal = 0;
    @api certTypes;
    @api feeTotal;
    @api tempRecord;
    @api showError;
    @api accountId;
    @api accBusinessType;
    @api businessType;
    @track dataLoaded = false;
    @track showCertError = false;
    @track expressCert = certFolder + "/certificate/ExpressCertificate.pdf";
    @track longformCert = certFolder + "/certificate/LongformCertificate.pdf";
    @track standardCert = certFolder + "/certificate/StandardCertificate.pdf";
    @track isLoading = false;
    isCertTypes = true;

    label = {
        BRS_Total_Fee,
        BRS_Cert_Type_Error,
        Next,
        Back,
        BRS_Proceed_Payment,
        brs_CertficateTypes,
        brs_CertficateTypeStandard,
        brs_CertficateTypeLongform,
        BRS_Express_Desc,
        BRS_Standard_Desc,
        BRS_Longform_Desc
    }

    connectedCallback() {
        // method to get All certs from BRS_Utility
        this.isLoading = true;
        if (this.certTypes && this.certTypes.length > 0) {
            this.selectedCertsArray = this.certTypes[0].split(";");
        }
        this.getAllCertsMethod();
    }

    getAllCertsMethod() {
        getAllcerts({ accountId: this.accountId })
            .then(result => {
                if (result && result.length !== 0) {
                    result.forEach(cert => {
                        cert.Certificate_Price__c = parseInt(cert.Amount__c);
                        switch (cert.Filing_Type__c.toLowerCase()) {
                            case "express":
                                cert.Order__c = 1;
                                cert.Certificate_Description__c = this.label.BRS_Express_Desc;
                                cert.MasterLabel = this.label.brs_CertficateTypes;
                                cert.showCard = true;
                                cert.sampleUrl = this.expressCert;
                                break;
                            case "standard":
                                cert.Order__c = 2;
                                cert.Certificate_Description__c = this.label.BRS_Standard_Desc;
                                cert.MasterLabel = this.label.brs_CertficateTypeStandard;
                                cert.showCard = true;
                                cert.sampleUrl = this.standardCert;
                                break;
                            case "longform":
                                cert.Order__c = 3;
                                cert.Certificate_Description__c = this.label.BRS_Longform_Desc;
                                cert.MasterLabel = this.label.brs_CertficateTypeLongform;
                                cert.showCard = (this.businessType === Domestic);
                                cert.sampleUrl = this.longformCert;
                                //cert.isDisabled = true; | BRS-7363 | Enable longform for online
                                break;
                        }
                        cert.checked = (this.selectedCertsArray && this.selectedCertsArray.includes(cert.MasterLabel));
                        if (cert.checked) {
                            this.feesTotal += cert.Certificate_Price__c;
                        }
                    });
                    result.sort(function (a, b) {
                        return a.Order__c - b.Order__c;
                    });
                    this.certificateCards = result;
                    this.dataLoaded = true;
                }
                this.isLoading = false;

            })
            .catch(error => {
                ComponentErrorLoging(
                    this.compName,
                    "performDMLOperationsApex",
                    "",
                    "",
                    "Medium",
                    error.message
                );
                this.isLoading = false;
            });
    }

    renderedCallback() {
        var errorElem = this.template.querySelector(".fees-error");
        if (errorElem) {
            errorElem.scrollIntoView();
        }
    }

    handleCertSelection(event) {
        var certData = event.detail;
        this.certChangeOperation("checked", certData);
        //fix added for BRS-2688 error persisting issue
        if (this.feesTotal > 0) {
            this.showCertError = false;
        }
    }

    handleCertUnselect(event) {
        var certData = event.detail;
        this.certChangeOperation("unchecked", certData);
    }

    certChangeOperation(param, value) {
        if (param === "checked") {
            let listData = this.certificateCards;
            listData.forEach(option => {
                if (option.Id === value) {
                    this.feesTotal += option.Certificate_Price__c;
                    if (this.selectedCertsArray && !this.selectedCertsArray.includes(option.MasterLabel)) {
                        this.selectedCertsArray.push(option.MasterLabel);
                    }
                }
            });
        } else if (param === "unchecked") {
            let listData = this.certificateCards;
            listData.forEach(option => {
                if (option.Id === value) {
                    this.feesTotal -= option.Certificate_Price__c;
                    if (this.selectedCertsArray && this.selectedCertsArray.includes(option.MasterLabel)) {
                        this.selectedCertsArray.splice(this.selectedCertsArray.indexOf(option.MasterLabel), 1);
                    }
                }
            });
        }
        const attributeChangeEvent = new FlowAttributeChangeEvent('certTypes', this.selectedCertsArray.join(";"));
        this.dispatchEvent(attributeChangeEvent);
        const attributeFeesChangeEvent = new FlowAttributeChangeEvent('feeTotal', this.feesTotal);
        this.dispatchEvent(attributeFeesChangeEvent);
    }

    handleProceed() {
        if (this.feesTotal && this.feesTotal > 0) {
            this.showCertError = false;
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        } else {
            this.showCertError = true;
        }

    }

    handleBack() {
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }
}
import { LightningElement, api, track, wire } from 'lwc';
import getUCCRelatedRecords from '@salesforce/apex/brs_genericSearchClass.getUCCRelatedRecords';
import { ComponentErrorLoging } from "c/formUtility";
import lapse_Date from '@salesforce/label/c.lapse_Date';
import filing_date from '@salesforce/label/c.filing_date';
import filing_numberNew from '@salesforce/label/c.filing_numberNew';
import filing_type from '@salesforce/label/c.filing_type';
import lien_number from '@salesforce/label/c.lien_number';
import filing_information from '@salesforce/label/c.filing_information';
import debtor_information from '@salesforce/label/c.debtor_information';
import debtor_name from '@salesforce/label/c.debtor_name';
import brs_maintenance_Address from '@salesforce/label/c.brs_maintenance_Address';
import Recovery_SelfCertify_PlaceholderCity from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderCity';
import debtor_state from '@salesforce/label/c.debtor_state';
import Recovery_SelfCertify_PlaceholderBusinessZipCode from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderBusinessZipCode';
import securedParty_information from '@salesforce/label/c.securedParty_information';
import securedParty_name from '@salesforce/label/c.securedParty_name';
import BRS_UCC_Assignor_Label from '@salesforce/label/c.BRS_UCC_Assignor_Label';
import lien_type from '@salesforce/label/c.lien_type';
import BRS_UCC_Debtor_Label from '@salesforce/label/c.BRS_UCC_Debtor_Label';
import BRS_UCC_Secured_Party_Label from '@salesforce/label/c.BRS_UCC_Secured_Party_Label';
import assetFolder from '@salesforce/resourceUrl/CT_Assets';
import microfilm_Volume_Number from '@salesforce/label/c.microfilm_Volume_Number';
import page_s from '@salesforce/label/c.page_s'
import AddsecuredParty_name from '@salesforce/label/c.AddsecuredParty_name'
import Adddebtor_name from '@salesforce/label/c.Adddebtor_name'
import Review_MasterLabel_Type_Owner from '@salesforce/label/c.Review_MasterLabel_Type_Owner'
import Judgment_Debtor_Label from '@salesforce/label/c.Judgment_Debtor_Label'
import Review_MasterLabel_Type_Claimant from '@salesforce/label/c.Review_MasterLabel_Type_Claimant'
import Judgment_Creditor_Label_Title_Case from '@salesforce/label/c.Judgment_Creditor_Label_Title_Case'
import Secured_Party_Label from '@salesforce/label/c.Secured_Party_Label';
import help_head from '@salesforce/label/c.help_head';
import help_body from '@salesforce/label/c.help_body';
import help_amend from '@salesforce/label/c.help_amend';
import amend_link from '@salesforce/label/c.amend_link';
import help_request from '@salesforce/label/c.help_request';
import irs_number from '@salesforce/label/c.irs_number';
import brs_ViewasPDF from '@salesforce/label/c.brs_ViewasPDF';
import brs_Digitalcopy from '@salesforce/label/c.brs_Digitalcopy';
import BRS_UCC_Defendant_Label from '@salesforce/label/c.BRS_UCC_Defendant_Label';
import BRS_UCC_Plaintiff_Label from '@salesforce/label/c.BRS_UCC_Plaintiff_Label';
import Start_page from '@salesforce/label/c.Start_page';
import None from '@salesforce/label/c.None';


import Label_Address from '@salesforce/label/c.Label_Address';
import Filing_information_Label from '@salesforce/label/c.Filing_information_Label';

export default class Brs_displayAllrecords extends LightningElement {
    @api scholarContent;
    @api FilingNumber;
    @api readFillingFromUrl;
    @track allRecords;
    @track debtorRecord;
    @track securedPartyRecord;
    @track isdebtor = false;
    @track isSecuredParty = false;
    @track helperImg = assetFolder + "/icons/drivers-license.svg";
    @track isLoading = false;
    @track filingInfo;
    @track viewLink;
    @track isLapseDatePresent = false;

    label = {
        lapse_Date,
        filing_date,
        filing_numberNew,
        filing_type,
        lien_number,
        filing_information,
        debtor_information,
        debtor_name,
        brs_maintenance_Address,
        Recovery_SelfCertify_PlaceholderCity,
        debtor_state,
        Recovery_SelfCertify_PlaceholderBusinessZipCode,
        securedParty_information,
        securedParty_name,
        BRS_UCC_Assignor_Label,
        lien_type,
        BRS_UCC_Debtor_Label,
        BRS_UCC_Secured_Party_Label,
        microfilm_Volume_Number,
        page_s,
        Adddebtor_name,
        AddsecuredParty_name,
        Review_MasterLabel_Type_Owner,
        Judgment_Debtor_Label,
        Review_MasterLabel_Type_Claimant,
        Judgment_Creditor_Label_Title_Case,
        Secured_Party_Label,
        help_head,
        help_body,
        help_amend,
        help_request,
        amend_link,
        irs_number,
        brs_Digitalcopy,
        brs_ViewasPDF,
        Start_page,
        None,
        Label_Address,
        Filing_information_Label
    }

    get className() {
        if (this.readFillingFromUrl) {
            return 'slds-col slds-size_12-of-12 slds-large-size_9-of-12 filling-info-container'
        }
        return 'slds-col slds-size_12-of-12 slds-large-size_7-of-12 filling-info-container'
    }
    connectedCallback() {
        if (!this.readFillingFromUrl) {
            let sPageURL = decodeURIComponent(window.location.search.substring(1));
            let sURLVariables = sPageURL.split('?');
            this.FilingNumber = sURLVariables ? sURLVariables[0] : this.FilingNumber;
        }
        this.getAll();
    }
    getAll() {
        this.isLoading = true;
        let filingInfo;
        getUCCRelatedRecords({
            FilingNumber: this.FilingNumber
        })
            .then(result => {
                this.isLoading = false;
                if (result && result.length) {
                    this.allRecords = result;
                    filingInfo = result[0].FilingRec;
                    this.filingInfo = this.modifyFilingsData(filingInfo);
                    this.viewLink = result[0].publicLink;
                    this.filterRecords();
                }
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "AllRecords",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });

    }
    filterRecords() {
        const records = this.filingInfo;
        this.debtorRecord = records.relatedList.filter(info => [BRS_UCC_Debtor_Label, Review_MasterLabel_Type_Owner, Judgment_Debtor_Label, BRS_UCC_Defendant_Label].includes(info.Type)).map((result) => {
            if (result.Unit) {
                return {
                    ...result,
                    Street__c: result.Street + ', ' + result.Unit
                }
            }
            return result;
        });
        this.securedPartyRecord = records.relatedList.filter(info => [Secured_Party_Label, Review_MasterLabel_Type_Claimant, Judgment_Creditor_Label_Title_Case, BRS_UCC_Plaintiff_Label].includes(info.Type)).map((result) => {
            if (result.Unit) {
                return {
                    ...result,
                    Street__c: result.Street + ', ' + result.Unit
                }
            }
            return result;
        });
        if (this.debtorRecord && this.debtorRecord.length > 0) {
            this.isdebtor = true;
        }
        if (this.securedPartyRecord && this.securedPartyRecord.length > 0) {
            this.isSecuredParty = true;
        }

    }

    modifyFilingsData(filing){
        let lienDetails;
        lienDetails =  filing.UCC_Lien_Id__r;
        const lapseDate = filing.LapseDate ? filing.LapseDate : this.label.None;
        this.isLapseDatePresent = filing.LapseDate ? true : false;
        lienDetails = {
            ...lienDetails,
            LapseDate :lapseDate
        }
        filing = {
            ...filing,
            UCC_Lien_Id__r: lienDetails
        }
        return filing;
    }

}
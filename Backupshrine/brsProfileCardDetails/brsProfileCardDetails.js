/**
 * @File Name          : brsProfileCardDetails
 * @Description        : Displays Profile Details
 * @Author             : Sibashrit Pattnaik
 * @Last Modified By   : Sibashrit Pattnaik
 * @Last Modified On   : 25.01.2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    25.01.2021        Sibashrit Pattnaik      Initial Version
 **/
import {
    LightningElement,
    api,
    track
} from 'lwc';
import getBusinessDetails from '@salesforce/apex/brs_filingDueController.getBusinessWithFiling';
import {
    ComponentErrorLoging
} from "c/formUtility";
import Business_ID from "@salesforce/label/c.Business_AELI";
import Name from "@salesforce/label/c.Recovery_SelfCertify_BusinessNameLabel";
import profileCard_Filing_Year from "@salesforce/label/c.profileCard_Filing_Year";
import profileCard_Filing_Fee from "@salesforce/label/c.profileCard_Filing_Fee";
import profileCard_Status from "@salesforce/label/c.profileCard_Status";
import profileCard_Empty_Status from "@salesforce/label/c.profileCard_Empty_Status";
import Annual_Report_Label from "@salesforce/label/c.Annual_Report_Label";
import brs_ObtainCertFlow from "@salesforce/label/c.brs_ObtainCertFlow";
import BRS_First_Report from "@salesforce/label/c.BRS_First_Report";
import Due_Date from "@salesforce/label/c.Due_Date";
import foreignInvestigation from "@salesforce/label/c.foreign_investigation_comparable";

export default class BrsProfileCardDetails extends LightningElement {
    @api itemdata;
    @api accountId;
    @api filingId;
getFilingId(){
    return this.filingId;
}

setFilingId(value){
     this.filingId=value;
}

    @api reportType;
    @track compName = "brsProfileCardDetails";
    @track isAnnual = false;
    @track isFirst = false;
    @track isObtainCert = false;
    label = {
        Business_ID,
        Name,
        profileCard_Filing_Year,
        profileCard_Filing_Fee,
        profileCard_Status,
        profileCard_Empty_Status,
        Annual_Report_Label,
        brs_ObtainCertFlow,
        BRS_First_Report,
        Due_Date,
		foreignInvestigation
    };
    connectedCallback() {
        getBusinessDetails({
            accountId: this.accountId,
            filingId: this.filingId,
            reportType: this.reportType
        })
        .then((result) => {
            this.itemdata = result;
                this.isFirst = (this.reportType === this.label.BRS_First_Report);
                this.isAnnual = (this.reportType === this.label.Annual_Report_Label);
                if(this.reportType === this.label.brs_ObtainCertFlow || this.reportType === this.label.foreignInvestigation){
                    this.isObtainCert = true;
                }
          })
        .catch((error) => {
            ComponentErrorLoging(
                this.compName,
                "getBusinessDetails",
                "",
                "",
                "Medium",
                error.message
            );
        });
    }
    @api
updateProfileRecord(filingID){
    if(filingID!== null && filingID!== undefined){
        this.filingId = filingID;
        this.connectedCallback();
    }
}
}
import { LightningElement, api, track } from 'lwc';
import { insertAnalytics } from "c/genericAnalyticsRecord";
import Business_Registration_Compare from '@salesforce/label/c.Business_Registration_Compare';
import UCC_Comparable from '@salesforce/label/c.UCC_Comparable';
import Annual_Report_Comparable from '@salesforce/label/c.Annual_Report_Comparable';
import FR_Comparable from '@salesforce/label/c.FR_Comparable';
import First_Annual_Report_Resume_Comparable from '@salesforce/label/c.First_Annual_Report_Resume_Comparable';
import Interim_Notice_Comparable from '@salesforce/label/c.Interim_Notice_Comparable';
import Change_Business_Address_Comparable from '@salesforce/label/c.Change_Business_Address_Comparable';
import Name_Change_Amendment_Comparable from '@salesforce/label/c.Name_Change_Amendment_Comparable';
import Change_Business_Email_Address_Comparable from '@salesforce/label/c.Change_Business_Email_Address_Comparable';
import Change_Business_NAICS_Code_Comparable from '@salesforce/label/c.Change_Business_NAICS_Code_Comparable';
import Change_Agent_Comparable from '@salesforce/label/c.Change_Agent_Comparable';
import Change_of_Agent_Address_Comparable from '@salesforce/label/c.Change_of_Agent_Address_Comparable';
import Agent_Resignation_Comparable from '@salesforce/label/c.Agent_Resignation_Comparable';
import Request_Copy_Comparable from '@salesforce/label/c.Request_Copy_Comparable';
import Obtain_Certificate_Comparable from '@salesforce/label/c.Obtain_Certificate_Comparable';
import Verify_Certificate_Comparable from '@salesforce/label/c.Verify_Certificate_Comparable';
import Revocation_Of_Dissolution_Comparable from '@salesforce/label/c.Revocation_Of_Dissolution_Comparable';
import Close_Business_Comparable from '@salesforce/label/c.Close_Business_Comparable';
import ForeignInvestigationComparable from '@salesforce/label/c.ForeignInvestigationComparable';
import Request_For_Information_Comparable from '@salesforce/label/c.Request_For_Information_Comparable';

export default class Brs_header extends LightningElement {
    @api subHeadingText;
    @api descriptionText;
    @api descriptionTextSecondLine;
    @api descriptionText1; // dont use this
    @api showScholarOnly = false;
    @api scholarContent;
    @track showSubHeading = false;
    @track showScholarContent = false;
    @track showExtraDescriptionText = false;
    @track startTime;
    @api
    get headingText() {
        return this._headingText;
    }

    set headingText(value) {
        this._headingText = value;
    }

    @api theme;

    get className() {
        return this.theme;
    }

    label = {
        Business_Registration_Compare,
        UCC_Comparable,
        Annual_Report_Comparable,
        FR_Comparable,
        First_Annual_Report_Resume_Comparable,
        Interim_Notice_Comparable,
        Change_Business_Address_Comparable,
        Name_Change_Amendment_Comparable,
        Change_Business_Email_Address_Comparable,
        Change_Business_NAICS_Code_Comparable,
        Change_Agent_Comparable,
        Change_of_Agent_Address_Comparable,
        Agent_Resignation_Comparable,
        Request_Copy_Comparable,
        Obtain_Certificate_Comparable,
        Verify_Certificate_Comparable,
        Revocation_Of_Dissolution_Comparable,
        Close_Business_Comparable,
        ForeignInvestigationComparable,
        Request_For_Information_Comparable
    }

    connectedCallback() {
        this.startTime = new Date().getTime();
        if (this.subHeadingText) {
            this.showSubHeading = true;
        }
        if (this.scholarContent) {
            this.showScholarContent = true;
        }
        if (this.descriptionTextSecondLine) {
            this.showExtraDescriptionText = true;
        }
        if (this.descriptionText && this.descriptionTextSecondLine) {
            this.descriptionText += " ";
        }
        setTimeout(() => {
            let heading = this.template.querySelector('h1.mainheading');
            if (heading) { heading.focus() }
        }, 300);
    }
    disconnectedCallback() {
        insertAnalytics({
            flowName: this.getFlowNameByUrl(),
            startTime: this.startTime,
            questionLabel: this.subHeadingText ? this.subHeadingText : this.headingText
        });
    }
    getFlowNameByUrl(){
        const url = window.location.href;
        let flowName = url;
        if (url.includes("brsflow")) {
            flowName = this.label.Business_Registration_Compare;
        } else if (url.includes("uccmainflow")) {
            flowName = this.label.UCC_Comparable;
        } else if (url.includes("businessfiling?rt=ar")) {
            flowName = this.label.Annual_Report_Comparable;
        } else if (url.includes("businessfiling?rt=fr")) {
            flowName = this.label.FR_Comparable;
        } else if (url.includes("businessfiling")) {
            flowName = this.label.First_Annual_Report_Resume_Comparable;
        } else if (url.includes("interimnotice")) {
            flowName = this.label.Interim_Notice_Comparable;
        } else if (url.includes("addresschange")) {
            flowName = this.label.Change_Business_Address_Comparable;
        } else if (url.includes("name-change-amendment")) {
            flowName = this.label.Name_Change_Amendment_Comparable;
        } else if (url.includes("emailchange")) {
            flowName = this.label.Change_Business_Email_Address_Comparable;
        } else if (url.includes("naicschange")) {
            flowName = this.label.Change_Business_NAICS_Code_Comparable;
        } else if (url.includes("agentchange")) {
            flowName = this.label.Change_Agent_Comparable;
        } else if (url.includes("changeagentaddress")) {
            flowName = this.label.Change_of_Agent_Address_Comparable;
        } else if (url.includes("agentresignation")) {
            flowName = this.label.Agent_Resignation_Comparable;
        } else if (url.includes("request-for-copy")) {
            flowName = this.label.Request_Copy_Comparable;
        } else if (url.includes("obtaincertificate")) {
            flowName = this.label.Obtain_Certificate_Comparable;
        } else if (url.includes("verifycertificate")) {
            flowName = this.label.Verify_Certificate_Comparable;
        } else if (url.includes("revocation-of-dissolution")) {
            flowName = this.label.Revocation_Of_Dissolution_Comparable;
        } else if (url.includes("closebusiness")) {
            flowName = this.label.Close_Business_Comparable;
        } else if (url.includes("foreign-investigation")) {
            flowName = this.label.ForeignInvestigationComparable;
        } else if (url.includes("request-for-information")) {
            flowName = this.label.Request_For_Information_Comparable;
        }
        return flowName;
    } 
    toggleSection() {
        var desc = this.template.querySelector("[data-id='desc']");
        var chevron = this.template.querySelector(".chevron-icon");
        const helpTextContainer = this.template.querySelector(".helptext-mob-header");
        if (desc.classList.contains("active")) {
            desc.classList.remove("active");
            chevron.classList.add("chevron-up");
            helpTextContainer.classList.add("helpText-opened");
            desc.classList.add("helptext-details");
        } else {
            desc.classList.add("active");
            chevron.classList.remove("chevron-up");
            helpTextContainer.classList.remove("helpText-opened");
            desc.classList.remove("helptext-details");
        }
    }
}
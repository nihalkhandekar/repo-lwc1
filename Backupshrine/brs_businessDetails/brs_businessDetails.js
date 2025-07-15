import {
    LightningElement,
    track,
    api
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import brsAssetFolder from "@salesforce/resourceUrl/BRS_Assets";
import None from '@salesforce/label/c.None';
import business_name_search from '@salesforce/label/c.business_name_search';
import businessProfile_bstatus from '@salesforce/label/c.businessProfile_bstatus';
import businessProfile_state from '@salesforce/label/c.businessProfile_state';
import brs_Business_Address from '@salesforce/label/c.brs_Business_Address';
import Annual_Report_Due1 from '@salesforce/label/c.Annual_Report_Due1';
import brs_NAICcode from '@salesforce/label/c.brs_NAICcode';
import Start_page from '@salesforce/label/c.Start_page';


import Business_ID from '@salesforce/label/c.Business_AELI';
import businessProfile_bdate from '@salesforce/label/c.businessProfile_bdate';
import BRSFirstScreen from '@salesforce/label/c.BRSFirstScreen';
import BRS_Location_MailingAddr from '@salesforce/label/c.BRS_Location_MailingAddr';
import brs_Lastreportfiled from '@salesforce/label/c.brs_Lastreportfiled';
import brs_NAICsubcode from '@salesforce/label/c.brs_NAICsubcode';

import Business_Details from '@salesforce/label/c.Business_Details';
import businessProfile_generalInfo from '@salesforce/label/c.businessProfile_generalInfo';
import businessProfile_principal from '@salesforce/label/c.businessProfile_principal';
import brs_PrincipalName from '@salesforce/label/c.brs_PrincipalName';
import brs_PrincipalTitle from '@salesforce/label/c.brs_PrincipalTitle';
import brs_PrincipalBusinessaddress from '@salesforce/label/c.brs_PrincipalBusinessaddress';

import brs_PrincipalResidenceaddress from '@salesforce/label/c.brs_PrincipalResidenceaddress';
import brs_AgentChange_AgentScreenHeading from '@salesforce/label/c.brs_AgentChange_AgentScreenHeading';
import Agent_Name from '@salesforce/label/c.Agent_Name';
import brs_AgentBusinessaddress from '@salesforce/label/c.brs_AgentBusinessaddress';
import brs_AgentMailingaddress from '@salesforce/label/c.brs_AgentMailingaddress';
import brs_AgentResidenceaddress from '@salesforce/label/c.brs_AgentResidenceaddress';


import brs_FilingHistory from '@salesforce/label/c.brs_FilingHistory';
import filing_date from '@salesforce/label/c.filing_date';
import brs_VolumeType from '@salesforce/label/c.brs_VolumeType';
import brs_Volume from '@salesforce/label/c.brs_Volume';
import brs_Pages from '@salesforce/label/c.brs_Pages';
import brs_TerminatedbusinessID from '@salesforce/label/c.brs_TerminatedbusinessID';

import brs_Terminatedbusinessname from '@salesforce/label/c.brs_Terminatedbusinessname';
import BRS_Date_Generated from '@salesforce/label/c.BRS_Date_Generated';
import brs_Digitalcopy from '@salesforce/label/c.brs_Digitalcopy';
import brs_ViewasPDF from '@salesforce/label/c.brs_ViewasPDF';
import brs_NameHistory from '@salesforce/label/c.brs_NameHistory';
import brs_Shares from '@salesforce/label/c.brs_Shares';
import brs_Valuepershare from '@salesforce/label/c.brs_Valuepershare';
import brs_SharesClass from '@salesforce/label/c.brs_SharesClass';
import filing_number_search from '@salesforce/label/c.filing_number_search';
import brs_totalshares from '@salesforce/label/c.brs_totalshares';
import BRS_Location_SOPAddr from '@salesforce/label/c.BRS_Location_SOPAddr';
import BRS_Location_JurisdictionOffice from '@salesforce/label/c.BRS_Location_JurisdictionOffice';
import Mailing_address_state_of_formation from '@salesforce/label/c.Mailing_address_state_of_formation';
import Filing_time from '@salesforce/label/c.Filing_time';
export default class Brs_businessDetails extends LightningElement {
    @api businessDetails;
    @api scholerContent;
    @track activeIcon = assetFolder + "/icons/license-active.svg";
    @track passiveIcon = assetFolder + "/icons/license-passive.svg";
    @track expandBusinessDetails = true;
    @track showGISubSection = true;
    @track showPDSubSection = true;
    @track showADSubSection = true;
    @track expandNH = true;
    @track expandShares = true;
    @track expandfh = true;
    @track tabHeader = "";
    @track tabClicked = false;
    @track tabList = [{
        label: Business_Details,
        icon: brsAssetFolder + "/icons/Business-Icon-Grey.svg",
        activeIcon: brsAssetFolder + "/icons/Business-Icon.svg"
    },
    {
        label: brs_FilingHistory,
        icon: brsAssetFolder + "/icons/Document-Icon-Grey.svg",
        activeIcon: brsAssetFolder + "/icons/Document-Icon.svg"
    },
    {
        label: brs_NameHistory,
        icon: brsAssetFolder + "/icons/Card-Icon-Grey.svg",
        activeIcon: brsAssetFolder + "/icons/Card-Icon.svg"
    },
    {
        label: brs_Shares,
        icon: brsAssetFolder + "/icons/Share-Icon-Grey.svg",
        activeIcon: brsAssetFolder + "/icons/Share-Icon.svg"
    }];
    @track label = {
        None, business_name_search, businessProfile_bstatus,
        businessProfile_state, brs_Business_Address, Annual_Report_Due1,
        brs_NAICcode, Business_ID, businessProfile_bdate, BRSFirstScreen,
        BRS_Location_MailingAddr, brs_Lastreportfiled, brs_NAICsubcode,
        Business_Details, businessProfile_generalInfo,
        businessProfile_principal, brs_PrincipalTitle, brs_PrincipalName,
        brs_PrincipalBusinessaddress, brs_PrincipalResidenceaddress,
        brs_AgentChange_AgentScreenHeading, Agent_Name, brs_AgentBusinessaddress,
        brs_AgentMailingaddress, brs_AgentResidenceaddress, brs_FilingHistory,
        filing_date, brs_VolumeType, brs_Volume, brs_Pages, brs_TerminatedbusinessID,
        brs_Terminatedbusinessname, BRS_Date_Generated, brs_Digitalcopy,
        brs_ViewasPDF, brs_NameHistory, brs_Valuepershare, brs_SharesClass,
        brs_Shares, filing_number_search, brs_totalshares,
        Start_page,BRS_Location_SOPAddr,BRS_Location_JurisdictionOffice,
        Mailing_address_state_of_formation,Filing_time
    }

    connectedCallback() {
        window.onscroll = () => {
            let tabContainer = this.template.querySelector('.tab-container');
            let stickysection = this.template.querySelector('.tab-list');
            if (tabContainer && stickysection) {
                let sticky2 = tabContainer.offsetTop;
                if (window.pageYOffset > sticky2) {
                    tabContainer.style.height = stickysection.getBoundingClientRect().height + "px";
                    stickysection.style.width = stickysection.getBoundingClientRect().width + "px";
                    stickysection.classList.add("sticky-header");
                } else {
                    stickysection.classList.remove("sticky-header");
                }
                const eachSection = this.template.querySelectorAll(".each-section");
                if (eachSection && !this.tabClicked) {
                    eachSection.forEach((ele, index) => {
                        if (ele.offsetTop - tabContainer.getBoundingClientRect().height <= window.pageYOffset) {
                            this.tabList = this.tabList.map((eachItem, i) => {
                                if (i == index) {
                                    this.tabHeader = eachItem.label;
                                }
                                return {
                                    ...eachItem,
                                    className: i == index ? "active" : ""
                                }
                            });
                        }
                    });
                }
            }
        }
        this.onResize();
    }
    onResize() {
        window.addEventListener('resize', () => {
            let tabContainer = this.template.querySelector('.tab-container');
            let stickysection = this.template.querySelector('.tab-list');
            if (tabContainer && stickysection) {
                stickysection.style.width = tabContainer.getBoundingClientRect().width + "px";
            }
        });
    }
    handleBDExpand() {
        this.expandBusinessDetails = !this.expandBusinessDetails;
    }
    expandGISubSection() {
        this.showGISubSection = !this.showGISubSection;
    }
    expandPDSubSection() {
        this.showPDSubSection = !this.showPDSubSection;
    }
    expandADSubSection() {
        this.showADSubSection = !this.showADSubSection;
    }
    handleNHsubExpand() {
        this.expandNH = !this.expandNH;
    }
    handleSharessubExpand() {
        this.expandShares = !this.expandShares;
    }
    handlefhsubExpand() {
        this.expandfh = !this.expandfh;
    }

    @api gotoPrincipals() {
        let sectionElement = this.template.querySelector(".principal-details");
        let tabContainer = this.template.querySelector('.tab-container');
        if (sectionElement && tabContainer) {
            window.scroll({ top: (sectionElement.offsetTop - tabContainer.getBoundingClientRect().height), behavior: 'smooth' });
        }
    }

    onTabClick(event) {
        this.tabClicked = true;
        let scrollToEle;
        switch (event.detail) {
            case "0":
                scrollToEle = ".business-details-header";
                break;
            case "1":
                scrollToEle = ".filing-history-header";
                break;
            case "2":
                scrollToEle = ".name-history-header";
                break;
            case "3":
                scrollToEle = ".shares-header";
                break;
        }
        let tabContainer = this.template.querySelector('.tab-container');
        const el = this.template.querySelector(scrollToEle);
        if (tabContainer && el) {
            window.scroll({ top: (el.offsetTop - tabContainer.getBoundingClientRect().height), behavior: 'smooth' });
        }
        setTimeout(() => {
            this.tabClicked = false;
        }, 1500);
    }

    onViewDetails(event) {
        const details = new CustomEvent("viewdetails", { detail: event.detail });
        this.dispatchEvent(details);
    }
}
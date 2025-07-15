import {
    LightningElement,
    track,
    api
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import businessProfile_generalInfo from '@salesforce/label/c.businessProfile_generalInfo';
import brs_FilingHistory from '@salesforce/label/c.brs_FilingHistory';
import filing_date from '@salesforce/label/c.filing_date';
import None from '@salesforce/label/c.None';
import brs_Volume from '@salesforce/label/c.brs_Volume';
import brs_Pages from '@salesforce/label/c.brs_Pages';
import Start_page from '@salesforce/label/c.Start_page';
import brs_Digitalcopy from '@salesforce/label/c.brs_Digitalcopy';
import brs_ViewasPDF from '@salesforce/label/c.brs_ViewasPDF';
import showMoreResults from "@salesforce/label/c.show_more_results";
import Mark_Information from "@salesforce/label/c.Mark_Information";
import Registration_number from "@salesforce/label/c.Registration_number";
import Class_of_goods_services from "@salesforce/label/c.Class_of_goods_services";
import Registration_date from "@salesforce/label/c.Registration_date";
import Description_of_mark from "@salesforce/label/c.Description_of_mark";
import Date_of_1st_use_in_CT from "@salesforce/label/c.Date_of_1st_use_in_CT";
import Renewal_date from "@salesforce/label/c.Renewal_date";
import First_Expiration_date from "@salesforce/label/c.First_Expiration_date";
import Disclaimer from "@salesforce/label/c.Disclaimer";
import Mark_used_for from "@salesforce/label/c.Mark_used_for";
import Mark_type from "@salesforce/label/c.Mark_type";
import Date_of_1st_use_anywhere from "@salesforce/label/c.Date_of_1st_use_anywhere";
import Expiration_date from "@salesforce/label/c.Expiration_date";
import Keywords from "@salesforce/label/c.Keywords";
import Method_of_use from "@salesforce/label/c.Method_of_use";
import Owner_information from "@salesforce/label/c.Owner_information";
import Owner_name from "@salesforce/label/c.Owner_name";
import State_Country_of_Formation from "@salesforce/label/c.State_Country_of_Formation";
import Owner_address from "@salesforce/label/c.Owner_address";
import Owner_type from "@salesforce/label/c.Owner_type";
import Partner_names from "@salesforce/label/c.Partner_names";
import Mark_History from "@salesforce/label/c.Mark_History";
import Filing_number_label from "@salesforce/label/c.Filing_number_label";
import Mark_image from "@salesforce/label/c.Mark_image";
import View_mark from "@salesforce/label/c.View_mark";
import No_of_pages from "@salesforce/label/c.No_of_pages";
import Individual_comparable from "@salesforce/label/c.Individual_comparable";


export default class Brs_tradeAndServiceMarkDetails extends LightningElement {
    @api details;
    @api scholerContent;
    @track activeIcon = assetFolder + "/icons/lien-active.svg";
    @track loadMoreIcon = assetFolder + "/icons/duplicate-outline.png";
    @track expandBusinessDetails = false;
    @track showGISubSection = false;
    @track showPDSubSection = false;
    @track expandNH = false;
    @track expandfh = false;
    @track isIndividualType = false;
    @track hasMarkHistory = false;
    @track hasFilingHistory = false;

    @track label = {
        businessProfile_generalInfo,
        brs_FilingHistory,
        filing_date,
        None,
        brs_Volume,
        brs_Pages,
        Start_page,
        brs_Digitalcopy,
        brs_ViewasPDF,
        showMoreResults,
        Mark_Information,
        Registration_number,
        Class_of_goods_services,
        Registration_date,
        Description_of_mark,
        Date_of_1st_use_in_CT,
        Renewal_date,
        First_Expiration_date,
        Disclaimer,
        Mark_used_for,
        Mark_type,
        Date_of_1st_use_anywhere,
        Expiration_date,
        Keywords,
        Method_of_use,
        Owner_information,
        Owner_name,
        State_Country_of_Formation,
        Owner_address,
        Owner_type,
        Partner_names,
        Mark_History,
        Filing_number_label,
        Mark_image,
        View_mark,
        No_of_pages,
        Individual_comparable
    }

    connectedCallback() {
        if (this.details && this.details.ownerType === this.label.Individual_comparable) {
            this.isIndividualType = true;
        }
        this.hasFilingHistory = this.details.filingHistory && this.details.filingHistory.length > 0;
        this.hasMarkHistory = this.details.markHistory && this.details.markHistory.length > 0;
    }

    @api printPdf() {
        this.expandBusinessDetails = true;
        this.showGISubSection = true;
        this.showPDSubSection = true;
        this.expandNH = true;
        this.expandfh = true;
        this.details = {
            ...this.details,
            filingHistory: this.details.filingHistory.map((filer) => {
                return {
                    ...filer,
                    show: true
                };
            })
        };
        setTimeout(() => {
            const allCards = this.template.querySelectorAll("c-brs_filing-cards");
            if (allCards && allCards.length > 0) {
                allCards.forEach((ele) => {
                    ele.handleExpandByParent();
                });
            }
        }, 100);

        setTimeout(() => {
            window.print();
        }, 300)
    }


    handleBDExpand() {
        this.expandBusinessDetails = !this.expandBusinessDetails;
    }
    handleBDExpandKeyPress(event) {
        var charCode = event.keyCode || event.which;
        if (charCode === 13) {
            this.handleBDExpand();
        }
    }
    expandGISubSection() {
        this.showGISubSection = !this.showGISubSection;
    }
    expandGISubSectionKeyPress(event) {
        var charCode = event.keyCode || event.which;
        if (charCode === 13) {
            this.expandGISubSection();
        }
    }
    expandPDSubSection() {
        this.showPDSubSection = !this.showPDSubSection;
    }
    expandPDSubSectionKeyPress(event) {
        var charCode = event.keyCode || event.which;
        if (charCode === 13) {
            this.expandPDSubSection();
        }
    }
    handleNHsubExpand() {
        this.expandNH = !this.expandNH;
    }
    handleNHsubExpandKeyPress(event) {
        var charCode = event.keyCode || event.which;
        if (charCode === 13) {
            this.handleNHsubExpand();
        }
    }
    handlefhsubExpand() {
        this.expandfh = !this.expandfh;
        if (this.details.filingHistory && this.details.filingHistory.length > 0) {
            this.details = {
                ...this.details,
                filingHistory: this.details.filingHistory.map((filing, index) => {
                    return {
                        ...filing,
                        show: index < 5
                    }
                })
            }
        }
    }
    handlefhsubExpandKeyPress(event) {
        var charCode = event.keyCode || event.which;
        if (charCode === 13) {
            this.handlefhsubExpand();
        }
    }

    showFewMoreItems() {
        let hideItemsStartIndex;
        this.details = {
            ...this.details,
            filingHistory: this.details.filingHistory.map((filer, index) => {
                if (filer.show) {
                    return { ...filer };
                } else {
                    if (!hideItemsStartIndex) {
                        hideItemsStartIndex = index;
                    }
                    return {
                        ...filer,
                        show: index < hideItemsStartIndex + 5
                    };
                }
            })
        }
    }

    showFewMoreItemsKeyPress(event) {
        var charCode = event.keyCode || event.which;
        if (charCode === 13) {
            this.showFewMoreItems();
        }
    }

    get hasMoreBusiness() {
        if (this.details.filingHistory && this.details.filingHistory.length > 0) {
            let hideFilings = this.details.filingHistory.filter((filing) => !filing.show);
            return hideFilings.length !== 0;
        }
        return false;
    }
}
import { LightningElement, track, api } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import None from '@salesforce/label/c.None';
import businessProfile_show_less from "@salesforce/label/c.businessProfile_show_less";
import Reg_No_Comparable from "@salesforce/label/c.Reg_No_Comparable";
import Registration_date from "@salesforce/label/c.Registration_date";
import Description_of_mark from "@salesforce/label/c.Description_of_mark";
import showMore from "@salesforce/label/c.showMore";
import Show_Details from "@salesforce/label/c.Show_Details";
import Hide_Details from "@salesforce/label/c.Hide_Details";

export default class Brs_tradeAndServiceMarkCard extends LightningElement {
    @track locationIcon = assetFolder + "/icons/location-passive.svg";
    @track arrowIcon = assetFolder + "/icons/chevron-right-blue.svg";
    @api allTradeAndService = [];
    @track label = {
        None,
        businessProfile_show_less,
        Reg_No_Comparable,
        Registration_date,
        Description_of_mark,
        showMore,
        Show_Details,
        Hide_Details
    }

    //Trade accordian
    onAccordianClick(event) {
        event.stopPropagation();
        var index = Number(event.currentTarget.dataset.name);
        this.allTradeAndService = this.allTradeAndService.map((trade, i) => {
            const hasShowMore = trade.descOfMark ? trade.descOfMark.length >= 100 : false;
            return {
                ...trade,
                showDetails: trade.showDetails ? false : (i === index),
                hasShowMore,
                showLess: false,
                description: hasShowMore ? trade.descOfMark.substring(0, 100) : trade.descOfMark
            }
        });
    }

    //onclick of trade card, show selected trade details
    showTSDetails(event) {
        var index = Number(event.currentTarget.dataset.name);
        if (this.allTradeAndService[index].recordId) {
            const recordId = new CustomEvent("showdetails", {
                detail: this.allTradeAndService[index].recordId
            });
            this.dispatchEvent(recordId);
        }
    }

    showTSDetailsKeyPress(event) {
        var charCode = event.keyCode || event.which;
        if (charCode === 13) {
            this.showTSDetails(event);
        }
    }

    onShowMoreText(event) {
        event.stopPropagation();
        this.allTradeAndService = this.allTradeAndService.map((trade, i) => {
            return {
                ...trade,
                showLess: true,
                description: trade.descOfMark
            }
        });
    }

    onShowLessText(event) {
        event.stopPropagation();
        this.allTradeAndService = this.allTradeAndService.map((trade, i) => {
            return {
                ...trade,
                showLess: false,
                description: trade.descOfMark.substring(0, 100)
            }
        });
    }
}
import {
    LightningElement,
    track,
    api
} from 'lwc';

import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import no_active_liens from "@salesforce/label/c.no_active_liens";
import no_lapsed_liens from "@salesforce/label/c.no_lapsed_liens";
import Show_More from "@salesforce/label/c.Show_More";
import Lapsed_Liens_Label from "@salesforce/label/c.LapsedLiens";
import Active_Liens_Label from "@salesforce/label/c.ActiveLiens";
import None from "@salesforce/label/c.None";

export default class Brs_lienSearchResults extends LightningElement {
    @track showMore = assetFolder + "/icons/duplicate-outline.png";
    @track debtorLabel = "Debtor of UCC Liens:";
    // @track dropDownOpts= ["name", "date", "time"];
    @track compName = 'brs_lienSearchResults';
    @api debtorList;
    @api lienList;
    @track activeLienList = [];
    @track lapsedLienList = [];
    @track activeLienListBkp = [];
    @track lapsedLienListBkp = [];
    @track showDebtor = true;
    @track activeLoadMore = false;
    @track lapsedLoadMore = false;
    @track lapsedLength = 50;
    @track activeLength = 50;

    labels = {
        no_active_liens,
        no_lapsed_liens,
        Show_More,
        Lapsed_Liens_Label,
        Active_Liens_Label,
        None
    }

    connectedCallback() {
        this.showliens();
    }
    showliens() {
        this.showDebtor = false;
        if (this.lienList && this.lienList.length) {
            this.lienList.forEach(element => {
                element = {
                    ...element,
                    lapseDate: element.lapseDate ?  element.lapseDate: this.labels.None
                }
                if (element.activeLien) {
                    this.activeLienListBkp.push(element)
                }
                if (element.LapsedLien) {
                    this.lapsedLienListBkp.push(element)
                }
            })
        }
        this.updateActiveList();
        this.updateLapsedList();
    }
    showMoreActive() {
        this.activeLength = this.activeLength + 50;
        this.updateActiveList();
    }
    showMoreActiveKey(event){
        if (event.keyCode == 13) {
            this.showMoreActive();
        }
    }
    showMoreLapsed() {
        this.lapsedLength = this.lapsedLength + 50;
        this.updateLapsedList();
    }
    showMoreLapsedKey(event){
        if (event.keyCode == 13) {
            this.showMoreLapsed();
        }
    }
    updateActiveList() {
        this.activeLienList = [];
        if (this.activeLienListBkp && this.activeLienListBkp.length) {
            let count = 0;
            this.activeLienListBkp.forEach(active => {
                if (count < this.activeLength) {
                    this.activeLienList.push(active);
                    count++;
                    this.activeLoadMore = false;
                } else {
                    this.activeLoadMore = true;
                }
            });

        }
    }
    updateLapsedList() {
        this.lapsedLienList = [];
        if (this.lapsedLienListBkp && this.lapsedLienListBkp.length) {
            let count = 0;
            this.lapsedLienListBkp.forEach(lapsed => {
                if (count < this.lapsedLength) {
                    this.lapsedLienList.push(lapsed);
                    count++;
                    this.lapsedLoadMore = false
                } else {
                    this.lapsedLoadMore = true;
                }
            });

        }
    }

    // showliens(event){
    //     console.log('Inside showliens',JSON.stringify(event.detail));
    //     const lienIds = event.detail;
    //     getAllLiens({LienIds: lienIds}).then((data) => {
    //         if(data){
    //             console.log('Inside getAllLiens', JSON.stringify(data));
    //         }
    //     }).catch(error => {
    //         ComponentErrorLoging(
    //             this.compName,
    //             "getAllLiens",
    //             "",
    //             "",
    //             "Medium",
    //             error.message
    //         );
    //     })
    // }

    viewFillingInfo(event) {
        const viewfillingEvent = new CustomEvent("debtorfilling", {
            detail: event.detail
        });
        this.dispatchEvent(viewfillingEvent);
    }
}
import { LightningElement, track, api } from 'lwc';

export default class SepTopNavigation extends LightningElement {
    @api pageTitle = "";
    @api tabList = [];
    @track currentPageName = "";
    @track activePageName = "";

    @api
    get currentPage() {
        return this.currentPageName;
    }

    set currentPage(value) {
        this.currentPageName = value;
        this.activeNavByCurrentPage(value);
    }

    activeNavByCurrentPage() {
        let foundActive = false;
        this.tabList = this.tabList.map((tab) => {
            let className = "";
            if (tab.value === this.currentPageName) {
                foundActive = true; 
                this.activePageName = tab.label;          
                className = "active";               
            } else if (!foundActive) {              
                className = "complete";                
            }
            return {
                ...tab,
                className
            }
        })
    }
}
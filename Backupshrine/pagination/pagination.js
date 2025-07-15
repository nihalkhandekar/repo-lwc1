import { LightningElement,api, track } from 'lwc';

export default class Pagination2 extends LightningElement {
    
    @api pageSize = 10;
    @track totalrecordscount = 0;
    @track clickedPage = 1;
    @track totalpages = 0;

    connectedCallback() {
        this.calculateTotalPages();
    }

    @api 
    get totalrecords() {
        return this.totalrecordscount;
    }
    
    set totalrecords(value) {
        this.totalrecordscount = value;
        this.calculateTotalPages();
    }

    get disableleftarrow() {
        return this.clickedPage === 1;
    }

    get disablerightarrow() {
        return this.clickedPage === this.totalpages || this.totalpages === 0;
    }

    handlePrevious(event) {
        if (this.clickedPage > 1) {
            this.clickedPage -= 1;
            this.dispatchPaginationevent();
        }
    }

    handleNext(event) {
        if (this.clickedPage < this.totalpages) {
            this.clickedPage += 1;
            this.dispatchPaginationevent();
        }
    }

    handlePageInput(event) {
        let page = Number(event.target.value);
        if (page >= 1 && page <= this.totalpages) {
            this.clickedPage = page;
            this.dispatchPaginationevent();
        } else {
            event.target.value = this.clickedPage; // Reset to valid value if out of range
        }
    }

    handlePageSizeChange(event) {
        this.pageSize = Number(event.target.value);
        this.calculateTotalPages();
        this.clickedPage = 1; // Reset to the first page on page size change
        this.dispatchPaginationevent();
    }

    calculateTotalPages() {
        if (this.totalrecordscount > 0 && this.pageSize > 0) {
            console.log('total records'+this.totalrecordscount+'pagesSize is '+this.pageSize);
            this.totalpages = Math.ceil(this.totalrecordscount / this.pageSize);
            console.log('page size is other than 0');

        } else {
            this.totalpages = 0;
            console.log('page size is &&&'+this.totalpages);
        }
    }

    dispatchPaginationevent() {
        this.dispatchEvent(new CustomEvent('pagination', {
            detail: {
                page: this.clickedPage,
                pageSize: this.pageSize
            },
            bubbles: true,
            composed: true
        }));
    }
}
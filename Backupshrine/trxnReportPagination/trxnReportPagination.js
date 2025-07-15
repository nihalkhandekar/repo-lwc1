import { LightningElement, api, track } from 'lwc';

export default class TrxnReportPagination extends LightningElement {
    @api currentPage = 1;
    @api pageSize = 10;
    @api totalPages = 0;
    @api disableLeftArrow = false;
    @api disableRightArrow = false;

    handlePageSizeChange(event) {
        this.dispatchEvent(new CustomEvent('pagesizechange', { detail: parseInt(event.target.value, 10) }));
    }

    handlePageInput(event) {
        const inputPage = parseInt(event.target.value, 10);
        if (inputPage >= 1 && inputPage <= this.totalPages) {
            this.dispatchEvent(new CustomEvent('pageinput', { detail: inputPage }));
        }
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.dispatchEvent(new CustomEvent('previouspage'));
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.dispatchEvent(new CustomEvent('nextpage'));
        }
    }
}
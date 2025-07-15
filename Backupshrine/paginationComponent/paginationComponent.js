import { LightningElement, api, track } from 'lwc';

export default class PaginationComponent extends LightningElement {
    @api records; // Data passed from parent
    @api pageSize; // Page size passed from parent
    @api currentPage; // Current page number passed from parent
    @api totalPages; // Total number of pages passed from parent
    @api disableLeftArrow; // Disable state for left arrow
    @api disableRightArrow; // Disable state for right arrow

    handlePageSizeChange(event) {
        const selectedPageSize = parseInt(event.target.value, 10);
        this.dispatchEvent(new CustomEvent('pagesizechange', { detail: selectedPageSize }));
    }

    handlePageInput(event) {
        const inputPage = parseInt(event.target.value, 10);
        if (inputPage >= 1 && inputPage <= this.totalPages) {
            this.dispatchEvent(new CustomEvent('pagechange', { detail: inputPage }));
        }
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.dispatchEvent(new CustomEvent('pagechange', { detail: this.currentPage - 1 }));
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.dispatchEvent(new CustomEvent('pagechange', { detail: this.currentPage + 1 }));
        }
    }
}
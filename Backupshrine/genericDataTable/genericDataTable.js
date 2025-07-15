import { LightningElement, track, api } from 'lwc';

export default class GenericDataTable extends LightningElement {

    @api buttonLimit;
    @api genericdata;
    @api generichidecheckbox;
    @api noOfRecordsPerPage;
    @api modalTheme = false;
    @api messageheader;
    @api messagetext;
    @api searchlength;
    @api actuallength;
    @api showAttentionCard = false;
    @track showPagination = true;
    @api currentPage = 1;
    @track pageListToShow = [];
    @track paginatedData = [];
    @track themeClass = "";
    pageListFirst;
    pageListLast;
    pageNumberList = [];
    showFirstDot;
    showNextDot;

    @api
    setRadioCheckedValue(index) {
        this.paginatedData = this.paginatedData.map((item) => {
            return {
                ...item,
                checked: this.checkedIfRadioChecked(item.Id, index)
            }
        });
        this.genericdata = this.genericdata.map((item) => {
            return {
                ...item,
                checked: false
            }
        });

    }
    @api
    setCheckboxCheckedValue(selectedValue, selectedFilingNo, type) {
        if(type == 'checkbox'){
            this.paginatedData = this.paginatedData.map((item) => {
                if(item.filingNo == selectedFilingNo){
                    return {
                        ...item,
                        checked: selectedValue,
                        disabled: !selectedValue,
                        isExpeditCheckBoxDisabled: !selectedValue
                    }
                }
                return item;
            });
            this.genericdata = this.genericdata.map((item) => {
                if(item.filingNo == selectedFilingNo){
                    return {
                        ...item,
                        checked: selectedValue,
                        disabled: !selectedValue,
                        isExpeditCheckBoxDisabled: !selectedValue
                    }
                }
                return item;
            });
        } else if (type == 'expediteCopycheckbox'){
            this.paginatedData = this.paginatedData.map((item) => {
                if(item.filingNo == selectedFilingNo){
                    return {
                        ...item,
                        isExpediteCopy: selectedValue
                    }
                }
                return item;
            });
            this.genericdata = this.genericdata.map((item) => {
                if(item.filingNo == selectedFilingNo){
                    return {
                        ...item,
                        isExpediteCopy: selectedValue
                    }
                }
                return item;
            });
        } else {
            this.paginatedData = this.paginatedData.map((item) => {
              if(item.filingNo == selectedFilingNo){
                  return {
                      ...item,
                      copyType: selectedValue
                  }
              }
              return item;
            });
            this.genericdata = this.genericdata.map((item) => {
                if(item.filingNo == selectedFilingNo){
                    return {
                        ...item,
                        copyType: selectedValue
                    }
                }
                return item;
            });
        }
      

    }
    @api
    hideLinks(selectedFiling) {
        this.paginatedData = this.paginatedData.map((item) => {
            if(item.workOrderNum == selectedFiling.workOrderNum){
                return {
                    ...item,
                    isResubmit: false
                }
            }
            return{
                ...item
            }
        });
        this.genericdata = this.genericdata.map((item) => {
            if(item.workOrderNum == selectedFiling.workOrderNum){
                return {
                    ...item,
                    isResubmit: false
                }
            }
            return{
                ...item
            }
        });

    }
    checkedIfRadioChecked(itemId, index) {
        if (itemId === index) {
            return true;
        }
        else {
            return false;
        }
    }
    renderedCallback() {
        this.addUnderline();
        this.dispatchDatatoParent(this.paginatedData);
    }

    connectedCallback() {
        if (this.modalTheme) {
            this.themeClass = "modal-pagination";
        }
        this.paginatedData = this.processPaginationWithGenericMethod(this.genericdata);
        this.dispatchDatatoParent(this.paginatedData);
    }

    get checkStart() {
        if (Number(this.currentPage) === 1) {
            return true;
        }
        return false;
    }

    get checkEnd() {
        if (this.pageNumberList) {
            if (this.pageNumberList.length === Number(this.currentPage)) {
                return true;
            }
            return false;
        }
        return false;
    }

    get showAttention() {
        let themeClass = "";
        let hasAttentionCard = false;
        if (this.searchlength && this.actuallength && ((this.searchlength < this.actuallength) || this.showAttentionCard) && this.pageNumberList && this.pageNumberList.length === Number(this.currentPage)) {
            themeClass = "has-attention-card";
            hasAttentionCard = true;
        }
        this.themeClass = this.modalTheme ? `modal-pagination ${themeClass}` : themeClass;
        return hasAttentionCard;
    }

    /* Method to convert genericData to Paginated data based on few conditions like show pagination
        paginatedData value will be set here if its not already set */
    get paginateddatafetch() {
        let paginatedDatavalue;
        if (this.paginatedData.length > 0) {
            paginatedDatavalue = this.paginatedData;
        } else if (this.genericdata && this.showPagination) {
            paginatedDatavalue = this.processPaginationWithGenericMethod(this.genericdata);
            this.paginatedData = paginatedDatavalue;
        } else {
            paginatedDatavalue = this.genericdata;
            this.paginatedData = paginatedDatavalue;
        }
        this.dispatchDatatoParent(paginatedDatavalue);
        return paginatedDatavalue;
    }

    dispatchDatatoParent(data) {
        const manipulatedDataEvent = new CustomEvent("paginationchange", {
            detail: data,
            pageNo: this.currentPage
        });
        this.dispatchEvent(manipulatedDataEvent);
    }


    /* Method to convert genericData to Paginated data based on few conditions like show pagination */
    set paginateddata(value) {
        if (this.paginatedData) {
            this.paginatedData = value;
        } else if (this.genericdata && this.showPagination) {
            this.paginatedData = this.processPaginationWithGenericMethod(this.genericdata);
        } else {
            this.paginatedData = this.genericdata;
        }
    }

    @api
    setDataOnSearch(value) {
        this.currentPage = 1;
        this.genericdata = value;
        this.paginatedData = this.processPaginationWithGenericMethod(value);
    }

    /* Method used to calcuate the number of pages to be displayed and assign value to pageNumberList variable */
    processPaginationWithGenericMethod(data) {
        if (data.length > 0) {
            const pageNumberArray = [];
            this.totalPagesToDisplay = Math.ceil(data.length / this.noOfRecordsPerPage);
            for (let index = 1; index <= this.totalPagesToDisplay; index++) {
                pageNumberArray.push(index);
            }
            this.pageNumberList = pageNumberArray;
            this.displayPageNumbers();
        } else {
            this.totalPagesToDisplay = 0;
            this.pageNumberList = [];
        }
        return data.slice(0, this.noOfRecordsPerPage);
    }

    displayPageNumbers() {
        let firstDot = false;
        let nextDot = false;
        const currentPageNumber = Number(this.currentPage);
        const buttonLimit = Number(this.buttonLimit);
        if (this.pageNumberList.length > currentPageNumber + buttonLimit) {
            nextDot = true;
        }
        if (currentPageNumber > 3) {
            firstDot = true;
        }
        let startIndexToArray;
        if (currentPageNumber === 1) {
            startIndexToArray = currentPageNumber;
        } else {
            if (currentPageNumber > 2) {
                startIndexToArray = currentPageNumber - 2;
            } else {
                startIndexToArray = currentPageNumber - 1;
            }
        }
        let endIndexToArray;
        if (currentPageNumber + buttonLimit >= this.pageNumberList.length) {
            endIndexToArray = this.pageNumberList.length - 1;
        } else {
            if (nextDot) {
                endIndexToArray = currentPageNumber + buttonLimit - 1;
            } else {
                endIndexToArray = currentPageNumber + buttonLimit;
            }
        }
        if (firstDot && nextDot) {
            endIndexToArray = endIndexToArray - 2;
        }
        const DynamicPageArray = this.pageNumberList.slice(startIndexToArray, endIndexToArray);
        this.showFirstDot = firstDot;
        this.showNextDot = nextDot;
        this.pageListToShow = DynamicPageArray;
        this.pageListFirst = this.pageNumberList.slice(0, 1);
        if (this.pageNumberList.length !== 1) {
            this.pageListLast = this.pageNumberList.slice(this.pageNumberList.length - 1, this.pageNumberList.length + 1);
        } else {
            this.pageListLast = [];
        }
    }

    onNext = () => {
        if (this.currentPage < this.totalPagesToDisplay) {
            this.currentPage = Number(this.currentPage) + 1;
            this.paginatedData = this.fetchCurrentPageData();
            this.displayPageNumbers();
        }
    };

    onPrev = () => {
        if (this.currentPage > 1) {
            this.currentPage = Number(this.currentPage) - 1;
            this.paginatedData = this.fetchCurrentPageData();
            this.displayPageNumbers();
        }
    };

    @api
    displayPageDetails(event) {
        this.currentPage = event && event.target ? event.target.dataset.id: this.currentPage ? this.currentPage : 1;
        this.paginatedData = this.fetchCurrentPageData();
        const lastpageData = this.fetchLastPageData();
        //redirect to previous page on all items delete on current page
        if(!this.paginatedData.length){
            this.currentPage = this.currentPage - 1;
            this.paginatedData = this.fetchCurrentPageData();
            this.pageNumberList.pop();
        }
        // refresh pagination on delete if there is no data on last page 
        if(!lastpageData.length){
            this.pageNumberList.pop();
        }
        this.displayPageNumbers();
        this.addUnderline();
        const scrollToTopEvent = new CustomEvent("scrolltotop");
        this.dispatchEvent(scrollToTopEvent);
    }

    fetchCurrentPageData() {
        const startIndexCurrent = (this.currentPage * this.noOfRecordsPerPage) - this.noOfRecordsPerPage;
        const endIndexCurrent = (this.currentPage * this.noOfRecordsPerPage);
        return this.genericdata.slice(startIndexCurrent, endIndexCurrent);
    }

    fetchLastPageData(){
        const lastPage = this.pageNumberList[this.pageNumberList.length -1];
        const startIndexCurrent = (lastPage * this.noOfRecordsPerPage) - this.noOfRecordsPerPage;
        const endIndexCurrent = (lastPage * this.noOfRecordsPerPage);
        return this.genericdata.slice(startIndexCurrent, endIndexCurrent);
    }

    addUnderline() {
        this.template.querySelectorAll('a.paginationlink').forEach((pagebutton) => {
            if (Number(this.currentPage) === parseInt(pagebutton.dataset.id, 10)) {
                pagebutton.classList.add("highlight");
            } else {
                pagebutton.classList.remove("highlight");
            }
        });
    }
}
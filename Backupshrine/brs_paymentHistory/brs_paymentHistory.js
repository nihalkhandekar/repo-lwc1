import {
    LightningElement,
    api,
    track
} from 'lwc';
import Sort_by from '@salesforce/label/c.Sort_by';
import date from '@salesforce/label/c.Date';
import ph_Amount from '@salesforce/label/c.ph_Amount';
import ph_Filing from '@salesforce/label/c.ph_Filing';
import ph_FilingType from '@salesforce/label/c.ph_FilingType';
import ph_mypayments from '@salesforce/label/c.ph_mypayments';
import ph_Status from '@salesforce/label/c.ph_Status';
import ph_transactionType from '@salesforce/label/c.ph_transactionType';
import ph_WO from '@salesforce/label/c.ph_WO';
import From from '@salesforce/label/c.From';
import TO from '@salesforce/label/c.TO';
import ph_export_as_csv from '@salesforce/label/c.ph_export_as_csv';
import accountdashboard_sortNewToOld from '@salesforce/label/c.accountdashboard_sortNewToOld';
import accountdashboard_sortOldToNew from '@salesforce/label/c.accountdashboard_sortOldToNew';
import ph_nodataHeader from '@salesforce/label/c.ph_nodataHeader';
import ph_nodataSubHeader from '@salesforce/label/c.ph_nodataSubHeader';
import getPaymentHistoryData from '@salesforce/apex/BRS_PaymentUtility.getPaymentHistoryData';
import {
    exportDataToCsv
} from 'c/appUtility';
import {
    isUndefinedOrNull
} from "c/appUtility";
import {
    ComponentErrorLoging
} from "c/formUtility";
import newAssetFolder from "@salesforce/resourceUrl/CT_New_Assets";
export default class Brs_paymentHistoryDetails extends LightningElement {
    @api tablecolumns;
    @api tabledata;
    @track showResults = true;
    @track recordsPerPage = 6;
    @track updatedData;
    @track expandSort = false;
    @track selectedSort = accountdashboard_sortNewToOld;
    @track spinner = false;
    @api fromDate;
    @api toDate;
    @track resultLength;
    @track compName = "paymenthistory";
    @track severity = "medium";
    @track icon = newAssetFolder + "/icons/paymentNoData.svg";
    labels={
        Sort_by,
        date,
        ph_Amount,
        ph_Filing,
        ph_FilingType,
        ph_mypayments,
        ph_Status,
        ph_transactionType,
        ph_WO,
        From,
        TO,
        ph_export_as_csv,
        accountdashboard_sortNewToOld,
        accountdashboard_sortOldToNew,
        ph_nodataHeader,
        ph_nodataSubHeader
    }
    connectedCallback() {
        // getVoucher()
        // .then(result=>{
        //     console.log('result: '+JSON.stringify(result));
        //     this.tablecolumns=result.tableColumns;
        //     this.tabledata=result.tableData;
        // })
        if (this.tabledata && this.tabledata.length) {
            this.resultLength = this.tabledata.length
            let temp = JSON.parse(JSON.stringify(this.tabledata))
            temp.forEach(item => {
                if (!item.transactionDateTime) {
                    item.transactionDateTime = item.transactionDate
                }
            });
            this.tabledata = temp;
        }
        this.handleSort(true);
    }
    handleExpandSort() {
        this.expandSort = !this.expandSort;
    }
    handleSort(event) {
        this.showResults = false;
        this.spinner = true;
        if (event.currentTarget) {
        this.selectedSort = event.currentTarget.dataset.id;
            this.expandSort = !this.expandSort;
        }
        let resultArray = JSON.parse(JSON.stringify(this.tabledata));
        this.tabledata = [];
        
        if (this.selectedSort == accountdashboard_sortNewToOld) {
            resultArray.sort(function (a, b) {
                var x = new Date(a.transactionDateTime);
                var y = new Date(b.transactionDateTime);
                return y - x;
            });
        } else if (this.selectedSort == accountdashboard_sortOldToNew) {
            resultArray.sort(function (a, b) {
                var x = new Date(a.transactionDateTime);
                var y = new Date(b.transactionDateTime);
                return x - y;
            });
        }
        setTimeout(() => {
            this.tabledata = resultArray;
            // let count = 0;
            // let temp = [];
            // this.tabledata.forEach(item => {
            //     if (count < 6) {
            //         temp.push(item);
            //         count++;
            //     }
            // });
            // this.updatedData = temp;
            this.showResults = true;
            this.spinner = false;
        }, 10);

    }
    updatePaginatedData(event) {
        this.updatedData = event.detail;
        if (this.updatedData.length > 3) {
            this.template.querySelector(".results-table").classList.add("box-shadow-table");
        } else {
            this.template.querySelector(".results-table").classList.remove("box-shadow-table");
        }
    }
    handleTableScrollToTop() {
        // this.template.querySelector(".results-table tbody").scrollTop = 0;
        // this.template.querySelector(".results-table tbody").style.overflowY  = "scroll";
    }
    getFilteredData(from, to) {
        this.spinner = true;
        getPaymentHistoryData({
                fromDate: from,
                toDate: to
            })
            .then(result => {
                const evt = new CustomEvent('filterdate', {
                    detail: {
                        result: JSON.stringify(result),
                        from : from,
                        to : to
                    }
                });
                this.dispatchEvent(evt);
                this.spinner = false;
            })
            .catch(error => {
                this.spinner = false;
                ComponentErrorLoging(
                    this.compName,
                    "getPaymentHistoryData",
                    "",
                    "",
                    this.severity,
                    error.message
                );
            })
    }
    CheckDateValidity() {
        if (this.fromDate && this.toDate && (this.fromDate < this.toDate)) {
           this.getFilteredData(this.fromDate, this.toDate);
            let fromElement = this.template.querySelector(".fromDate");
            let toElement = this.template.querySelector(".toDate");
            if (toElement && fromElement) {
                fromElement.setCustomValidity("");
                fromElement.reportValidity();
                toElement.setCustomValidity("");
                toElement.reportValidity();
            }
            return true;
        } else {
            return false
        }
    }
    handleFromDate(event) {
        this.fromDate = event.target.value;
        if (isUndefinedOrNull(this.toDate)) {
            this.getFilteredData(this.fromDate, null)
        } else {
            let isValid = this.CheckDateValidity();
            let inputElement = this.template.querySelector(".fromDate");
            if (!isValid && inputElement) {
                inputElement.setCustomValidity("Invalid Range");
                inputElement.reportValidity();
            } else if (isValid) {
                this.getFilteredData(this.fromDate, this.toDate)
            }
        }
    }
    handleToDate(event) {
        this.toDate = event.target.value;
        if (isUndefinedOrNull(this.fromDate)) {
            this.getFilteredData(null, this.toDate)
        } else {
            let isValid = this.CheckDateValidity();
            let inputElement = this.template.querySelector(".toDate");
            if (!isValid && inputElement) {
                inputElement.setCustomValidity("Invalid Range");
                inputElement.reportValidity();
            } else if (isValid) {
                this.getFilteredData(this.fromDate, this.toDate)
            }
        }
    }
    ExportCsv() {
        let fromDate = this.fromDate;
        let toDate = this.toDate;
        this.spinner = true;
        getPaymentHistoryData({
            fromDate:fromDate,
            toDate:toDate
        })
        .then(result => {
                exportDataToCsv(result.tableData, "Payment History", true, result.tableColumns);
                this.spinner = false;
        })
        .catch(error => {
                this.spinner = false;
                ComponentErrorLoging(
                    this.compName,
                    "getPaymentHistoryData",
                    "",
                    "",
                    this.severity,
                    error.message
                );
        })
    }
}
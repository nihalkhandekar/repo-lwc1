import { LightningElement, track, api } from 'lwc';
import getCreditCardCount from '@salesforce/apex/FinsysCreditCardReport.getCreditCardCount';
import getCreditCardData from '@salesforce/apex/FinsysCreditCardReport.getCreditCardData';

export default class FinsysSettlementReport extends LightningElement {
    @track creditCardReport = [];
    @track isRecordsLoading = false;
    @track fromDate = null;
    @track toDate = null;
    @track recordsFound = "0 Found";

    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';

    @track activeBadge = '';
    @track dateFilter = '';

    connectedCallback() {
        const today = new Date().toISOString().split('T')[0];

        this.fromDate = today;
        this.toDate = today;
        this.loadCreditCardData();
    }

    @api
    receiveFormFields(fields) {
        console.log('Form fields passed to child:', fields);

        fields.forEach((field) => {
            switch (field.label) {
                case 'Transaction From Date':
                    this.fromDate = field.value;
                    break;
                case 'Transaction To Date':
                    this.toDate = field.value;
                    break;
                default:
                    console.warn('Unmapped field:', field.label);
                    break;
            }
        });

        this.loadCreditCardData();
    }

    loadCreditCardData() {
        this.isRecordsLoading = true;
    
        const params = {
            fromDate: this.fromDate,
            toDate: this.toDate,
        };
    
        Promise.all([
            getCreditCardCount({ paramsJson: JSON.stringify(params) }),
            getCreditCardData({ paramsJson: JSON.stringify(params) }),
        ])
            .then(([totalCount, data]) => {
                this.recordsFound = `${totalCount} Found`;
    
                this.creditCardReport = data.map((record, recordIndex) => {
                    const transactionDate = record.transactionDate
                        ? new Date(record.transactionDate).toLocaleDateString()
                        : "N/A";
    
                    const totalAmount = record.totalAmount
                        ? `$${parseFloat(record.totalAmount).toFixed(2)}`
                        : "$0.00";
    
                    const activities = record.activities.map((activity, activityIndex) => ({
                        key: `activity-${recordIndex}-${activityIndex}`,
                        Activity: activity.batchName || "Unknown",
                        TransactionCount: activity.batchTransactionCount || 0,
                        Amount: activity.batchTotal
                            ? `$${parseFloat(activity.batchTotal).toFixed(2)}`
                            : "$0.00",
                        isFirstRow: activityIndex === 0, // Flag first row for rendering rowspan
                    }));
    
                    return {
                        key: `record-${recordIndex}`,
                        TransactionDate: transactionDate, // Match template casing
                        TotalAmount: totalAmount, // Match template casing
                        Activities: activities, // Match template casing
                        rowspan: activities.length // Set rowspan for the first row
                    };
                });
    
                console.log("Credit Card Report Data:", JSON.stringify(this.creditCardReport, null, 2));
            })
            .catch((error) => {
                console.error("Error fetching settlement data:", error);
            })
            .finally(() => {
                this.isRecordsLoading = false;
            });
    }
    

    get isrecordFound() {
        return this.creditCardReport && this.creditCardReport.length > 0;
    }

    handleBadgeClick(event) {

        const clickedBadgeId = event.target.dataset.id;
        console.log('clickedBadgeId..............',clickedBadgeId);
        
        if (this.activeBadge === clickedBadgeId) {
          // If the clicked badge is already active, reset to show all data
          console.log('Inside if same button');
          this.activeBadge = "";
          this.dateFilter = "";
          this.fromDate = null;
          this.toDate = null;
        } else {
          // Set the new active badge and update the filter
          const rangeTypeMap = {
            "today": "Today",
            "this-week": "ThisWeek",
            "this-month": "ThisMonth",
            "this-quarter": "ThisQuarter",
            "this-year": "ThisYear"
          };
          this.activeBadge = clickedBadgeId;
          this.dateFilter = rangeTypeMap[clickedBadgeId];
          this.handleDateRange(this.dateFilter);
        }
    
        this.updateBadgeClasses();    
        this.loadCreditCardData();
    }
    
    handleDateRange(rangeType) {
        const now = new Date();
        let startDate, endDate;

        switch (rangeType) {
            case 'Today':
                startDate = endDate = new Date(); 
                break;
            case 'ThisWeek':
                const dayOfWeek = now.getDay(); 
                startDate = new Date(now);
                startDate.setDate(now.getDate() - dayOfWeek); 
                endDate = new Date(now);
                endDate.setDate(now.getDate() + (6 - dayOfWeek)); 
                break;
            case 'ThisMonth':
                startDate = new Date(now.getFullYear(), now.getMonth(), 1); 
                endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0); 
                break;
            case 'ThisQuarter':
                const currentMonth = now.getMonth();
                const startMonth = Math.floor(currentMonth / 3) * 3; 
                startDate = new Date(now.getFullYear(), startMonth, 1); 
                endDate = new Date(now.getFullYear(), startMonth + 3, 0); 
                break;
            case 'ThisYear':
                startDate = new Date(now.getFullYear(), 0, 1); 
                endDate = new Date(now.getFullYear(), 11, 31); 
                break;
            default:
                startDate = endDate = null;
                break;
        }

        this.fromDate = startDate ? startDate.toISOString().split('T')[0] : '';
        this.toDate = endDate ? endDate.toISOString().split('T')[0] : '';
        console.log('fromDate==>' + this.fromDate + 'toDate ==>>' + this.toDate);
    }

    updateBadgeClasses() {
        this.badgeClassCurrentDay =
          this.dateFilter === "Today"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisWeek =
          this.dateFilter === "ThisWeek"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisMonth =
          this.dateFilter === "ThisMonth"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisQuarter =
          this.dateFilter === "ThisQuarter"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisYear =
          this.dateFilter === "ThisYear"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
    }

    handleExportResultButtonClick() {
        // Define headers with labels and corresponding field names
        let headers = [
            { label: 'Transaction Date', fieldName: 'TransactionDate' },
            { label: 'Total Amount', fieldName: 'TotalAmount' },
            { label: 'Activity/Category', fieldName: 'Activity' },
            { label: 'Amount', fieldName: 'Amount' }
        ];
    
        // Set the desired file name
        const fileName = 'Credit_Card_Summary';
    
        // Prepare search parameters (fromDate and toDate)
        const params = {
            fromDate: this.fromDate,
            toDate: this.toDate,
        };
    
        // Find the Excel generator component in the DOM
        const excelgenerator = this.template.querySelector('c-finsys-export-to-excel');
    
        // Call the export function if the component is found
        if (excelgenerator) {
            excelgenerator.creditCardSummaryFinsys(headers, params, fileName);
        } else {
            console.error('Excel generator component not found');
        }
    }

    handleDownloadPdf() {
        const fileName = 'Credit_Card_Summary';
        const params = {
            fromDate: this.fromDate,
            toDate: this.toDate,
        };
        
        const pdfgenerator =  this.template.querySelector('c-finsys-reports-pdf-generator');
        if (pdfgenerator) {
            pdfgenerator.creditCardSummaryReportFinsys(params, fileName);
        } else {
            console.error('Excel generator component not found');
        }
    }
    
}
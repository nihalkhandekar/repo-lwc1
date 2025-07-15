import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import reportFinsys from '@salesforce/resourceUrl/reportFinsys';
import getUserCloseoutReport from '@salesforce/apex/SAP_TransactionReportController.getUserCloseoutReport';

export default class UserCloseoutReport extends LightningElement {
    @track settlementReport = [];
    @track isRecordsLoading = false;
    @track iconState = {};
    @track isvisible = true;

    // @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    // @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    // @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    // @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    // @track badgeClassThisYear = 'slds-badge_inverse custom-badge';

    // @track dateFilter = '';
    // @track activeBadge = '';
    @track fromDate = null;
    @track toDate = null;

    @track WorkOrderNum;
    @track closingDate = new Date(new Date().getTime() - new Date().getTimezoneOffset() * 60000)
    .toISOString()
    .slice(0, 10);
   // @track paymentDate;
    @track paymentType;
    @track selectedTransactions = [];
    @track selectedUsers = [];
    @track structuredData = [];

    @track noResult;

    @api
    receiveFormFields(fields, selectedActivities, selectedUsers) {
        console.log("Form fields passed to child:", JSON.stringify(fields));
        
        this.formFields = fields;
        this.selectedTransactions = selectedActivities;
        this.selectedUsers = selectedUsers;

        // Process form fields
        fields.forEach((field) => {
            if (field.label === "Payment Type") {
                this.paymentType = field.value;
            } else if (field.label === "Wo/Invoice#") {
                this.WorkOrderNum = field.value;
            } else if (field.label === "Date") {
                this.closingDate = field.value || new Date().toISOString().slice(0, 10);
            }else {
                console.warn("Unmapped field:", field.label);
            }
        });

        console.log('received data');

        this.loadTransactionData();
    }


    connectedCallback() {
        loadStyle(this, reportFinsys)
            .then(() => console.log('CSS file loaded successfully'))
            .catch((error) => console.error('Error loading CSS file:', error));
            
            const today = new Date().toISOString().split('T')[0];
            this.fromDate = today;
            this.toDate = today;
            this.loadTransactionData();

    }


    loadTransactionData() {
        this.isRecordsLoading = true;

        const searchParams = {
            fromDate: this.fromDate,
            toDate: this.toDate,
            closingDate: this.closingDate,
            selectedUsers: this.selectedUsers,
            selectedTransactions: this.selectedTransactions,
            paymentType: this.paymentType,
            WorkOrderNum: this.WorkOrderNum
        };

        console.log(searchParams);

        getUserCloseoutReport({ paramsJson: JSON.stringify(searchParams) })
            .then((result) => {
                console.log("Fetched Data:", JSON.stringify(result));
                this.structuredData = this.formatData(result);
                this.isRecordsLoading = false;
            })
            .catch((error) => {
                console.error('Error fetching transaction data:', error);
                this.isRecordsLoading = false;
            });
    }

    formatData(data) {
        let formattedArray = [];
        if (data) {
            Object.keys(data).forEach(activity => {
                let payments = [];
                Object.keys(data[activity]).forEach(paymentType => {
                    let transactions = data[activity][paymentType];
    
                    // Convert Date Format to MM/DD/YYYY
                    transactions = transactions.map(txn => ({
                        ...txn,
                        Date: txn.Date ? this.formatDate(txn.Date) : 'N/A'
                    }));
    
                    // Calculate total amount
                    let totalAmount = transactions.reduce((sum, txn) => sum + (txn.Amount || 0), 0);
    
                    // Add record count for the payment type
                    let recordCount = transactions.length + ' Found';
    
                    payments.push({
                        paymentType: paymentType,
                        transactions: transactions,
                        totalAmount: totalAmount,
                        recordSummaryLabel: recordCount // Store count of transactions
                    });
                });
    
                formattedArray.push({
                    activity: activity,
                    payments: payments
                });
            });
        }
        return formattedArray;
    }
    
    
    formatDate(dateString) {
        if (!dateString) return '';
    
        try {
            // Ensure correct parsing in local time zone
            const dateParts = dateString.split('-'); // Assuming format "YYYY-MM-DD"
            const date = new Date(
                Number(dateParts[0]), // Year
                Number(dateParts[1]) - 1, // Month (0-based index)
                Number(dateParts[2]) // Day
            );
    
            if (isNaN(date.getTime())) return 'Invalid Date';
    
            return date.toLocaleDateString('en-US', {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit'
            });
    
        } catch (error) {
            console.error("Error formatting date:", dateString, error);
            return 'Invalid Date';
        }
    }
    
    

    
    toggleSection(event) {
        const activity = event.currentTarget.dataset.activity; // Get activity from clicked icon
        const section = this.template.querySelector(`[data-id="${activity}"]`);
        const icon = event.currentTarget; // Get the clicked icon element directly
        
        console.log('Activity:', activity);
        console.log('Section:', section);
        console.log('Icon:', icon);
    
        if (section) {
            const isHidden = section.classList.contains("slds-hide");
            section.classList.toggle("slds-hide"); // Toggle section visibility
    
            // Change the icon based on the section's state
            if (icon) {
                icon.iconName = isHidden ? "utility:chevrondown" : "utility:chevronright";
            }
        }
    }
    

    handleDownloadPdf(){
        const fileName = 'UserCloseOutReport';
        const data = this.structuredData;
        const closingDate = this.formatDate(this.closingDate);
    
    const pdfgenerator =  this.template.querySelector('c-sap_-finsys-reports-pdf-generator');
    if (pdfgenerator) {
        pdfgenerator.userCloseoutReport(data, fileName, closingDate);
    } else {
        console.error('Excel generator component not found');
    }

    }
    handleExportResultButtonClick() {
        const fileName = 'UserCloseoutReport';
        const data = this.structuredData;

        const excelgenerator = this.template.querySelector('c-sap_-finsys-export-to-excel');
        if (excelgenerator) {
            excelgenerator.userCloseoutReportExcel(data, fileName);
        } else {
            console.error('Excel generator component not found');
        }

    }
    


    handleDismiss() {
        this.isvisible = false;
      }
    
    
}
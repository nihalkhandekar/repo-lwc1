import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import reportFinsys from '@salesforce/resourceUrl/reportFinsys';
import getUserCloseoutReport from '@salesforce/apex/TransactionReportController.getUserCloseoutReport';

export default class UserCloseoutReport extends LightningElement {
    @track settlementReport = [];
    @track checkPayments = [];
    @track creditCardPayments = [];
    @track cashPayments = [];
    @track moneyOrderPayments = [];
    @track isRecordsLoading = false;
    @track currentPage = 1;
    @track pageSize = 10;
    @track totalPages = 0;
    @track recordsFound = 0;
    @track startRange = 0;
    @track endRange = 0;

    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';
    @track dateFilter = '';

    @track sortedBy = 'CreatedDate';
    @track sortDirection = 'desc';
    @track sortIcons = {
        Customer__c: 'utility:arrowdown',
        Name: 'utility:arrowdown',
    };
    @track isSectionFinsysVisible = true;
    @track isApostilleSectionVisible = true;
    @track isBRSSectionVisible = true;
    @track headerIcon = 'utility:chevrondown';

    
  @track WorkOrderNum;
  @track name;
  @track paymentType;
  @track paymentDate;
  @track selectedTransactions = [];
  @track selectedUsers = [];

  @track Apostille = true;
  @track Finsys = true;
  @track BRS = true;

  @api
  receiveFormFields(fields, selectedTransactions, selectedUsers) {
    console.log("Form fields passed to child:", JSON.stringify(fields));
    this.formFields = fields;
    this.selectedTransactions = selectedTransactions;
    this.selectedUsers = selectedUsers;

    fields.forEach((field) => {
      if (field.label === "Payment Type") {
        this.paymentType = field.value;
      } else if (field.label === "Name") {
        this.name = field.value;
      } else if (field.label === "Wo/Invoice#") {
        this.WorkOrderNum = field.value;
      } else if (field.label === "Date") {
        this.paymentDate = field.value;
      } else {
        console.warn("Unmapped field:", field.label);
      }
    });

    this.updateBooleans();
    this.loadTransactionData();
  }

  updateBooleans() {
    this.Apostille = this.selectedTransactions.includes('Apostille');
    this.Finsys = this.selectedTransactions.includes('Finsys');
    this.BRS = this.selectedTransactions.includes('BRS');
    if(this.selectedTransactions.includes('All')){
        this.Apostille = true;
        this.Finsys = true;
        this.BRS = true;
    }
}

    connectedCallback() {
        loadStyle(this, reportFinsys)
            .then(() => console.log('CSS file loaded successfully'))
            .catch((error) => console.error('Error loading CSS file:', error));
            this.updateBooleans();
        this.loadTransactionData();
    }

    toggleApostilleSections(){
        this.isApostilleSectionVisible = !this.isApostilleSectionVisible;
        this.headerIcon = this.isApostilleSectionVisible ? 'utility:chevrondown' : 'utility:chevronright';
    }

    toggleFinsysSections(){
        this.isSectionFinsysVisible = !this.isSectionFinsysVisible;
        this.headerIcon = this.isSectionFinsysVisible ? 'utility:chevrondown' : 'utility:chevronright';
    }

    toggleBRSSections(){
        this.isBRSSectionVisible = !this.isBRSSectionVisible;
        this.headerIcon = this.isBRSSectionVisible ? 'utility:chevrondown' : 'utility:chevronright';
    }

    loadTransactionData() {
        this.isRecordsLoading = true;

        const searchParams = {
            dateFilter: this.dateFilter || '',
            sortBy: this.sortedBy,
            sortDirection: this.sortDirection,
            pageSize: this.pageSize,
            pageNumber: this.currentPage,
            name: this.name,
            paymentType: this.paymentType,
            WorkOrderNum: this.WorkOrderNum,
            paymentDate: this.paymentDate
        };

        getUserCloseoutReport({ paramsJson: JSON.stringify(searchParams) })
            .then((result) => {
                console.log('result: ', JSON.stringify(result));
                this.processTransactionData(result);
                this.isRecordsLoading = false;
            })
            .catch((error) => {
                console.error('Error fetching transaction data:', error);
                this.isRecordsLoading = false;
            });
    }

    processTransactionData(result) {
        if (!result?.records) return;
        
        const records = result.records;
        const BRSData = result.workOrderData;
        this.recordsFound = result.totalCount || 0;
        this.paymentCounts = result.paymentTypeCounts || {};
        
        // Reset arrays
        this.checkPayments = [];
        this.creditCardPayments = [];
        this.cashPayments = [];
        this.moneyOrderPayments = [];
        
        this.checkFinsysPayments = [];
        this.creditFinsysCardPayments = [];
        this.cashFinsysPayments = [];
        this.moneyOrderFinsysPayments = [];
        
        this.creditBRSCardPayments = [];
        
        // Process Apostille payments
        if (this.Apostille && records.Apostille) {
            this.checkPayments = this.processPaymentType(records.Apostille.Check || []);
            this.creditCardPayments = this.processPaymentType(records.Apostille.Card || []);
            this.cashPayments = this.processPaymentType(records.Apostille.Cash || []);
            this.moneyOrderPayments = this.processPaymentType(records.Apostille['Money Order'] || []);
        }
        
        // Process Finsys payments
        if (this.Finsys && records.FinSys) {
            this.checkFinsysPayments = this.processPaymentType(records.FinSys.Check || []);
            this.creditFinsysCardPayments = this.processPaymentType(records.FinSys.Card || []);
            this.cashFinsysPayments = this.processPaymentType(records.FinSys.Cash || []);
            this.moneyOrderFinsysPayments = this.processPaymentType(records.FinSys['Money Order'] || []);
        }
        
        // Process BRS payments
        if (this.BRS && BRSData?.groupedTransactions?.Credit) {
            this.creditBRSCardPayments = this.processBRSPaymentType(BRSData.groupedTransactions);
            console.log('Processed BRS Payments:', this.creditBRSCardPayments);
        }
    }
    
    processBRSPaymentType(groupedTransactions) {
        const processedPayments = [];
        const creditTransactions = groupedTransactions.Credit || {};
    
        console.log('Credit Transactions:', creditTransactions); // Debug log for Credit Transactions
    
        for (const workOrderId in creditTransactions) {
            const payments = creditTransactions[workOrderId];
            console.log(`Payments for ${workOrderId}:`, payments); // Debug log for each workOrderId
    
            if (Array.isArray(payments)) {
                payments.forEach(payment => {
                    if (payment?.transaction && payment?.workOrder) {
                        processedPayments.push({
                            id: payment.transaction.Id,
                            workOrderId: workOrderId,
                            amount: payment.transaction.Amount,
                            funding: payment.transaction.Funding,
                            cardLast4: payment.transaction.CardLast4,
                            createdDate: this.formatDate(payment.workOrder.CreatedDate),  
                            name: payment.workOrder.Name,
                            workOrder: payment.workOrder.workOrderNum
                        });
                    }
                });
            }
        }
    
        console.log('Processed Payments Array:', processedPayments); // Debug log for the processed array
        return processedPayments;
    }
    
    
    processPaymentType(payments) {
        return payments.map(payment => {
            return {
                Id: payment.children[0].Id,
                WorkOrderNumber: payment.parent.Sequence_Number__c,
                CustomerName: `${payment.parent.First_Name__c} ${payment.parent.Last_Name__c}`,
                Payment_Number__c: payment.children[0].Payment_Number__c,
                TotalFeeAmount: payment.children[0].TotalFeeAmount,
                CreatedDate: this.formatDate(payment.children[0].CreatedDate), // Format date
                Payment_Type__c: payment.children[0].Payment_Type__c
            };
        });
    }
    
    get hasCreditBRSPayments() {
        console.log('Credit BRS Payments Length:', this.creditBRSCardPayments?.length);
        return this.creditBRSCardPayments?.length > 0;
    }
    

    formatDate(date) {
        if (!date) return null;
    
        const options = { year: 'numeric', month: '2-digit', day: '2-digit' };
        const formattedDate = new Date(date).toLocaleDateString('en-US', options);
        return formattedDate;
    }
    

    get recordTypes() {
        return Object.keys(this.processedData);
    }

    getPaymentTypes(recordType) {
        return this.processedData[recordType] ? Object.keys(this.processedData[recordType]) : [];
    }

    getPaymentRecords(recordType, paymentType) {
        return this.processedData[recordType]?.[paymentType] || [];
    }

    filterRecordsByType(records) {
        const filtered = {};
        
        // Group by payment type
        for (let type in records) {
            filtered[type] = records[type].filter(record => {
                const matchesName = !this.name || 
                    `${record.parent.First_Name__c} ${record.parent.Last_Name__c}`
                        .toLowerCase()
                        .includes(this.name.toLowerCase());
                const matchesPaymentType = !this.paymentType || type === this.paymentType;
                const matchesWorkOrder = !this.WorkOrderNum || 
                    record.parent.Sequence_Number__c.includes(this.WorkOrderNum);
                const matchesDate = !this.paymentDate || record.children.some(child => 
                    child.CreatedDate.split('T')[0] === this.paymentDate
                );
                
                return matchesName && matchesPaymentType && matchesWorkOrder && matchesDate;
            });
        }

        return filtered;
    }

    get checkCount() {
        return this.paymentCounts['Check'] || 0;
    }

    get creditCardCount() {
        return this.paymentCounts['Card'] || 0;
    }

    get cashCount() {
        return this.paymentCounts['Cash'] || 0;
    }

    get moneyOrderCount() {
        return this.paymentCounts['Money Order'] || 0;
    }

    handleBadgeClick(event) {
        const clickedBadgeId = event.target.dataset.id;

        const rangeTypeMap = {
            today: 'today',
            'this-week': 'this-week',
            'this-month': 'this-month',
            'this-quarter': 'this-quarter',
            'this-year': 'this-year',
        };

        this.dateFilter = this.dateFilter === rangeTypeMap[clickedBadgeId] ? '' : rangeTypeMap[clickedBadgeId];
        this.updateBadgeClasses();
        this.currentPage = 1;
        this.loadTransactionData();
    }

    updateBadgeClasses() {
        const activeClass = 'slds-badge_inverse custom-badge active';
        const inactiveClass = 'slds-badge_inverse custom-badge';

        this.badgeClassCurrentDay = this.dateFilter === 'today' ? activeClass : inactiveClass;
        this.badgeClassThisWeek = this.dateFilter === 'this-week' ? activeClass : inactiveClass;
        this.badgeClassThisMonth = this.dateFilter === 'this-month' ? activeClass : inactiveClass;
        this.badgeClassThisQuarter = this.dateFilter === 'this-quarter' ? activeClass : inactiveClass;
        this.badgeClassThisYear = this.dateFilter === 'this-year' ? activeClass : inactiveClass;
    }

    handleSort(event) {
        const field = event.currentTarget.dataset.field;
        if (this.sortedBy === field) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortedBy = field;
            this.sortDirection = 'asc';
        }
        this.loadTransactionData();
    }

    handleExportApostille() {
        const fileName = 'User_Closeout_Apostille_Report';
        const searchParams = {
            dateFilter: this.dateFilter || '',
            sortBy: this.sortedBy,
            sortDirection: this.sortDirection,
            pageSize: this.pageSize,
            pageNumber: this.currentPage,
            name: this.name,
            paymentType: this.paymentType,
            WorkOrderNum: this.WorkOrderNum,
            paymentDate: this.paymentDate
        };
    
        const excelGenerator = this.template.querySelector('c-excel-export-finsys');
        if (excelGenerator) {
            excelGenerator.apostilleReport(searchParams, fileName);
        }
    }

    handleExportFinsys() {
        const fileName = 'User_Closeout_Finsys_Report';
            let searchParams = {
                dateFilter: this.dateFilter || '',
                sortBy: this.sortedBy,
                sortDirection: this.sortDirection,
                pageSize: this.pageSize,
                pageNumber: this.currentPage,
                name: this.name,
                paymentType: this.paymentType,
                WorkOrderNum: this.WorkOrderNum,
                paymentDate: this.paymentDate
            };
        const excelgenerator =  this.template.querySelector('c-excel-export-finsys');
        if (excelgenerator) {
            excelgenerator.finsysReport(searchParams, fileName);
        } else {
            console.error('Excel generator component not found');
        }
    }

    handleExportBRS() {
        const fileName = 'User_Closeout_BRS_Report';
            let searchParams = {
                dateFilter: this.dateFilter || '',
                sortBy: this.sortedBy,
                sortDirection: this.sortDirection,
                pageSize: this.pageSize,
                pageNumber: this.currentPage,
                name: this.name,
                paymentType: this.paymentType,
                WorkOrderNum: this.WorkOrderNum,
                paymentDate: this.paymentDate
            };
        const excelgenerator =  this.template.querySelector('c-excel-export-finsys');
        if (excelgenerator) {
            excelgenerator.workOrderReport(searchParams, fileName);
        } else {
            console.error('Excel generator component not found');
        }
    }
}
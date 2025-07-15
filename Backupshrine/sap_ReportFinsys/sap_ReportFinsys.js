import { LightningElement, wire, track} from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import sap_stateExtradition from "@salesforce/resourceUrl/sap_stateExtradition";
import reportFinsys from '@salesforce/resourceUrl/sap_reportFinsys';
import fetchUserNames from "@salesforce/apex/SAP_ReportFinsysController.fetchUserNames";
//import getReportId from '@salesforce/apex/ReportPdfCoreCtController.getReportId';
// import getIdReport from '@salesforce/apex/SAP_ReportDownloadController.getIdReport';
// import agingReport from '@salesforce/apex/SAP_ReportDownloadController.agingReport';
// import agingReportCount from '@salesforce/apex/SAP_ReportDownloadController.agingReportCount';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import feeItem_OBJECT from '@salesforce/schema/RegulatoryTrxnFeeItem';
import Activity_Field from '@salesforce/schema/RegulatoryTrxnFeeItem.Select_Activity__c';
import WorkOrder_OBJECT from '@salesforce/schema/Work_Order__c';
import Category_Field  from '@salesforce/schema/Work_Order__c.Type__c';

// const reportFilterFieldMapping = {
//   "CORE-CT Deposit Summary": {
//     "Batch Code": {
//       fieldName: "RegulatoryTrxnFeeItem.Select_Activity__c",
//       type: "picklist"
//     },
//     "Transaction From Date": {
//       fieldName: "RegulatoryTrxnFee.CreatedDate",
//       type: "date",
//       operator: "greaterOrEqual"
//     },
//     "Transaction To Date": {
//       fieldName: "RegulatoryTrxnFee.CreatedDate",
//       type: "date",
//       operator: "lessOrEqual"
//     }
//     // "Deposit Date": {
//     //     fieldName: "RegulatoryTrxnFeeItem.Deposit_Date__c",
//     //     type: "date"
//     // }
//   },
//   "Cumulative Deposit Summary": {
//     "Transaction From Date": {
//       fieldName: "RegulatoryTrxnFee.CreatedDate",
//       type: "date",
//       operator: "greaterOrEqual"
//     },
//     "Transaction To Date": {
//       fieldName: "RegulatoryTrxnFee.CreatedDate",
//       type: "date",
//       operator: "lessOrEqual"
//     }
//   },
//   "Daily Transaction Listing": {
//     "Sort Order": {
//       fieldName: "RegulatoryTrxnFeeItem.Sort_Order__c",
//       type: "picklist"
//     },
//     "Transaction From Date": {
//       fieldName: "RegulatoryTrxnFee.CreatedDate",
//       type: "date",
//       operator: "greaterOrEqual"
//     },
//     "Transaction To Date": {
//       fieldName: "RegulatoryTrxnFee.CreatedDate",
//       type: "date",
//       operator: "lessOrEqual"
//     }
//   },
//   "Deposit Summary": {
//     "Transaction From Date": {
//       fieldName: "RegulatoryTrxnFee.CreatedDate",
//       type: "date",
//       operator: "greaterOrEqual"
//     },
//     "Transaction To Date": {
//       fieldName: "RegulatoryTrxnFee.CreatedDate",
//       type: "date",
//       operator: "lessOrEqual"
//     }
//   },
//   "Credit Card Summary": {
//     "Transaction From Date": {
//       fieldName: "RegulatoryTrxnFee.CreatedDate",
//       type: "date",
//       operator: "greaterOrEqual"
//     },
//     "Transaction To Date": {
//       fieldName: "RegulatoryTrxnFee.CreatedDate",
//       type: "date",
//       operator: "lessOrEqual"
//     }
//   },
//   "Aging Report": {
//     Name: {
//       fieldName: "RegulatoryTrxnFeeItem.Name",
//       type: "text"
//     },
//     "Invoice #": {
//       fieldName: "RegulatoryTrxnFeeItem.Invoice_Number__c",
//       type: "text"
//     },
//     Date: {
//       fieldName: "RegulatoryTrxnFee.CreatedDate",
//       type: "date"
//     }
//   },
//   "Returned Checks Summary": {
//     "Work Order Number": {
//       fieldName: "IndividualApplication.SAP_Sequence_Number__c",
//       type: "text"
//     },
//     "Customer Name": {
//       fieldName: "IndividualApplication.SAP_First_Name__c",
//       type: "text"
//     },
//     "Check Number": {
//       fieldName: "RegulatoryTrxnFeeItem.Check_Number__c",
//       type: "text"
//     },
//     "Check Date": {
//       fieldName: "RegulatoryTrxnFeeItem.Check_Date__c",
//       type: "date"
//     },
//     "Check Amount": {
//       fieldName: "RegulatoryTrxnFeeItem.Check_Amount__c",
//       type: "number"
//     },
//     "Bounce Date": {
//       fieldName: "RegulatoryTrxnFeeItem.Bounce_Date__c",
//       type: "date"
//     },
//     Status: {
//       fieldName: "RegulatoryTrxnFeeItem.SAP_Status__c",
//       type: "picklist"
//     },
//     "Reason for Return": {
//       fieldName: "RegulatoryTrxnFeeItem.Return_Reason__c",
//       type: "text"
//     }
//   },
//   "Credit Balance": {
//     "Customer Name": {
//       fieldName: "RegulatoryTrxnFeeItem.Customer_Name__c",
//       type: "text"
//     },
//     "Customer ID": {
//       fieldName: "RegulatoryTrxnFeeItem.SAP_Customer_ID__c",
//       type: "text"
//     },
//     "Handed Date": {
//       fieldName: "RegulatoryTrxnFeeItem.Handed_Date__c",
//       type: "date"
//     }
//   },
//   "Refunded Request History": {
//     "Work Order Number": {
//       fieldName: "IndividualApplication.SAP_Sequence_Number__c",
//       type: "text"
//     },
//     "Customer Name": {
//       fieldName: "IndividualApplication.SAP_First_Name__c",
//       type: "text"
//     },
//     "Check Number": {
//       fieldName: "RegulatoryTrxnFeeItem.Check_Number__c",
//       type: "text"
//     },
//     "Check Date": {
//       fieldName: "RegulatoryTrxnFeeItem.Check_Date__c",
//       type: "date"
//     },
//     "Check Amount": {
//       fieldName: "RegulatoryTrxnFeeItem.Check_Amount__c",
//       type: "number"
//     },
//     "Bounce Date": {
//       fieldName: "RegulatoryTrxnFeeItem.Bounce_Date__c",
//       type: "date"
//     },
//     Status: {
//       fieldName: "RegulatoryTrxnFeeItem.SAP_Status__c",
//       type: "picklist"
//     },
//     "Reason for Return": {
//       fieldName: "RegulatoryTrxnFeeItem.Return_Reason__c",
//       type: "text"
//     }
//   },
//   "User Closeout Report": {
//     Name: {
//       fieldName: "RegulatoryTrxnFeeItem.Name",
//       type: "text"
//     },
//     "Payment Type": {
//       fieldName: "RegulatoryTrxnFeeItem.Payment_Type__c",
//       type: "text"
//     },
//     "Wo/Invoice#": {
//       fieldName: "RegulatoryTrxnFeeItem.Wo_Invoice_Number__c",
//       type: "text"
//     },
//     Date: {
//       fieldName: "RegulatoryTrxnFeeItem.CreatedDate",
//       type: "date"
//     }
//   },
//   "Daily Settlement Report": {
//     "Transaction Type": {
//       fieldName: "RegulatoryTrxnFeeItem.Transaction_Type__c",
//       type: "text"
//     },
//     Date: {
//       fieldName: "RegulatoryTrxnFeeItem.CreatedDate",
//       type: "date"
//     }
//   },
//   "Settlement Report": {
//     "Transaction Type": {
//       fieldName: "RegulatoryTrxnFeeItem.Transaction_Type__c",
//       type: "text"
//     },
//     "Work Order#": {
//       fieldName: "RegulatoryTrxnFeeItem.SAP_Work_Order_Number__c",
//       type: "text"
//     },
//     Date: {
//       fieldName: "RegulatoryTrxnFeeItem.CreatedDate",
//       type: "date"
//     },
//     Amount: {
//       fieldName: "RegulatoryTrxnFeeItem.Amount__c",
//       type: "text"
//     },
//     "Received By": {
//       fieldName: "RegulatoryTrxnFeeItem.Received_By__c",
//       type: "text"
//     },
//     "Check/Money Order#": {
//       fieldName: "RegulatoryTrxnFeeItem.Check_Money_Order_Number__c",
//       type: "text"
//     }
//   },
//   "Notary Public Reconciliation Report": {
//     "Transaction Type": {
//       fieldName: "RegulatoryTrxnFeeItem.Transaction_Type__c",
//       type: "text"
//     },
//     "Report Date": {
//       fieldName: "RegulatoryTrxnFeeItem.Report_Date__c",
//       type: "date"
//     }
//   }
// };

export default class ReportFinsys extends NavigationMixin(LightningElement) {
  @track showActivityAndUser = true;
  @track userOptions = [];
  @track checkReportType = [];

  selectedActivities = [];
  @track isRecordsLoading = false;
  selectedUsers = [];
  @track agingReport = [];
  @track agingCount = "";
  @track recordsFound = 0;
  @track currentPage = 1;
  @track totalPages = 0;
  @track recordsPerPage = 10;
  @track sortedBy = "Customer__c";
  @track sortedDirection = "asc";
  @track startRange = 1;
  @track endRange = 0;
  @track isRegularDeposits = true;

  @track formFields = [];
  @track selectedTransactions = [];
  @track showTransaction = false;

  connectedCallback() {
    Promise.all([
      loadStyle(this, sap_stateExtradition),
      loadStyle(this, reportFinsys)
  ])
      .then(() => {
        console.log("First CSS file (sap_stateExtradition) loaded successfully");
      })
      .catch((error) => console.error("Error loading CSS file:", error));
    this.fetchUsersData();
    this.initializeReportFieldMapping();
  }

  fetchUsersData() {
    fetchUserNames()
      .then((result) => {
        this.userOptions = result;
        this.userOptions = this.userOptions.map((user) => ({
          label: user.Assignee.Name,
          value: user.Assignee.Name,
          checked: false,
          class: "checkbox-item"
        }));
        console.log("the user data is " + JSON.stringify(result));
      })
      .catch((error) => {
        console.error("Error fetching Users:", error);
      });
  }

  @track selectReport;
  @track selectReportOptions = [
    { label: "CORE-CT Deposit Summary", value: "CORE-CT Deposit Summary" },
    {
      label: "Cumulative Deposit Summary",
      value: "Cumulative Deposit Summary"
    },
    { label: "Daily Transaction Listing", value: "Daily Transaction Listing" },
    { label: "Deposit Summary", value: "Deposit Summary" },
    { label: "Credit Card Summary", value: "Credit Card Summary" },
    { label: "Aging Report", value: "Aging Report" },
    { label: "Returned Checks Summary", value: "Returned Checks Summary" },
    { label: "Credit Balance Report", value: "Credit Balance Report" },
    { label: "Refunded Request History", value: "Refunded Request History" },
    { label: "User Closeout Report", value: "User Closeout Report" },
    { label: "Settlement Report", value: "Settlement Report" },
    { label: "Daily Settlement Report", value: "Daily Settlement Report" },
    {
      label: "Notary Public Reconciliation Report",
      value: "Notary Public Reconciliation Report"
    }
  ];

  @track activity;
  @track activityOptions = [];
  
  @track regulatoryOptions = [];
  @track workOrderOptions = [];

  @wire(getObjectInfo, { objectApiName: feeItem_OBJECT })
  feeItemObjectInfo;

  @wire(getObjectInfo, { objectApiName: WorkOrder_OBJECT })
  WorkOrderObjectInfo;
  
  @wire(getPicklistValues, {
      recordTypeId: '$feeItemObjectInfo.data.defaultRecordTypeId',
      fieldApiName: Activity_Field
  })
  handleActivityPicklist({ error, data }) {
      if (data) {
          this.regulatoryOptions = data.values.map(picklistOption => ({
              label: picklistOption.label,
              value: picklistOption.value
          }));
      } else if (error) {
          console.error('Error fetching activity picklist values', error);
      }
      this.mergeOptions();
  }
  
  @wire(getPicklistValues, {
      recordTypeId: '$WorkOrderObjectInfo.data.defaultRecordTypeId',
      fieldApiName: Category_Field
  })
  handleWOActivityPicklist({ error, data }) {
      if (data) {
          this.workOrderOptions = data.values.map(picklistOption => ({
              label: picklistOption.label,
              value: picklistOption.value
          }));
      } else if (error) {
          console.error('Error fetching work order category picklist values', error);
      }
      this.mergeOptions();
  }
  
  mergeOptions() {
      this.activityOptions = [...this.regulatoryOptions, ...this.workOrderOptions];
      console.log('Merged Activity Options:', JSON.stringify(this.activityOptions));
  }

  // @track activityOptions = [
  //   {
  //     label: "Authentication/Apostille",
  //     value: "Authentication/Apostille",
  //     checked: false,
  //     class: "checkbox-item"
  //   },
  //   {
  //     label: "Board of Accountancy",
  //     value: "Board of Accountancy",
  //     checked: false,
  //     class: "checkbox-item"
  //   },
  //   {
  //     label: "Current Refunds CRD",
  //     value: "Current Refunds CRD",
  //     checked: false,
  //     class: "checkbox-item"
  //   },
  //   {
  //     label: "Notary Public",
  //     value: "Notary Public",
  //     checked: false,
  //     class: "checkbox-item"
  //   },
  //   {
  //     label: "Sales",
  //     value: "Sales",
  //     checked: false,
  //     class: "checkbox-item"
  //   },
  //   {
  //     label: "Trademarks",
  //     value: "Trademarks",
  //     checked: false,
  //     class: "checkbox-item"
  //   },
  //   {
  //     label: "Trade & Service Marks",
  //     value: "Trade & Service Marks",
  //     checked: false,
  //     class: "checkbox-item"
  //   },
  //   {
  //     label: "Business Filing",
  //     value: "Business Filing",
  //     checked: false,
  //     class: "checkbox-item"
  //   },
  //   {
  //     label: "UCC Filing",
  //     value: "UCC Filing",
  //     checked: false,
  //     class: "checkbox-item"
  //   },
  //   {
  //     label: "Foreign Investigation",
  //     value: "Foreign Investigation",
  //     checked: false,
  //     class: "checkbox-item"
  //   },
  //   {
  //     label: "Other Requests",
  //     value: "Other Requests",
  //     checked: false,
  //     class: "checkbox-item"
  //   },
  //   {
  //     label: "Mass Agent Change",
  //     value: "Mass Agent Change",
  //     checked: false,
  //     class: "checkbox-item"
  //   },
  //   {
  //     label: "WRIT Case",
  //     value: "WRIT Case",
  //     checked: false,
  //     class: "checkbox-item"
  //   }
  //   // {
  //   //   label: "Reciprocity",
  //   //   value: "Reciprocity",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // { label: "New", value: "New", checked: false, class: "checkbox-item" },
  //   // { label: "Renew", value: "Renew", checked: false, class: "checkbox-item" },
  //   // {
  //   //   label: "Change of Name",
  //   //   value: "Change of Name",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "Change of Address",
  //   //   value: "Change of Address",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "CERT Copy",
  //   //   value: "CERT Copy",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // { label: "Data", value: "Data", checked: false, class: "checkbox-item" },
  //   // {
  //   //   label: "GS Set",
  //   //   value: "GS Set",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "GS Individual Volume",
  //   //   value: "GS Individual Volume",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "Supplement",
  //   //   value: "Supplement",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "P & S Acts",
  //   //   value: "P & S Acts",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "R/M Soft Cover",
  //   //   value: "R/M Soft Cover",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "R/M Hard Cover",
  //   //   value: "R/M Hard Cover",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "Initial",
  //   //   value: "Initial",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "Renewal",
  //   //   value: "Renewal",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "Amendment",
  //   //   value: "Amendment",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "Transfer",
  //   //   value: "Transfer",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "Copies",
  //   //   value: "Copies",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "Search",
  //   //   value: "Search",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // },
  //   // {
  //   //   label: "Budgeted Approp",
  //   //   value: "Budgeted Approp",
  //   //   checked: false,
  //   //   class: "checkbox-item"
  //   // }
  // ];

  initializeReportFieldMapping() {
    this.reportFieldMapping = {
      "CORE-CT Deposit Summary": {
        showActivityAndUser: true,
        showTransaction: false,
        fields: [
          {
            label: "Select Report Type",
            isCombobox: true,
            options: [
              {
                label: "Regular Bank Deposits",
                value: "Regular Bank Deposits"
              },
              { label: "Credit Card Deposits", value: "Credit Card Deposits" }
            ]
          },
          {
            label: "Transaction From Date",
            isDateInput: true,
            inputType: "date"
          },
          { label: "Transaction To Date", isDateInput: true, inputType: "date" }
        ]
      },
      "Cumulative Deposit Summary": {
        showActivityAndUser: true,
        showTransaction: false,
        fields: [
          {
            label: "Transaction From Date",
            isDateInput: true,
            inputType: "date"
          },
          { label: "Transaction To Date", isDateInput: true, inputType: "date" }
        ]
      },
      "Daily Transaction Listing": {
        showActivityAndUser: true,
        showTransaction: false,
        fields: [
          // {
          //   label: "Sort Order",
          //   isCombobox: true,
          //   options: [
          //     {
          //       label: "Program Code, Activity, Sub-Activity, Transaction ID",
          //       value: "Program Code, Activity, Sub-Activity, Transaction ID"
          //     },
          //     {
          //       label: "Payment Type, Transaction ID",
          //       value: "Payment Type, Transaction ID"
          //     },
          //     {
          //       label: "Transaction ID, Program Code, Activity, Sub-Activity",
          //       value: "Transaction ID, Program Code, Activity, Sub-Activity"
          //     },
          //     {
          //       label: "Program Code, Activity, Sub-Activity, Payment Type",
          //       value: "Program Code, Activity, Sub-Activity, Payment Type"
          //     },
          //     {
          //       label: "Payment Type, Transaction ID, Totals Co",
          //       value: "Payment Type, Transaction ID, Totals Co"
          //     }
          //   ]
          // },
          {
            label: "Transaction From Date",
            isDateInput: true,
            inputType: "date"
          },
          { label: "Transaction To Date", isDateInput: true, inputType: "date" }
        ]
      },
      "Deposit Summary": {
        showActivityAndUser: true,
        showTransaction: false,
        fields: [
          {
            label: "Transaction From Date",
            isDateInput: true,
            inputType: "date"
          },
          { label: "Transaction To Date", isDateInput: true, inputType: "date" }
        ]
      },
      "Credit Card Summary": {
        showActivityAndUser: false,
        showTransaction: false,
        fields: [
          {
            label: "Transaction From Date",
            isDateInput: true,
            inputType: "date"
          },
          { label: "Transaction To Date", isDateInput: true, inputType: "date" }
        ]
      },
      "Aging Report": {
        showActivityAndUser: false,
        showTransaction: false,
        fields: [
          { label: "Name", isInput: true, inputType: "text" },
          { label: "Date", isDateInput: true, inputType: "date" }
        ]
      },
      "Refunded Request History": {
        showActivityAndUser: false,
        showTransaction: false,
        fields: [
          { label: "Refund Date", isDateInput: true, inputType: "date" },
          { label: "Customer Name", isInput: true, inputType: "text" },
          { label: "Refund Reason", isInput: true, inputType: "text" },
          { label: "Work Order", isInput: true, inputType: "text" },
          { label: "Refund Status", isInput: true, inputType: "text" },
          { label: "Requested By", isInput: true, inputType: "text" },
          { label: "Payment Number", isInput: true, inputType: "text" },
          { label: "Payment Amount", isInput: true, inputType: "text" },
          { label: "Refund Amount", isInput: true, inputType: "text" }
        ]
      },
      "Credit Balance Report": {
        showActivityAndUser: false,
        showTransaction: false,
        fields: [
          { label: "Customer Name", isInput: true, inputType: "text" },
          { label: "Customer ID", isInput: true, inputType: "text" },
          { label: "Handed Date", isDateInput: true, inputType: "date" }
        ]
      },
      "User Closeout Report": {
        showActivityAndUser: true,
        showTransaction: true,
        fields: [
          // { label: "Name", isInput: true, inputType: "text" },
          { label: "Payment Type", isInput: true, inputType: "text" },
          { label: "Wo/Invoice#", isInput: true, inputType: "text" },
          { label: "Date", isDateInput: true, inputType: "date" }
        ],
      },
      "Daily Settlement Report": {
        showActivityAndUser: false,
        showTransaction: false,
        fields: [
          { label: "Transaction Type", isInput: true, inputType: "text" },
          { label: "Date", isDateInput: true, inputType: "date" }
        ]
      },
      "Returned Checks Summary": {
        showActivityAndUser: false,
        showTransaction: false,
        fields: [
          { label: "Work Order Number", isInput: true, inputType: "text" },
          { label: "Customer Name", isInput: true, inputType: "text" },
          { label: "Check Number", isInput: true, inputType: "text" },
          { label: "Check Date", isDateInput: true, inputType: "date" },
          { label: "Check Amount", isInput: true, inputType: "text" },
          { label: "Status", isInput: true, inputType: "text" },
          { label: "Reason for Return", isInput: true, inputType: "text" }
        ]
      },
      "Settlement Report": {
        showActivityAndUser: false,
        showTransaction: false,
        fields: [
          { label: "Transaction Type", isInput: true, inputType: "text" },
          { label: "Work Order#", isInput: true, inputType: "text" },
          { label: "Date", isDateInput: true, inputType: "date" },
          { label: "Amount", isInput: true, inputType: "text" },
          { label: "Received By", isInput: true, inputType: "text" },
          { label: "Check/Money Order#", isInput: true, inputType: "text" }
        ]
      },
      "Notary Public Reconciliation Report": {
        showActivityAndUser: false,
        showTransaction: false,
        fields: [
          { label: "Transaction Type", isInput: true, inputType: "text" },
          { label: "Report Date", isDateInput: true, inputType: "date" }
        ]
      }
    };
    console.log('show trasaction', this.showTransaction);
    
  }

  @track refundedRequestHistoryFieldMap = {
    2: "Work Order Number",
    3: "Customer Name",
    4: "Check Number",
    5: "Check Date",
    6: "Check Amount",
    7: "Bounce Date",
    8: "Status",
    9: "Reason for Return"
  };

  @track creditBalanceMap = {
    2: "Customer Name",
    3: "Handed Date"
  };

  @track transactionOptions = [
    { label: "All", value: "All", checked: false, class: "checkbox-item" },
    { label: "Apostille", value: "Apostille", checked: false, class: "checkbox-item" },
    { label: "Finsys", value: "Finsys", checked: false, class: "checkbox-item" },
    { label: "BRS", value: "BRS", checked: false, class: "checkbox-item" }
];

  get checkBatchCondition() {
    return this.selectReport === "CORE-CT Deposit Summary";
  }

  get isCumulativeDepositSelected() {
    return this.selectReport === "Cumulative Deposit Summary";
  }

  handleDynamicFieldChange(event) {
    const fieldName = event.target.name;
    const fieldValue = event.target.value;

    const fieldToUpdate = this.formFields.find(
      (field) => field.label === fieldName
    );
    if (fieldToUpdate) {
      fieldToUpdate.value = fieldValue;
    }
    if (fieldName === "Select Report Type") {
      if (fieldValue) {
        this.isRegularDeposits = fieldValue === "Regular Bank Deposits";
      }
    }

    console.log("form field: ", JSON.stringify(this.formFields));
  }

  handleInputChange(event) {
    this.handleClear();
    const field = event.target.name;
    const value =
      event.target.value === "" || event.target.value === null
        ? null
        : event.target.value;
    this[field] = value;
    if (field === "selectReport") {
      this.checkReportTypeStatus();
      this.updateReportSettings(value);
    }
  }

  updateReportSettings(selectedReport) {
    const settings = this.reportFieldMapping[selectedReport] || {};
    this.showActivityAndUser = settings.showActivityAndUser || false;
    this.showTransaction = settings.showTransaction || false;
    this.formFields = settings.fields || [];
}

handleTransactionChange(event) {
    const value = event.target.name;
    const isChecked = event.target.checked;
    const selectedOption = this.transactionOptions.find(
        (option) => option.value === value
    );
    selectedOption.checked = isChecked;
    selectedOption.class = isChecked
        ? "checkbox-item checked-item"
        : "checkbox-item";

    if (isChecked) {
        this.selectedTransactions = [...this.selectedTransactions, value];
    } else {
        this.selectedTransactions = this.selectedTransactions.filter(
            (item) => item !== value
        );
    }
}

handleTransactionReset() {
    this.transactionOptions.forEach((option) => {
        option.checked = false;
        option.class = "checkbox-item";
    });
    this.selectedTransactions = [];
}

  // Handle Activity Reset
  handleActivityReset() {
    this.activityOptions.forEach((option) => {
      option.checked = false;
      option.class = "checkbox-item";
    });
    this.selectedActivities = [];
  }

  // Handle User Reset
  handleUserReset() {
    this.userOptions.forEach((option) => {
      option.checked = false;
      option.class = "checkbox-item";
    });
    this.selectedUsers = [];
  }

  handleActivityCheckboxChange(event) {
    const value = event.target.name;
    const isChecked = event.target.checked;
    const selectedOption = this.activityOptions.find(
      (option) => option.value === value
    );
    selectedOption.checked = isChecked;
    selectedOption.class = isChecked
      ? "checkbox-item checked-item"
      : "checkbox-item";

    if (isChecked) {
      this.selectedActivities = [...this.selectedActivities, value];
    } else {
      this.selectedActivities = this.selectedActivities.filter(
        (item) => item !== value
      );
    }
    console.log("the selected activity are " + this.selectedActivities);
  }

  // Handle User Checkbox Change
  handleUserCheckboxChange(event) {
    const value = event.target.name;
    const isChecked = event.target.checked;
    const selectedOption = this.userOptions.find(
      (option) => option.value === value
    );
    selectedOption.checked = isChecked;
    selectedOption.class = isChecked
      ? "checkbox-item checked-item"
      : "checkbox-item";

    if (isChecked) {
      this.selectedUsers = [...this.selectedUsers, value];
    } else {
      this.selectedUsers = this.selectedUsers.filter((item) => item !== value);
    }
    console.log("the selected users are " + JSON.stringify(this.selectedUsers));
  }

  async handleSearch() {
    if (!this.selectReport) {
      console.error("Please select a report.");
      this.showToast("Error", "Please select a report.", "error");
      return;
    }

    try {
      this.checkReportTypeStatus();
      // const reportId = await getIdReport({ reportName: this.selectReport });

      // if (!reportId) {
      //     console.error('Report ID not found.');
      //     this.showToast('Error', 'Report ID not found.', 'error');
      //     return;
      // }

      // let url = `https://ctds--sapdev001.sandbox.lightning.force.com/lightning/r/Report/${reportId}/view?queryScope=userFolders`;

      if (this.selectReport === "Aging Report") {
        const childComponent = this.template.querySelector(
          "c-sap_-finsys-aging-report"
        );
        if (childComponent) {
          childComponent.receiveFormFields(this.formFields);
          console.log("Form fields passed to child:", this.formFields);
        }
      }else if (this.selectReport === "Daily Settlement Report") {
        const childComponent = this.template.querySelector(
          "c-sap_-finsys-daily-settlement-report"
        );
        if (childComponent) {
          childComponent.receiveFormFields(this.formFields);
          console.log("Form fields passed to child:", this.formFields);
        }
    }else if (this.selectReport === "Settlement Report") {
        const childComponent = this.template.querySelector(
          "c-sap_-finsys-settlement-report"
        );
        if (childComponent) {
          childComponent.receiveFormFields(this.formFields);
          console.log("Form fields passed to child:", this.formFields);
        }
      } else if (this.selectReport === "Credit Balance Report") {
        const childComponent = this.template.querySelector(
          "c-sap_-finsys-credit-balance-report"
        );
        if (childComponent) {
          childComponent.receiveFormFields(this.formFields);
          console.log("Form fields passed to child:", this.formFields);
        }
      } else if (this.selectReport === "Credit Card Summary") {
        const childComponent = this.template.querySelector(
          "c-sap_-finsys-credit-card-report"
        );
        if (childComponent) {
          childComponent.receiveFormFields(this.formFields);
          console.log("Form fields passed to child:", this.formFields);
        }
      } else if (this.selectReport === "Cumulative Deposit Summary") {
        const childComponent = this.template.querySelector(
          "c-sap_-cumulative-deposit-summary-report"
        );
        if (childComponent) {
          childComponent.receiveFormFields(
            this.formFields,
            this.selectedActivities,
            this.selectedUsers
          );
          console.log(
            "Form fields passed to child:",
            JSON.stringify(this.formFields)
          );
        }
      } else if (this.selectReport === "Daily Transaction Listing") {
        const childComponent = this.template.querySelector(
          "c-sap_-daily-transaction-listing-report"
        );
        if (childComponent) {
          childComponent.receiveFormFields(
            this.formFields,
            this.selectedActivities,
            this.selectedUsers
          );
          console.log(
            "Form fields passed to child:",
            JSON.stringify(this.formFields)
          );
        }
      } else if (this.selectReport === "Deposit Summary") {
        const childComponent = this.template.querySelector(
          "c-sap_-deposit-summary-report"
        );
        if (childComponent) {
          childComponent.receiveFormFields(
            this.formFields,
            this.selectedActivities,
            this.selectedUsers
          );
          console.log(
            "Form fields passed to child:",
            JSON.stringify(this.formFields)
          );
        }
      } else if (this.selectReport === "Returned Checks Summary") {
        const childComponent = this.template.querySelector(
          "c-sap_-returned-checks-summary-report"
        );
        if (childComponent) {
          childComponent.receiveFormFields(this.formFields);
          console.log(
            "Form fields passed to child:",
            JSON.stringify(this.formFields)
          );
        }
      } else if (this.selectReport === "Refunded Request History") {
        const childComponent = this.template.querySelector(
          "c-sap_-refund-request-report"
        );
        if (childComponent) {
          childComponent.receiveFormFields(this.formFields);
          console.log(
            "Form fields passed to child:",
            JSON.stringify(this.formFields)
          );
        }
      } else if (this.selectReport === "User Closeout Report") {
        const childComponent = this.template.querySelector(
          "c-sap_-user-closeout-report"
        );
        if (childComponent) {
          childComponent.receiveFormFields(
            this.formFields,
            this.selectedActivities,
            this.selectedUsers
          );
          console.log(
            "Form fields passed to child:",
            JSON.stringify(this.formFields)
          );
        }
      } else if (this.selectReport === "Notary Public Reconciliation Report") {
        const childComponent = this.template.querySelector(
          "c-sap_-notary-public-report"
        );
        if (childComponent) {
          childComponent.receiveFormFields(
            this.formFields,
            this.selectedActivities,
            this.selectedUsers
          );
          console.log(
            "Form fields passed to child:",
            JSON.stringify(this.formFields)
          );
        }
      } else if (this.selectReport === "CORE-CT Deposit Summary") {
        const childComponent = this.template.querySelector("c-sap_-core-c-t-report");
        if (childComponent) {
          childComponent.receiveFormFields(
            this.formFields,
            this.selectedActivities,
            this.selectedUsers
          );
          console.log(
            "Form fields passed to child:",
            JSON.stringify(this.formFields)
          );
        }
      }
      // else {
      //     if (this.selectReport == 'Credit Balance Report') {
      //         let url = `https://ctds--sapdev001.sandbox.lightning.force.com/lightning/r/Report/${reportId}/view?queryScope=userFolders`;

      //         // Apply Credit Balance filters dynamically
      //         this.formFields.forEach((field) => {
      //             if (field.value && field.value.trim() !== '') {
      //                 const fieldValue = encodeURIComponent(field.value.trim());
      //                 if (field.label === 'Customer Name') {
      //                     url += `&fv2=${fieldValue}`; // fv2 is for Customer Name
      //                 } else if (field.label === 'Handed Date') {
      //                     url += `&fv3=${fieldValue}`; // fv3 is for Handed Date
      //                 }
      //             }
      //         });

      //         console.log('Constructed Credit Balance URL:', url);

      //         // Open the constructed URL
      //         window.open(url, '_blank');
      //     } else {
      //         // Handle other report types
      //         let filterIndex = 0;
      //         this.formFields.forEach((field) => {
      //             console.log('field value: ', field.value);
      //             if (field.value !== null && field.value !== undefined && field.value !== '') {
      //                 url += `&fv${filterIndex}=${encodeURIComponent(field.value)}`;
      //                 filterIndex++;
      //             } else {
      //                 filterIndex++;
      //             }
      //         });

      //         if (this.selectedActivities.length > 0) {
      //             url += `&fv${filterIndex}=${encodeURIComponent(this.selectedActivities.join(','))}`;
      //             filterIndex++;
      //         }

      //         if (this.selectedUsers.length > 0) {
      //             url += `&fv${filterIndex}=${encodeURIComponent(this.selectedUsers.join(','))}`;
      //         }

      //         window.open(url, '_blank');
      //     }
      //}
    } catch (error) {
      console.error("Error fetching report ID:", error);
      this.showToast("Error", "Error fetching report ID.", "error");
    }
  }

  // get isSettelmentReport(){
  //     if(this.selectReport == 'Settlement Report'){
  //         return true;
  //     }else{
  //         return false;
  //     }
  // }

  // get isAgingReport(){
  //     if(this.selectReport === 'Aging Report'){
  //         return true;
  //     }else{
  //         return false;
  //     }
  // }

  async checkReportTypeStatus() {
    this.checkReportType = {
      isSettlementReport: this.selectReport === "Settlement Report",
      isDailySettlementReport: this.selectReport === "Daily Settlement Report",
      isCreditBalanceReport: this.selectReport === "Credit Balance Report",
      isCreditCardReport: this.selectReport === "Credit Card Summary",
      isAgingReport: this.selectReport === "Aging Report",
      isCumulativeDepositSummary: this.selectReport === "Cumulative Deposit Summary",
      isDailyTransactionListing: this.selectReport === "Daily Transaction Listing",
      isDepositSummary: this.selectReport === "Deposit Summary",
      isReturnedChecksSummary: this.selectReport === "Returned Checks Summary",
      isRefundedRequestHistory: this.selectReport === "Refunded Request History",
      isUserCloseoutReport: this.selectReport === "User Closeout Report",
      isNotaryPublicReconciliationReport: this.selectReport === "Notary Public Reconciliation Report",
      isCoreCtDepositSummary: this.selectReport === "CORE-CT Deposit Summary"
    };
  }
  

  handleClear() {
    this.selectReport = null;
    this.formFields.forEach((field) => {
        field.value = null;
    });
    
    this.handleTransactionReset();
    this.handleUserReset();
    this.handleActivityReset();
    
    this.showActivityAndUser = false;
    this.showTransaction = false;
    this.checkReportTypeStatus();
}

  result = [];



  // async handleDownloadPdf() {
  //     if (!this.selectReport) {
  //         this.showToast('Error', 'Please select a report type', 'error');
  //         return;
  //     }

  //     // Create the parameters object using the parent component's values
  //     const searchParams = {
  //         dateFilter: this.formFields.dateFilter,
  //         transactionFromDate: this.formFields.fromDate,
  //         transactionToDate: this.formFields.toDate,
  //         selectedActivities: this.selectedActivities,
  //         selectedUsers: this.selectedUsers,
  //         pageSize: this.pageSize,
  //         pageNumber: this.pageNumber
  //     };

  //     // Convert parameters to a JSON string and properly encode it
  //     const encodedParams = encodeURIComponent(JSON.stringify(searchParams));

  //     // Generate the URL for the Visualforce page
  //     const vfPageUrl = `/apex/ReportPDF?reportType=${this.selectReport}&params=${encodedParams}`;

  //     // Use NavigationMixin to open the VF page
  //     this[NavigationMixin.Navigate]({
  //         type: 'standard__webPage',
  //         attributes: {
  //             url: vfPageUrl
  //         }
  //     });
  // }

  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }
}
import LightningModal from "lightning/modal";
import { loadStyle } from "lightning/platformResourceLoader";
import stateExtradition from "@salesforce/resourceUrl/stateExtradition";
import searchContacts from "@salesforce/apex/FinsysWorkOrderController.searchContacts";
import getContactFirstName from "@salesforce/apex/FinsysWorkOrderController.getContactFirstName";
import getActivityData from "@salesforce/apex/FinsysWorkOrderController.getActivityData";
import getActivityFee from "@salesforce/apex/FinsysWorkOrderController.getActivityFee";
import workOrderConfirmationModal from "c/workOrderConfirmationModal";
import updateWorkOrder from "@salesforce/apex/FinsysWorkOrderController.updateWorkOrder";
import finsysSendEmailModal from "c/finsysSendEmailModal";
import getWorkOrderDetailsUpdated from "@salesforce/apex/FinsysWorkOrderController.getWorkOrderDetailsUpdated";
import getBRSdata from "@salesforce/apex/FinsysWorkOrderController.getBRSdata";
import updateRefundTransaction from "@salesforce/apex/FinsysWorkOrderController.updateRefundTransaction";
import createRefundTransaction from "@salesforce/apex/FinsysWorkOrderController.createRefundTransaction";
import { CurrentPageReference } from "lightning/navigation";
import { track, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class FinsysWorkOrderModal extends NavigationMixin(
  LightningModal
) {
  @track recordId = "";
  @track regulatoryTrxnFeeId = "";
  @track mode = ""; // 'view', 'edit', 'refund' ,'add'
  @track source;
  // @track selectedFeeItemIndexFor_edit_refund_mode;
  @track totalTransactionFeeAmount = 0;
  @track totalTransactionFeeAmountForRefund = 0;
  @track totalTransactionFeeItemAmount = 0;
  @track individualFeeItemRefundAmount = 0;
  @track refundAmountExceeded = false;
  @api totalOfAllFeeItemForEditModeOnly = 0;
  //@api activityId='';
  @track transactionType = "";
  @track batchId = "";
  @track creatingOrUpdating = false;
  @track visible = true;
  @track isSinglePayment = false;

  @track workOrderStatus = "";
  @track workOrderDate = null;
  @track comment = "";
  @track customerDetails = [];
  @track customerFound = false;
  @track search = '';
  @track selectedCustomerId = null;

  @track lastName = "";
  @track middleInitial = "";
  @track firstName = "";
  @track organizationName = "";
  @track emailAddress = "";
  @track phoneNumber = "";
  @track accountBalance = "";
  @track location = "";
  @track address2 = "";
  @track city = "";
  @track state = "";
  @track zipCode = "";
  @track country = "";
  @track caBalance = "";
  @track isDelinquite = false;

  @track defaultActivity = "";
  @track defaultActivityId = "";
  @track updatedActivity = "";
  @track workOrderLabel = "Add Transaction";
  @track isAllMapping = false;
  @track isEditTransaction = false;
  @track transactionList = [];
  @track multipleTransactionList = [];
  @track multipleRefundList = [];
  @track documentsList = [];
  @track deletedFiles = [];
  @track activitiesMapping = [];

  @track refundHistoryFound = false;
  @track showRefundCard = false; // Toggle to show card dropdown
  @track selectedRefundCard = ""; // Selected refund card value
  @track refundCardOptions = [];
  @track refundMethod = "";
  @track refundDate = "";
  @track voucherId = "";
  @track refundAmount = "";
  @track refundHistory = [];
  @track editRefundList = [];
  @track refundReason = "";

  @track activityOptions = [];
  @track subActivityOptions = [];
  @track programCodeOptions = [];
  @track fullActivityData = [];

  @track refundMethodOptions = [];
  @track refundHistoryForEditRefund = [];

  @track edit_refund = false;
  @track view_refund = false;

  @track batchOptions = [
    { label: "Authentication/Apostille", value: "Authentication/Apostille" },
    { label: "Board of Accountancy", value: "Board of Accountancy" },
    { label: "Current Refunds CRD", value: "Current Refunds CRD" },
    { label: "Notary Public", value: "Notary Public" },
    { label: "Sales", value: "Sales" },
    { label: "Trademarks", value: "Trademarks" }
  ];

  @track workOrderStatusOptions = [
    { label: "Open", value: "Open" },
    { label: "In Progress", value: "In Progress" },
    { label: "Closed", value: "Closed" }
  ];

  @track paymentCollectionOptions = [
    { label: "IRS (ACH)", value: "IRS (ACH)" },
    { label: "Foreign Investigations", value: "Foreign Investigations" },
    {
      label: "Notary Public (ACH) via Velocity",
      value: "Notary Public (ACH) via Velocity"
    }
  ];

  @track paymentTypeOptions = [
    { label: "Cash", value: "Cash" },
    { label: "Card", value: "Card" },
    { label: "Check", value: "Check" },
    { label: "Money Order", value: "Money Order" }
  ];

  @track refundMethodForEditMode = [
    { label: "Check", value: "Check" },
    { label: "Card", value: "Card" }
  ];

  @track cardTypeOptions = [
    { label: "Master Card", value: "Master Card" },
    { label: "Visa", value: "Visa" },
    { label: "Discover", value: "Discover" },
    { label: "Amex", value: "Amex" }
  ];

  @track docTypeOptions = [
    { label: "Passport", value: "Passport" },
    { label: "Driver's Licence", value: "Driver's Licence" }
  ];

  @track urlBatchId = "";

  @wire(CurrentPageReference)
  setCurrentPageReference(pageRef) {
    if (pageRef) {
      this.mode = pageRef.state.c__mode;
      this.source = pageRef.state.c__source;

      if (pageRef.state.c__recordID) {
        this.recordId = pageRef.state.c__recordID;
        //this.activityId = pageRef.state.c__activityId;
        console.log(this.recordId);
      } else {
        this.recordId = null;
      }

      if (pageRef.state.c__batchId) {
        this.urlBatchId = pageRef.state.c__batchId;
      }
    }
    console.log('current mode is '+ this.mode);

    this.loadTheReord();
  }

  // Dynamic header text based on the record's existence and read-only state
  // get headerText() {
  //   if (!this.recordId && this.mode === "add") {
  //     this.transactionType = "New Transaction";
  //     return "Add Work Order";
  //   }
  //   if ((this.mode === "view" || this.mode === "workOrder") && this.recordId) {
  //     return "View Work Order";
  //   }
  //   if (
  //     this.mode === "edit" &&
  //     this.recordId &&
  //     this.source !== "viewOrEditBatchFinsys"
  //   ) {
  //     return "Edit Work Order";
  //   }

  //   if (this.mode === "edit" && this.source === "viewOrEditBatchFinsys") {
  //     return "Edit Transaction";
  //   }

  //   if (this.mode === "addRefund") {
  //     this.transactionType = "Refund Transaction";
  //     return "Add Refund";
  //   }

  //   if (this.mode === "view_refund" && this.recordId) {
  //     return "View Refund";
  //   }

  //   if (this.mode === "edit_refund" && this.recordId) {
  //     return "Edit Refund";
  //   }
  // }

  get headerText() {
    if (!this.recordId && this.mode === "add") {
        this.transactionType = "New Transaction";
        return "Add Work Order";
    }

    if (this.recordId) {
        switch (this.mode) {
            case "view":
            case "workOrder":
                return "View Work Order";

            case "edit":
                return this.source === "viewOrEditBatchFinsys" ? "Edit Transaction" : "Edit Work Order";

            case "view_refund":
                return "View Refund";

            case "edit_refund":
                return "Edit Refund";

                default:
                  return "";
        }
    }

    if (this.mode === "addRefund") {
        this.transactionType = "Refund Transaction";
        return "Add Refund";
    }

    return ""; // Default return to prevent undefined issues
}


  handleClear(){
    this.workOrderStatus = "";
    this.workOrderDate = null;
    this.comment = "";
    this.search = '';
    this.customerFound = false;
    this.customerDetails = null;
    this.selectedCustomerId = '';
    this.lastName = "";
    this.middleInitial = "";
    this.firstName = "";
    this.organizationName = "";
    this.emailAddress = "";
    this.phoneNumber = "";
    this.accountBalance = "";
    this.location = "";
    this.address2 = "";
    this.city = "";
    this.state = "";
    this.zipCode = "";
    this.country = "";
    this.transactionType = "New Transaction";
    this.defaultActivity = "";
    this.updatedActivity = "";
    this.transactionList = [];
    this.documentsList = [];
    this.multipleTransactionList = [];
    this.multipleRefundList = [];
    this.totalTransactionFeeAmount = 0;
    this.totalTransactionFeeAmountForRefund = 0;
    this.refundMethod = "";
    this.refundAmount = "";
    this.refundDate = null;
    this.voucherId = "";
    this.selectedRefundCard = "";
    this.refundReason ="";

  }

  loadTheReord() {
    if (!this.recordId && this.mode === "add") {
      this.handleClear();
      this.fetchActivityData();
      this.initializeDefaultTransaction();
      this.initializeDefaultDocument();
    } else if (
      this.mode === "view" ||
      this.mode === "edit" ||
      this.mode === "addRefund"
    ) {
      this.handleClear();
      this.loadWorkOrderData();

      this.edit_refund = false;
    } else if (this.mode === "edit_refund") {
      this.loadWorkOrderData();
      this.edit_refund = true;
      this.view_refund = false;
      this.transactionType = "Refund Transaction";
    } else if (this.mode === "view_refund") {
      this.loadWorkOrderData();
      this.view_refund = true;

      this.edit_refund = false;
      this.transactionType = "Refund Transaction";
    } else if(this.mode === "workOrder"){
      this.handleClear();
      console.log("we are into work order mode only");
      this.loadBRSdata();

    }
    console.log(
      "transaction list have data is " + JSON.stringify(this.transactionList)
    );
  }

  get isAddWorkMode() {
    return this.mode === "add";
  }

  get isViewMode() {
    if (this.mode === "view" && this.recordId) return true;
    else if (this.mode === "view_refund" && this.recordId) return true;
    else if (this.mode === "addRefund" && this.recordId) return true;
    else if (this.mode === "edit_refund" && this.recordId) return true;
    else if (this.mode === "workOrder" && this.recordId) return true;
    return false;
  }

  get isViewModeFooter() {
    if (this.mode === "view" && this.recordId) return true;
    else if (this.mode === "view_refund" && this.recordId) return true;
    else if (this.mode === "addRefund" && this.recordId) return true;
    else if (this.mode === "workOrder" && this.recordId) return true;
    return false;
  }

  get isEditMode() {
    if (this.mode === "edit" && this.recordId) return true;
    else if (this.mode === "edit_refund" && this.recordId) return true;
    return false;
  }

  get isAddRefundWorkMode() {
    return this.mode === "addRefund";
  }

  get isRefundSectionEditMode() {
    if (this.mode === "view_refund" && this.recordId) return true;
    return false;
  }

  get showTransactionsMode() {
    if (this.urlBatchId && this.source === "viewOrEditBatchFinsys") return true;
    return false;
  }

  get showCustomerSearch() {
    if (this.mode === "add" || this.mode === "edit") return true;
    return false;
  }

  get showRefundSec() {
    if (
      this.mode === "edit_refund" ||
      this.mode === "view_refund" ||
      this.mode === "addRefund"
    )
      return true;
    return false;
  }

  get isBRSModalMode(){
    return this.mode === "workOrder";
  }

  @track footerOprions = false;

  cancelEditMode() {
    this.footerOprions = true;

    if (this.mode === "edit_refund") this.mode = "view_refund";

    if (this.mode === "edit" && this.source !== "viewOrEditBatchFinsys")
      this.mode = "view";

    if (this.urlBatchId && this.source === "viewOrEditBatchFinsys") {
      try {
        // Navigate to the RecordDetail component and pass the recordId
        this[NavigationMixin.Navigate]({
          type: "standard__component",
          attributes: {
            componentName: "c__viewOrEditBatchFinsys" // The target component name
          },
          state: {
            c__mode: "edit",
            c__recordID: this.urlBatchId
          }
        });
      } catch (error) {
        console.error("Error navigating to RecordDetail:", error);
      }
    }

    this.loadTheReord();

    this.footerOprions = false;
  }

  goBackModal() {
    if (this.mode === "view_refund") {
      try {
        // Navigate to the RecordDetail component and pass the recordId
        this[NavigationMixin.Navigate]({
          type: "standard__component",
          attributes: {
            componentName: "c__finsysWorkOrder" // The target component name
          }
        });
      } catch (error) {
        console.error("Error navigating to RecordDetail:", error);
      }
    } else if (this.urlBatchId && this.source === "viewOrEditBatchFinsys") {
      try {
        // Navigate to the RecordDetail component and pass the recordId
        this[NavigationMixin.Navigate]({
          type: "standard__component",
          attributes: {
            componentName: "c__viewOrEditBatchFinsys" // The target component name
          },
          state: {
            c__mode: "view",
            c__recordID: this.urlBatchId
          }
        });
      } catch (error) {
        console.error("Error navigating to RecordDetail:", error);
      }
    } else {
      try {
        // Navigate to the RecordDetail component and pass the recordId
        this[NavigationMixin.Navigate]({
          type: "standard__component",
          attributes: {
            componentName: "c__finsysWorkOrder" // The target component name
          }
        });
      } catch (error) {
        console.error("Error navigating to RecordDetail:", error);
      }
    }
  }

  goToParentModal() {
    if (this.urlBatchId && this.source === "viewOrEditBatchFinsys") {
      try {
        // Navigate to the RecordDetail component and pass the recordId
        this[NavigationMixin.Navigate]({
          type: "standard__component",
          attributes: {
            componentName: "c__viewOrEditBatchFinsys" // The target component name
          },
          state: {
            c__mode: "view",
            c__recordID: this.urlBatchId
          }
        });
      } catch (error) {
        console.error("Error navigating to RecordDetail:", error);
      }
    } else {
      try {
        // Navigate to the RecordDetail component and pass the recordId
        this[NavigationMixin.Navigate]({
          type: "standard__component",
          attributes: {
            componentName: "c__finsysWorkOrder" // The target component name
          }
        });
      } catch (error) {
        console.error("Error navigating to RecordDetail:", error);
      }
    }
  }

  get buttonStatus() {
    if (this.mode === "view") {
      return true;
    } else if (this.refundAmountExceeded) {
      return true;
    } else if (!this.refundAmountExceeded) {
      return false;
    }
    return false;
  }

  // Computed property for email address
  get checkEmailAddress() {
    return this.emailAddress ? this.emailAddress : "";
  }

  // get isAddOrder(){
  //     if(this.mode === 'add'){
  //         return false;
  //     }else{
  //         return true;
  //     }
  // }

  get editButtonMode() {
    if (this.mode === "view" || this.mode === "view_refund") {
      return true;
    }
    return false;
  }

  connectedCallback() {
    Promise.all([loadStyle(this, stateExtradition)])
      .then(() => {
        console.log("Both CSS files loaded successfully");
      })
      .catch((error) => {
        console.error("Error loading CSS files:", error);
      });

    //document.addEventListener('click', this.handleOutsideClick);

    //  this.loadTheReord();
  }

  disconnectedCallback() {
    // Remove the click listener
    document.removeEventListener("click", this.handleOutsideClick);
  }

  // Initialize default transaction with `isRemovable = false`
  initializeDefaultTransaction() {
    console.log(this.defaultActivity);
    const defaultTransaction = {
      id: Date.now(),
      tnxId: "",
      activity: this.defaultActivity,
      batchId: null,
      activityCode: "",
      programCode: "",
      feeAmount: "",
      taxExempt: false,
      isRemovable: false, // Hide "Remove" button for the default transaction
      reportingOnly: false,
      paymentCollection: "",
      paymentActivity: "",
      paymentType: "",
      cardType: "",
      cardDigit: "",
      serialNumber: "",
      ckNumber: "",
      paymentAmount: "",
      transactionDate: "",
      isSubCard: false,
      isSubMoneyOrder: false,
      isSubCheck: false,
      isFirst: this.defaultActivity != "" ? true : false
    };
    this.transactionList = [defaultTransaction];
  }

  // Initialize default payment with `isRemovable = false`

  initializeDefaultDocument() {
    this.documentsList = [
      ...this.documentsList,
      { id: Date.now(), docType: "", docFile: null, isRemovable: true }
    ];
  }

  async loadWorkOrderData() {
    this.footerOprions = true;
    try {
      await this.fetchActivityData();

      let requestData = JSON.stringify({
        workOrderId: this.recordId,
        transactionType: this.transactionType
      });

      const data = await getWorkOrderDetailsUpdated({ requestData });
      if (!data) throw new Error("No data returned");
      console.log(data);

      const workOrder = data.workOrder || {};
      this.batchId = data.batchId || "";
      this.defaultActivity = data.defaultActivity || "";
      this.workOrderDate = workOrder.woDate || null;
      this.workOrderStatus = workOrder.status || "";
      this.comment = workOrder.comments || "";
      this.selectedCustomerId = workOrder.contactId || "";
      this.lastName = workOrder.lastName || "";
      this.middleInitial = workOrder.middleName || "";
      this.firstName = workOrder.firstName || "";
      this.organizationName = workOrder.organizationName || "";
      this.phoneNumber = workOrder.phoneNumber !=null ? this.formatPhoneNumber(workOrder.phoneNumber) : "";
      this.emailAddress = workOrder.emailAddress || "";
      this.location = workOrder.addressLine1 || "";
      this.address2 = workOrder.suiteApartmentFloor || "";
      this.city = workOrder.city || "";
      this.state = workOrder.state || "";
      this.zipCode = workOrder.zipCode || "";
      this.country = workOrder.country || "";
      this.accountBalance = workOrder.customerAccountBal
          ? (workOrder.customerAccountBal < 0
              ? "-$" + Math.abs(workOrder.customerAccountBal).toFixed(2)
              : "$" + workOrder.customerAccountBal.toFixed(2))
          : null;



      console.log('accountBalance  is '+this.accountBalance);


      if (this.mode === "edit") {
        this.selectedCustomerId = workOrder.contactId;
        console.log("selected CustomerId", this.selectedCustomerId);
        // this.search = workOrder.firstName;
        if (this.selectedCustomerId) {
          getContactFirstName({ contactId: this.selectedCustomerId })
              .then(result => {
                  this.search = result;
                  this.fetchCustomerResults();
                  console.log('Contact First Name:', this.search);
              })
              .catch(error => {
                  console.error('Error fetching contact first name:', error);
              });
      }
        // this.getContactName(this.selectedCustomerId);
      }

      const transactions = data.transactions || [];
      this.multipleTransactionList = transactions.map((trx) => ({
        id: trx.id,
        tnxId: trx.id,
        activity: trx.activity || "",
        activityCode: trx.activityCode || "",
        programCode: trx.programCode || "",
        feeAmount: trx.feeAmount ? "$" + trx.feeAmount : "",
        taxExempt: trx.taxExempt || false,
        taxExemptDisplay: trx.taxExempt ? "Yes" : "No",
        reportingOnly: trx.reportingOnly || false,
        reportingOnlyDisplay: trx.reportingOnly ? "Yes" : "No",
        transactionDate: trx.transactionDate || "",
        paymentCollection: trx.paymentCollection || "",
        paymentType: trx.paymentType || "",
        cardType: trx.cardType || "",
        cardDigit: trx.cardDigit || "",
        serialNumber: trx.serialNumber || "",
        ckNumber: trx.ckNumber || "",
        paymentAmount: trx.paymentAmount ? "$" + trx.paymentAmount : "",
        batchId: trx.batchId || "",
        recordTypeName: trx.recordType || ""
      }));

      // console.log(
      //   "multipleTransactionList have data as" +
      //     JSON.stringify(this.multipleTransactionList)
      // );

      this.totalTransactionFeeAmount = 0;

      this.multipleTransactionList.forEach((transaction) => {
        if (transaction.recordTypeName === "New Transaction") {
          this.totalTransactionFeeAmount += Number(
            transaction.paymentAmount.slice(1)
          );
        }
      });

      this.totalTransactionFeeAmount = '$' + this.totalTransactionFeeAmount.toFixed(2);


      const refundTransactions = data.refundTransactions || [];
      this.multipleRefundList = refundTransactions.map((refund) => ({
        id: refund.id,
        refundAmount: refund.refundAmount,
        refundDate: refund.refundDate,
        recordTypeName: refund.recordType
      }));

      // console.log(
      //   "multipleRefundList has data as: " +
      //     JSON.stringify(this.multipleRefundList)
      // );

      this.totalTransactionFeeAmountForRefund = 0;

      this.multipleRefundList.forEach((refund) => {
        if (refund.recordTypeName === "Refund Transaction") {
          // console.log('inside refund section calculation');

          this.totalTransactionFeeAmountForRefund += Number(
            refund.refundAmount.slice(0)
          );
          // console.log('current refund is '+this.totalTransactionFeeAmountForRefund);
          // console.log('and refundAmount is '+ Number(refund.refundAmount.slice(0)));

        }
      });

      // console.log(
      //   " total transaction amount is " + this.totalTransactionFeeAmount
      // );
      // console.log(
      //   " total refund transaction amount is " +
      //     this.totalTransactionFeeAmountForRefund
      // );

      this.initializeDefaultTransaction();
      this.generateDependentOptions(this.defaultActivity);

      if (this.transactionType === "New Transaction") {
        // Map documents (using FileInfo helper class)
        const documents = data.documents || [];
        this.documentsList = documents.map((doc, index) => ({
          id: `document-${Date.now()}-${index}`, // Generate unique ID for frontend
          docType:
            doc.title.substring(0, doc.title.lastIndexOf(".")) || doc.title, // Extract type from title
          docFile: {
            fileName: doc.title || "",
            documentId: doc.documentId || "",
            downloadLink: `/sfc/servlet.shepherd/version/download/${doc.versionId}`, // Download link
            docId: doc.Id || "" // ContentDocumentLink ID
          },
          isRemovable: true // Allow removal for fetched documents
        }));
        if (this.documentsList.length === 0) {
          this.initializeDefaultDocument();
        }
      } else {
        // Map refund transactions
        // console.log("Inside refund flow");
        const refunds = data.refundTransactions || [];

        if (refunds.length > 0) {
          // Check if refunds has data
          this.refundHistory = refunds.map((refund) => ({
            id: refund.id,
            refundId: refund.refundId,
            originalId: refund.originalTransactionId || null,
            showRefundCard: refund.originalTransactionId || false,
            cardNumber: refund.cardNumber ,
            voucherId: refund.voucherId || "N/A", // Voucher ID
            refundPaymentMethod: refund.refundPaymentMethod || "", // Payment Method
            refundAmount: refund.refundAmount ? "$" + refund.refundAmount : "", // Refund Amount
            refundDate: refund.refundDate || "",
            refundDateFormatted: refund.refundDateFormatted || "",
            refundReason: refund.refundReason || "",
            refundStatus: refund.status
          }));

          this.individualFeeItemRefundAmount = Number(
            this.refundHistory[0].refundAmount
          );

          this.refundHistoryFound = true;
          console.log('refundHistory data is '+JSON.stringify(this.refundHistory));
          this.editRefundList = this.refundHistory;

        } else {
          console.log("No refunds found, skipping refund mapping.");
          this.refundHistory = [];
          this.editRefundList = this.refundHistory;
          this.individualFeeItemRefundAmount = 0;
          this.refundHistoryFound = false;
        }
        this.updateRefundMethodOptions();
        this.updateRefundCardOptions();
      }
    } catch (error) {
      console.error("Error loading Work Order data:", error);
    } finally {
      this.footerOprions = false;
    }
  }

  async loadBRSdata(){
    this.footerOprions = true;
    const recordId = this.recordId;
    const data = await getBRSdata({ recordId });

    this.workOrderStatus = data.status != null ? (data.status === 'In-Progress' ? 'In Progress' : data.status) : null;
    this.workOrderDate = data.createdDate !=null ? data.createdDate : null;
    this.lastName = data.customerLastName || "";
    this.middleInitial = data.customerMiddleName || "";
    this.firstName = data.customerFirstName || "";
    this.organizationName = data.customerOrganization || "";
    this.phoneNumber = data.customerPhone || "";
    this.emailAddress = data.customerEmail || "";

    this.location = data.mailingStreet || "";
    // this.address2 = data.suiteApartmentFloor || "";
    this.city = data.mailingCity || "";
    this.state = data.mailingState || "";
    this.zipCode = data.mailingPostalCode || "";
    this.country = data.mailingCountry || "";
    this.accountBalance = data.customerAccountBalance ? "$"+ data.customerAccountBalance.toFixed(2) : null;


    // this.batchId = data.batchId || "";
    // this.defaultActivity = data.defaultActivity || "";
    // this.comment = workOrder.comments || "";
    // this.selectedCustomerId = workOrder.contactId || "";

    const transactions = data.transactions || [];
    this.multipleTransactionList = transactions.map((trx) => ({
      id: trx.id,
      // tnxId: trx.id,
      activity: trx.category || "",
      // activityCode: trx.activityCode || "",
      // programCode: trx.programCode || "",
      feeAmount: trx.amount ? "$" + trx.amount.toFixed(2) : "",
      // taxExempt: trx.taxExempt || false,
      // taxExemptDisplay: trx.taxExempt ? "Yes" : "No",
      // reportingOnly: trx.reportingOnly || false,
      // reportingOnlyDisplay: trx.reportingOnly ? "Yes" : "No",
      // transactionDate: trx.transactionDate || "",
      // paymentCollection: trx.paymentCollection || "",
      paymentType: trx.recordType ==="Charge_Card" ? "Card" : trx.recordType,
      cardType: trx.brand || "",
      cardDigit: trx.cardLast4Digits || "",
      // serialNumber: trx.serialNumber || "",
      // ckNumber: trx.ckNumber || "",
      paymentAmount: trx.amount ? "$" + trx.amount.toFixed(2) : "",
      // batchId: trx.batchId || "",
      // recordTypeName: trx.recordType || ""
    }));


    console.log(data);

    this.footerOprions = false;

  }

  updateRefundMethodOptions() {
    const hasCardPayment = this.multipleTransactionList.some(
      (payment) => payment.paymentType === "Card"
    );

    // Dynamically generate refund options
    this.refundMethodOptions = [];
    if (hasCardPayment) {
      this.refundMethodOptions.push({ label: "Card", value: "Card" });
      this.refundMethodOptions.push({ label: "Check", value: "Check" }); // Always include Check with Card
    } else {
      this.refundMethodOptions.push({ label: "Check", value: "Check" });
    }

    console.log("Updated Refund Method Options:", this.refundMethodOptions);
   // console.log('rufund Card options are :'+this.refundCardOptions);

  }

  updateRefundCardOptions() {
    // Filter and map the multipleTransactionList to include only card payments
    this.refundCardOptions = this.multipleTransactionList
      .filter((payment) => payment.paymentType === "Card") // Only include payments with type "Card"
      .map((payment) => ({
        label: `${payment.cardType} ending in ${payment.cardDigit}`, // Customize the label
        value: payment.id // Use the payment ID as the value
      }));

    console.log("Updated Refund Card Options:", this.refundCardOptions);
  }

  // getDisplayLabel(activityId) {
  //   if (activityId && activityId.includes(",")) {
  //     return "All"; // Return 'All' if the value contains a comma
  //   }
  //   return activityId || "All"; // Return the single ID or default to 'All'
  // }

  // Event handler for input change



  handleSearchChange(event) {
    this.search = event.target.value;

    // Fetch results only if the search string has more than 3 characters
    if (this.search.length > 1) {
      this.fetchCustomerResults();
    } else {
      this.customerDetails = []; // Clear results if the search string is too short
      this.customerFound = false;
    }
  }

  // Fetch customer records based on the search term
  fetchCustomerResults() {
    this.isLoading = true;

    searchContacts({ searchName: this.search })
      .then((result) => {
        if (result && result.length > 0) {
          // Format the result for display by converting Delinquent to "Yes" or "No"
          this.customerDetails = result.map((customer) => ({
            ...customer,
            DelinquentLabel: customer.Deliquent__c ? "Yes" : "No", // Add a new field
            Address: [
              customer.MailingStreet,
              customer.MailingCity,
              customer.MailingState,
              customer.MailingPostalCode,
              customer.MailingCountry
            ]
              .filter(Boolean)
              .join(", "),
            Organization: customer.Organization__c,
            isChecked: customer.Id === this.selectedCustomerId
          }));
          this.customerFound = true;
        } else {
          this.customerDetails = [];
          this.customerFound = false;
        }
        console.log(
          "customer details data is## " + JSON.stringify(this.customerDetails)
        );

        this.isLoading = false;
      })
      .catch((error) => {
        console.error("Error fetching customer results", error);
        this.customerDetails = [];
        this.customerFound = false;
        this.isLoading = false;
      });
  }

  // Handle row click for selection
  handleRowClick(event) {
    this.selectedCustomerId = event.currentTarget.dataset.id;
  }

  get tableStatus() {

    return this.search.trim() !== '' && !this.customerFound;

  }

  // Handle radio button change
  handleRadioChange(event) {
    const selectedId = event.target.dataset.id;
    this.selectedCustomerId = selectedId;

    // Find the customer details based on the selected Id
    const selectedCustomer = this.customerDetails.find(
      (customer) => customer.Id === selectedId
    );

    if (selectedCustomer) {
      // Populate the detail fields with the selected customer's data
      this.lastName = selectedCustomer.LastName || "";
      this.middleInitial = selectedCustomer.MiddleName || "";
      this.firstName = selectedCustomer.FirstName || "";
      this.organizationName = selectedCustomer.Organization__c || "";
      this.emailAddress = selectedCustomer.Email || "";
      this.phoneNumber =  selectedCustomer.Phone ? this.formatPhoneNumber(selectedCustomer.Phone) : "";
      this.accountBalance = selectedCustomer.Customer_Account_Balance__c
        ? "$" + selectedCustomer.Customer_Account_Balance__c.toFixed(2)
        : "";
        this.accountBalance =  selectedCustomer.Customer_Account_Balance__c
        ? ( selectedCustomer.Customer_Account_Balance__c < 0
            ? "-$" + Math.abs( selectedCustomer.Customer_Account_Balance__c).toFixed(2)
            : "$" +  selectedCustomer.Customer_Account_Balance__c.toFixed(2))
        : null;



      this.location = selectedCustomer.MailingStreet || "";
      this.address2 = selectedCustomer.MailingAddress2__c || "";
      this.city = selectedCustomer.MailingCity || "";
      this.state = selectedCustomer.MailingState || "";
      this.zipCode = selectedCustomer.MailingPostalCode || "";
      this.country = selectedCustomer.MailingCountry || "";
      this.isDelinquite = selectedCustomer.Deliquent__c;
    }
  }

  handleDismiss() {
    this.visible = false;
  }

  get isvisible() {
    if (this.visible && this.isDelinquite) {
      return true;
    }
    return false;
  }

  // Method to handle the search action
  handleSearchCustomer() {
    this.fetchCustomerResults();
  }

  handleKeyPress(event) {
    // Key code references
    const key = event.key;

    // Allow only numbers (0-9), spaces, backspace, arrow keys, delete, and tab
    const validKeys = ["Backspace", "ArrowLeft", "ArrowRight", "Delete", "Tab"];
    const isNumber = /^\d$/.test(key); // Check if the pressed key is a number

    // Block any key that is not a number or space, or one of the valid keys
    if (!isNumber && key !== " " && !validKeys.includes(key)) {
      event.preventDefault();
    }
  }

  formatPhoneNumber(phoneNumberString) {
    let cleaned = phoneNumberString.replace(/\D/g, "");

    cleaned = cleaned.substring(0, 10);

    if (cleaned.length >= 6) {
      return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}`;
    } else if (cleaned.length >= 3) {
      return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3)}`;
    } else if (cleaned.length > 0) {
      return `(${cleaned}`;
    }
    return "";
  }

  addDollarPrefix(value) {
    // Ensure value is a string and valid
    if (value === undefined || value === null) {
      return "$"; // Default to '$' for empty values
    }

    // Convert value to string and trim leading/trailing spaces
    value = String(value).trim();

    // Check if the first character is '$'
    if (value.charAt(0) !== "$") {
      value = `$${value}`; // Append '$' if not present
    }

    return value;
  }

  handleInputChange(event) {
    const field = event.target.name;
    let value = event.target.value;

    if (this.mode === "edit_refund" || this.mode === "addRefund") {
      console.log(
        " inside transaction amount is " + this.totalTransactionFeeAmount
      );
      console.log("total refund amount is "+this.totalTransactionFeeAmountForRefund);

      console.log("field is " + field);
      console.log("valus is " + value);
      value = value.replace(/^\$/, "");

      // Access the nested object directly
      let refund = { ...this.refundHistoryForEditRefund[0] };

      // Update the specific field dynamically
      switch (field) {
        case "refundReason":
          refund.refundReason = value;
          break;
        case "refundAmount":
          const refundInput = this.template.querySelector(
            'lightning-input[data-id="refund-amount-input"]'
          );
          if (refundInput) {
            refundInput.setCustomValidity(""); // Clear the custom error message
            refundInput.reportValidity(); // Update the validity UI
          }
          refund.refundAmount = value;
          break;
        case "voucherId":
          refund.voucherId = value;
          break;
        case "refundDate":
          refund.date = value;
          break;
        case "refundMethod":
          refund.paymentAmount = value;
          break;
      }

      // Assign the updated object back
      this.refundHistoryForEditRefund[0] = refund;
      console.log(
        "refund history for edit refund is " +
        JSON.stringify(this.refundHistoryForEditRefund)
      );

    }

    if (event.target.type === "checkbox") {
      this[field] = event.target.checked; // Use `checked` for checkboxes
    } else if (field === "phoneNumber") {
      this[field] = this.formatPhoneNumber(value); // Format the phone number
    } //else if (field === "refundAmount") {
    //   value = this.addDollarPrefix(value);
    //   this[field] = value;
    // }
    else {
      this[field] = event.target.value; // Use `value` for other input types
    }

    if (field === "paymentType") {
      this.paymentTypeSet();
    }

    // Format phone number if the field is 'phone'
  }

  handleAddressChange(event) {
    this.location = event.detail.street ? event.detail.street : "";
    this.city = event.detail.city;
    this.address2 = event.detail.subpremise;
    this.state = event.detail.province;
    this.zipCode = event.detail.postalCode;
    this.country = event.detail.country;
  }

  fetchActivityData() {
    return getActivityData()
      .then((result) => {
        this.fullActivityData = result || [];
        this.setActivityOptions();
      })
      .catch((error) => {
        console.error("Error fetching activity data:", error);
      });
  }

  setActivityOptions() {
    const uniqueActivities = [
      ...new Set(this.fullActivityData.map((item) => item.activity))
    ];
    this.activityOptions = uniqueActivities.map((activity) => ({
      label: activity,
      value: activity
    }));
  }

  generateDependentOptions(selectedActivity) {
    const filteredData = this.fullActivityData.find(
      (item) => item.activity === selectedActivity
    );
    if (filteredData) {
      this.subActivityOptions = this.createOptionsFromCommaString(
        filteredData.subActivity
      );
      this.programCodeOptions = this.createOptionsFromCommaString(
        filteredData.programCode
      );
    } else {
      this.subActivityOptions = [];
      this.programCodeOptions = [];
    }
  }

  createOptionsFromCommaString(commaString) {
    return (commaString || "")
      .split(",")
      .map((item) => item.trim())
      .filter(Boolean)
      .map((item) => ({ label: item, value: item }));
  }

  handleActivityChange(event) {
    const index = event.target.dataset.index; // Index of the current row
    const selectedActivity = event.target.value; // Selected activity value

    if (this.isEditTransaction) {
      // Update all activity fields in transactionList to the selected activity
      this.transactionList = this.transactionList.map((transaction) => ({
        ...transaction,
        activity: selectedActivity,
        activityCode: "", // Reset activityCode
        programCode: "" // Reset programCode
      }));

      // Reflect the same change in multipleTransactionList
      this.multipleTransactionList = this.multipleTransactionList.map(
        (transaction) => ({
          ...transaction,
          activity: selectedActivity,
          activityCode: "", // Reset activityCode
          programCode: "" // Reset programCode
        })
      );

      console.log(
        "[DEBUG] Edited transactionList and multipleTransactionList with unified activity"
      );
    } else {
      if (this.mode != "edit") {
        // Update the default activity
        this.defaultActivity = selectedActivity;
        console.log("defaultActivity is " + this.defaultActivity);
      } else {
        // Update the updated activity
        this.updatedActivity = selectedActivity;
        console.log("UpdatedActivity is " + this.updatedActivity);
      }

      // Update all rows in `transactionList` with the same activity
      this.transactionList = this.transactionList.map(
        (transaction, rowIndex) => ({
          ...transaction,
          activity: selectedActivity,
          activityCode: rowIndex === index ? "" : transaction.activityCode, // Reset activityCode if it's the changed row
          programCode: rowIndex === index ? "" : transaction.programCode, // Reset programCode if it's the changed row
          paymentAmount: rowIndex === index ? "" : null // Reset paymentAmount if it's the changed row
        })
      );
    }

    // Generate dependent options based on the newly selected activity
    this.generateDependentOptions(selectedActivity);

    console.log(
      "[DEBUG] Updated transactionList:",
      JSON.stringify(this.transactionList)
    );
  }

  // Handle Sub-Activity change
  handleSubActivityChange(event) {
    const index = event.target.dataset.index;
    const value = event.target.value;

    if (index !== undefined) {
      this.transactionList[index].activityCode = value;
      this.transactionList = [...this.transactionList];
    }
  }

  // Handle Program Code change
  handleProgramCodeChange(event) {
    const index = event.target.dataset.index;
    const value = event.target.value;

    if (index !== undefined) {
      this.transactionList[index].programCode = value;
      this.transactionList = [...this.transactionList];
    }
  }

  handleTransactionAmountOnfocusIn(event) {
    const field = event.target.name;
    let value = event.target.value;

    switch (field) {
      case "feeAmount":
        this.totalOfAllFeeItemForEditModeOnly -= Number(value.slice(1));
        break;
    }
  }
  handleTransactionAmountOnfocusOut(event) {
    const field = event.target.name;
    let value = event.target.value;

    switch (field) {
      case "feeAmount":
        this.totalOfAllFeeItemForEditModeOnly += Number(value.slice(1));
        if (
          this.totalOfAllFeeItemForEditModeOnly > this.totalTransactionFeeAmount
        ) {
          this.refundAmountExceeded = true;
          this.showToast(
            "Error",
            "Work Order Transaction Fee Amount exceeds the allowable limit.",
            "error"
          );
        } else {
          this.refundAmountExceeded = false;
        }
        break;
    }
  }


  handleTransactionFieldChange(event) {
    const index = event.target.dataset.index;
    const field = event.target.name;
    let value =
      event.target.type === "checkbox"
        ? event.target.checked
        : event.target.value;

    if(field === "activityCode"){
        console.log('activity code is : '+ value);
        const currentTransaction = this.transactionList[index];
        const activity = currentTransaction.activity;
        const activityCode = value;

        // Call getFee Apex method
      getActivityFee({ activity: activity, subActivity: activityCode })
      .then(result => {
          console.log('Fee received: ', result);
          // Update payment amount in the transaction
          this.transactionList[index].paymentAmount = '$' + result;
          this.transactionList = [...this.transactionList];
      })
      .catch(error => {
          console.error('Error getting fee: ', error);
      });

    }


    if (field === "paymentAmount") {
      value = this.addDollarPrefix(value);
    }

    if (field === "paymentType") {
      // Clear fields based on the previous payment type
      const previousType = this.transactionList[index].paymentType;

      if (value === "Cash") {
        // Clear all fields when switching to Cash
        this.transactionList[index] = {
          ...this.transactionList[index],
          paymentType: "Cash",
          cardType: "",
          cardDigit: "",
          serialNumber: "",
          ckNumber: "",
          isSubCard: false,
          isSubMoneyOrder: false,
          isSubCheck: false
        };
      } else {
        // Clear fields specific to the previous payment type
        if (previousType === "Card" && value !== "Card") {
          this.transactionList[index].cardType = "";
          this.transactionList[index].cardDigit = "";
        }
        if (previousType === "Check" && value !== "Check") {
          this.transactionList[index].ckNumber = "";
        }
        if (previousType === "Money Order" && value !== "Money Order") {
          this.transactionList[index].serialNumber = "";
        }

        // Update flags for conditional rendering
        this.transactionList[index].isSubCard = value === "Card";
        this.transactionList[index].isSubMoneyOrder = value === "Money Order";
        this.transactionList[index].isSubCheck = value === "Check";
      }
    }

    // Update the selected field value
    this.transactionList[index][field] = value;
    this.transactionList = [...this.transactionList];


    console.log('current transaction list', JSON.stringify(this.transactionList));
    console.log('isEditTransaction values are : '+this.isEditTransaction);
    console.log('Field : '+field+ " value is : "+value);




    if (this.isEditTransaction) {
      // Update the corresponding transaction in multipleTransactionList
      const transactionToUpdate = this.transactionList[index];
      this.multipleTransactionList = this.multipleTransactionList.map(
        (transaction) => {
          if (transaction.id === transactionToUpdate.id) {
            const updatedTransaction = { ...transaction, [field]: value };

            if (field === "paymentType" && value === "Cash") {
              // Clear all fields in multipleTransactionList for Cash
              updatedTransaction.cardType = "";
              updatedTransaction.cardDigit = "";
              updatedTransaction.serialNumber = "";
              updatedTransaction.ckNumber = "";
            }
            if (field === "paymentType" && value === "Card") {
              // Clear all fields in multipleTransactionList for Cash
              updatedTransaction.serialNumber = "";
              updatedTransaction.ckNumber = "";
            }
            if (field === "paymentType" && value === "Check") {
              // Clear all fields in multipleTransactionList for Cash
              updatedTransaction.cardType = "";
              updatedTransaction.cardDigit = "";
              updatedTransaction.serialNumber = "";
            }
            if (field === "paymentType" && value === "Money Order") {
              // Clear all fields in multipleTransactionList for Cash
              updatedTransaction.cardType = "";
              updatedTransaction.cardDigit = "";
              updatedTransaction.ckNumber = "";
            }
            if(field === "taxExempt"){
              updatedTransaction.taxExemptDisplay = updatedTransaction.taxExempt ? "Yes" : "No";
            }
            if(field === "reportingOnly"){
              updatedTransaction.reportingOnlyDisplay = updatedTransaction.reportingOnly ? "Yes" : "No";
            }

            return updatedTransaction;
          }
          return transaction;
        }
      );

      console.log(
        "[DEBUG] Updated transactionList and multipleTransactionList"
      );
    }
  }

  get ismultipleTransactionList() {
    if (this.multipleTransactionList.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  // Handle adding a new transaction
  // Add Transaction handler
  handleAddTransaction() {
    // Flag to check if there are missing fields
    let hasErrors = false;

    // Iterate through each transaction and validate fields
    this.transactionList.forEach((transaction, index) => {
      // Get all inputs for this transaction by using the `data-index` attribute
      const inputs = this.template.querySelectorAll(`[data-index="${index}"]`);

      // Validate each input field and flag if invalid
      inputs.forEach((input) => {
        if (typeof input.reportValidity === "function") {
          const isValid = input.reportValidity();
          if (!isValid) {
            hasErrors = true;
          }
        }
      });
    });
    if (this.isEditTransaction) {
      this.workOrderLabel = "Add Transaction";
    }

    // If any field is invalid, show a toast message and stop further processing
    if (hasErrors) {
      this.showToast(
        "Error",
        "Please fill all required fields before adding the transaction.",
        "error"
      );
      return;
    }

    // Check if transactions already exist in multipleTransactionList
    const transactionsToAdd = this.transactionList.filter((transaction) => {
      // Check if the transaction ID is not already in multipleTransactionList
      return !this.multipleTransactionList.some(
        (existingTransaction) => existingTransaction.id === transaction.id
      );
    });

    if (transactionsToAdd.length > 0) {
      const updatedTransactions = transactionsToAdd.map((transaction) => ({
        ...transaction,
        taxExemptDisplay: transaction.taxExempt ? "Yes" : "No",
        reportingOnlyDisplay: transaction.reportingOnly ? "Yes" : "No"
      }));

      this.multipleTransactionList = [
        ...this.multipleTransactionList,
        ...updatedTransactions
      ];
    } else {
      this.showToast("Success", "Transaction updated.", "Success");
    }

    // Reset the transactionList with a new transaction template
    this.transactionList = [
      {
        id: this.generateUniqueId(),
        activity: this.defaultActivity,
        activityCode: "",
        programCode: "",
        paymentCollection: "",
        paymentType: "",
        cardType: "",
        cardDigit: "",
        serialNumber: "",
        ckNumber: "",
        paymentAmount: "",
        taxExempt: false,
        reportingOnly: false,
        isRemovable: false, // Mark it as removable
        isFirst: true // Editable as it's the first transaction
      }
    ];

    console.log(
      "Updated multipleTransactionList:",
      this.multipleTransactionList
    );
    console.log("Reset transactionList:", this.transactionList);
  }

  handleEditTransaction(event) {
    // Get the transaction ID from the clicked icon's dataset
    const transactionId = event.target.dataset.id;

    // Find the transaction to edit in the multipleTransactionList
    const transactionToEdit = this.multipleTransactionList.find(
      (transaction) => transaction.id == transactionId
    );

    if (transactionToEdit) {
      // Set the edit mode flag
      this.isEditTransaction = true;
      this.workOrderLabel = "Save Transaction";

      // Load the transaction into transactionList for editing
      this.transactionList = [
        {
          ...transactionToEdit,
          isFirst: true, // Make it editable
          isRemovable: false // Prevent removal while editing
        }
      ];

      console.log("[DEBUG] Editing Transaction:", transactionToEdit);
    }
    this.generateDependentOptions(this.defaultActivity);
  }

  handleDeleteTransaction(event) {
    // Get the transaction ID from the clicked icon's dataset
    const transactionId = event.target.dataset.id;

    // Filter out the transaction from the list
    const updatedList = this.multipleTransactionList.filter(
      (transaction) => transaction.id != transactionId
    );

    // Reassign the filtered list to the reactive property
    this.multipleTransactionList = [...updatedList];

    console.log("Deleted transaction ID:", transactionId);
    console.log(
      "Updated multipleTransactionList:",
      JSON.stringify(this.multipleTransactionList)
    );
    // Check if the `multipleTransactionList` is empty
    if (this.multipleTransactionList.length === 0) {
      // Make the single transaction in `transactionList` editable
      if (this.transactionList.length > 0) {
        this.transactionList = this.transactionList.map((transaction) => ({
          ...transaction,
          isFirst: false, // Mark as the first transaction
          isRemovable: false // Prevent removal since it's the only editable transaction
        }));
      }
    }
  }

  // Generate a unique ID for each new transaction
  generateUniqueId() {
    return "id-" + Math.random().toString(36).substring(2, 15);
  }

  handleRemoveTransaction(event) {
    const index = event.target.dataset.index;

    if (index !== undefined) {
      // const removedTransaction = this.transactionList[index]; // Get the transaction being removed

      // // Parse the fee amount to remove the `$` and convert to a number
      // const removedAmount = parseFloat(
      //   removedTransaction.feeAmount?.replace("$", "") || "0"
      // );

      // Remove the transaction from transactionList
      this.transactionList.splice(index, 1);
      this.transactionList = [...this.transactionList];
    }
  }

  // Add and remove documents
  handleAddDocument() {
    this.documentsList = [
      ...this.documentsList,
      { id: Date.now(), docType: "", docFile: null, isRemovable: false }
    ];
  }
  // Remove a document row from documentsList based on the index
  handleRemoveDocument(event) {
    const index = event.target.dataset.index;
    if (index !== undefined) {
      const document = this.documentsList[parseInt(index, 10)];
      // Check if the document has a documentId and add it to deletedFiles
      if (
        document.docFile &&
        document.docFile.documentId &&
        this.mode === "edit"
      ) {
        this.deletedFiles.push(document.docFile.documentId);
      }
      // Remove the document row from documentsList
      this.documentsList.splice(index, 1);
    }
  }

  // Handle input changes for dynamically added document rows
  handleDocumentFieldChange(event) {
    const fieldName = event.target.name;
    const index = event.target.dataset.index;


    if (index !== undefined) {
       // Clear any existing error for this specific field
        const docTypeInput = this.template.querySelector(
          `lightning-combobox[data-row-index="${index}"]`
      );
      if (docTypeInput) {
          docTypeInput.setCustomValidity('');
          docTypeInput.reportValidity();
      }

      this.documentsList = this.documentsList.map((doc, i) =>
        i === parseInt(index, 10)
          ? { ...doc, [fieldName]: event.target.value }
          : doc
      );
    }
    console.log('document field is '+ JSON.stringify(this.documentsList));

  }

  handleDocumentFileUpload(event) {
    const index = event.target.dataset.index;
    const file = event.target.files[0];
    console.log("handleDocumentFileUpload:",   file,  "index:", index);

      // Check if document type is selected
      if (!this.documentsList[index].docType) {
        // Clear the file input
        event.target.value = '';

        const docTypeInput = this.template.querySelector(
          `lightning-combobox[data-row-index="${index}"]`
      );

        if (docTypeInput) {
            docTypeInput.setCustomValidity('Please select a document type before uploading a file');
            docTypeInput.reportValidity();
        }

        // Show toast message
        this.showToast(
            'Error',
            'Please select a document type before uploading a file',
            'error'
        );

        return;
    }

    if (file && index !== undefined) {
      const reader = new FileReader();
      const fileExtension = file.name.substring(file.name.lastIndexOf(".")); // Extract file extension (e.g., .pdf)

      reader.onload = () => {
        const docType = this.documentsList[index].docType || "Default"; // Get the docType for this row or use a default fallback
        const newFileName = `${docType}${fileExtension}`; // Combine docType with the extension

        this.documentsList = this.documentsList.map((doc, i) =>
          i === parseInt(index, 10)
            ? {
                ...doc,
                docFile: {
                  fileName: newFileName,
                  base64Data: reader.result.split(",")[1], // Extract base64 data
                  contentType: file.type
                }
              }
            : doc
        );
      };

      reader.readAsDataURL(file);
      console.log("document list is " + JSON.stringify(this.documentsList));

    }

  }

  handleRemoveFile(event) {
    const index = event.target.dataset.index;
    if (index !== undefined) {
      const document = this.documentsList[parseInt(index, 10)];

      // Check if the document has a docFile and documentId
      if (
        document &&
        document.docFile &&
        document.docFile.documentId &&
        this.mode === "edit"
      ) {
        this.deletedFiles.push(document.docFile.documentId); // Store the documentId in deletedFiles
      }

      // Update the documentsList to clear the docFile at the specified index
      this.documentsList = this.documentsList.map((doc, i) =>
        i === parseInt(index, 10) ? { ...doc, docFile: null } : doc
      );
    }
  }

  // Handle refund method change
  handleRefundMethod(event) {
    this.refundMethod = event.target.value;
    console.log(this.refundMethod);
    let refund = { ...this.refundHistoryForEditRefund[0] };
    refund.refundMethod = this.refundMethod;

    if (this.refundMethod === "Card") {
      this.showRefundCard = true;
      this.refundCardOptions = this.multipleTransactionList
        .filter((payment) => payment.paymentType === "Card") // Only include card payments
        .map((payment) => ({
          label: `${payment.cardType} ending in ${payment.cardDigit}`, // Customize label
          value: payment.id // Use payment ID as value
        }));
    } else {
      this.showRefundCard = false; // Hide dropdown if refund method is not "Card"
      this.selectedRefundCard = ""; // Clear selection
    }
    this.refundHistoryForEditRefund[0] = refund;

  }

  // Handle refund card selection
  handleRefundCardChange(event) {
    this.selectedRefundCard = event.target.value; // Capture selected card value
    console.log('card change '+this.selectedRefundCard);
    let refund = { ...this.refundHistoryForEditRefund[0] };

    refund.selectedRefundCard = this.selectedRefundCard;
    this.refundHistoryForEditRefund[0] = refund;
    console.log('runfund history '+JSON.stringify(this.refundHistoryForEditRefund));

  }

//   handleRefundEditMethod(event) {
//     const selectedMethod = event.detail.value;
//     const currentIndex = event.target.closest('[data-id]').getAttribute('data-id');

//     console.log('selectedMethod is ' + selectedMethod + ' currentIndex is ' + currentIndex);


//     // Update the refund method in the refundHistory
//     this.editRefundList = this.editRefundList.map(row => {
//         if (row.id === currentIndex) {
//             // If the method is not Card, set originalId to null
//             return {
//                 ...row,
//                 refundPaymentMethod: selectedMethod,
//                 showRefundCard: selectedMethod === 'Card' ? true : false,
//                 voucherId: selectedMethod === 'Card' ? "N/A" : null
//             };
//         }
//         return row;
//     });
//     console.log('editRefundList :'+ JSON.stringify(this.editRefundList));
// }

handleRefundEditInputChange(event) {
  const { name, value } = event.target;
  const currentIndex = event.target.closest('[data-id]').getAttribute('data-id');

  console.log('currentIndex is ' + currentIndex + ' name is ' + name + ' value is ' + value);

  // Update the specific field in refundHistory
  this.editRefundList = this.editRefundList.map(row => {
      if (row.id === currentIndex) {
          return {
            ...row,
            [name]: value
          };
      }
      return row;
  });
  console.log('editRefundList :'+ JSON.stringify(this.editRefundList));

}

// handleRefundEditCardChange(event) {
//   const selectedCard = event.detail.value;
//   const currentIndex = event.target.closest('[data-id]').getAttribute('data-id');

//   // Update the originalId in refundHistory
//   this.editRefundList = this.editRefundList.map(row => {
//       if (row.id === currentIndex) {
//           return { ...row,
//             originalId: selectedCard
//           };
//       }
//       return row;
//   });
//   console.log('editRefundList :'+ JSON.stringify(this.editRefundList));

// }

  async handleAdd() {
    const isValid = this.validateInputs(); // Validate form before proceeding
    if (!isValid) {
        // this.showToast(
        //     "Error",
        //     "Please correct the validation errors before proceeding.",
        //     "error"
        // );
      return;
    }

     // Prepare work order data
  const workOrderData = {
      defaultActivity: this.defaultActivity
        ? String(this.defaultActivity)
        : null,
      updatedActivity: this.updatedActivity
        ? String(this.updatedActivity)
        : null,
      batchId: this.batchId ? String(this.batchId) : null,
      workOrderDate: this.workOrderDate,
      transactionType: this.transactionType,
      recordId: this.recordId ? String(this.recordId) : null,
      batch: this.batch ? String(this.batch) : null,
      workOrderStatus: this.workOrderStatus
        ? String(this.workOrderStatus)
        : null,
      comment: this.comment ? String(this.comment) : null,
      batchDefaultId: this.batchDefaultId ? String(this.batchDefaultId) : null,
      selectedCustomerId: this.selectedCustomerId
        ? String(this.selectedCustomerId)
        : null,
      isSinglePayment: this.isSinglePayment,
      customerDetails: {
        lastName: this.lastName ? String(this.lastName) : null,
        middleInitial: this.middleInitial ? String(this.middleInitial) : null,
        firstName: this.firstName ? String(this.firstName) : null,
        organizationName: this.organizationName
          ? String(this.organizationName)
          : null,
        emailAddress: this.emailAddress ? String(this.emailAddress) : null,
        phoneNumber: this.phoneNumber ? String(this.phoneNumber) : null,
        accountBalance: this.accountBalance
          ? this.accountBalance.replace("$", "")
          : null,
        address: {
          street: this.location ? String(this.location) : null,
          address2: this.address2 ? String(this.address2) : null,
          city: this.city ? String(this.city) : null,
          state: this.state ? String(this.state) : null,
          zipCode: this.zipCode ? String(this.zipCode) : null,
          country: this.country ? String(this.country) : null
        }
      },

      // Use multipleTransactionList if it's not empty; otherwise, use transactionList
      transactions: (this.multipleTransactionList.length > 0
        ? this.multipleTransactionList
        : this.transactionList
      ).map((transaction) => ({
        Id: transaction.id ? String(transaction.id) : null,
        tnxId: transaction.tnxId ? String(transaction.tnxId) : null,
        activity: transaction.activity ? String(transaction.activity) : null,
        activityCode: transaction.activityCode
          ? String(transaction.activityCode)
          : null,
        programCode: transaction.programCode
          ? String(transaction.programCode)
          : null,
        batchId: transaction.batchId ? String(transaction.batchId) : null,
        feeAmount: transaction.feeAmount
          ? transaction.feeAmount.replace("$", "")
          : null,
        taxExempt: transaction.taxExempt || false,
        reportingOnly: transaction.reportingOnly || false,
        transactionDate: this.workOrderDate ? String(this.workOrderDate) : null,
        paymentCollection: transaction.paymentCollection
          ? String(transaction.paymentCollection)
          : null,
        paymentType: transaction.paymentType
          ? String(transaction.paymentType)
          : null,
        cardType: transaction.cardType ? String(transaction.cardType) : null,
        cardDigit: transaction.cardDigit ? String(transaction.cardDigit) : null,
        serialNumber: transaction.serialNumber
          ? String(transaction.serialNumber)
          : null,
        ckNumber: transaction.ckNumber ? String(transaction.ckNumber) : null,
        paymentAmount: transaction.paymentAmount
          ? transaction.paymentAmount.replace("$", "")
          : null
      })),

      refundTransactions: this.refundHistoryForEditRefund.map(
        (transaction) => ({
          Id: transaction.id ? String(transaction.id) : Date.now(),
          wordOrderId : this.recordId ? String(this.recordId) : null,
          transactionType: this.transactionType ? String(this.transactionType) : null,
          batchId: this.batchId ? String(this.batchId) : null,
          refundAmount: transaction.refundAmount
            ? String(transaction.refundAmount)
            : null,
          refundDate: transaction.date ? String(transaction.date) : null,
          voucherId: transaction.voucherId
            ? String(transaction.voucherId)
            : null,
          refundMethod: transaction.refundMethod
            ? String(transaction.refundMethod)
            : null,
          refundReason: transaction.refundReason
            ? String(transaction.refundReason)
            : null,
          selectedRefundCard: transaction.selectedRefundCard
            ? String(transaction.selectedRefundCard)
            : null

        })
      ),

      documents: this.documentsList.map((document) => ({
        docType: document.docType || null,
        docFile: document.docFile
          ? {
              fileName: document.docFile.fileName || null,
              base64Data: document.docFile.base64Data || null,
              contentType: document.docFile.contentType || null
            }
          : null
      })),
      deletedFiles: this.deletedFiles || []
    };
   // console.log("Work Order Data:", workOrderData);

    const serializedData = JSON.stringify(workOrderData);
   // console.log("serialized data is " + serializedData);

    if (this.mode === "add") {

      // Open the modal with work order data
      const result = await workOrderConfirmationModal.open({
        size: "small",
        description: "Accessible description of modal's purpose",
        workOrderData: serializedData
      });

      console.log('result value is '+ result);


      if (result) {
        this.goBackModal();
      }
    }else if (this.mode === "addRefund"){
      this.footerOprions = true;
      const refundTrxnData = workOrderData.refundTransactions;
      const serializedRefundTrxnData = JSON.stringify(refundTrxnData);

      console.log("refundTrxnData: ", serializedRefundTrxnData);
      createRefundTransaction({ refundTransactionJSON: serializedRefundTrxnData })
        .then((result) => {
          console.log("Updated Result : ", result);
          this.showToast("Success", "Refund Transaction Processed", "success");
          if(result){
            this.mode = "view_refund";
            this.loadTheReord();
            this.footerOprions = false;

          }
          //this.loadWorkOrderData();
        })
        .catch((error) => {
          console.log("Error in Updation : ", error);
          console.log("Full Error Object: ", JSON.stringify(error, null, 2));

          let errorMessage = "An error occurred while processing the refund";

          // Try different ways to get the error message
          if (error.body && error.body.message) {
              errorMessage = error.body.message;
          } else if (error.detail && error.detail.message) {
              errorMessage = error.detail.message;
          } else if (error.message) {
              errorMessage = error.message;
          } else if (typeof error === 'string') {
              errorMessage = error;
          }

          // Remove any "Script-thrown exception" prefix if present
          errorMessage = errorMessage.replace("Script-thrown exception: ", "");

          console.log('Final error message:', errorMessage);

          // Set the input field as invalid
          const refundInput = this.template.querySelector(
            'lightning-input[data-id="refund-amount-input"]'
          );
          if (refundInput) {
            refundInput.setCustomValidity(
              "Refund amount exceeds the allowable limit."
            );
            refundInput.reportValidity();
          }

            // Show the detailed error message in the toast
          this.showToast("Error", errorMessage, "error");
          this.footerOprions = false;

        });

    } else if (this.mode === "edit_refund") {
      this.footerOprions = true;
      console.log('editTable data is'+ this.editRefundList);
      const serializedRefundData = JSON.stringify(this.editRefundList);
      console.log('serialized refund data is'+ serializedRefundData);

      updateRefundTransaction({ refundTransactionJSON: serializedRefundData })
      .then((result) => {
        console.log("Updated Result : ", result);
        this.showToast("Success", "Refund Updated Processed", "success");
        if(result){
          this.mode = "view_refund";
          this.loadTheReord();
          this.footerOprions = false;

        }
        //this.loadWorkOrderData();
      })
      .catch((error) => {
        console.log("Error in Updation : ", error);
        this.showToast("Error", " Error into Refund Updated ", "error");
        this.footerOprions = false;

      });
    } else {
      console.log("Update Work Order");
      this.footerOprions = true;
      console.log('customer data is '+JSON.stringify(workOrderData.customerDetails));

        updateWorkOrder({ workOrderDataJson: serializedData })
          .then((result) => {
            // Extract required data from the result
            // const sequenceNumber = result.sequenceNumber;
            // const workOrderId = result.id;

            // Show a success toast message
            this.showToast("Success", "Work Order Updated", "success");

            if(result){
              this.mode = "view";
              this.loadTheReord();
              this.footerOprions = false;

            }

          })
          .catch((error) => {
            // Handle errors from the Apex method
            console.error("Error creating work order:", error);

            // Extract the error message
            const errorMessage =
              error.body?.message || "An unknown error occurred.";

            // Show an error toast message
            this.footerOprions = false;

            this.showToast("Error", errorMessage, "error");
          });

    }
  }

  // Validate input fields
  validateInputs() {
    let allValid = true;
    let missingFields = [];

    // Get all input components
    const inputComponents = this.template.querySelectorAll(
      "lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group, lightning-input-address "
    );

    inputComponents.forEach((inputCmp) => {
      // Check each input's validity

      const excludedFields = [
        "activity",
        "activityCode",
        "programCode",
        "paymentCollection",
        "paymentType",
        "paymentAmount"
      ];
      if (excludedFields.includes(inputCmp.name)) {
        return; // Skip validation for excluded fields
      }
    //   if (inputCmp.name === 'refundAmount') {
    //     if (this.refundAmountExceeded) {
    //         inputCmp.setCustomValidity("Refund amount exceeds the allowable limit.");
    //         allValid = false;
    //         missingFields.push("Refund Amount");
    //     } else {
    //         inputCmp.setCustomValidity("");
    //     }
    // }

      inputCmp.reportValidity();

      if (!inputCmp.checkValidity()) {
        allValid = false;
        // Only add to missing fields if not already added
        if (!missingFields.includes(inputCmp.label)) {
            missingFields.push(inputCmp.label);
        }
    }

});

    if (!allValid) {
      const message = `Please fill in the required fields: ${missingFields.join(", ")}`;
      this.showToast("Error", message, "error");
    }

    return allValid;
  }



  // Show Toast Message Utility Method
  showToast(title, message, variant) {
    const toast = this.template.querySelector("c-toast-message-state-modal");
    if (toast) {
      toast.showToast({
        title: title,
        message: message,
        variant: variant
      });
    }
  }

  // Method to handle edit button click to toggle edit mode
  handleEditClick() {
    if (this.mode === "view") {
      this.mode = "edit";
      this.loadWorkOrderData();
      this.edit_refund = false;
      this.view_refund = false;
    } else if (this.mode === "view_refund") {
      this.mode = "edit_refund";
      if (this.mode === "edit_refund") {
        this.refundHistoryForEditRefund = [
          {
            ...this.refundHistory[this.selectedFeeItemIndexFor_edit_refund_mode]
          }
        ];
      }
      this.view_refund = false;
      this.edit_refund = true;
    } else {
      this.mode = "edit";
    }
  }

  async sendEmailModal() {
    const result = await finsysSendEmailModal.open({
      size: "small",
      description: "Accessible description of modal's purpose",
      recordId: this.recordId
    });
    console.log("Email modal closed with result:", result);
  }

  handlePrintPaymentReceipt() {
    try {
      const pdfgenerator = this.template.querySelector(
        "c-finsys-pdf-generator"
      );
      if (pdfgenerator) {
        const blob = pdfgenerator.generatePaymentInvoice(this.recordId, "");
        console.log(blob);

      } else {
        console.error("PDF generator component not found.");
      }
    } catch (error) {
      console.error("Error generating payment document:", error);
    }
  }

  async refundRequest() {
    this[NavigationMixin.Navigate]({
      type: "standard__component",
      attributes: {
        componentName: "c__finsysWorkOrderModal" // Replace with your target component's name
      },
      state: {
        c__mode: "addRefund",
        c__recordID: this.recordId
        //c__activityId: ''
      }
    });
  }
}
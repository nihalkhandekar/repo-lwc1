import { api, LightningElement, wire } from 'lwc';
import ApostilleReceipt from 'c/sap_ApostilleReceipt';
import ApostillePrintSubmissionDocumentV2 from 'c/sap_ApostillePrintSubmissionDocumentV2';
import getApplicationDetails from '@salesforce/apex/SAP_ApostilleIADetails.getApplicationDetails';
import { loadScript } from 'lightning/platformResourceLoader';
import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS';
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';
import sendEmailWithAttachment from '@salesforce/apex/SAP_IndividualApplicationTriggerHelper.sendEmailWithAttachment';

const LANGUAGE_TEXT = 'Language';

export default class sap_ApostilleRequestSuccess extends LightningElement {
  @api recordId;
  @api firstName;
  @api lastName;
  @api workOrderNumber;
  @api workOrderNumb;
  @api price;
  @api authCode;
  @api PaymentDate;
  @api paymentMethod;
  @api CardLastDigit;
  @api CreditCardName;
  @api emailToSend;

  // Labels storage
  labels = {};
  JsonLanguageData;

  @wire(MessageContext)
  messageContext;

  // Fetch firstName and lastName based on recordId
  connectedCallback() {
    loadScript(this, labelsResource)
      .then(() => {
        this.JsonLanguageData = window.myobj;
        getCacheValue({ key: LANGUAGE_TEXT })
          .then((result) => {
            this.handleLanguageChange(result);
          })
          .catch((error) => console.error(error));
      })
      .catch((error) => console.error('Error loading script:', error));

    // Subscribe to language updates
    subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
      this.handleLanguageChange(message);
    });

    // Reset email sent flag on load
    this.emailSent = false;

    this.fetchRequestorDetails();

    // Scroll to top on component load
    window.scrollTo(0, 0);
  }

  // Convert Blob to Base64 format
  async convertBlobToBase64(blob) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onloadend = () => resolve(reader.result.split(',')[1]); // Extract Base64
      reader.onerror = reject;
      reader.readAsDataURL(blob);
    });
  }

  async getPDFForEmail() {
    // Skip if email is already sent
    if (this.emailSent) {
      return;
    }

    try {
      await new Promise(resolve => setTimeout(resolve, 30000));

      const result = await getApplicationDetails({ recordId: this.recordId });
      if (result) {
        this.paymentMethod = result.MethodofPayment;
        // Update other payment-related properties
        this.authCode = result.AuthenticationCode;
        this.PaymentDate = result.DateofPayment;
        this.CreditCardName = result.CreditCardName;
        this.CardLastDigit = result.CardLastDigit;
        this.price = result.TotalFees;
      }
      const pdfgenerator = this.template.querySelector('[data-id="pdfGenerator"]');
      if (pdfgenerator) {
        const blob = await pdfgenerator.pdfForApostilleSuccess('email');
        if (blob) {
          // Initialize attachments array if not set
          if (!this.attachments) {
            this.attachments = [];
          }

          const attachmentName = `Apostille_Document${this.workOrderNumber}.pdf`;
          const existingAttachment = this.attachments.find((a) => a.name === attachmentName);

          // Add attachment only if not already present
          if (!existingAttachment) {
            const pdfUrl = URL.createObjectURL(blob);
            const base64Content = await this.convertBlobToBase64(blob);

            this.attachments.push({
              name: attachmentName,
              url: pdfUrl,
              content: base64Content,
              mimeType: 'application/pdf'
            });
          }

          // Send email only if not already sent
          if (!this.emailSent) {
            await this.sendConfirmationEmail();
          }
        } else {
          console.error('Failed to generate PDF blob.');
        }
      } else {
        console.error('PDF generator component not found.');
      }
    } catch (error) {
      console.error('Error generating payment document:', error);
    }
  }

  async sendConfirmationEmail() {
    // Skip if email is already sent
    if (this.emailSent) {
      return;
    }

    try {
      const emailData = {
        firstName: this.firstName,
        lastName: this.lastName,
        workOrderNumber: this.workOrderNumber,
        authCode: this.authCode,
        PaymentDate: this.PaymentDate,
        paymentMethod: this.paymentMethod,
        CreditCardName: this.CreditCardName,
        CardLastDigit: this.CardLastDigit,
        price: this.price,
        emailToSend: this.emailToSend,
        Status: 'Submitted',
        attachments:
          this.attachments ?
            this.attachments.map((attachment) => ({
              name: attachment.name,
              content: attachment.content,
              mimeType: attachment.mimeType
            }))
          : []
      };

      await sendEmailWithAttachment({ emailData: JSON.stringify(emailData) });

      // Mark email as sent
      this.emailSent = true;
    } catch (error) {
      console.error('Error sending email:', error);
    }
  }

  // Show receipt button only if payment method is not "Check"
  get shouldShowReceiptButton() {
    return this.paymentMethod !== 'Check';
  }

  async fetchRequestorDetails() {
    try {
      const result = await getApplicationDetails({ recordId: this.recordId });
      if (result) {
        this.firstName = result.firstName;
        this.lastName = result.lastName;
        this.workOrderNumber = result.sequanceNumber;
        this.authCode = result.AuthenticationCode;
        this.PaymentDate = result.DateofPayment;
        this.paymentMethod = result.MethodofPayment;
        this.CreditCardName = result.CreditCardName;
        this.CardLastDigit = result.CardLastDigit;
        this.price = result.TotalFees;
        this.emailToSend = result.emailAddress;

        // Generate PDF and send email if not already sent
        if (!this.emailSent) {
          await this.getPDFForEmail();
        }
      } else {
        console.error('No data returned from getApplicationDetails.');
      }
    } catch (error) {
      console.error('Error fetching requestor details:', error);
    }
  }

  isModalOpen = false;

  async openReceiptModal() {
    this.isModalOpen = true;

    await ApostilleReceipt.open({
      size: 'small',
      description: 'Payment Receipt',
      label: 'Payment Receipt',
      workOrderNumber: this.workOrderNumber,
      authCode: this.authCode,
      PaymentDate: this.PaymentDate,
      paymentMethod: this.paymentMethod,
      CreditCardName: this.CreditCardName,
      CardLastDigit: this.CardLastDigit,
      recordId: this.recordId,
      price: this.price
    });

    this.isModalOpen = false;
  }

  async openPrintModal() {
    this.isModalOpen = true;

    await ApostillePrintSubmissionDocumentV2.open({
      size: 'medium',
      description: 'Print Submission Document',
      label: 'Print Submission Document',
      recordId: this.recordId
    });

    this.isModalOpen = false;
  }

  async handleDownload() {
    try {
      // Fetch application details from Apex
      const result = await getApplicationDetails({ recordId: this.recordId });

      // If data is retrieved, update component properties
      if (result) {
        this.authCode = result.AuthenticationCode;
        this.PaymentDate = result.DateofPayment;
        this.paymentMethod = result.MethodofPayment;
        this.CreditCardName = result.CreditCardName;
        this.CardLastDigit = result.CardLastDigit;
        this.price = result.TotalFees;
        this.emailToSend = result.emailAddress;

        // Call the PDF generator child component
        const childComponent = this.template.querySelector('[data-id="pdfGenerator"]');
        if (childComponent) {
          childComponent.pdfForApostilleSuccess('download');
        } else {
          console.error('PDF generator component not found.');
        }
      } else {
        console.error('No data returned from getApplicationDetails.');
      }
    } catch (error) {
      console.error('Error in handleDownload:', error);
    }
  }

  // Returns CSS class for container based on modal state
  get apostilleContainerClass() {
    return this.isModalOpen ? 'hidden' : '';
  }

  navigateToTrack() {
    // Navigate to tracking page with work order number
    window.location.href = `/eApostille/apostillerequest?workOrderNumber=${encodeURIComponent(this.workOrderNumber)}`;
  }

  // Handles language selection changes
  handleLanguageChange(message) {
    let language;
    if (message.language) {
      language = message.language;
    } else {
      language = message;
    }
    this.labels = JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
  }
}
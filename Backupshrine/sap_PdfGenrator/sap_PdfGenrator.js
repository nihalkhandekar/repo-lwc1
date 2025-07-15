import { LightningElement, api, track } from 'lwc';
import jsPDF from '@salesforce/resourceUrl/sap_pdfGenerator';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import mainData from '@salesforce/apex/SAP_PdfDataFetch.fetchTransactionData';
import documentRequestImage from '@salesforce/resourceUrl/sap_apostilleDocumentRequestedImageForPrintSubmissionDocument';
import mailingImage from '@salesforce/resourceUrl/sap_apostilleDocumentRequestedImageForMailingInformation';
import jsPdfAutotable from '@salesforce/resourceUrl/sap_jsPdfAutotable';
import fetchEnvelopeData from '@salesforce/apex/SAP_PrintDocumentController.fetchEnvelopeData';
import fetchLetterData from '@salesforce/apex/SAP_PrintDocumentController.fetchLetterData';
import getBase64Image from '@salesforce/apex/SAP_ApostilleLetterController.getBase64Image';
import getBatchPDFData from '@salesforce/apex/SAP_BatchPDFController.getBatchData';
import getDocDetails from '@salesforce/apex/SAP_ApostillePrntSubmDocController.getDocDetails';
import sapSOTSAppUrl from '@salesforce/label/c.sap_SOTSAppUrl';

// import APOSTILLE_RESOURCE from '@salesforce/resourceUrl/certificateImage';

export default class PdfGenerator extends LightningElement {
  imageForMailingInformation = mailingImage;
  imageForDocumentRequest = documentRequestImage;
  sapSOTSAppUrl = sapSOTSAppUrl;
  @track Transaction_Id;
  @track Tax_Exempt;
  @track Mailiing_Address_same_as_Residential;
  @track BillingCity;
  @track BillingState;
  @track BillingCountry;
  @track BillingPostalcode;
  @track BillingStreet;
  @track Customer_Type;
  @track Organization_Name;
  @track name;
  @track Customer_ID;
  @track ckNumber;
  @track paymentAmount;
  @track paymentType;
  @api recordId;
  Account1;
  RegulatoryTrxnFee1 = null;
  jsPdfInitialized = false;
  dataLoaded = false;

  //receipt param
  @api workOrderNumb;
  @api authCode;
  @api price;
  @api paymentMethod;
  @api paymentDate;
  @api requestorName;
  @api paidFor;
  @api cardName;
  @api cardLastDigit;

  //New param
  @api workOrderNum;
  @api documentsRequested;
  @api customerName;
  @api totalFee;
  @api expediteFee;

  //letter param
  @api workOrderNumber;
  @api appliedDate;
  @api addressLine;
  @api city;
  @api state;
  @api zipCode;
  @api individualName;
  @api itemDetails;
  @api paymentDetails;

  //fields for print enevelop state seal
  // Fields fetched dynamically from Apex
  @track street;
  @track postalCode;
  @track dateOfSOTSResponse; // Date of SOTS response
  @track requestFor; // Request for field (Re: section)
  @track letterText; // Main body of the letter (Letter Text)
  @track letterType;
  @track reason;
  @track status_record;
  @track lastName;
  @track wetSignature;
  @track signedBy;

  @api wetSign;

  @api batchId; //for finsys print batch pdf

  @api individualApplicationId;
  @api individualApplication;
  @api finalTotal;

  // Method to call Apex method and return a Promise
  fetchData() {
    return mainData({ recordid: this.recordId })
      .then((data) => {
        this.processData(data);
        this.dataLoaded = true;
        console.log('Data successfully fetched');
      })
      .catch((error) => {
        console.error('Error fetching data:', error);
        this.dataLoaded = false;
      });
  }

  processData(data) {
    this.RegulatoryTrxnFee1 = data.RegulatoryTrxnFee || '';
    this.Account1 = data.RegulatoryTrxnFee.Account || '';
    this.Transaction_Id = this.RegulatoryTrxnFee1.Transaction_Id__c || '';
    this.Tax_Exempt = this.RegulatoryTrxnFee1.SAP_Tax_Exempt__c || false;
    this.Mailiing_Address_same_as_Residential = this.RegulatoryTrxnFee1.Mailiing_Address_same_as_Residential__c || false;
    this.BillingCity = this.Account1.BillingAddress?.city || '';
    this.BillingStreet = this.Account1.BillingAddress?.street || '';
    this.BillingState = this.Account1.BillingAddress?.state || '';
    this.BillingPostalcode = this.Account1.BillingAddress?.postalCode || '';
    this.BillingCountry = this.Account1.BillingAddress?.country || '';
    this.Customer_Type = this.Account1.SAP_Customer_Type__c || '';
    this.Customer_ID = this.Account1.Customer_ID__pc || '';
    this.Organization_Name = this.Account1.SAP_Organization_Name__c || '';
    this.ckNumber = data.CK_Number__c || '';
    this.paymentAmount = data.Payment_Amount__c || '';
    this.paymentType = data.Payment_Type__c || '';
    this.name = this.Account1.Name || '';
  }

  renderedCallback() {
    if (this.jsPdfInitialized) {
      return;
    }
    loadScript(this, jsPDF)
      .then(() => {
        console.log('jsPDF library loaded');
        this.jsPdfInitialized = true;
      })
      .catch((error) => {
        console.error('Error loading jsPDF library:', error);
      });
  }

  generatePdf() {
    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }

    if (!this.dataLoaded) {
      console.error('Data not loaded yet');
      return;
    }

    console.log('PDF generator called with values:', this);

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();

    doc.setFontSize(20);
    doc.setFont('helvetica');
    doc.text('INVOICE', 90, 20);

    doc.setFontSize(10);
    doc.setFont('arial');
    doc.text('Name:', 20, 40);
    doc.text('Transaction Id:', 20, 50);
    doc.text('Tax Exempt:', 20, 60);
    doc.text('Mailiing_Address_same_as_Residential:', 20, 70);
    doc.text('Customer Type:', 20, 80);
    doc.text('Billing Address:', 20, 90);
    doc.text('Organization Name:', 20, 120);
    doc.text('CK Number:', 20, 130);
    doc.text('Payment Amount:', 20, 140);
    doc.text('Payment Type:', 20, 150);
    doc.text('Customer ID:', 20, 160);

    doc.setFont('times');
    doc.text(String(this.name) || '', 100, 40);
    doc.text(this.Transaction_Id || '', 100, 50);
    doc.text(String(this.Tax_Exempt) || '', 100, 60);
    doc.text(String(this.Mailiing_Address_same_as_Residential) || '', 100, 70);
    doc.text(this.Customer_Type || '', 100, 80);
    doc.text(this.BillingStreet || '', 100, 90);
    doc.text(this.BillingCity || '', 120, 90);
    doc.text(this.BillingState || '', 100, 95);
    doc.text(this.BillingCountry || '', 120, 95);
    doc.text(this.BillingPostalcode || '', 100, 100);
    doc.text(this.Organization_Name || '', 100, 120);
    doc.text(this.ckNumber || '', 100, 130);
    doc.text(String(this.paymentAmount) || '', 100, 140);
    doc.text(this.paymentType || '', 100, 150);
    doc.text(this.Customer_ID || '', 100, 160);

    try {
      /*Direct Download pdf*/

      /*  doc.save('CustomerInvoice.pdf');
             console.log('PDF generated and saved.');*/

      /*preview pdf*/

      // Generate the PDF blob
      const pdfBlob = doc.output('blob');

      // Create a URL for the PDF blob
      this.pdfUrl = URL.createObjectURL(pdfBlob);

      // Dynamically create an iframe and set its src to the blob URL
      const anchor = document.createElement('a');
      console.log(this.pdfUrl);
      anchor.href = this.pdfUrl;
      anchor.target = '_blank';
      anchor.click();

      // Append the iframe to the component
      //this.template.querySelector('.pdf-container').appendChild(anchor);

      // Optionally, display the iframe for a preview
    } catch (error) {
      console.error('Error generating or previewing PDF:', error);
    }
  }

  @api
  generateData(recordId) {
    console.log('API method called with recordId:', recordId);
    this.recordId = recordId;

    // Fetch data and generate PDF when data is available
    this.fetchData()
      .then(() => {
        if (this.dataLoaded) {
          this.generatePdf();
        } else {
          console.log('Data is not available for PDF generation.');
        }
      })
      .catch((error) => {
        console.error('Error in data fetch process:', error);
      });
  }

  @api
  handleExportResultButtonClickInPdfGenrator(map) {
    console.log('data generated', JSON.stringify(map));
  }

  @api
  async LetterCertificatePdfGenerator(certificateNo) {
    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }

    console.log('Certificate No in child component:', certificateNo);

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.width;
    const pageHeight = doc.internal.pageSize.height;
    const marginLeft = 20;
    const marginRight = 20;
    const marginTop = 10;
    const marginBottom = 20;
    const textWidth = pageWidth - marginLeft - marginRight;

    // Function to add header image on each page, spanning from marginLeft to marginRight
    const addHeaderImage = async () => {
      try {
        const imageData = await getBase64Image({
          imageName: 'certificateImage'
        });
        const imageHeight = (35 / 297) * pageWidth; // Adjust height as needed

        // Set image to start at marginLeft and span textWidth
        doc.addImage(imageData, 'PNG', marginLeft - 8, marginTop, textWidth + 15, imageHeight);
        return marginTop + imageHeight + 5; // Minimal padding after image
      } catch (error) {
        console.error('Error loading image:', error);
        return marginTop;
      }
    };

    // Load header image and set initial Y position
    let yPosition = await addHeaderImage();

    // Helper function to handle pagination
    const checkPageEnd = async (additionalHeight = 0) => {
      if (yPosition + additionalHeight > pageHeight - marginBottom) {
        doc.addPage();
        yPosition = await addHeaderImage();
      }
    };

    // Define fallback values
    const appliedDate = this.appliedDate || 'N/A';
    const workOrderNumber = this.workOrderNumber || 'N/A';
    const individualName = this.individualName || 'N/A';
    const addressLine = this.addressLine || 'N/A';
    const city = this.city || 'N/A';
    const state = this.state || 'N/A';
    const zipCode = this.zipCode || 'N/A';

    const documentBody = this.itemDetails.map((item) => [
      item.nameDisplay || '---',
      item.countryDisplay || '---',
      item.hagueStatusDisplay || '---',
      item.statusDisplay || '---',
      item.rejectionReasonDisplay || '---',
      item.notesDisplay || '---'
    ]);

    const paymentDetail = this.paymentDetails.length > 0 ? this.paymentDetails[0] : {};

    // Header Section
    doc.setFontSize(10);
    doc.setFont('times', 'bold');
    doc.text('CUSTOMER RECEIPT', pageWidth / 2, yPosition, { align: 'center' });
    yPosition += 5; // Reduced spacing between lines
    doc.text('ORDER DETAILS REPORT', pageWidth / 2, yPosition, {
      align: 'center'
    });
    yPosition += 12;

    // Date and Work Order Number
    await checkPageEnd(8);
    doc.setFontSize(10);
    doc.text(`Date Processed: ${appliedDate}`, marginLeft, yPosition);
    doc.text(`Work Order Number: ${workOrderNumber}`, pageWidth - marginRight - 60, yPosition);
    yPosition += 8;

    // Customer Details
    await checkPageEnd(8);
    doc.text(`${individualName}`, marginLeft, yPosition);
    doc.text(`${addressLine}`, marginLeft, yPosition + 5);
    doc.text(`${city}, ${state} ${zipCode}`, marginLeft, yPosition + 10);
    yPosition += 15;

    // Thank You Note
    await checkPageEnd(10);
    doc.setFont('times', 'normal');
    doc.setFontSize(10);
    doc.text('Thank you for presenting your documents to the Connecticut Secretary of the State. Please find the order details below:', marginLeft, yPosition, {
      maxWidth: textWidth
    });
    yPosition += 10;

    // Order Details Section
    await checkPageEnd(8);
    doc.setFont('times', 'bold');
    doc.text('Order Details:', marginLeft, yPosition);
    yPosition += 3;

    // Table with autoTable plugin
    doc.autoTable({
      startY: yPosition,
      head: [['Name on Document', 'Country', 'Hague Status', 'Status', 'Rejection Reason', 'Notes']],
      body: documentBody,
      theme: 'grid',
      margin: { left: marginLeft, right: marginRight },
      headStyles: {
        fillColor: [243, 243, 243],
        textColor: [68, 68, 79]
      },
      styles: {
        font: 'times',
        fontSize: 10,
        cellPadding: 2, // Reduced cell padding for compact table
        overflow: 'linebreak'
      },
      columnStyles: {
        4: { cellWidth: 45 }
      },
      didDrawPage: (data) => {
        if (data.cursor.y + 20 > pageHeight - marginBottom) {
          doc.addPage();
          yPosition = addHeaderImage();
        }
      }
    });

    yPosition = doc.lastAutoTable.finalY + 6;

    // Work Order Payment Details
    const totalReceived = '$' + paymentDetail.TotalFeeAmount || '---';
    const paymentType = paymentDetail.New_Transaction_Types || '---';
    const partialRefund = '$' +paymentDetail.Partial_Refund__c || '---';
    const refundType = paymentDetail.Refund_Transaction_Types || '---';

    await checkPageEnd(20);
    doc.setFontSize(10);
    const rejectedDocsText = [
      '*Rejected Documents: Once you have corrected the issues with your document(s), you may log in to the Apostille portal at (URL) to re-open your order request and resubmit your corrected document(s).'
    ];
    doc.text(rejectedDocsText, marginLeft, yPosition, { maxWidth: textWidth });
    yPosition += 10;

    await checkPageEnd(12);
    doc.setFont('times', 'bold');
    doc.text('Work Order Payment Details:', marginLeft, yPosition);
    yPosition += 5;

    doc.setFont('times', 'normal');
    const colWidth = textWidth / 4;
    doc.text('Total Received', marginLeft, yPosition);
    doc.text(totalReceived, marginLeft + colWidth, yPosition);
    doc.text(paymentType, marginLeft + colWidth * 2, yPosition);
    yPosition += 5;
    doc.text('Partial Refund', marginLeft, yPosition);
    doc.text(partialRefund, marginLeft + colWidth, yPosition);
    doc.text(refundType, marginLeft + colWidth * 2, yPosition);
    yPosition += 6;

    // Additional Information Text
    await checkPageEnd(70);
    const infoText = [
      'On January 1, 2025, the Connecticut Secretary of the State began issuing a single authentication certificate for all',
      'legalization requests. Every eligible document presented to the Connecticut Secretary of the State will receive the same',
      "treatment. You will find the uniform certificate has been affixed to the underlying public document's signature",
      'page using a gold grommet and an offset raised seal.',
      '',
      'Documents legalized for use in countries that are contracting members of the Hague Apostille Convention can immediately',
      'be used overseas. Documents legalized for use in countries that are not contracting members of the Hague Apostille',
      'Convention will require further legalization through the U.S. Department of State prior to being sent overseas.'
    ];
    doc.text(infoText, marginLeft, yPosition, {
      maxWidth: textWidth,
      lineHeightFactor: 1.15
    }); // Tighter line spacing for paragraph
    yPosition += doc.getTextDimensions(infoText).h + 10;

    // Final Warning Text
    await checkPageEnd(8);
    doc.setFont('times', 'italic', 'bold');
    doc.text('Apostilles cannot be issued for U.S. territories and possessions such as Puerto Rico and the U.S. Virgin Islands.', marginLeft, yPosition);
    yPosition += 10;

    // Footer
    await checkPageEnd(25);
    doc.setFont('times', 'normal');
    doc.setFontSize(10);

    // Text before the link
    doc.text("Receiving parties may verify the issuance of an apostille via Connecticut's e-register:", marginLeft, yPosition);

    // Link text
    const linkText = 'Link to SOTS Website Verify apostille';
    const linkUrl = `${sapSOTSAppUrl}/eApostille/apostilleverification`;
    yPosition += 8;

    doc.setTextColor(0, 0, 255);

    // Draw the link text and underline it
    doc.text(linkText, marginLeft, yPosition);
    const underlineWidth = doc.getTextWidth(linkText);
    doc.setLineWidth(0.2);
    doc.line(marginLeft, yPosition + 1, marginLeft + underlineWidth, yPosition + 1); // Underline the link text

    // Add the clickable link
    doc.link(marginLeft, yPosition - 4, underlineWidth, 10, { url: linkUrl });

    yPosition += 18; // Space after the link
    doc.setTextColor(0); // Reset text color to black

    await checkPageEnd(25);
    doc.setFont('times', 'bold');
    doc.text('Thank you,', marginLeft, yPosition);
    doc.setFont('times', 'normal');
    const closingText = ['Secretary of the State', 'Authentications and Apostille Unit', '165 Capitol Ave Suite 1000,', 'Hartford, CT 06106', 'bsd@ct.gov'];
    doc.text(closingText, marginLeft, yPosition + 8, { lineHeightFactor: 1.1 });

    try {
      const pdfBlob = doc.output('blob');
      this.pdfUrl = URL.createObjectURL(pdfBlob);

      const anchor = document.createElement('a');
      anchor.href = this.pdfUrl;
      anchor.download = 'Letter.pdf';
      anchor.click();

      setTimeout(() => URL.revokeObjectURL(this.pdfUrl), 10000);
    } catch (error) {
      console.error('Error generating PDF:', error);
    }
  }

  @api
  async printLetterCertificate(certificateNo) {
    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }

    console.log('Certificate No in child component:', certificateNo);

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.width;
    const pageHeight = doc.internal.pageSize.height;
    const marginLeft = 20;
    const marginRight = 20;
    const marginTop = 10;
    const marginBottom = 20;
    const textWidth = pageWidth - marginLeft - marginRight;

    // Function to add header image on each page, spanning from marginLeft to marginRight
    const addHeaderImage = async () => {
      try {
        const imageData = await getBase64Image({
          imageName: 'certificateImage'
        });
        const imageHeight = (35 / 297) * pageWidth; // Adjust height as needed

        // Set image to start at marginLeft and span textWidth
        doc.addImage(imageData, 'PNG', marginLeft - 8, marginTop, textWidth + 15, imageHeight);
        return marginTop + imageHeight + 5; // Minimal padding after image
      } catch (error) {
        console.error('Error loading image:', error);
        return marginTop;
      }
    };

    // Load header image and set initial Y position
    let yPosition = await addHeaderImage();

    // Helper function to handle pagination
    const checkPageEnd = async (additionalHeight = 0) => {
      if (yPosition + additionalHeight > pageHeight - marginBottom) {
        doc.addPage();
        yPosition = await addHeaderImage();
      }
    };

    // Define fallback values
    const appliedDate = this.appliedDate || 'N/A';
    const workOrderNumber = this.workOrderNumber || 'N/A';
    const individualName = this.individualName || 'N/A';
    const addressLine = this.addressLine || 'N/A';
    const city = this.city || 'N/A';
    const state = this.state || 'N/A';
    const zipCode = this.zipCode || 'N/A';

    const documentBody = this.itemDetails.map((item) => [
      item.nameDisplay || '---',
      item.countryDisplay || '---',
      item.hagueStatusDisplay || '---',
      item.statusDisplay || '---',
      item.rejectionReasonDisplay || '---',
      item.notesDisplay || '---'
    ]);

    const paymentDetail = this.paymentDetails.length > 0 ? this.paymentDetails[0] : {};

    // Header Section
    doc.setFontSize(10);
    doc.setFont('times', 'bold');
    doc.text('CUSTOMER RECEIPT', pageWidth / 2, yPosition, { align: 'center' });
    yPosition += 5; // Reduced spacing between lines
    doc.text('ORDER DETAILS REPORT', pageWidth / 2, yPosition, {
      align: 'center'
    });
    yPosition += 12;

    // Date and Work Order Number
    await checkPageEnd(8);
    doc.setFontSize(10);
    doc.text(`Date Processed: ${appliedDate}`, marginLeft, yPosition);
    doc.text(`Work Order Number: ${workOrderNumber}`, pageWidth - marginRight - 60, yPosition);
    yPosition += 8;

    // Customer Details
    await checkPageEnd(8);
    doc.text(`${individualName}`, marginLeft, yPosition);
    doc.text(`${addressLine}`, marginLeft, yPosition + 5);
    doc.text(`${city}, ${state} ${zipCode}`, marginLeft, yPosition + 10);
    yPosition += 15;

    // Thank You Note
    await checkPageEnd(10);
    doc.setFont('times', 'normal');
    doc.setFontSize(10);
    doc.text('Thank you for presenting your documents to the Connecticut Secretary of the State. Please find the order details below:', marginLeft, yPosition, {
      maxWidth: textWidth
    });
    yPosition += 10;

    // Order Details Section
    await checkPageEnd(8);
    doc.setFont('times', 'bold');
    doc.text('Order Details:', marginLeft, yPosition);
    yPosition += 3;

    // Table with autoTable plugin
    doc.autoTable({
      startY: yPosition,
      head: [['Name on Document', 'Country', 'Hague Status', 'Status', 'Rejection Reason', 'Notes']],
      body: documentBody,
      theme: 'grid',
      margin: { left: marginLeft, right: marginRight },
      headStyles: {
        fillColor: [243, 243, 243],
        textColor: [68, 68, 79]
      },
      styles: {
        font: 'times',
        fontSize: 10,
        cellPadding: 2, // Reduced cell padding for compact table
        overflow: 'linebreak'
      },
      columnStyles: {
        4: { cellWidth: 45 }
      },
      didDrawPage: (data) => {
        if (data.cursor.y + 20 > pageHeight - marginBottom) {
          doc.addPage();
          yPosition = addHeaderImage();
        }
      }
    });

    yPosition = doc.lastAutoTable.finalY + 6;

    // Work Order Payment Details
    const totalReceived = paymentDetail.TotalFeeAmount || '---';
    const paymentType = paymentDetail.SAP_Payment_Type__c || '---';
    const partialRefund = '---';
    const refundType = '---';

    await checkPageEnd(20);
    doc.setFontSize(10);
    const rejectedDocsText = [
      '*Rejected Documents: Once you have corrected the issues with your document(s), you may log in to the Apostille portal at (URL) to re-open your order request and resubmit your corrected document(s).'
    ];
    doc.text(rejectedDocsText, marginLeft, yPosition, { maxWidth: textWidth });
    yPosition += 10;

    await checkPageEnd(12);
    doc.setFont('times', 'bold');
    doc.text('Work Order Payment Details:', marginLeft, yPosition);
    yPosition += 5;

    doc.setFont('times', 'normal');
    const colWidth = textWidth / 4;
    doc.text('Total Received', marginLeft, yPosition);
    doc.text(totalReceived, marginLeft + colWidth, yPosition);
    doc.text(paymentType, marginLeft + colWidth * 2, yPosition);
    yPosition += 5;
    doc.text('Partial Refund', marginLeft, yPosition);
    doc.text(partialRefund, marginLeft + colWidth, yPosition);
    doc.text(refundType, marginLeft + colWidth * 2, yPosition);
    yPosition += 6;

    // Additional Information Text
    await checkPageEnd(70);
    const infoText = [
      'On January 1, 2025, the Connecticut Secretary of the State began issuing a single authentication certificate for all',
      'legalization requests. Every eligible document presented to the Connecticut Secretary of the State will receive the same',
      "treatment. You will find the uniform certificate has been affixed to the underlying public document's signature",
      'page using a gold grommet and an offset raised seal.',
      '',
      'Documents legalized for use in countries that are contracting members of the Hague Apostille Convention can immediately',
      'be used overseas. Documents legalized for use in countries that are not contracting members of the Hague Apostille',
      'Convention will require further legalization through the U.S. Department of State prior to being sent overseas.'
    ];
    doc.text(infoText, marginLeft, yPosition, {
      maxWidth: textWidth,
      lineHeightFactor: 1.15
    }); // Tighter line spacing for paragraph
    yPosition += doc.getTextDimensions(infoText).h + 10;

    // Final Warning Text
    await checkPageEnd(8);
    doc.setFont('times', 'italic', 'bold');
    doc.text('Apostilles cannot be issued for U.S. territories and possessions such as Puerto Rico and the U.S. Virgin Islands.', marginLeft, yPosition);
    yPosition += 10;

    // Footer
    await checkPageEnd(25);
    doc.setFont('times', 'normal');
    doc.setFontSize(10);

    // Text before the link
    doc.text("Receiving parties may verify the issuance of an apostille via Connecticut's e-register:", marginLeft, yPosition);

    // Link text
    const linkText = 'Link to SOTS Website Verify apostille';
    const linkUrl = `${sapSOTSAppUrl}/eApostille/apostilleverification?certificateNo=${encodeURIComponent(certificateNo)}`;
    yPosition += 8;

    doc.setTextColor(0, 0, 255);

    // Draw the link text and underline it
    doc.text(linkText, marginLeft, yPosition);
    const underlineWidth = doc.getTextWidth(linkText);
    doc.setLineWidth(0.2);
    doc.line(marginLeft, yPosition + 1, marginLeft + underlineWidth, yPosition + 1); // Underline the link text

    // Add the clickable link
    doc.link(marginLeft, yPosition - 4, underlineWidth, 10, { url: linkUrl });

    yPosition += 18; // Space after the link
    doc.setTextColor(0); // Reset text color to black

    await checkPageEnd(25);
    doc.setFont('times', 'bold');
    doc.text('Thank you,', marginLeft, yPosition);
    doc.setFont('times', 'normal');
    const closingText = ['Secretary of the State', 'Authentications and Apostille Unit', '165 Capitol Ave Suite 1000,', 'Hartford, CT 06106', 'bsd@ct.gov'];
    doc.text(closingText, marginLeft, yPosition + 8, { lineHeightFactor: 1.1 });

    // Generate the PDF
    try {
      const pdfBlob = doc.output('blob');
      this.pdfUrl = URL.createObjectURL(pdfBlob);

      const anchor = document.createElement('a');
      anchor.href = this.pdfUrl;
      anchor.target = '_blank';
      anchor.click();

      setTimeout(() => URL.revokeObjectURL(this.pdfUrl), 10000);
    } catch (error) {
      console.error('Error generating PDF:', error);
    }
  }

  @api
  async generateDataForApostillePaymentReceiptCard() {
    console.log('API method called:');

    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.width;
    const pageHeight = doc.internal.pageSize.height;
    const marginLeft = 15;
    const marginRight = 15;
    const marginTop = 10;
    const marginBottom = 20;
    const textWidth = pageWidth - marginLeft - marginRight;
    console.log(textWidth);

    let yPosition = marginTop;

    // Function to handle page breaks
    const checkPageEnd = (additionalHeight = 10) => {
      if (yPosition + additionalHeight > pageHeight - marginBottom) {
        doc.addPage();
        yPosition = marginTop;
      }
    };

    // Load the base64 image asynchronously
    try {
      const imageData = await getBase64Image({ imageName: 'certificateImage' });
      const imageWidth = pageWidth - marginLeft - marginRight; // Full width with margins
      const imageHeight = (35 / 297) * pageWidth; // Adjust height

      doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
      yPosition += imageHeight + 8; // Padding below image
    } catch (error) {
      console.error('Error loading image:', error);
    }

    // Header Text
    checkPageEnd(20);
    doc.setFontSize(15);
    doc.setFont('Verdana', 'bold');
    doc.text('PAYMENT RECEIPT', pageWidth / 2, yPosition, { align: 'center' });
    yPosition += 15;

    // Dynamic Customer Info
    checkPageEnd(10);
    doc.setFontSize(12); // Reduced size for dynamic customer info
    doc.setFont('Verdana', 'normal');
    doc.setFont('Verdana', 'normal');
    doc.text('Requestor Name:', marginLeft, yPosition);
    doc.setFont('Verdana', 'normal');
    doc.text(this.requestorName || 'N/A', marginLeft + 100, yPosition);

    doc.setFont('Verdana', 'normal');
    yPosition += 10;
    doc.text('Work Order Number:', marginLeft, yPosition);
    doc.setFont('Verdana', 'normal');
    doc.text(this.workOrderNumb || 'N/A', marginLeft + 100, yPosition);

    doc.setFont('Verdana', 'normal');
    yPosition += 10;
    doc.text('Total Amount Paid:', marginLeft, yPosition);
    doc.setFont('Verdana', 'normal');
    doc.text('$' + this.price || 'N/A', marginLeft + 100, yPosition);

    doc.setFont('Verdana', 'normal');
    yPosition += 10;
    doc.text('Payment Method:', marginLeft, yPosition);
    doc.setFont('Verdana', 'normal');
    doc.text(this.paymentMethod || 'N/A', marginLeft + 100, yPosition);

    doc.setFont('Verdana', 'normal');
    yPosition += 10;
    doc.text('Auth Code:', marginLeft, yPosition);
    doc.setFont('Verdana', 'normal');
    doc.text(this.authCode || 'N/A', marginLeft + 100, yPosition);

    doc.setFont('Verdana', 'normal');
    yPosition += 10;
    doc.text('Credit Card Name:', marginLeft, yPosition);
    doc.setFont('Verdana', 'normal');
    doc.text(this.cardName || 'N/A', marginLeft + 100, yPosition);

    doc.setFont('Verdana', 'normal');
    yPosition += 10;
    doc.text('Card Last digit:', marginLeft, yPosition);
    doc.setFont('Verdana', 'normal');
    doc.text(this.cardLastDigit || 'N/A', marginLeft + 100, yPosition);

    doc.setFont('Verdana', 'normal');
    yPosition += 10;
    doc.text('Date of Payment:', marginLeft, yPosition);
    doc.setFont('Verdana', 'normal');
    doc.text(this.paymentDate || 'N/A', marginLeft + 100, yPosition);

    const tableDataHeader = ['Type of Document', 'Person Listed on the Document/Certified Copy Number', 'Destination Country', 'Hague Member', 'Fee'];

    // Replace with dynamic data
    const tableData = this.documentsRequested.map((doc) => [
      doc.documentType || 'N/A',
      doc.name || 'N/A',
      doc.country || 'N/A',
      doc.hagueStatus || 'N/A',
      doc.fees || 'N/A',
      `${doc.fees ? `${doc.fees}` : 'N/A'}${this.expediteFee ? ' (+ $50.00)' : ''}`
    ]);

    // Add row for total fee and expedite fee
    tableData.push([
      {
        content: `Total: ${this.totalFee || 'N/A'} (Expedite: ${this.expediteFee || 'N/A'})`,
        colSpan: 5,
        styles: { halign: 'right', fontStyle: 'normal' }
      }
    ]);

    // Add the table with autoTable
    doc.autoTable({
      head: [tableDataHeader], // Use the defined table header
      body: tableData,
      startY: yPosition + 15, // Ensure it starts below the previous content
      margin: { left: marginLeft, right: marginRight },
      styles: {
        font: 'helvetica',
        fontSize: 10,
        cellPadding: 2,
        overflow: 'linebreak',
        valign: 'middle'
      },
      columnStyles: {
        4: { halign: 'right' } // Right-align the last column (Fees)
      },
      tableWidth: pageWidth - marginLeft - marginRight // Adjust table width to fit between margins
    });

    // Save the PDF
    try {
      doc.save('CustomerInvoice.pdf');
      console.log('PDF generated and saved.');
    } catch (error) {
      console.error('Error generating or previewing PDF:', error);
    }
  }

  @api
  async generateDataForApostillePaymentReceiptCheck() {
    console.log('API method called:');

    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.width;
    const pageHeight = doc.internal.pageSize.height;
    const marginLeft = 15;
    const marginRight = 15;
    const marginTop = 10;
    const marginBottom = 20;
    const textWidth = pageWidth - marginLeft - marginRight;
    console.log(textWidth);

    let yPosition = marginTop;

    // Function to handle page breaks
    const checkPageEnd = (additionalHeight = 10) => {
      if (yPosition + additionalHeight > pageHeight - marginBottom) {
        doc.addPage();
        yPosition = marginTop;
      }
    };

    // Load the base64 image asynchronously
    try {
      const imageData = await getBase64Image({ imageName: 'certificateImage' });
      const imageWidth = pageWidth - marginLeft - marginRight; // Full width with margins
      const imageHeight = (35 / 297) * pageWidth; // Adjust height

      doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
      yPosition += imageHeight + 8; // Padding below image
    } catch (error) {
      console.error('Error loading image:', error);
    }

    // Header Text
    checkPageEnd(20);
    doc.setFontSize(15);
    doc.setFont('Verdana', 'bold');
    doc.text('PAYMENT RECEIPT', pageWidth / 2, yPosition, { align: 'center' });
    yPosition += 15;

    // Dynamic Customer Info
    checkPageEnd(10);
    doc.setFontSize(12); // Reduced size for dynamic customer info
    doc.setFont('Verdana', 'normal');
    doc.setFont('Verdana', 'normal');
    doc.text('Requestor Name:', marginLeft, yPosition);
    doc.setFont('Verdana', 'normal');
    doc.text(this.requestorName || 'N/A', marginLeft + 100, yPosition);

    doc.setFont('Verdana', 'normal');
    yPosition += 10;
    doc.text('Work Order Number:', marginLeft, yPosition);
    doc.setFont('Verdana', 'normal');
    doc.text(this.workOrderNumb || 'N/A', marginLeft + 100, yPosition);

    doc.setFont('Verdana', 'normal');
    yPosition += 10;
    doc.text('Total Amount Paid:', marginLeft, yPosition);
    doc.setFont('Verdana', 'normal');
    doc.text('$' + this.price || 'N/A', marginLeft + 100, yPosition);

    doc.setFont('Verdana', 'normal');
    yPosition += 10;
    doc.text('Payment Method:', marginLeft, yPosition);
    doc.setFont('Verdana', 'normal');
    doc.text(this.paymentMethod || 'N/A', marginLeft + 100, yPosition);

    doc.setFont('Verdana', 'normal');
    yPosition += 10;
    doc.text('Date of Payment:', marginLeft, yPosition);
    doc.setFont('Verdana', 'normal');
    doc.text(this.paymentDate || 'N/A', marginLeft + 100, yPosition);

    const tableDataHeader = ['Type of Document', 'Person Listed on the Document/Certified Copy Number', 'Destination Country', 'Hague Member', 'Fee'];

    // Replace with dynamic data
    const tableData = this.documentsRequested.map((doc) => [
      doc.documentType || 'N/A',
      doc.name || 'N/A',
      doc.country || 'N/A',
      doc.hagueStatus || 'N/A',
      doc.fees || 'N/A',
      `${doc.fees ? `${doc.fees}` : 'N/A'}${this.expediteFee ? ' (+ $50.00)' : ''}`
    ]);

    // Add row for total fee and expedite fee
    tableData.push([
      {
        content: `Total: ${this.totalFee || 'N/A'} (Expedite: ${this.expediteFee || 'N/A'})`,
        colSpan: 5,
        styles: { halign: 'right', fontStyle: 'normal' }
      }
    ]);

    // Add the table with autoTable
    doc.autoTable({
      head: [tableDataHeader], // Use the defined table header
      body: tableData,
      startY: yPosition + 15, // Ensure it starts below the previous content
      margin: { left: marginLeft, right: marginRight },
      styles: {
        font: 'helvetica',
        fontSize: 10,
        cellPadding: 2,
        overflow: 'linebreak',
        valign: 'middle'
      },
      columnStyles: {
        4: { halign: 'right' } // Right-align the last column (Fees)
      },
      tableWidth: pageWidth - marginLeft - marginRight // Adjust table width to fit between margins
    });

    // Save the PDF
    try {
      doc.save('CustomerInvoice.pdf');
      console.log('PDF generated and saved.');
    } catch (error) {
      console.error('Error generating or previewing PDF:', error);
    }
  }

  @api records = []; // Receive the entire records array from the parent component

  @api
  async generateDataForApostillePrintPaymentReceipt() {
    console.log('API method called:');

    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.width;
    const pageHeight = doc.internal.pageSize.height;
    const marginLeft = 15;
    const marginRight = 15;
    const marginTop = 10;
    const marginBottom = 20;
    const textWidth = pageWidth - marginLeft - marginRight;
    console.log(textWidth);

    let yPosition = marginTop;
    let imageData;

    // Load the base64 image asynchronously
    try {
      imageData = await getBase64Image({ imageName: 'certificateImage' });
    } catch (error) {
      console.error('Error loading image:', error);
    }

    // Function to add header and image
    const addHeader = () => {
      if (imageData) {
        const imageWidth = pageWidth - marginLeft - marginRight;
        const imageHeight = (35 / 297) * pageWidth;
        doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
        yPosition += imageHeight + 8;
      }

      doc.setFontSize(15);
      doc.setFont('Verdana', 'bold');
      doc.text('PAYMENT RECEIPT', pageWidth / 2, yPosition, {
        align: 'center'
      });
      yPosition += 15;
    };

    // Function to check if a page break is needed
    const checkPageEnd = (additionalHeight = 10) => {
      if (yPosition + additionalHeight > pageHeight - marginBottom) {
        doc.addPage();
        yPosition = marginTop;
        addHeader();
      }
    };

    // Add initial header
    addHeader();
    doc.setFontSize(10);
    doc.setFont('Verdana', 'normal');
    this.records.forEach((record) => {
      checkPageEnd(30); // Check if space is available before adding record

      const details = [
        { label: 'Work Order#:', value: record.workOrder },
        { label: 'Total Amount Paid:', value: record.totalAmountPaid },
        { label: 'Payment Method:', value: record.paymentMethod },
        { label: 'Auth Code:', value: record.authCode },
        { label: 'Date of Payment:', value: record.dateOfPayment }
      ];

      const startX = marginLeft + 5;
      const valueX = pageWidth / 2;
      const lineHeight = 8;
      doc.setFontSize(10);

      details.forEach((item) => {
        checkPageEnd(lineHeight);
        doc.setFont('helvetica', 'bold');
        doc.setFontSize(10);

        doc.text(item.label, startX, yPosition);
        doc.setFont('helvetica', 'normal');
        doc.text(item.value, valueX, yPosition);
        yPosition += lineHeight;
      });

      // Draw separator line after each entry
      checkPageEnd(10);
      doc.setDrawColor(12, 124, 206);
      doc.setLineWidth(0.5);
      doc.line(marginLeft, yPosition, pageWidth - marginRight, yPosition);
      yPosition += 10;
    });

    try {
      doc.save('CustomerInvoice.pdf');
      console.log('PDF generated and saved.');
    } catch (error) {
      console.error('Error generating or previewing PDF:', error);
    }
  }

  @api
  async generateDataForInhouseApostillePrintPaymentReceipt(type) {
    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }
  
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.width;
    const pageHeight = doc.internal.pageSize.height;
    const marginLeft = 15;
    const marginRight = 15;
    const marginTop = 10;
    const marginBottom = 20;
    const textWidth = pageWidth - marginLeft - marginRight;
    let yPosition = marginTop;
  
    let imageData = '';
    const imageHeight = (35 / 297) * pageWidth;
    const imageWidth = pageWidth - marginLeft - marginRight;
  
    try {
      imageData = await getBase64Image({ imageName: 'certificateImage' });
  
      // Draw header image + title on first page
      doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
      yPosition += imageHeight + 8;
  
      doc.setFontSize(15);
      doc.setFont('Verdana', 'bold');
      doc.text('PAYMENT RECEIPT', pageWidth / 2, yPosition, { align: 'center' });
      yPosition += 15;
    } catch (error) {
      console.error('Error loading image:', error);
    }
  
    doc.setFontSize(10);
    doc.setFont('Verdana', 'normal');
  
    const checkPageEnd = (additionalHeight = 10) => {
      if (yPosition + additionalHeight > pageHeight - marginBottom) {
        doc.addPage();
        yPosition = marginTop + imageHeight + 8 + 15; // Image + space + title
      }
    };
  
    // Payment records
    this.records.forEach((record) => {
      checkPageEnd(40);
      const details = [
        { label: 'Work Order#:', value: record.workOrder },
        { label: 'Total Amount Paid:', value: record.totalAmountPaid },
        { label: 'Payment Method:', value: record.paymentMethod },
        { label: 'Auth Code:', value: record.authCode || 'N/A' },
        { label: 'Date of Payment:', value: record.dateOfPayment }
      ];
  
      const startX = marginLeft + 5;
      const valueX = pageWidth / 2;
      const lineHeight = 8;
  
      details.forEach((item) => {
        checkPageEnd(lineHeight);
        doc.setFont('helvetica', 'bold').setFontSize(10);
        doc.text(item.label, startX, yPosition);
        doc.setFont('helvetica', 'normal');
        doc.text(item.value, valueX, yPosition);
        yPosition += lineHeight;
      });
  
      checkPageEnd(10);
      doc.setDrawColor(12, 124, 206);
      doc.setLineWidth(0.5);
      doc.line(marginLeft, yPosition, pageWidth - marginRight, yPosition);
      yPosition += 10;
    });
  
    // Document Table
    const tableDataHeader = [
      'Type of Document',
      'Person Listed on the Document/Certified Copy Number',
      'Destination Country',
      'Hague Member',
      'Fee'
    ];
  
    const tableData = this.documentsRequested.map((doc) => [
      doc.documentType || 'N/A',
      doc.name || 'N/A',
      doc.country || 'N/A',
      doc.hagueStatus || 'N/A',
      `${doc.fees ? `${doc.fees}` : 'N/A'}${this.expediteFee ? ' (+ $50.00)' : ''}`
    ]);
  
    tableData.push([
      {
        content: `Total: ${this.totalFee || 'N/A'} (Expedite: ${this.expediteFee || 'N/A'})`,
        colSpan: 5,
        styles: { halign: 'right', fontStyle: 'normal' }
      }
    ]);
  
    doc.autoTable({
      head: [tableDataHeader],
      body: tableData,
      startY: yPosition,
      margin: { left: marginLeft, right: marginRight },
      styles: {
        font: 'helvetica',
        fontSize: 10,
        cellPadding: 2,
        overflow: 'linebreak',
        valign: 'middle'
      },
      columnStyles: {
        4: { halign: 'right' }
      },
      didDrawPage: (data) => {
        // Re-draw image + title on each page
        doc.addImage(imageData, 'PNG', marginLeft, marginTop, imageWidth, imageHeight);
        doc.setFontSize(15);
        doc.setFont('Verdana', 'bold');
        doc.text('PAYMENT RECEIPT', pageWidth / 2, marginTop + imageHeight + 8, { align: 'center' });
      }
    });
  
    try {
      const pdfBlob = await doc.output('blob');
      if (type === 'download') {
        doc.save('CustomerInvoice.pdf');
      } else if (type === 'email') {
        const base64Data = await this.convertBlobToBase64(pdfBlob);
        return base64Data;
      }
    } catch (error) {
      console.error('Error generating or previewing PDF:', error);
    }
  }
  
  convertBlobToBase64(blob) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onloadend = () => resolve(reader.result);
      reader.onerror = reject;
      reader.readAsDataURL(blob);
    });
  }
  
  

  connectedCallback() {
    // if (this.jsPdfInitialized) {
    //     return;
    // }
    // this.jsPdfInitialized = true;

    // Load jsPDF and autoTable in sequence
    // Promise.all([
    //     loadScript(this, jsPDF),
    //     loadScript(this, jsPdfAutotable) // Ensure jsPdfAutotable comes after jsPDF
    // ]).then(() => {
    //     console.log('jsPDF and jsPdfAutotable loaded successfully.');
    // }).catch(error => {
    //     console.error('Error loading jsPDF or jsPdfAutotable', error);
    // });

    loadScript(this, jsPDF)
      .then(() => {
        console.log('jsPDF loaded successfully.');

        // Now load jsPdfAutotable after jsPDF is loaded
        return loadScript(this, jsPdfAutotable);
      })
      .then(() => {
        console.log('jsPdfAutotable loaded successfully.');
      })
      .catch((error) => {
        console.error('Error loading jsPDF or jsPdfAutotable:', error);
      });

    console.log('individual application id: ', this.individualApplicationId);
  }

  @api
  async generateDataForPrintApostilleSubmissionDocument() {
    console.log('API method called:');

    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.width;
    const pageHeight = doc.internal.pageSize.height;
    const marginLeft = 15;
    const marginRight = 15;
    const marginTop = 10;
    const marginBottom = 20;
    const textWidth = pageWidth - marginLeft - marginRight;
    console.log(textWidth);

    let yPosition = marginTop;

    // Function to handle page breaks
    const checkPageEnd = (additionalHeight = 10) => {
      if (yPosition + additionalHeight > pageHeight - marginBottom) {
        doc.addPage();
        yPosition = marginTop;
      }
    };

    // Load the base64 image asynchronously
    try {
      const imageData = await getBase64Image({ imageName: 'certificateImage' });
      const imageWidth = pageWidth - marginLeft - marginRight; // Full width with margins
      const imageHeight = (35 / 297) * pageWidth; // Adjust height

      doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
      yPosition += imageHeight + 8; // Padding below image
    } catch (error) {
      console.error('Error loading image:', error);
    }

    // Header Text
    checkPageEnd(20);
    doc.setFontSize(20);
    doc.setFont('Verdana', 'normal');
    doc.text('Apostille Submission Document', pageWidth / 2, yPosition, {
      align: 'center'
    });
    yPosition += 15;

    // Intro Text
    doc.setFontSize(10);
    doc.setFont('Verdana', 'normal');
    doc.text('Thank You, Your apostille request has been successfully submitted. Below are the details of your request:', marginLeft, yPosition);
    yPosition += 10;

    // Dynamic Customer Info
    checkPageEnd(10);
    doc.setFont('Verdana', 'normal');
    doc.text('Customer Name:', marginLeft, yPosition);
    doc.setFont('Verdana', 'bold');
    doc.text(this.customerName || 'N/A', marginLeft + 40, yPosition);

    doc.setFont('Verdana', 'normal');
    yPosition += 5;
    doc.text('Work Order Number:', marginLeft, yPosition);
    doc.setFont('Verdana', 'bold');
    doc.text(this.workOrderNum || 'N/A', marginLeft + 40, yPosition);

    yPosition += 10;

    // Table Data Header
    const tableDataHeader = ['Type of Document', 'Person Listed on the Document/Certified Copy Number', 'Destination Country', 'Hague Member', 'Fee'];

    // Replace with dynamic data
    const tableData = this.documentsRequested.map((doc) => [
      doc.documentType || 'N/A',
      doc.name || 'N/A',
      doc.country || 'N/A',
      doc.hagueStatus || 'N/A',
      `${doc.fees ? `${doc.fees}` : 'N/A'}${this.expediteFee ? ' (+ $50.00)' : ''}`
    ]);

    // Add row for total fee and expedite fee
    tableData.push([
      {
        content: `Total: ${this.totalFee || 'N/A'} (Expedite: ${this.expediteFee || 'N/A'})`,
        colSpan: 5,
        styles: { halign: 'right', fontStyle: 'normal' }
      }
    ]);

    // Table rendering with autoTable
    checkPageEnd(10);
    doc.autoTable({
      head: [tableDataHeader],
      body: tableData,
      startY: yPosition,
      margin: { left: marginLeft, right: marginRight },
      styles: {
        font: 'Verdana',
        fontSize: 10,
        cellPadding: 2,
        overflow: 'linebreak'
      },
      columnStyles: {
        4: { halign: 'right' } // Right-align the last column
      }
    });

    yPosition = doc.lastAutoTable.finalY + 10;

    // Mailing Information Table
    const mailingInfoHeader = ['Preferred Method', 'Mailing Address'];
    const mailingInfoData = [
      [
        'Hand delivery of original document(s), or send via FedEx, UPS, or DHL:',
        'Secretary of the State, Authentications and Apostille Unit, 165 Capitol Avenue Suite 1000, Hartford, CT 06106'
      ],
      ['First Class or Priority Mail through the US Postal Service:', 'Secretary of the State, Authentications and Apostille Unit, P.O. Box 150470, Hartford, CT 06115-0470']
    ];

    checkPageEnd(10);
    doc.autoTable({
      head: [mailingInfoHeader],
      body: mailingInfoData,
      startY: yPosition,
      margin: { left: marginLeft, right: marginRight },
      styles: {
        font: 'Verdana',
        fontSize: 10,
        cellPadding: 2,
        overflow: 'linebreak'
      }
    });

    yPosition = doc.lastAutoTable.finalY + 10;

    // Optional Footer Text with Link
    checkPageEnd(15);
    doc.setFont('Verdana', 'normal');
    doc.setFontSize(10);
    doc.setTextColor(0, 0, 0);
    doc.text("Receiving parties may verify the issuance of an apostille via Connecticut's e-register:", marginLeft, yPosition);

    // Set link in blue
    yPosition += 5;
    const linkText = 'Link to SOTS Website Track apostille';
    const linkUrl = `${sapSOTSAppUrl}/eApostille/apostillerequest?workOrderNumber=${encodeURIComponent(this.workOrderNum)}`;
    doc.setTextColor(0, 0, 255);
    doc.text(linkText, marginLeft, yPosition);
    const underlineWidth = doc.getTextWidth(linkText);
    doc.setLineWidth(0.2);
    doc.line(marginLeft, yPosition + 1, marginLeft + underlineWidth, yPosition + 1); // Underline link text
    doc.link(marginLeft, yPosition - 4, underlineWidth, 10, { url: linkUrl });
    doc.setTextColor(0); // Reset color to black

    yPosition += 15;

    // Generate PDF and preview
    try {
      const pdfBlob = doc.output('blob');
      this.pdfUrl = URL.createObjectURL(pdfBlob);

      // Open in new tab
      const anchor = document.createElement('a');
      anchor.href = this.pdfUrl;
      anchor.target = '_blank';
      anchor.click();
    } catch (error) {
      console.error('Error generating or previewing PDF:', error);
    }
  }

  @api
  async generateDataForDownloadApostilleSubmissionDocument() {
    console.log('API method called:');

    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.width;
    const pageHeight = doc.internal.pageSize.height;
    const marginLeft = 15;
    const marginRight = 15;
    const marginTop = 10;
    const marginBottom = 20;
    const textWidth = pageWidth - marginLeft - marginRight;
    console.log(textWidth);

    let yPosition = marginTop;

    // Function to handle page breaks
    const checkPageEnd = (additionalHeight = 10) => {
      if (yPosition + additionalHeight > pageHeight - marginBottom) {
        doc.addPage();
        yPosition = marginTop;
      }
    };

    // Load the base64 image asynchronously
    try {
      const imageData = await getBase64Image({ imageName: 'certificateImage' });
      const imageWidth = pageWidth - marginLeft - marginRight; // Full width with margins
      const imageHeight = (35 / 297) * pageWidth; // Adjust height

      doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
      yPosition += imageHeight + 8; // Padding below image
    } catch (error) {
      console.error('Error loading image:', error);
    }

    // Header Text
    checkPageEnd(20);
    doc.setFontSize(20);
    doc.setFont('Verdana', 'normal');
    doc.text('Apostille Submission Document', pageWidth / 2, yPosition, {
      align: 'center'
    });
    yPosition += 15;

    // Intro Text
    doc.setFontSize(10);
    doc.setFont('Verdana', 'normal');
    doc.text('Thank You, Your apostille request has been successfully submitted. Below are the details of your request:', marginLeft, yPosition);
    yPosition += 10;

    // Dynamic Customer Info
    checkPageEnd(10);
    doc.setFont('Verdana', 'normal');
    doc.text('Customer Name:', marginLeft, yPosition);
    doc.setFont('Verdana', 'bold');
    doc.text(this.customerName || 'N/A', marginLeft + 40, yPosition);

    doc.setFont('Verdana', 'normal');
    yPosition += 5;
    doc.text('Work Order Number:', marginLeft, yPosition);
    doc.setFont('Verdana', 'bold');
    doc.text(this.workOrderNum || 'N/A', marginLeft + 40, yPosition);

    yPosition += 10;

    const tableDataHeader = ['Type of Document', 'Person Listed on the Document/Certified Copy Number', 'Destination Country', 'Hague Member', 'Fee'];

    // Replace with dynamic data
    const tableData = this.documentsRequested.map((doc) => [
      doc.documentType || 'N/A',
      doc.name || 'N/A',
      doc.country || 'N/A',
      doc.hagueStatus || 'N/A',
      `${doc.fees ? `${doc.fees}` : 'N/A'}${this.expediteFee ? ' (+ $50.00)' : ''}`
    ]);

    // Add row for total fee and expedite fee
    tableData.push([
      {
        content: `Total: ${this.totalFee || 'N/A'} (Expedite: ${this.expediteFee || 'N/A'})`,
        colSpan: 5,
        styles: { halign: 'right', fontStyle: 'normal' }
      }
    ]);

    // Table rendering with autoTable
    checkPageEnd(10);
    doc.autoTable({
      head: [tableDataHeader],
      body: tableData,
      startY: yPosition,
      margin: { left: marginLeft, right: marginRight },
      styles: {
        font: 'Verdana',
        fontSize: 10,
        cellPadding: 2,
        overflow: 'linebreak'
      },
      columnStyles: {
        4: { halign: 'right' } // Right-align the last column
      }
    });

    yPosition = doc.lastAutoTable.finalY + 10;

    // Mailing Information Table
    const mailingInfoHeader = ['Preferred Method', 'Mailing Address'];
    const mailingInfoData = [
      [
        'Hand delivery of original document(s), or send via FedEx, UPS, or DHL:',
        'Secretary of the State, Authentications and Apostille Unit, 165 Capitol Avenue Suite 1000, Hartford, CT 06106'
      ],
      ['First Class or Priority Mail through the US Postal Service:', 'Secretary of the State, Authentications and Apostille Unit, P.O. Box 150470, Hartford, CT 06115-0470']
    ];

    checkPageEnd(10);
    doc.autoTable({
      head: [mailingInfoHeader],
      body: mailingInfoData,
      startY: yPosition,
      margin: { left: marginLeft, right: marginRight },
      styles: {
        font: 'Verdana',
        fontSize: 10,
        cellPadding: 2,
        overflow: 'linebreak'
      }
    });

    yPosition = doc.lastAutoTable.finalY + 10;

    // Optional Footer Text with Link
    checkPageEnd(15);
    doc.setFont('Verdana', 'normal');
    doc.setFontSize(10);
    doc.setTextColor(0, 0, 0);
    doc.text("Receiving parties may verify the issuance of an apostille via Connecticut's e-register:", marginLeft, yPosition);

    // Set link in blue
    yPosition += 5;
    const linkText = 'Link to SOTS Website Track apostille';
    const linkUrl = `${sapSOTSAppUrl}/eApostille/apostillerequest?workOrderNumber=${encodeURIComponent(this.workOrderNum)}`;
    doc.setTextColor(0, 0, 255);
    doc.text(linkText, marginLeft, yPosition);
    const underlineWidth = doc.getTextWidth(linkText);
    doc.setLineWidth(0.2);
    doc.line(marginLeft, yPosition + 1, marginLeft + underlineWidth, yPosition + 1); // Underline link text
    doc.link(marginLeft, yPosition - 4, underlineWidth, 10, { url: linkUrl });
    doc.setTextColor(0); // Reset color to black

    yPosition += 15;

    // Save PDF
    try {
      doc.save('CustomerSubmittedDocumet.pdf');
      console.log('PDF generated and saved.');
    } catch (error) {
      console.error('Error generating or saving PDF:', error);
    }
  }

  //Print Envelope for state Seal
  // Generates Envelope PDF
  generatePdfForEnvelope() {
    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();

    // Set font to Times New Roman, bold
    doc.setFont('times', 'bold');

    // Set font size to 12 (adjust as needed to match the PDF)
    doc.setFontSize(12);

    // Starting 30% from the top (30% of 297mm = ~89mm from the top)
    const startY = 63;

    // Move content 30% from the right (30% of 210mm = ~63mm from the left)
    const startX = 63;
    // Use dynamic values for name and address
    const recipientName = this.name || ''; // Default to empty if no name is provided
    const streetAddress = this.street || '';
    const cityStatePostal = `${this.city || ''}, ${this.state || ''} ${this.postalCode || ''}`;

    // Name of the recipient
    doc.text(recipientName, startX, startY);

    // Address (Remove extra spacing between lines)
    doc.text(streetAddress, startX, startY + 5); // Smaller gap between lines for a compact look
    doc.text(cityStatePostal, startX, startY + 10); // Smaller gap between lines for a compact look

    try {
      // Generate the PDF blob for download
      const pdfBlob = doc.output('blob');
      const pdfUrl = URL.createObjectURL(pdfBlob);
      const anchor = document.createElement('a');
      anchor.href = pdfUrl;
      anchor.download = this.name + '_Envelope.pdf';
      anchor.click();
      console.log('Envelope PDF generated and downloaded.');
    } catch (error) {
      console.error('Error generating or downloading PDF:', error);
    }
  }

  @api
  generateEnvelope(recordId) {
    console.log('Generating envelope with recordId:', recordId);
    this.recordId = recordId;

    // Fetch data for envelope from Apex
    fetchEnvelopeData({ recordId: this.recordId })
      .then((data) => {
        this.name = data.name;
        this.street = data.street;
        this.city = data.city;
        this.state = data.state;
        this.postalCode = data.postalCode;
        this.dataLoaded = true;
        this.generatePdfForEnvelope();
      })
      .catch((error) => {
        console.error('Error fetching envelope data:', error);
      });
  }

  @api
  viewGenerateEnvelope(recordId) {
    console.log('Generating envelope with recordId:', recordId);
    this.recordId = recordId;

    // Fetch data for envelope from Apex
    fetchEnvelopeData({ recordId: this.recordId })
      .then((data) => {
        this.name = data.name;
        this.street = data.street;
        this.city = data.city;
        this.state = data.state;
        this.postalCode = data.postalCode;
        this.dataLoaded = true;
        this.generatePdfForEnvelope();
      })
      .catch((error) => {
        console.error('Error fetching envelope data:', error);
      });
  }

  //State Seal Letter

  stateSealApprovedOfficialNotice() {
    return `Permission is hereby granted as such reproduction is related to the official business of the state and is allowable under Section 3-106a of the Connecticut General Statutes.`;
  }

  stateSealApprovedNonStandardLetter() {
    return ''; // No additional text for non-standard letter
  }

  stateSealDenialShortNotice() {
    return `Section 3-106a of the Connecticut General Statutes limits the purposes for which the Secretary of the State can approve reproduction of the state arms and seal. The Secretary may approve use that is specifically authorized by the Constitution and laws of the state, or is related to official state business. The Secretary also has discretion, but is not required, to approve use for memorials or for purposes the Secretary considers to be educational. Use of the state seal is rarely approved except for official state business. In addition, the Secretary does not approve use of either the state arms or state seal for commercial purposes.

We have reviewed your proposed usage and believe that it does not fall within the scope of the statutory provisions outlined above. Therefore, I must respectfully decline to approve your request.`;
  }

  stateSealDenialLongNotice() {
    return `Section 3-106a of the Connecticut General Statutes limits the purposes for which the Secretary of the State can approve reproduction of the state arms and seal. The Secretary may approve use that is specifically authorized  by the Constitution and laws of the state, or is related to official state business. The Secretary also has discretion,  but is not required, to approve use for memorials or educational purposes.

Use for official state business requires the involvement of a state office or agency acting in an official capacity. The provision regarding memorials has been interpreted to mean a broad range of plaques, awards and testimonials that have some connection with the functions of a department or an official/employee of state government. This office has historically viewed educational uses as reproduction of the seal or arms in published material used for instructional purposes, such as school textbooks and encyclopedias. This office does not authorize use of the state arms or seal for commercial purposes, for advertising, on non-state agency websites, by candidates for public office, by partisan political organizations or for partisan political purposes, given that such uses are not specifically allowed by law.

We have reviewed your proposed usage and believe that it does not fall within the scope of the statutory provisions outlined above. Therefore, I must respectfully decline to approve your request.`;
  }

  // Helper function to format the date to "Month Day, Year"
  formatDateToLongDate(dateString) {
    const dateObj = new Date(dateString); // Convert the string to a Date object
    const options = { year: 'numeric', month: 'long', day: 'numeric' }; // Format as "Month Day, Year"
    return dateObj.toLocaleDateString('en-US', options); // Output: "September 18, 2024"
  }

  generatePdfForLetter() {
    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.getWidth();
    const pageHeight = doc.internal.pageSize.getHeight();
    let margin = 20; // Set left and right margin
    let currentY = 50; // Initial Y position for the first line

    // Set font to Helvetica, normal
    doc.setFont('helvetica', 'normal');
    doc.setFontSize(10);

    // Date (Date of SOTS Response)
    const dateOfSOTS = this.dateOfSOTSResponse ? this.formatDateToLongDate(this.dateOfSOTSResponse) : '';
    doc.text(dateOfSOTS, margin, currentY);
    currentY += 10; // Move Y position down

    // Recipient Name and Address
    const recipientName = this.name || '';
    const streetAddress = this.street || '';
    const cityStatePostal = `${this.city || ''}, ${this.state || ''} ${this.postalCode || ''}`;
    const lastName = this.lastName || '';

    doc.text(recipientName, margin, currentY);
    currentY += 5; // Move Y position down
    doc.text(streetAddress, margin, currentY);
    currentY += 5;
    doc.text(cityStatePostal, margin, currentY);
    currentY += 10;

    // "Re:" section (Request For field)
    const requestFor = this.requestFor || '';
    doc.setFont('helvetica', 'bold');
    doc.text(`Re: ${requestFor}`, margin, currentY);
    currentY += 10;

    // Reset font to normal for the body
    doc.setFont('helvetica', 'normal');
    doc.text(`Dear ${lastName},`, margin, currentY);
    currentY += 10;

    // Letter Body Text (letterText field)
    const letterText = this.letterText || '';

    // Dynamically split the text to fit within the page width
    const letterTextLines = doc.splitTextToSize(letterText, pageWidth - margin * 2);
    doc.text(letterTextLines, margin, currentY);

    // Calculate height of the letter text block
    const letterTextHeight = letterTextLines.length * 5; // 5 is the approximate height per line
    currentY += letterTextHeight + 10; // Add some padding after the letter text

    // Insert additional content based on letter type
    let additionalText = '';
    if (this.letterType === 'Official Business') {
      additionalText = this.stateSealApprovedOfficialNotice();
    } else if (this.letterType === 'Non-Standard') {
      additionalText = this.stateSealApprovedNonStandardLetter();
    } else if (this.letterType === 'Denial (short)') {
      additionalText = this.stateSealDenialShortNotice();
    } else if (this.letterType === 'Denial (long)') {
      additionalText = this.stateSealDenialLongNotice();
    } else {
      alert('Cannot Print Document for Pedning request!');
      console.log('Cannot Print Document for request InProgress!');
      return;
    }

    if (additionalText) {
      const additionalTextLines = doc.splitTextToSize(additionalText, pageWidth - margin * 2);
      doc.text(additionalTextLines, margin, currentY);
      const additionalTextHeight = additionalTextLines.length * 5; // Approx height per line
      currentY += additionalTextHeight + 5;
    }

    // Add "Sincerely" section
    doc.setFont('helvetica', 'normal');
    doc.setFontSize(10);
    doc.text('Sincerely,', margin, currentY);
    currentY += 5;

    // Signature logic based on wetSignature value
    if (this.wetSignature === 'Yes') {
      // Leave space for handwritten signature
      currentY += 10; // Add space for a handwritten signature
    } else {
      // Placeholder for an image signature (non-wet signature)
      doc.text('Signature Placeholder (image)', margin, currentY);
      currentY += 10;
    }

    // Signature title and names
    doc.setFontSize(10);
    doc.text('Stephanie Thomas', margin, currentY);
    currentY += 5;
    doc.text('Secretary of the State', margin, currentY);
    currentY += 10;

    // Signature logic based on wetSignature value
    if (this.wetSignature === 'Yes') {
      // Leave space for handwritten signature
      currentY += 10; // Add space for a handwritten signature
    } else {
      // Placeholder for an image signature (non-wet signature)
      doc.text('Signature Placeholder (image)', margin, currentY);
      currentY += 10; // Space for image
    }

    // "By" section for deputy
    doc.text('By: Jacqueline A. Kozin', margin, currentY);
    currentY += 5;
    margin += 5;
    doc.text('Deputy Secretary of the State', margin, currentY);
    currentY += 5;
    doc.text('Office of the Secretary of the State', margin, currentY);
    currentY += 5;
    doc.text('(860)509-1111', margin, currentY);

    // Ensure page boundaries
    if (currentY + 20 > pageHeight) {
      doc.addPage(); // Add a new page if there's no space left
      currentY = 25; // Reset Y position for new page
    }

    // Final PDF generation
    try {
      const pdfBlob = doc.output('blob');
      const pdfUrl = URL.createObjectURL(pdfBlob);
      const anchor = document.createElement('a');
      anchor.href = pdfUrl;
      anchor.download = `${this.name}_${this.letterType}.pdf`;
      anchor.click();
      console.log('Letter PDF generated and downloaded.');
    } catch (error) {
      console.error('Error generating or downloading PDF:', error);
    }
  }

  @api
  generateLetter(recordId, letterType, wetSignature, signedBy) {
    console.log('Generating letter with recordId:', recordId);
    this.recordId = recordId;
    this.wetSignature = wetSignature;
    this.signedBy = signedBy;
    console.log(this.wetSignature);

    //Fetch data for the letter from Apex
    fetchLetterData({ recordId: this.recordId })
      .then((data) => {
        // Assign the fetched data to the tracked variables
        this.name = data.name;
        this.lastName = data.lastName;
        this.street = data.street;
        this.city = data.city;
        this.state = data.state;
        this.postalCode = data.postalCode;
        this.dateOfSOTSResponse = data.dateOfSOTSResponse;
        this.requestFor = data.requestFor;
        this.letterText = data.letterText;
        this.letterType = data.letterType;
        this.reason = data.reason;

        console.log(this.letterType);

        // Proceed to generate the PDF once data is loaded
        if (letterType !== null) {
          this.letterType = letterType;
        }

        this.generatePdfForLetter();
      })
      .catch((error) => {
        console.error('Error fetching letter data:', error);
      });
  }

  @api
  viewGenerateLetter(recordId) {
    console.log('Generating letter with recordId:', recordId);
    this.recordId = recordId;
    // Fetch data for the letter from Apex
    fetchLetterData({ recordId: this.recordId })
      .then((data) => {
        // Assign the fetched data to the tracked variables
        this.name = data.name;
        this.lastName = data.lastName;
        this.street = data.street;
        this.city = data.city;
        this.state = data.state;
        this.postalCode = data.postalCode;
        this.dateOfSOTSResponse = data.dateOfSOTSResponse;
        this.requestFor = data.requestFor;
        this.letterText = data.letterText;
        this.letterType = data.letterType;
        this.wetSignature = data.wetSignature;
        this.reason = data.reason;

        this.generatePdfForLetter();
      })
      .catch((error) => {
        console.error('Error fetching letter data:', error);
      });
  }

  @api
  generatepdfLetter() {
    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }
    console.log('PDF generator');

    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    // Set up the document
    const pageWidth = 210;
    const pageHeight = 297;
    doc.setFillColor(255, 255, 255);
    doc.rect(0, 0, pageWidth, pageHeight, 'F');

    // Header with light blue background
    doc.setFillColor(12, 124, 206);
    doc.rect(0, 0, pageWidth, 20, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(16);
    doc.setFont('helvetica', 'bold');
    doc.text('PDF', pageWidth / 2, 14, { align: 'center' });

    // Receipt Details
    doc.setFontSize(10);
    doc.setFont('helvetica', 'normal');
    doc.setTextColor(0, 0, 0);
    const startY = 40;
    const leftMargin = 20;
    const rightMargin = 80;
    const lineHeight = 15;

    const details = [
      { label: 'signedBy', value: this.signedBy },
      { label: 'letterType', value: this.letterType },
      { label: 'wetSign', value: this.wetSign }
    ];

    details.forEach((item, index) => {
      const y = startY + index * lineHeight;
      doc.setFont('helvetica', 'bold');
      doc.text(item.label, leftMargin, y);
      doc.setFont('helvetica', 'normal');
      doc.text(item.value, rightMargin, y);
    });

    // Add a decorative element
    doc.setDrawColor(12, 124, 206);
    doc.setLineWidth(0.5);
    doc.line(leftMargin, startY + details.length * lineHeight + 5, pageWidth - leftMargin, startY + details.length * lineHeight + 5);

    try {
      doc.save('CustomerInvoice.pdf');
      console.log('PDF generated and saved.');
    } catch (error) {
      console.error('Error generating or previewing PDF:', error);
    }
  }

  @api
  generateApostilleHouseCertificate() {
    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();

    // Set font and color for the main heading (blue color)
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(18, 49, 134); // Blue color for heading
    doc.setFontSize(20);
    doc.text('Stephanie Thomas', 105, 20, { align: 'center' });
    doc.setFontSize(14);
    doc.text('Secretary of the State', 105, 27, { align: 'center' });

    // Reset font color to black for the rest of the content
    doc.setTextColor(0, 0, 0);

    // Create table with custom formatting
    const tableData = [
      [
        {
          content: 'APOSTILLE\n(Convention de La Haye du 5 octobre 1961)',
          colSpan: 2,
          styles: { fontStyle: 'bold', halign: 'center' }
        }
      ],
      [{ content: '1. Country:\n     País:', colSpan: 2 }],
      [
        {
          content: '2. has been signed by\n     ha sido firmado por',
          colSpan: 2
        }
      ],
      [
        {
          content: '3. acting in the capacity of\n     quien actúa en calidad de',
          colSpan: 2
        }
      ],
      [
        {
          content: '4. bears the seal / stamp of\n     y está revestido del sello / timbre de',
          colSpan: 2
        }
      ],
      [
        {
          content: 'Certified\nCertificado',
          colSpan: 2,
          styles: { fontStyle: 'bold', halign: 'center' }
        }
      ],
      [
        { content: '5. at Hartford, Connecticut\n    en', colSpan: 1 },
        { content: '6. the\n    el día', colSpan: 1 }
      ],
      [
        {
          content: '7. by\n     por Stephanie Thomas, Secretary of the State of Connecticut',
          colSpan: 2
        }
      ],
      [{ content: '8. Nº\n     bajo el número 2025 - xxxxx', colSpan: 2 }],
      [
        { content: '9. Seal / stamp:\n    Sello / timbre:', colSpan: 1 },
        { content: '10. Signature:\n       Firma:', colSpan: 1 }
      ]
    ];

    doc.autoTable({
      startY: 40,
      head: [],
      body: tableData,
      theme: 'plain',
      styles: {
        fontSize: 10,
        cellPadding: 5,
        textColor: [0, 0, 0],
        lineWidth: 0.1
      },
      columnStyles: {
        0: { cellWidth: 90 },
        1: { cellWidth: 90 }
      },
      didDrawCell: function (data) {
        var doc = data.doc;
        var rows = data.table.body;
        if (data.row.index === 0) {
          // Draw all borders for the first row (APOSTILLE)
          doc.rect(data.cell.x, data.cell.y, data.cell.width, data.cell.height, 'S');
        } else if (data.row.index === rows.length - 1 || data.row.index === 6) {
          // Draw vertical line between columns for the last row and row 7 (5/6)
          if (data.column.index === 0) {
            doc.line(data.cell.x + data.cell.width, data.cell.y, data.cell.x + data.cell.width, data.cell.y + data.cell.height);
          }
          // Draw horizontal lines for these rows
          doc.line(data.cell.x, data.cell.y, data.cell.x + data.cell.width, data.cell.y);
          if (data.row.index === rows.length - 1) {
            doc.line(data.cell.x, data.cell.y + data.cell.height, data.cell.x + data.cell.width, data.cell.y + data.cell.height);
          }
        } else {
          // For other rows, only draw horizontal lines
          doc.line(data.cell.x, data.cell.y, data.cell.x + data.cell.width, data.cell.y);
        }
        // Draw left and right borders of the table
        if (data.column.index === 0) {
          doc.line(data.cell.x, data.cell.y, data.cell.x, data.cell.y + data.cell.height);
        }
        if (data.column.index === data.table.columns.length - 1) {
          doc.line(data.cell.x + data.cell.width, data.cell.y, data.cell.x + data.cell.width, data.cell.y + data.cell.height);
        }
      }
    });

    // Add footer with lighter text
    const pageHeight = doc.internal.pageSize.height;
    doc.setFontSize(10);
    doc.setTextColor(150, 150, 150); // Grey color for footer text
    doc.text('This Apostille only certifies the signature, the capacity of the signer and the seal or stamp it bears.', 105, pageHeight - 20, { align: 'center' });
    doc.text('It does not certify the content of the document for which it was issued.', 105, pageHeight - 15, { align: 'center' });

    // Save the PDF
    doc.save('Apostille_Certificate.pdf');
  }

  @api
  generatePrintApostilleHouseCertificate() {
    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();

    // Set font and color for the main heading (blue color)
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(18, 49, 134); // Blue color for heading
    doc.setFontSize(20);
    doc.text('Stephanie Thomas', 105, 20, { align: 'center' });
    doc.setFontSize(14);
    doc.text('Secretary of the State', 105, 27, { align: 'center' });

    // Reset font color to black for the rest of the content
    doc.setTextColor(0, 0, 0);

    // Create table with custom formatting
    const tableData = [
      [
        {
          content: 'APOSTILLE\n(Convention de La Haye du 5 octobre 1961)',
          colSpan: 2,
          styles: { fontStyle: 'bold', halign: 'center' }
        }
      ],
      [{ content: '1. Country:\n     País:', colSpan: 2 }],
      [
        {
          content: '2. has been signed by\n     ha sido firmado por',
          colSpan: 2
        }
      ],
      [
        {
          content: '3. acting in the capacity of\n     quien actúa en calidad de',
          colSpan: 2
        }
      ],
      [
        {
          content: '4. bears the seal / stamp of\n     y está revestido del sello / timbre de',
          colSpan: 2
        }
      ],
      [
        {
          content: 'Certified\nCertificado',
          colSpan: 2,
          styles: { fontStyle: 'bold', halign: 'center' }
        }
      ],
      [
        { content: '5. at Hartford, Connecticut\n    en', colSpan: 1 },
        { content: '6. the\n    el día', colSpan: 1 }
      ],
      [
        {
          content: '7. by\n     por Stephanie Thomas, Secretary of the State of Connecticut',
          colSpan: 2
        }
      ],
      [{ content: '8. Nº\n     bajo el número 2025 - xxxxx', colSpan: 2 }],
      [
        { content: '9. Seal / stamp:\n    Sello / timbre:', colSpan: 1 },
        { content: '10. Signature:\n       Firma:', colSpan: 1 }
      ]
    ];

    doc.autoTable({
      startY: 40,
      head: [],
      body: tableData,
      theme: 'plain',
      styles: {
        fontSize: 10,
        cellPadding: 5,
        textColor: [0, 0, 0],
        lineWidth: 0.1
      },
      columnStyles: {
        0: { cellWidth: 90 },
        1: { cellWidth: 90 }
      },
      didDrawCell: function (data) {
        var doc = data.doc;
        var rows = data.table.body;
        if (data.row.index === 0) {
          // Draw all borders for the first row (APOSTILLE)
          doc.rect(data.cell.x, data.cell.y, data.cell.width, data.cell.height, 'S');
        } else if (data.row.index === rows.length - 1 || data.row.index === 6) {
          // Draw vertical line between columns for the last row and row 7 (5/6)
          if (data.column.index === 0) {
            doc.line(data.cell.x + data.cell.width, data.cell.y, data.cell.x + data.cell.width, data.cell.y + data.cell.height);
          }
          // Draw horizontal lines for these rows
          doc.line(data.cell.x, data.cell.y, data.cell.x + data.cell.width, data.cell.y);
          if (data.row.index === rows.length - 1) {
            doc.line(data.cell.x, data.cell.y + data.cell.height, data.cell.x + data.cell.width, data.cell.y + data.cell.height);
          }
        } else {
          // For other rows, only draw horizontal lines
          doc.line(data.cell.x, data.cell.y, data.cell.x + data.cell.width, data.cell.y);
        }
        // Draw left and right borders of the table
        if (data.column.index === 0) {
          doc.line(data.cell.x, data.cell.y, data.cell.x, data.cell.y + data.cell.height);
        }
        if (data.column.index === data.table.columns.length - 1) {
          doc.line(data.cell.x + data.cell.width, data.cell.y, data.cell.x + data.cell.width, data.cell.y + data.cell.height);
        }
      }
    });

    // Add footer with lighter text
    const pageHeight = doc.internal.pageSize.height;
    doc.setFontSize(10);
    doc.setTextColor(150, 150, 150); // Grey color for footer text
    doc.text('This Apostille only certifies the signature, the capacity of the signer and the seal or stamp it bears.', 105, pageHeight - 20, { align: 'center' });
    doc.text('It does not certify the content of the document for which it was issued.', 105, pageHeight - 15, { align: 'center' });

    // Save the PDF
    try {
      // Generate the PDF blob
      const pdfBlob = doc.output('blob');

      // Create a URL for the PDF blob
      this.pdfUrl = URL.createObjectURL(pdfBlob);

      // Dynamically create an iframe and set its src to the blob URL
      const anchor = document.createElement('a');
      console.log(this.pdfUrl);
      anchor.href = this.pdfUrl;
      anchor.target = '_blank';
      anchor.click();
      console.log('Letter PDF generated and downloaded.');
    } catch (error) {
      console.error('Error generating or downloading PDF:', error);
    }
  }

  @api
  async generateBatchPDF() {
    if (!window.jspdf) {
      console.error('jsPDF library not loaded');
      return;
    }
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();

    try {
      // Fetch batch data from server
      const batchData = await getBatchPDFData({ batchId: this.batchId });

      const pageWidth = doc.internal.pageSize.getWidth();

      // Set header
      doc.setFont('helvetica', 'normal');
      doc.setTextColor(18, 49, 134); // Blue color for heading
      doc.setFontSize(20);
      doc.text('Batch Details Report', pageWidth / 2, 20, { align: 'center' });

      doc.setFontSize(14);
      doc.setTextColor(0, 0, 0);
      doc.text('Basic Information', 14, 40);

      // Basic Info Table
      const basicInfoData = [
        ['Batch Name', batchData.batchName || 'N/A'],
        ['Created Date', batchData.createdDate || 'N/A'],
        ['Last Modified Date', batchData.lastModifiedDate || 'N/A'],
        ['Created By', batchData.createdBy || 'N/A'],
        ['Batch Status', batchData.batchStatus || 'N/A'],
        ['Transaction Count', batchData.transactionCount?.toString() || '0'],
        ['Transaction Amount', `$${batchData.transactionAmount?.toFixed(2) || '0.00'}`]
      ];

      // Updated basic info table with uniform styling
      doc.autoTable({
        startY: 45,
        body: basicInfoData,
        theme: 'grid',
        styles: {
          fontSize: 10,
          cellPadding: 5,
          fontStyle: 'normal',
          lineWidth: 0.1,
          lineColor: [0, 0, 0]
        },
        columnStyles: {
          0: { cellWidth: 80 },
          1: { cellWidth: 100 }
        }
      });

      // Transaction Details
      doc.setFontSize(14);
      doc.text('Transaction Details', 14, doc.lastAutoTable.finalY + 20);

      const transactionsHead = [['Last Name', 'First Name', 'Payment Type', 'Amount', 'Date']];
      const transactionsBody = batchData.fees.map((fee) => [
        fee.lastName || 'N/A',
        fee.firstName || 'N/A',
        fee.paymentType || 'N/A',
        `$${fee.amount?.toFixed(2) || '0.00'}`,
        fee.createdDate || 'N/A'
      ]);

      // Updated transaction details table with uniform styling
      doc.autoTable({
        startY: doc.lastAutoTable.finalY + 25,
        head: transactionsHead,
        body: transactionsBody,
        theme: 'grid',
        styles: {
          fontSize: 10,
          cellPadding: 5,
          fontStyle: 'normal',
          lineWidth: 0.1,
          lineColor: [0, 0, 0]
        },
        headStyles: {
          fillColor: [200, 200, 200],
          textColor: [0, 0, 0],
          fontStyle: 'normal'
        },
        columnStyles: {
          3: { halign: 'right' }
        }
      });

      const timestamp = new Date().toLocaleString();
      doc.setFontSize(10);
      doc.setTextColor(150, 150, 150);
      doc.text(`Generated on: ${timestamp}`, pageWidth - 14, doc.internal.pageSize.getHeight() - 10, {
        align: 'right'
      });

      const pdfBlob = doc.output('blob');

      this.pdfUrl = URL.createObjectURL(pdfBlob);

      const anchor = document.createElement('a');
      anchor.href = this.pdfUrl;
      anchor.download = `Batch_${batchData.batchName}_${batchData.createdDate}.pdf`;
      anchor.click();

      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Success',
          message: 'PDF generated successfully',
          variant: 'success'
        })
      );
    } catch (error) {
      console.error('Error generating PDF:', error);

      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: `Error generating PDF: ${error.body?.message || error.message || 'Unknown error'}`,
          variant: 'error'
        })
      );
    }
  }

  fetchDocDetails(recordId) {
    return new Promise((resolve, reject) => {
      console.log(`Fetching document details for recordId: ${recordId}`);

      getDocDetails({ recordId })
        .then((result) => {
          console.log('Raw result from getDocDetails:', JSON.stringify(result));

          // Directly use result instead of result.data
          if (result && result.documents && result.individualApplication) {
            this.documentsRequested = result.documents.map((doc) => {
              return {
                ...doc,
                fees: this.convertToUSD(doc.fees)
              };
            });

            this.individualApplication = result.individualApplication;

            this.customerName = result.individualApplication.organization || `${result.individualApplication.firstName} ${result.individualApplication.lastName}`;

            this.workOrderNumber = result.individualApplication.sequenceNumber;
            this.totalFee = this.convertToUSD(result.individualApplication.totalFees);

            if (result.individualApplication.expedited) {
              this.expediteFee = this.convertToUSD(result.individualApplication.expedited);
            }

            this.finalTotal = this.convertToUSD(result.individualApplication.finalTotal);

            this.error = undefined;

            console.log('Documents requested:', JSON.stringify(this.documentsRequested));
            console.log('Individual application details:', JSON.stringify(this.individualApplication));

            resolve();
          } else {
            console.error('Invalid result structure:', result);
            reject(new Error('Invalid result structure'));
          }
        })
        .catch((error) => {
          console.error('Error fetching document details:', error);
          this.error = error;
          this.documentsRequested = [];
          reject(error);
        });
    });
  }

  convertToUSD(amount) {
    if (amount === null || amount === undefined) {
      return '$0.00';
    }

    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2, // Ensures two decimal places
      maximumFractionDigits: 2
    }).format(amount);
  }

  @api
  async pdfForApostilleSuccess(type) {
    console.log('API method pdfForApostilleSuccess called with type:', type);
    return new Promise(async (resolve, reject) => {
      try {
        // Fetch data first
        console.log('Fetching document details...');
        await this.fetchDocDetails(this.individualApplicationId);
        console.log('Document details fetched successfully.');

        // Ensure data is loaded
        if (!this.documentsRequested || !this.individualApplication) {
          console.error('Document details not loaded');
          reject(new Error('Document details not loaded'));
          return;
        }

        if (!window.jspdf) {
          console.error('jsPDF library not loaded');
          return;
        }

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const pageWidth = doc.internal.pageSize.width;

        const marginLeft = 15;
        const marginRight = 15;
        const marginTop = 10;

        // Standardized styling
        const styles = {
          header: {
            fontSize: 18,
            fontStyle: 'bold',
            align: 'center'
          },
          subheader: {
            fontSize: 14,
            fontStyle: 'bold'
          },
          normalText: {
            fontSize: 10,
            fontStyle: 'normal'
          },
          tableHeader: {
            fillColor: [41, 128, 185],
            textColor: 255,
            fontStyle: 'bold',
            fontSize: 12
          }
        };

        // Reusable function to add header image with consistent positioning
        const addHeaderImage = async () => {
          try {
            const imageData = await getBase64Image({
              imageName: 'certificateImage'
            });
            const imageWidth = pageWidth - marginLeft - marginRight; 
            const imageHeight = (35 / 297) * pageWidth; 

            doc.addImage(imageData, 'PNG', marginLeft, marginTop, imageWidth, imageHeight);
            return marginTop + imageHeight + 8; 
          } catch (error) {
            console.error('Error loading header image:', error);
            return marginTop;
          }
        };

        // Function to add section header with consistent styling
        const addSectionHeader = (text, yPos) => {
          doc.setFontSize(styles.header.fontSize);
          doc.setFont('Verdana', styles.header.fontStyle);
          doc.text(text, pageWidth / 2, yPos, { align: styles.header.align });
          return yPos + 15;
        };

        function addWrappedText(doc, text, x, y, maxWidth, lineHeight) {
          const lines = doc.splitTextToSize(text, maxWidth);
          doc.text(lines, x, y);
          return y + lines.length * lineHeight;
        }

        /* ====================== PAGE 1: SUBMITTED DOCUMENTS ====================== */
        let yPosition = await addHeaderImage(); 
        console.log('Header added, starting to add content...');

        // Header Text
        yPosition = addSectionHeader('Apostille Submission', yPosition);
        console.log('Section header added.');

        // Intro Text
        doc.setFontSize(styles.normalText.fontSize);
        doc.setFont('Verdana', styles.normalText.fontStyle);


        // Use text wrapping for longer text
        const introText = 'Thank you, your apostille request has been successfully submitted. Below are the details of your request:';
        const maxWidth = pageWidth - marginLeft - marginRight;
        yPosition = addWrappedText(doc, introText, marginLeft, yPosition, maxWidth, 5);
        yPosition += 4;

        // Customer Info Table
        const customerInfoData = [
          ['Customer Name:', this.customerName || 'N/A'],
          ['Work Order Number:', this.workOrderNumber || 'N/A']
        ];

        doc.autoTable({
          body: customerInfoData,
          startY: yPosition,
          margin: { left: marginLeft, right: marginRight }, 
          styles: {
            font: 'Verdana',
            fontSize: styles.normalText.fontSize,
            cellPadding: 1
          },
          columnStyles: {
            0: { fontStyle: 'normal', halign: 'left', cellWidth: 35 },
            1: { fontStyle: 'bold', halign: 'left', cellWidth: 'auto' }
          },
          tableWidth: 'auto',
          theme: 'plain'
        });

        // Set position after the previous content
        yPosition = doc.lastAutoTable.finalY + 10;

        // Set bold font for the first line
        doc.setFont('Verdana', 'bold');
        // Use text wrapping for the bold instruction text
        const boldText = 'You must print and mail the submission document along with the documents to be authenticated.';
        yPosition = addWrappedText(doc, boldText, marginLeft, yPosition, maxWidth, 5);

        // Reset font to normal for the next lines
        doc.setFont('Verdana', styles.normalText.fontStyle);
        yPosition += 6;

        // Use text wrapping for each paragraph
        const paragraph1 = 'The status of this filing, including approval or rejection, can be viewed in the work queue associated with the account used to submit this filing.';
        yPosition = addWrappedText(doc, paragraph1, marginLeft, yPosition, maxWidth, 5);
        yPosition += 6;

        const paragraph2 =
          'I have read and agree to the terms of this online submission. I understand that I must print this application and send it to the Secretary of the State office along with the documents to be authenticated.*';
        yPosition = addWrappedText(doc, paragraph2, marginLeft, yPosition, maxWidth, 5);

        // Adjust yPosition for the next section
        yPosition += 10;

        // Ensure documentsRequested is defined and is an array
        if (!this.documentsRequested || !Array.isArray(this.documentsRequested)) {
          console.error('documentsRequested is undefined or not an array');
          return;
        }

        const tableDataHeader = ['Type of Document', 'Person Listed on the Document/Certified Copy Number', 'Destination Country', 'Hague Member', 'Fee'];

        // Replace with dynamic data
        const tableData = this.documentsRequested.map((doc) => [
          doc.documentType || 'N/A',
          doc.name || 'N/A',
          doc.country || 'N/A',
          doc.hagueStatus || 'N/A',
          doc.fees ? `${doc.fees}` : 'N/A' + (this.expediteFee ? ' (+ $50.00)' : '')
        ]);

        // Add row for total fee and expedite fee
        tableData.push([
          {
            content: `Total: ${this.totalFee || 'N/A'} (Expedite: ${this.expediteFee || 'N/A'})`,
            colSpan: 5,
            styles: { halign: 'right', fontStyle: 'normal' }
          }
        ]);

        // Documents Table
        doc.autoTable({
          head: [tableDataHeader],
          body: tableData,
          startY: yPosition,
          margin: { left: marginLeft, right: marginRight },
          styles: {
            font: 'Verdana',
            fontSize: styles.normalText.fontSize - 1, 
            cellPadding: 3,
            overflow: 'linebreak',
            minCellWidth: 10 // Ensure minimum cell width
          },
          headStyles: styles.tableHeader,
          columnStyles: {
            0: { cellWidth: 'auto' }, 
            1: { cellWidth: 'auto' }, 
            2: { cellWidth: 'auto' }, 
            3: { cellWidth: 'auto' }, 
            4: { cellWidth: 20, halign: 'right' } 
          },
          tableWidth: 'auto', 
          didDrawPage: async function (data) {
            // Add header to new pages created by autoTable
            if (data.pageCount > 1 && data.pageNumber > 1) {
              const savedY = data.cursor.y;
              data.cursor.y = await addHeaderImage(); 
              // Adjust cursor position to account for header
              data.cursor.y = savedY;
            }
          },
          willDrawCell: function (data) {
            // Ensure content fits in cells with wrapping
            if (data.cell.text && data.cell.text.length > 0) {
              const cellWidth = data.cell.width;
              data.cell.text = doc.splitTextToSize(data.cell.text.join(' '), cellWidth - 4);
            }
          }
        });

        /* ====================== PAGE 2: DOCUMENTS SUBMISSION REQUIREMENTS ====================== */
        // Always start on a new page
        doc.addPage();
        yPosition = await addHeaderImage(); 

        // Header
        yPosition = addSectionHeader('Document Submission Requirements', yPosition);

        doc.setFontSize(styles.normalText.fontSize);
        doc.setFont('Verdana', styles.normalText.fontStyle);
        doc.text('Documents submitted for legalization must meet certain standards. You should verify:', marginLeft, yPosition);
        yPosition += 8;

        // MOVED: Requirements list comes first now
        const requirementsList = [
          'The document(s) are issued by a Connecticut official or certified by a Connecticut Notary Public',
          'The document(s) must be properly notarized',
          'The document(s) contains an original signature and/or seal',
          'Print and include your Order Receipt. If you cannot print the receipt, please make certain to include your Work Order number with your document(s).'
        ];

        // Create bulleted list as a table for consistent formatting
        const requirementsData = requirementsList.map((item) => ['•', item]);

        doc.autoTable({
          body: requirementsData,
          startY: yPosition,
          margin: { left: marginLeft, right: marginRight },
          styles: {
            font: 'Verdana',
            fontSize: styles.normalText.fontSize,
            cellPadding: 2
          },
          columnStyles: {
            0: { cellWidth: 5 },
            1: { cellWidth: 'auto' }
          },
          theme: 'plain'
        });

        yPosition = doc.lastAutoTable.finalY + 10;
        
        // MOVED: Detailed content about document types comes after the requirements list
        doc.setFontSize(styles.normalText.fontSize);
        doc.setFont('Verdana', styles.normalText.fontStyle);
        
        const documentInfoText = 'Before you submit your document(s) you should ensure that it meets the requirements for legalization and was issued by the appropriate office or individual.';
        yPosition = addWrappedText(doc, documentInfoText, marginLeft, yPosition, maxWidth, 5);
        yPosition += 5;
        
        // Divorce Decrees section
        doc.setFont('Verdana', 'bold');
        const divorceTitle = 'Divorce Decrees and Orders Granting Custody';
        yPosition = addWrappedText(doc, divorceTitle, marginLeft, yPosition, maxWidth, 5);
        doc.setFont('Verdana', 'normal');
        
        const divorceText = 'Divorce decrees, orders granting custody, and other official documents related to family matters must be issued by the Court Clerk\'s Office.';
        yPosition = addWrappedText(doc, divorceText, marginLeft, yPosition, maxWidth, 5);
        yPosition += 5;
        
        // Other Judgments section
        doc.setFont('Verdana', 'bold');
        const judgmentsTitle = 'Other Judgments and Orders';
        yPosition = addWrappedText(doc, judgmentsTitle, marginLeft, yPosition, maxWidth, 5);
        doc.setFont('Verdana', 'normal');
        
        const judgmentsText = 'Judgments, orders, or other official documents issued by any court in Connecticut must be certified by that court to be legalized. You can request a certified copy of your record from the court.';
        yPosition = addWrappedText(doc, judgmentsText, marginLeft, yPosition, maxWidth, 5);
        yPosition += 5;
        
        // Probate Records section
        doc.setFont('Verdana', 'bold');
        const probateTitle = 'Probate Records';
        yPosition = addWrappedText(doc, probateTitle, marginLeft, yPosition, maxWidth, 5);
        doc.setFont('Verdana', 'normal');
        
        const probateText = 'Judgments, orders, or other official records must be certified by the probate court in the Connecticut city or town where the probate action was taken.';
        yPosition = addWrappedText(doc, probateText, marginLeft, yPosition, maxWidth, 5);
        yPosition += 5;
        
        // Notaries section - italic
        doc.setFont('Verdana', 'italic');
        const notariesText = 'Notaries public are not empowered to notarize or copy certify court records or vital records.';
        yPosition = addWrappedText(doc, notariesText, marginLeft, yPosition, maxWidth, 5);
        doc.setFont('Verdana', 'normal');
        yPosition += 10;

        // Updated Mailing Information Table based on Image 3
        const mailingInfoHeader = [['Preferred Method', 'Mailing Address']];
        const mailingInfoData = [
          [
            'Hand delivery of original document(s), or send via FedEx, UPS, or DHL:',
            'Secretary of the State, Authentications and Apostille Unit, 165 Capitol Avenue Suite 1000, Hartford, CT 06106'
          ],
          [
            'First Class or Priority Mail through the US Postal Service:',
            'Secretary of the State, Authentications and Apostille Unit, P.O. Box 150470, Hartford, CT 06115-0470'
          ]
        ];

        doc.autoTable({
          head: mailingInfoHeader,
          body: mailingInfoData,
          startY: yPosition,
          margin: { left: marginLeft, right: marginRight },
          styles: {
            font: 'Verdana',
            fontSize: styles.normalText.fontSize,
            cellPadding: 5,
            overflow: 'linebreak'
          },
          headStyles: styles.tableHeader,
          columnStyles: {
            0: { cellWidth: 'auto' },
            1: { cellWidth: 'auto' }
          }
        });

        /* ====================== PAGE 3: PAYMENT RECEIPT ====================== */
        if (this.paymentMethod === 'Card'|| 
        this.paymentMethod === 'Credit Card' ||  
        this.paymentMethod === 'card') {
          // Always start on a new page
          doc.addPage();
          yPosition = await addHeaderImage(); 

          // Header Text with same font and sizing as the first method
          doc.setFontSize(15);
          doc.setFont('Verdana', 'bold');
          doc.text('PAYMENT RECEIPT', pageWidth / 2, yPosition, {
            align: 'center'
          });
          yPosition += 15;

          // Use the exact same approach for payment details
          doc.setFontSize(10);
          doc.setFont('Verdana', 'normal');

          const details = [
            { label: 'Work Order#:', value: this.workOrderNumber || 'N/A' },
            { label: 'Total Amount Paid:', value: this.price ? `$${this.price}` : 'N/A' },
            { label: 'Payment Method:', value: this.paymentMethod || 'N/A' },
            { label: 'Auth Code:', value: this.authCode || 'N/A' },
            { label: 'Date of Payment:', value: this.paymentDate ? new Date(this.paymentDate).toLocaleDateString('en-US') : 'N/A' },
            { label: 'Card Type:', value: this.cardName || 'N/A' },
            { label: 'Card Last 4 Digits:', value: this.cardLastDigit || 'N/A' }
          ];

          let startY = yPosition;
          const lineHeight = 10;
          const leftMargin = marginLeft + 5;
          const rightMargin = pageWidth - marginRight - 50;

          details.forEach((item, i) => {
            const y = startY + i * lineHeight;
            doc.setFont('helvetica', 'bold');
            doc.text(item.label, leftMargin, y);
            doc.setFont('helvetica', 'normal');
            doc.text(item.value, rightMargin, y);
          });

          // Update yPosition for potential next section
          yPosition = startY + details.length * lineHeight + 10;

          console.log('Payment Receipt page added for Card payment with matching styling.');
        }

        // Save PDF
        if (type === 'email') {
          const pdfBlob = doc.output('blob');
          console.log('PDF blob created for email.');
          resolve(pdfBlob);
        } else if (type == 'download') {
          doc.save('CustomerSubmittedDocument.pdf');
          console.log('PDF saved for download.');
          resolve();
        }
      } catch (error) {
        console.error('Error generating or saving PDF:', error);
        reject(error);
      }
    });
  }
}
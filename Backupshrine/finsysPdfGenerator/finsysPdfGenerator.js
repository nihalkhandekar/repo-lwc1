import { LightningElement, api } from 'lwc';
import jsPDF from '@salesforce/resourceUrl/pdfGenerator';
import jsPdfAutotable from '@salesforce/resourceUrl/jsPdfAutotable';
import { loadScript } from 'lightning/platformResourceLoader';
import getBase64Image from '@salesforce/apex/ApostilleLetterController.getBase64Image';
import getEmailData from '@salesforce/apex/finsysWorkOrderTransactionController.getEmailData';

export default class finsysPdfGenerator extends LightningElement {
    @api recordId;
    jsPdfInitialized = false;

    renderedCallback() {
        if (this.jsPdfInitialized) {
            return;
        }
        loadScript(this, jsPDF)
            .then(() => {
                console.log('jsPDF loaded successfully.');

                // Now load jsPdfAutotable after jsPDF is loaded
                return loadScript(this, jsPdfAutotable);
            })
            .then(() => {
                console.log('jsPdfAutotable loaded successfully.');
                this.jsPdfInitialized = true;
            })
            .catch(error => {
                console.error('Error loading jsPDF or jsPdfAutotable:', error);
            });
    }

    async generatePdfPaymentInvoice(type) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library not loaded or initialized.');
            return;
        }

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        let yPosition = 10;
        const pageWidth = doc.internal.pageSize.getWidth();

        try {
            // Fetch data from Apex
            const jsonRequest = JSON.stringify({ recordId: this.recordId });
            const response = await getEmailData({ jsonRequest });

            if (response) {
                const userInfo = response.userInfo;
                const mappedTransactions = response.mappedTransactions;

                // Add Header Image
                try {
                    const imageData = await getBase64Image({ imageName: 'certificateImage' });
                    const imageWidth = pageWidth - marginLeft - marginRight;
                    const imageHeight = (35 / 297) * pageWidth; // Adjust height for aspect ratio
                    doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                    yPosition += imageHeight + 10; // Add padding below the image
                } catch (error) {
                    console.error('Error loading header image:', error);
                }

                // Add Header
                doc.setFontSize(16);
                doc.setFont('helvetica', 'bold');
                doc.text('PAYMENT RECEIPT', pageWidth / 2, yPosition, { align: 'center' });
                yPosition += 15;

                // Add Work Order Details
                const totalAmount = mappedTransactions.reduce((sum, item) => sum + (item.feeAmount || 0), 0).toFixed(2);
                const uniquePaymentMethods = [...new Set(mappedTransactions.map(item => item.paymentType))].join(', ');
                const authCodes = [...new Set(mappedTransactions.map(item => item.authCode).filter(code => code))].join(', ');
                console.log(authCodes);

                const paymentIds = [...new Set(mappedTransactions.map(item => item.paymentUId || 'N/A'))].join(', ');
                console.log(paymentIds);
                
                const appliedDate = [...new Set(mappedTransactions.map(item => item.createdDate))].join(', ');
                const createdBy = [...new Set(mappedTransactions.map(item => item.createdBy))].join(', ');

                const details = [
                    { label: 'Work Order#', value: userInfo.workOrderNo },
                    { label: 'Total Amount Paid', value: `$${totalAmount}` },
                    { label: 'Payment Method', value: uniquePaymentMethods },
                    { label: 'Date of Payment', value: appliedDate },
                    { label: 'Staff Name', value: createdBy },
                ];

                doc.setFontSize(12);
                details.forEach(detail => {
                    doc.setFont('helvetica', 'bold');
                    doc.text(`${detail.label}:`, marginLeft, yPosition);
                    doc.setFont('helvetica', 'normal');
                    doc.text(detail.value, marginLeft + 50, yPosition); // Adjust for label-value alignment
                    yPosition += 8;
                });
                yPosition += 5;

                // Add Table
                if (typeof doc.autoTable === 'function') {
                    const tableHeaders = ['Payment Type', 'Activity', 'Sub-Activity', 'Fee Amount'];
                    const tableBody = mappedTransactions.map(tx => [
                        tx.paymentType || 'N/A',
                        tx.activity || 'N/A',
                        tx.subActivity || 'N/A',
                        `$${(tx.feeAmount || 0).toFixed(2)}`,
                    ]);

                    doc.autoTable({
                        startY: yPosition,
                        head: [tableHeaders],
                        body: tableBody,
                        margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                        styles: { fontSize: 10 },
                    });

                    yPosition = doc.lastAutoTable.finalY + 10;
                } else {
                    console.error('autoTable plugin not initialized.');
                }

                // Save or Email PDF
                const pdfBlob = doc.output('blob');
                if (type === 'email') {
                    console.log(pdfBlob);
                    return pdfBlob;
                } else {
                    const pdfUrl = URL.createObjectURL(pdfBlob);
                    if (type === 'print') {
                        window.open(pdfUrl, '_blank');
                    } else {
                        const anchor = document.createElement('a');
                        anchor.href = pdfUrl;
                        anchor.download = `${userInfo.workOrderNo}_PaymentReceipt.pdf`;
                        anchor.click();
                    }
                }
            } else {
                console.error('No response received from Apex.');
            }
        } catch (error) {
            console.error('Error generating PDF:', error);
        }
    }



    @api
    generatePaymentInvoice(recordId, type) {
        this.recordId = recordId;
        const blob = this.generatePdfPaymentInvoice(type);
        if(blob){
            return blob;
        }else{
            return null;
        }


    }
}
import { LightningElement, api, track } from 'lwc';
import jsPDF from '@salesforce/resourceUrl/sap_pdfGenerator';
import { loadScript } from 'lightning/platformResourceLoader';
import fetchEnvelopeData from '@salesforce/apex/SAP_PrintDocumentController.fetchEnvelopeData';
import fetchLetterData from '@salesforce/apex/SAP_PrintDocumentController.fetchLetterData';
import getSignedByDetails from '@salesforce/apex/SAP_SignedByController.getSignedByDetails';
import getDefaultSignedByDetails from '@salesforce/apex/SAP_SignedByController.getDefaultSignedByDetails';
import getDetailsforExtradictionReceiptPdf from '@salesforce/apex/SAP_ExtraditionRequestController.getDetailsforExtradictionReceiptPdf';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadPdfToIndividualApp from '@salesforce/apex/SAP_PdfUploadController.uploadPdfToIndividualApp';

export default class PdfGenerator extends LightningElement {

    @api isAlternateContent = false;
    @api extradictionRequestId;
    @api recordId;
    jsPdfInitialized = false;
    @track name;
    @track street;
    @track city;
    @track state;
    @track postalCode;
    @track dateOfSOTSResponse; // Date of SOTS response
    @track requestFor;    // Request for field (Re: section)
    @track letterText;    // Main body of the letter (Letter Text)
    @track letterType;
    @track reason;
    @track status_record;
    @track lastName;
    @track wetSignature;
    @track signedBy;
    @track disposition;
    @track esq = false;
    @track title = '';
    @track entity = '';
     // Signer Data Fields (selected staff member)
    @track signerFirstName;
    @track signerLastName;
    @track signerTitle;
    @track signerDivision;
    @track signerPhone;
    @track signerSignatureFileId;

      // Default Signer Data Fields (e.g., Secretary of the State)
    @track defaultSignerFirstName;
    @track defaultSignerLastName;
    @track defaultSignerTitle;
    @track defaultSignerSignatureFileId;

    @track letterTypeExtradition;
    @track wetsignExtradition;
    @track positionExtradition;
    @track signedbyExtradition;
    @track districtExtradition;
    @track fullnameExtradition;
    @track countryExtradition;
    @track officialRecordId;

    @track type = '';


    renderedCallback() {
        if (this.jsPdfInitialized) {
            return;
        }
        loadScript(this, jsPDF)
            .then(() => {
                this.jsPdfInitialized = true;
            })
            .catch(error => {
                console.error('Error loading jsPDF library:', error);
            });
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
        const entityName = this.title || '';
        //const entity = this.entity || '';
        const streetAddress = this.street || '';
        const cityStatePostal = `${this.city || ''}, ${this.state || ''} ${this.postalCode || ''}`;

        // Name of the recipient
        doc.text(recipientName, startX, startY);

        // Conditionally add the entity line if it has a value
        let currentY = startY + 5;
        if (entityName) {
            doc.text(entityName, startX, currentY);
            currentY += 5; // Increment Y position only if entity is printed
        }

        // Address (remove extra spacing between lines)
        doc.text(streetAddress, startX, currentY); // Adjusted gap between lines for a compact look
        doc.text(cityStatePostal, startX, currentY + 5);



        try {
            // Generate the PDF blob for download
            const pdfBlob = doc.output('blob');
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = this.name + '_Envelope.pdf';
            anchor.click();
        } catch (error) {
            console.error('Error generating or downloading PDF:', error);
        }
    }

    @api
    generateEnvelope(recordId) {
        this.recordId = recordId;

        // Fetch data for envelope from Apex
        fetchEnvelopeData({ recordId: this.recordId })
            .then((data) => {
                this.name = data.name;
                this.street = data.street;
                this.city = data.city;
                this.state = data.state ? data.state.toUpperCase() : '';
                this.postalCode = data.postalCode;
                this.entity = data.organizationName ? data.organizationName.toUpperCase() : '';
                this.title = data.title ? data.title.toUpperCase() : '';
                this.esq = data.esq;
                this.dataLoaded = true;

                // Format the display name based on Esq and Title
                if (this.esq && this.entity) {
                    this.name = `${this.name},  Esq., ${this.entity}`;
                } else if (this.esq) {
                    this.name = `${this.name},  Esq.`;
                } else if (this.entity) {
                    this.name = `${this.name}, ${this.entity}`;
                } else {
                    this.name = `${this.name}`;
                }

                this.generatePdfForEnvelope();
            })
            .catch(error => {
                console.error('Error fetching envelope data:', error);
            });
    }

    @api
    viewGenerateEnvelope(recordId) {
        this.recordId = recordId;

        // Fetch data for envelope from Apex
        fetchEnvelopeData({ recordId: this.recordId })
            .then((data) => {
                this.name = data.name;
                this.street = data.street;
                this.city = data.city;
                this.state = data.state ? data.state.toUpperCase() : '';
                this.postalCode = data.postalCode;
                this.entity = data.organizationName ? data.organizationName.toUpperCase() : '';
                this.title = data.title ? data.title.toUpperCase() : '';
                this.esq = data.esq;
                this.dataLoaded = true;

                // Format the display name based on Esq and Title
                if (this.esq && this.entity) {
                    this.name = `${this.name},  Esq., ${this.entity}`;
                } else if (this.esq) {
                    this.name = `${this.name},  Esq.`;
                } else if (this.entity) {
                    this.name = `${this.name}, ${this.entity}`;
                } else {
                    this.name = `${this.name}`;
                }

                this.generatePdfForEnvelope();
            })
            .catch(error => {
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
        const dateObj = new Date(dateString);  // Convert the string to a Date object
        const options = { year: 'numeric', month: 'long', day: 'numeric', timeZone: 'UTC' };  // Specify UTC for consistent output
        return dateObj.toLocaleDateString('en-US', options);  // Output in "Month Day, Year" format
    }


    generatePdfForLetter() {
        return new Promise((resolve, reject) => {
            if (!window.jspdf) {
                console.error('jsPDF library not loaded');
                reject('jsPDF library not loaded');
                return;
            }

            try {
                const { jsPDF } = window.jspdf;
                const doc = new jsPDF();
                const pageWidth = doc.internal.pageSize.getWidth();
                const pageHeight = doc.internal.pageSize.getHeight();
                let margin = 20;  // Set left and right margin
                let currentY = 50;  // Initial Y position for the first line

                // Helper function to check space and add a new page if needed
                const checkPageSpace = (requiredHeight) => {
                    if (currentY + requiredHeight > pageHeight) {
                        doc.addPage();
                        currentY = 25; // Reset Y position for new page
                    }
                };

                // Set font to Helvetica, normal
                doc.setFont('helvetica', 'normal');
                doc.setFontSize(10);

                // Date (Date of SOTS Response)
                const dateOfSOTS = this.dateOfSOTSResponse ? this.formatDateToLongDate(this.dateOfSOTSResponse) : '';
                checkPageSpace(10);
                doc.text(dateOfSOTS, margin, currentY);
                currentY += 10; // Move Y position down

                // Recipient Name and Address
                const recipientName = this.name || '';
                const streetAddress = this.street || '';
                const cityStatePostal = `${this.city || ''}, ${this.state || ''} ${this.postalCode || ''}`;
                const lastName = this.lastName || '';

                checkPageSpace(20);
                doc.text(recipientName, margin, currentY);
                currentY += 5; // Move Y position down
                doc.text(streetAddress, margin, currentY);
                currentY += 5;
                doc.text(cityStatePostal, margin, currentY);
                currentY += 10;

                // "Re:" section (Request For field)
                const requestFor = this.requestFor || '';
                doc.setFont('helvetica', 'bold');
                checkPageSpace(10);
                doc.text(`Re: ${requestFor}`, margin, currentY);
                currentY += 10;

                // Reset font to normal for the body
                doc.setFont('helvetica', 'normal');
                checkPageSpace(10);
                doc.text(`Dear ${lastName},`, margin, currentY);
                currentY += 10;

                // Letter Body Text (letterText field)
                const letterText = this.letterText || '';
                const letterTextLines = doc.splitTextToSize(letterText, pageWidth - margin * 2);
                const letterTextHeight = letterTextLines.length * 5; // Approximate height per line
                checkPageSpace(letterTextHeight + 10);
                doc.text(letterTextLines, margin, currentY);
                currentY += letterTextHeight + 5;

                // Insert additional content based on letter type
                let additionalText = '';
                if (this.letterType === 'Official Business' || this.letterType === 'Educational' || this.letterType === 'Memorial' || this.letterType === 'Constitution and Laws') {
                    additionalText = this.stateSealApprovedOfficialNotice();
                } else if (this.letterType === 'Non-Standard') {
                    additionalText = this.stateSealApprovedNonStandardLetter();
                } else if (this.letterType === 'Denial (short)') {
                    additionalText = this.stateSealDenialShortNotice();
                } else if (this.letterType === 'Denial (long)') {
                    additionalText = this.stateSealDenialLongNotice();
                } else {
                    alert('Cannot Print Document Letter Type is Missing');
                    console.error('Cannot Print Document for request InProgress!');
                    reject('Letter type is missing.');
                    return;
                }

                if (additionalText) {
                    const additionalTextLines = doc.splitTextToSize(additionalText, pageWidth - margin * 2);
                    const additionalTextHeight = additionalTextLines.length * 5; // Approximate height per line
                    checkPageSpace(additionalTextHeight + 2);
                    doc.text(additionalTextLines, margin, currentY);
                    currentY += additionalTextHeight + 2;
                }

                // "Sincerely" section
                checkPageSpace(50);
                doc.setFont('helvetica', 'normal');
                doc.setFontSize(10);
                doc.text('Sincerely,', margin, currentY);
                currentY += 3;  // Reduced space after "Sincerely" to bring it closer to the name

                // Signature logic based on wetSignature value
                if (this.wetSignature === 'Yes') {
                    currentY += 20;  // Reduced space for handwritten signature
                } else {
                    checkPageSpace(25);
                    doc.addImage(this.defaultSignerSignatureFileId, 'PNG', margin, currentY, 50, 20); // Adjust dimensions as needed
                    currentY += 25;
                }

                // Secretary of the State section
                checkPageSpace(10);
                doc.text(`${this.defaultSignerFirstName} ${this.defaultSignerLastName}`, margin, currentY);
                currentY += 5;
                doc.text(`${this.defaultSignerTitle}`, margin, currentY);
                currentY += 3;  // Increased space between title and "By" section
                if (this.wetSignature === 'Yes') {
                    currentY += 20;  // Reduced space for handwritten signature
                } else {
                    checkPageSpace(25);
                    doc.addImage(this.signerSignatureFileId, 'PNG', margin, currentY, 50, 20); // Adjust dimensions as needed
                    currentY += 25;
                }

                // "By" section for the selected staff member
                checkPageSpace(20);
                doc.text(`By: ${this.signerFirstName} ${this.signerLastName}`, margin, currentY);
                currentY += 5;
                margin += 5;
                doc.text(`${this.signerTitle}`, margin, currentY);
                currentY += 5;
                doc.text(`${this.signerDivision}`, margin, currentY); // Signer's Division
                currentY += 5;
                doc.text(`${this.signerPhone}`, margin, currentY);    // Signer's Phone number

                // Final PDF generation
                const pdfBlob = doc.output('blob');

                if (this.type === 'print') {
                    const pdfUrl = URL.createObjectURL(pdfBlob);
                    const anchor = document.createElement('a');
                    anchor.href = pdfUrl;
                    anchor.download = `${this.name}_${this.letterType}.pdf`;
                    anchor.click();
                    resolve();
                } else if (this.type === 'email') {
                    this.uploadPdfToSalesforce(pdfBlob)
                        .then((contentDocumentId) => {
                            resolve(contentDocumentId);
                        })
                        .catch((error) => {
                            console.error('Error uploading PDF to Salesforce:', error);
                            reject(error);
                        });
                } else {
                    console.error('Invalid type provided. Cannot generate PDF.');
                    reject('Invalid type provided.');
                }
            } catch (error) {
                console.error('Error generating or downloading PDF:', error);
                reject(error);
            }
        });
    }







    uploadPdfToSalesforce(pdfBlob) {
        console.log('Inside uploadPdtToSalesforce');
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = async () => {
                const base64Data = reader.result ? reader.result.split(',')[1] : null;
                const fileName = `${this.name}_${this.letterType}.pdf`;

                if (!base64Data) {
                    console.error('Failed to convert PDF to base64.');
                    reject('Failed to convert PDF to base64.');
                    return;
                }

                try {
                    // const fileInfo = { base64: base64Data, filename: fileName };
                    //const contentDocumentId = await uploadSingleFile({ fileInfo: fileInfo, recordId: this.recordId });
                    const contentDocumentId = await uploadPdfToIndividualApp({ fileName: fileName, base64Data: base64Data, linkedEntityId: this.recordId });
                    resolve(contentDocumentId);
                } catch (error) {
                    console.error('Error uploading PDF to Salesforce:', error.body ? error.body.message : error);
                    reject(error);
                }
            };
            reader.onerror = (e) => {
                console.error('FileReader error:', e);
                reject(e);
            };
            reader.readAsDataURL(pdfBlob);
        });
    }

    uploadPdfExtraditionRequest(pdfBlob, extradiReqId) {
        this.recordId = extradiReqId;
        console.log('Inside uploadPdtToSalesforce');
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = async () => {
                const base64Data = reader.result ? reader.result.split(',')[1] : null;
                const fileName = 'extraditionRequestReceipt.pdf';

                if (!base64Data) {
                    console.error('Failed to convert PDF to base64.');
                    reject('Failed to convert PDF to base64.');
                    return;
                }

                try {
                    // const fileInfo = { base64: base64Data, filename: fileName };
                    //const contentDocumentId = await uploadSingleFile({ fileInfo: fileInfo, recordId: this.recordId });
                    const contentDocumentId = await uploadPdfToIndividualApp({ fileName: fileName, base64Data: base64Data, linkedEntityId: this.recordId});
                    resolve(contentDocumentId);
                } catch (error) {
                    console.error('Error uploading PDF to Salesforce:', error.body ? error.body.message : error);
                    reject(error);
                }
            };
            reader.onerror = (e) => {
                console.error('FileReader error:', e);
                reject(e);
            };
            reader.readAsDataURL(pdfBlob);
        });
    }

    @api
    async generateLetter(recordId, letterType, wetSignature, signedBy, type) {
        this.recordId = recordId;
        this.wetSignature = wetSignature;
        this.signedBy = signedBy;
        this.letterType = letterType;
        this.type = type;

        // Validate required input fields
        if (!this.wetSignature) {
            this.showToast('Error', 'Please select letterType', 'error');
            return;
        }
        // Validate required input fields
        if (!this.wetSignature) {
            this.showToast('Error', 'Please select wetSignature', 'error');
            return;
        }

        try {
            // Fetch data for the letter from Apex
            const data = await fetchLetterData({ recordId: this.recordId });

            this.name = data.name;
            this.lastName = data.lastName;
            this.street = data.street;
            this.city = data.city;
            this.state = data.state ? data.state.toUpperCase() : '';
            this.postalCode = data.postalCode;
            this.entity = data.organizationName ? data.organizationName.toUpperCase() : '';
            this.title = data.title ? data.title.toUpperCase() : '';
            this.dateOfSOTSResponse = data.dateOfSOTSResponse;
            this.requestFor = data.requestFor;
            this.letterText = data.letterText;
            this.reason = data.reason;
            this.esq = data.esq;
            console.log(data);



            // Format the display name based on Esq and Title
            if (this.esq && this.entity) {
                this.name = `${this.name},  Esq., ${this.entity}`;
            } else if (this.esq) {
                this.name = `${this.name},  Esq.`;
            } else if (this.entity) {
                this.name = `${this.name}, ${this.entity}`;
            } else {
                this.name = `${this.name}`;
            }

            // Fetch the selected signer details
            const staffData = await getSignedByDetails({ contactId: this.signedBy });
            if(staffData == null){
                this.showToast('Error', 'Please select a official', 'error');
            return;
            }
            this.signerFirstName = staffData.firstName;
            this.signerLastName = staffData.lastName;
            this.signerTitle = staffData.staffTitle;
            this.signerDivision = staffData.division;
            this.signerPhone = staffData.phone;
            this.signerSignatureFileId = staffData.signatureBase64;
            // Validate required input fields
            if(this.wetSignature == 'No'){
                if (!this.signerSignatureFileId) {
                    this.showToast('Error', 'Please upload Signature for the selected Official', 'error');
                    return;
                }
            }

            // Fetch the default signer details
            const defaultStaffData = await getDefaultSignedByDetails();
            if(defaultStaffData == null){
                this.showToast('Error', 'Please set a Default official', 'error');
            return;
            }
            this.defaultSignerFirstName = defaultStaffData.firstName;
            this.defaultSignerLastName = defaultStaffData.lastName;
            this.defaultSignerTitle = defaultStaffData.staffTitle;
            this.defaultSignerSignatureFileId = defaultStaffData.signatureBase64;

            // Validate required input fields
            if(this.wetSignature == 'No'){
            if (!this.defaultSignerSignatureFileId) {
                this.showToast('Error', 'Please upload Signature for the default Official', 'error');
                return;
            }
        }

            // Generate the PDF and return the result
            return await this.generatePdfForLetter(); // Call the method without parameters
        } catch (error) {
            console.error('Error in generateLetter:', error);
            throw error;
        }
    }

    @api
    async viewGenerateLetter(recordId, type) {
        this.recordId = recordId;
        this.type = type;

        try {
            // Fetch data for the letter from Apex
            const data = await fetchLetterData({ recordId: this.recordId });

            // Assign fetched data to component's variables
            this.name = data.name;
            this.lastName = data.lastName;
            this.street = data.street;
            this.city = data.city;
            this.state = data.state ? data.state.toUpperCase() : '';
            this.postalCode = data.postalCode;
            this.dateOfSOTSResponse = data.dateOfSOTSResponse;
            this.requestFor = data.requestFor;
            this.disposition = data.disposition;
            this.letterText = data.letterText;
            this.letterType = data.letterType;
            this.signedBy = data.signedBy;
            this.wetSignature = data.wetSignature;
            this.reason = data.reason;
            this.esq = data.esq;
            this.entity = data.organizationName ? data.organizationName.toUpperCase() : '';
            this.title = data.title ? data.title.toUpperCase() : '';

             // Format the display name based on Esq and Title
             if (this.esq && this.entity) {
                this.name = `${this.name},  Esq., ${this.entity}`;
            } else if (this.esq) {
                this.name = `${this.name},  Esq.`;
            } else if (this.entity) {
                this.name = `${this.name}, ${this.entity}`;
            } else {
                this.name = `${this.name}`;
            }

            // Validate required input fields
            if (this.disposition === 'Pending') {
                this.showToast('Info', 'Letter cannot be generated for pending status', 'errinfoor');
                return;
            }
            if (!this.letterType) {
                this.showToast('Error', 'Please select Letter Type', 'error');
                return;
            }

            if (!this.wetSignature) {
                this.showToast('Error', 'Please select Wet Signature', 'error');
                return;
            }

            if (!this.signedBy) {
                this.showToast('Error', 'Please select Signed By official', 'error');
                return;
            }

            // Step 2: Fetch the selected signer details
            const staffData = await getSignedByDetails({ contactId: this.signedBy });

            // Handle error for missing staff data
            if (staffData == null) {
                this.showToast('Error', 'Please select an official', 'error');
                return;
            }

            // Assign signer details dynamically
            this.signerFirstName = staffData.firstName;
            this.signerLastName = staffData.lastName;
            this.signerTitle = staffData.staffTitle;
            this.signerDivision = staffData.division;
            this.signerPhone = staffData.phone;
            this.signerSignatureFileId = staffData.signatureBase64;

            if(this.wetSignature == 'No'){
                if (!this.signerSignatureFileId) {
                    this.showToast('Error', 'Please upload Signature for the selected Official', 'error');
                    return;
                }
            }

            // Step 3: Fetch the default signer details
            const defaultStaffData = await getDefaultSignedByDetails();

            // Handle error for missing default staff data
            if (defaultStaffData == null) {
                this.showToast('Error', 'Please set a Default official', 'error');
                return;
            }

            // Assign default signer details
            this.defaultSignerFirstName = defaultStaffData.firstName;
            this.defaultSignerLastName = defaultStaffData.lastName;
            this.defaultSignerTitle = defaultStaffData.staffTitle;
            this.defaultSignerSignatureFileId = defaultStaffData.signatureBase64;

            // Validate required input fields
            if(this.wetSignature == 'No'){
                if (!this.defaultSignerSignatureFileId) {
                    this.showToast('Error', 'Please upload Signature for the default Official', 'error');
                    return;
                }
            }

            // Proceed to generate the PDF once both the signer and default staff details are fetched
            return await this.generatePdfForLetter();
        } catch (error) {
            console.error('Error fetching letter data:', error);
            this.showToast('Error', 'Error fetching letter data: ' + error.message, 'error');
        }
    }

    // Helper function to show toast messages
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }



    @api
async stateExtraditionPdfGenerator(config) {
    const {
        recordId = '',
        fullName = '',
        signedBy = '',
        judicialDistrict = '',
        letterType = '',
        wetSign = '',
        position = '',
        country = ''
    } = config;

    this.fullnameExtradition = fullName;
    this.signedbyExtradition = signedBy;
    this.districtExtradition = judicialDistrict;
    this.letterTypeExtradition = letterType;
    this.wetsignExtradition = wetSign;
    this.positionExtradition = position;
    this.countryExtradition = country;
    this.officialRecordId = recordId;

    if (letterType === "Apostille no Term" ||
        letterType === "Apostille with Term" ||
        letterType === "Career State's Attorney Apostille") {
        return await this.generateLetterTypeApostille();
    } else {
        return await this.generateLetterTypeExtradition();
    }
}

    async generateLetterTypeExtradition() {
        if (!window.jspdf) {
            console.error('jsPDF library not loaded');
            return;
        }

        await this.fetchSignerDetails();

        const today = new Date();
        const formattedDate = today.toLocaleDateString('en-US', {
            month: 'long',
            day: 'numeric',
            year: 'numeric',
        });

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF({
            unit: 'mm',
            format: 'letter'
        });

        const pageWidth = doc.internal.pageSize.getWidth();
        const leftMargin = 30;
        const rightMargin = 30;
        const paragraphWidth = pageWidth - leftMargin - rightMargin;

        const drawHeader = () => {
            doc.setFont('Roboto', 'bold');
            doc.setFontSize(14);
            doc.text('STATE OF CONNECTICUT', 105, 60, { align: 'center' });
            doc.text('OFFICE OF THE SECRETARY OF THE STATE', 105, 65, { align: 'center' });
        };

        const drawContent = (content) => {
            doc.setFont('Roboto', 'normal');
            doc.setFontSize(12);
            let yPos = 85;
            const paragraphSpacing = 2;
            const firstLineIndent = 10;
            const subsequentLineIndent = 0;

            content.forEach(paragraph => {
                const wrappedText = doc.splitTextToSize(paragraph, paragraphWidth);
                if (wrappedText.length > 0) {
                    doc.text(wrappedText[0], leftMargin + firstLineIndent, yPos);
                    yPos += 5.5;
                    for (let i = 1; i < wrappedText.length; i++) {
                        doc.text(wrappedText[i], leftMargin + subsequentLineIndent, yPos);
                        yPos += 5.5;
                    }
                }
                yPos += paragraphSpacing;
            });
            return yPos;
        };

        const drawSealPlaceholder = () => {
            doc.setDrawColor(255);
            doc.rect(20, 120, 40, 40);
            doc.setFontSize(12);
            doc.setTextColor(215, 215, 215);
            doc.text('Place', 55, 130, { align: 'center' });
            doc.text('Seal', 55, 134, { align: 'center' });
            doc.text('Here', 55, 138, { align: 'center' });
        };

        const drawClosingText = (text) => {
            doc.setFontSize(12);
            doc.setTextColor(0, 0, 0);
            const wrappedText = doc.splitTextToSize(text, paragraphWidth - 70);
            doc.text(wrappedText, 100, 120);

            doc.text('IN TESTIMONY WHEREOF, I have hereunto', 100, 139.5);
            doc.text('set my hand and affixed the Great Seal of the', 100, 144.5);
            doc.text(`State of Connecticut, at ${this.districtExtradition || ''}, on ${formattedDate}.`, 100, 149.5);
        };

        // Define letter type-specific content
        const letterContent = {
            Clerk: [
                `DO HEREBY CERTIFY, that ${this?.fullnameExtradition?.toUpperCase() || ''} is now, and was at the time of signing the attached Certificate, ${this?.positionExtradition?.toUpperCase() || ''}, in and for the Judicial District of ${this?.districtExtradition?.toUpperCase() || ''}.`,
                `AND I FURTHER CERTIFY, that the seal of said Court upon said Certificate is genuine, and that I verily believe the signature thereto to be genuine.`
            ],
            "Clerk with Location": [
                `DO HEREBY CERTIFY, that ${this.fullnameExtradition?.toUpperCase() || ''} has been duly authorized as a ${this.positionExtradition?.toUpperCase() || ''} for the State of Connecticut, with jurisdiction in the Judicial District of ${this.districtExtradition?.toUpperCase() || ''} at .`,
                `AND I FURTHER CERTIFY, that the aforementioned individual has met all requirements and maintains good standing as of the date of this letter.`
            ],
            Judge: [
                `DO HEREBY CERTIFY, that ${this.fullnameExtradition.toUpperCase() || ''} having been appointed by the General Assembly on nomination by the Governor for the term of eight years from, is now, and was at the time of signing the attached document, ${this.positionExtradition?.toUpperCase() || ''} of said State;`,
                `and that to his/her acts and attestations as such, full faith and credit are and ought to be given in and out of Court.`
            ],
            "Notary Public": [
                `DO HEREBY CERTIFY, that ${this.fullnameExtradition.toUpperCase() || ''} was duly appointed and commissioned a, ${this.positionExtradition?.toUpperCase() || ''}, in and for the State of Connecticut, for the term of to;`,
                `and that to his/her acts and attestations as such, full faith and credit are and ought to be given in and out of Court.`
            ],
            "Other Appointee": [
                `DO HEREBY CERTIFY, that ${this.fullnameExtradition.toUpperCase() || ''} at the time of signing the attached document, ${this.positionExtradition?.toUpperCase() || ''}, in and for the State of Connecticut, for the term of to;`,
                `and that to his/her acts and attestations as such, full faith and credit are and ought to be given in and out of Court.`
            ],
            "Town Clerk": [
                `DO HEREBY CERTIFY, that ${this.fullnameExtradition.toUpperCase() || ''} is now, and was at the time of signing the attached Certificate, ${this.positionExtradition?.toUpperCase() || ''}, for the town of , in the Country of ${this.districtExtradition.toUpperCase() || ''} in said state;`,
                `and that to his/her acts and attestations as such, full faith and credit are and ought to be given in and out of Court.`
            ],
            "Chief State's Attorney": [
                `DO HEREBY CERTIFY, that ${this.fullnameExtradition.toUpperCase() || ''} having been appointed by the State of Connecticut Criminal Justice Commission for the term of to, is now, and was at the time of signing the attached document, ${this.positionExtradition?.toUpperCase() || ''} for the State of Connecticut;`,
                `and that to his/her acts and attestations as such, full faith and credit are and ought to be given in and out of Court.`
            ],
            "Career States Atty(Asst., Supervisory, etc)": [
                `DO HEREBY CERTIFY, that ${this.fullnameExtradition.toUpperCase() || ''} is now, and was at the time of signing the attached Certificate, ${this.positionExtradition?.toUpperCase() || ''}, for the Judicial District of ${this.districtExtradition.toUpperCase() || ''} State of Connecticut;`,
                `and that to his/her acts and attestations as such, full faith and credit are and ought to be given in and out of Court.`
            ],
            "State's Attorney": [
                `DO HEREBY CERTIFY, that ${this.fullnameExtradition.toUpperCase() || ''} having been appointed by the State of Connecticut Criminal Justice Commission for the term of to, is now, and was at the time of signing the attached document, ${this.positionExtradition?.toUpperCase() || ''} for the Judicial District of ${this.districtExtradition.toUpperCase() || ''} State of Connecticut;`,
                `and that to his/her acts and attestations as such, full faith and credit are and ought to be given in and out of Court.`
            ]
        };

        const content = [
            `I, ${this.signerFirstName?.toUpperCase() || ''} ${this.signerLastName?.toUpperCase() || ''}, ${this.signerTitle?.toUpperCase() || ''} of Connecticut,`,
            ...(letterContent[this.letterTypeExtradition] || [])
        ];

        if (this.wetsignExtradition === 'Yes') {
            doc.text('', 100, 200);
        } else if (this.signerSignatureFileId) {
            doc.addImage(this.signerSignatureFileId, 'PNG', 120, 160, 50, 20);
        }

        const drawFooter = () => {
            doc.text(`${this.signerTitle?.toUpperCase() || ''}`, 145, 190, { align: 'center' });
            doc.setLineWidth(0.5);
            doc.setDrawColor(0, 0, 0);
            doc.line(110, 183, 180, 183);
        };

        drawHeader();
        drawContent(content.slice(0, 2));
        drawSealPlaceholder();
        drawClosingText(content[2]);
        drawFooter();

        // Convert the PDF to a Blob for download
        const pdfBlob = doc.output('blob');

        doc.save(`${this.fullnameExtradition}_${this.positionExtradition}.pdf`);

        // Convert Blob to Base64 for uploading to Salesforce
        const reader = new FileReader();
        reader.readAsDataURL(pdfBlob);
        reader.onloadend = async () => {
            const base64Pdf = reader.result.split(',')[1];
            const fileName = `${this.fullnameExtradition}_${this.positionExtradition}.pdf`;

            try {
                // Upload the PDF to Salesforce Files
                await uploadPdfToIndividualApp({
                    fileName: fileName,
                    base64Data: base64Pdf,
                    linkedEntityId: this.officialRecordId
                });
                console.log('PDF uploaded to Salesforce Files successfully.');
            } catch (uploadError) {
                console.error('Error uploading PDF to Salesforce:', uploadError);
            }
        };
    }

    async fetchSignerDetails() {
        const staffData = await getSignedByDetails({ contactId: this.signedbyExtradition });
        this.signerFirstName = staffData.firstName;
        this.signerLastName = staffData.lastName;
        this.signerTitle = staffData.staffTitle;
        this.signerSignatureFileId = staffData.signatureBase64;
        this.signerDivision = staffData.division || '';
    }

    async generateLetterTypeApostille() {
        if (!window.jspdf) {
            console.error('jsPDF library not loaded');
            return;
        }

        await this.fetchSignerDetails();

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF({
            unit: 'mm',
            format: 'letter'
        });

        const pageWidth = doc.internal.pageSize.getWidth();
        const leftMargin = 30;
        const rightMargin = 30;
        const paragraphWidth = pageWidth - leftMargin - rightMargin;

        const drawHeader = () => {
            doc.setFont('Roboto', 'bold');
            doc.setFontSize(20);
            doc.text('APOSTILLE', 97, 20, { align: 'center' });
            doc.setFont('Roboto', 'normal');
            doc.setFontSize(12);
            doc.text('(Convention de La Haye du 5 October 1961)', 97, 27, { align: 'center' });
        };

        const drawContent = () => {
            doc.setFont('Roboto', 'normal');
            doc.setFontSize(12);
            let yPos = 50;

            doc.text('1. Country: ', leftMargin, yPos);
            doc.setFont('Roboto', 'bold');
            doc.text(
                `${this.countryExtradition ?? ''}`,
                leftMargin + doc.getTextWidth('1. Country: '),
                yPos
            );

            doc.setFont('Roboto', 'normal');
            yPos += 10;

            doc.setFont('Roboto', 'bold');
            doc.text('THIS PUBLIC DOCUMENT', leftMargin, yPos);
            yPos += 10;

            doc.setFont('Roboto', 'normal');
            doc.text('2. has been signed by', leftMargin, yPos);
            doc.setFont('Roboto', 'bold');
            doc.text(
                `${this.fullnameExtradition ?? ''}`,
                leftMargin + doc.getTextWidth('2. has been signed by'),
                yPos
            );
            doc.setFont('Roboto', 'normal');
            yPos += 10;

            const part1 = '3. acting in the capacity of';
            const part2 = `${this.positionExtradition ?? ''}`;

            doc.setFont('Roboto', 'normal');
            doc.text(part1, leftMargin, yPos);

            doc.setFont('Roboto', 'bold');
            const part1Width = doc.getTextWidth(part1);
            doc.text(part2, leftMargin + part1Width, yPos);

            yPos += 10;

            doc.setFont('Roboto', 'normal');
            let sealText = '4. ';

            switch (this.letterTypeExtradition ?? '') {
                case "Apostille no Term":
                    sealText += 'bears the seal/stamp of';
                    break;
                case "Apostille with Term":
                    sealText += 'in the State of Connecticut for the term of  to';
                    break;
                case "Career State\'s Attorney Apostille":
                    sealText += 'in the State of Connecticut for an indefinite term of office';
                    break;
                default:
                    sealText += '';
            }
            doc.text(sealText, leftMargin, yPos);
            yPos += 15;

            doc.setFont('Roboto', 'bold');
            doc.setFontSize(20);
            doc.text('CERTIFIED', 105, yPos, { align: 'center' });
            yPos += 15;

            doc.setFont('Roboto', 'normal');
            doc.setFontSize(12);
            doc.text(`5. at ${this.judicialDistrict ?? ''}, Connecticut`, leftMargin, yPos);
            doc.text('6. on September 3, 2024', 105, yPos);
            yPos += 10;

            const text2 = `7. ${this.signerFirstName?.toUpperCase() || ''} ${this.signerLastName?.toUpperCase() || ''}, ${this.signerTitle ?? ''}`;
            const lines2 = doc.splitTextToSize(text2, paragraphWidth);
            doc.text(lines2, leftMargin, yPos);
            yPos += lines2.length * 5 + 5;

            doc.text('8. Number:', leftMargin, yPos);
            yPos += 10;

            doc.text('9. Seal', leftMargin, yPos);
            return yPos;
        };

        const drawSealPlaceholder = (yPos) => {
            doc.setDrawColor(255);
            doc.rect(leftMargin, yPos, 40, 40);
            doc.setFontSize(12);
            doc.setTextColor(200);
            doc.text('Place', leftMargin + 30, yPos + 18, { align: 'center' });
            doc.text('Seal', leftMargin + 30, yPos + 22, { align: 'center' });
            doc.text('Here', leftMargin + 30, yPos + 26, { align: 'center' });
        };

        const drawSignature = (yPos) => {
            doc.setTextColor(0);
            doc.setFontSize(12);
            doc.text('10. Signature', 107, yPos + 25);
        };

        if (this.wetsignExtradition === 'Yes') {
            doc.text('', 120, 250);
        } else {
            doc.addImage(this.signerSignatureFileId ?? '', 'PNG', 110, 180, 50, 10);
        }

        const drawFooter = (yPos) => {
            doc.text(`${this.signerTitle ?? ''}`, 138, yPos + 50, { align: 'center' });
            doc.setLineWidth(0.5);
            doc.setDrawColor(0, 0, 0);
            doc.line(110, 195, 175, 195);
        };

        drawHeader();
        const contentYPos = drawContent();
        drawSealPlaceholder(contentYPos);
        drawSignature(contentYPos);
        drawFooter(contentYPos);

        // Convert the PDF to a Blob for download
        const pdfBlob = doc.output('blob');

        doc.save(`${this.fullnameExtradition}_${this.positionExtradition}.pdf`);

        // Convert Blob to Base64 for uploading to Salesforce
        const reader = new FileReader();
        reader.readAsDataURL(pdfBlob);
        reader.onloadend = async () => {
            const base64Pdf = reader.result.split(',')[1];
            const fileName = `${this.fullnameExtradition}_${this.positionExtradition}.pdf`;

            try {
                // Upload the PDF to Salesforce Files
                await uploadPdfToIndividualApp({
                    fileName: fileName,
                    base64Data: base64Pdf,
                    linkedEntityId: this.officialRecordId
                });
                console.log('PDF uploaded to Salesforce Files successfully.');
            } catch (uploadError) {
                console.error('Error uploading PDF to Salesforce:', uploadError);
            }
        };
    }

    @api
    async generateReceiptPdf(extradictionRequestId, isAlternateContent, type) {
        return new Promise( (resolve, reject) => {
            const extradiReqId = extradictionRequestId;
            let isAltContent = isAlternateContent;
            this.type = type;
            console.log('@@@ Type:', this.type);

            if (!window.jspdf) {
                console.error('jsPDF library not loaded');
                reject('jsPDF library not loaded');
                return;
            }

            // try {
                 getDetailsforExtradictionReceiptPdf({ extradictionRequestId: extradiReqId })
                 .then((applicationData) => {

                const { jsPDF } = window.jspdf;
                const doc = new jsPDF();

                // Header
                doc.setFont('helvetica', 'bold');
                doc.setFontSize(16);
                doc.text('RECEIPT', 105, 20, { align: 'center' });
                doc.setFontSize(12);
                doc.text('For Extradition Certifications', 105, 28, { align: 'center' });

                // Sender information
                doc.setFont('helvetica', 'normal');
                doc.setFontSize(10);
                doc.text([
                    'Legislation and Elections Administration',
                    'Division',
                    'Office of the Secretary of the State',
                    'PO BOX 150470',
                    'Hartford CT 06115-0470',
                    '860-509-6100'
                ], 105, 40, { align: 'center' });

                // Recipient information
                doc.setFontSize(11);
                doc.text([
                    applicationData.attorenyInspectorName.toUpperCase(),
                    applicationData.attorenyInspectorOffice.toUpperCase(),
                    applicationData.attorenyInspectorStreet.toUpperCase(),
                    `${applicationData.attorenyInspectorCity.toUpperCase()}, ${applicationData.attorenyInspectorState.toUpperCase()} ${applicationData.attorenyInspectorPostalCode}`
                ], 20, 70);

                // Extradition information
                doc.text([
                    `Re: EXTRADITION OF ${applicationData.personSoughtName.toUpperCase()}`,
                    `AKA: ${applicationData.akaPersonNames.toUpperCase()}`
                ], 20, 95);

                // Horizontal line
                doc.setLineWidth(0.5);
                doc.line(20, 103, 190, 103);

                // Main content based on `isAltContent`
                let mainContentLines;
                if (isAltContent) {
                    mainContentLines = [
                        "According to your request, we have prepared authentication certificates and plain copies of",
                        "statutes as described below. Please make arrangements for forwarding your request to the",
                        "Extradition Unit, Department of Public Safety."
                    ];
                } else {
                    mainContentLines = [
                        "According to your request, we have forwarded your extradition applications and supporting",
                        "paperwork for the above-named individual by Interdepartmental Mail to Det. David Hickey,",
                        "Extradition Unit, Dept of Public Safety. Authentication certificates and plain copies of",
                        "statutes were prepared for your documents as described below."
                    ];
                }

                mainContentLines.forEach((line, index) => {
                    doc.text(line, 20, 110 + (index * 5));
                });

                // Table
                doc.text('Quantity', 160, 140);
                const quantityWidth = doc.getTextWidth('Quantity');
                doc.line(160, 141, 160 + quantityWidth, 141);

                doc.text('A. Authentications / Apostilles', 20, 150);
                doc.text(applicationData.Authentication ? applicationData.Authentication : '0', 165, 150);
                doc.text('B. Plain photocopies', 20, 160);
                doc.text(applicationData.PlainPC ? applicationData.PlainPC : '0', 165, 160);

                // Footer
                doc.setFontSize(12);
                doc.text('No Fee', 105, 180, { align: 'center' });
                doc.text('OFFICIAL STATE BUSINESS', 105, 188, { align: 'center' });

                doc.setFontSize(10);
                doc.text('NOTES:', 20, 210);

                if (!isAltContent) {
                    doc.text('CC: State Police Extradition Unit', 20, 250);
                }

                // Save or upload PDF
                if (type === 'print') {
                    doc.save('Extradition_Receipt.pdf');
                    resolve(null); // No contentDocumentId when printing
                } else {
                    const pdfBlob = doc.output('blob');
                    console.log('Uploading PDF to Salesforce...');
                    this.uploadPdfExtraditionRequest(pdfBlob, extradiReqId)
                        .then((contentDocumentId) => {
                            console.log('PDF uploaded successfully:', contentDocumentId);
                            resolve(contentDocumentId);
                        })
                        .catch((error) => {
                            console.error('Error uploading PDF to Salesforce:', error);
                            reject(error);
                        });
                }
            })  .catch((error) => {
                console.error('Error fetching application data:', error);
                reject(error);
            });
        });
    }


    @api
    async cspMailingLabelPdf() {
        if (!window.jspdf) {
            console.error('jsPDF library not loaded');
            return;
        }

        try {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF();

            const addressBlock = [
                'Det. David Hickey, Extradtion Unit',
                'Dept of Public Safety',
                '1111 Country Club Rd',
                'Middletown CT 06457-555'
            ];

            const margin = 10;
            const blockHeight = 25;
            const blockWidth = 60;
            const cols = 3;
            const rows = 10;
            let currentX = margin;
            let currentY = margin;

            doc.setFont('helvetica');
            doc.setFontSize(10);

            for (let i = 0; i < 30; i++) {
                addressBlock.forEach((line, index) => {
                    doc.text(line, currentX, currentY + (index * 5));
                });

                // Move to the next column or row
                if ((i + 1) % cols === 0) {
                    currentX = margin;
                    currentY += blockHeight;

                    // Start a new page if we've filled this one
                    if ((i + 1) % (cols * rows) === 0 && i < 29) {
                        doc.addPage();
                        currentY = margin;
                    }
                } else {
                    currentX += blockWidth;
                }
            }

            // Generate and download the PDF
            doc.save('CSP_Mailing_Label.pdf');
        } catch (error) {
            console.error('Error generating PDF:', error);
        }
    }
}
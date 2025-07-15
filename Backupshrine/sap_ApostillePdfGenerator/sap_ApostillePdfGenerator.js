import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import jsPDF from '@salesforce/resourceUrl/sap_pdfGenerator'; 
import ApostilleHouseImg from '@salesforce/resourceUrl/ApostilleHouseImg'; 
import apostilleCertBorder from '@salesforce/resourceUrl/apostilleCertBorder';
import stateSealLogo from '@salesforce/resourceUrl/stateSealLogo';
import greatSealLogo from '@salesforce/resourceUrl/greatSealLogo';
import stateGoldEmb from '@salesforce/resourceUrl/stateGoldEmb';
// import verificationQr from '@salesforce/resourceUrl/verificationQr';
import uploadPdfToIndividualApplication from '@salesforce/apex/SAP_PdfUploadController.uploadPdfToIndividualApplication';
import uploadPdfToIndividualApp from '@salesforce/apex/SAP_PdfUploadController.uploadPdfToIndividualApp';
// import fetchPdfUrlFromDatabase from '@salesforce/apex/SAP_PdfUploadController.fetchPdfUrlFromDatabase';
import checkIfDocumentExists from '@salesforce/apex/SAP_PdfUploadController.checkIfDocumentExists';

export default class PdfGenerator extends LightningElement {
    @track checkList = {};
    jsPdfInitialized = false;
    @track verifyUrl = ''
    @track noPages = '1';

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

    // Rename the internal PDF generation function
    async generatePdfDocument(type) {

        if (!window.jspdf) {
            console.error('jsPDF library not loaded');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const pageWidth = doc.internal.pageSize.getWidth();
    
        // Load and add header image
        const imgData = await this.fetchBase64Image(ApostilleHouseImg);
        const imageHeight = 22;
        doc.addImage(imgData, 'PNG', 12, 13, pageWidth - 30, imageHeight);
    
        let currentY = imageHeight + 15;
    
        // Draw main bordered box with a fixed height
        const boxX = 20;
        const boxY = currentY;
        const boxWidth = pageWidth - 40;
        const boxHeight = 122; // Fixed box height for all content
        doc.setLineWidth(0.0075); // Thicker border for main box
        doc.rect(boxX, boxY, boxWidth, boxHeight);
    
        currentY += 6; // Move inside the box for content
    
        // Function to draw dotted line below each section with adjusted spacing
        const drawDottedLine = (y) => {
            doc.setLineWidth(0.00075); // Thinner line width
            doc.setLineDash([0.5, 0.2], 0); // Dotted line style
            doc.line(boxX, y, boxX + boxWidth, y); // Horizontal line
            doc.setLineDash([]); // Reset to solid line for other elements
        };
    
        // Title Section: APOSTILLE
        doc.setFont("times", "bold");
        doc.setFontSize(11);
        doc.text("APOSTILLE", pageWidth / 2, currentY, { align: "center" });
        doc.setFont("times", "normal");
        doc.setFontSize(9);
        currentY += 5;
        doc.text("(Convention de La Haye du 5 octobre 1961)", pageWidth / 2, currentY, { align: "center" }); 
        drawDottedLine(currentY + 3);
        currentY += 8;
    
        // Consistent styling for static rows
        doc.setFont("times", "normal");
        doc.setFontSize(10);
    
        // Static Content for Apostille Certificate
        const data = {
            country: this.checkList.destination,
            documentType: this.checkList.documentType,
            signedBy: this.checkList.signedBy,
            position: this.checkList.position,
            certified: "",
            location: "Hartford, Connecticut",
            date: new Date().toLocaleDateString(),
            issuer: "Stephanie Thomas, Secretary of the State of Connecticut",
            certificateNumber:this.checkList.certificateNumber,
            seal: "Gold Embossed Seal",
            signature: "Signature Here"
        };
    
        // Function to draw each row of content with reduced vertical space
        const drawRow = (label, value, translation) => {
            doc.setFont("times", "bold");
            doc.text(label, boxX + 2, currentY);
            doc.setFont("times", "normal");
            doc.text(value, boxX + 60, currentY);
            doc.setFontSize(8);
            doc.text(translation, boxX + 6, currentY + 3);
            doc.setFontSize(11);
            drawDottedLine(currentY + 6);
            currentY += 10.4; // Reduced space between rows
        };
    
        // Draw each row with the updated styling
        drawRow("1. Country:", data.country, "País:");
        drawRow("   This public document", data.documentType, "El presente documento público");
        drawRow("3. has been signed by", data.signedBy, "ha sido firmado por");
        drawRow("4. acting in the capacity of", data.position, "quien actúa en calidad de");
        drawRow("5. bears the seal / stamp of", data.certified, "y está revestido del sello / timbre de");
    
        // Certified centered text
        doc.setFont("times", "bold");
        doc.text("Certified", pageWidth / 2, currentY, { align: "center" });
        doc.setFont("times", "normal");
        doc.setFontSize(8);
        doc.text("Certificado", pageWidth / 2, currentY+3, { align: "center" });
        drawDottedLine(currentY + 6);
        const verticalLineStartY = currentY+6;
        currentY += 10.4;
    
        // Location and Date in Split Row
        
        doc.setFont("times", "bold");
        doc.setFontSize(11);
        doc.text("5. at", boxX + 2, currentY);
        doc.setFont("times", "normal");
        doc.text(data.location, boxX + 11, currentY);
        doc.setFont("times", "bold");
        doc.text("6. the", boxX + 100, currentY);
        doc.setFont("times", "normal");
        doc.text(data.date, boxX + 111, currentY);
        doc.setFontSize(8);
        doc.text("en", boxX + 6, currentY + 3);
        doc.text("el día", boxX + 103, currentY+3);
        doc.setFontSize(11);
        drawDottedLine(currentY + 6);
        const verticalLineEndY = currentY+6; 
        currentY += 12;

        // Draw vertical line beside the "Connecticut" value
        const verticalLineX = boxX + 95; // Adjust the x position as needed to align beside "Connecticut"
        //const verticalLineStartY = currentY - 18; // Start of the vertical line at the original `currentY`
        //const verticalLineEndY = currentY; // End of the vertical line at the end of the dotted line

        doc.setLineDash([0.5, 0.2], 0); // Dotted line style
        doc.line(verticalLineX, verticalLineStartY, verticalLineX, verticalLineEndY);
    
        // Issuer Info
        drawRow("7. by", data.issuer, "por");
    
        // Certificate Number
        drawRow("8. Nº", data.certificateNumber, "bajo el número");
        const verticalLineStartYy = currentY-4; 
    
        // Seal and Signature (Two-column layout)
        doc.setFont("times", "bold");
        doc.text("9. Seal / stamp:", boxX + 2, currentY);
        doc.setFont("times", "normal");
        doc.text(data.seal, boxX + 45, currentY);
        doc.setFontSize(8);
        doc.text("Sello / timbre:", boxX + 6, currentY + 3);
    
        doc.setFontSize(11);
        doc.setFont("times", "bold");
        doc.text("10. Signature:", boxX + 100, currentY);
        doc.setFont("times", "normal");
        doc.setFontSize(8);
        doc.text("Firma:", boxX + 103, currentY+3);
        const verticalLineEndYy = currentY+7.5; // End of the vertical line at the end of the dotted line


        // Draw vertical line beside the "Connecticut" value
        const verticalLineXx = boxX + 95; // Adjust the x position as needed to align beside "Connecticut"
        
        

        doc.setLineDash([0.5, 0.2], 0); // Dotted line style
        doc.line(verticalLineXx, verticalLineStartYy, verticalLineXx, verticalLineEndYy);
        //drawDottedLine(currentY + 6);
        currentY += 45;

        // Draw a solid line before the footer
        doc.setLineDash([]);
        doc.setLineWidth(0.5); // Thicker line for the footer separator
        doc.line(10, currentY, pageWidth - 10, currentY); // Horizontal line across the width of the page
        currentY += 6; // Adjust space below the line
    
        // Footer Section with structured text and highlights
        doc.setFontSize(8);
        doc.setFont("times", "normal");
        doc.setTextColor(0, 102, 153);
        doc.text("This Certificate is not valid anywhere within the United States of America, its territories or possessions.", 11, currentY);
        currentY += 6;
        doc.text("This Apostille only certifies the authenticity of the signature and the capacity of the person who has signed the public document, and, where appropriate, the identity of the seal or stamp which the public document bears. This Apostille does not certify the content of the document for which it was issued.", 11, currentY, { maxWidth: pageWidth - 20 });
        currentY += 12;
        doc.setFont("times", "bold");
        
        doc.text("This certificate does not constitute an Apostille under the Hague Convention of 5 October 1961, for those countries that have not acceded to that Convention. If this document is to be used in a country which is not party to the Hague Convention of 5 October 1961, the certificate should be presented to the consular section of the mission representing that country.", 11, currentY, { maxWidth: pageWidth - 20 });
        currentY += 12;
       // Set the RGB color for the highlight (e.g., yellow)
        doc.setFillColor(255, 255, 0); // Yellow

        // Draw the rectangle for highlighting
        const highlightX = 10; // X position of the highlight
        const highlightY = currentY - 3; // Y position, slightly above the text to cover it
        const highlightWidth = 110; // Adjust width to fit the text
        const highlightHeight = 4; // Height to cover the text

        doc.rect(highlightX, highlightY, highlightWidth, highlightHeight, 'F'); // 'F' for fill

        // Set text color (e.g., blue)
        doc.setTextColor(0, 102, 153);

        // Add the highlighted text
        doc.setFont("times", "bold");
        doc.setFontSize(8);
        doc.text("[To verify the issuance of this Apostille, see [insert the URL of the e-Register].]", highlightX + 2, currentY);
        drawDottedLine(currentY + 6);
        currentY += 14;

        // Add Spanish translation in the footer section
        doc.text("Este Certificado no es valido en ningun lugar dentro de los Estados Unidos, sus territorios o posesiones.", 11, currentY);
        currentY += 6;
        doc.text("Esta Apostilla certifica únicamente la autenticidad de la firma, la calidad en que el signatario del documento haya actuado y, en su caso, la identidad del sello o timbre del que el documento público esté revestido.", 11, currentY, { maxWidth: pageWidth - 20 });
        currentY += 12;
        doc.text("Esta Apostilla no certifica el contenido del documento para el cual se expidió.", 11, currentY);
        currentY += 6;
        doc.setFont("times", "bold");
        doc.text("Este certificado no constituye una Apostilla en virtud del Convenio de la Haya de 5 de octubre de 1961, para los países que no se han adherido a la Convención. Si este documento para ser utilizado en un país que no es parte en el Convenio de La Haya de 5 de octubre de 1961, el certificado debe ser presentado a la sección consular de la misión que representa a ese país.", 11, currentY, { maxWidth: pageWidth - 20 });
        currentY += 12;
        doc.setTextColor(0, 102, 153);
        // Set the RGB color for the highlight (e.g., yellow)
        doc.setFillColor(255, 255, 0); // Yellow

        // Draw the rectangle for highlighting
        const highlightXx = 10; // X position of the highlight
        const highlightYy = currentY - 3; // Y position, slightly above the text to cover it
        const highlightWidthh = 140; // Adjust width to fit the text
        const highlightHeightt = 4; // Height to cover the text

        doc.rect(highlightXx, highlightYy, highlightWidthh, highlightHeightt, 'F'); // 'F' for fill

        doc.text("[Esta Apostilla se puede verificar en la dirección siguiente: [ingresar la dirección URL del e-Registro].]", 11, currentY);

        // After generating the PDF content
        if (type === "print") {
            // Generate the PDF blob
            const pdfBlob = doc.output('blob');

            // Create a URL for the PDF blob
            this.pdfUrl = URL.createObjectURL(pdfBlob);

            // Dynamically create an iframe and set its src to the blob URL
            const anchor = document.createElement('a');
            console.log(this.pdfUrl);
            anchor.href = this.pdfUrl;
            anchor.target="_blank"; 
            anchor.click();
        } else {
            // Download the PDF
            doc.save("Apostille_Document.pdf");
        }
    }  

    async generatePdfDocumentLatest(type){
        
        if (!window.jspdf) {
            console.error('jsPDF library not loaded');
            return;
        }
    
        const { jsPDF } = window.jspdf;
    
        // Set page size to 'letter' (8.5 x 11 inches)
        const doc = new jsPDF({
            unit: 'in',   // Use inches for easy alignment with provided margins
            format: 'letter',   // Letter size: 8.5 x 11 inches
            orientation: 'portrait',
            compress: true
        });

        // Get the current date
        const currentDate = new Date();

        // Format the date as "Month day, year"
        const formattedDate = currentDate.toLocaleDateString('en-US', {
            month: 'long',  // Full month name
            day: 'numeric', // Day of the month
            year: 'numeric' // Full year
        });

        // Store it in a constant
        const dateToDisplay = formattedDate;

        
    
        // Page dimensions (letter size)
        const pageWidth = 8.5;
        const pageHeight = 11;
    
        // Margins
        const marginTop = 1;
        const marginLeft = 0.63;
        const marginRight = 1;
        const centerX = pageWidth / 2;
    
        // Load images
        //const borderImage = await this.fetchBase64Image(apostilleCertBorder);
       // const sealLogo = await this.fetchBase64Image(stateSealLogo);
        const veriQR = await this.generateQRCode();
    
        const goldEmb = await this.fetchBase64Image(greatSealLogo);
        // Center helper function
        const centerText = (text, yPosition, fontSize, fontStyle = 'normal') => {
            doc.setFont("times", fontStyle);
            doc.setFontSize(fontSize);
            doc.setTextColor(0, 0, 0) // Dark blue color
            const textWidth = doc.getTextWidth(text);
            const xPosition = (pageWidth - textWidth) / 2;
            doc.text(text, xPosition, yPosition);
        };
    
        // Add the border image to cover the whole page
       // doc.addImage(borderImage, 'PNG', 0, 0, pageWidth, pageHeight);
    
        // Starting Y position
        let currentY = marginTop;
    
        // Centered header text
       // centerText('Secretary of the State of Connecticut', currentY, 24, 'normal');
        currentY += 0.5;
        centerText('APOSTILLE', currentY, 22, 'bold');
        currentY += 0.3;
        centerText('(Convention de La Haye du 5 octobre 1961)', currentY, 14, 'normal');
        currentY += 0.25;
    
        // Position and add the seal logo to the top right corner
        const sealLogoX = marginLeft + 6.4;
        const sealLogoY = marginTop - 0.4;
        const sealLogoWidth = 1 * 0.91;
        const sealLogoHeight = 1.05 * 0.91;
       // doc.addImage(sealLogo, 'PNG', sealLogoX, sealLogoY, sealLogoWidth, sealLogoHeight);
    
        // Start adding content with English and Spanish translation below
        const labelX = marginLeft + 0.3;
        const offsetValueX = centerX + 0.1 * pageWidth; // Offset by 10% from center
    
        doc.setTextColor(0,0,0) // Dark blue color
        const englishFontSize = 11;
        const spanishFontSize = 8;
        const englishLineSpacing = 0.150;
        const spanishLineSpacing = 0.23;

        const country = this.checkList.destination || '';
        const documentype = this.checkList.documentType || '';
        const signedBy = this.checkList.signedBy || '';
        const sealStramp = this.checkList.sealStramp || '';
        const position = this.checkList.position || '';
        const certificateNumber = this.checkList.certificateNumber || '';
        const Signing_Authority_Name = this.checkList.Signing_Authority_Name + ', ' || '';
        const Signing_Authority_Title = this.checkList.Signing_Authority_Title + ' of Connecticut' || '';
        const recordId = this.checkList.recordId || '';

        const siginedAuthority = Signing_Authority_Name + ', ' + Signing_Authority_Title;
        const location = 'Hartford, Connecticut';

    
        // Line-by-line content with translation below
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("1. Country:", labelX, currentY);
        doc.setFont("times", "normal");
        doc.text(country, centerX-1.5, currentY);
        currentY += englishLineSpacing;
        doc.setFont("times", "italic");
        doc.setFontSize(spanishFontSize);
        doc.text("País:", labelX + 0.18, currentY); // Align Spanish under English text
        currentY += spanishLineSpacing;
    
        // Continue with each line in the same format
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("This public document", labelX + 0.18, currentY);
        currentY += englishLineSpacing;
        doc.setFont("times", "italic");
        doc.setFontSize(spanishFontSize);
        doc.text("El presente documento público", labelX + 0.18, currentY);
        currentY += spanishLineSpacing;
    
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("2. has been signed by", labelX, currentY);
        doc.setFont("times", "normal");
        doc.text(signedBy, centerX-1.5, currentY);
        currentY += englishLineSpacing;
        doc.setFont("times", "italic");
        doc.setFontSize(spanishFontSize);
        doc.text("ha sido firmado por", labelX + 0.18, currentY);
        currentY += spanishLineSpacing;
    
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("3. acting in the capacity of", labelX, currentY);

        // Calculate the available width for wrapping the text
        const availableWidth = pageWidth/2 - marginRight ; // Adjust based on your document margins

        // Wrap the position text
        const wrappedPositionText = doc.splitTextToSize(position, availableWidth);
        doc.setFont("times", "normal");
        let wrapY = currentY;
        // Print the wrapped position text
        wrappedPositionText.forEach((line) => {
            doc.text(line, centerX-1.5, wrapY); // Adjust horizontal alignment
            wrapY += englishLineSpacing;
        });
        
        // doc.text(position, centerX-0.5, currentY);
        currentY += englishLineSpacing;
        doc.setFont("times", "italic");
        doc.setFontSize(spanishFontSize);
        doc.text("quien actúa en calidad de", labelX + 0.18, currentY);
        currentY += spanishLineSpacing;
    
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("4. bears the seal / stamp of", labelX, currentY);
        const wrappedsealStrampText = doc.splitTextToSize(sealStramp, availableWidth);
        doc.setFont("times", "normal");
        let wrapoedY = currentY;
        // Print the wrapped position text
        wrappedsealStrampText.forEach((line) => {
            doc.text(line, centerX-1.5, wrapoedY); // Adjust horizontal alignment
            wrapoedY += englishLineSpacing;
        });
        currentY += englishLineSpacing;
        doc.setFont("times", "italic");
        doc.setFontSize(spanishFontSize);
        doc.text("y está revestido del sello / timbre de", labelX + 0.18, currentY);
        currentY += spanishLineSpacing;
    
        // Centered "Certified" section
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("Certified", centerX, currentY, { align: "center" });
        currentY += englishLineSpacing;
        doc.setFont("times", "italic");
        doc.setFontSize(spanishFontSize);
        doc.text("Certificado", centerX, currentY, { align: "center" });
        currentY += 0.3;
    
        // Remaining sections
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("5. at", labelX, currentY);
        doc.setFont("times", "normal");
        doc.text(location, labelX+0.5, currentY);
        doc.setFont("times", "bold");
        doc.text("6. the", offsetValueX-1.5, currentY); // Offset by 10% from center
        doc.text("Date", offsetValueX, currentY); // Offset by 10% from center
        doc.setFont("times", "normal");
        doc.text(dateToDisplay, offsetValueX+0.38, currentY); // Offset by 10% from center
        currentY += englishLineSpacing;
        doc.setFont("times", "italic");
        doc.setFontSize(spanishFontSize);
        doc.text("en", labelX + 0.18, currentY);
        doc.text("el día", offsetValueX + 0.2-1.5, currentY); // Align Spanish text under English
        currentY += spanishLineSpacing;
    
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("7. by", labelX, currentY);
        doc.setFont("times", "normal");
        doc.setFont("times", "bold");
        doc.text(Signing_Authority_Name, centerX-1.5, currentY);
        doc.setFont("times", "bold");
        doc.text(Signing_Authority_Title, centerX-0.2, currentY);
        currentY += englishLineSpacing;
        doc.setFont("times", "italic");
        doc.setFontSize(spanishFontSize);
        doc.text("por", labelX + 0.18, currentY);
        currentY += spanishLineSpacing;
    
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("8. Nº", labelX, currentY);
        doc.setFont("times", "normal");
        doc.setFont("times", "bold");
        doc.text(certificateNumber,  labelX + 0.4, currentY);
        doc.setFont("times", "normal");
        currentY += englishLineSpacing;
        doc.setFont("times", "italic");
        doc.setFontSize(spanishFontSize);
        doc.text("bajo el número", labelX + 0.18, currentY);
        currentY += spanishLineSpacing;
    
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("9. Seal / stamp:", labelX, currentY);
        //doc.text("10. Signature:", offsetValueX, currentY); // Offset by 10% from center
        currentY += englishLineSpacing;
        doc.setFont("times", "italic");
        doc.setFontSize(spanishFontSize);
        doc.text("Sello / timbre:", labelX + 0.18, currentY);
        //doc.text("Firma:", offsetValueX + 0.2, currentY);
        currentY += 0.35;
    
        // Add goldEmb image with specified dimensions and position
        // const goldEmbX = marginLeft - 0.01;  // Adjust based on column position
        // const goldEmbY = currentY + 0.01;    // Adjust based on vertical reference point

        //doc.addImage(goldEmb, 'PNG', labelX, currentY, 1.8, 2);
        const qrX = marginLeft + 6
        currentY += 0.5;
         // Place the QR code image with specified position and dimensions
        //const qrX = pageWidth - marginRight - 0.85; // Right-aligned relative to the right margin
        // const qrY = goldEmbY + 2;                   // Adjust vertical position to avoid overlapping with other elements
        doc.addImage(veriQR, 'PNG', qrX, currentY+0.5, 0.7, 0.7);
            
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("10. Signature:", centerX, currentY-0.25, { align: "center" }); // Offset by 10% from center
        currentY += englishLineSpacing;
        doc.setFont("times", "italic");
        doc.setFontSize(spanishFontSize);
        doc.text("Firma:", centerX-0.05, currentY-0.25, { align: "center" });
        doc.setLineWidth(0.01); // Set underline thickness to 0.1mm
        doc.line(centerX + 0.18, currentY-0.25 , centerX + 2.5, currentY-0.25); 

        let linx = labelX + 1.6;
        doc.setFont("times", "bold");
        doc.setFontSize(7);
       // doc.text('Verify eApostille:', linx, currentY);
        currentY += 0.153;
        doc.setFont("times", "normal");
       // Add the text
       const linkVText = 'To verify the issuance of this Apostille/ Esta Apostilla se puede verificar en la dirección siguiente:';
       // const linkVWidth = doc.getTextWidth(linkVText);
        doc.text(linkVText, linx+0.3, currentY);
        doc.text(this.verifyUrl, linx+0.31, currentY+0.1);

        currentY += 1.4;



        // Footer Section with structured text and highlights
        doc.setFontSize(7);
        doc.setFont("times", "normal");
        doc.setTextColor(0, 0, 0);
        doc.text("This Certificate is not valid anywhere within the United States of America, its territories or possessions.", labelX+1.2, currentY);
        currentY += 0.2;
        doc.text("This Apostille only certifies the authenticity of the signature and the capacity of the person who has signed the public document, and, where appropriate, the identity of the seal or stamp which the public document bears. This Apostille does not certify the content of the document for which it was issued.", labelX, currentY, { maxWidth: pageWidth - 2 });
        currentY += 0.3;
        doc.setFont("times", "bold");
        
        doc.text("This certificate does not constitute an Apostille under the Hague Convention of 5 October 1961, for those countries that have not acceded to that Convention. If this document is to be used in a country which is not party to the Hague Convention of 5 October 1961, the certificate should be presented to the consular section of the mission representing that country.", labelX, currentY, { maxWidth: pageWidth - 2 });
        
        doc.setLineWidth(0.01); // Set line thickness to 0.1mm
        doc.setLineDash([0.01, 0.01], 0); // Define the pattern: 0.5mm line, 1mm space
        doc.line(labelX + 1.2, currentY + 0.3, labelX + 6, currentY + 0.3); // Draw the dotted line
        doc.setLineDash([]); // Reset to solid lines for future drawings
        
        currentY += 0.5;
        doc.setFont("times", "normal");
        // Add Spanish translation in the footer section
        doc.text("Este Certificado no es valido en ningun lugar dentro de los Estados Unidos, sus territorios o posesiones.", labelX+1.2, currentY);
        currentY += 0.2;
        doc.setFont("times", "normal");
        doc.text("Esta Apostilla certifica únicamente la autenticidad de la firma, la calidad en que el signatario del documento haya actuado y, en su caso, la identidad del sello o timbre del que el documento público esté revestido.", labelX, currentY, { maxWidth: pageWidth - 2 });
        currentY += 0.3;
        //doc.text("Esta Apostilla no certifica el contenido del documento para el cual se expidió.", labelX, currentY);
        //currentY += 0.1;
        doc.setFont("times", "bold");
        doc.text("Este certificado no constituye una Apostilla en virtud del Convenio de la Haya de 5 de octubre de 1961, para los países que no se han adherido a la Convención. Si este documento para ser utilizado en un país que no es parte en el Convenio de La Haya de 5 de octubre de 1961, el certificado debe ser presentado a la sección consular de la misión que representa a ese país.", labelX, currentY, { maxWidth: pageWidth - 2 });


        //  const linkText = 'Apostille Verification';
        // // const linkWidth = doc.getTextWidth(linkText);
        // doc.setLineWidth(0.001); // Set underline thickness to 0.1mm
        // doc.setDrawColor(47, 85, 151);
        
        // doc.textWithLink(linkText, linx+linkVWidth, currentY, { url: this.verifyUrl });
        // doc.line(linx+linkVWidth, currentY + 0.015, linx + linkVWidth+ linkWidth, currentY + 0.015);

        // After generating the PDF content
        const pdfBlob = doc.output('blob');

        if (type === "print") {

          await this.pdfStoreApplication("print", pdfBlob, recordId, doc, certificateNumber);

        } else {
            console.log('i am before convertBlobToBase64()');
            this.pdfStoreApplication("download", pdfBlob, recordId, doc, certificateNumber);
        }

        // if (type === "print") {
        //     // Generate the PDF blob
        //     const pdfBlob = doc.output('blob');

        //     // Create a URL for the PDF blob
        //     this.pdfUrl = URL.createObjectURL(pdfBlob);

        //     // Dynamically create an iframe and set its src to the blob URL
        //     const anchor = document.createElement('a');
        //     console.log(this.pdfUrl);
        //     anchor.href = this.pdfUrl;
        //     anchor.target="_blank"; 
        //     anchor.click();
        // } else {
        //     // Download the PDF
        //     doc.save("Apostille_Document.pdf");
        // }
    }

    delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

    async pdfStoreApplication(actionType, pdfBlob, recordId, doc, certificateNumber) {
        try {
            const base64Pdf = await this.blobToBase64(pdfBlob);
            const fileName =  `${certificateNumber}_Apostille_Cert.pdf`;
    
            // Check if ContentDocument already exists for the given recordId
            // console.log('Checking if document exists for recordId:', recordId);
            const checkDocResponse = await checkIfDocumentExists({
                linkedEntityId: recordId,
                fileName: fileName
            });
    
            let contentDocumentId = checkDocResponse.contentDocumentId;
            let contentVersionId = checkDocResponse.contentVersionId;

            if (!contentDocumentId) {
                console.log('No document found with specified file name, proceeding with upload...');
            } else if (contentDocumentId && fileName === `${certificateNumber}_Apostille_Cert.pdf`) {
                console.log('Document with matching file name already exists. ContentDocumentId:', contentDocumentId, 'ContentVersionId:', contentVersionId);
            }
    
            // If document does not exist, proceed with upload
            if (!contentDocumentId) {
                // console.log('Document not found, proceeding with upload...');
                const uploadResponse = await uploadPdfToIndividualApplication({
                    fileName: fileName, 
                    base64Data: base64Pdf,
                    linkedEntityId: recordId,
                });
    
                contentDocumentId = uploadResponse.contentDocumentId;
                contentVersionId = uploadResponse.contentVersionId;
                console.log('Document uploaded successfully. ContentDocumentId:', contentDocumentId, 'ContentVersionId:', contentVersionId);
            } else {
                console.log('Document already exists. ContentDocumentId:', contentDocumentId, 'ContentVersionId:', contentVersionId);
            }
    
            console.log('Action type selected:', actionType);

            
    
            // Perform the action based on the type (print or download)
            if (actionType === "print") {
                console.log('Generating preview URL for print...');
                const previewUrl = `/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${contentVersionId}`;
                await this.delay(5000); 
                window.open(previewUrl, '_blank'); // Opens the preview in a new tab
                console.log('Navigating to file preview with URL:', previewUrl);
            } else if (actionType === "download") {
                console.log('Generating download URL...');
                const downloadUrl = `/sfc/servlet.shepherd/version/download/${contentVersionId}`;
                console.log('Download URL generated:', downloadUrl);
                const anchor = document.createElement('a');
                anchor.href = downloadUrl;
                anchor.download = fileName;
                document.body.appendChild(anchor);
                anchor.click();  // Trigger the download
                document.body.removeChild(anchor);
                console.log('Download triggered successfully.');
            } else {
                console.error('Invalid action type specified. ActionType:', actionType);
            }
        } catch (error) {
            console.error('Error handling PDF upload/preview:', error);
        }
    }    

    

    fetchBase64Image(url) {
        return fetch(url)
            .then((response) => response.blob())
            .then((blob) => {
                return new Promise((resolve, reject) => {
                    const reader = new FileReader();
                    reader.onloadend = () => resolve(reader.result);
                    reader.onerror = reject;
                    reader.readAsDataURL(blob);
                });
            });
    }

    async generateQRCode() {
        try {
            // Construct the dynamic URL with the certificate number
            const certificateNo = this.checkList.certificateNumber;
            if (!certificateNo) {
                throw new Error("Certificate number is missing.");
            }
    
            const baseUrl = "https://ctds--sapdev001.sandbox.my.site.com/eApostille/apostilleverification";
            const qrDataUrl = `${baseUrl}?certificateNo=${encodeURIComponent(certificateNo)}`;
            this.verifyUrl = qrDataUrl;
    
            // API URL to generate the QR code
            const apiUrl = `https://api.qrserver.com/v1/create-qr-code/?data=${encodeURIComponent(qrDataUrl)}&size=300x300&format=png`;
    
            // Fetch the QR code image as binary data
            const response = await fetch(apiUrl);
            if (!response.ok) {
                throw new Error(`Failed to generate QR code. Status: ${response.status}`);
            }
    
            // Convert the image to a blob
            const blob = await response.blob();
    
            // Convert the blob to a Base64 string
            const base64 = await this.convertBlobToBase64(blob);
    
            // Return the Base64 string
            return base64;
        } catch (error) {
            console.error("Error generating QR code:", error);
            throw error; // Ensure error propagation for further handling if needed
        }
    }
    
    // Helper function to convert a blob to a Base64 string
    convertBlobToBase64(blob) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = () => resolve(reader.result.split(',')[1]); // Extract only the Base64 data without metadata
            reader.onerror = reject;
            reader.readAsDataURL(blob);
        });
    }


    @api
    async generateApostilleCertificate(checkList, type) {
        this.checkList = checkList;
        console.log(this.checkList, 'CheckList data received in @api method');
        //this.generatePdfDocument(type); // Call the renamed internal function
       await this.generatePdfDocumentLatest(type);
        return 'success';
    }

    async generatePdfDocumentNew(type) {

        if (!window.jspdf) {
            console.error('jsPDF library not loaded');
            return;
        }



        // if(type === 'print'){
        //     this.showToast('Generating', 'PDF is being Generated!', 'info');
        // }else{
        //     this.showToast('Downloading', 'PDF is being Downloaded!', 'info');
        // }
    
        const { jsPDF } = window.jspdf;
    
        // Set page size to 'letter' (8.5 x 11 inches)
        const doc = new jsPDF({
            unit: 'in',   // Use inches for easy alignment with provided margins
            format: 'letter',   // Letter size: 8.5 x 11 inches
            orientation: 'portrait',
            compress: true
        });

        
    
        // Page dimensions (letter size)
        const pageWidth = 8.5;
        const pageHeight = 11;
    
        // Margins
        const marginTop = 1;
        const marginLeft = 0.63;
        const marginRight = 1;
        const centerX = pageWidth / 2;
    
        // Load images
        const borderImage = await this.fetchBase64Image(apostilleCertBorder);
        const sealLogo = await this.fetchBase64Image(stateSealLogo);
        const veriQR = await this.generateQRCode();
    
        const goldEmb = await this.fetchBase64Image(stateGoldEmb);
        // Center helper function
        const centerText = (text, yPosition, fontSize, fontStyle = 'normal') => {
            doc.setFont("times", fontStyle);
            doc.setFontSize(fontSize);
            doc.setTextColor(47, 85, 151) // Dark blue color
            const textWidth = doc.getTextWidth(text);
            const xPosition = (pageWidth - textWidth) / 2;
            doc.text(text, xPosition, yPosition);
        };
    
        // Add the border image to cover the whole page
        doc.addImage(borderImage, 'PNG', 0, 0, pageWidth, pageHeight);
    
        // Starting Y position
        let currentY = marginTop;
    
        // Centered header text
        centerText('Secretary of the State of Connecticut', currentY, 24, 'normal');
        currentY += 0.4;
        centerText('APOSTILLE', currentY, 22, 'bold');
        currentY += 0.3;
        centerText('(Convention de La Haye du 5 octobre 1961)', currentY, 14, 'bold');
        currentY += 0.25;
    
        // Position and add the seal logo to the top right corner
        const sealLogoX = marginLeft + 6.4;
        const sealLogoY = marginTop - 0.4;
        const sealLogoWidth = 1 * 0.91;
        const sealLogoHeight = 1.05 * 0.91;
        doc.addImage(sealLogo, 'PNG', sealLogoX, sealLogoY, sealLogoWidth, sealLogoHeight);
    
        // Start adding content with English and Spanish translation below
        const labelX = marginLeft + 0.3;
        const offsetValueX = centerX + 0.1 * pageWidth; // Offset by 10% from center
    
        doc.setTextColor(47, 85, 151) // Dark blue color
        const englishFontSize = 11;
        const spanishFontSize = 8;
        const englishLineSpacing = 0.150;
        const spanishLineSpacing = 0.23;

        const country = this.checkList.destination || '';
        const documentype = this.checkList.documentType || '';
        const signedBy = this.checkList.signedBy || '';
        const position = this.checkList.position || '';
        const certificateNumber = this.checkList.certificateNumber || '';
        const Signing_Authority_Name = this.checkList.Signing_Authority_Name + ', ' || '';
        const Signing_Authority_Title = this.checkList.Signing_Authority_Title || '';
        const recordId = this.checkList.docId || '';

        const siginedAuthority = Signing_Authority_Name + ', ' + Signing_Authority_Title;
        const location = 'Hartford, Connecticut';

    
        // Line-by-line content with translation below
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("1. Country:", labelX, currentY);
        doc.setFont("times", "normal");
        doc.text(country, centerX-0.5, currentY);
        currentY += englishLineSpacing;
        doc.setFont("times", "normal");
        doc.setFontSize(spanishFontSize);
        doc.text("País:", labelX + 0.18, currentY); // Align Spanish under English text
        currentY += spanishLineSpacing;
    
        // Continue with each line in the same format
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("This public document", labelX + 0.18, currentY);
        currentY += englishLineSpacing;
        doc.setFont("times", "normal");
        doc.setFontSize(spanishFontSize);
        doc.text("El presente documento público", labelX + 0.18, currentY);
        currentY += spanishLineSpacing;
    
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("2. has been signed by", labelX, currentY);
        doc.setFont("times", "normal");
        doc.text(signedBy, centerX-0.5, currentY);
        currentY += englishLineSpacing;
        doc.setFont("times", "normal");
        doc.setFontSize(spanishFontSize);
        doc.text("ha sido firmado por", labelX + 0.18, currentY);
        currentY += spanishLineSpacing;
    
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("3. acting in the capacity of", labelX, currentY);

        // Calculate the available width for wrapping the text
        const availableWidth = pageWidth/2 - marginRight ; // Adjust based on your document margins

        // Wrap the position text
        const wrappedPositionText = doc.splitTextToSize(position, availableWidth);
        doc.setFont("times", "normal");
        let wrapY = currentY;
        // Print the wrapped position text
        wrappedPositionText.forEach((line) => {
            doc.text(line, centerX-0.5, wrapY); // Adjust horizontal alignment
            wrapY += englishLineSpacing;
        });
        
        // doc.text(position, centerX-0.5, currentY);
        currentY += englishLineSpacing;
        doc.setFont("times", "normal");
        doc.setFontSize(spanishFontSize);
        doc.text("quien actúa en calidad de", labelX + 0.18, currentY);
        currentY += spanishLineSpacing;
    
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("4. bears the seal / stamp of", labelX, currentY);
        currentY += englishLineSpacing;
        doc.setFont("times", "normal");
        doc.setFontSize(spanishFontSize);
        doc.text("y está revestido del sello / timbre de", labelX + 0.18, currentY);
        currentY += spanishLineSpacing;
    
        // Centered "Certified" section
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("Certified", centerX, currentY, { align: "center" });
        currentY += englishLineSpacing;
        doc.setFont("times", "normal");
        doc.setFontSize(spanishFontSize);
        doc.text("Certificado", centerX, currentY, { align: "center" });
        currentY += 0.3;
    
        // Remaining sections
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("5. at", labelX, currentY);
        doc.setFont("times", "normal");
        doc.text(location, labelX+0.5, currentY);
        doc.setFont("times", "bold");
        doc.text("6. the", offsetValueX, currentY); // Offset by 10% from center
        doc.setFont("times", "normal");
        currentY += englishLineSpacing;
        doc.setFont("times", "normal");
        doc.setFontSize(spanishFontSize);
        doc.text("en", labelX + 0.18, currentY);
        doc.text("el día", offsetValueX + 0.2, currentY); // Align Spanish text under English
        currentY += spanishLineSpacing;
    
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("7. by", labelX, currentY);
        doc.setFont("times", "normal");
        doc.setFont("times", "bold");
        doc.text(Signing_Authority_Name, centerX-0.5, currentY);
        doc.setFont("times", "normal");
        doc.text(Signing_Authority_Title, centerX+0.85, currentY);
        currentY += englishLineSpacing;
        doc.setFont("times", "normal");
        doc.setFontSize(spanishFontSize);
        doc.text("por", labelX + 0.18, currentY);
        currentY += spanishLineSpacing;
    
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("8. Nº", labelX, currentY);
        doc.setFont("times", "normal");
        doc.setFont("times", "bold");
        doc.text(certificateNumber,  offsetValueX + 0.2, currentY);
        doc.setFont("times", "normal");
        currentY += englishLineSpacing;
        doc.setFont("times", "normal");
        doc.setFontSize(spanishFontSize);
        doc.text("bajo el número", labelX + 0.18, currentY);
        currentY += spanishLineSpacing;
    
        doc.setFont("times", "bold");
        doc.setFontSize(englishFontSize);
        doc.text("9. Seal / stamp:", labelX, currentY);
        doc.text("10. Signature:", offsetValueX, currentY); // Offset by 10% from center
        currentY += englishLineSpacing;
        doc.setFont("times", "normal");
        doc.setFontSize(spanishFontSize);
        doc.text("Sello / timbre:", labelX + 0.18, currentY);
        doc.text("Firma:", offsetValueX + 0.2, currentY);
        currentY += 0.08;
    
        // Add goldEmb image with specified dimensions and position
        // const goldEmbX = marginLeft - 0.01;  // Adjust based on column position
        // const goldEmbY = currentY + 0.01;    // Adjust based on vertical reference point

        doc.addImage(goldEmb, 'PNG', labelX, currentY, 1.7, 1.4);
        const qrX = marginLeft + 6
        currentY += 0.3;
         // Place the QR code image with specified position and dimensions
        //const qrX = pageWidth - marginRight - 0.85; // Right-aligned relative to the right margin
        // const qrY = goldEmbY + 2;                   // Adjust vertical position to avoid overlapping with other elements
        doc.addImage(veriQR, 'PNG', qrX, currentY, 0.85, 0.84);

        let linx = labelX + 1.8;
        doc.setFont("times", "bold");
        doc.setFontSize(8);
        doc.text('Verify eApostille:', linx, currentY);
        currentY += 0.153;
        doc.setFont("times", "normal");
       // Add the text
       const linkVText = 'To view / verify this document log-in to:  ';
        const linkVWidth = doc.getTextWidth(linkVText);
        doc.text('To view / verify this document log-in to  ', linx, currentY);

        const linkText = 'Apostille Verification';
        const linkWidth = doc.getTextWidth(linkText);
        doc.setLineWidth(0.001); // Set underline thickness to 0.1mm
        doc.setDrawColor(47, 85, 151);
        
        doc.textWithLink(linkText, linx+linkVWidth, currentY, { url: this.verifyUrl });
        doc.line(linx+linkVWidth, currentY + 0.015, linx + linkVWidth+ linkWidth, currentY + 0.015); 
        

        // Continue with additional text
        currentY += 0.5;
        doc.setFont("times", "normal");
        doc.text('Encryption Information?', linx, currentY);
        currentY += 0.153;

        const linkDText = 'Document Information:  ';
        const linkDWidth = doc.getTextWidth(linkDText);

        const noOfPages = this.noPages || '';

        doc.text('Document Information:  ', linx, currentY);
        doc.text(noOfPages, linx+linkDWidth, currentY );

        // Bottom Content Section
        const bottomContentY = currentY + 1.2;  // Position it slightly above the border
        const columnWidth = (pageWidth - marginLeft - marginRight) / 2 - 0.175; // Half-page width minus gap
        const leftColumnX = marginLeft;
        const rightColumnX = leftColumnX + columnWidth + 0.175; // Set 0.25-inch gap between columns

        doc.setFont("times", "normal");
        doc.setFontSize(7);

        // Bottom text content
        const englishText = [
            "This Certificate is not valid anywhere within the United States of America, its territories or possessions.",
            "This Apostille only certifies the authenticity of the signature and the capacity of the person who has signed the public document, and, where appropriate, the identity of the seal or stamp which the public document bears.",
            "This Apostille does not certify the content of the document for which it was issued.",
            "This certificate does not constitute an Apostille under the Hague Convention of October 5, 1961, for those countries that have not acceded to that Convention. If this document is to be used in a country which is not party to the Hague Convention of October 5, 1961, the certificate should be presented to the consular section of the mission representing that country."
        ];

        const spanishText = [
            "Este Certificado no es válido en ningún lugar dentro de los Estados Unidos, sus territorios o posesiones.",
            "Esta Apostilla certifica únicamente la autenticidad de la firma, la calidad en que el signatario del documento haya actuado y, en su caso, la identidad del sello o timbre del que el documento público esté revestido.",
            "Esta Apostilla no certifica el contenido del documento para el cual se expidió.",
            "Este certificado no constituye una Apostilla en virtud del Convenio de La Haya de 5 de octubre de 1961, para los países que no han adherido a la Convención. Si este documento será utilizado en un país que no es parte en el Convenio de La Haya de 5 de octubre de 1961, el certificado debe ser presentado a la sección consular de la misión que representa a ese país."
        ];

        // Render left column (English text) within the column width
        currentY = bottomContentY;
        englishText.forEach((line) => {
            const wrappedText = doc.splitTextToSize(line, columnWidth);  // Wrap text within column width
            wrappedText.forEach((textLine) => {
                doc.text(textLine, leftColumnX, currentY);
                currentY += 0.13;  // Line spacing for each wrapped line
            });
            currentY += 0.1; // Additional spacing after each paragraph
        });

        // Render right column (Spanish text) within the column width
        currentY = bottomContentY;
        spanishText.forEach((line) => {
            const wrappedText = doc.splitTextToSize(line, columnWidth);  // Wrap text within column width
            wrappedText.forEach((textLine) => {
                doc.text(textLine, rightColumnX, currentY);
                currentY += 0.13;  // Line spacing for each wrapped line
            });
            currentY += 0.1; // Additional spacing after each paragraph
        });

        // Generate PDF blob
        const pdfBlob = doc.output('blob');

        // PDF download or print functionality
        if (type === "print") {

            this.pdf("print", pdfBlob, recordId, doc);

        } else {
            console.log('i am before convertBlobToBase64()');
            this.pdf("download", pdfBlob, recordId, doc);
        }
       
    }

    async pdf(actionType, pdfBlob, recordId, doc) {
        try {
            const base64Pdf = await this.blobToBase64(pdfBlob);
            const fileName = "Apostille_Document.pdf";
    
            // Check if ContentDocument already exists for the given recordId
            console.log('Checking if document exists for recordId:', recordId);
            const checkDocResponse = await checkIfDocumentExists({
                linkedEntityId: recordId,
                fileName: fileName
            });
    
            let contentDocumentId = checkDocResponse.contentDocumentId;
            let contentVersionId = checkDocResponse.contentVersionId;

            if (!contentDocumentId) {
                console.log('No document found with specified file name, proceeding with upload...');
            } else if (contentDocumentId && fileName === "Apostille_Document.pdf") {
                console.log('Document with matching file name already exists. ContentDocumentId:', contentDocumentId, 'ContentVersionId:', contentVersionId);
            }
    
            // If document does not exist, proceed with upload
            if (fileName != "Apostille_Document.pdf") {
                console.log('Document not found, proceeding with upload...');
                const uploadResponse = await uploadPdfToIndividualApp({
                    fileName: fileName, 
                    base64Data: base64Pdf,
                    linkedEntityId: recordId,
                });
    
                contentDocumentId = uploadResponse.contentDocumentId;
                contentVersionId = uploadResponse.contentVersionId;
                console.log('Document uploaded successfully. ContentDocumentId:', contentDocumentId, 'ContentVersionId:', contentVersionId);
            } else {
                console.log('Document already exists. ContentDocumentId:', contentDocumentId, 'ContentVersionId:', contentVersionId);
            }
    
            console.log('Action type selected:', actionType);
    
            // Perform the action based on the type (print or download)
            if (actionType === "print") {
                console.log('Generating preview URL for print...');
                const previewUrl = `/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${contentVersionId}`;
                window.open(previewUrl, '_blank'); // Opens the preview in a new tab
                console.log('Navigating to file preview with URL:', previewUrl);
            } else if (actionType === "download") {
                console.log('Generating download URL...');
                const downloadUrl = `/sfc/servlet.shepherd/version/download/${contentVersionId}`;
                console.log('Download URL generated:', downloadUrl);
                const anchor = document.createElement('a');
                anchor.href = downloadUrl;
                anchor.download = fileName;
                document.body.appendChild(anchor);
                anchor.click();  // Trigger the download
                document.body.removeChild(anchor);
                console.log('Download triggered successfully.');
            } else {
                console.error('Invalid action type specified. ActionType:', actionType);
            }
        } catch (error) {
            console.error('Error handling PDF upload/preview:', error);
        }
    }    
    
    

    async blobToBase64(blob) {
        const arrayBuffer = await blob.arrayBuffer();
        const base64 = btoa(
            new Uint8Array(arrayBuffer)
                .reduce((data, byte) => data + String.fromCharCode(byte), '')
        );
        return base64;
    }

    @api
    generateApostilleCertificateNew(checkList, type) {
        this.checkList = checkList;
        console.log(this.checkList, 'CheckList data received in @api method');
        this.generatePdfDocumentNew(type); // Call the renamed internal function
    }



}
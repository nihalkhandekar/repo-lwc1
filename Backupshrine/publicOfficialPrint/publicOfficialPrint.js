import { LightningElement, api, track } from 'lwc';
import jsPDF from '@salesforce/resourceUrl/pdfGenerator';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Import toast event
import processLabelSelections from '@salesforce/apex/PublicOfficialLabelService.processLabelSelections';
import getTownClerksByTownCity from '@salesforce/apex/PublicOfficialLabelService.getTownClerksByTownCity';
import getRegistrarsByTownCity from '@salesforce/apex/PublicOfficialLabelService.getRegistrarsByTownCity';
import getMayorByTownCity from '@salesforce/apex/PublicOfficialLabelService.getMayorByTownCity';
import getLegislatorsByAddressAndType from '@salesforce/apex/PublicOfficialLabelService.getLegislatorsByAddressAndType';
import getROVLabels from '@salesforce/apex/PublicOfficialLabelService.getROVLabels';
import getOutOfStateLabels from '@salesforce/apex/PublicOfficialLabelService.getOutOfStateLabels';
import StateLabelLogo from '@salesforce/resourceUrl/StateLabelLogo';

export default class PublicOfficialPrint extends LightningElement {
    jsPdfInitialized = false;
    @track apo = false;
    stateLogoBase64;
    @track selectedTitle = '';
    @track selectedLabelType = '';
    @track legislatorAddressSelected = '';

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
        this.loadLogoAsBase64();
    }

    // Load the state label logo image as base64
    loadLogoAsBase64() {
        fetch(StateLabelLogo)
            .then(response => response.blob())
            .then(blob => {
                const reader = new FileReader();
                reader.onloadend = () => {
                    this.stateLogoBase64 = reader.result; // Store the image as a base64 string
                };
                reader.readAsDataURL(blob);
            })
            .catch(error => {
                console.error('Error loading state logo image:', error);
            });
    }

    @api
    generateLabelForTitle(labelSelections) {
        const { selectedTitle, titleValues, selectedTowns, selectedCities, labelType } = labelSelections;

        // Log the received data
        console.log('Selected Title:', selectedTitle);
        console.log('Title Values:', titleValues);
        console.log('Selected Towns:', selectedTowns);
        console.log('Selected Cities:', selectedCities);
        console.log('Label Type:', labelType);
        if(selectedTitle ==='ROV Offices'){
            this.selectedTitle = 'ROV';
        }else{
            this.selectedTitle = selectedTitle;
        }
        this.selectedLabelType = labelType;


        // Switch case to call specific function based on selected title
        switch (selectedTitle) {
            case 'Election':
                this.generateElectionLabels(titleValues, selectedTowns, selectedCities, labelType);
                break;
            case 'Town Clerk':
                this.generateTownClerkLabels(selectedTowns, selectedCities, labelType);
                break;
            case 'Registrars':
                this.generateRegistrarLabels(titleValues, selectedTowns, selectedCities, labelType);
                break;
            
            case 'Mayor/1st Selectmen':
                this.generateMayorLabels(titleValues, selectedTowns, selectedCities, labelType);
                break;
            case 'Legislator':
                this.generateLegislatorLabels(titleValues, selectedTowns, selectedCities, labelType);
                break;
            case 'ROV Offices':
                this.generateROVLabels(selectedTowns, selectedCities, labelType);
                break;
            case 'Out of State Election Offices':
                this.generateOutOfStateLabels(selectedTowns, selectedCities, labelType, titleValues);
                break;
            default:
                console.error('Unknown title:', selectedTitle);
        }
    }

    generateElectionLabels(titleValues, selectedTowns, selectedCities, labelType) {
        // Check the election month from titleValues
        let electionTitle = titleValues.electionMonth;
        console.log('Election Title:', electionTitle);
    
        // If 'Both' is selected, set both 'May' and 'Nov' for titleValues
        let electionMonths = (electionTitle === 'Both') ? ['May', 'Nov', 'Both'] : [electionTitle];
    
        // Log the updated titleValues
        console.log('Updated Title Values:', electionMonths);
    // Create a single object for the parameters
        const selectionCriteria = {
            labelType: labelType,
            selectedTowns: selectedTowns,
            selectedCities: selectedCities,
            selectedTitle: 'Election',
            titleValues: electionMonths, // Pass as an array
        };
        // Process label selections with the updated title values
        const selectionCriteriaJson = JSON.stringify(selectionCriteria);

        processLabelSelections({ selectionCriteriaJson })
        .then((result) => {
            if (result.length === 0) {
                this.showToast('No Records', 'No election officials found for the selected criteria.', 'warning');
            } else {
                this.generatePDF(result, labelType);
            }
        })
        .catch((error) => {
            console.error('Error retrieving election officials:', error);
            this.showToast('Error', 'Error retrieving election officials.', 'error');
        });
    }
    

    generateTownClerkLabels(selectedTowns, selectedCities, labelType) {
        const criteria = {
            selectedTowns: selectedTowns, // Default to an empty array if null
            selectedCities: selectedCities, // Default to an empty array if null
            labelType: labelType // Default to an empty string if null
        };
        const selectionCriteriaJson = JSON.stringify(criteria);

        getTownClerksByTownCity({selectionCriteriaJson})
        .then((result) => {
            if (result.length === 0) {
                this.showToast('No Records', 'No town clerks found for the selected criteria.', 'warning');
            } else {
                this.generatePDF(result, labelType);
            }
        })
        .catch((error) => {
            this.showToast('Error', `Error retrieving town clerks: ${error?.message || error}`, 'error');
        });        
    }

    generateRegistrarLabels(titleValues, selectedTowns, selectedCities, labelType) {
        const criteria = {
            selectedTowns: selectedTowns , // Default to an empty array if null
            selectedCities: selectedCities , // Default to an empty array if null
            labelType: labelType , // Default to an empty string if null
            selectedParties: titleValues?.registrarTypes // Safely access registrarTypes and default to empty array
        };
        const criteriaJson = JSON.stringify(criteria);

        getRegistrarsByTownCity({ criteriaJson })
        .then((result) => {
            if (result.length === 0) {
                this.showToast('No Records', 'No registrars found for the selected criteria.', 'warning');
            } else {
                this.generatePDF(result, labelType);
            }
        })
        .catch((error) => {
            this.showToast('Error', `Error retrieving registrars: ${error?.message || error}`, 'error');
        });        
    }

    generateMayorLabels(titleValues, selectedTowns, selectedCities, labelType) {
        // Ensure mayorOption is an array even when not selected
        const isAuthorized = titleValues.mayorOption && titleValues.mayorOption.length > 0;
        console.log(isAuthorized);
        const criteria ={
            selectedTowns: selectedTowns,
            selectedCities: selectedCities,
            labelType: labelType,
            isAuthorized: titleValues // Updated here
        };

        const criteriaJson = JSON.stringify(criteria);

        getMayorByTownCity({ criteriaJson })
        .then((result) => {
            if (result.length === 0) {
                this.showToast('No Records', 'No Mayor/First Selectmen found for the selected criteria.', 'warning');
            } else {
                this.generatePDF(result, labelType);
            }
        })
        .catch((error) => {
            this.showToast('Error', `Error retrieving Mayors/1st Selectmen: ${error?.message || error}`, 'error');
        });        
    }

    generateLegislatorLabels(titleValues, selectedTowns, selectedCities, labelType){

            // Extract legislatorAddress and legislatorTypes
        const legislatorAddress = titleValues.legislatorAddress;
        const legislatorTypes = [...titleValues.legislatorTypes];

        this.legislatorAddressSelected = legislatorAddress;
        // You can log or process these values as needed
        console.log('Legislator Address:', legislatorAddress);
        console.log('Legislator Types:', legislatorTypes); 
        // Call the Apex method and pass the parameters
        getLegislatorsByAddressAndType({
            legislatorAddress: legislatorAddress,
            legislatorTypes: legislatorTypes,
            labelType: this.labelType
        })
        .then((result) => {
            if (result.length === 0) {
                this.showToast('No Records', 'No Legislator found for the selected criteria.', 'warning');
            } else {
                this.generatePDF(result, labelType);
            }
        })
        .catch((error) => {
            this.showToast('Error', 'Error retrieving Legislators.', 'error');
            console.log(error);
        });

    }
    

    generateROVLabels(selectedTowns, selectedCities, labelType) {
        getROVLabels({
            selectedTowns: selectedTowns,
            selectedCities: selectedCities,
            labelType: labelType
        })
        .then((result) => {
            if (result.length === 0) {
                this.showToast('No Records', 'No ROV Offices found for the selected criteria.', 'warning');
            } else {
                this.generatePDF(result, labelType);
            }
        })
        .catch((error) => {
            this.showToast('Error', 'Error retrieving ROV Offices.', 'error');
            console.log(error);
        });
    }

    generateOutOfStateLabels(selectedTowns, selectedCities, labelType, titleValues) {
        getOutOfStateLabels({
            selectedStates: titleValues.selectedStates,
            labelType: labelType
        })
        .then((result) => {
            if (result.length === 0) {
                this.showToast('No Records', 'No out-of-state election offices found for the selected criteria.', 'warning');
            } else {
                this.generatePDF(result, labelType);
            }
        })
        .catch((error) => {
            this.showToast('Error', `Error retrieving out-of-state election offices: ${error?.message || error}`, 'error');
        });        
    }

    generatePDF(labelData, labelType) {
        switch (labelType) {
            case 'CallingList':
                this.generateCallingList(labelData); // New case for calling list
                break;
            case '5160':
                this.generate5160Label(labelData);
                break;
            case '5163':
                this.generate5163Label(labelData);
                break;
                case '5160Dymo':
                this.generate5160DymoLabel(labelData);
                break;
            case '5163Dymo':
                this.generate5163DymoLabel(labelData);
                break;
            case 'Envelope':
                this.generateEnvelope(labelData);
                break;
            case 'Portrait':  // Correct case for Portrait PDF generation
                this.generatePortraitPDFWithBorderAndLogo(labelData, labelType);  // Call the portrait function
                break;
            case 'Landscape':  
                this.generateLandscapePDFs(labelData);  // Call the Landscape PDF generation function
                break;
            default:
                console.error('Invalid label type');
                this.showToast('Error', 'Invalid label type selected.', 'error');
        }
    }
    

    // Generate PDF for Avery 5160 (3x10 layout)
    generate5160Label(labelData) {
        try {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF({
                unit: 'in',
                format: 'letter',
                orientation: 'portrait'
            });

            const xMargin = 0.26;
            const yMargin = 0.5;
            const labelWidth = 2.625;
            const labelHeight = 1;
            const labelsPerRow = 3;
            const labelsPerCol = 10;
            const xGutter = 0.125;

            doc.setFont('helvetica', 'normal');
            doc.setFontSize(8);

            let currentX = xMargin;
            let currentY = yMargin;

            labelData.forEach((label, index) => {
                const name = (label.name || '').toUpperCase(); // Convert to uppercase
                const title = (label.title || '').toUpperCase(); // Convert to uppercase
                const officeName = (label.officeName || '').toUpperCase(); // Convert to uppercase
                const addressLine1 = (label.addressLine1 || '').toUpperCase(); // Convert to uppercase
                const addressLine2 = (label.addressLine2 || '').toUpperCase(); // Convert to uppercase
                const addressLine3 = (label.addressLine3 || '').toUpperCase(); // Convert to uppercase;
                const city = (label.city || '').toUpperCase(); // Convert to uppercase
                const state = (label.state || '').toUpperCase(); // Convert to uppercase
                const postalCode = (label.postalCode || '').toUpperCase(); // Convert to uppercase

                const textLines = [
                    name,
                    `${title} ${officeName}`,
                    addressLine1,
                    addressLine2,
                    addressLine3,
                    `${city} ${state} ${postalCode}`.trim()
                ].filter(Boolean); // Remove empty lines

                const wrappedText = doc.splitTextToSize(textLines.join('\n'), labelWidth - xGutter);
                doc.text(wrappedText, currentX, currentY + 0.2);

                if ((index + 1) % labelsPerRow === 0) {
                    currentX = xMargin;
                    currentY += labelHeight;
                } else {
                    currentX += labelWidth + xGutter;
                }

                if ((index + 1) % (labelsPerRow * labelsPerCol) === 0) {
                    doc.addPage();
                    currentX = xMargin;
                    currentY = yMargin;
                }
            });

            doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf'); 
        } catch (error) {
            this.showToast('Error', 'Failed to generate PDF for 5160.', 'error');
        }
    }

    generate5163Label(labelData) {
        try {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF({
                unit: 'in',
                format: 'letter',
                orientation: 'portrait'
            });
    
            // Avery 5163 layout specifications
            const xMargin = 0.25; // Left margin for Avery 5163
            const yMargin = 0.5;  // Top margin for Avery 5163
            const labelWidth = 4; // Width of each label
            const labelHeight = 2; // Height of each label
            const labelsPerRow = 2; // Labels per row
            const labelsPerCol = 5; // Labels per column
            const xGutter = 0.125; // Horizontal gutter between labels
            const yGutter = 0; // Vertical gutter between labels
    
            // Logo dimensions and positioning within the label
            const imageWidth = 0.65;
            const imageHeight = 0.65;
    
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(9);
    
            let currentX = xMargin;
            let currentY = yMargin;
    
            labelData.forEach((label, index) => {
                // Capitalize each word in specified fields
                const name = this.capitalizeWords(label.name || '');
                const title = this.capitalizeWords(label.title || '');
                const officeName = (label.officeName || '').toUpperCase();
                const addressLine1 = this.capitalizeWords(label.addressLine1 || '');
                const addressLine2 = this.capitalizeWords(label.addressLine2 || '');
                const addressLine3 = this.capitalizeWords(label.addressLine3 || '');
                const city = this.capitalizeWords(label.city || '');
                const state = (label.state || '').toUpperCase();
                const postalCode = label.postalCode || '';
    
                // Content lines for the recipient's address
                const textLines = [
                    name,
                    `${title} ${officeName}`,
                    addressLine1,
                    addressLine2,
                    addressLine3,
                    `${city} ${state} ${postalCode}`.trim()
                ].filter(Boolean); // Remove any empty strings
    
                // Step 1: Add the state logo image to the left of the text
                if (this.stateLogoBase64) {
                    doc.addImage(this.stateLogoBase64, 'PNG', currentX + 0.2, currentY + 0.35 - 0.10, imageWidth, imageHeight);
                }
    
                // Step 2: Text for "Secretary of the State" and office address
                doc.setFont('helvetica', 'bold');
                doc.text('SECRETARY OF THE STATE', currentX + imageWidth + 0.4, currentY + 0.55- 0.10);
                doc.text('PO BOX 150470', currentX + imageWidth + 0.4, currentY + 0.69- 0.10);
                doc.text('HARTFORD, CT 06115-0470', currentX + imageWidth + 0.4, currentY + 0.83- 0.10);
    
                // Step 3: Draw a line under the "Secretary of the State" block
                doc.setFont('helvetica', 'normal');
                doc.setLineWidth(0.0039);
                doc.line(currentX + 0.1, currentY + imageHeight + 0.47- 0.10, currentX + labelWidth - 0.1, currentY + imageHeight + 0.47- 0.10);
    
                // Step 4: Add the recipient's information below the line
                doc.setFont('helvetica', 'normal');
                const wrappedText = doc.splitTextToSize(textLines.join('\n'), labelWidth - imageWidth - 0.4);
                doc.text(wrappedText, currentX + 0.1, currentY + imageHeight + 0.65- 0.10); // Positioned text under the line
    
                // Adjust position for the next label
                if ((index + 1) % labelsPerRow === 0) { // Move down to next row after two labels
                    currentX = xMargin;
                    currentY += labelHeight + yGutter;
                } else { // Move to the right for the next label in the same row
                    currentX += labelWidth + xGutter;
                }
    
                // If reaching the end of the page, add a new page
                if ((index + 1) % (labelsPerRow * labelsPerCol) === 0) {
                    doc.addPage();
                    currentX = xMargin;
                    currentY = yMargin;
                }
            });
    
            doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
        } catch (error) {
            console.error('Error generating 5163 PDF:', error);
            this.showToast('Error', 'Failed to generate PDF for 5163.', 'error');
        }
    }
    

    generateEnvelope(labelData){
        if(this.selectedTitle === 'Legislator'){
            this.generateEnvelopeFormatLegislator(labelData);
        }else{
            this.generateEnvelopeFormat(labelData);
        }
    }

    // Generate Envelope format PDF
    generateEnvelopeFormat(labelData) {
        try {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF({
                unit: 'in',
                format: [11, 4.2], // #10 Envelope dimensions
                orientation: 'landscape'
            });

            const fontSize = 16;
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(fontSize);

            const xMargin = 4.8;
            const yStart = 2.3;
            const lineSpacing = 0.25;  // Line spacing to adjust between text lines

            labelData.forEach((label, index) => {
                let currentY = yStart;


                const name = this.capitalizeWords(label.name || ''); // Apply capitalizeWords
                const title = this.capitalizeWords(label.title || ''); // Apply capitalizeWords
                const officeName = (label.officeName || '').toUpperCase(); // Keep office name fully uppercase
                const addressLine1 = this.capitalizeWords(label.addressLine1 || ''); // Apply capitalizeWords
                const addressLine2 = this.capitalizeWords(label.addressLine2 || ''); // Apply capitalizeWords
                const addressLine3 = this.capitalizeWords(label.addressLine3 || ''); // Apply capitalizeWords
                const city = this.capitalizeWords(label.city || ''); // Apply capitalizeWords
                const state = (label.state || ''); // Apply capitalizeWords
                const postalCode = this.capitalizeWords(label.postalCode || ''); // Apply capitalizeWords

                const textLines = [
                    name,
                    `${title} ${officeName}`, // Title and officeName (uppercase)
                    addressLine1,
                    addressLine2,
                    addressLine3,
                    `${city} ${state} ${postalCode}`.trim() // City, state, and postal code
                ].filter(Boolean); // Remove empty lines

                // Print each line of text separately
                textLines.forEach((line) => {
                    doc.text(line, xMargin, currentY);  // Print each line
                    currentY += lineSpacing;  // Adjust vertical spacing for the next line
                });

                // Add a new page if there are more labels
                if (index < labelData.length - 1) {
                    doc.addPage();
                }
            });

            // Save the PDF as 'Envelope_Labels.pdf'
            doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
        } catch (error) {
            this.showToast('Error', 'Failed to generate PDF for envelope format.', 'error');
            console.error('Error generating Envelope PDF:', error);
        }
    }

    // Generate Envelope format PDF
    generateEnvelopeFormatLegislator(labelData) {
        try {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF({
                unit: 'in',
                format: [11, 4.2], // #10 Envelope dimensions
                orientation: 'landscape'
            });

            const fontSize = 16;
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(fontSize);

            const xMargin = 4.8;
            const yStart = 2.3;
            const lineSpacing = 0.25;  // Line spacing to adjust between text lines

            labelData.forEach((label, index) => {
                let currentY = yStart;

                const name = this.capitalizeWords(label.name || ''); // Apply capitalizeWords
                const leftDistrict = `${label.districtType || ''} ${label.districtId || ''}`.trim();
                const addressLine1 = this.capitalizeWords(label.addressLine1 || ''); // Apply capitalizeWords
                const addressLine2 = this.capitalizeWords(label.addressLine2 || ''); // Apply capitalizeWords
                const city = this.capitalizeWords(label.city || ''); // Apply capitalizeWords
                const state = (label.state || ''); // Apply capitalizeWords
                const postalCode = this.capitalizeWords(label.postalCode || ''); // Apply capitalizeWords

                const textLines = [
                    name,
                    leftDistrict, // Title and officeName (uppercase)
                    addressLine1,
                    addressLine2,
                    `${city} ${state} ${postalCode}`.trim() // City, state, and postal code
                ].filter(Boolean); // Remove empty lines

                // Print each line of text separately
                textLines.forEach((line) => {
                    doc.text(line, xMargin, currentY);  // Print each line
                    currentY += lineSpacing;  // Adjust vertical spacing for the next line
                });

                // Add a new page if there are more labels
                if (index < labelData.length - 1) {
                    doc.addPage();
                }
            });

            // Save the PDF as 'Envelope_Labels.pdf'
            doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
        } catch (error) {
            this.showToast('Error', 'Failed to generate PDF for envelope format.', 'error');
            console.error('Error generating Envelope PDF:', error);
        }
    }

    generatePortraitPDFWithBorderAndLogo(labelData){
        if(this.selectedTitle == 'ROV' || this.selectedTitle == 'Out of State Election Offices'){
            this.generatePortraitLabelROVState(labelData);

        }else{
            this.generatePortraitLabel(labelData);
            
        }
    }

    generatePortraitLabelROVState = (labelData) => {
        try {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF({
                unit: 'in',
                format: 'letter',
                orientation: 'portrait'
            });
    
            const pageWidth = 8.5;  // Standard letter width
            const pageHeight = 11;  // Standard letter height
            const xMargin = 0.45;   // X margin for content
            const yMargin = 0.4;    // Y margin for content
            const lineSpacing = 0.15;  // Line spacing between each text line
            const labelWidth = 3.75;  // Width for each label
            const labelHeight = 1;    // Height for each label
            const labelsPerRow = 2;   // Two columns per row
            const xGutter = 0.4;      // Horizontal gap between columns
            const yGutter = 0.2;    // Vertical gap between rows (can be 0.1-0.2 inches)
    
            let currentY = yMargin;   // Initial Y position
            let currentX = xMargin;   // Initial X position
            let currentPage = 1;      // Start page numbering from the second page as "Page 1"
            let rowCount = 0;         // Track the number of rows
            let colCount = 0;         // Track the number of columns
    
            // Get the current date
            const currentDate = new Date().toLocaleString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                weekday: 'long',
                hour: 'numeric',
                minute: 'numeric',
                second: 'numeric'
            });
    
            // Add border on the first page
            addFirstPageBorder(doc, pageWidth, pageHeight);
    
            // Add the logo on the first page
            if (this.stateLogoBase64) {
                doc.addImage(this.stateLogoBase64, 'PNG', xMargin + 0.5, yMargin + 0.4, 1.5, 1.4);  // Adjusted logo size and position
            }
    
            // Position the text next to the image, aligning horizontally
            const textXStart = xMargin + 2.3;  // This moves the text next to the image
    
            // Add the static content beside the logo (State of Connecticut address)
            currentY += 0.7;  // Adjust Y for spacing next to the logo
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(14);
            doc.text('STATE OF CONNECTICUT', textXStart, currentY);
            currentY += lineSpacing + 0.1;
            doc.text('OFFICE OF THE SECRETARY OF THE STATE', textXStart, currentY);
            currentY += lineSpacing + 0.1;
            doc.text('165 Capitol Avenue, Suite 1000', textXStart, currentY);
            currentY += lineSpacing + 0.1;
            doc.text('P.O BOX 150470', textXStart, currentY);
            currentY += lineSpacing + 0.1;
            doc.text('HARTFORD, CT, 061150-0470', textXStart, currentY);
    
            // Determine the main title based on the office type
            let mainTitle = 'May Election List';  // Default title
    
            if (this.selectedTitle === 'ROV') {
                mainTitle = 'Registrar Offices';  // Set for ROV Office
            } else {
                mainTitle = 'Out of State Election Offices';  // Set for Out of State Office
            }
    
            // Add the main title (based on the condition) centered below the text
            currentY += 1.0;  // Add space before the title
            doc.setFontSize(16);
            doc.text(mainTitle, pageWidth / 2, currentY, { align: 'center' });
    
            // Footer: Add the number of records and current date on the first page
            doc.setFontSize(10);
            doc.setFont('helvetica', 'normal');
            doc.text(`There are ${labelData.length} records`, xMargin, pageHeight - 0.75);  // Bottom-left for number of records
            doc.text(`${currentDate}`, pageWidth - xMargin, pageHeight - 0.75, { align: 'right' });  // Bottom-right for the date
    
            // ** Calculate total pages ** 
            const totalLabelsPerPage = labelsPerRow * Math.floor((pageHeight - currentY) / (labelHeight + yGutter));  // Labels per page
            const totalPages = Math.ceil(labelData.length / totalLabelsPerPage);  // Total pages needed
    
            // Move to the second page for label data
            doc.addPage();
            currentY = yMargin;  // Reset Y for the content
            currentX = xMargin;  // Reset X for the content
    
            // Iterate through the label data and format it for the 2-column layout
            labelData.forEach((label) => {
                // Check if label fields are defined before using them
                const officeName = label.officeName ? label.officeName.toUpperCase() : '';  // Ensure the office name exists
                const title = label.title ? label.title.toUpperCase() : '';  // Ensure the title exists
                const city = label.city ? label.city.toUpperCase() : '';
                const state = label.state ? label.state.toUpperCase() : '';
                const postalCode = label.postalCode ? label.postalCode : '';
                const addressLine1 = label.addressLine1 ? label.addressLine1.toUpperCase() : '';  // Ensure Address Line 1 exists
                const addressLine2 = label.addressLine2 ? label.addressLine2.toUpperCase() : '';  // Ensure Address Line 2 exists
                const addressLine3 = label.addressLine3 ? label.addressLine3.toUpperCase() : '';  // Ensure Address Line 2 exists
    
                // Properly format the recipient's details in the specified format:
                // Title + Office Name
                // Address Line 1
                // Address Line 2 (optional)
                // City, State, Zip
                const recipientAddress = [
                    `${title} ${officeName}`,  // Title and Office Name
                    `${addressLine1}`,  // Address Line 1
                    `${addressLine2}`,  // Address Line 2 (optional, if available)
                    `${addressLine3}`,
                    `${city} ${state} ${postalCode}`  // City, State, Zip
                ].filter(Boolean);  // Only include non-empty values
    
                // Wrap text dynamically to fit within the label width
                const wrappedText = doc.splitTextToSize(recipientAddress.join('\n'), labelWidth - xGutter);
    
                // Check if there is enough space for the label
                const availableHeight = pageHeight - currentY;  // Calculate remaining space on the page
                if (availableHeight < labelHeight + yGutter) {
                    // Not enough space for the next label, add a new page
                    doc.text(`Page ${currentPage} of ${totalPages}`, pageWidth / 2, pageHeight - 0.4, { align: 'center' });
                    currentPage++;
                    doc.addPage();
                    currentX = xMargin;
                    currentY = yMargin;
                    rowCount = 0;
                }
    
                // Add each line of the address
                doc.setFontSize(10);
                doc.setFont('helvetica', 'normal');
                doc.text(wrappedText, currentX, currentY + 0.2);  // Add text with slight margin
    
                // Adjust position for the next label (move to the next column or start a new row)
                colCount++;
                if (colCount === labelsPerRow) {  // If we've filled both columns, move to the next row
                    currentX = xMargin;
                    currentY += labelHeight + yGutter;  // Move down to the next row
                    colCount = 0;
                    rowCount++;
                } else {
                    currentX += labelWidth + xGutter;  // Move to the next column
                }
            });
    
            // Add the final page number for the last page
            doc.text(`Page ${currentPage} of ${totalPages}`, pageWidth / 2, pageHeight - 0.4, { align: 'center' });
    
            // Save the PDF
            doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
        } catch (error) {
            console.error('Error generating portrait PDF with border and logo:', error);
        }
    
        // Function to add border to the first page
        function addFirstPageBorder(doc, pageWidth, pageHeight) {
            doc.setLineWidth(0.03);
            doc.rect(0.4, 0.4, pageWidth - 0.8, pageHeight - 0.8);
        }
    }; 


    generatePortraitLabel = (labelData) => {
        try {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF({
                unit: 'in',
                format: 'letter',
                orientation: 'portrait'
            });
    
            const pageWidth = 8.5;  // Standard letter width
            const pageHeight = 11;  // Standard letter height
            const xMargin = 0.45;   // X margin for content
            const yMargin = 0.4;    // Y margin for content
            const lineSpacing = 0.15;  // Line spacing between each text line
            const labelWidth = 3.75;  // Width for each label
            const labelHeight = 1.4;    // Height for each label
            const labelsPerRow = 2;   // Two columns per row
            const labelsPerCol = 6;   // Six rows per page
            const xGutter = 0.4;      // Horizontal gap between columns
            const yGutter = 0.125;    // Vertical gap between rows
    
            let currentY = yMargin;   // Initial Y position
            let currentX = xMargin;   // Initial X position
            let currentPage = 1;      // Start page numbering
            let rowCount = 0;         // Track the number of rows
            let colCount = 0;         // Track the number of columns
    
            // ** Pre-calculate total pages **
            const totalLabelsPerPage = labelsPerRow * labelsPerCol;
            const totalPages = Math.ceil(labelData.length / totalLabelsPerPage);
    
            // Get the current date
            const currentDate = new Date().toLocaleString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                weekday: 'long',
                hour: 'numeric',
                minute: 'numeric',
                second: 'numeric'
            });
    
            // Determine the title dynamically based on the first label's title
            let title = 'May Election List';  // Default title
    
            if (this.selectedTitle == 'Election') {
                title = 'Election List';
            } else if (this.selectedTitle == 'Town Clerk') {
                title = 'Town Clerks List';
            } else if (this.selectedTitle == 'Registrars') {
                title = 'Registrar of Voters List';
            } else if (this.selectedTitle == 'Mayor/1st Selectmen') {
                title = 'Mayor/First Selectman List';
            }else if (this.selectedTitle == 'Legislator') {
                title = 'State Legislators List';
            }
    
            // Add border on the first page
            addFirstPageBorder(doc, pageWidth, pageHeight);
    
            // Add the logo on the first page
            if (this.stateLogoBase64) {
                doc.addImage(this.stateLogoBase64, 'PNG', xMargin + 0.5, yMargin + 0.4, 1.5, 1.4);  // Adjusted logo size and position
            }
    
            // Position the text next to the image, aligning horizontally
            const textXStart = xMargin + 2.3;  // This moves the text next to the image
    
            // Add the static content beside the logo (State of Connecticut address)
            currentY += 0.7;  // Adjust Y for spacing next to the logo
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(14);
            doc.text('STATE OF CONNECTICUT', textXStart, currentY);
            currentY += lineSpacing + 0.1;
            doc.text('OFFICE OF THE SECRETARY OF THE STATE', textXStart, currentY);
            currentY += lineSpacing + 0.1;
            doc.text('165 Capitol Avenue, Suite 1000', textXStart, currentY);
            currentY += lineSpacing + 0.1;
            doc.text('P.O BOX 150470', textXStart, currentY);
            currentY += lineSpacing + 0.1;
            doc.text('HARTFORD, CT, 061150-0470', textXStart, currentY);
    
            // Add the dynamic title centered below the text
            currentY += 1.0;  // Add space before the title
            doc.setFontSize(16);
            doc.text(title, pageWidth / 2, currentY, { align: 'center' });
    
            // Footer: Add the number of records and current date on the first page
            doc.setFontSize(10);
            doc.setFont('helvetica', 'normal');
            doc.text(`There are ${labelData.length} records`, xMargin, pageHeight - 0.75);  // Bottom-left for number of records
            doc.text(`${currentDate}`, pageWidth - xMargin, pageHeight - 0.75, { align: 'right' });  // Bottom-right for the date
    
            // Move to the second page for label data
            doc.addPage();
            currentY = yMargin;  // Reset Y for the content
            currentX = xMargin;  // Reset X for the content
    
            // Iterate through the label data and format it for the 2x6 layout
            labelData.forEach((label) => {
                // Check if label fields are defined before using them
                const name = label.name ? label.name.toUpperCase() : '';  // Ensure the name exists
                const officeName = label.officeName ? label.officeName.toUpperCase() : '';  // Ensure the office name exists
                const city = label.city ? label.city.toUpperCase() : '';
                const state = label.state ? label.state.toUpperCase() : '';
                const postalCode = label.postalCode ? label.postalCode : '';
                const leftDistrict = `${label.districtType || ''} ${label.districtId || ''}`.trim();
    
                // If we've exceeded the number of rows, add a new page
                if (rowCount >= labelsPerCol) {
                    // Add the page number in the format "Page X of Y"
                    doc.text(`Page ${currentPage} of ${totalPages}`, pageWidth / 2, pageHeight - 0.4, { align: 'center' });
                    currentPage++;
    
                    doc.addPage();  // Add a new page
                    currentY = yMargin;  // Reset Y for the new page
                    rowCount = 0;  // Reset row count for the new page
                    colCount = 0;  // Reset column count for the new page
                }
    
                // Abbreviate the party name and shorten the elected field
                const partyAbbreviation = getPartyAbbreviation(label.party);
                const electedShortened = capitalizeFirstLetter(label.elected || '').slice(0, 4);

                if(this.selectedTitle === 'Legislator'){
                    // Properly format the recipient's details in uppercase, including the title
                this.recipientAddress = [
                    leftDistrict,
                    `${name} (${partyAbbreviation})`,  // Ensure the title exists
                    `${label.addressLine1 ? label.addressLine1.toUpperCase() : ''}`,  // Ensure the address exists
                    `${label.addressLine2 ? label.addressLine2.toUpperCase() : ''}`,  // Ensure the address exists
                    `${city} ${state} ${postalCode}`  // City, State, Zip in uppercase

                ].filter(Boolean);  // Only include non-empty values


                 // Define recipient's contact details
                 this.recipientContact = [
                    `Phone: ${label.phone || ''}${label.extension ? ' x' + label.extension : ''}`,  // Business phone with extension
                    `Email: ${label.email || ''}`  // Email
                ].filter(Boolean);  // Only include non-empty values
                }else{
    
                // Properly format the recipient's details in uppercase, including the title
                this.recipientAddress = [
                    name,
                    `${officeName} (${partyAbbreviation}) ${label.title ? label.title.toUpperCase() : ''} ${electedShortened}`,  // Ensure the title exists
                    `${label.addressLine1 ? label.addressLine1.toUpperCase() : ''}`,  // Ensure the address exists
                    `${label.addressLine2 ? label.addressLine2.toUpperCase() : ''}`,  // Ensure the address exists
                    `${city} ${state} ${postalCode}`  // City, State, Zip in uppercase

                ].filter(Boolean);  // Only include non-empty values

                 // Define recipient's contact details
                 this.recipientContact = [
                    `Bus: ${label.phone || ''}${label.extension ? ' x' + label.extension : ''}`,  // Business phone with extension
                    `Fax: ${label.fax || ''}`,  // Fax
                    `Email: ${label.email || ''}`  // Email
                ].filter(Boolean);  // Only include non-empty values
                }
    
    
                // Add each line of the address
                doc.setFontSize(10);
                doc.setFont('helvetica', 'normal');
                let textY = currentY;
                this.recipientAddress.forEach((line) => {
                    doc.text(line, currentX, textY);
                    textY += lineSpacing;
                });
    
                // Add the contact details below the address with a slight indent
                this.recipientContact.forEach((line) => {
                    doc.text(line, currentX + 0.3, textY);  // Indent contact details slightly
                    textY += lineSpacing;
                });
    
                // Adjust position for the next label (move to the next column or start a new row)
                colCount++;
                if (colCount === labelsPerRow) {  // If we've filled both columns, move to the next row
                    currentX = xMargin;
                    currentY += labelHeight + yGutter;  // Move down to the next row
                    colCount = 0;
                    rowCount++;
                } else {
                    currentX += labelWidth + xGutter;  // Move to the next column
                }
            });
    
            // Add the final page number for the last page
            doc.text(`Page ${currentPage} of ${totalPages}`, pageWidth / 2, pageHeight - 0.4, { align: 'center' });
    
            // Save the PDF
            doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
        } catch (error) {
            console.error('Error generating portrait PDF with border and logo:', error);
        }
    
        // Function to add border to the first page
        function addFirstPageBorder(doc, pageWidth, pageHeight) {
            doc.setLineWidth(0.03);
            doc.rect(0.4, 0.4, pageWidth - 0.8, pageHeight - 0.8);
        }
    
        // Helper function to capitalize the first letter of a string
        function capitalizeFirstLetter(string) {
            return string.charAt(0).toUpperCase() + string.slice(1).toLowerCase();
        }
    
        // Helper function to abbreviate the party name
        function getPartyAbbreviation(party) {
            switch (party) {
                case 'Democratic':
                    return 'D';
                case 'Republican':
                    return 'R';
                case 'Green':
                    return 'G';
                case 'Unaffiliated':
                    return 'U';
                case 'Unknow':
                    return 'UK';
                case 'Working Families':
                    return 'WF';
                default:
                    return '';
            }
        }
    };

    generateLandscapePDFs(labelData) {
        console.log("generateLandscapePDFS called with title:", this.selectedTitle);
        
        if (this.selectedTitle === 'Legislator') {
            console.log("Generating Legislator PDF");
            this.generateLegislatorPDF(labelData);
        } else if (this.selectedTitle === 'ROV') {
            console.log("Generating ROV PDF");
            this.generateROVPDF(labelData);
        } else {
            console.log("Generating Default PDF");
            this.generateDefaultPDF(labelData);
        }
    }

    generateLegislatorPDF(labelData) {
        console.log("Starting Legislator PDF generation");
    
        // Load jsPDF library
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF({ orientation: 'landscape', unit: 'in', format: 'letter' });
    
        // Define page dimensions and margins
        const pageWidth = 11, pageHeight = 8.5, xMargin = 0.2, yMargin = 1, lineSpacing = 0.2, sectionSpacing = 0.1;
        let currentY = yMargin, currentPage = 1;
    
        // Set headers and column widths specific to Legislator format
        const headers = ['Name', 'Address1', 'Address2', 'City/State/Zip', 'BusPhone', 'Fax', 'Email', 'Party'];
        const colWidths = [1.2, 1.4, 1, 1.4, 1, 1, 1.2, 0.8];
    
        // Helper function to capitalize words
        function capitalizeWords(str) {
            return str.split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()).join(' ');
        }
    
        // Helper function to add footer with date and page number
        function addFooter() {
            console.log("Adding footer on page:", currentPage);
            doc.line(xMargin, pageHeight - 0.7, pageWidth - xMargin, pageHeight - 0.7);
            const currentDate = new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
            doc.setFontSize(8);
            doc.text(currentDate, xMargin, pageHeight - 0.5);
            doc.text(`Page ${currentPage}`, pageWidth - xMargin, pageHeight - 0.5, { align: 'right' });
        }
    
        // Helper function to abbreviate the party name
        function getPartyAbbreviation(party) {
            return party ? party.charAt(0).toUpperCase() : '';
        }
    
        // Function to render table headers
        function renderTableHeaders() {
            console.log("Rendering table headers for Legislator");
            let currentX = xMargin;
            doc.setFont('helvetica', 'bolditalic');
            doc.setFontSize(10);
            headers.forEach((header, index) => {
                doc.text(header, currentX, currentY);
                currentX += colWidths[index];
            });
            currentY += 0.15;
            doc.setLineWidth(0.01);
            doc.line(xMargin, currentY, pageWidth - xMargin, currentY);
            currentY += 0.2;
        }
    
        // Function to render each row of data
        function renderRowData(row) {
            console.log("Rendering row data for:", row.name || row.officeName);
            let currentX = xMargin;

            const phoneWithExtension = row.phone ? `${row.phone}${row.extension ? ' x' + row.extension : ''}` : '';
    
            // Format and prepare row data
            const formattedRow = {
                name: capitalizeWords(row.name || ''),
                addressLine1: capitalizeWords(row.addressLine1 || ''),
                addressLine2: capitalizeWords(row.addressLine2 || ''),
                city: capitalizeWords(row.city || ''),
                state: row.state || '',
                postalCode: row.postalCode || '',
                phone: phoneWithExtension,
                fax: row.fax || '',
                email: row.email || '',
                party: getPartyAbbreviation(row.party)
            };
    
            // Split row data into multiple lines if necessary
            const rowData = [
                doc.splitTextToSize(formattedRow.name, colWidths[0]),
                doc.splitTextToSize(formattedRow.addressLine1, colWidths[1]),
                doc.splitTextToSize(formattedRow.addressLine2, colWidths[2]),
                doc.splitTextToSize(`${formattedRow.city} ${formattedRow.state} ${formattedRow.postalCode}`, colWidths[3]),
                doc.splitTextToSize(formattedRow.phone, colWidths[4]),
                doc.splitTextToSize(formattedRow.fax, colWidths[5]),
                doc.splitTextToSize(formattedRow.email, colWidths[6]),
                doc.splitTextToSize(formattedRow.party, colWidths[7])
            ];
    
            // Determine the maximum number of lines required for this row
            const maxLines = Math.max(...rowData.map(data => data.length));
            for (let i = 0; i < maxLines; i++) {
                currentX = xMargin;
                rowData.forEach((data, index) => {
                    doc.setFontSize(8);
                    doc.text(data[i] || '', currentX, currentY);
                    currentX += colWidths[index];
                });
                currentY += lineSpacing;
            }
            currentY += sectionSpacing;
        }
    
        // Start rendering headers
        renderTableHeaders();
    
        // Iterate over each row in labelData
        labelData.forEach((row) => {
            if (currentY > pageHeight - 1.0) { // Check if we need a new page
                console.log("Adding new page in Legislator PDF");
                addFooter();
                doc.addPage();
                currentY = yMargin; // Reset Y position for the new page
                currentPage++;
                renderTableHeaders(); // Re-render table headers on the new page
            }
    
            renderRowData(row); // Render row data
        });
    
        // Add final footer and save the PDF
        addFooter();
        doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
        console.log("Legislator PDF generation complete");
    }
    
    generateDefaultPDF(labelData) {
        console.log("Starting Default PDF generation");
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF({ orientation: 'landscape', unit: 'in', format: 'letter' });
    
        const pageWidth = 11, pageHeight = 8.5, xMargin = 0.2, yMargin = 1, lineSpacing = 0.1, sectionSpacing = 0.1;
        let currentY = yMargin, currentPage = 1, currentTown = '';
    
        // Define headers and adjusted column widths
        const headers = ['Town', 'Name', 'Address1', 'Address2', 'City/State/Zip', 'BusPhone', 'Fax', 'Email', 'Party'];
        const colWidths = [1, 1.3, 1.2, 1.2, 1.8, 1, 1, 1.2, 0.7];
    
        function capitalizeWords(str) {
            return str ? str.split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()).join(' ') : '';
        }
    
        function addFooter() {
            console.log("Adding footer on page:", currentPage);
            doc.line(xMargin, pageHeight - 0.7, pageWidth - xMargin, pageHeight - 0.7);
            const currentDate = new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
            doc.setFontSize(8);
            doc.text(currentDate, xMargin, pageHeight - 0.5);
            doc.text(`Page ${currentPage}`, pageWidth - xMargin, pageHeight - 0.5, { align: 'right' });
        }
    
        function renderTableHeaders() {
            console.log("Rendering table headers for Default PDF");
            let currentX = xMargin;
            doc.setFont('helvetica', 'bolditalic');
            doc.setFontSize(10);
            headers.forEach((header, index) => {
                doc.text(header, currentX, currentY);
                currentX += colWidths[index];
            });
            currentY += 0.15;
            doc.setLineWidth(0.01);
            doc.line(xMargin, currentY, pageWidth - xMargin, currentY);
            currentY += 0.2;
        }
    
        function renderTownHeader(townName) {
            console.log("Rendering town header for:", townName);
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(capitalizeWords(townName), xMargin, currentY);
            currentY += lineSpacing + 0.1; // Add extra space after the town name
            doc.setFont('helvetica', 'normal'); // Reset to normal font for official details
        }
    
        function renderDetailRow(row) {
            console.log("Rendering detail row for:", row.name);
            let currentX = xMargin ; // Start after the "Town" column
            const phoneWithExtension = row.phone ? `${row.phone}${row.extension ? ' x' + row.extension : ''}` : '';
    
            const formattedRow = {
                name: capitalizeWords(row.name || ''),
                addressLine1: capitalizeWords(row.addressLine1 || ''),
                addressLine2: capitalizeWords(row.addressLine2 || ''),
                city: capitalizeWords(row.city || ''),
                state: row.state || '',
                postalCode: row.postalCode || '',
                phone: phoneWithExtension,
                fax: row.fax || '',
                email: row.email || '',
                party: row.party ? row.party.charAt(0).toUpperCase() : ''
            };
    
            const rowData = [
                '',  // Leave town column blank since town is shown as header
                doc.splitTextToSize(formattedRow.name, colWidths[1]),
                doc.splitTextToSize(formattedRow.addressLine1, colWidths[2]),
                doc.splitTextToSize(formattedRow.addressLine2, colWidths[3]),
                doc.splitTextToSize(`${formattedRow.city} ${formattedRow.state} ${formattedRow.postalCode}`, colWidths[4]),
                doc.splitTextToSize(formattedRow.phone, colWidths[5]),
                doc.splitTextToSize(formattedRow.fax, colWidths[6]),
                doc.splitTextToSize(formattedRow.email, colWidths[7]),
                doc.splitTextToSize(formattedRow.party, colWidths[8])
            ];
    
            const maxLines = Math.max(...rowData.map(data => data.length));
            for (let i = 0; i < maxLines; i++) {
                rowData.forEach((data, index) => {
                    doc.setFontSize(8);
                    doc.setFont('helvetica', 'normal'); // Reset to normal font for official details
                    doc.text(data[i] || '', currentX, currentY);
                    currentX += colWidths[index];
                });
                currentY += lineSpacing;
            }
            currentY += sectionSpacing;
        }
    
        renderTableHeaders();
    
        labelData.forEach((row) => {
            // Check for page overflow
            if (currentY > pageHeight - 1.0) {
                console.log("Adding new page in Default PDF");
                addFooter();
                doc.addPage();
                currentY = yMargin;
                currentPage++;
                renderTableHeaders();
            }
    
            // Render town header only if it's a new town
            if (row.officeName !== currentTown) {
                currentTown = row.officeName;
                renderTownHeader(currentTown);  // Always show town name as header
            }
    
            // Render the details row for each official under the current town
            renderDetailRow(row);
        });
    
        addFooter();
        doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
        console.log("Default PDF generation complete");
    }
      
    generateROVPDF(labelData) {
        console.log("Starting ROV PDF generation");
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF({ orientation: 'landscape', unit: 'in', format: 'letter' });
    
        const pageWidth = 11, pageHeight = 8.5, xMargin = 0.2, yMargin = 1, lineSpacing = 0.2, sectionSpacing = 0.1;
        let currentY = yMargin, currentPage = 1, currentTown = '';
    
        // Define headers and adjusted column widths
        const headers = ['Town', 'Address1', 'Address2', 'City/State/Zip', 'BusPhone', 'Fax', 'Email', 'Party'];
        const colWidths = [1, 1.5, 1.5, 2, 1.2, 1, 1.5, 0.5];
    
        function capitalizeWords(str) {
            return str ? str.split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()).join(' ') : '';
        }
    
        function addFooter() {
            console.log("Adding footer on page:", currentPage);
            doc.line(xMargin, pageHeight - 0.7, pageWidth - xMargin, pageHeight - 0.7);
            const currentDate = new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
            doc.setFontSize(8);
            doc.text(currentDate, xMargin, pageHeight - 0.5);
            doc.text(`Page ${currentPage}`, pageWidth - xMargin, pageHeight - 0.5, { align: 'right' });
        }
    
        function renderTableHeaders() {
            console.log("Rendering table headers for ROV PDF");
            let currentX = xMargin;
            doc.setFont('helvetica', 'bolditalic');
            doc.setFontSize(10);
            headers.forEach((header, index) => {
                doc.text(header, currentX, currentY);
                currentX += colWidths[index];
            });
            currentY += 0.15;
            doc.setLineWidth(0.01);
            doc.line(xMargin, currentY, pageWidth - xMargin, currentY);
            currentY += 0.2;
        }
    
        function renderTownHeader(townName) {
            console.log("Rendering town header for:", townName);
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(10);
            doc.text(capitalizeWords(townName), xMargin, currentY);
            currentY += lineSpacing + 0.1; // Add extra space after the town name
            doc.setFont('helvetica', 'normal'); // Reset to normal font for official details
        }
    
        function renderDetailRow(row) {
            console.log("Rendering detail row for:", row.name);
            let currentX = xMargin + colWidths[0]; // Start after the "Town" column

            const phoneWithExtension = row.phone ? `${row.phone}${row.extension ? ' x' + row.extension : ''}` : '';
    
            const formattedRow = {
                addressLine1: capitalizeWords(row.addressLine1 || ''),
                addressLine2: capitalizeWords(row.addressLine2 || ''),
                city: capitalizeWords(row.city || ''),
                state: row.state || '',
                postalCode: row.postalCode || '',
                phone: phoneWithExtension,
                fax: row.fax || '',
                email: row.email || '',
                party: row.party ? row.party.charAt(0).toUpperCase() : ''
            };
    
            const rowData = [
                doc.splitTextToSize(formattedRow.addressLine1, colWidths[1]),
                doc.splitTextToSize(formattedRow.addressLine2, colWidths[2]),
                doc.splitTextToSize(`${formattedRow.city}, ${formattedRow.state} ${formattedRow.postalCode}`, colWidths[3]),
                doc.splitTextToSize(formattedRow.phone, colWidths[4]),
                doc.splitTextToSize(formattedRow.fax, colWidths[5]),
                doc.splitTextToSize(formattedRow.email, colWidths[6]),
                doc.splitTextToSize(formattedRow.party, colWidths[7])
            ];
    
            const maxLines = Math.max(...rowData.map(data => data.length));
            for (let i = 0; i < maxLines; i++) {
                currentX = xMargin + colWidths[0]; // Start each line after the "Town" column
                rowData.forEach((data, index) => {
                    doc.setFontSize(8);
                    doc.setFont('helvetica', 'normal'); // Reset to normal font for each row detail
                    doc.text(data[i] || '', currentX, currentY);
                    currentX += colWidths[index + 1]; // Skip the "Town" column width
                });
                currentY += lineSpacing;
            }
            currentY += sectionSpacing;
        }
    
        renderTableHeaders();
    
        labelData.forEach((row) => {
            // Check for page overflow
            if (currentY > pageHeight - 1.0) {
                console.log("Adding new page in ROV PDF");
                addFooter();
                doc.addPage();
                currentY = yMargin;
                currentPage++;
                renderTableHeaders();
            }
    
            // Render town header only if it's a new town
            if (row.officeName !== currentTown) {
                currentTown = row.tname;
                renderTownHeader(currentTown);  // Show town name as header
            }
    
            // Render the details row for each official under the current town
            renderDetailRow(row);
        });
    
        addFooter();
        doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
        console.log("ROV PDF generation complete");
    }

    generateLandscapePDFTest(labelData, selectedTitle) {
        function capitalizeWords(str) {
            return str.split(' ').map(word => {
                return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
            }).join(' ');
        }
    
        function renderTableHeaders() {
            currentX = xMargin;
            doc.setFont('helvetica', 'bolditalic');
            doc.setFontSize(10);
            headers.forEach((header, index) => {
                doc.text(header, currentX, currentY);
                currentX += colWidths[index];
            });
            currentY += 0.15;
            doc.line(xMargin, currentY, pageWidth - xMargin, currentY);
            currentY += 0.2;
        }
    
        function addFooter() {
            doc.line(xMargin, pageHeight - 0.7, pageWidth - xMargin, pageHeight - 0.7);
            const currentDate = new Date().toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
            doc.setFontSize(8);
            doc.text(currentDate, xMargin, pageHeight - 0.5);
            doc.text(`Page ${currentPage}`, pageWidth - xMargin, pageHeight - 0.5, { align: 'right' });
        }
    
        function renderRowData(row, showTown) {
            currentX = xMargin;
    
            const phoneWithExtension = row.phone ? `${row.phone}${row.extension ? ' x' + row.extension : ''}` : '';
    
            const formattedRow = {
                officeName: showTown ? capitalizeWords(row.officeName || '') : '',
                name: capitalizeWords(row.name || ''),
                addressLine1: capitalizeWords(row.addressLine1 || ''),
                addressLine2: capitalizeWords(row.addressLine2 || ''),
                city: capitalizeWords(row.city || ''),
                state: row.state || '',
                postalCode: row.postalCode || '',
                phone: phoneWithExtension,
                fax: row.fax || '',
                email: row.email || '',
                party: row.party ? row.party.charAt(0).toUpperCase() : ''
            };
    
            const rowData = [
                selectedTitle !== 'Legislator' ? doc.splitTextToSize(formattedRow.officeName, colWidths[0]) : '',
                selectedTitle !== 'ROV' ? doc.splitTextToSize(formattedRow.name, colWidths[selectedTitle === 'Legislator' ? 0 : 1]) : '',
                doc.splitTextToSize(formattedRow.addressLine1, colWidths[2]),
                doc.splitTextToSize(formattedRow.addressLine2, colWidths[3]),
                doc.splitTextToSize(`${formattedRow.city} ${formattedRow.state} ${formattedRow.postalCode}`, colWidths[4]),
                doc.splitTextToSize(formattedRow.phone, colWidths[5]),
                doc.splitTextToSize(formattedRow.fax, colWidths[6]),
                doc.splitTextToSize(formattedRow.email, colWidths[7]),
                doc.splitTextToSize(formattedRow.party, colWidths[8])
            ];
    
            if (showTown && formattedRow.officeName) {
                doc.setFont('helvetica', 'bold');
                doc.setFontSize(9);
                doc.text(formattedRow.officeName, xMargin, currentY);
                doc.setFont('helvetica', 'normal');
                currentY += lineSpacing;
            }
    
            const maxLines = Math.max(...rowData.slice(1).map(data => data ? data.length : 0));
    
            for (let i = 0; i < maxLines; i++) {
                currentX = xMargin + colWidths[0];
                rowData.slice(1).forEach((data, index) => {
                    doc.setFontSize(8);
                    doc.text(data[i] || '', currentX, currentY);
                    currentX += colWidths[index + 1];
                });
                currentY += lineSpacing;
            }
            currentY += sectionSpacing;
        }
    
        try {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF({
                orientation: 'landscape',
                unit: 'in',
                format: 'letter'
            });
    
            const pageHeight = 8.5;
            const xMargin = 0.2;
            const yMargin = 1;
            let currentY = yMargin;
            let currentPage = 1;
    
            const formats = {
                Default: {
                    headers: ['Town', 'Name', 'Address1', 'Address2', 'City/State/Zip', 'BusPhone', 'Fax', 'Email', 'Party'],
                    colWidths: [1, 1.2, 1.4, 1.4, 1.3, 1.1, 1, 1.2, 0.8]
                },
                Legislator: {
                    headers: ['Name', 'Address1', 'Address2', 'City/State/Zip', 'BusPhone', 'Fax', 'Email', 'Party'],
                    colWidths: [1.2, 1.4, 1, 1.4, 1, 1, 1.2, 0.8]
                },
                ROV: {
                    headers: ['Town', 'Address1', 'Address2', 'City/State/Zip', 'BusPhone', 'Fax', 'Email', 'Party'],
                    colWidths: [1, 1.4, 1, 1.4, 1, 1, 1.2, 0.8]
                }
            };
    
            const format = formats[selectedTitle] || formats.Default;
    
            doc.setLineWidth(0.0039);
            doc.setFont('helvetica', 'bolditalic');
    
            renderTableHeaders();
    
            doc.setFont('helvetica', 'normal');
    
            let currentTown = '';
            labelData.forEach((row) => {
                if (currentY > pageHeight - 1.0) {
                    addFooter();
                    doc.addPage();
                    currentY = yMargin;
                    currentPage++;
                    renderTableHeaders();
                }
    
                const showTown = row.officeName && row.officeName !== currentTown && selectedTitle !== 'Legislator';
                if (showTown) {
                    currentTown = row.officeName;
                }
    
                doc.setFont('helvetica', 'normal');
                renderRowData(row, showTown);
            });
    
            addFooter();
            doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
        } catch (error) {
            console.error('Error generating landscape PDF:', error);
            this.showToast('Error', 'Failed to generate landscape PDF.', 'error');
        }
    }
    

   // Main function to generate the PDF calling list
   generateCallingList(labelData) {

    if(this.selectedTitle === 'Legislator'){
        console.log("calling legi");
        this.generateLegislatorsCallingListPDF(labelData);
        return;
    }
    if(this.selectedTitle === 'Election'){
        this.generateElectionsTownsListPDF(labelData);
        return; 
    }
    if(this.selectedTitle === 'Town Clerk' || this.selectedTitle === 'Registrars'){
        this.generateTownClerksOrRegistrarsCallingListPDF(labelData, this.selectedTitle);
        return; 
    }
    if(this.selectedTitle === 'Mayor/1st Selectmen'){
        this.generateMayorsCallingListPDF(labelData);
        return; 
    }
    if(this.selectedTitle === 'ROV' || this.selectedTitle == 'Out of State Election Offices'){
        this.generateROVOfficesCallingListPDF(labelData, this.selectedTitle);
        return; 
    }
    }

    generateElectionsTownsListPDF(labelData) {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF({
            orientation: 'portrait',
            unit: 'in',
            format: 'letter'
        });
    
        const pageWidth = 8.5;
        const pageHeight = 11;
        const xMargin = 0.5;
        const yMargin = 0.75;
        const lineSpacing = 0.25;
        const headerSpacing = 0.2;
        let currentPage = 1;
        let currentY = yMargin;
    
        // Function to add footer with page number and date
        function addFooter() {
            doc.line(xMargin, pageHeight - 0.7, pageWidth - xMargin, pageHeight - 0.7);
            const currentDate = new Date().toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
            doc.setFontSize(8);
            doc.setFont('helvetica', 'normal');
            doc.text(currentDate, xMargin, pageHeight - 0.5); // Date on the left
            doc.text(`Page ${currentPage}`, pageWidth - xMargin, pageHeight - 0.5, { align: 'right' }); // Page number on the right
        }
    
        // Function to add header title
        function addHeader() {
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(14);
            doc.text("ELECTIONS TOWNS LIST", pageWidth / 2, currentY, { align: 'center' });
            currentY += headerSpacing + 0.5; // Adjust spacing after title
        }
    
        // Function to add column headers
        function addColumnHeaders() {
            doc.setFontSize(10);
            doc.setFont('helvetica', 'bolditalic');
            const headers = ["TOWN ID", "TOWN", "ELECTION HELD IN"];
            const columnPositions = [xMargin, xMargin + 1.5, xMargin + 4];
    
            headers.forEach((header, index) => {
                doc.text(header, columnPositions[index], currentY);
            });
            currentY += headerSpacing;
            doc.setLineWidth(0.01);
            doc.line(xMargin, currentY, pageWidth - xMargin, currentY); // Draw line under headers
            currentY += lineSpacing;
        }
    
        // Initialize PDF with header and column headers
        addHeader();
        addColumnHeaders();
    
        // Loop through each town data entry
        labelData.forEach((data) => {
            doc.setFontSize(8);
            doc.setFont('helvetica', 'normal');
            doc.text(data.officeId || '', xMargin, currentY);
            doc.text(data.officeName || '', xMargin + 1.5, currentY);
            doc.text(data.electionHeldIn || '', xMargin + 4, currentY);
            currentY += lineSpacing;
    
            // Check if we need a new page
            if (currentY > pageHeight - 1.25) {
                addFooter();
                doc.addPage();
                currentPage++;
                currentY = yMargin;
                addHeader();
                addColumnHeaders();
            }
        });
    
        addFooter(); // Add footer to the last page
        doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
    }

    generateTownClerksOrRegistrarsCallingListPDF(labelData, titleType) {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF({
            orientation: 'portrait',
            unit: 'in',
            format: 'letter'
        });
    
        const pageWidth = 8.5;
        const pageHeight = 11;
        const xMargin = 0.5;
        const yMargin = 0.75;
        const headerSpacing = 0.2;
        const lineSpacing = 0.25;
        let currentPage = 1;
        let currentY = yMargin;
    
        // Function to add footer with page number and date
        function addFooter() {
            doc.line(xMargin, pageHeight - 0.7, pageWidth - xMargin, pageHeight - 0.7);
            const currentDate = new Date().toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
            doc.setFontSize(8);
            doc.setFont('helvetica', 'normal');
            doc.text(currentDate, xMargin, pageHeight - 0.5); // Date on the left
            doc.text(`Page ${currentPage}`, pageWidth - xMargin, pageHeight - 0.5, { align: 'right' }); // Page number on the right
        }
    
        // Function to add header title based on type
        function addHeader(titleType) {
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(14);
            
            // Title at the top
            doc.text("STATE OF CONNECTICUT", pageWidth / 2, currentY, { align: 'center' });
            currentY += headerSpacing;
    
            // Subtitle for either "Town Clerk" or "Registrars"
            let subTitle = titleType === 'Town Clerk' 
                ? 'TOWN CLERK TELEPHONE NUMBERS' 
                : 'REGISTRARS CALLING LIST';
            
            doc.setFontSize(14);
            doc.text(subTitle, pageWidth / 2, currentY, { align: 'center' });
            currentY += headerSpacing + 0.2; // Adjust spacing after subtitle
        }


    
        // Function to add column headers
        function addColumnHeaders() {
            doc.setFontSize(10);
            doc.setFont('helvetica', 'bolditalic');
            const headers = ["Name", "Town Name", "Business Phone"];
            const columnPositions = [xMargin, xMargin + 2.5, xMargin + 5];
    
            headers.forEach((header, index) => {
                doc.text(header, columnPositions[index], currentY);
            });
            currentY += headerSpacing;
            doc.setLineWidth(0.01);
            doc.line(xMargin, currentY, pageWidth - xMargin, currentY); // Draw line under headers
            currentY += lineSpacing;
        }

        addHeader(titleType);
            addColumnHeaders();
    
       
    
        // Loop through each entry (either Town Clerk or Registrar)
        for (let i = 0; i < labelData.length; i++) {
            
            const entry = labelData[i];
            doc.setFontSize(8);
            doc.setFont('helvetica', 'normal');
    
            const businessPhone = entry.extension 
                ? `${entry.phone} x${entry.extension}` 
                : entry.phone;
    
            // Print Name, Town, and Business Phone
            doc.text(entry.name || '', xMargin, currentY);
            doc.text(entry.officeName || '', xMargin + 2.5, currentY);
            doc.text(businessPhone || '', xMargin + 5, currentY);
    
            currentY += lineSpacing;
    
            // Check if a new page is needed
            if (currentY > pageHeight - 1.25) {
                addFooter();
                doc.addPage();
                currentPage++;
                currentY = yMargin;
                addHeader(titleType);
                addColumnHeaders();
            }
        }
    
        addFooter(); // Add footer to the last page
        doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
    }
    

    generateMayorsCallingListPDF(labelData) {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF({
            orientation: 'portrait',
            unit: 'in',
            format: 'letter'
        });
    
        const pageWidth = 8.5;
        const pageHeight = 11;
        const xMargin = 0.5;
        const yMargin = 0.75;
        const lineSpacing = 0.25;
        const headerSpacing = 0.3;
        let currentPage = 1;
        let currentY = yMargin;
    
        // Function to add footer with page number and date
        function addFooter() {
            doc.line(xMargin, pageHeight - 0.7, pageWidth - xMargin, pageHeight - 0.7);
            const currentDate = new Date().toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
            doc.setFontSize(8);
            doc.setFont('helvetica', 'normal');
            doc.text(currentDate, xMargin, pageHeight - 0.5); // Date on the left
            doc.text(`Page ${currentPage}`, pageWidth - xMargin, pageHeight - 0.5, { align: 'right' }); // Page number on the right
        }
    
        // Function to add header title
        function addHeader() {
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(12);
            doc.text("MAYORS/FIRST SELECTMEN CALLING LIST", pageWidth / 2, currentY, { align: 'center' });
            currentY += headerSpacing + 0.2;
        }
    
        // Function to add column headers with correct alignment and lines
        function addColumnHeaders() {
            doc.setFontSize(10);
            doc.setFont('helvetica', 'bolditalic');
            const headers = ["Name", "Business Phone", "Name", "Business Phone"];
            const columnPositions = [xMargin, xMargin + 1.5, xMargin + 3.5, xMargin + 5.5];
    
            headers.forEach((header, index) => {
                doc.text(header, columnPositions[index], currentY);
            });
            currentY += headerSpacing;
            doc.setLineWidth(0.01);
            doc.line(xMargin, currentY, pageWidth - xMargin, currentY); // Draw line under headers
            currentY += lineSpacing;
        }
    
        // Initialize PDF with header and column headers
        addHeader();
        addColumnHeaders();
    
        
        // Loop through each entry and add to the document in two columns
        for (let i = 0; i < labelData.length; i += 2) {
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(8);
    
            // Left Column
            const leftData = labelData[i];
            const leftPhone = `${leftData.phone || ''}${leftData.extension ? ' x' + leftData.extension : ''}`.trim(); // Concatenate phone and extension
            doc.text(leftData.name || '', xMargin, currentY);
            doc.text(leftPhone, xMargin + 1.5, currentY);
    
            // Right Column
            if (labelData[i + 1]) {
                const rightData = labelData[i + 1];
                const rightPhone = `${rightData.phone || ''}${rightData.extension ? ' x' + rightData.extension : ''}`.trim(); // Concatenate phone and extension
                doc.text(rightData.name || '', xMargin + 3.5, currentY);
                doc.text(rightPhone, xMargin + 5.5, currentY);
            }
    
            currentY += lineSpacing;
    
            // Check if we need a new page
            if (currentY > pageHeight - 1.25) {
                addFooter();
                doc.addPage();
                currentPage++;
                currentY = yMargin;
                addHeader();
                addColumnHeaders();
            }
        }
    
        addFooter(); // Add footer to the last page
        doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
    } 
    
    
    generateLegislatorsCallingListPDF(labelData) {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF({
            orientation: 'portrait',
            unit: 'in',
            format: 'letter'
        });

        let dynamicSubTitle = ''

        if(this.legislatorAddressSelected ==='Preferred Address'){
            dynamicSubTitle = 'PREFERRED PHONE CALLING LIST'

        }else if(this.legislatorAddressSelected === 'Business Address'){
            dynamicSubTitle = 'BUSINESS PHONE CALLING LIST'

        }else if(this.legislatorAddressSelected === 'Home Address'){
            dynamicSubTitle = 'HOME PHONE CALLING LIST'

        }
        else{
            dynamicSubTitle = 'LOB PHONE CALLING LIST'

        }
    
        const pageWidth = 8.5;
        const pageHeight = 11;
        const xMargin = 0.5;
        const yMargin = 0.75;
        const lineSpacing = 0.2;
        const headerSpacing = 0.15;
        let currentPage = 1;
        let currentY = yMargin;
    
        // Footer with date and page number
        function addFooter() {
            doc.line(xMargin, pageHeight - 0.7, pageWidth - xMargin, pageHeight - 0.7);
            const currentDate = new Date().toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
            doc.setFontSize(8);
            doc.setFont('helvetica', 'normal');
            doc.text(currentDate, xMargin, pageHeight - 0.5); // Date on the left
            doc.text(`Page ${currentPage}`, pageWidth - xMargin, pageHeight - 0.5, { align: 'right' }); // Page number on the right
        }
    
        // Header with title and subtitle
        function addHeader() {
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(14);
            doc.text("LEGISLATORS", pageWidth / 2, currentY-0.1, { align: 'center' });
            currentY += headerSpacing;
    
            // Add the dynamic subtitle
            doc.text(dynamicSubTitle, pageWidth / 2, currentY, { align: 'center' });
            currentY += headerSpacing + 0.2; // Adjust spacing after subtitle
        }
    
        // Column headers with alignment and styling
        function addColumnHeaders() {
            doc.setFontSize(10);
            doc.setFont('helvetica', 'bolditalic');
            const headers = ["Name", "District", "Business Phone", "Name", "District", "Business Phone"];
            const columnPositions = [xMargin, xMargin + 1.2, xMargin + 2.3, xMargin + 4, xMargin + 5.2, xMargin + 6.4];
    
            headers.forEach((header, index) => {
                doc.text(header, columnPositions[index], currentY);
            });
            currentY += headerSpacing;
            doc.setLineWidth(0.01);
            doc.line(xMargin, currentY, pageWidth - xMargin, currentY); // Draw line under headers
            currentY += lineSpacing;
        }
    
        // Initialize PDF with header and column headers
        addHeader();
        addColumnHeaders();
    
        // Loop through each legislator and add to the document in two columns
        for (let i = 0; i < labelData.length; i += 2) {
            doc.setFontSize(7);
            doc.setFont('helvetica', 'normal');
    
            // Left Column
            const leftData = labelData[i];
            const leftDistrict = `${leftData.districtType || ''} ${leftData.districtId || ''}`.trim();
            const leftPhone = leftData.extension ? `${leftData.phone} x${leftData.extension}` : leftData.phone;
            doc.text(leftData.name || '', xMargin, currentY);
            doc.text(leftDistrict, xMargin + 1.2, currentY);
            doc.text(leftPhone || '', xMargin + 2.3, currentY);
    
            // Right Column
            if (labelData[i + 1]) {
                const rightData = labelData[i + 1];
                const rightDistrict = `${rightData.districtType || ''} ${rightData.districtId || ''}`.trim();
                const rightPhone = rightData.extension ? `${rightData.phone} x${rightData.extension}` : rightData.phone;
                doc.text(rightData.name || '', xMargin + 4, currentY);
                doc.text(rightDistrict, xMargin + 5.2, currentY);
                doc.text(rightPhone || '', xMargin + 6.4, currentY);
            }
    
            currentY += lineSpacing;
    
            // Check if new page is needed
            if (currentY > pageHeight - 1.25) {
                addFooter();
                doc.addPage();
                currentPage++;
                currentY = yMargin;
                addHeader();
                addColumnHeaders();
            }
        }

    
        addFooter(); // Add footer to the last page
        doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
    }

    generateROVOfficesCallingListPDF(labelData, title) {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF({
            orientation: 'portrait',
            unit: 'in',
            format: 'letter'
        });
    
        const pageWidth = 8.5;
        const pageHeight = 11;
        const xMargin = 0.5;
        const yMargin = 0.75;
        const lineSpacing = 0.25;
        const headerSpacing = 0.3;
        const columnSpacing = 4;
        let currentPage = 1;
        let currentY = yMargin;
    
        // Footer function with date and page number
        function addFooter() {
            doc.line(xMargin, pageHeight - 0.7, pageWidth - xMargin, pageHeight - 0.7);
            const currentDate = new Date().toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
            doc.setFontSize(8);
            doc.setFont('helvetica', 'normal');
            doc.text(currentDate, xMargin, pageHeight - 0.5);
            doc.text(`Page ${currentPage}`, pageWidth - xMargin, pageHeight - 0.5, { align: 'right' });
        }
    
        // Header function with conditional title and subtitle
        function addHeader() {
            doc.setFont('helvetica', 'bold');
            doc.setFontSize(12);
    
            if (title === "ROV") {
                doc.text("STATE OF CONNECTICUT", pageWidth / 2, currentY, { align: 'center' });
                currentY += headerSpacing;
                doc.setFontSize(11);
                doc.text("REGISTRAR OF VOTERS TELEPHONE NUMBERS", pageWidth / 2, currentY, { align: 'center' });
            } else if (title === "Out of State Election Offices") {
                doc.text("OUT OF STATE ELECTION OFFICES CALLING LIST", pageWidth / 2, currentY, { align: 'center' });
                currentY += headerSpacing;
                doc.setFontSize(11);

            }
            currentY += headerSpacing + 0.2;
        }
    
        // Column headers setup
        function addColumnHeaders() {
            doc.setFontSize(10);
            doc.setFont('helvetica', 'bolditalic');
            doc.text("Town", xMargin, currentY);
            doc.text("Business Phone", xMargin + 2, currentY);
            doc.text("Town", xMargin + columnSpacing, currentY);
            doc.text("Business Phone", xMargin + columnSpacing + 2, currentY);
            currentY += headerSpacing;
            doc.setLineWidth(0.01);
            doc.line(xMargin, currentY, pageWidth - xMargin, currentY);
            currentY += lineSpacing;
        }
    
        // Initialize PDF with header and column headers
        addHeader();
        addColumnHeaders();
    
        // Loop through labelData for two-column content layout
        for (let i = 0; i < labelData.length; i += 2) {
            doc.setFontSize(9);
            doc.setFont('helvetica', 'normal');
    
            // Left Column Data
            const leftData = labelData[i];
            const leftPhone = leftData.extension 
                ? `${leftData.phone} x${leftData.extension}` 
                : leftData.phone;
            doc.text(leftData.tname || '', xMargin, currentY);
            doc.text(leftPhone || '', xMargin + 2, currentY);
    
            // Right Column Data (if exists)
            if (labelData[i + 1]) {
                const rightData = labelData[i + 1];
                const rightPhone = rightData.extension 
                    ? `${rightData.phone} x${rightData.extension}` 
                    : rightData.phone;
                doc.text(rightData.tname || '', xMargin + columnSpacing, currentY);
                doc.text(rightPhone || '', xMargin + columnSpacing + 2, currentY);
            }
    
            currentY += lineSpacing;
    
            // Page break if needed
            if (currentY > pageHeight - 1.25) {
                addFooter();
                doc.addPage();
                currentPage++;
                currentY = yMargin;
                addHeader();
                addColumnHeaders();
            }
        }
    
        addFooter(); // Add footer to the last page
        doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
    }

    generate5160DymoLabel(labelData) {
        try {
            const { jsPDF } = window.jspdf;
    
            // Dymo label size (2.625" x 1") and page orientation as landscape
            const labelWidth = 2.625; // Width of a single label in inches
            const labelHeight = 1;    // Height of a single label in inches
            const xMargin = 0.1;      // Small margin inside the label
            const yMargin = 0.1;
    
            // Create a PDF document with label-sized pages in landscape orientation
            const doc = new jsPDF({
                unit: 'in', // Use inches for measurements
                format: [labelWidth, labelHeight], // Custom size for Dymo labels
                orientation: 'landscape' // Set page orientation to landscape
            });
    
            // Set the font and font size
            doc.setFont('helvetica', 'normal'); // Use Helvetica font, normal style
            doc.setFontSize(8); // Set font size to 8
    
            // Process each label data and add to a new page
            labelData.forEach((label, index) => {
                try {
                    // Extract and format label data
                    const name = (label.name || '').toUpperCase(); // Convert to uppercase
                    const title = (label.title || '').toUpperCase(); // Convert to uppercase
                    const officeName = (label.officeName || '').toUpperCase(); // Convert to uppercase
                    const addressLine1 = (label.addressLine1 || '').toUpperCase(); // Convert to uppercase
                    const addressLine2 = (label.addressLine2 || '').toUpperCase(); // Convert to uppercase
                    const addressLine3 = this.capitalizeWords(label.addressLine3 || ''); // Capitalize words
                    const city = (label.city || '').toUpperCase(); // Convert to uppercase
                    const state = (label.state || '').toUpperCase(); // Convert to uppercase
                    const postalCode = (label.postalCode || '').toUpperCase(); // Convert to uppercase
    
                    // Combine lines into one block of text
                    const textLines = [
                        name,
                        `${title} ${officeName}`.trim(),
                        addressLine1,
                        addressLine2,
                        addressLine3,
                        `${city} ${state} ${postalCode}`.trim()
                    ].filter(Boolean); // Remove empty lines
    
                    // Wrap text to fit within the label width
                    const wrappedText = doc.splitTextToSize(textLines.join('\n'), labelWidth - 2 * xMargin);
    
                    // Draw the text on the label
                    doc.text(wrappedText, xMargin, yMargin, { baseline: 'top' });
    
                    // Add a new page if there are more labels to process
                    if (index < labelData.length - 1) {
                        doc.addPage();
                    }
                } catch (labelError) {
                    console.error(`Error generating label for index ${index}:`, labelError);
                }
            });
    
            // Save or display the PDF
            doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
        } catch (error) {
            this.showToast('Error', 'Failed to generate PDF for Dymo labels.', 'error');
        }
    }
    
    

    generate5163DymoLabel(labelData) {
        try {
            const { jsPDF } = window.jspdf;
    
            // Define the size of a single 5163 label
            const labelWidth = 4; // Width of the label in inches
            const labelHeight = 2; // Height of the label in inches
            const xMargin = 0.25; // Left margin inside the label
            const yMargin = 0.25; // Top margin inside the label
            const imageWidth = 0.65; // Width of the logo
            const imageHeight = 0.65; // Height of the logo
    
            // Create a new PDF document with each page sized for a 5163 label
            const doc = new jsPDF({
                unit: 'in', // Use inches for measurement
                format: [labelWidth, labelHeight], // Page size matches 5163 label dimensions
                orientation: 'landscape' // Orientation is landscape
            });
    
            // Set default font
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(9);
    
            // Loop through each label data and generate a page for each
            labelData.forEach((label, index) => {
                try {
                    // Capitalize or format the label data fields
                    const name = this.capitalizeWords(label.name || '');
                    const title = this.capitalizeWords(label.title || '');
                    const officeName = (label.officeName || '').toUpperCase();
                    const addressLine1 = this.capitalizeWords(label.addressLine1 || '');
                    const addressLine2 = this.capitalizeWords(label.addressLine2 || '');
                    const addressLine3 = this.capitalizeWords(label.addressLine3 || '');
                    const city = this.capitalizeWords(label.city || '');
                    const state = (label.state || '').toUpperCase();
                    const postalCode = label.postalCode || '';
    
                    // Combine lines for the recipient's address
                    const textLines = [
                        name,
                        `${title} ${officeName}`.trim(),
                        addressLine1,
                        addressLine2,
                        addressLine3,
                        `${city} ${state} ${postalCode}`.trim()
                    ].filter(Boolean); // Remove empty strings
    
                    // Step 1: Add the state logo (if available)
                    if (this.stateLogoBase64) {
                        doc.addImage(this.stateLogoBase64, 'PNG', xMargin, yMargin, imageWidth, imageHeight);
                    }
    
                    // Step 2: Add "Secretary of the State" and office address text
                    doc.setFont('helvetica', 'bold');
                    doc.text('SECRETARY OF THE STATE', xMargin + imageWidth + 0.2, yMargin + 0.2);
                    doc.text('PO BOX 150470', xMargin + imageWidth + 0.2, yMargin + 0.35);
                    doc.text('HARTFORD, CT 06115-0470', xMargin + imageWidth + 0.2, yMargin + 0.5);
    
                    // Step 3: Draw a line under the "Secretary of the State" block
                    doc.setLineWidth(0.0039);
                    doc.line(xMargin, yMargin + imageHeight + 0.1, labelWidth - xMargin, yMargin + imageHeight + 0.1);
    
                    // Step 4: Add the recipient's address below the line
                    doc.setFont('helvetica', 'normal');
                    const wrappedText = doc.splitTextToSize(textLines.join('\n'), labelWidth - xMargin * 2);
                    doc.text(wrappedText, xMargin, yMargin + imageHeight + 0.25);
    
                    // Add a new page for the next label (if there are more labels to process)
                    if (index < labelData.length - 1) {
                        doc.addPage();
                    }
                } catch (labelError) {
                    console.error(`Error generating label for index ${index}:`, labelError);
                }
            });
    
            // Save or display the PDF
            doc.save(this.selectedTitle + '_' + this.selectedLabelType + '.pdf');
        } catch (error) {
            console.error('Error generating 5163 Dymo PDF:', error);
            this.showToast('Error', 'Failed to generate PDF for 5163 Dymo labels.', 'error');
        }
    }
    
    
    
    

    
    



    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    



    
    
    
    
    

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    // Helper function to capitalize the first letter of each word
    capitalizeWords(str) {
        return str.split(' ').map(word => {
            return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
        }).join(' ');
    }

    

    

}
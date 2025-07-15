/**
 * Connot have as utility class as:
 * 1. used in aura & lwc
 * 2. ondocumentcomplete event
 */
import { LightningElement, api } from 'lwc';
import pdflibResource from '@salesforce/resourceUrl/PDFLib';
import { loadScript } from 'lightning/platformResourceLoader';
import getPDFs from '@salesforce/apex/UCCFileMerge.getPDFs';
import saveChunkedFile from '@salesforce/apex/UCCFileMerge.saveChunkedFile';
import { ComponentErrorLoging } from "c/formUtility";
import SSO_JIT_UserTimeZone from '@salesforce/label/c.SSO_JIT_UserTimeZone';
import brs_FilingOnline from '@salesforce/label/c.brs_FilingOnline';
import BRS_FilingStatus_Rejected from '@salesforce/label/c.BRS_FilingStatus_Rejected';
import Merge_Doc_Overlay_Header_Biz_Name from '@salesforce/label/c.Merge_Doc_Overlay_Header_Biz_Name';

const CHUNK_SIZE = 3000000; //10^6 ~ 1MB | ~3MB client payload
export default class UccFileMerge extends LightningElement {
    isLoading;
    @api
    filingStatus;
    @api
    boFiling;

    label = {
        SSO_JIT_UserTimeZone,
        brs_FilingOnline,
        BRS_FilingStatus_Rejected,
        Merge_Doc_Overlay_Header_Biz_Name
    }

    connectedCallback(){
        if(this.boFiling){
            this.createMergeDocument(this.boFiling);        
        }
    }

    @api
    createMergeDocument(filing) {
        if (filing) {
            this.isLoading = true;

            getPDFs({
               filing: filing,
               status: this.filingStatus
              
            })
                .then(response => {
                    var data = JSON.parse(JSON.stringify(response));
                    //Only execute script if contains uploaded file
                    if (data && data.listFileContents && (data.listFileContents.length > 1 || data.isOnlyUploadedFiles)) {
                        let sfFilingDate = data.filingDate;
                        loadScript(this, pdflibResource + '/pdf-lib.min.js')
                            .then(() => {
                                this.initializePdfLib(filing, data.listFileContents, sfFilingDate, data.isOnlyUploadedFiles);
                            });
                    } else if (data) {
                        this.isLoading = false;
                        this.dispatchEvent(new CustomEvent('documentcompleted', { detail: data.downloadUrl }));
                    }
                })
                .catch(error => {
                    this.isLoading = false;
                    ComponentErrorLoging("uccFileMerge", "getPDFs", "", "", "Medium", error.message);
                });
        }
    }

    initializePdfLib = async (filing, fileContents, sfFilingDate, isOnlyUploadedFiles) => {
        const doc = await PDFLib.PDFDocument.create();
        let filingDate = this.filingStatus != this.label.BRS_FilingStatus_Rejected && sfFilingDate ? sfFilingDate : null

        let totalPages = 0;
        let pageIndex = 0;
        let listColPages = [];

        //1. sdoc content
        if (!isOnlyUploadedFiles) {
            const sDocFile = await PDFLib.PDFDocument.load(fileContents[0]);
            const sDocPages = await doc.copyPages(sDocFile, sDocFile.getPageIndices());
            totalPages = sDocPages.length;

            //2. Scanned copy/Collateral
            if (this.filingStatus != this.label.BRS_FilingStatus_Rejected && fileContents.length > 1) {
                for (let i = 1; i < fileContents.length; i++) {
                    const collateral = await PDFLib.PDFDocument.load(fileContents[i]);
                    let colPages = await doc.copyPages(collateral, collateral.getPageIndices());

                    listColPages.push(colPages);
                    totalPages += colPages.length;
                }
            }

            //3. if not sdocs, add overlay
            for (const page of sDocPages) {
                pageIndex++;

                if (this.filingStatus != this.label.BRS_FilingStatus_Rejected && (
                    (filing.Source__c && filing.Source__c != this.label.brs_FilingOnline)
                    ||
                    (filing.Filing_Source__c && filing.Filing_Source__c != this.label.brs_FilingOnline)
                )) {
                    this.drawTextColl(page, filing, filingDate, pageIndex, totalPages);
                }
                else if (this.filingStatus != this.label.BRS_FilingStatus_Rejected) {
                    this.drawTextSdocs(page, filing, filingDate, pageIndex, totalPages);
                }

                doc.addPage(page);
            }

            //4. Adding collaterals to merged doc
            if (listColPages && listColPages.length > 0) {
                for (const colPages of listColPages) {
                    for (const page of colPages) {
                        pageIndex++;
                        this.drawTextColl(page, filing, filingDate, pageIndex, totalPages);
                        doc.addPage(page);
                    }
                }
            }
        } else {
            //1. Scanned copy/Collateral
            if (this.filingStatus != this.label.BRS_FilingStatus_Rejected && fileContents.length > 0) {
                for (let i = 0; i < fileContents.length; i++) {
                    const collateral = await PDFLib.PDFDocument.load(fileContents[i]);
                    let colPages = await doc.copyPages(collateral, collateral.getPageIndices());

                    listColPages.push(colPages);
                    totalPages += colPages.length;
                }
            }

            //2. Adding collaterals to merged doc
            if (listColPages && listColPages.length > 0) {
                for (const colPages of listColPages) {
                    for (const page of colPages) {
                        pageIndex++;
                        this.drawTextColl(page, filing, filingDate, pageIndex, totalPages);
                        doc.addPage(page);
                    }
                }
            }
        }

        const pdfBytes = await doc.saveAsBase64({ dataUri: false });
        let startPosition = 0;
        let endPosition = Math.min(pdfBytes.length, startPosition + CHUNK_SIZE);
        //send back to SF to create merged doc
        this.createMergedFile(filing, pdfBytes, startPosition, endPosition, null);
    };

    createMergedFile(filing, pdfBytes, startPosition, endPosition, fileId) {
        let chunk = pdfBytes.substring(startPosition, endPosition);
        let downloadUrl;
        saveChunkedFile({
            filing: filing,
            base64Data: encodeURIComponent(chunk),
            fileId: fileId
        })
            .then(result => {
                let resultObj = JSON.parse(JSON.stringify(result));
                fileId = resultObj.fileVersionId;
                downloadUrl = resultObj.downloadUrl;
                startPosition = endPosition;
                endPosition = Math.min(pdfBytes.length, startPosition + CHUNK_SIZE);

                if (startPosition < endPosition) { //to-do | while
                    this.createMergedFile(null, pdfBytes, startPosition, endPosition, fileId);
                } else {
                    this.isLoading = false;
                    this.dispatchEvent(new CustomEvent('documentcompleted', { detail: downloadUrl }));
                }
            });
    }

    drawTextColl(page, filing, filingDate, pageIndex, totalPages) {
        const stdPageWidth = 612;            // 612 points equal to std. page width -> 8.5in, font size -> 10
        const { width, height } = page.getSize();
        const multiplyFactor = width / 612;
        const fontSize = 10 * multiplyFactor;

        //filing details
        page.drawText(
            this.label.Merge_Doc_Overlay_Header_Biz_Name + ' - Filing Number: '
            + (filing.Sdoc_Filing_Number__c ? filing.Sdoc_Filing_Number__c : filing.Name)
            + (filingDate ? ' - Filing Date: ' + filingDate : ''),
            {
                x: width - (width / 2) - (175 * multiplyFactor),
                y: height - (10 * multiplyFactor),
                size: fontSize,
            }
        );
        //page no
        page.drawText(
            'Page ' + pageIndex + ' of ' + totalPages,
            {
                x: width - (width / 2) - (20 * multiplyFactor),
                y: 10 * multiplyFactor,
                size: fontSize
            }
        );
    }

    drawTextSdocs(page, filing, filingDate, pageIndex, totalPages) {
        const { width, height } = page.getSize();

        //page no
        page.drawText(
            'Page ' + pageIndex + ' of ' + totalPages,
            {
                x: width - (width / 2) - 20,
                y: 10,
                size: 10
            }
        );
    }
}
/* ********************************************************************************************
* NAME       :  qnA_FileSectionComponent
* DESCRIPTION:  This component display the File subsection type using record edit form both in Editable and 
RealOnly mode and also display theReview mode. This component is called from QnA_FlowContainer and LnP_ReviewSection
Components And hanlde all opertaions implmented on the subsection
*
* @AUTHOR Sabhyata Rao
* @DATE 31/03/2020
*
*
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* ================================================================================
* Sabhyata Rao                       31/03/2020                   Created the first version
*
********************************************************************************************* 
*/
import { LightningElement, api } from 'lwc';
import fetchFileSubsectionRecord from '@salesforce/apex/QnA_FlowController.fetchFileSubsectionRecord';
import { ComponentErrorLoging } from "c/formUtility";
export default class qnA_FileSectionComponent extends LightningElement {
    @api subsection;
    @api parentrecordid;
    @api parentobjectname;
    @api sectionIndex;
    @api index;
    @api editRecordIndex;
    @api flowconfig;
    @api spinner = false
    @api isReview;
    @api recordId;
    @api compName = 'qnA_FileSectionComponent';

    connectedCallback() {
        try {
            if (this.subsection.isServerCallDone === false) {
                fetchFileSubsectionRecord({
                    parentObjectName: this.parentobjectname,
                    parentID: this.parentrecordid,
                    questions: JSON.stringify(this.subsection.files)
                })

                    .then(response => {
                        this.spinner = false;
                            let sections = flowconfig.sections;
                            this.sections.subsections.files = response;
                            this.sections.subsections.isServerCallDone = true;
                            this.flowconfig = sections;
                            this.flowconfig = config;                            
                        
                    }).catch(error => {
                        this.spinner = false;
                        ComponentErrorLoging(
                            this.compName,
                            "fetchFileSubsectionRecord",
                            "",
                            "",
                            "Medium",
                            error.message
                          );
                    });

            }
        }
        catch (error) {
            this.spinner = false;
            ComponentErrorLoging(
                this.compName,
                "connectedCallBack",
                "",
                "",
                "Medium",
                error.message
              );
        }

    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        try {
            var uploadedFiles = event.detail.files;
            const sections = this.flowconfig.sections;
            var previousFiles = sections.subsections.files.uploadedFiles;
            var fileIds = [];
            uploadedFiles.forEach(function (file) {
                fileIds.push(file.documentId);
            });
            const flow = this.flowconfig;
            const parentId = this.parentrecordid;
            const parentObjName = flow.parentobjectname;
            const questionId = sections.subsections.files.id;
            const responseId = sections.subsections.files.responseID;
            const attachmentName = sections.subsections.files.attachmentName;
            linkFiles({
                parentObjName: parentObjName,
                parentId: parentId,
                questionId: questionId,
                questionBody: attachmentName,
                responseId: responseId,
                documentIds: fileIds
            })

                .then(resp => {
                    /**
                     * On success update the files list on the question object, using the indexes
                     * extracted.
                     */
                    if (previousFiles) {
                        for (var i = 0; i < previousFiles.length; i++) {
                            fileIds.push(previousFiles[i]);
                        }
                    }
                    this.flow.sections.subsections.files.responseID = resp;
                    this.sections.subsections.files.uploadedFiles = fileIds;
                    this.flow.sections = sections;
                    this.flowconfig = flow;
                });
        }
        catch (error) {
            this.spinner = false;
            ComponentErrorLoging(
                this.compName,
                "linkFiles",
                "",
                "",
                "Medium",
                error.message
              );
        }

    }

    @api fIndex = ''
    get computeFileName() {
        return this.index + "-" + this.fIndex;
    }

    idIndex = '';
    fileData = '';
    
    get ComputeButtonName() {
        return this.index + "-" + this.idIndex + "-" + this.fIndex + "-" + this.fileData;
    }

    deleteFile(event) {
        try {
            /**
     * Delete file handler. Get the document id from 'name' attribute.
     */
            var recordID = event.target.value.name;
            var menuItemNo = recordID.split("-");
            /**
             * Get all indexes from name splits.
             */
            if (menuItemNo.length > 4) {
                let secIndex = parseInt(menuItemNo[0]);
                let subsecIndex = parseInt(menuItemNo[1]);
                let fieldIndex = parseInt(menuItemNo[2]);
                let fileIndex = parseInt(menuItemNo[3]);
                let record = menuItemNo[4];
                /**
                 * make the apex call to delete the record.
                 */
                deleteRecord({ recordID: record }).then(result => {
                    if (result.toUpperCase() === "SUCCESS") {
                        /**
                         * If the deletion is successfull. Delete the file from 'uploadedFiles' list of the
                         * question and update the flow.
                         */
                        const sections = flowConfig.sections;
                        sections[secIndex].subsections[subsecIndex].files[fieldIndex].uploadedFiles.splice(fileIndex, 1);
                        var config = flowConfig;
                        config.sections = sections;
                        this.flowConfig = config;
                    } else {
                        /**
                         * If the deletion fails, show error toast.
                         */
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'Error file section cmp',
                        });
                        this.dispatchEvent(event);
                    }
                });
            }

        }
        catch (error) {
            this.spinner = false;
            ComponentErrorLoging(
                this.compName,
                "deleteRecord",
                "",
                "",
                "Medium",
                error.message
              );
        }
    }
}
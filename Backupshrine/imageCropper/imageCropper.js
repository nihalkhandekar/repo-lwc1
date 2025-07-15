import { LightningElement, track, api } from 'lwc';
import cropperRes from '@salesforce/resourceUrl/CropperJS';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import saveFile from '@salesforce/apex/BRS_ImageCropper.saveFile'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UploadImage from "@salesforce/label/c.UploadImage";
import CropImage from "@salesforce/label/c.CropImage";
import modalclose from "@salesforce/label/c.modal_close";
import CancelButton from "@salesforce/label/c.CancelButton";
import CropButton from "@salesforce/label/c.CropButton";
import FileTypeError from "@salesforce/label/c.FileTypeError";
import EmptyFileError from "@salesforce/label/c.EmptyFileError";
import Imageuploadsuccessmsg from "@salesforce/label/c.Imageuploadsuccessmsg";
import RanIntoErrorMsg from "@salesforce/label/c.RanIntoErrorMsg";
import { ComponentErrorLoging } from "c/formUtility";

const MAX_FILE_SIZE = 4500000;
const CHUNK_SIZE = 750000;
export default class ImageCropper extends LightningElement {
    @track toUploadImg = true;
    @track toCropImg = false;
    @track propFileBody;
    @track propFileName;
    @track propContentType;
    @track isModalOpen = false;
    @api recordId;
    @track isloading = false;
    cropper;
    fileName='';
    fileUploaded=[];
    fileSize;
    fileCon;
    image;
	@track compName = 'ImageCropper';
	@track label = {
        UploadImage,
		CropImage,
		modalclose,
		CancelButton,
		CropButton,
		FileTypeError,
		EmptyFileError,
		Imageuploadsuccessmsg,
		RanIntoErrorMsg
    };
    connectedCallback(){
        loadStyle(this, cropperRes + '/cropper.min.css')
        .then(() => {});

    }
    handleFileChange(event){
        if(event.target.files.length > 0)
        {
            this.fileName = event.target.files[0].name;
            this.fileUploaded = event.target.files;
        }
    }
    showToast(msg,type) {
        var titlename = type + '!!';
        const event = new ShowToastEvent({
            title: titlename,
            message: msg,
            variant: type,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    submitFile(){
        if(!this.fileName)
        {
            this.showToast(this.label.EmptyFileError,'info');
            this.fileName = '';
        }
        if(this.fileName){
            this.fileCon = this.fileUploaded[0];
            var fileTypeIndex = (this.fileName).lastIndexOf('.');
            var fileType = (this.fileName).substring(fileTypeIndex+1);
            if (!["png","jpg","jpeg"].includes(fileType))
            {
                this.showToast(this.label.FileTypeError,'info');
                this.fileName = '';
            }
            else{
                var reader = new FileReader();
                var self = this;
                reader.onload = function(){
                    var fileContents = reader.result;
                    var base64Mark = 'base64,';
                    var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                    fileContents = fileContents.substring(dataStart);
                    self.upload(fileContents);
                };
                reader.readAsDataURL(this.fileCon);
            }
        }
    }
    upload(fileContents){
        this.isModalOpen = true;
        loadScript(this, cropperRes + '/cropper.min.js')
        .then(() => {
            this.image = this.template.querySelector('.image');
            this.done(URL.createObjectURL(this.fileCon));
            var pre = this.template.querySelector('.preview');
            this.cropper = new Cropper(this.image, {
                aspectRatio: NaN,
                viewMode: 3,
                preview: pre
            });
            var imageData = this.cropper.getImageData();
            var canvasData = this.cropper.getCanvasData();
        })
        .catch(error => {
            ComponentErrorLoging(
            this.compName,
            "upload",
            "",
            "",
            this.severity,
            error.message
          );
        })
        

    }
    done(url){
        this.image.src = url;
    }
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isloading = false;
        this.isModalOpen = false;
        this.cropper.destroy();
        this.cropper = null;
        this.closeQuickAction();
    }
    submitDetails() {
        var base64data;
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        var recid = this.recordId;
        var isspinner = this.isloading;
        this.isloading = true;
        var self = this;
        loadScript(this, cropperRes + '/cropper.min.js')
        .then(() => {
            var canvas = this.cropper.getCroppedCanvas({
                width: 160,
                height: 160,
            });
            canvas.toBlob(function(blob) {
                var aa = canvas.toDataURL();
                var url = URL.createObjectURL(blob);
                var reader = new FileReader();
                reader.readAsDataURL(blob);
                reader.onloadend = function() {
                    base64data = reader.result;
					saveFile({
						basebob: base64data,
						recId : recid
					}).then(response => {
                        self.showToast(self.label.Imageuploadsuccessmsg,response);
                        self.closeModal();
                    })
                .catch(error => {
                        var err = self.label.RanIntoErrorMsg + error;
                        self.showToast(err,'error');
                    })
                };
            });
        })
        .catch(error => {
            ComponentErrorLoging(
            this.compName,
            "submitDetails",
            "",
            "",
            this.severity,
            error.message
          );
        })
    }
}
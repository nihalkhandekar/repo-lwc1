import { LightningElement, track,api } from 'lwc';
import { ComponentErrorLoging } from "c/formUtility";

export default class QnAQuestionHelpText extends LightningElement {
    @api helptextnotes;
    @api headinghelptext;
    @api inputclassname='';
    @track helpTextNotesPresent = false;
    @track headingHelpTextPresent = false;
    @track compName='QnAQuestionHelpText';

    /**
     * Check if each type of help-text is present.
     */
    updateHelpText(){
        try{
            if(this.helptextnotes!==null && this.helptextnotes!==undefined){
                    this.helpTextNotesPresent = true;
            }
            if(this.headinghelptext!==null && this.headinghelptext!==undefined){
                this.headingHelpTextPresent = true;
            }
        } catch(error){
        ComponentErrorLoging(this.compName, 'updateHelpText', '', '', 'Low', error);
        }
    }

    @api 
    get questionid(){
        return this._questionid;
    }

    set questionid(value){
        this._questionid = value;
        this.helpTextNotesPresent = false;
        this.updateHelpText();
    }
}
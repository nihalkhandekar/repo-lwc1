import { LightningElement, track, api } from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import communityMainFlowPage from "@salesforce/label/c.Community_Main_Flow_Page_Name";
import communityBRSMainFlowPage from "@salesforce/label/c.Community_BRS_Main_FlowPageName";
import { ComponentErrorLoging } from "c/formUtility";
import { insertRecord } from "c/genericAnalyticsRecord";
import analyticsRecord_helpText from "@salesforce/label/c.analyticsRecord_helpText";

export default class QnASubsectionHelpText extends LightningElement {
  @track linkSearch = assetFolder + "/icons/DocSearch@2x.png";
  @api helptextstatic;
  @api helptextlinklabel;
  @api helptextlinkurls;
  @track staticTextPresent = false;
  @track linkPresent = false;
  @track parentId;
  @api sectiontitle;
  @api response;
  @track linkLabelsList = [];
  @track linkURLsList = [];
  @track linkLabelUrlFinalList = [];
  @track showHelpText = false;
  @track currentQuestionId;
  isLoaded = false;

  @api 
  get questionid(){
      return this._questionid;
  }

  set questionid(value){

    this._questionid = value;
    if(this.currentQuestionId != this._questionid){
        this.currentQuestionId = this._questionid
        this.linkLabelUrlFinalList = [];
        this.updateHelpText();
    }
    
        
  }
  /**
   * Get Subsection helptext information(Static and Links).
   */
  updateHelpText() {
	  try{
    if (this.helptextstatic !== null && this.helptextstatic !== undefined) {
      this.staticTextPresent = true;
    }
    if ((window.location.href.indexOf(communityMainFlowPage) > -1) ||
		window.location.href.indexOf(communityBRSMainFlowPage) > -1 ||
		(window.location.href.indexOf('businesslocation') > -1)) {
      this.showHelpText = true;
    }
    if (
      this.helptextlinklabel !== null &&
      this.helptextlinklabel !== undefined
    ) {
      this.linkPresent = true;
      /*const labels = JSON.stringify(this.helptextlinklabel);
        if(labels.includes(';')){
          this.linkLabelsList = labels.split(';');
        }else{
          this.linkLabelsList.push(labels);
        }
        
        const urls = JSON.stringify(this.helptextlinkurls);
        this.linkURLsList = urls.split(';');*/
      for (var i = 0; i < this.helptextlinklabel.length; i++) {
        if (
          this.helptextlinkurls !== null &&
          this.helptextlinkurls !== undefined
        ) {
          const tempVar = {
            label: String(this.helptextlinklabel[i]).replace(/(&quot\;)/g,'"'),
            url: this.helptextlinkurls[i]
          };
          this.linkLabelUrlFinalList.push(tempVar);
        } else {
          const tempVar = {
            label: String(this.helptextlinklabel[i]).replace(/(&quot\;)/g,'"'),
            url: ""
          };
          this.linkLabelUrlFinalList.push(tempVar);
        }
      }
    }
    }
    catch (error) {
    ComponentErrorLoging('QnASubsectionHelpText', 'updateHelpText', '', '', 'Low', error.message);
    }
  }
  
  connectedCallback() {
    var url_string = document.location.href;
    var url = new URL(url_string);
    var arr = url_string.split("?");
    if (url_string.length > 1 && arr[1] !== "") {
      var URLParams = url.searchParams;
      this.parentId = URLParams.get("c__parentObjId");
    }
  }
  
  renderedCallback(){
    if(!this.isLoaded){
      let startTime = new Date().getTime();
      let self = this;
      const temp = this.template.querySelectorAll('a');
      if(temp && temp.length){
        this.isLoaded = true;
        temp.forEach(element => {
          element.addEventListener("click", function(event){
            event.preventDefault();      
            setTimeout((function(ev){
             insertRecord(
               self.parentId, 
               self.sectiontitle, 
               JSON.stringify(self.response.Question_Body__c).replace(/\"/g, ""), 
               JSON.stringify(self.response.Given_Response__c).replace(/\"/g, ""),
               communityMainFlowPage,
               analyticsRecord_helpText,
               ev.target.getAttribute("href"),
               ev.target.textContent,
               startTime,
               "");
              window.open(ev.target.getAttribute("href"), '_blank');
            })(event), 2000);
          });
        });                
      }
      this.isLoaded = false;
    }  
  }
}
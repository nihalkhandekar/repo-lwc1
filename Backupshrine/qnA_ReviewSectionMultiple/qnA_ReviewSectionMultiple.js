import { LightningElement, api, track } from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import ReviewPage_heading from "@salesforce/label/c.ReviewPage_heading";
import ReviewPage_subHeader from "@salesforce/label/c.ReviewPage_subHeader";
import ReviewPage_listHeader from "@salesforce/label/c.ReviewPage_listHeader";
import ReviewPage_listItem1 from "@salesforce/label/c.ReviewPage_listItem1";
import ReviewPage_listItem2 from "@salesforce/label/c.ReviewPage_listItem2";
import ReviewPage_listItem3 from "@salesforce/label/c.ReviewPage_listItem3";
import pipelineSeparator from "@salesforce/label/c.Pipeline_Separator_UI";
import hyphen from "@salesforce/label/c.QnA_hyphen";
import edit from "@salesforce/label/c.Edit_btn";
import object from "@salesforce/label/c.QnA_Object";
import braces from "@salesforce/label/c.QnA_ObjectBraces";
import squarebraces from "@salesforce/label/c.QnA_ListBraces";
import noneOfTheOptions from "@salesforce/label/c.ReviewPage_BlankAnswer";

export default class qnA_ReviewSection extends LightningElement {
  @api sections;
  @api parentRecordID;
  @api parentObjectName;
  @api overrideNotNull;
  @api mapToShow = [];
  @track reviewCheckList = assetFolder + "/icons/reviewImage.svg";
  @track showCheckList = true;

  label = {
    ReviewPage_heading,
    ReviewPage_subHeader,
    ReviewPage_listHeader,
    ReviewPage_listItem1,
    ReviewPage_listItem2,
    ReviewPage_listItem3,
    edit,
    hyphen,
    object,
    braces,
    squarebraces,
    noneOfTheOptions
  };
  @api
  get flowconfig() {
    return this._flowconfig;
  }

  set flowconfig(value) {
    this._flowconfig = value;
  }
  @api
  get allvisiblesection() {
    return this._allvisiblesection;
  }

  set allvisiblesection(value) {
    this._allvisiblesection = value;
    this.mergeSection(value);
  }
  get subsectioncheck() {
    return subsection.componentOverride != null ? true : false;
  }
  connectedCallback() {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  } 
  updatemap(allSection) {
    let localList = [];
    let alldata = JSON.parse(JSON.stringify(allSection));
    for (var keyValue in alldata) {
      let keyData = keyValue.split(hyphen);
      let iconData = JSON.parse(
        JSON.stringify(keyData[0].replace(/ /g, hyphen))
      );
      let icon = iconData.toLowerCase();
      for (var key in alldata[keyValue]) {
        let answer = alldata[keyValue][key].responseText;
        
        if (answer === "" || answer === undefined) {
          answer = '';
        } else if (answer.startsWith(braces)) {
          answer = JSON.parse(answer);
        }

        if (typeof answer === object) {
          var tempArr = [];
          for (var i = 0; i < answer.length; i++) {
            var temp = answer[i].name;
              tempArr.push(temp);
          }
            answer = tempArr;
          alldata[keyValue][key].isList = true;
        } else if (answer.includes(pipelineSeparator)) {
          answer = answer.split(pipelineSeparator);
          alldata[keyValue][key].isList = true;
        } else {
          alldata[keyValue][key].isList = false;
        }
        alldata[keyValue][key].displayResponseArray = answer;
       if( alldata[keyValue][key].responselabel !=undefined ){
        alldata[keyValue][key].responseText = alldata[keyValue][key].responselabel;
       }
       if(alldata[keyValue][key].responseText ===undefined || alldata[keyValue][key].responseText ==="" || alldata[keyValue][key].responseText==squarebraces){
        alldata[keyValue][key].responseText = this.label.noneOfTheOptions;
       }
      }

      let data = {
        value: alldata[keyValue],
        key: keyData[0].toLowerCase(),
        actualKey: keyData[0],
        image: assetFolder + "/icons/" + icon + ".svg"
      };
      localList.push(data);
      this.mapToShow = JSON.parse(JSON.stringify(localList));
    }
  }
  handleEdit(event) {
    event.preventDefault();
    let sectiondata = event.target.name;
    const selectedEvent = new CustomEvent("edithanlder", {
      detail: sectiondata
    });

    this.dispatchEvent(selectedEvent);
  }

  mergeSection(allSection){
      

   let updateData={};
    let alldata = JSON.parse(JSON.stringify(allSection));
    for (var keyValue in alldata) {
        let keyData = keyValue.split(hyphen);
        

        let key = keyData[0];
        if(updateData[key]==null || updateData[key]==undefined){
            updateData[key] = allSection[keyValue];
        }else{
            let data = updateData[key];
           let newArr = [...data, ...data];
            
            updateData[key] = newArr;
        }
  }
  
  this.updatemap(updateData);
}
}
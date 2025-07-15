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
import { ComponentErrorLoging } from "c/formUtility";
import { insertRecord } from "c/genericAnalyticsRecord";
import edit from "@salesforce/label/c.Edit_btn";
import object from "@salesforce/label/c.QnA_Object";
import braces from "@salesforce/label/c.QnA_ObjectBraces";
import squarebraces from "@salesforce/label/c.QnA_ListBraces";
import noneOfTheOptions from "@salesforce/label/c.ReviewPage_BlankAnswer";
import ReviewSectionName from "@salesforce/label/c.ReviewSectionName";
import communityMainFlowPage from "@salesforce/label/c.Community_Main_Flow_Page_Name";
import analyticsRecord_EditBttn from "@salesforce/label/c.analyticsRecord_EditBttn";

export default class qnA_ReviewSection extends LightningElement {
  @api sections;
  //@api flowconfig;
  @api parentRecordID;
  @api questionairreId;
  @api parentObjectName;
  @api overrideNotNull;
  @api mapToShow = [];
  @track reviewCheckList = assetFolder + "/icons/reviewImage.svg";
  @track showCheckList = true;
  @track startTime;
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
  get sectionlanguagemap() {
    return this._sectionlanguagemap;
  }

  set sectionlanguagemap(value) {
    this._sectionlanguagemap = value;
  }
  @api    //Code Review SP4
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
    this.updatemap(value);
  }
  // Commenting due to Code Review SP4
  connectedCallback() {
	this.startTime = new Date().getTime();
    var url_string = document.location.href;
    var url = new URL(url_string);
    var arr = url_string.split("?");
    if (url_string.length > 1 && arr[1] !== "") {
      var URLParams = url.searchParams;
      this.questionairreId = URLParams.get("c__parentObjId");
    }
    window.scrollTo({ top: 0, behavior: 'smooth' });
    let localList = [];
    let alldata = JSON.parse(JSON.stringify(this.allvisiblesection));
    for (var keyValue in alldata) {
      let keyData = keyValue.split(hyphen);
      let iconName = this.sectionlanguagemap[keyData[0]] != undefined ? this.sectionlanguagemap[keyData[0]] : keyData[0]
      let iconData = JSON.parse(
        JSON.stringify(iconName.replace(/ /g, hyphen))
      );
      let icon = iconData.toLowerCase();

      //CTBOS-3629 | Shreya | 21/8/20 | check is object
			alldata[keyValue].forEach((response) => {
				if(response.responseText && response.responseText.startsWith("[")) {
					let licenses = JSON.parse(response.responseText);
					let allLicenses = '';
	
					licenses.forEach((license) => {
						allLicenses += license.name + '|';
					});
					
					response.responseText = allLicenses.slice(0, -1);
				}
			});

    let data = {
      value: alldata[keyValue],
      key: keyData[0].toLowerCase(),
      actualKey: keyData[0],
      image: assetFolder + "/icons/" + icon + ".svg"
    };
    localList.push(data);
    }
  } 
  get subsectioncheck() {
    return subsection.componentOverride != null ? true : false;
  }

  updatemap(allSection) {
    try{
    let localList = [];
    let alldata = JSON.parse(JSON.stringify(allSection));
    for (var keyValue in alldata) {
      let keyData = keyValue.split(hyphen);
      let iconName = this.sectionlanguagemap[keyData[0]] != undefined ? this.sectionlanguagemap[keyData[0]] : keyData[0]
      let iconData = JSON.parse(
        JSON.stringify(iconName.replace(/ /g, hyphen))
      );
      let icon = iconData.toLowerCase();
     for (var key in alldata[keyValue]) {
         let answer = alldata[keyValue][key].responseText ?
                      JSON.parse(JSON.stringify( alldata[keyValue][key].responseText)) :
                      undefined;
        
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
       if( alldata[keyValue][key].responselabel !=undefined  ){
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
  catch (error) {
    ComponentErrorLoging('QnA_ReviewSection', 'updatemap', '', '', 'Low', error);
  }
  }
  handleEdit(event) {
    try{
    event.preventDefault();
    let sectiondata = event.target.name;
	insertRecord(
        this.questionairreId, 
        ReviewSectionName, 
        JSON.stringify(sectiondata).replace(/\"/g, ""), 
        "",
        communityMainFlowPage,
        analyticsRecord_EditBttn,
        "",
        "",
        this.startTime,
        new Date().getTime()
      );
    const selectedEvent = new CustomEvent("edithanlder", {
      detail: sectiondata
    });

    this.dispatchEvent(selectedEvent);
  }
  catch (error) {
    ComponentErrorLoging('QnA_ReviewSection', 'handleEdit', '', '', 'Low', error);
  }
  }
}
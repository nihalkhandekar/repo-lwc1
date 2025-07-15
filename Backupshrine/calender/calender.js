import { LightningElement ,track , wire} from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import apostileDashboardCalender from '@salesforce/resourceUrl/apostileDashboardCalender'; // Import the CSS file

import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS'; // Static resource URL
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';
const LANGUAGE_TEXT = 'Language';
import labelsResourceForLocal from "@salesforce/resourceUrl/sap_EnglishLabel"; // Static resource URL

export default class calender extends LightningElement {

days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];

d = new Date(); // you can not use Date. ...() directly


/*Month Selection Properties*/
currentSelectedMonthIndex=this.d.getMonth();
currentMonthIndexed=this.currentSelectedMonthIndex
currentMonth =  this.months[this.currentSelectedMonthIndex];  // return index of month
currentSelectedMonth=this.currentMonth;
nextmonth='';
previousmonth='';
nextSelectedMonthIndex;
previousSelectedMonthIndex;



/*year combo box properties*/
currentYear=this.d.getFullYear();
currentSelectedYear=this.currentYear;
yearOptions=[];

/*Date Grid*/
@track calenderGrid=[];
@track calenderDate=[];
index=0;

/*highlight Days*/
@track currentDate=this.d.getDate();
@track currentDay=this.d.getDay();//0-6
SelectedDay='';
SelectedDate;//only number because moth and year already selected
startHighlightingDate;//for This Week & This Month //only number because moth and year already selected
endHighlightingDate;//for This Week & This Month //only number because moth and year already selected
highlightedElementIndexesForWeek=[];
highlightedElementIndexesForToday=[];
highlightFlag=false;
sDate=false;
eDate=false;
renderCalled=false;

todayClicked=false;
thisWeekClicked=false;
thisMonthClicked=false;
thisQuaterClicked=false;
thisYearClicked=false;

curruntDateLocale=this.d.toLocaleDateString();
showStartHighlightingDate;
showEndHighlightingDate;
fullStartHighlightingDate;
fullEndHighlightingDate;
showCurrentDate;
twoMonthInputsVisibleForQuater=false;

secoundTimeSameDateAppearForTodayButton=false;
secoundTimeSameDatesAppearForThisWeekButtonForStart=false;
secoundTimeSameDatesAppearForThisWeekButtonForEnd=false;

numberOfDaysBeforeCurrentMonth=0;
totalNumberOfDaysInCurrentMonth=0;



//lastDateOfCurrentMonth='';
lastDayOfCurrentMonth='';

//input should be visible or not?
twoMonthInputsVisible=false;     // if this true than make SingleMonthInputsVisible=false
SingleMonthInputsVisible=false; // if this true than make twoMonthInputsVisible=false
showLoader;

@track valueStartQuater='';
@track valueEndQuater='';

//transfer data to myactivity component for query right count
firstDateSelected=''; //transfred as a stating date
lastDateSelected=''; // transfered as a last date

//labels
 //@track language = 'English';
 labels={};
 JsonLanguageData;

//labels
  @wire(MessageContext)
    messageContext;


//variable for highlight any cell

connectedCallback() {

    loadScript(this,labelsResource)
    .then(()=> {
        this.JsonLanguageData=window.myobj;
        getCacheValue({ key: LANGUAGE_TEXT })
        .then(result => {
            this.handleLanguageChange(result);
        })
        .catch(error => {
            console.error(error);
        });
    }).catch(error => console.error('error is there', error));


    fetch(labelsResourceForLocal)
    .then((response) => {
        if (response.ok) {
            return response.json(); // Parse JSON data
        }
        throw new Error("Failed to load JSON");
    })
    .then((data) => {
        this.JsonLanguageData = data;
        this.labels = this.JsonLanguageData["English"];

        // Check if in community context and fetch cached language preference
        if (this.isCommunityContext()) {
            getCacheValue({ key: LANGUAGE_TEXT })
                .then((result) => {
                    this.handleLanguageChange(result);
                })
                .catch((error) => {
                    console.error("Error fetching cached language:", error);
                });
        }
    })
    .catch((error) => {
        console.error("Error fetching labels:", error);
    });




        //Load the CSS file
        this.showLoader = true;
        Promise.all([
            loadStyle(this, apostileDashboardCalender) // Load the CSS file
        ]).then(() => {
            this.staticResourceLoaded = true;
            this.showLoader=false;
            console.log('CSS file loaded successfully');
        }).catch(error => {
            console.error('Error loading CSS file:', error);
        });
        this.setMonthName();
        this.nextMonthIndex();
        this.previousMonthIndex();
        this.setYearOptionsInComboboxController();
        // this.setHighlightElementIndexesForHighlightThisWeek();
        this.dateGrid();
       // this.setHighlightElementIndexesForHighlightThisWeek();
       this.template.host.style.setProperty('--hight-of-card', '420px');


         // Subscribe to the language message channel
         subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
            this.handleLanguageChange(message);
          });
}
renderedCallback(){

    console.log('render call back called');
}
/* Month Related functions*/
setMonthName(){
    this.currentSelectedMonth=this.months[this.currentSelectedMonthIndex];
}
findIndexOfMonth(){
    for(let i=0;i<=11;i++){
        if(this.currentSelectedMonth==this.months[i])
        {
            this.setMonthName();
            this.nextMonthIndex();
            this.previousMonthIndex();
            return i;
        }

    }
}
nextMonthIndex(){
        if(this.currentSelectedMonthIndex==11){
            this.nextSelectedMonthIndex=0;

        }
        else{
            this.nextSelectedMonthIndex=this.currentSelectedMonthIndex+1;
        }

        //this.nextmonth=this.days[this.nextSelectedMonthIndex];
}
previousMonthIndex(){
        if(this.currentSelectedMonthIndex==0){
            this.previousSelectedMonthIndex=11;

        }
        else{
            this.previousSelectedMonthIndex=this.currentSelectedMonthIndex-1;
        }
        //this.previousmonth=this.days[this.previousSelectedMonthIndex];
}
nextMonthButtonClickController(){
    this.renderCalled=false;
    // this.twoMonthInputsVisible=false;     // if this true than make SingleMonthInputsVisible=false
    // this.SingleMonthInputsVisible=false;
    if(this.currentSelectedMonthIndex==11){
        this.currentSelectedYear++;
    }
    this.currentSelectedMonthIndex=this.nextSelectedMonthIndex;
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.currentSelectedMonth=this.months[this.currentSelectedMonthIndex];
    //this.findIndexOfMonth();
    this.quaterMonthSet();
    this.dateGrid();


}
previousMonthButtonClickController(){
    this.renderCalled=false;
    this.twoMonthInputsVisible=false;     // if this true than make SingleMonthInputsVisible=false
    this.SingleMonthInputsVisible=false;
    if(this.currentSelectedMonthIndex==0){
        this.currentSelectedYear--;
    }
    this.currentSelectedMonthIndex=this.previousSelectedMonthIndex;
    this.nextMonthIndex();
    this.previousMonthIndex();
    // this.findIndexOfMonth();
    this.currentSelectedMonth=this.months[this.currentSelectedMonthIndex];
    this.quaterMonthSet();
    this.dateGrid();
}
/*combo Box For years*/
setYearOptionsInComboboxController(){
    this.renderCalled=false;
    this.twoMonthInputsVisible=false;     // if this true than make SingleMonthInputsVisible=false
    this.SingleMonthInputsVisible=false;
 let firstOption=this.currentSelectedYear-30;
 let lastOption=this.currentSelectedYear+30;
 for (let i = firstOption; i <= lastOption; i++) {
    this.yearOptions.push({ label: String(i), value: String(i) });
}


}
YearChanged(event){
    this.currentSelectedYear = event.detail.value;
    this.dateGrid();
}

/*For Date Grid*/
dateGrid(){
    this.renderCalled=true;
    console.log('Date Grid Called');
    this.index=0;
    this.calenderGrid=[];
        //const calenderGrid=[6][7];
        this.calenderDate = new Array(42);
        this.totalNumberOfDaysInCurrentMonth=this.dayOfMonth(this.currentSelectedYear,this.currentSelectedMonthIndex);
        //let totalNumberOfDaysInNextMonth=this.dayOfMonth(this.currentSelectedYear,(this.currentSelectedMonthIndex+1));
        let totalNumberOfDaysInPreviousMonth=0;

        if(this.currentSelectedMonthIndex==0){ // for January
             totalNumberOfDaysInPreviousMonth=31;
        }
        else{
            totalNumberOfDaysInPreviousMonth=this.dayOfMonth(this.currentSelectedYear,(this.currentSelectedMonthIndex-1));
        }
        //let currentDayNumber=Date.getDay(); // 0-6 number of day in week

        //const Example = new Date("June 21, 1983");
        const startOfTheMonth = new Date(this.currentSelectedMonth+' 1, '+this.currentSelectedYear);
        // const endOfTheMonth = new Date(this.currentSelectedMonth+' '+this.totalNumberOfDaysInCurrentMonth+', '+this.currentSelectedYear);

        let firstDayInMonth=startOfTheMonth.getDay();//it will return 0-6
        // let lastDayInMonth=endOfTheMonth.getDay();//it will return 0-6



        this.numberOfDaysBeforeCurrentMonth=firstDayInMonth;
        // let numberOfDaysAfterCurrentMonth=(42-(this.totalNumberOfDaysInCurrentMonth+this.numberOfDaysBeforeCurrentMonth));


    /*Set Values in calenderGrid[][] */

    //Dates of previous month
    for(let j=0,i=(totalNumberOfDaysInPreviousMonth-this.numberOfDaysBeforeCurrentMonth+1);j<this.numberOfDaysBeforeCurrentMonth;j++,i++,this.index++){
        this.calenderDate[this.index]={ date: i, highlight: false ,startDate:false,endDate:false };
        //this.calenderGrid.push({ label: String(i), value: String(i) });
    }
    totalNumberOfDaysInPreviousMonth=this.dayOfMonth(this.currentSelectedYear,(this.currentSelectedMonthIndex-1));

    //Dates of current Month
    for(let j=this.numberOfDaysBeforeCurrentMonth,i=1;j<(this.totalNumberOfDaysInCurrentMonth+this.numberOfDaysBeforeCurrentMonth);j++,i++,this.index++){
        this.calenderDate[this.index]={ date: i, highlight: false ,startDate:false,endDate:false };
        //this.calenderGrid.push({ label: String(i), value: String(i) });
    }

    //Dates of next Month
    for(let j=(this.totalNumberOfDaysInCurrentMonth+this.numberOfDaysBeforeCurrentMonth),i=1;j<42;j++,i++,this.index++){
        this.calenderDate[this.index]={ date: i, highlight: false ,startDate:false,endDate:false };
        //this.calenderGrid.push({ label: String(i), value: String(i) });
    }

    console.log('this.calenderDate',JSON.stringify(this.calenderDate));


    this.calendarGrid = [];
     for (let i = 0; i < 6; i++)
    {
      this.calendarGrid.push(this.calenderDate.slice(i * 7, i * 7 + 7));
    }
        console.log(this.calenderGrid)
}

setCalendarGrid(){
    this.renderCalled=true;
    this.calendarGrid = [];
     for (let i = 0; i < 6; i++)
    {
      this.calendarGrid.push(this.calenderDate.slice(i * 7, i * 7 + 7));
    }
}
dayOfMonth(year,monthIndex){
        //leap year
        if(monthIndex==1){
            if(((year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0))&& monthIndex==1){
                return 29;
            }
            else {
                return 28;
            }
        }

        //non-leap year
        else if(monthIndex==0||monthIndex==2||monthIndex==4||monthIndex==6||monthIndex==7|| monthIndex== 9||monthIndex==11)
        {
            return 31;
        }

        else if(monthIndex==3||monthIndex==5|| monthIndex== 8||monthIndex==10){
            return 30;
        }
}
today(){

    this.todayClicked=true;
    this.twoMonthInputsVisibleForQuater=false;
    this.renderCalled=true;
    this.twoMonthInputsVisible=false;     // if this true than make SingleMonthInputsVisible=false
    this.SingleMonthInputsVisible=true;
    this.currentSelectedMonth=this.currentMonth;
    this.currentSelectedMonthIndex=this.currentMonthIndexed;
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.template.host.style.setProperty('--hight-of-card', '480px');

    this.currentSelectedYear=this.d.getFullYear();
    this.SelectedDate=this.d.getDate();//return value 1-31
    this.startHighlightingDate=this.d.getDate();
    this.endHighlightingDate=this.d.getDate();
    console.log('startHighlightingDate',this.startHighlightingDate);
    console.log('endHighlightingDate',this.endHighlightingDate);



    let month='';
    let date='';
    month=(this.currentMonthIndexed+1<10) ? `0${this.currentMonthIndexed+1}` : `${this.currentMonthIndexed+1}`;
    date=(this.currentDate<10) ? `0${this.currentDate}` : `${this.currentDate}`;
    this.showCurrentDate=`${month}/${date}/${this.currentYear}`;


    this.dateGrid();
    for(let i=0;i<=41;i++){
        if((this.calenderDate[i].date==this.startHighlightingDate)&&this.secoundTimeSameDateAppearForTodayButton==false){
            this.calenderDate[i].highlight=true;
            this.calenderDate[i].startDate=true;
            this.calenderDate[i].endDate=true;
            this.secoundTimeSameDateAppearForTodayButton=true;
            console.log(this.calenderDate[i]);
        }
    }

    this.setCalendarGrid();
    this.apply();

}
thisWeek(){
    this.thisWeekClicked=true;
    this.twoMonthInputsVisibleForQuater=false;
    this.renderCalled=true;
    this.twoMonthInputsVisible=true;     // if this true than make SingleMonthInputsVisible=false
    this.SingleMonthInputsVisible=false;
    this.secoundTimeSameDateAppearForTodayButton=false; // it should be false because if we click on today secound time after any button than this variable will always true
    this.template.host.style.setProperty('--hight-of-card', '480px');

    this.currentSelectedMonth=this.currentMonth;
    this.currentSelectedMonthIndex=this.currentMonthIndexed;
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.currentSelectedYear=this.d.getFullYear();
    this.SelectedDate=this.d.getDate();//return value 1-31
    //this.startHighlightingDate=this.d.startOfWeek();
    //this.endHighlightingDate=this.startHighlightingDate

    // this.setHighlightElementIndexesForHighlightThisWeek();
    console.log('startHighlightingDate',this.startHighlightingDate);
    console.log('endHighlightingDate',this.endHighlightingDate);
    //this.lastDayOfCurrentMonth
    this.dateGrid();
    this.setHighlightElementIndexesForHighlightThisWeek();



    // //logic for highlighting whole week
    // let indexOfTodayDateInGrid=this.numberOfDaysBeforeCurrentMonth+this.currentDate-this.currentDay+1; // it will give perfect index because this.currentDay start from 0
    // let noOfWeek=indexOfTodayDateInGrid/7;
    // console.log('noOfWeek',Math.floor(noOfWeek));

    // let startHighlightingIndex=Math.floor(noOfWeek)*7;
    // let endHighlightingIndex=startHighlightingIndex+6;

    // for(let i=startHighlightingIndex;i<=endHighlightingIndex;i++){
    //     this.calenderDate[i].highlight=true;
    //     console.log('From new for loop',i);
    //     if(i==startHighlightingIndex){
    //         this.startHighlightingDate=this.calenderDate[i].date;
    //         this.calenderDate[i].startDate=true;
    //         //month and year nu jovu padse
    //     }
    //     else if(i==endHighlightingIndex){
    //         this.endHighlightingDate=this.calenderDate[i].date;
    //         this.calenderDate[i].endDate=true;
    //         //month and year nu jovu padse
    //     }
    // }

    // for(let i=0;i<=41;i++){

    //     if(this.calenderDate[i].date>=this.startHighlightingDate  && this.calenderDate[i].date<=this.endHighlightingDate){


    //         if(this.calenderDate[i].date==this.startHighlightingDate){
    //             this.calenderDate[i].startDate=true;console.log(i);
    //         }
    //         else if(this.calenderDate[i].date==this.endHighlightingDate)
    //             {this.calenderDate[i].endDate=true;console.log(i);
    //             }

    //         console.log(i);
    //     }

    // }
    this.setCalendarGrid();
    this.apply();

    console.log('this.calenderDate',JSON.stringify(this.calenderDate));

}
setHighlightElementIndexesForHighlightThisWeek(){

    //logic for highlighting whole week
    let indexOfTodayDateInGrid=this.numberOfDaysBeforeCurrentMonth+this.currentDate-this.currentDay+1; // it will give perfect index because this.currentDay start from 0
    let noOfWeek=indexOfTodayDateInGrid/7;
    console.log('noOfWeek',Math.floor(noOfWeek));
    noOfWeek=Math.floor(noOfWeek);//0-6

    let startHighlightingIndex=Math.floor(noOfWeek)*7;
    let endHighlightingIndex=startHighlightingIndex+6;



    let month='';
    let date='';
    let year=''

    month=(this.currentMonthIndexed+1<10) ? `0${this.currentMonthIndexed+1}` : `${this.currentMonthIndexed+1}`;
    date=(this.currentDate<10) ? `0${this.currentDate}` : `${this.currentDate}`;
    year=`${this.currentYear}`;

    this.showCurrentDate=`${month}/${date}/${this.currentYear}`;

    for(let i=startHighlightingIndex;i<=endHighlightingIndex;i++){
        this.calenderDate[i].highlight=true;
        console.log('From new for loop',i);
        if(i==startHighlightingIndex){
            this.startHighlightingDate=this.calenderDate[i].date;
            this.startHighlightingDate=(this.startHighlightingDate<10) ? `0${this.startHighlightingDate}` : `${this.startHighlightingDate}`;
            this.calenderDate[i].startDate=true;
            //month and year nu jovu padse
        }
        else if(i==endHighlightingIndex){
            this.endHighlightingDate=this.calenderDate[i].date;
            this.endHighlightingDate=(this.endHighlightingDate<10) ? `0${this.endHighlightingDate}` : `${this.endHighlightingDate}`;
            this.calenderDate[i].endDate=true;
            //month and year nu jovu padse
        }

    }



    // startHighlightDate=(this.startHighlightingDate<10) ? `0${this.startHighlightingDate}` : `${this.startHighlightingDate}`;
    // endHighlightDate=(this.endHighlightingDate<10) ? `0${this.endHighlightingDate}` : `${this.endHighlightingDate}`;

     this.showStartHighlightingDate=`${month}/${this.startHighlightingDate}/${this.currentYear}`;
    this.showEndHighlightingDate=`${month}/${this.endHighlightingDate}/${this.currentYear}`;




        //set month and year for start date in first week
        if(noOfWeek==0&&Number(this.startHighlightingDate)>1){
            month=(this.currentMonthIndexed<10) ? `0${this.currentMonthIndexed}` : `${this.currentMonthIndexed}`;
            this.showStartHighlightingDate=`${month}/${this.startHighlightingDate}/${this.currentYear}`;
            month=(this.currentMonthIndexed+1<10) ? `0${this.currentMonthIndexed+1}` : `${this.currentMonthIndexed+1}`;
            if(this.currentMonthIndexed==0){
                year=`${this.currentYear-1}`;
                this.showStartHighlightingDate=`${month}/${this.startHighlightingDate}/${this.currentYear}`;
                year=`${this.currentYear}`;
            }
        }


        //set month for end date in last weeks
        if((noOfWeek==5||noOfWeek==6)&&Number(this.endHighlightingDate)<this.totalNumberOfDaysInCurrentMonth){
            month=(this.currentMonthIndexed+2<10) ? `0${this.currentMonthIndexed+2}` : `${this.currentMonthIndexed+2}`;
            this.showEndHighlightingDate=`${month}/${this.showEndHighlightingDate}/${this.currentYear}`;
            month=(this.currentMonthIndexed+1<10) ? `0${this.currentMonthIndexed+1}` : `${this.currentMonthIndexed+1}`;
            if(this.currentMonthIndexed==11){
                year=`${this.currentYear+1}`;
                this.showEndHighlightingDate=`${month}/${this.showEndHighlightingDate}/${this.currentYear}`;
                year=`${this.currentYear}`;
                console.log(year);
                
            }
        }



}
thisMonth(){
    this.thisMonthClicked=true;
    this.twoMonthInputsVisibleForQuater=false;
    this.renderCalled=true;
    this.twoMonthInputsVisible=false;     // if this true than make SingleMonthInputsVisible=false
    this.SingleMonthInputsVisible=false;
    this.secoundTimeSameDateAppearForTodayButton=false; // it should be false because if we click on today secound time after any button than this variable will always true
    this.template.host.style.setProperty('--hight-of-card', '420px');

    this.currentSelectedMonth=this.currentMonth;
    this.currentSelectedMonthIndex=this.currentMonthIndexed;
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.currentSelectedYear=this.d.getFullYear();
    this.SelectedDate=this.d.getDate();//return value 1-31
    this.startHighlightingDate=1
    this.endHighlightingDate=this.dayOfMonth(this.currentSelectedYear,this.currentSelectedMonthIndex);
    console.log('startHighlightingDate',this.startHighlightingDate);
    console.log('endHighlightingDate',this.endHighlightingDate);

    this.dateGrid();
    this.apply();
}
thisQuater(){
    this.quaterMonthSet();
    this.twoMonthInputsVisibleForQuater=true;
    this.thisQuaterClicked=true;
    this.renderCalled=false;
    this.twoMonthInputsVisible=false;     // if this true than make SingleMonthInputsVisible=false
    this.SingleMonthInputsVisible=false;
    this.secoundTimeSameDateAppearForTodayButton=false; // it should be false because if we click on today secound time after any button than this variable will always true
    this.template.host.style.setProperty('--hight-of-card', '480px');

    this.currentSelectedMonth=this.currentMonth;
    this.currentSelectedMonthIndex=this.currentMonthIndexed;
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.currentSelectedYear=this.d.getFullYear();
    this.SelectedDate=this.d.getDate();//return value 1-31

    this.dateGrid();
    this.setCalendarGrid();
    this.apply();
}
// thisBiyearly(){
//     this.renderCalled=true;
//     this.twoMonthInputsVisible=true;     // if this true than make SingleMonthInputsVisible=false
//     this.SingleMonthInputsVisible=false;

//     this.dateGrid();
// }
thisYear(){
    this.thisYearClicked=true;
    this.twoMonthInputsVisibleForQuater=false;
    this.renderCalled=true;
    this.twoMonthInputsVisible=false;     // if this true than make SingleMonthInputsVisible=false
    this.SingleMonthInputsVisible=false;
    this.secoundTimeSameDateAppearForTodayButton=false; // it should be false because if we click on today secound time after any button than this variable will always true
    this.template.host.style.setProperty('--hight-of-card', '420px');




    this.currentSelectedMonth=this.currentMonth;
    this.currentSelectedMonthIndex=this.currentMonthIndexed;
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.currentSelectedYear=this.d.getFullYear();
    this.SelectedDate=this.d.getDate();//return value 1-31

    this.dateGrid();
    this.setCalendarGrid();
    this.apply();
}
highlightElements(){
    this.renderCalled=true;
    this.highlightedElements=[];
    this.highlightFlag=false;
}
// apply(){
//     console.log('apply called');
//     const fromDateOne = this.template.querySelector('#FromOne');
//     const fromDateTwo = this.template.querySelector('#fromTwo');
//     const toDateTwo = this.template.querySelector('#ToTwo');

//     if(this.todayClicked==true){
//         fromDateOne=this.currentDate;
//     }
//     else if(this.thisWeekClicked==true){
//         fromDateTwo=this.startHighlightingDate;
//         toDateTwo=this.endHighlightingDate;
//     }
//     else if(this.thisMonthClicked==true){}
//     else if(this.thisQuaterClicked==true){
//         fromDateTwo=this.startHighlightingDate;
//         toDateTwo=this.endHighlightingDate;
//     }
//     else if(this.thisYearClicked==true){}
// }


apply() {
    // here we will pass whole date in format of mm/dd/yyyy
    //this.currentMonth is Index for Current Month

    let month='';
    let date='';
    if(this.currentMonthIndexed+1<10){
        month=`0${this.currentMonthIndexed+1}`;
    }
    else {
        month=`${this.currentMonthIndexed+1}`;
    }
    if(this.currentDate<10){
        date=`0${this.currentDate}`;
    }
    else {
        date=`${this.currentDate}`;
    }

// check which button is clicked
    console.log('apply called');
    if(this.todayClicked==true){

        this.firstDateSelected=`${month}/${date}/${this.currentYear}`;
        this.lastDateSelected=this.firstDateSelected;
        console.log('firstDateSelected ',this.firstDateSelected,' lastDateSelected ',this.lastDateSelected);
        this.todayClicked=false;
        const customEvent= new CustomEvent('dateselected',{
            detail:{startDate:`${this.firstDateSelected}`,endDate:`${this.lastDateSelected}`}
        });
        this.dispatchEvent(customEvent);
    }
    else if(this.thisWeekClicked==true){
        // this.firstDateSelected=`${month}/${this.startHighlightingDate}/${this.currentYear}`;
        // this.lastDateSelected=`${month}/${this.endHighlightingDate}/${this.currentYear}`;
        this.firstDateSelected=this.showStartHighlightingDate;
        this.lastDateSelected=this.showEndHighlightingDate;
        console.log('firstDateSelected ',this.firstDateSelected,' lastDateSelected ',this.lastDateSelected);
        this.thisWeekClicked=false;
        const customEvent= new CustomEvent('dateselected',{
            detail:{startDate:`${this.firstDateSelected}`,endDate:`${this.lastDateSelected}`}
        });
        this.dispatchEvent(customEvent);
    }
    else if(this.thisMonthClicked==true){
        this.lastDayOfCurrentMonth=this.dayOfMonth(this.currentYear,this.currentMonthIndexed);

        this.firstDateSelected=`${month}/01/${this.currentYear}`;
        this.lastDateSelected=`${month}/${this.lastDayOfCurrentMonth}/${this.currentYear}`;
        console.log('firstDateSelected ',this.firstDateSelected,' lastDateSelected ',this.lastDateSelected);
        this.thisMonthClicked=false;

        const customEvent= new CustomEvent('dateselected',{
            detail:{startDate:`${this.firstDateSelected}`,endDate:`${this.lastDateSelected}`}
        });
        this.dispatchEvent(customEvent);
    }
    else if(this.thisQuaterClicked==true){
        let startingMonthIndexForQuater;
        let endingMonthIndexForQuater;

        // Get month indices
        for(let i=0;i<=11;i++){
            if(this.months[i]==this.valueStartQuater){
                startingMonthIndexForQuater=i;
            }
            else if(this.months[i]==this.valueEndQuater){
                endingMonthIndexForQuater=i;
            }
        }

        let lastDayOfEndingMonthOfQuater=this.dayOfMonth(this.currentYear,endingMonthIndexForQuater);

        // Format month numbers with leading zeros
        let startMonth = (startingMonthIndexForQuater + 1).toString().padStart(2, '0');
        let endMonth = (endingMonthIndexForQuater + 1).toString().padStart(2, '0');

        this.firstDateSelected=`${startMonth}/01/${this.currentYear}`;
        this.lastDateSelected=`${endMonth}/${lastDayOfEndingMonthOfQuater}/${this.currentYear}`;

        console.log('firstDateSelected ',this.firstDateSelected,' lastDateSelected ',this.lastDateSelected);
        this.thisQuaterClicked=false;

        const customEvent= new CustomEvent('dateselected',{
            detail:{startDate:`${this.firstDateSelected}`,endDate:`${this.lastDateSelected}`}
        });
        this.dispatchEvent(customEvent);
    }
    else if(this.thisYearClicked==true){
        this.firstDateSelected=`01/01/${this.currentYear}`;
        this.lastDateSelected=`12/31/${this.currentYear}`;
        console.log('firstDateSelected ',this.firstDateSelected,' lastDateSelected ',this.lastDateSelected);
        this.thisYearClicked=false;
        const customEvent= new CustomEvent('dateselected',{
            detail:{startDate:`${this.firstDateSelected}`,endDate:`${this.lastDateSelected}`}
        });
        this.dispatchEvent(customEvent);
    }
}

quaterMonthSet(){
    if(this.currentSelectedMonthIndex==0 || this.currentSelectedMonthIndex==1 || this.currentSelectedMonthIndex==2){
        this.valueStartQuater='January';
        this.valueEndQuater='March';
    }
    else if(this.currentSelectedMonthIndex==3 || this.currentSelectedMonthIndex==4 || this.currentSelectedMonthIndex==5){
        this.valueStartQuater='April';
        this.valueEndQuater='June';
    }
    else if(this.currentSelectedMonthIndex==6 || this.currentSelectedMonthIndex==7 || this.currentSelectedMonthIndex==8){
        this.valueStartQuater='July';
        this.valueEndQuater='September';
    }
    else if(this.currentSelectedMonthIndex==9 || this.currentSelectedMonthIndex==10 || this.currentSelectedMonthIndex==11){
        this.valueStartQuater='October';
        this.valueEndQuater='December';
    }
}

outSideOfComponentClicked(){
    console.log('outside called')
}

    // Handle language change
    handleLanguageChange(message) {
        let language;
        if (message.language) {
            language = message.language;
        }else{
            language = message;
        }
  this.labels=JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
    }

}
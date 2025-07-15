import { LightningElement, track, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import apostileDashboardCalender from '@salesforce/resourceUrl/sap_apostileDashboardCalender';
import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS';
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';
import labelsResourceForLocal from '@salesforce/resourceUrl/sap_EnglishLabel';

const LANGUAGE_TEXT = 'Language';

export default class sap_Calender extends LightningElement {
  days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  d = new Date(); // you can not use Date. ...() directly

  /*Month Selection Properties*/
  currentSelectedMonthIndex = this.d.getMonth();
  currentMonthIndexed = this.currentSelectedMonthIndex;
  currentMonth = this.months[this.currentSelectedMonthIndex];
  currentSelectedMonth = this.currentMonth;
  nextmonth = '';
  previousmonth = '';
  nextSelectedMonthIndex;
  previousSelectedMonthIndex;

  /*year combo box properties*/
  currentYear = this.d.getFullYear();
  currentSelectedYear = this.currentYear;
  yearOptions = [];

  /*Date Grid*/
  @track sap_CalenderGrid = [];
  @track sap_CalenderDate = [];
  index = 0;

  /*highlight Days*/
  @track currentDate = this.d.getDate();
  @track currentDay = this.d.getDay();
  SelectedDay = '';
  SelectedDate;
  startHighlightingDate;
  endHighlightingDate;
  highlightedElementIndexesForWeek = [];
  highlightedElementIndexesForToday = [];
  highlightFlag = false;
  sDate = false;
  eDate = false;
  renderCalled = false;

  todayClicked = false;
  thisWeekClicked = false;
  thisMonthClicked = false;
  thisQuaterClicked = false;
  thisYearClicked = false;

  curruntDateLocale = this.d.toLocaleDateString();
  showStartHighlightingDate;
  showEndHighlightingDate;
  fullStartHighlightingDate;
  fullEndHighlightingDate;
  showCurrentDate;
  twoMonthInputsVisibleForQuater = false;

  secoundTimeSameDateAppearForTodayButton = false;
  secoundTimeSameDatesAppearForThisWeekButtonForStart = false;
  secoundTimeSameDatesAppearForThisWeekButtonForEnd = false;

  numberOfDaysBeforeCurrentMonth = 0;
  totalNumberOfDaysInCurrentMonth = 0;

  // Variable for last day of current month
  lastDayOfCurrentMonth = '';

  // Flag: if true, display two-month inputs; if false, display single-month inputs
  twoMonthInputsVisible = false;
  // Flag: if true, display single-month inputs; if false, display two-month inputs
  SingleMonthInputsVisible = false;

  showLoader;

  @track valueStartQuater = '';
  @track valueEndQuater = '';

  // Dates transferred for query (start and end)
  firstDateSelected = '';
  lastDateSelected = '';

  // Labels and language data
  labels = {};
  JsonLanguageData;

  // Wire the message context for message service
  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    // Load labels resource script
    loadScript(this, labelsResource)
      .then(() => {
        this.JsonLanguageData = window.myobj;
        getCacheValue({ key: LANGUAGE_TEXT })
          .then((result) => {
            this.handleLanguageChange(result);
          })
          .catch((error) => {
            console.error(error);
          });
      })
      .catch((error) => console.error('error is there', error));

    // Fetch local labels JSON
    fetch(labelsResourceForLocal)
      .then((response) => {
        if (response.ok) {
          return response.json();
        }
        throw new Error('Failed to load JSON');
      })
      .then((data) => {
        this.JsonLanguageData = data;
        this.labels = this.JsonLanguageData['English'];

        // If in community context, fetch cached language preference
        if (this.isCommunityContext()) {
          getCacheValue({ key: LANGUAGE_TEXT })
            .then((result) => {
              this.handleLanguageChange(result);
            })
            .catch((error) => {
              console.error('Error fetching cached language:', error);
            });
        }
      })
      .catch((error) => {
        console.error('Error fetching labels:', error);
      });

    // Load CSS file for the dashboard calendar
    this.showLoader = true;
    Promise.all([loadStyle(this, apostileDashboardCalender)])
      .then(() => {
        this.staticResourceLoaded = true;
        this.showLoader = false;
      })
      .catch((error) => {
        console.error('Error loading CSS file:', error);
      });

    // Initialize month and date settings
    this.setMonthName();
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.setYearOptionsInComboboxController();
    this.dateGrid();
    this.template.host.style.setProperty('--hight-of-card', '420px');

    // Subscribe to language message channel for updates
    subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
      this.handleLanguageChange(message);
    });
  }
  renderedCallback() {
    console.log('render call back called');
  }

  // Set current selected month name
  setMonthName() {
    this.currentSelectedMonth = this.months[this.currentSelectedMonthIndex];
  }

  // Find index of the current selected month
  findIndexOfMonth() {
    for (let i = 0; i <= 11; i++) {
      if (this.currentSelectedMonth == this.months[i]) {
        this.setMonthName();
        this.nextMonthIndex();
        this.previousMonthIndex();
        return i;
      }
    }
  }

  // Calculate next month index
  nextMonthIndex() {
    if (this.currentSelectedMonthIndex == 11) {
      this.nextSelectedMonthIndex = 0;
    } else {
      this.nextSelectedMonthIndex = this.currentSelectedMonthIndex + 1;
    }
  }

  // Calculate previous month index
  previousMonthIndex() {
    if (this.currentSelectedMonthIndex == 0) {
      this.previousSelectedMonthIndex = 11;
    } else {
      this.previousSelectedMonthIndex = this.currentSelectedMonthIndex - 1;
    }
  }

  // Handler for next month button click
  nextMonthButtonClickController() {
    this.renderCalled = false;
    if (this.currentSelectedMonthIndex == 11) {
      this.currentSelectedYear++;
    }
    this.currentSelectedMonthIndex = this.nextSelectedMonthIndex;
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.currentSelectedMonth = this.months[this.currentSelectedMonthIndex];
    this.quaterMonthSet();
    this.dateGrid();
  }

  // Handler for previous month button click
  previousMonthButtonClickController() {
    this.renderCalled = false;
    this.twoMonthInputsVisible = false;
    this.SingleMonthInputsVisible = false;
    if (this.currentSelectedMonthIndex == 0) {
      this.currentSelectedYear--;
    }
    this.currentSelectedMonthIndex = this.previousSelectedMonthIndex;
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.currentSelectedMonth = this.months[this.currentSelectedMonthIndex];
    this.quaterMonthSet();
    this.dateGrid();
  }

  /* Combo Box for Years */

  // Set year options for the combobox
  setYearOptionsInComboboxController() {
    this.renderCalled = false;
    this.twoMonthInputsVisible = false;
    this.SingleMonthInputsVisible = false;
    let firstOption = this.currentSelectedYear - 30;
    let lastOption = this.currentSelectedYear + 30;
    for (let i = firstOption; i <= lastOption; i++) {
      this.yearOptions.push({ label: String(i), value: String(i) });
    }
  }

  // Handler for year change event
  YearChanged(event) {
    this.currentSelectedYear = event.detail.value;
    this.dateGrid();
  }

  dateGrid() {
    this.renderCalled = true;
    this.index = 0;
    this.calenderGrid = [];
    this.calenderDate = new Array(42);
    this.totalNumberOfDaysInCurrentMonth = this.dayOfMonth(this.currentSelectedYear, this.currentSelectedMonthIndex);
    let totalNumberOfDaysInPreviousMonth = 0;

    if (this.currentSelectedMonthIndex == 0) {
      totalNumberOfDaysInPreviousMonth = 31;
    } else {
      totalNumberOfDaysInPreviousMonth = this.dayOfMonth(this.currentSelectedYear, this.currentSelectedMonthIndex - 1);
    }
    const startOfTheMonth = new Date(this.currentSelectedMonth + ' 1, ' + this.currentSelectedYear);

    let firstDayInMonth = startOfTheMonth.getDay();

    this.numberOfDaysBeforeCurrentMonth = firstDayInMonth;

    //Dates of previous month
    for (let j = 0, i = totalNumberOfDaysInPreviousMonth - this.numberOfDaysBeforeCurrentMonth + 1; j < this.numberOfDaysBeforeCurrentMonth; j++, i++, this.index++) {
      this.calenderDate[this.index] = {
        date: i,
        highlight: false,
        startDate: false,
        endDate: false
      };
    }
    totalNumberOfDaysInPreviousMonth = this.dayOfMonth(this.currentSelectedYear, this.currentSelectedMonthIndex - 1);

    //Dates of current Month
    for (let j = this.numberOfDaysBeforeCurrentMonth, i = 1; j < this.totalNumberOfDaysInCurrentMonth + this.numberOfDaysBeforeCurrentMonth; j++, i++, this.index++) {
      this.calenderDate[this.index] = {
        date: i,
        highlight: false,
        startDate: false,
        endDate: false
      };
    }

    //Dates of next Month
    for (let j = this.totalNumberOfDaysInCurrentMonth + this.numberOfDaysBeforeCurrentMonth, i = 1; j < 42; j++, i++, this.index++) {
      this.calenderDate[this.index] = {
        date: i,
        highlight: false,
        startDate: false,
        endDate: false
      };
    }

    this.calendarGrid = [];
    for (let i = 0; i < 6; i++) {
      this.calendarGrid.push(this.calenderDate.slice(i * 7, i * 7 + 7));
    }
  }

  setCalendarGrid() {
    this.renderCalled = true;
    this.calendarGrid = [];
    for (let i = 0; i < 6; i++) {
      this.calendarGrid.push(this.calenderDate.slice(i * 7, i * 7 + 7));
    }
  }
  dayOfMonth(year, monthIndex) {
    //leap year
    if (monthIndex == 1) {
      if (((year % 4 === 0 && year % 100 !== 0) || year % 400 === 0) && monthIndex == 1) {
        return 29;
      } else {
        return 28;
      }
    }

    //non-leap year
    else if (monthIndex == 0 || monthIndex == 2 || monthIndex == 4 || monthIndex == 6 || monthIndex == 7 || monthIndex == 9 || monthIndex == 11) {
      return 31;
    } else if (monthIndex == 3 || monthIndex == 5 || monthIndex == 8 || monthIndex == 10) {
      return 30;
    }
  }
  today() {
    this.todayClicked = true;
    this.twoMonthInputsVisibleForQuater = false;
    this.renderCalled = true;
    this.twoMonthInputsVisible = false;
    this.SingleMonthInputsVisible = true;
    this.currentSelectedMonth = this.currentMonth;
    this.currentSelectedMonthIndex = this.currentMonthIndexed;
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.template.host.style.setProperty('--hight-of-card', '480px');

    this.currentSelectedYear = this.d.getFullYear();
    this.SelectedDate = this.d.getDate();
    this.startHighlightingDate = this.d.getDate();
    this.endHighlightingDate = this.d.getDate();

    let month = '';
    let date = '';
    month = this.currentMonthIndexed + 1 < 10 ? `0${this.currentMonthIndexed + 1}` : `${this.currentMonthIndexed + 1}`;
    date = this.currentDate < 10 ? `0${this.currentDate}` : `${this.currentDate}`;
    this.showCurrentDate = `${month}/${date}/${this.currentYear}`;

    this.dateGrid();
    for (let i = 0; i <= 41; i++) {
      if (this.calenderDate[i].date == this.startHighlightingDate && this.secoundTimeSameDateAppearForTodayButton == false) {
        this.calenderDate[i].highlight = true;
        this.calenderDate[i].startDate = true;
        this.calenderDate[i].endDate = true;
        this.secoundTimeSameDateAppearForTodayButton = true;
      }
    }

    this.setCalendarGrid();
    this.apply();
  }
  thisWeek() {
    // Set UI state
    this.thisWeekClicked = true;
    this.twoMonthInputsVisibleForQuater = false;
    this.renderCalled = true;
    this.twoMonthInputsVisible = true;
    this.SingleMonthInputsVisible = false;
    this.secoundTimeSameDateAppearForTodayButton = false;
    this.template.host.style.setProperty('--hight-of-card', '480px');

    // Set up current date info
    this.currentSelectedMonth = this.currentMonth;
    this.currentSelectedMonthIndex = this.currentMonthIndexed;
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.currentSelectedYear = this.d.getFullYear();
    this.SelectedDate = this.d.getDate();

    // Generate the calendar grid first
    this.dateGrid();

    //Highlight the week (after calendar grid is generated)
    this.setHighlightElementIndexesForHighlightThisWeek();

    // Update UI and apply changes
    this.setCalendarGrid();
    this.apply();
  }
  setHighlightElementIndexesForHighlightThisWeek() {
    // Find today's index in the calendar grid
    let indexOfTodayDateInGrid = this.numberOfDaysBeforeCurrentMonth + this.currentDate - this.currentDay + 1;

    // Calculate the week row (0-based) for today
    let noOfWeek = Math.floor(indexOfTodayDateInGrid / 7);

    // Determine start and end indices for the current week
    let startHighlightingIndex = noOfWeek * 7;
    let endHighlightingIndex = startHighlightingIndex + 6;

    // Clear previous highlights in the calendar grid
    for (let i = 0; i < this.calenderDate.length; i++) {
      if (this.calenderDate[i]) {
        this.calenderDate[i].highlight = false;
        this.calenderDate[i].startDate = false;
        this.calenderDate[i].endDate = false;
      }
    }

    // Format the current date
    let currentMonth = this.currentMonthIndexed + 1 < 10 ? `0${this.currentMonthIndexed + 1}` : `${this.currentMonthIndexed + 1}`;
    let currentDate = this.currentDate < 10 ? `0${this.currentDate}` : `${this.currentDate}`;
    let currentYear = `${this.currentYear}`;
    this.showCurrentDate = `${currentMonth}/${currentDate}/${currentYear}`;

    // Initialize start and end month/year variables
    let startMonth = currentMonth;
    let startYear = currentYear;
    let endMonth = currentMonth;
    let endYear = currentYear;

    // Highlight the current week's cells and set start/end flags
    for (let i = startHighlightingIndex; i <= endHighlightingIndex; i++) {
      if (i >= 0 && i < this.calenderDate.length && this.calenderDate[i]) {
        this.calenderDate[i].highlight = true;

        if (i === startHighlightingIndex) {
          // Set and format the start date info
          this.startHighlightingDate = this.calenderDate[i].date;
          this.startHighlightingDate = this.startHighlightingDate < 10 ? `0${this.startHighlightingDate}` : `${this.startHighlightingDate}`;
          this.calenderDate[i].startDate = true;

          // Update startMonth and startYear if start date is in previous month
          if (i < this.numberOfDaysBeforeCurrentMonth) {
            let prevMonthIndex = this.currentMonthIndexed === 0 ? 11 : this.currentMonthIndexed - 1;
            startMonth = prevMonthIndex + 1 < 10 ? `0${prevMonthIndex + 1}` : `${prevMonthIndex + 1}`;
            startYear = this.currentMonthIndexed === 0 ? `${parseInt(currentYear) - 1}` : currentYear;
          }
        } else if (i === endHighlightingIndex) {
          // Set and format the end date info
          this.endHighlightingDate = this.calenderDate[i].date;
          this.endHighlightingDate = this.endHighlightingDate < 10 ? `0${this.endHighlightingDate}` : `${this.endHighlightingDate}`;
          this.calenderDate[i].endDate = true;

          // Update endMonth and endYear if end date is in next month
          if (i >= this.numberOfDaysBeforeCurrentMonth + this.totalNumberOfDaysInCurrentMonth) {
            let nextMonthIndex = this.currentMonthIndexed === 11 ? 0 : this.currentMonthIndexed + 1;
            endMonth = nextMonthIndex + 1 < 10 ? `0${nextMonthIndex + 1}` : `${nextMonthIndex + 1}`;
            endYear = this.currentMonthIndexed === 11 ? `${parseInt(currentYear) + 1}` : currentYear;
          }
        }
      }
    }

    // Format and store the start and end highlighting dates
    this.showStartHighlightingDate = `${startMonth}/${this.startHighlightingDate}/${startYear}`;
    this.showEndHighlightingDate = `${endMonth}/${this.endHighlightingDate}/${endYear}`;
  }

  thisMonth() {
    // Handle "This Month" selection
    this.thisMonthClicked = true;
    this.twoMonthInputsVisibleForQuater = false;
    this.renderCalled = true;

    // Hide month input toggles
    this.twoMonthInputsVisible = false;
    this.SingleMonthInputsVisible = false;
    this.secoundTimeSameDateAppearForTodayButton = false;

    // Set card height for "This Month"
    this.template.host.style.setProperty('--hight-of-card', '420px');

    // Update month and year details
    this.currentSelectedMonth = this.currentMonth;
    this.currentSelectedMonthIndex = this.currentMonthIndexed;
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.currentSelectedYear = this.d.getFullYear();
    this.SelectedDate = this.d.getDate(); // Returns value 1-31
    this.startHighlightingDate = 1;
    this.endHighlightingDate = this.dayOfMonth(this.currentSelectedYear, this.currentSelectedMonthIndex);

    this.dateGrid();
    this.apply();
  }

  thisQuater() {
    // Handle "This Quarter" selection
    this.quaterMonthSet();
    this.twoMonthInputsVisibleForQuater = true;
    this.thisQuaterClicked = true;
    this.renderCalled = false;

    // Hide month input toggles
    this.twoMonthInputsVisible = false;
    this.SingleMonthInputsVisible = false;
    this.secoundTimeSameDateAppearForTodayButton = false;

    // Set card height for "This Quarter"
    this.template.host.style.setProperty('--hight-of-card', '480px');

    // Update month and year details
    this.currentSelectedMonth = this.currentMonth;
    this.currentSelectedMonthIndex = this.currentMonthIndexed;
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.currentSelectedYear = this.d.getFullYear();
    this.SelectedDate = this.d.getDate(); // Returns value 1-31

    this.dateGrid();
    this.setCalendarGrid();
    this.apply();
  }

  thisYear() {
    // Handle "This Year" selection
    this.thisYearClicked = true;
    this.twoMonthInputsVisibleForQuater = false;
    this.renderCalled = true;

    // Hide month input toggles
    this.twoMonthInputsVisible = false;
    this.SingleMonthInputsVisible = false;
    this.secoundTimeSameDateAppearForTodayButton = false;

    // Set card height for "This Year"
    this.template.host.style.setProperty('--hight-of-card', '420px');

    // Update month and year details
    this.currentSelectedMonth = this.currentMonth;
    this.currentSelectedMonthIndex = this.currentMonthIndexed;
    this.nextMonthIndex();
    this.previousMonthIndex();
    this.currentSelectedYear = this.d.getFullYear();
    this.SelectedDate = this.d.getDate();

    this.dateGrid();
    this.setCalendarGrid();
    this.apply();
  }

  highlightElements() {
    this.renderCalled = true;
    this.highlightedElements = [];
    this.highlightFlag = false;
  }

  apply() {
    let month = '';
    let date = '';
    if (this.currentMonthIndexed + 1 < 10) {
      month = `0${this.currentMonthIndexed + 1}`;
    } else {
      month = `${this.currentMonthIndexed + 1}`;
    }
    if (this.currentDate < 10) {
      date = `0${this.currentDate}`;
    } else {
      date = `${this.currentDate}`;
    }

    if (this.todayClicked == true) {
      this.firstDateSelected = `${month}/${date}/${this.currentYear}`;
      this.lastDateSelected = this.firstDateSelected;
      this.todayClicked = false;
      const customEvent = new CustomEvent('dateselected', {
        detail: {
          startDate: `${this.firstDateSelected}`,
          endDate: `${this.lastDateSelected}`
        }
      });
      this.dispatchEvent(customEvent);
    } else if (this.thisWeekClicked == true) {
      this.firstDateSelected = this.showStartHighlightingDate;
      this.lastDateSelected = this.showEndHighlightingDate;
      this.thisWeekClicked = false;
      const customEvent = new CustomEvent('dateselected', {
        detail: {
          startDate: `${this.firstDateSelected}`,
          endDate: `${this.lastDateSelected}`
        }
      });
      this.dispatchEvent(customEvent);
    } else if (this.thisMonthClicked == true) {
      this.lastDayOfCurrentMonth = this.dayOfMonth(this.currentYear, this.currentMonthIndexed);

      this.firstDateSelected = `${month}/01/${this.currentYear}`;
      this.lastDateSelected = `${month}/${this.lastDayOfCurrentMonth}/${this.currentYear}`;
      this.thisMonthClicked = false;

      const customEvent = new CustomEvent('dateselected', {
        detail: {
          startDate: `${this.firstDateSelected}`,
          endDate: `${this.lastDateSelected}`
        }
      });
      this.dispatchEvent(customEvent);
    } else if (this.thisQuaterClicked == true) {
      let startingMonthIndexForQuater;
      let endingMonthIndexForQuater;

      // Get month indices
      for (let i = 0; i <= 11; i++) {
        if (this.months[i] == this.valueStartQuater) {
          startingMonthIndexForQuater = i;
        } else if (this.months[i] == this.valueEndQuater) {
          endingMonthIndexForQuater = i;
        }
      }

      let lastDayOfEndingMonthOfQuater = this.dayOfMonth(this.currentYear, endingMonthIndexForQuater);

      // Format month numbers with leading zeros
      let startMonth = (startingMonthIndexForQuater + 1).toString().padStart(2, '0');
      let endMonth = (endingMonthIndexForQuater + 1).toString().padStart(2, '0');

      this.firstDateSelected = `${startMonth}/01/${this.currentYear}`;
      this.lastDateSelected = `${endMonth}/${lastDayOfEndingMonthOfQuater}/${this.currentYear}`;
      this.thisQuaterClicked = false;

      const customEvent = new CustomEvent('dateselected', {
        detail: {
          startDate: `${this.firstDateSelected}`,
          endDate: `${this.lastDateSelected}`
        }
      });
      this.dispatchEvent(customEvent);
    } else if (this.thisYearClicked == true) {
      this.firstDateSelected = `01/01/${this.currentYear}`;
      this.lastDateSelected = `12/31/${this.currentYear}`;
      this.thisYearClicked = false;
      const customEvent = new CustomEvent('dateselected', {
        detail: {
          startDate: `${this.firstDateSelected}`,
          endDate: `${this.lastDateSelected}`
        }
      });
      this.dispatchEvent(customEvent);
    }
  }

  quaterMonthSet() {
    if (this.currentSelectedMonthIndex == 0 || this.currentSelectedMonthIndex == 1 || this.currentSelectedMonthIndex == 2) {
      this.valueStartQuater = 'January';
      this.valueEndQuater = 'March';
    } else if (this.currentSelectedMonthIndex == 3 || this.currentSelectedMonthIndex == 4 || this.currentSelectedMonthIndex == 5) {
      this.valueStartQuater = 'April';
      this.valueEndQuater = 'June';
    } else if (this.currentSelectedMonthIndex == 6 || this.currentSelectedMonthIndex == 7 || this.currentSelectedMonthIndex == 8) {
      this.valueStartQuater = 'July';
      this.valueEndQuater = 'September';
    } else if (this.currentSelectedMonthIndex == 9 || this.currentSelectedMonthIndex == 10 || this.currentSelectedMonthIndex == 11) {
      this.valueStartQuater = 'October';
      this.valueEndQuater = 'December';
    }
  }

  outSideOfComponentClicked() {
    console.log('outside called');
  }

  // Handle language change
  handleLanguageChange(message) {
    let language;
    if (message.language) {
      language = message.language;
    } else {
      language = message;
    }
    this.labels = JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
  }
}